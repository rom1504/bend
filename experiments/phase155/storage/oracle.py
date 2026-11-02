#!/usr/bin/env python3
"""Independent ordinary-dict reference; prints one complete expected String.

This does not execute or compile Bend. Arithmetic is explicitly modulo 2**32.
The references share no trie, array, binary search or merge implementation.
"""
import argparse

MASK = (1 << 32) - 1


def mix(key, value):
    lo, hi, version = value
    return ((key * 31 + lo) ^ (hi * 17 + version * 257)) & MASK


def initial(n, key):
    return ((n + key * 3 + 1) & MASK, (n ^ (key * 65537)) & MASK, 1)


def reference(family, n):
    if not 0 <= n <= MASK:
        raise ValueError("n must be U32")
    keys = list(range(64)) if family == "dense" else [1000003 + i * 65537 for i in range(64)]
    facts = {key: initial(n, key) for i, key in enumerate(keys) if family == "dense" or i % 2 == 0}
    acc = 2166136261
    for step in range(n):
        index = (step * (17 if family == "dense" else 13) + n) & 63
        key = keys[index]
        seen = mix(key, facts[key]) if key in facts else 0
        acc = ((acc * 16777619) ^ seen) & MASK
        if family == "dense":
            facts[key] = ((seen + step + 11) & MASK, seen ^ ((n + key) & MASK), (step + 2) & MASK)
        else:
            for index in range(step & 7, 64, 8):
                key = keys[index]
                facts[key] = ((seen + step + key) & MASK, seen ^ ((n + key) & MASK), (step + 2) & MASK)
    rows = [f"{key}:" + (":".join(map(str, facts[key])) if key in facts else "-") + ";" for key in keys]
    return f"{acc}|" + "".join(rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("family", choices=["dense", "sparse"])
    parser.add_argument("n", type=int)
    args = parser.parse_args()
    print(reference(args.family, args.n))
