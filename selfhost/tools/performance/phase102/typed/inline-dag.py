#!/usr/bin/env python3
"""Measure repeated named-NF forced-inline source expansion; no target execution."""
import argparse
from collections import Counter
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import re


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def decode(symbol):
    m = re.fullmatch(r'NF_FID_((?:[0-9]+_)+)(.*)', symbol)
    assert m, symbol
    return ''.join(chr(int(v)) for v in m[1].strip('_').split('_')) + (('::' + m[2]) if m[2] else '')


def audit(path):
    source = path.read_text()
    plain = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*.*?\*/',
        lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), source, flags=re.S)
    pattern = r'(?m)^(NF_INLINE|INLINE|OUTLINE) Term (NF_FID_[A-Za-z0-9_]+)\([^\n]*\) \{'
    nodes, outside, previous = {}, [], 0
    for m in re.finditer(pattern, plain):
        end, depth = m.end(), 1
        while depth:
            depth += (plain[end] == '{') - (plain[end] == '}'); end += 1
        name = decode(m[2]); assert name not in nodes
        nodes[name] = dict(name=name, hint=m[1], bodyBytes=end - m.end(),
            calls=dict(Counter(decode(v) for v in re.findall(r'(NF_FID_[A-Za-z0-9_]+)\s*\(', plain[m.end():end]))))
        outside.append(plain[previous:m.start()]); previous = end
    outside.append(plain[previous:])
    calls = Counter(decode(v) for v in re.findall(r'(NF_FID_[A-Za-z0-9_]+)\s*\(e,\s*seq,', ''.join(outside)))
    missing = sorted({n for v in nodes.values() for n in v['calls'] if n not in nodes})
    assert not missing, missing
    policies = {}
    for policy in ['original', 'none', 'leaf', 'depth1', 'depth2', 'budget8192', 'budget16384', 'budget32768']:
        selected, active, depths = set(), set(), {}
        @lru_cache(None)
        def cost(name):
            assert name not in active, ('Recursive NF graph', name)
            active.add(name); row = nodes[name]; total = row['bodyBytes']
            for child, count in row['calls'].items():
                expanded = cost(child)
                if child in selected: total += count * expanded
            depths[name] = 0 if not row['calls'] else 1 + max(depths[c] for c in row['calls'])
            eligible = row['hint'] == 'NF_INLINE'
            choose = policy == 'original' or (policy == 'leaf' and not row['calls'])
            if policy.startswith('depth'): choose = depths[name] <= int(policy[5:])
            if policy.startswith('budget'): choose = total <= int(policy[6:])
            if eligible and choose: selected.add(name)
            active.remove(name)
            return total
        costs = {name:cost(name) for name in nodes}
        contributions = sorted((dict(name=n, calls=calls[n], expandedBytes=costs[n], totalBytes=calls[n] * costs[n])
            for n in selected if calls[n]), key=lambda row:-row['totalBytes'])
        policies[policy] = dict(forcedCount=len(selected), sumAllExpanded=sum(costs.values()),
            outsideForcedExpansionBytes=sum(v['totalBytes'] for v in contributions),
            largestOutsideContributions=contributions[:20],
            nodes={n:dict(expandedBytes=costs[n], dependencyDepth=depths[n], forced=n in selected) for n in nodes})
    return dict(source=pin(path), functions=len(nodes), nodes=nodes, outsideDirectCalls=dict(calls), policies=policies)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, nargs='+', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    rows = [audit(path) for path in a.source]
    result = dict(complete=True, targetsRun=False, method=pin(__file__), rows=rows,
        scope='Lexical named NF graph after removing quoted strings and comments. '
              'Repeated direct-call source bytes count only callee NF_INLINE expansion; '
              'no C simplification, heuristic inlining or runtime helpers are modeled. '
              'This is a cost proxy, not actual compiler IR or machine-code size. '
              'Depth simulations use the actual C graph, including TRMC wrapper edges; '
              'Bend worker metadata folds each TRMC wrapper/inner pair into one worker.')
    with a.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps([dict(source=r['source']['file'], functions=r['functions'],
        originalOutsideExpansion=r['policies']['original']['outsideForcedExpansionBytes']) for r in rows]))


if __name__ == '__main__': main()
