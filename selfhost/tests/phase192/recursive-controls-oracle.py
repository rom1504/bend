#!/usr/bin/env python3
"""Independent finite unsigned arithmetic/string oracle; never invokes Bend."""
import json

MASK = (1 << 32) - 1


def one(depth, seed):
    captures = [(seed + 3 * i) & MASK for i in range(depth)]
    return (((seed + 3 * depth) + sum(x ^ 17 for x in captures)) & MASK) ^ 2779096485


def two(depth, odd, seed):
    frames = []
    for _ in range(depth):
        frames.append((odd, seed))
        seed = (seed + (5 if odd else 3)) & MASK
        odd = not odd
    for odd, captured in reversed(frames):
        seed = seed ^ ((captured * 17) & MASK) if odd else (seed + (captured ^ 91)) & MASK
    return seed


def tree(depth, seed):
    # Bottom-up leaf vector, independent of source heap representation.
    leaves = [seed]
    for _ in range(depth):
        leaves = [child & MASK for parent in leaves for child in (parent + 3, parent + 11)]
    while len(leaves) > 1:
        leaves = [((leaves[i] * 3) & MASK) ^ ((leaves[i + 1] + 7) & MASK)
                  for i in range(0, len(leaves), 2)]
    return leaves[0]


def ready(depth, seed):
    value = (seed + 7 * depth) & MASK
    for _ in range(19):
        value = ((value * 33) & MASK) ^ 2654435769
    for i in reversed(range(depth)):
        value ^= (seed + 7 * i + 101) & MASK
    return (value + 1234567) & MASK


def fallback(depth, seed, multiply=False):
    values = [((seed + i) & MASK) for i in range(depth + 1)]
    transformed = [((x * 19) & MASK) if multiply else x ^ 85 for x in values]
    return (sum(transformed) & MASK) ^ 1431655765


def expected():
    cases = {
        "one": [one(0, 7), one(1, 7), one(4096, 4294967289)],
        "two": [two(0, True, 4294967295), two(5, True, 19), two(129, False, 4294967283)],
        "tree": [tree(0, 13), tree(3, 13), tree(8, 4294967281)],
        "ready": [ready(0, 23), ready(1, 23), ready(67, 4294967287)],
        "sharing": ["zero", "73q|" * 4 + "end", "73q!?73q!?73q!", "73q"],
        "fallback": [fallback(0, 9), fallback(7, 9), fallback(31, 4294967281, True)],
    }
    return {name: "".join(str(value) + "\n" for value in values) for name, values in cases.items()}


if __name__ == "__main__":
    print(json.dumps(expected(), indent=2, sort_keys=True))
