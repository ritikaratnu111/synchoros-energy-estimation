from __future__ import annotations
import sys
import argparse
import json
import logging
from pathlib import Path
from typing import Dict, Tuple, List
from collections import deque


def main():
    parser = argparse.ArgumentParser()
    for arg in ("isa", "ops", "arch"):
        parser.add_argument(f"--{arg}", required=True)
    
    run(parser.parse_args())

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.exception("Fatal error")
        sys.exit(1)
