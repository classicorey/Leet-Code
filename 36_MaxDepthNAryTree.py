class Node:
    def __init__(self, val=None, children=None):
        self.val = val
        self.children = children if children is not None else []

def maxDepth(root: Node) -> int:
    if not root: return 0
    if not root.children: return 1
    return 1 + max(maxDepth(c) for c in root.children)
