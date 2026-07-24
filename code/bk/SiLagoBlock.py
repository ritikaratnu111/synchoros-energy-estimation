from __future__ import annotations
import json
from typing import List
from Resource import Resource
from Operation import Operation

class SiLagoBlock:
    def __init__(
        self,
        name: str,
        resources: List[Resource],
        valid_neighbor_topology: List[dict],
    ):
        self.name = name
        self.valid_neighbor_topology = valid_neighbor_topology
        self.resources = resources

    @staticmethod
    def load(data: dict) -> SiLagoBlock:
        base_path = data.get("DesignBasePath")
        resource_fpath = base_path + data.get("Resources")
        resources: List[Resource] = []
        if isinstance(resource_fpath, str):
            with open(resource_fpath, "r") as f:
                resource_dicts = json.load(f)
                resources = [Resource.load(r) for r in resource_dicts]

        for neighbor_cfg in data.get("ValidNeighborConfigurations", []):
            design = base_path + "/" + neighbor_cfg.get("Id") + "/" + "netlist.v"
            neighbor_cfg["Design"] = design
            ops = base_path + neighbor_cfg.get("Operations")
            if isinstance(ops, str):
                with open(ops, "r") as f:
                    operation_dicts = json.load(f)
                    neighbor_cfg["Operations"] = [ Operation.load(op_dict) for op_dict in operation_dicts]

        return SiLagoBlock(
            name=data["Name"],
            resources=resources,
            valid_neighbor_topology=data.get(
                "ValidNeighborConfigurations", []
            ),
        )
    
#with open("SiLagoBlockForHyCUBE.json", "r") as f:
#    data = json.load(f)
#
#silago_block = SiLagoBlock.load(data)
#    def get_resources(self):
#        return self.resources
#
#    def load_operations(self, ops_path: Path) -> None:
#        with ops_path.open() as f:
#            raw_ops = json.load(f)
#
#        for op_name, resources in raw_ops.items():
#            res_objs = [
#                ResourceUsage(r["name"], r["cycles"])
#                for r in resources
#            ]
#            self.operations[op_name] = Operation(op_name, res_objs)
