def generate(numRows: int) -> list[list[int]]:
    res = []
    for r in range(numRows):
        row = [1]*(r+1)
        for i in range(1, r):
            row[i] = res[-1][i-1] + res[-1][i]
        res.append(row)
    return res
