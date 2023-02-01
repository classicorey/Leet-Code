from collections import deque

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def zigzagLevelOrder(root: TreeNode) -> list[list[int]]:
    if not root: return []
    q, res, left_to_right = deque([root]), [], True
    while q:
        level = [node.val for node in q]
        if not left_to_right:
            level.reverse()
        res.append(level)
        left_to_right = not left_to_right
        for _ in range(len(q)):
            node = q.popleft()
            if node.left: q.append(node.left)
            if node.right: q.append(node.right)
    return res
