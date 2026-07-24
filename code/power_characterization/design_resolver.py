"""Associate each explicit neighbour configuration with one netlist.v file."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Mapping, Sequence

from .errors import DesignResolutionError, InputError
from .input_loader import load_json
from .models import BlockSpec, DesignContext, NeighbourConfiguration


def load_design_manifest(path: Path | None) -> Mapping[str, Any]:
    if path is None:
        return {}
    raw = load_json(path)
    if not isinstance(raw, Mapping):
        raise InputError(f"Design manifest {path} must contain a JSON object")
    return raw


def _configuration_key(block: BlockSpec, config: NeighbourConfiguration) -> str:
    return f"{block.name}/{config.config_id}"


def _manifest_lookup(
    manifest: Mapping[str, Any],
    block: BlockSpec,
    config: NeighbourConfiguration,
) -> Path | None:
    flat_keys = (
        _configuration_key(block, config),
        config.config_id,
    )
    for key in flat_keys:
        value = manifest.get(key)
        if isinstance(value, str) and value.strip():
            return Path(value).expanduser()

    nested = manifest.get(block.name)
    if isinstance(nested, Mapping):
        value = nested.get(config.config_id)
        if isinstance(value, str) and value.strip():
            return Path(value).expanduser()

    return None


def _resolve_one(
    block: BlockSpec,
    config: NeighbourConfiguration,
    *,
    design_root: Path | None,
    manifest: Mapping[str, Any],
    single_netlist: Path | None,
    total_configurations: int,
) -> Path:
    if single_netlist is not None:
        if total_configurations != 1:
            raise DesignResolutionError(
                "--netlist can only be used when the inputs contain exactly one "
                f"explicit configuration; found {total_configurations}"
            )
        path = single_netlist.expanduser()
        if not path.is_file():
            raise DesignResolutionError(f"Netlist does not exist: {path}")
        return path.resolve()

    manifest_path = _manifest_lookup(manifest, block, config)
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
            f"No netlist location is available for {block.name}/{config.config_id}. "
            "Use --netlist, --design-root, or --design-manifest."
        )
    root = root.expanduser()

    candidates = (
        root / block.name / config.config_id / "netlist.v",
        root / config.config_id / "netlist.v",
        root / block.name / "netlist.v",
        root / "netlist.v",
    )
    for candidate in candidates:
        if candidate.is_file():
            return candidate.resolve()

    tried = "\n  - ".join(str(candidate) for candidate in candidates)
    raise DesignResolutionError(
        f"Could not resolve netlist for {block.name}/{config.config_id}. "
        f"Tried:\n  - {tried}"
    )


def build_design_contexts(
    blocks: Sequence[BlockSpec],
    *,
    design_root: Path | None,
    manifest: Mapping[str, Any],
    single_netlist: Path | None,
) -> list[DesignContext]:
    """Create exactly one design for each listed configuration.

    The neighbours inside a configuration are metadata for that complete design.
    They are never expanded into subsets.
    """

    planned = [
        (block, config)
        for block in blocks
        for config in block.neighbour_configurations
    ]

    contexts: list[DesignContext] = []
    for block, config in planned:
        contexts.append(
            DesignContext(
                block_name=block.name,
                configuration_id=config.config_id,
                neighbours=config.neighbours,
                netlist_path=_resolve_one(
                    block,
                    config,
                    design_root=design_root,
                    manifest=manifest,
                    single_netlist=single_netlist,
                    total_configurations=len(planned),
                ),
            )
        )
    return contexts
