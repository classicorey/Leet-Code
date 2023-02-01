class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def isBalanced(root: TreeNode) -> bool:
    def check(node):
        if not node: return 0
        l, r = check(node.left), check(node.right)
        if l == -1 or r == -1 or abs(l-r) > 1: return -1
        return 1 + max(l, r)
    return check(root) != -1
