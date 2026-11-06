#!/usr/bin/env python3
"""Offline conservative structural census; no IR rewrite or semantic admission."""
import argparse
import hashlib
import json
import re
from pathlib import Path


def decoded(symbol):
    if '_FID_' not in symbol:
        return symbol
    prefix, suffix = symbol.split('_FID_', 1)
    try:
        return prefix + ':' + ''.join(chr(int(x)) for x in suffix.split('_') if x)
    except ValueError:
        return symbol


def inspect(owner, label, lines):
    if not lines or len(lines) > 160:
        return None
    take = re.fullmatch(r'%\w+ =l call \$(p111_rt_take|p125_rt_take[1-4])\(l %state, l (%\w+), l (%\w+)(?:, w (\d+))?\)', lines[0])
    if not take:
        return None
    helper, parent, buffer, explicit = take.groups()
    count = int(explicit) if explicit is not None else int(helper[-1])
    if not 1 <= count <= 32:
        return None
    offsets = {buffer: 0}
    fields = {}
    sinks = []
    result = None
    for index, line in enumerate(lines[1:], 1):
        add = re.fullmatch(r'(%\w+) =l add (%\w+), (\d+)', line)
        load = re.fullmatch(r'(%\w+) =l loadl (%\w+)', line)
        sink = re.fullmatch(r'%\w+ =l call \$p111_rt_sink\(l %state, l (%\w+)\)', line)
        ret = re.fullmatch(r'ret (%\w+)', line)
        if add and add[2] in offsets:
            offsets[add[1]] = offsets[add[2]] + int(add[3])
        elif load and load[2] in offsets and offsets[load[2]] % 8 == 0:
            if load[1] in fields:
                return None
            fields[load[1]] = offsets[load[2]] // 8
        elif sink and sink[1] in fields:
            sinks.append(fields[sink[1]])
        elif ret and index == len(lines) - 1 and ret[1] in fields:
            result = fields[ret[1]]
        else:
            return None
    if sorted(fields.values()) != list(range(count)) or result is None:
        return None
    if result in sinks or len(sinks) != len(set(sinks)):
        return None
    return dict(owner=decoded(owner), label=label, count=count, selected=result,
                sinkIndices=sinks, ascendingSinks=sinks == sorted(sinks),
                unsunkIndices=[x for x in range(count) if x != result and x not in sinks],
                requiresScalarOmissionProof=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--ssa', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    raw = args.ssa.read_bytes()
    rows = []
    owner = None
    label = None
    lines = []
    def flush():
        if owner is not None and label is not None:
            found = inspect(owner, label, lines)
            if found is not None:
                rows.append(found)
    for text in raw.decode().splitlines():
        line = text.strip()
        fn = re.match(r'(?:export )?function .*?\$(\S+)\(', line)
        if fn:
            flush(); owner = fn[1]; label = None; lines = []
        elif line.startswith('@'):
            flush(); label = line; lines = []
        elif line == '}':
            flush(); owner = None; label = None; lines = []
        elif owner and label and line and not line.startswith('#'):
            lines.append(line)
    result = dict(kind='phase169-owned-projection-structural-census', targetsRun=False,
                  semanticAdmission=False, dynamicCounts=False,
                  input=dict(file=str(args.ssa.resolve()), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()),
                  method=dict(file=str(Path(__file__).resolve()), sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
                  candidates=len(rows), ascendingSinkCandidates=sum(x['ascendingSinks'] for x in rows),
                  owners=len({x['owner'] for x in rows}), rows=rows)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps({k: result[k] for k in ('candidates', 'ascendingSinkCandidates', 'owners')}))


if __name__ == '__main__':
    main()
