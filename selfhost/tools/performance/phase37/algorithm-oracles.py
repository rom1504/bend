#!/usr/bin/env python3
"""Independent integer reference calculations; no Bend compiler is imported.

The root runner executes this while freezing the coverage catalog. Historical
goldens cross-check the implementations; they do not establish a universal proof.
"""
import functools

MASK = (1 << 32) - 1


def u32(x):
    return x & MASK


def prng(x):
    x = u32(x ^ (x << 13))
    x ^= x >> 17
    return u32(x ^ (x << 5))


def editdist(depth, first):
    def pair(index):
        def sequence(seed):
            values = []
            for _ in range(256):
                seed = prng(seed)
                values.append(seed & 3)
            return values
        seed = u32((index + 1) * 2654435761)
        left, right = sequence(seed), sequence(u32(seed * 340573321))
        previous = list(range(257))
        for i, a in enumerate(left):
            current = [i + 1]
            for j, b in enumerate(right):
                current.append(min(previous[j + 1] + 1, current[j] + 1,
                                   previous[j] + (a != b)))
            previous = current
        return u32(previous[-1] * 2654435761) ^ u32(index + 1)
    return u32(sum(pair(u32(first + i)) for i in range(1 << depth)))


def lexer(depth, first):
    template = 'i = ( n o i ) o ( n o i ) o ( n o i ) ;'
    def line(index):
        seed = prng(u32((index + 1) * 2654435761))
        parts = []
        for k, char in enumerate(template):
            state = prng(seed ^ u32(k * 2654435761))
            if char in ('i', 'n'):
                count = 1 + ((state & 7) if char == 'i' else state % 6)
                part = []
                for _ in range(count):
                    state = prng(state)
                    part.append(chr((97 + state % 26) if char == 'i' else (48 + state % 10)))
                parts.append(''.join(part))
            elif char == 'o':
                parts.append('+-*/'[state & 3])
            else:
                parts.append(char)
        text = ''.join(parts)
        result, cursor = 0, 0
        def mix(acc, kind, value):
            return u32(acc * 2654435761) ^ u32(kind * 40503 + value)
        while cursor < len(text):
            char = text[cursor]
            if 'a' <= char <= 'z':
                value = 2166136261
                while cursor < len(text) and 'a' <= text[cursor] <= 'z':
                    value = u32((value ^ ord(text[cursor])) * 16777619)
                    cursor += 1
                result = mix(result, 1, value)
            elif '0' <= char <= '9':
                value = 0
                while cursor < len(text) and '0' <= text[cursor] <= '9':
                    value = u32(value * 10 + ord(text[cursor]) - 48)
                    cursor += 1
                result = mix(result, 2, value)
            else:
                if char != ' ':
                    result = mix(result, 3, ord(char))
                cursor += 1
        return result
    return u32(sum(line(u32(first + i)) for i in range(1 << depth)))


def bitonic(depth, first):
    # bsort builds the full key-index interval [first*2^depth,(first+1)*2^depth).
    # A host sort independently specifies the intended ascending ordering; the
    # balanced summary matches the benchmark's order-sensitive verification.
    values = sorted(prng(u32((u32((first << depth) + i) + 1) * 2654435761))
                    for i in range(1 << depth))
    level = list(values)
    while len(level) > 1:
        level = [u32(level[i] * 2654435761 + level[i + 1])
                 for i in range(0, len(level), 2)]
    return u32((u32(level[0] * 2654435761) ^ u32(values[-1] + values[0] * 340573321))
               + 2246822519)


def symreg(depth, seed):
    def tree(d, h):
        if not d:
            return ('var',) if ((h >> 8) & 1) == 0 else ('lit', h & 255)
        return (h % 4, tree(d - 1, prng(h ^ 2654435761)),
                tree(d - 1, prng(u32(h + 340573321))))
    def evaluate(t, x):
        if t[0] == 'var': return x
        if t[0] == 'lit': return t[1]
        a, b = evaluate(t[1], x), evaluate(t[2], x)
        if t[0] == 0: return u32(a + b)
        if t[0] == 1: return u32(a - b)
        if t[0] == 2: return u32(a * b)
        return a ^ b
    @functools.lru_cache(maxsize=None)
    def candidate(s):
        t = tree(5, prng(s))
        fit = u32(sum(abs(evaluate(t, x) - (x * x + 3 * x + 7)) for x in range(16)) + 63 * 8)
        return fit, s, fit ^ u32(s * 2654435761)
    def batch(d, s):
        if not d:
            return candidate(prng(s))
        a = batch(d - 1, u32(s * 1664525 + 1))
        b = batch(d - 1, u32(s * 214013 + 3))
        chosen = a if a[0] < b[0] else b
        return chosen[0], chosen[1], u32(a[2] + b[2])
    fitness, winner, checksum = batch(depth, seed)
    for remaining in range(31, -1, -1):
        next_fit, next_seed, _ = candidate(prng(winner ^ u32((remaining + 1) * 40503)))
        if next_fit < fitness:
            fitness, winner = next_fit, next_seed
    return u32((fitness ^ u32(winner * 2654435761)) + checksum)


def mandelbrot_pixel(index, iterations):
    cr = u32(((index & 4095) * 768) // 4096 - 512)
    ci = u32(((index >> 12) * 768) // 4096 - 384)
    zr = zi = escaped = count = 0
    def asr8(value):
        return u32((value if value < 1 << 31 else value - (1 << 32)) >> 8)
    for _ in range(iterations):
        r2, i2 = asr8(u32(zr * zr)), asr8(u32(zi * zi))
        escaped |= u32(r2 + i2) > 1024
        if not escaped:
            zr, zi = u32(r2 - i2 + cr), u32(asr8(u32(2 * zr * zi)) + ci)
            count += 1
    return count


def mandelbrot_grid(depth, iterations):
    # depth4:16x16 cells; depth5:32x32; centers across the full fixed viewport.
    side = 1 << depth
    stride = 4096 // side
    checksum = 0
    for y in range(side):
        for x in range(side):
            index = (y * stride + stride // 2) * 4096 + x * stride + stride // 2
            value = mandelbrot_pixel(index, iterations)
            checksum = u32(checksum + u32(value * u32(index * 2654435761 + 1)))
    return checksum


def verify_historical():
    observations = {
        'editdist': (editdist(2, 0), 2065873279),
        'lexer': (lexer(8, 0), 1822208108),
        'tree-bitonic': (bitonic(8, 0), 971629740),
        'symreg': (symreg(6, 42), 2490246820),
    }
    for name, (actual, expected) in observations.items():
        if actual != expected:
            raise ValueError(f'Independent oracle differs from historical {name}: {actual} != {expected}')
    return {name: actual for name, (actual, _) in observations.items()}
