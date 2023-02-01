from collections import defaultdict

def subarraySum(nums: list[int], k: int) -> int:
    count = 0
    prefix = 0
    seen = defaultdict(int)
    seen[0] = 1
    for x in nums:
        prefix += x
        count += seen[prefix - k]
        seen[prefix] += 1
    return count
