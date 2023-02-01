class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def diameterOfBinaryTree(root: TreeNode) -> int:
    diameter = 0
    def depth(node):
        nonlocal diameter
        if not node: return 0
        l = depth(node.left)
        r = depth(node.right)
        diameter = max(diameter, l + r)
        return 1 + max(l, r)
    depth(root)
    return diameter
