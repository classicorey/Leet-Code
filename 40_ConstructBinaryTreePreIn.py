class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def buildTree(preorder: list[int], inorder: list[int]):
    if not preorder or not inorder: return None
    idx = {v:i for i,v in enumerate(inorder)}
    def helper(pl, pr, il, ir):
        if pl > pr: return None
        root_val = preorder[pl]
        root = TreeNode(root_val)
        k = idx[root_val]
        left_len = k - il
        root.left = helper(pl+1, pl+left_len, il, k-1)
        root.right = helper(pl+left_len+1, pr, k+1, ir)
        return root
    return helper(0, len(preorder)-1, 0, len(inorder)-1)
