"""Tool-specific power extraction hook.

Only this file needs to know how to run vsim, Innovus, Voltus, PrimeTime PX,
or another simulation and power-analysis flow.
"""

from __future__ import annotations

from .models import PowerRequest


def get_power(request: PowerRequest) -> float:
    """Return one instantaneous power sample.

    A future implementation can use the request fields to:

    1. Generate stimulus for ``request.operation``.
    2. Simulate ``request.design.netlist_path``.
    3. Produce VCD or SAIF switching activity.
    4. Run the selected power tool.
    5. Match instances using ``request.resource.netlist_strings``.
    6. Parse and return one power value as a float.

    Use one consistent unit for all returned values.
    """

    raise NotImplementedError(
        "power_backend.get_power() is not connected to a power-analysis flow"
    )
