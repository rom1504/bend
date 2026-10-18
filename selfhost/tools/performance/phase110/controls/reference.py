#!/usr/bin/env python3
"""Independent mathematical observations of frozen inputs. Executes no Bend code."""
import json
from pathlib import Path

OFFSET = 14695981039346656037
PRIME = 1099511628211


def hash_words(words):
    value = OFFSET
    for word in words:
        for byte in int(word).to_bytes(4, 'little'):
            value = ((value ^ byte) * PRIME) & ((1 << 64) - 1)
    return f'{value:016x}'


def observation(values, kind):
    words = values if kind == 'string' else [word for value in values for word in [len(value), *map(ord, value)]]
    return {'count': len(values), 'hash': hash_words(words)}


def values(case, side):
    result = case[side + ('Codepoints' if case['kind'] == 'string' else 'Strings')]
    return result * (case['inputPatternRepeats'] if side == 'input' else 1)


def expected(case, variant='reverse'):
    xs, acc = values(case, 'input'), values(case, 'acc')
    kind = case['kind']
    if variant == 'reverse':
        result = xs[::-1] + acc
    elif variant == 'discard':
        result = acc
    elif variant == 'duplicate':
        result = [value for value in xs[::-1] for _ in range(2)] + acc
    elif variant == 'append':
        result = xs + acc
    elif variant == 'tail':
        result = xs[1:]
    elif variant == 'last':
        result = list(map(ord, xs[-1])) if xs else case['lastAccumulatorCodepoints']
        kind = 'string'
    else:
        raise ValueError(variant)
    aliases = []
    for alias in case['aliases']:
        if alias['from'] == 'root':
            alias_value = xs
        elif alias['from'] == 'tail':
            alias_value = xs[alias['offset']:]
        elif alias['from'] == 'head':
            alias_value = list(map(ord, xs[alias['offset']]))
        else:
            raise ValueError(alias['from'])
        aliases.append(observation(alias_value, alias['kind']))
    return {'name': case['name'], **observation(result, kind), 'aliases': aliases, 'released': True}


def selected(cases, variant):
    return [c for c in cases if variant not in ('tail', 'last', 'append') or c['kind'] == 'list']


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cases', type=Path, default=Path(__file__).with_name('cases.json'))
    parser.add_argument('--variant', choices=['reverse', 'discard', 'duplicate', 'tail', 'last', 'append'], default='reverse')
    args = parser.parse_args()
    for case in selected(json.loads(args.cases.read_text())['cases'], args.variant):
        print(json.dumps(expected(case, args.variant), separators=(',', ':')))
