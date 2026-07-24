"""Checkpoint, resume, and output JSON handling."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Mapping, Sequence

from .errors import InputError
from .input_loader import load_json
from .models import CharacterizationResult, ConvergenceSettings

ResultIdentity = tuple[str, str, str, str, str]


def identity_from_record(record: Mapping[str, Any]) -> ResultIdentity:
    return (
        str(record.get("block", "")),
        str(record.get("configuration_id", "")),
        str(record.get("neighbour_key", "")),
        str(record.get("operation", "")),
        str(record.get("resource", "")),
    )


def load_existing(output_path: Path, resume: bool) -> list[dict[str, Any]]:
    if not resume or not output_path.exists():
        return []

    raw = load_json(output_path)
    if not isinstance(raw, Mapping) or not isinstance(raw.get("results"), list):
        raise InputError(
            f"Cannot resume from {output_path}: expected an object with a "
            "'results' list"
        )
    return [record for record in raw["results"] if isinstance(record, dict)]


def replace_result(
    records: Sequence[dict[str, Any]],
    result: CharacterizationResult,
    result_dict: dict[str, Any],
) -> list[dict[str, Any]]:
    updated = [
        record
        for record in records
        if identity_from_record(record) != result.identity
    ]
    updated.append(result_dict)
    return updated


def write_output(
    output_path: Path,
    results: Sequence[Mapping[str, Any]],
    settings: ConvergenceSettings,
) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "schema_version": 1,
        "power_unit": "defined by power_backend.get_power()",
        "design_scope": "explicit_valid_neighbour_configurations",
        "convergence": {
            "epsilon": settings.epsilon,
            "window_size": settings.window_size,
            "minimum_iterations": settings.minimum_iterations,
            "maximum_iterations": settings.maximum_iterations,
            "error_metric": "abs(P_inst - updated_running_mean)",
        },
        "results": list(results),
    }

    temporary_path = output_path.with_suffix(output_path.suffix + ".tmp")
    with temporary_path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")
    temporary_path.replace(output_path)
