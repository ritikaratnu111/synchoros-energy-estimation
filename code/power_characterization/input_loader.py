"""Load and validate SiLagoBlock, Operations, and Resources JSON files."""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any, Mapping, Sequence

from .errors import InputError
from .models import (
    BlockSpec,
    Neighbour,
    NeighbourConfiguration,
    OperationResource,
    OperationSpec,
    ResourceSpec,
)

LOG = logging.getLogger(__name__)


def load_json(path: Path) -> Any:
    try:
        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError as exc:
        raise InputError(f"Input file does not exist: {path}") from exc
    except json.JSONDecodeError as exc:
        raise InputError(
            f"Invalid JSON in {path} at line {exc.lineno}, "
            f"column {exc.colno}: {exc.msg}"
        ) from exc


def _require_string(obj: Mapping[str, Any], key: str, context: str) -> str:
    value = obj.get(key)
    if not isinstance(value, str) or not value.strip():
        raise InputError(f"{context}.{key} must be a non-empty string")
    return value.strip()


def _positive_int(value: Any, context: str) -> int:
    try:
        parsed = int(value)
    except (TypeError, ValueError) as exc:
        raise InputError(f"{context} must be an integer; got {value!r}") from exc
    if parsed < 1:
        raise InputError(f"{context} must be at least 1; got {parsed}")
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
    seen_blocks: set[str] = set()

    for block_index, record in enumerate(records):
        context = f"{source}[block {block_index}]"
        if not isinstance(record, Mapping):
            raise InputError(f"{context} must be an object")

        block_name = _require_string(record, "Name", context)
        if block_name in seen_blocks:
            raise InputError(f"Duplicate block name {block_name!r}")
        seen_blocks.add(block_name)

        raw_configs = record.get("ValidNeighborConfigurations")
        if not isinstance(raw_configs, list) or not raw_configs:
            raise InputError(
                f"{context}.ValidNeighborConfigurations must be a non-empty list"
            )

        configurations: list[NeighbourConfiguration] = []
        seen_configurations: set[str] = set()
        for config_index, raw_config in enumerate(raw_configs):
            config_context = (
                f"{context}.ValidNeighborConfigurations[{config_index}]"
            )
            if not isinstance(raw_config, Mapping):
                raise InputError(f"{config_context} must be an object")

            config_id = _require_string(raw_config, "Id", config_context)
            if config_id in seen_configurations:
                raise InputError(
                    f"Duplicate configuration ID {config_id!r} for {block_name!r}"
                )
            seen_configurations.add(config_id)

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
                    name=_require_string(raw_neighbour, "Name", neighbour_context),
                    alignment=_require_string(
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
                    description=str(raw_config.get("Description", "")).strip(),
                    neighbours=tuple(neighbours),
                )
            )

        raw_base_path = record.get("DesignBasePath")
        design_base_path = (
            Path(raw_base_path).expanduser()
            if isinstance(raw_base_path, str) and raw_base_path.strip()
            else None
        )
        blocks.append(
            BlockSpec(
                name=block_name,
                neighbour_configurations=tuple(configurations),
                design_base_path=design_base_path,
            )
        )

    return tuple(blocks)


def parse_operations(raw: Any, source: Path) -> tuple[OperationSpec, ...]:
    if not isinstance(raw, list) or not raw:
        raise InputError(f"{source} must contain a non-empty JSON list")

    operations: list[OperationSpec] = []
    seen_operations: set[str] = set()

    for operation_index, record in enumerate(raw):
        context = f"{source}[{operation_index}]"
        if not isinstance(record, Mapping):
            raise InputError(f"{context} must be an object")

        name = _require_string(record, "Name", context)
        if name in seen_operations:
            raise InputError(f"Duplicate operation name {name!r}")
        seen_operations.add(name)

        operation_cycles = _positive_int(record.get("Cycles"), f"{context}.Cycles")
        raw_resources = record.get("Resources")
        if not isinstance(raw_resources, list) or not raw_resources:
            raise InputError(f"{context}.Resources must be a non-empty list")

        operation_resources: list[OperationResource] = []
        seen_resources: set[str] = set()
        for resource_index, raw_resource in enumerate(raw_resources):
            resource_context = f"{context}.Resources[{resource_index}]"
            if not isinstance(raw_resource, Mapping):
                raise InputError(f"{resource_context} must be an object")

            resource_name = _require_string(raw_resource, "Name", resource_context)
            if resource_name in seen_resources:
                raise InputError(
                    f"Operation {name!r} lists resource {resource_name!r} twice"
                )
            seen_resources.add(resource_name)

            resource_cycles = _positive_int(
                raw_resource.get("Cycles"), f"{resource_context}.Cycles"
            )
            if resource_cycles > operation_cycles:
                LOG.warning(
                    "Operation %s occupies %s for %d cycles, exceeding its "
                    "declared %d cycles",
                    name,
                    resource_name,
                    resource_cycles,
                    operation_cycles,
                )
            operation_resources.append(
                OperationResource(name=resource_name, cycles=resource_cycles)
            )

        operations.append(
            OperationSpec(
                name=name,
                cycles=operation_cycles,
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

        name = _require_string(record, "Name", context)
        if name in resources:
            raise InputError(f"Duplicate resource name {name!r}")

        raw_strings = record.get("NetlistString")
        if not isinstance(raw_strings, list) or not raw_strings:
            raise InputError(f"{context}.NetlistString must be a non-empty list")

        netlist_strings: list[str] = []
        for string_index, value in enumerate(raw_strings):
            if not isinstance(value, str) or not value.strip():
                raise InputError(
                    f"{context}.NetlistString[{string_index}] must be non-empty"
                )
            netlist_strings.append(value.strip())

        resources[name] = ResourceSpec(
            name=name,
            description=str(record.get("Description", "")).strip(),
            netlist_strings=tuple(netlist_strings),
        )

    return resources


def reconcile_resources(
    operations: Sequence[OperationSpec],
    resources: Mapping[str, ResourceSpec],
    *,
    allow_undefined: bool,
) -> dict[str, ResourceSpec]:
    """Check that every operation resource has a Resources.json entry."""

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
            + ". Fix the JSON files or use --allow-undefined-resources."
        )

    for name in undefined:
        LOG.warning(
            "Resource %s is undefined; using its name as NetlistString", name
        )
        reconciled[name] = ResourceSpec(
            name=name,
            description="Automatically generated fallback resource",
            netlist_strings=(name,),
        )

    if unused:
        LOG.warning("Resources not used by any operation: %s", ", ".join(unused))

    return reconciled


def load_all_inputs(
    block_path: Path,
    operations_path: Path,
    resources_path: Path,
    *,
    allow_undefined_resources: bool,
) -> tuple[tuple[BlockSpec, ...], tuple[OperationSpec, ...], dict[str, ResourceSpec]]:
    blocks = parse_blocks(load_json(block_path), block_path)
    operations = parse_operations(load_json(operations_path), operations_path)
    resources = parse_resources(load_json(resources_path), resources_path)
    resources = reconcile_resources(
        operations,
        resources,
        allow_undefined=allow_undefined_resources,
    )
    return blocks, operations, resources
