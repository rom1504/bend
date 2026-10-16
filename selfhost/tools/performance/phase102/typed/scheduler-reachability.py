#!/usr/bin/env python3
"""Offline opportunity census, not a validated scheduler-pruning transform."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def host_union(source):
    """Select literal DEVICE conditions, retain both sides of unknown ones."""
    stack, output = [], []
    for line in source.splitlines(True):
        match = re.match(r'\s*#\s*(if|ifdef|ifndef|elif|else|endif)\b(.*)', line)
        if match:
            op, arg = match[1], match[2].strip()
            if op in ['if', 'ifdef', 'ifndef']:
                value = (arg == '!DEVICE') if op == 'if' and arg in ['DEVICE', '!DEVICE'] else None
                stack.append([value, value]); continue
            if op == 'else':
                value = stack[-1][0]; stack[-1][1] = not value if value is not None else None
            elif op == 'elif': stack[-1][1] = None
            elif op == 'endif': stack.pop()
            continue
        if not any(row[1] is False for row in stack): output.append(line)
    assert not stack
    return ''.join(output)


def decode(name):
    if not name.startswith('FID_') or not re.fullmatch(r'(?:\d+_)+', name[4:]): return name
    return ''.join(chr(int(v)) for v in name[4:].strip('_').split('_'))


def pin(path):
    path = path.resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def audit(path):
    raw = path.read_text(); source = host_union(raw)
    plain = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*.*?\*/',
        lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), source, flags=re.S)
    starts = list(re.finditer(r'(?m)^  WL_CASE\((FID_\w+|BEND_CLO_APPLY)\)', plain)); assert starts
    refs = lambda text: set(re.findall(r'\b(?:FID_\w+|BEND_CLO_APPLY)\b', text))
    nodes = {}
    for i, match in enumerate(starts):
        end = starts[i + 1].start() if i + 1 < len(starts) else len(plain)
        assert match[1] not in nodes
        nodes[match[1]] = dict(name=decode(match[1]), chars=end - match.start(),
                              refs=refs(plain[match.end():end]))
    prefix = re.sub(r'(?m)^\s*#define (?:FID_\w+|WL_TABLE)\b[^\n]*\n', '', plain[:starts[0].start()])
    roots = refs(prefix) & nodes.keys(); kept = set(); todo = list(roots)
    while todo:
        name = todo.pop()
        if name in kept: continue
        kept.add(name); todo.extend((nodes[name]['refs'] & nodes.keys()) - kept)
    dead = nodes.keys() - kept
    return dict(source=pin(path), hostApproxChars=len(plain), segments=len(nodes), roots=sorted(roots),
        retained=len(kept), unreachable=len(dead), unreachableChars=sum(nodes[n]['chars'] for n in dead),
        totalSegmentChars=sum(n['chars'] for n in nodes.values()),
        unreachableContinuations=sum(nodes[n]['name'].startswith('native_k_') for n in dead),
        largestDead=sorted([dict(fid=n, name=nodes[n]['name'], chars=nodes[n]['chars']) for n in dead],
                           key=lambda row:-row['chars'])[:20], unreachableIds=sorted(dead))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, nargs='+', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    rows = [audit(path) for path in a.source]
    report = dict(complete=True, targetsRun=False, method=pin(Path(__file__)), rows=rows,
        scope='Exploratory host-branch union and literal-FID reachability. All NF/runtime '
              'literal references before scheduler cases are roots. The final EXIT case '
              'conservatively includes all runtime footer references. Dispatch-table and '
              'numeric-ID definitions do not root execution. Unknown branches remain. '
              'Not a proof that foreign code/raw words cannot manufacture callable IDs; '
              'does not rewrite C, renumber IDs, remove tables or qualify any compiler.')
    with a.out.open('x') as stream: json.dump(report, stream, indent=2); stream.write('\n')
    print(json.dumps([{k:row[k] for k in ['segments', 'unreachable', 'unreachableChars']} for row in rows]))


if __name__ == '__main__': main()
