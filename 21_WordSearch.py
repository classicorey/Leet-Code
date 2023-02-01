def exist(board: list[list[str]], word: str) -> bool:
    rows, cols = len(board), len(board[0])
    def dfs(r, c, i):
        if i == len(word):
            return True
        if r<0 or c<0 or r>=rows or c>=cols or board[r][c] != word[i]:
            return False
        tmp = board[r][c]
        board[r][c] = '#'
        for dr, dc in ((1,0),(-1,0),(0,1),(0,-1)):
            if dfs(r+dr, c+dc, i+1):
                board[r][c] = tmp
                return True
        board[r][c] = tmp
        return False
    for r in range(rows):
        for c in range(cols):
            if dfs(r, c, 0):
                return True
    return False
