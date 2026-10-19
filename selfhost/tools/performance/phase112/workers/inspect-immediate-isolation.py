#!/usr/bin/env python3
"""Offline, reversible textual isolation of the rejected immediate expansion.

Reads emitted QBE only. Does not run QBE, a compiler, or a generated program.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw), sha256=digest(raw))


TEMPLATE = re.compile(
    r'%t_\d+ =w cultl ([^\n]+), 144115188075855872\n'
    r'jnz %t_\d+, (@b_\d+), (@b_\d+)\n\2\n'
    r'([^\n]+) =l copy ([^\n]+)\njmp (@b_\d+)\n\3\n'
    r'\4 =l call \$(p111_rt_keep|p111_rt_sink)\(l %state, l \1\)\n'
    r'jmp \6\n\6\n')


def functions(text):
    result = {}
    for match in re.finditer(r'((?:export )?function [^\n]+)\n(.*?)\n}', text, re.S):
        names = {}
        body = re.sub(r'(%t_\d+|@b_\d+)',
                      lambda token: names.setdefault(token[0], token[0][:3] + str(len(names))),
                      match[0])
        if match[1] in result:
            raise ValueError('Duplicate function declaration')
        result[match[1]] = body
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fast', type=Path, required=True)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError('Use a fresh report path')
    inputs = [pin(Path(__file__)), pin(args.fast), pin(args.baseline)]
    fast, baseline = args.fast.read_text(), args.baseline.read_text()
    function, seen, collisions = '', collections.Counter(), []
    for line_number, line in enumerate(fast.splitlines(), 1):
        if re.match(r'(?:export )?function ', line):
            function, seen = line, collections.Counter()
        match = re.match(r'(@\S+)\s*$', line) or re.match(r'(%t_\d+)\s*=', line)
        if match:
            seen[match[1]] += 1
            if seen[match[1]] > 1:
                collisions.append(dict(line=line_number, function=function, name=match[1]))
    edits, pieces, cursor, collapsed_length = [], [], 0, 0
    for match in TEMPLATE.finditer(fast):
        lines = match[0].splitlines()
        if lines[0].split()[0] != lines[1].split()[1].rstrip(','):
            raise ValueError('Predicate temporary differs from branch condition')
        expected_copy = match[1] if match[7] == 'p111_rt_keep' else '0'
        if match[5] != expected_copy or len({match[2], match[3], match[6]}) != 3:
            raise ValueError('Unexpected immediate template semantics')
        prefix = fast[cursor:match.start()]
        replacement = f'{match[4]} =l call ${match[7]}(l %state, l {match[1]})\n'
        collapsed_length += len(prefix)
        edits.append(dict(originalStart=match.start(), originalEnd=match.end(),
                          collapsedStart=collapsed_length, original=match[0], replacement=replacement))
        pieces.extend([prefix, replacement])
        collapsed_length += len(replacement)
        cursor = match.end()
    pieces.append(fast[cursor:])
    collapsed = ''.join(pieces)
    reconstructed = collapsed
    for edit in reversed(edits):
        start, replacement = edit['collapsedStart'], edit['replacement']
        if reconstructed[start:start + len(replacement)] != replacement:
            raise ValueError('Reverse edit does not match')
        reconstructed = reconstructed[:start] + edit['original'] + reconstructed[start + len(replacement):]
    if reconstructed != fast:
        raise ValueError('Reversible reconstruction failed')
    left, right = functions(collapsed), functions(baseline)
    mismatches = [name for name in left.keys() | right.keys() if left.get(name) != right.get(name)]
    remaining = collapsed.count('144115188075855872')
    if collisions or remaining or mismatches:
        raise ValueError('Isolation differs: ' + repr((collisions, remaining, mismatches)))
    record = dict(kind='phase112-offline-immediate-isolation', complete=True, targetsExecuted=False,
                  inputs=inputs, reversible=True, immediateSites=len(edits), functions=len(left),
                  duplicateEmitterNames=collisions, unmatchedThresholds=remaining,
                  changedNormalizedFunctions=mismatches,
                  collapsedSha256=digest(collapsed.encode()),
                  normalizedFunctionHashes={name: digest(body.encode()) for name, body in left.items()},
                  edits=edits,
                  scope='All function bodies match after exact template collapse and numeric temporary/label alpha-renaming. This does not prove the compiled conditional expansion correct.')
    for item in inputs:
        if pin(Path(item['file'])) != item:
            raise ValueError('Input changed during inspection')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, functions=len(left), immediateSites=len(edits), targetsExecuted=False)))


if __name__ == '__main__':
    main()
