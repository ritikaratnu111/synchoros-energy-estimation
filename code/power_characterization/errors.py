"""Application-specific exceptions."""


class InputError(ValueError):
    """Raised when an input file is missing, malformed, or inconsistent."""


class DesignResolutionError(InputError):
    """Raised when a netlist cannot be associated with a configuration."""
