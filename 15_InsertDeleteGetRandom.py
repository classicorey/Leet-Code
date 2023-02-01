import random

class RandomizedSet:
    def __init__(self):
        self.vals = []
        self.pos = {}
    def insert(self, val: int) -> bool:
        if val in self.pos:
            return False
        self.pos[val] = len(self.vals)
        self.vals.append(val)
        return True
    def remove(self, val: int) -> bool:
        if val not in self.pos:
            return False
        idx = self.pos[val]
        last = self.vals[-1]
        self.vals[idx] = last
        self.pos[last] = idx
        self.vals.pop()
        del self.pos[val]
        return True
    def getRandom(self) -> int:
        return random.choice(self.vals)
