"""High-level orchestration of loading, planning, characterization, and output."""

from __future__ import annotations

import argparse
import json
import logging
from dataclasses import asdict
from typing import Any

from .convergence import characterize
from .design_resolver import build_design_contexts, load_design_manifest
from .input_loader import load_all_inputs
from .models import ConvergenceSettings, DesignContext, OperationSpec
from .power_backend import get_power
from .result_store import (
    identity_from_record,
    load_existing,
    replace_result,
    write_output,
)

LOG = logging.getLogger(__name__)


def _work_item_count(
    designs: list[DesignContext], operations: tuple[OperationSpec, ...]
) -> int:
    resources_per_design = sum(len(operation.resources) for operation in operations)
    return len(designs) * resources_per_design


def _dry_run_plan(
    designs: list[DesignContext],
    operations: tuple[OperationSpec, ...],
    resource_names: list[str],
) -> dict[str, Any]:
    return {
        "design_scope": "explicit_valid_neighbour_configurations",
        "designs": [
            {
                "block": design.block_name,
                "configuration_id": design.configuration_id,
                "neighbours": [
                    {
                        "Name": neighbour.name,
                        "Alignment": neighbour.alignment,
                    }
                    for neighbour in design.neighbours
                ],
                "neighbour_key": design.neighbour_key,
                "netlist": str(design.netlist_path),
            }
            for design in designs
        ],
        "operations": [operation.name for operation in operations],
        "resources": resource_names,
        "characterization_items": _work_item_count(designs, operations),
    }


def run(args: argparse.Namespace) -> int:
    blocks, operations, resources = load_all_inputs(
        args.blocks,
        args.operations,
        args.resources,
        allow_undefined_resources=args.allow_undefined_resources,
    )
    manifest = load_design_manifest(args.design_manifest)
    designs = build_design_contexts(
        blocks,
        design_root=args.design_root,
        manifest=manifest,
        single_netlist=args.netlist,
    )

    total_items = _work_item_count(designs, operations)
    LOG.info(
        "Validated %d block(s), %d explicit configuration(s), %d operation(s), "
        "%d characterization item(s)",
        len(blocks),
        len(designs),
        len(operations),
        total_items,
    )

    if args.dry_run:
        print(
            json.dumps(
                _dry_run_plan(designs, operations, sorted(resources)),
                indent=2,
            )
        )
        return 0

    settings = ConvergenceSettings(
        epsilon=args.epsilon,
        window_size=args.window_size,
        minimum_iterations=args.minimum_iterations,
        maximum_iterations=args.maximum_iterations,
    )
    result_records = load_existing(args.output, args.resume)
    completed = {
        identity_from_record(record)
        for record in result_records
        if bool(record.get("converged"))
    }

    item_index = 0
    for design in designs:
        for operation in operations:
            for operation_resource in operation.resources:
                item_index += 1
                resource = resources[operation_resource.name]
                identity = (
                    design.block_name,
                    design.configuration_id,
                    design.neighbour_key,
                    operation.name,
                    resource.name,
                )
                if identity in completed:
                    LOG.info(
                        "[%d/%d] Skipping converged %s/%s/%s",
                        item_index,
                        total_items,
                        design.configuration_id,
                        operation.name,
                        resource.name,
                    )
                    continue

                LOG.info(
                    "[%d/%d] Characterizing config=%s operation=%s resource=%s",
                    item_index,
                    total_items,
                    design.configuration_id,
                    operation.name,
                    resource.name,
                )
                result = characterize(
                    design,
                    operation,
                    operation_resource,
                    resource,
                    settings,
                    sample_power=get_power,
                )
                result_records = replace_result(
                    result_records,
                    result,
                    asdict(result),
                )
                write_output(args.output, result_records, settings)

                if not result.converged:
                    message = (
                        f"Did not converge after {result.iterations} iterations: "
                        f"{design.configuration_id}/{operation.name}/{resource.name}"
                    )
                    if args.fail_on_nonconvergence:
                        raise RuntimeError(message)
                    LOG.warning(message)

    write_output(args.output, result_records, settings)
    LOG.info("Wrote %d result(s) to %s", len(result_records), args.output)
    return 0
