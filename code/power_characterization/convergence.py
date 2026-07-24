"""Running-average and convergence logic from the supplied algorithm."""

from __future__ import annotations

import math
from collections import deque
from typing import Callable

from .models import (
    CharacterizationResult,
    ConvergenceSettings,
    DesignContext,
    OperationResource,
    OperationSpec,
    PowerRequest,
    ResourceSpec,
)

PowerSampler = Callable[[PowerRequest], float]


def characterize(
    design: DesignContext,
    operation: OperationSpec,
    operation_resource: OperationResource,
    resource: ResourceSpec,
    settings: ConvergenceSettings,
    sample_power: PowerSampler,
) -> CharacterizationResult:
    average_power = 0.0
    iteration_count = 0
    errors: deque[float] = deque(maxlen=settings.window_size)
    converged = False

    while not converged and iteration_count < settings.maximum_iterations:
        request = PowerRequest(
            design=design,
            operation=operation,
            operation_resource=operation_resource,
            resource=resource,
            iteration=iteration_count,
        )
        instantaneous_power = float(sample_power(request))
        if not math.isfinite(instantaneous_power):
            raise RuntimeError(
                f"Power backend returned a non-finite value for "
                f"{operation.name}/{resource.name}: {instantaneous_power!r}"
            )

        average_power = (
            iteration_count * average_power + instantaneous_power
        ) / (iteration_count + 1)
        iteration_count += 1

        if iteration_count > settings.minimum_iterations:
            error = abs(instantaneous_power - average_power)
            errors.append(error)
            if len(errors) == settings.window_size and all(
                value < settings.epsilon for value in errors
            ):
                converged = True

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
        epsilon=settings.epsilon,
        window_size=settings.window_size,
        minimum_iterations=settings.minimum_iterations,
        maximum_iterations=settings.maximum_iterations,
        final_error_window=list(errors),
    )
