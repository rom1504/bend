#!/usr/bin/env python3
"""Read-only emitted NF call-graph/loop audit; does not compile or execute C."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def decode(name):
    return ''.join(chr(int(v)) for v in name.removeprefix('NF_FID_').strip('_').split('_'))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('source', type=Path)
    p.add_argument('output', type=Path)
    a = p.parse_args()
    source = a.source.read_text()
    # Keep offsets while ignoring braces/call spellings in C strings/comments.
    plain = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*.*?\*/',
                   lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), source, flags=re.S)
    start = re.compile(r'(?m)^(?:NF_INLINE|INLINE) Term (NF_FID_[0-9_]+)\([^\n]*\) \{')
    nodes = {}
    for m in start.finditer(plain):
        end, depth = m.end(), 1
        while depth:
            depth += (plain[end] == '{') - (plain[end] == '}')
            end += 1
        name = decode(m[1]); body = plain[m.end():end]
        assert name not in nodes, name
        nodes[name] = dict(name=name, bytes=end - m.end(), line=source.count('\n', 0, m.start()) + 1,
            calls=sorted(set(decode(x) for x in re.findall(r'(NF_FID_[0-9_]+)\s*\(', body))),
            localTailJumps=len(re.findall(r'goto nf_again;', body)),
            schedulerMacros=sorted(set(re.findall(r'\bWL_[A-Z_]+', body))))
    missing = sorted({v for row in nodes.values() for v in row['calls'] if v not in nodes})
    order, low, stack, active, components = {}, {}, [], set(), []
    def visit(v):
        order[v] = low[v] = len(order); stack.append(v); active.add(v)
        for w in nodes[v]['calls']:
            if w not in nodes: continue
            if w not in order:
                visit(w); low[v] = min(low[v], low[w])
            elif w in active: low[v] = min(low[v], order[w])
        if low[v] == order[v]:
            row = []
            while True:
                w = stack.pop(); active.remove(w); row.append(w)
                if w == v: break
            if len(row) > 1 or v in nodes[v]['calls']: components.append(sorted(row))
    for name in nodes:
        if name not in order: visit(name)
    report = dict(complete=True, targetsRun=False, source=pin(a.source), method=pin(__file__),
        functionCount=len(nodes), missingDefinitions=missing, recursiveComponents=components,
        functions=list(nodes.values()),
        scope='Lexical named NF function graph in exact emitted C, with quoted strings/comments removed. '
              'Checks direct NF call cycles and local tail-loop syntax; not a full C/control-flow proof.')
    a.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k:report[k] for k in ('functionCount','missingDefinitions','recursiveComponents')}))


if __name__ == '__main__': main()
