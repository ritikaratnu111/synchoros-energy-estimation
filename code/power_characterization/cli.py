"""Command-line argument parsing and application entry point."""

from __future__ import annotations

import argparse
import logging
import math
import sys
from pathlib import Path
from typing import Sequence

from .errors import DesignResolutionError, InputError
from .runner import run

LOG = logging.getLogger("power_extraction")


def _positive_float(text: str) -> float:
    value = float(text)
    if not math.isfinite(value) or value <= 0.0:
        raise argparse.ArgumentTypeError("must be a finite number greater than zero")
    return value


def _positive_int(text: str) -> int:
    value = int(text)
    if value < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return value


def _nonnegative_int(text: str) -> int:
    value = int(text)
    if value < 0:
        raise argparse.ArgumentTypeError("must be at least 0")
    return value


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Extract per-operation, per-resource power until convergence."
    )
    parser.add_argument("--blocks", type=Path, required=True)
    parser.add_argument("--operations", type=Path, required=True)
    parser.add_argument("--resources", type=Path, required=True)

    design_group = parser.add_mutually_exclusive_group()
    design_group.add_argument(
        "--netlist",
        type=Path,
        help="One netlist.v; valid when exactly one configuration is listed",
    )
    design_group.add_argument(
        "--design-root",
        type=Path,
        help="Root containing a netlist.v for each explicit configuration",
    )
    parser.add_argument(
        "--design-manifest",
        type=Path,
        help="Optional JSON mapping configuration IDs to netlist paths",
    )

    parser.add_argument("--epsilon", type=_positive_float, required=True)
    parser.add_argument("--window-size", type=_positive_int, default=5)
    parser.add_argument("--minimum-iterations", type=_nonnegative_int, default=10)
    parser.add_argument("--maximum-iterations", type=_positive_int, default=1000)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("CharacterizedPower.json"),
    )
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--allow-undefined-resources", action="store_true")
    parser.add_argument("--fail-on-nonconvergence", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--verbose", action="store_true")
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
        return run(args)
    except (InputError, DesignResolutionError, RuntimeError, NotImplementedError) as exc:
        LOG.error("%s", exc)
        return 2


if __name__ == "__main__":
    sys.exit(main())
