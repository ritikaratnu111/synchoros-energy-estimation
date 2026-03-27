from dataclasses import dataclass
from typing import Any, Dict, List
from Resource import Resource

@dataclass
class Operation:
    Name: str
    Description: str
    Cycles: str
    Resources: List["Resource"]

    @staticmethod
    def load(data: Dict[str, Any]) -> "Operation":
        return Operation(
            Name=data.get("Name", ""),
            Description=data.get("Description", ""),
            Cycles=data.get("Cycles", ""),
            Resources=[
                Resource.load(r) for r in data.get("Resources", [])
            ],
        )

#data = {
#    "Name": "Op1",
#    "Description": "Example operation",
#    "Cycles": "10",
#    "Resources": [
#        {"Name": "R1", "Description": "Res 1", "NetlistString": ["n1"]},
#        {"Name": "R2", "Description": "Res 2", "NetlistString": ["n2", "n3"]},
#    ],
#}
#
#op = Operation.load(data)
#
#print(op)
#print(op.resources[0].name)
