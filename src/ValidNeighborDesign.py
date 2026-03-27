class ValidNeighborDesign():
    def __init__(self, block: SiLagoBlock, neighbors: tuple) -> None:
        self.cells = {}
        self.applied_ops = {}

    def load_design(self, arch_path: Path)-> None:
        with arch_path.open() as f:
            self.cells = json.load(f)

    def resolve_placeholders(self) -> None:
        PLACEHOLDER = ".."
    
        for _, cells in self.cells.items():
            previous_cell_resources: List[dict] = []
            for cell in cells:
                resources = cell.get("resource")
                if resources == PLACEHOLDER:
                    cell["resource"] = list(previous_cell_resources)
                else:
                    prev_cell_resources = cell.get("resource", [])

    def flatten_arch(self)-> None:
        for _, cells in self.cells.items():
            for cell in cells:
                cell_id = cell.get("id")
                for resource in cell.get("resource", []):
                    base = resource.get("id")
                    resource["qualified_id"] = f"{cell_id}*{base}"
                   # print(resource)

    def _index_cells_by_pos(self) -> Dict[str, Dict[Tuple[int, int], dict]]:
        index: Dict[str, Dict[Tuple[int, int], dict]] = {}
        for typ, cells in self.cells.items():
            index[typ] = {(c["row"], c["col"]): c for c in cells}
        return index

