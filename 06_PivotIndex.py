def pivotIndex(nums: list[int]) -> int:
    total = sum(nums)
    left = 0
    for i, v in enumerate(nums):
        if left == total - left - v:
            return i
        left += v
    return -1
