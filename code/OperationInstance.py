from dataclasses import dataclass
from operation import Operation

@dataclass
class OperationInstance:
    operation: Operation
    start_time: int
    end_time: int
    
    @classmethod
    def load(cls, data: Dict[str, Any]) -> "OperationInstance":
        return cls(
            operation=Operation.load(data["Operation"]),
            start_time=data["StartTime"],
            end_time=data["EndTime"],
        )

    def __post_init__(self):
        if self.end_time < self.start_time:
            raise ValueError("end_time must be >= start_time")
