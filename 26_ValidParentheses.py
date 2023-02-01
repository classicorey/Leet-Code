def isValid(s: str) -> bool:
    stack = []
    mapping = {')':'(', ']':'[', '}':'{'}
    for ch in s:
        if ch in mapping.values():
            stack.append(ch)
        elif not stack or stack[-1] != mapping[ch]:
            return False
        else:
            stack.pop()
    return not stack
