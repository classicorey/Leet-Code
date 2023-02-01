def majorityElement(nums: list[int]) -> int:
    count = 0
    candidate = None
    for n in nums:
        if count == 0:
            candidate = n
        count += (1 if n == candidate else -1)
    return candidate
