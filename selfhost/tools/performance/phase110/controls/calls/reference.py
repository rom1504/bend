#!/usr/bin/env python3
"""Independent append semantics for distinct/shared input-accumulator graphs."""
import importlib.util
import sys
from pathlib import Path
sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location('old_reference', Path(__file__).resolve().parents[1] / 'reference.py')
OLD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(OLD)


def expanded(case):
    xs = case['inputStrings'] * case['inputPatternRepeats']
    offset = case.get('accFromInputTailOffset')
    ys = xs[offset:] if offset is not None else case['accStrings'] * case.get('accPatternRepeats', 1)
    return xs, ys


def expected(case):
    xs, ys = expanded(case)
    aliases = []
    for alias in case['aliases']:
        origin = alias['from']
        values = ys if origin.startswith('acc-') else xs
        origin = origin.removeprefix('acc-')
        offset = alias.get('offset', 0)
        if origin == 'root':
            value = values
        elif origin == 'tail':
            value = values[offset:]
        elif origin == 'head':
            value = list(map(ord, values[offset]))
        else:
            raise ValueError(origin)
        aliases.append(OLD.observation(value, alias['kind']))
    return dict(name=case['name'], **OLD.observation(xs + ys, 'list'), aliases=aliases, released=True)
