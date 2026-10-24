#!/usr/bin/env python3
"""Metadata-only conservative reference census; never a deletion certificate."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess

SYMBOL = r'[A-Za-z_.$][A-Za-z0-9_.$]*'
DECL = re.compile(r'^\s*(export\s+)?(function\s+\w+|data)\s+\$(' + SYMBOL + r')')
GLOBAL = re.compile(r'\$(' + SYMBOL + r')')
CALL = re.compile(r'\bcall\s+\$(' + SYMBOL + r')\s*\(')
INDIRECT = re.compile(r'\bcall\s+%')
# This input uses ordinary quoted QBE strings. Do not interpret names in them.
NONCODE = re.compile(r'"(?:\\.|[^"\\])*"|#.*$')


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def decode(name):
    m = re.fullmatch(r'(.*FID_)((?:[0-9]+_)+)', name)
    return m[1] + ''.join(chr(int(x)) for x in m[2].split('_') if x) if m else name


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qbe', type=Path, required=True)
    p.add_argument('--runtime-object', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists(), 'fresh evidence path required'
    defs, calls, refs, indirect, active = {}, Counter(), {}, 0, None
    with a.qbe.open() as stream:
        for number, raw in enumerate(stream, 1):
            line = NONCODE.sub('', raw)
            m = DECL.match(line)
            if m:
                assert active is None and m[3] not in defs
                active = m[3]
                defs[active] = dict(kind='data' if m[2] == 'data' else 'function',
                                    exported=bool(m[1]), line=number, bytes=0)
                refs[active] = set()
                line = line[m.end():]
            if active:
                defs[active]['bytes'] += len(raw.encode())
                refs[active].update(GLOBAL.findall(line))
                calls.update(CALL.findall(line))
                indirect += len(INDIRECT.findall(line))
                if '}' in line:
                    active = None
    assert active is None and {'p111_program', 'p111_segments', 'main'} <= defs.keys()
    functions = {n for n, v in defs.items() if v['kind'] == 'function'}
    table = refs['p111_segments']
    assert table and table <= functions
    def closure(roots):
        reached, todo = set(), list(roots)
        while todo:
            n = todo.pop()
            if n not in reached and n in defs:
                reached.add(n)
                todo.extend(refs[n] - reached)
        return reached
    rooted = closure({'main', 'p111_program'})
    exported = {n for n, v in defs.items() if v['exported']}
    all_roots = closure(exported)
    incoming = Counter(n for edges in refs.values() for n in edges)
    by_prefix = Counter((('exported_' if defs[n]['exported'] else 'local_') +
                         n.split('_FID_')[0]) for n in functions)
    runtime_undefined = sorted(line.split()[-1] for line in subprocess.check_output(
        ['nm', '-u', str(a.runtime_object)], text=True).splitlines() if line.strip())
    missing = sorted(set().union(*refs.values()) - defs.keys())
    result = dict(kind='phase132-static-reference-boundaries', complete=True,
        targetExecution=False, inputs=[pin(__file__), pin(a.qbe), pin(a.runtime_object)],
        definitions=len(defs), functions=len(functions), functionKinds=dict(by_prefix),
        exportedDefinitions=len(exported), dispatchTableFunctions=len(table),
        directCallSites=sum(calls.values()), indirectCallSites=indirect,
        dispatchFunctionsWithoutDirectTextualCalls=len(table - calls.keys()),
        privateFunctionsWithoutDirectTextualCalls=sum(not defs[n]['exported'] and n not in calls for n in functions),
        functionsNotReachedFromMainAndDescriptor=len(functions - rooted),
        functionsNotReachedFromAllExportedDefinitions=len(functions - all_roots),
        unrootedFunctionKinds=dict(Counter(n.split('_FID_')[0] for n in functions - all_roots)),
        unrootedFunctionTextBytes=sum(defs[n]['bytes'] for n in functions - all_roots),
        unrootedFunctionTextBytesByKind=dict(Counter({prefix: sum(defs[n]['bytes'] for n in functions - all_roots
            if n.split('_FID_')[0] == prefix) for prefix in {n.split('_FID_')[0] for n in functions - all_roots}})),
        privateFunctionsWithNoGlobalReference=[decode(n) for n in sorted(functions)
            if not defs[n]['exported'] and not incoming[n]],
        unresolvedGlobalReferences=missing, runtimeUndefined=runtime_undefined,
        runtimeUndefinedOverlapsGeneratedDefinitions=sorted(set(runtime_undefined) & defs.keys()),
        scope='Conservative syntactic global-reference graph includes data relocations and all branch references. '
              'The dispatch table roots every registered segment, including continuations and generic fallbacks. '
              'Numeric FID values embedded in instructions/Terms are not decoded here. Neither textual absence '
              'nor lack of graph reachability establishes semantic deadness. No deletion is proposed.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if not isinstance(v, list)}))


if __name__ == '__main__':
    main()
