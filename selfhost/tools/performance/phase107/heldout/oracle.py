#!/usr/bin/env python3
"""Independent integer models and frozen vectors; running this launches no compiler."""
import json
import math

MASK = 2**32 - 1
HIGH = 2**31


def expected():
    gcd = [(0, 0), (0, 7), (7, 0), (84, 30), (30, 84), (987, 610),
           (1023, 1), (1, 1023), (1023, 1022), (1024, 1023), (1025, 2049),
           (HIGH, 1023), (HIGH+35, HIGH+49), (MASK, 0), (MASK, 1),
           (MASK, MASK), (MASK, HIGH), (MASK-1, 512)]
    triangular = [(n, seed) for n in [0, 1, 2, 3, 10, 255, 256, 511, 1023,
                  1024, 1025, HIGH, HIGH+1023, MASK] for seed in [0, 11, HIGH, MASK]]
    saturating = [(0, 0), (1, 0), (0, 1), (128, 128), (128, 129), (129, 129),
                  (257, 0), (258, 0), (1000, 2000), (HIGH-1, 0), (HIGH-1, 1),
                  (HIGH, 0), (HIGH, 1), (HIGH, HIGH-1), (HIGH, HIGH), (MASK, 0),
                  (0, MASK), (MASK, 1), (1, MASK), (MASK-1, 1), (MASK-1, 2),
                  (MASK, MASK), (4294967000, 500), (65535, 65536)]

    def answer(name, n, seed):
        if name == 'gcd':
            return math.gcd(n % 1024, seed % 1024)
        if name == 'triangular':
            k = n % 1024
            return (k * (k+1) // 2 + seed) % 2**32
        total = min(n+seed, MASK)
        return total*3 if total < 257 else total-HIGH if total >= HIGH else total-257

    return dict(kind='phase107-heldout-expectations', version=1, sources=[
        dict(id=name, cases=[dict(argv=[str(n), str(seed)],
             value=answer(name, n, seed), stdout=str(answer(name, n, seed))+'\n', stderr='')
             for n, seed in vectors])
        for name, vectors in [('gcd', gcd), ('triangular', triangular), ('saturating', saturating)]])


if __name__ == '__main__':
    print(json.dumps(expected(), indent=2))
