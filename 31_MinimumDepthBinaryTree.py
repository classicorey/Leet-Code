from collections import deque

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def minDepth(root: TreeNode) -> int:
    if not root: return 0
    q = deque([(root,1)])
    while q:
        node, d = q.popleft()
        if not node.left and not node.right:
            return d
        if node.left: q.append((node.left,d+1))
        if node.right: q.append((node.right,d+1))
