def sortedSquares(nums: list[int]) -> list[int]:
    n = len(nums)
    res = [0]*n
    i, j, pos = 0, n-1, n-1
    while i <= j:
        if abs(nums[i]) > abs(nums[j]):
            res[pos] = nums[i]*nums[i]
            i += 1
        else:
            res[pos] = nums[j]*nums[j]
            j -= 1
        pos -= 1
    return res
