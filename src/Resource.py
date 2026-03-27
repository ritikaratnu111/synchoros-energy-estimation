from dataclasses import dataclass
from typing import Any, Dict, List

@dataclass
class Resource:
    Name: str
    Description: str
    Netlist_string: List[str]

    @staticmethod
    def load(data: Dict[str, Any]) -> "Resource":
        return Resource(
            Name=data.get("Name"),
            Description=data.get("Description"),
            Netlist_string=data.get("NetlistString", []),
        )
