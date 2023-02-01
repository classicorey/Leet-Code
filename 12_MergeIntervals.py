def merge(intervals: list[list[int]]) -> list[list[int]]:
    if not intervals:
        return []
    intervals.sort(key=lambda x: x[0])
    res = [intervals[0]]
    for s, e in intervals[1:]:
        last_s, last_e = res[-1]
        if s <= last_e:
            res[-1][1] = max(last_e, e)
        else:
            res.append([s, e])
    return res
