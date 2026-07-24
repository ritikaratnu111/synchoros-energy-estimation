#!/usr/bin/env python3
"""

Inputs
------
1. SiLagoBlock.json
2. Operations.json
3. Resources.json
4. Design netlist.v.

get_power function should consist of tool-specific power flow.  It needs to return one instantaneous power sample as a float.

"""

from __future__ import annotations

import argparse
import json
import logging
import math
import sys
from collections import deque
from dataclasses import asdict, dataclass
from itertools import combinations
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

LOG = logging.getLogger("power_extraction")


class InputError(ValueError):
    """Raised when an input file is missing, malformed, or inconsistent."""


class DesignResolutionError(InputError):
    """Raised when no netlist can be associated with a design configuration."""


@dataclass(frozen=True)
class Neighbour:
    name: str
    alignment: str

    @property
    def token(self) -> str:
        return f"{self.alignment.lower()}-{self.name.lower()}"


@dataclass(frozen=True)
class NeighbourConfiguration:
    config_id: str
    description: str
    neighbours: tuple[Neighbour, ...]


@dataclass(frozen=True)
class BlockSpec:
    name: str
    neighbour_configurations: tuple[NeighbourConfiguration, ...]
    design_base_path: Path | None


@dataclass(frozen=True)
class OperationResource:
    name: str
    cycles: int


@dataclass(frozen=True)
class OperationSpec:
    name: str
    cycles: int
    resources: tuple[OperationResource, ...]


@dataclass(frozen=True)
class ResourceSpec:
    name: str
    description: str
    netlist_strings: tuple[str, ...]


@dataclass(frozen=True)
class DesignContext:
    block_name: str
    configuration_id: str
    neighbours: tuple[Neighbour, ...]
    netlist_path: Path

    @property
    def neighbour_key(self) -> str:
        return neighbour_key(self.neighbours)


@dataclass(frozen=True)
class PowerRequest:
    design: DesignContext
    operation: OperationSpec
    operation_resource: OperationResource
    resource: ResourceSpec
    iteration: int


@dataclass
class CharacterizationResult:
    block: str
    configuration_id: str
    neighbours: list[dict[str, str]]
    neighbour_key: str
    netlist: str
    operation: str
    operation_cycles: int
    resource: str
    resource_cycles: int
    netlist_strings: list[str]
    average_power: float
    iterations: int
    converged: bool
    epsilon: float
    window_size: int
    minimum_iterations: int
    maximum_iterations: int
    final_error_window: list[float]

    @property
    def identity(self) -> tuple[str, str, str, str, str]:
        return (
            self.block,
            self.configuration_id,
            self.neighbour_key,
            self.operation,
            self.resource,
        )


# ---------------------------------------------------------------------------
# Power-tool integration hook
# ---------------------------------------------------------------------------

def get_power(request: PowerRequest) -> float:
    """Return one instantaneous power sample for a resource and operation.

    Implement this function for the chosen tool flow. E.g., ``vsim`` to produce switching activity (VCD/SAIF), Innovus, PrimeTime PX, Voltus, for post-route power.
    """

    raise NotImplementedError(
        "get_power() has not been connected to a simulation/power-analysis flow"
    )


# ---------------------------------------------------------------------------
# JSON loading and validation
# ---------------------------------------------------------------------------

def load_json(path: Path) -> Any:
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError as exc:
        raise InputError(f"Input file does not exist: {path}") from exc
    except json.JSONDecodeError as exc:
        raise InputError(
            f"Invalid JSON in {path} at line {exc.lineno}, column {exc.colno}: "
            f"{exc.msg}"
        ) from exc


def require_string(obj: Mapping[str, Any], key: str, context: str) -> str:
    value = obj.get(key)
    if not isinstance(value, str) or not value.strip():
        raise InputError(f"{context}.{key} must be a non-empty string")
    return value.strip()


def parse_positive_int(value: Any, context: str, *, allow_zero: bool = False) -> int:
    try:
        parsed = int(value)
    except (TypeError, ValueError) as exc:
        raise InputError(f"{context} must be an integer; got {value!r}") from exc
    minimum = 0 if allow_zero else 1
    if parsed < minimum:
        raise InputError(f"{context} must be >= {minimum}; got {parsed}")
    return parsed


def parse_blocks(raw: Any, source: Path) -> tuple[BlockSpec, ...]:
    if isinstance(raw, Mapping) and "Blocks" in raw:
        records = raw["Blocks"]
    elif isinstance(raw, list):
        records = raw
    elif isinstance(raw, Mapping):
        records = [raw]
    else:
        raise InputError(f"{source} must contain an object, list, or 'Blocks' list")

    if not isinstance(records, list) or not records:
        raise InputError(f"{source} contains no SiLago block definitions")

    blocks: list[BlockSpec] = []
    seen_names: set[str] = set()

    for block_index, record in enumerate(records):
        context = f"{source}[block {block_index}]"
        if not isinstance(record, Mapping):
            raise InputError(f"{context} must be an object")

        name = require_string(record, "Name", context)
        if name in seen_names:
            raise InputError(f"Duplicate block name {name!r} in {source}")
        seen_names.add(name)

        raw_configs = record.get("ValidNeighborConfigurations", [])
        if not isinstance(raw_configs, list) or not raw_configs:
            raise InputError(
                f"{context}.ValidNeighborConfigurations must be a non-empty list"
            )

        configurations: list[NeighbourConfiguration] = []
        seen_config_ids: set[str] = set()
        for config_index, raw_config in enumerate(raw_configs):
            config_context = (
                f"{context}.ValidNeighborConfigurations[{config_index}]"
            )
            if not isinstance(raw_config, Mapping):
                raise InputError(f"{config_context} must be an object")

            config_id = require_string(raw_config, "Id", config_context)
            if config_id in seen_config_ids:
                raise InputError(
                    f"Duplicate neighbour configuration ID {config_id!r} "
                    f"for block {name!r}"
                )
            seen_config_ids.add(config_id)

            description = str(raw_config.get("Description", "")).strip()
            raw_neighbours = raw_config.get("Neighbours", [])
            if not isinstance(raw_neighbours, list):
                raise InputError(f"{config_context}.Neighbours must be a list")

            neighbours: list[Neighbour] = []
            seen_neighbours: set[tuple[str, str]] = set()
            for neighbour_index, raw_neighbour in enumerate(raw_neighbours):
                neighbour_context = (
                    f"{config_context}.Neighbours[{neighbour_index}]"
                )
                if not isinstance(raw_neighbour, Mapping):
                    raise InputError(f"{neighbour_context} must be an object")
                neighbour = Neighbour(
                    name=require_string(raw_neighbour, "Name", neighbour_context),
                    alignment=require_string(
                        raw_neighbour, "Alignment", neighbour_context
                    ),
                )
                identity = (neighbour.name, neighbour.alignment)
                if identity in seen_neighbours:
                    raise InputError(
                        f"Duplicate neighbour {identity!r} in {config_context}"
                    )
                seen_neighbours.add(identity)
                neighbours.append(neighbour)

            configurations.append(
                NeighbourConfiguration(
                    config_id=config_id,
                    description=description,
                    neighbours=tuple(neighbours),
                )
            )

        raw_base = record.get("DesignBasePath")
        base_path = (
            Path(raw_base).expanduser() if isinstance(raw_base, str) else None
        )
        blocks.append(
            BlockSpec(
                name=name,
                neighbour_configurations=tuple(configurations),
                design_base_path=base_path,
            )
        )

    return tuple(blocks)


def parse_operations(raw: Any, source: Path) -> tuple[OperationSpec, ...]:
    if not isinstance(raw, list) or not raw:
        raise InputError(f"{source} must contain a non-empty JSON list")

    operations: list[OperationSpec] = []
    seen_names: set[str] = set()
    for operation_index, record in enumerate(raw):
        context = f"{source}[{operation_index}]"
        if not isinstance(record, Mapping):
            raise InputError(f"{context} must be an object")

        name = require_string(record, "Name", context)
        if name in seen_names:
            raise InputError(f"Duplicate operation name {name!r} in {source}")
        seen_names.add(name)
        cycles = parse_positive_int(record.get("Cycles"), f"{context}.Cycles")

        raw_resources = record.get("Resources", [])
        if not isinstance(raw_resources, list) or not raw_resources:
            raise InputError(f"{context}.Resources must be a non-empty list")

        operation_resources: list[OperationResource] = []
        seen_resource_names: set[str] = set()
        for resource_index, raw_resource in enumerate(raw_resources):
            resource_context = f"{context}.Resources[{resource_index}]"
            if not isinstance(raw_resource, Mapping):
                raise InputError(f"{resource_context} must be an object")
            resource_name = require_string(raw_resource, "Name", resource_context)
            if resource_name in seen_resource_names:
                raise InputError(
                    f"Operation {name!r} lists resource {resource_name!r} more than once"
                )
            seen_resource_names.add(resource_name)
            resource_cycles = parse_positive_int(
                raw_resource.get("Cycles"), f"{resource_context}.Cycles"
            )
            if resource_cycles > cycles:
                LOG.warning(
                    "Operation %s occupies resource %s for %d cycles, exceeding "
                    "the operation's declared %d cycles",
                    name,
                    resource_name,
                    resource_cycles,
                    cycles,
                )
            operation_resources.append(
                OperationResource(name=resource_name, cycles=resource_cycles)
            )

        operations.append(
            OperationSpec(
                name=name,
                cycles=cycles,
                resources=tuple(operation_resources),
            )
        )

    return tuple(operations)


def parse_resources(raw: Any, source: Path) -> dict[str, ResourceSpec]:
    if not isinstance(raw, list) or not raw:
        raise InputError(f"{source} must contain a non-empty JSON list")

    resources: dict[str, ResourceSpec] = {}
    for resource_index, record in enumerate(raw):
        context = f"{source}[{resource_index}]"
        if not isinstance(record, Mapping):
            raise InputError(f"{context} must be an object")

        name = require_string(record, "Name", context)
        if name in resources:
            raise InputError(f"Duplicate resource name {name!r} in {source}")

        description = str(record.get("Description", "")).strip()
        raw_strings = record.get("NetlistString", [])
        if not isinstance(raw_strings, list) or not raw_strings:
            raise InputError(f"{context}.NetlistString must be a non-empty list")
        netlist_strings: list[str] = []
        for string_index, value in enumerate(raw_strings):
            if not isinstance(value, str) or not value.strip():
                raise InputError(
                    f"{context}.NetlistString[{string_index}] must be a "
                    "non-empty string"
                )
            netlist_strings.append(value.strip())

        resources[name] = ResourceSpec(
            name=name,
            description=description,
            netlist_strings=tuple(netlist_strings),
        )

    return resources


def reconcile_operation_resources(
    operations: Sequence[OperationSpec],
    resources: Mapping[str, ResourceSpec],
    *,
    allow_undefined: bool,
) -> dict[str, ResourceSpec]:
    reconciled = dict(resources)
    used_names = {
        operation_resource.name
        for operation in operations
        for operation_resource in operation.resources
    }
    undefined = sorted(used_names - set(resources))
    unused = sorted(set(resources) - used_names)

    if undefined and not allow_undefined:
        raise InputError(
            "Operations.json references resources absent from Resources.json: "
            + ", ".join(undefined)
            + ". Update the JSON files or pass --allow-undefined-resources "
            "to use each missing resource name as its fallback NetlistString."
        )

    for name in undefined:
        LOG.warning(
            "Resource %s is undefined; using fallback NetlistString [%r]",
            name,
            name,
        )
        reconciled[name] = ResourceSpec(
            name=name,
            description="Automatically generated fallback resource",
            netlist_strings=(name,),
        )

    if unused:
        LOG.warning(
            "Resources not referenced by any operation: %s", ", ".join(unused)
        )

    return reconciled


# ---------------------------------------------------------------------------
# Neighbour-set and design resolution
# ---------------------------------------------------------------------------

def neighbour_key(neighbours: Sequence[Neighbour]) -> str:
    if not neighbours:
        return "none"
    return "__".join(sorted(neighbour.token for neighbour in neighbours))


def iter_neighbour_sets(
    configuration: NeighbourConfiguration,
    mode: str,
) -> Iterable[tuple[Neighbour, ...]]:
    if mode == "configurations":
        yield configuration.neighbours
        return
    if mode != "all-subsets":
        raise InputError(f"Unsupported neighbour mode: {mode}")

    neighbours = configuration.neighbours
    for subset_size in range(len(neighbours) + 1):
        for subset in combinations(neighbours, subset_size):
            yield tuple(subset)


def load_design_manifest(path: Path | None) -> Mapping[str, Any]:
    if path is None:
        return {}
    raw = load_json(path)
    if not isinstance(raw, Mapping):
        raise InputError(f"Design manifest {path} must contain a JSON object")
    return raw


def manifest_lookup(
    manifest: Mapping[str, Any],
    block: BlockSpec,
    configuration: NeighbourConfiguration,
    neighbours: Sequence[Neighbour],
) -> Path | None:
    """Resolve a path from several convenient manifest key formats.

    Supported flat keys, checked in order:

    * ``Block/Configuration/NeighbourKey``
    * ``Configuration/NeighbourKey``
    * ``Block/NeighbourKey``
    * ``NeighbourKey``
    * ``Configuration``

    A nested ``manifest[block][configuration][neighbour_key]`` object is also
    accepted.
    """

    key = neighbour_key(neighbours)
    flat_candidates = (
        f"{block.name}/{configuration.config_id}/{key}",
        f"{configuration.config_id}/{key}",
        f"{block.name}/{key}",
        key,
        configuration.config_id,
    )
    for candidate in flat_candidates:
        value = manifest.get(candidate)
        if isinstance(value, str) and value.strip():
            return Path(value).expanduser()

    nested: Any = manifest.get(block.name)
    if isinstance(nested, Mapping):
        nested = nested.get(configuration.config_id)
        if isinstance(nested, Mapping):
            value = nested.get(key)
            if isinstance(value, str) and value.strip():
                return Path(value).expanduser()
        elif isinstance(nested, str) and nested.strip():
            return Path(nested).expanduser()

    return None


def resolve_design_path(
    block: BlockSpec,
    configuration: NeighbourConfiguration,
    neighbours: Sequence[Neighbour],
    *,
    design_root: Path | None,
    manifest: Mapping[str, Any],
    single_netlist: Path | None,
    total_designs: int,
) -> Path:
    if single_netlist is not None:
        if total_designs != 1:
            raise DesignResolutionError(
                "--netlist may only be used when exactly one design is planned; "
                f"the current inputs produce {total_designs} designs"
            )
        path = single_netlist.expanduser()
        if not path.is_file():
            raise DesignResolutionError(f"Netlist does not exist: {path}")
        return path.resolve()

    manifest_path = manifest_lookup(manifest, block, configuration, neighbours)
    if manifest_path is not None:
        if not manifest_path.is_absolute() and design_root is not None:
            manifest_path = design_root / manifest_path
        if not manifest_path.is_file():
            raise DesignResolutionError(
                f"Manifest-selected netlist does not exist: {manifest_path}"
            )
        return manifest_path.resolve()

    root = design_root or block.design_base_path
    if root is None:
        raise DesignResolutionError(
            f"No design root is available for block {block.name!r}. Pass "
            "--design-root, --design-manifest, or --netlist."
        )
    root = root.expanduser()
    key = neighbour_key(neighbours)

    candidates = (
        root / block.name / configuration.config_id / key / "netlist.v",
        root / configuration.config_id / key / "netlist.v",
        root / block.name / key / "netlist.v",
        root / key / "netlist.v",
        root / configuration.config_id / "netlist.v",
        root / "netlist.v",
    )
    for candidate in candidates:
        if candidate.is_file():
            return candidate.resolve()

    tried = "\n  - ".join(str(candidate) for candidate in candidates)
    raise DesignResolutionError(
        f"Could not resolve netlist for block={block.name!r}, "
        f"configuration={configuration.config_id!r}, neighbours={key!r}. "
        f"Tried:\n  - {tried}\n"
        "Use --design-manifest when your design directory uses another naming "
        "scheme."
    )


def build_design_contexts(
    blocks: Sequence[BlockSpec],
    *,
    neighbour_mode: str,
    design_root: Path | None,
    manifest: Mapping[str, Any],
    single_netlist: Path | None,
) -> list[DesignContext]:
    planned: list[tuple[BlockSpec, NeighbourConfiguration, tuple[Neighbour, ...]]] = []
    seen: set[tuple[str, str, str]] = set()

    for block in blocks:
        for configuration in block.neighbour_configurations:
            for neighbours in iter_neighbour_sets(configuration, neighbour_mode):
                identity = (
                    block.name,
                    configuration.config_id,
                    neighbour_key(neighbours),
                )
                if identity in seen:
                    continue
                seen.add(identity)
                planned.append((block, configuration, neighbours))

    contexts: list[DesignContext] = []
    for block, configuration, neighbours in planned:
        contexts.append(
            DesignContext(
                block_name=block.name,
                configuration_id=configuration.config_id,
                neighbours=neighbours,
                netlist_path=resolve_design_path(
                    block,
                    configuration,
                    neighbours,
                    design_root=design_root,
                    manifest=manifest,
                    single_netlist=single_netlist,
                    total_designs=len(planned),
                ),
            )
        )
    return contexts


# ---------------------------------------------------------------------------
# Characterization and output
# ---------------------------------------------------------------------------

def characterize_resource_operation(
    design: DesignContext,
    operation: OperationSpec,
    operation_resource: OperationResource,
    resource: ResourceSpec,
    *,
    epsilon: float,
    window_size: int,
    minimum_iterations: int,
    maximum_iterations: int,
) -> CharacterizationResult:
    average_power = 0.0
    iteration_count = 0
    errors: deque[float] = deque(maxlen=window_size)
    converged = False

    while not converged and iteration_count < maximum_iterations:
        request = PowerRequest(
            design=design,
            operation=operation,
            operation_resource=operation_resource,
            resource=resource,
            iteration=iteration_count,
        )
        instantaneous_power = float(get_power(request))
        if not math.isfinite(instantaneous_power):
            raise RuntimeError(
                f"get_power returned a non-finite value for "
                f"{operation.name}/{resource.name}: {instantaneous_power!r}"
            )

        # Running mean from the supplied algorithm.
        average_power = (
            iteration_count * average_power + instantaneous_power
        ) / (iteration_count + 1)
        iteration_count += 1

        if iteration_count > minimum_iterations:
            error = abs(instantaneous_power - average_power)
            errors.append(error)
            if len(errors) == window_size and all(
                current_error < epsilon for current_error in errors
            ):
                converged = True

        LOG.debug(
            "block=%s config=%s neighbours=%s op=%s resource=%s k=%d "
            "sample=%g mean=%g errors=%s converged=%s",
            design.block_name,
            design.configuration_id,
            design.neighbour_key,
            operation.name,
            resource.name,
            iteration_count,
            instantaneous_power,
            average_power,
            list(errors),
            converged,
        )

    return CharacterizationResult(
        block=design.block_name,
        configuration_id=design.configuration_id,
        neighbours=[
            {"Name": neighbour.name, "Alignment": neighbour.alignment}
            for neighbour in design.neighbours
        ],
        neighbour_key=design.neighbour_key,
        netlist=str(design.netlist_path),
        operation=operation.name,
        operation_cycles=operation.cycles,
        resource=resource.name,
        resource_cycles=operation_resource.cycles,
        netlist_strings=list(resource.netlist_strings),
        average_power=average_power,
        iterations=iteration_count,
        converged=converged,
        epsilon=epsilon,
        window_size=window_size,
        minimum_iterations=minimum_iterations,
        maximum_iterations=maximum_iterations,
        final_error_window=list(errors),
    )


def result_identity_from_dict(record: Mapping[str, Any]) -> tuple[str, str, str, str, str]:
    return (
        str(record.get("block", "")),
        str(record.get("configuration_id", "")),
        str(record.get("neighbour_key", "")),
        str(record.get("operation", "")),
        str(record.get("resource", "")),
    )


def load_existing_results(output_path: Path, resume: bool) -> list[dict[str, Any]]:
    if not resume or not output_path.exists():
        return []
    raw = load_json(output_path)
    if not isinstance(raw, Mapping) or not isinstance(raw.get("results"), list):
        raise InputError(
            f"Cannot resume from {output_path}: expected an object with a "
            "'results' list"
        )
    return [record for record in raw["results"] if isinstance(record, dict)]


def write_output(
    output_path: Path,
    results: Sequence[Mapping[str, Any]],
    *,
    epsilon: float,
    window_size: int,
    minimum_iterations: int,
    maximum_iterations: int,
    neighbour_mode: str,
) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "schema_version": 1,
        "power_unit": "defined by get_power()",
        "convergence": {
            "epsilon": epsilon,
            "window_size": window_size,
            "minimum_iterations": minimum_iterations,
            "maximum_iterations": maximum_iterations,
            "error_metric": "abs(P_inst - updated_running_mean)",
        },
        "neighbour_mode": neighbour_mode,
        "results": list(results),
    }
    temporary_path = output_path.with_suffix(output_path.suffix + ".tmp")
    with temporary_path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")
    temporary_path.replace(output_path)


def count_work_items(
    designs: Sequence[DesignContext], operations: Sequence[OperationSpec]
) -> int:
    resources_per_design = sum(len(operation.resources) for operation in operations)
    return len(designs) * resources_per_design


def run_characterization(args: argparse.Namespace) -> int:
    blocks = parse_blocks(load_json(args.blocks), args.blocks)
    operations = parse_operations(load_json(args.operations), args.operations)
    resources = parse_resources(load_json(args.resources), args.resources)
    resources = reconcile_operation_resources(
        operations,
        resources,
        allow_undefined=args.allow_undefined_resources,
    )

    manifest = load_design_manifest(args.design_manifest)
    designs = build_design_contexts(
        blocks,
        neighbour_mode=args.neighbour_mode,
        design_root=args.design_root,
        manifest=manifest,
        single_netlist=args.netlist,
    )

    total_items = count_work_items(designs, operations)
    LOG.info(
        "Validated %d block(s), %d design(s), %d operation(s), %d resource "
        "characterization item(s)",
        len(blocks),
        len(designs),
        len(operations),
        total_items,
    )

    if args.dry_run:
        plan = {
            "blocks": [block.name for block in blocks],
            "designs": [
                {
                    "block": design.block_name,
                    "configuration_id": design.configuration_id,
                    "neighbour_key": design.neighbour_key,
                    "netlist": str(design.netlist_path),
                }
                for design in designs
            ],
            "operations": [operation.name for operation in operations],
            "resources": sorted(resources),
            "characterization_items": total_items,
        }
        print(json.dumps(plan, indent=2))
        return 0

    existing_results = load_existing_results(args.output, args.resume)
    completed = {
        result_identity_from_dict(record)
        for record in existing_results
        if bool(record.get("converged"))
    }
    result_records: list[dict[str, Any]] = list(existing_results)

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
                        "[%d/%d] Skipping converged result %s/%s/%s",
                        item_index,
                        total_items,
                        design.neighbour_key,
                        operation.name,
                        resource.name,
                    )
                    continue

                LOG.info(
                    "[%d/%d] Characterizing block=%s config=%s neighbours=%s "
                    "operation=%s resource=%s",
                    item_index,
                    total_items,
                    design.block_name,
                    design.configuration_id,
                    design.neighbour_key,
                    operation.name,
                    resource.name,
                )
                result = characterize_resource_operation(
                    design,
                    operation,
                    operation_resource,
                    resource,
                    epsilon=args.epsilon,
                    window_size=args.window_size,
                    minimum_iterations=args.minimum_iterations,
                    maximum_iterations=args.maximum_iterations,
                )

                # Replace a stale/non-converged record with the same identity.
                result_records = [
                    record
                    for record in result_records
                    if result_identity_from_dict(record) != result.identity
                ]
                result_records.append(asdict(result))
                write_output(
                    args.output,
                    result_records,
                    epsilon=args.epsilon,
                    window_size=args.window_size,
                    minimum_iterations=args.minimum_iterations,
                    maximum_iterations=args.maximum_iterations,
                    neighbour_mode=args.neighbour_mode,
                )

                if not result.converged:
                    message = (
                        f"Did not converge after {result.iterations} iterations: "
                        f"{design.neighbour_key}/{operation.name}/{resource.name}"
                    )
                    if args.fail_on_nonconvergence:
                        raise RuntimeError(message)
                    LOG.warning(message)

    write_output(
        args.output,
        result_records,
        epsilon=args.epsilon,
        window_size=args.window_size,
        minimum_iterations=args.minimum_iterations,
        maximum_iterations=args.maximum_iterations,
        neighbour_mode=args.neighbour_mode,
    )
    LOG.info("Wrote %d result(s) to %s", len(result_records), args.output)
    return 0


def positive_float(text: str) -> float:
    value = float(text)
    if not math.isfinite(value) or value <= 0.0:
        raise argparse.ArgumentTypeError("must be a finite number greater than zero")
    return value


def positive_cli_int(text: str) -> int:
    value = int(text)
    if value < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return value


def nonnegative_cli_int(text: str) -> int:
    value = int(text)
    if value < 0:
        raise argparse.ArgumentTypeError("must be at least 0")
    return value


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Extract per-operation, per-resource power until convergence."
    )
    parser.add_argument("--blocks", type=Path, required=True, help="SiLagoBlock.json")
    parser.add_argument(
        "--operations", type=Path, required=True, help="Operations.json"
    )
    parser.add_argument("--resources", type=Path, required=True, help="Resources.json")

    design_group = parser.add_mutually_exclusive_group()
    design_group.add_argument(
        "--design-root",
        type=Path,
        help="Root directory containing abutment-generated netlist.v designs",
    )
    design_group.add_argument(
        "--netlist",
        type=Path,
        help="A single netlist.v; valid only when one design is planned",
    )
    parser.add_argument(
        "--design-manifest",
        type=Path,
        help="Optional JSON mapping configurations/neighbour keys to netlist paths",
    )

    parser.add_argument(
        "--neighbour-mode",
        choices=("configurations", "all-subsets"),
        default="all-subsets",
        help=(
            "Use each listed neighbour configuration as one design, or enumerate "
            "every subset of its valid neighbours (default: all-subsets)"
        ),
    )
    parser.add_argument(
        "--epsilon",
        type=positive_float,
        required=True,
        help="Absolute convergence threshold in the power unit returned by get_power",
    )
    parser.add_argument(
        "--window-size",
        type=positive_cli_int,
        default=5,
        help="Number of consecutive errors required below epsilon (default: 5)",
    )
    parser.add_argument(
        "--minimum-iterations",
        type=nonnegative_cli_int,
        default=10,
        help="Do not evaluate convergence until k > this value (default: 10)",
    )
    parser.add_argument(
        "--maximum-iterations",
        type=positive_cli_int,
        default=1000,
        help="Safety limit for each resource/operation pair (default: 1000)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("CharacterizedPower.json"),
        help="Output/checkpoint JSON path (default: CharacterizedPower.json)",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Reuse converged records already present in the output file",
    )
    parser.add_argument(
        "--allow-undefined-resources",
        action="store_true",
        help="Create fallback resources when Operations.json uses undefined names",
    )
    parser.add_argument(
        "--fail-on-nonconvergence",
        action="store_true",
        help="Stop if a pair reaches maximum iterations without converging",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate inputs and print the planned work without calling get_power",
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Enable per-sample debug logging"
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    if args.maximum_iterations <= args.minimum_iterations:
        parser.error("--maximum-iterations must exceed --minimum-iterations")

    try:
        return run_characterization(args)
    except (InputError, DesignResolutionError, RuntimeError, NotImplementedError) as exc:
        LOG.error("%s", exc)
        return 2


if __name__ == "__main__":
    sys.exit(main())
