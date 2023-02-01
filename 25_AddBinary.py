def addBinary(a: str, b: str) -> str:
    i, j, carry = len(a)-1, len(b)-1, 0
    res = []
    while i >= 0 or j >= 0 or carry:
        if i >= 0:
            carry += ord(a[i]) - ord('0')
            i -= 1
        if j >= 0:
            carry += ord(b[j]) - ord('0')
            j -= 1
        res.append(str(carry % 2))
        carry //= 2
    return ''.join(reversed(res))
