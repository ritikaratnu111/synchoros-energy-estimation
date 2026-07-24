class Testcase():
    def __init__(self, block: SiLagoBlock, neighbors: tuple) -> None:
        self.cells = {}
        self.applied_ops = {}
    #def __init__(self, epsilon: float, window: int, min_iters: int):
        self.epsilon = epsilon
        self.window = window
        self.min_iters = min_iters
        self.errors = deque(maxlen=window)
        self.k = 0

