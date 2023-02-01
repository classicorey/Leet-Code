class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def flatten(root: TreeNode) -> None:
    prev = None
    def helper(node):
        nonlocal prev
        if not node: return
        helper(node.right)
        helper(node.left)
        node.right = prev
        node.left = None
        prev = node
    helper(root)
