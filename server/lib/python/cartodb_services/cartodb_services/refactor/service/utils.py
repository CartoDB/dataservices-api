def round_robin(elements, GD, key):
    rr = GD[key] if key in GD else 0
    value = elements[rr]
    GD[key] = rr + 1 if rr < len(elements) - 1 else 0

    return value
