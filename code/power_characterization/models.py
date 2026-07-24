"""Shared data structures used by the power-characterization flow."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


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
        if not self.neighbours:
            return "none"
        return "__".join(sorted(neighbour.token for neighbour in self.neighbours))


@dataclass(frozen=True)
class PowerRequest:
    design: DesignContext
    operation: OperationSpec
    operation_resource: OperationResource
    resource: ResourceSpec
    iteration: int


@dataclass(frozen=True)
class ConvergenceSettings:
    epsilon: float
    window_size: int
    minimum_iterations: int
    maximum_iterations: int


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
