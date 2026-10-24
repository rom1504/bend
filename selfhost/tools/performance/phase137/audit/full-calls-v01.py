#!/usr/bin/env python3
"""Stream full-compiler direct getter/query call counts, without retaining IR."""
import argparse
import collections
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from owners import FUNCTION, decoded_symbol, pin


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--audit', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'implementation/phase137/audit')
    evidence = json.loads(a.audit.read_text())
    assert evidence['complete']
    cases = []
    for case in evidence['cases']:
        targets = {f['symbol']: f['decoded'] for f in case['functions'] if f['decoded'].startswith('$direct.')}
        counts = {name: collections.Counter() for name in targets}
        family = {name: collections.Counter() for name in targets}
        runtime = collections.Counter()
        caller = '<data>'
        caller_family = '<data>'
        path = Path(case['qbe']['file'])
        assert pin(path) == case['qbe']
        with path.open() as stream:
            for line in stream:
                if 'function ' in line and line.lstrip().startswith(('function ', 'export function ')):
                    m = FUNCTION.match(line)
                    assert m
                    caller = decoded_symbol(m[1]) or m[1]
                    caller_family = 'private' if m[1].startswith('p113d_') else 'segment-or-other'
                at = line.find('call $')
                if at < 0:
                    continue
                end = line.find('(', at)
                assert end >= 0
                symbol = line[at + 6:end]
                if symbol in targets:
                    counts[symbol][caller] += 1
                    family[symbol][caller_family] += 1
                if symbol in ('p111_rt_take', 'p111_rt_sink', 'p111_rt_keep'):
                    runtime[symbol] += 1
                if symbol == 'p111_rt_take' and line.rstrip().endswith('w 9)'):
                    runtime['p111_rt_take_count9'] += 1
        rows = [dict(target=targets[symbol], symbol=symbol, staticSites=sum(counter.values()),
                     callerFamilies=dict(family[symbol]), distinctCallers=len(counter),
                     topCallers=[dict(name=name, sites=count) for name, count in counter.most_common(12)])
                for symbol, counter in counts.items()]
        cases.append(dict(label=case['label'], qbe=case['qbe'], queries=rows, wholeRuntimeStaticSites=dict(runtime)))
    report = dict(kind='phase137-full-static-query-call-census', complete=True, targetsRun=False,
                  inputs=[pin(__file__), pin(a.audit), *[c['qbe'] for c in evidence['cases']]], cases=cases,
                  scope='Static direct-call sites only. Private and generic fallback bodies coexist, so totals are not dynamic execution or exclusive reachable work; changed inlining changes site count. No whole IR/function map retained.')
    out.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, report=pin(out))))


if __name__ == '__main__':
    main()
