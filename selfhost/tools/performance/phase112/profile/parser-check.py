#!/usr/bin/env python3
"""Finite parser transport controls; no native compilation or target execution."""
import json
from parse import parse_records, validate_output, PREFIX
from prepare import COUNTERS, SOURCE_SHA


def encode(records):
    return b''.join(PREFIX + json.dumps(r).encode() + b'\n' for r in records)


meta = dict(type='meta', version=1, sourceSha256=SOURCE_SHA, heapRc=False,
            abi=11101, segments=1, constructors=18, transportWidth=2)
records = [meta] + [dict(type='counter', name=n, count=0) for n in COUNTERS]
records += [dict(type='end', rows=len(COUNTERS), invalid=0)]
raw = encode(records)
prefix, suffix = b'ordinary stderr\r\n', b'unchanged tail\x00'
assert parse_records(prefix + raw + suffix)[3] == prefix + suffix
cases = {
    'missing': b'',
    'truncated': raw[:-1],
    'missing-end': encode(records[:-1]),
    'duplicate-counter': encode(records[:-1] + [records[1], dict(type='end', rows=len(COUNTERS)+1, invalid=0)]),
    'overflow': encode(records[:-1] + [dict(type='end', rows=len(COUNTERS), invalid=1)]),
    'missing-counter': encode([meta] + records[2:-1] + [dict(type='end', rows=len(COUNTERS)-1, invalid=0)]),
    'wrong-row-total': encode(records[:-1] + [dict(type='end', rows=0, invalid=0)]),
    'extra-meta': encode(records[:-1] + [meta, dict(type='end', rows=len(COUNTERS)+1, invalid=0)]),
    'inconsistent-histogram': encode(records[:-1] + [dict(type='histogram', name='op', index=1, count=1),
                                                  dict(type='end', rows=len(COUNTERS)+1, invalid=0)]),
    'duplicate-json-key': raw.replace(b'"version": 1', b'"version": 1, "version": 1'),
}
for name, data in cases.items():
    try:
        parse_records(data)
    except (ValueError, KeyError, TypeError):
        continue
    raise AssertionError('parser accepted invalid case: ' + name)
batch = dict(kind='phase112-diagnostic-batch-output', status=0, stdoutPrefix='answer\n0\n1\n',
             stderr='', suffixRule='unsigned-decimal-milliseconds-newline')
validate_output(b'answer\n0\n1\n0\n', b'', batch, 0.01)
batch_bad = [b'wrong\n0\n1\n0\n', b'answer\n1\n1\n0\n', b'answer\n0\n1\n0.0\n',
             b'answer\n0\n1\n0\nextra\n', b'answer\n0\n1\n99999\n']
for stdout in batch_bad:
    try:
        validate_output(stdout, b'', batch, 0.01)
    except ValueError:
        continue
    raise AssertionError('accepted malformed diagnostic batch output')
print(json.dumps(dict(complete=True, nativeTargetsRun=False,
                     positive=['byte-exact non-profile stderr', 'batch exact prefix and numeric suffix'],
                     negative=list(cases), batchNegative=len(batch_bad))))
