from dataclasses import dataclass, field
from typing import Any, Dict, List

@dataclass
class Topology:
    id: str
    blocks: List[Dict[str, str]] = field(default_factory=list)

    @classmethod
    def load(cls, data: Dict[str, Any]) -> "Topology":
        return cls(
            id=data.get("Id", ""),
            blocks=[
                {
                    "name": b.get("Name", ""),
                    "alignment": b.get("Alignment", ""),
                }
                for b in data.get("Topology", [])
            ],
        )

