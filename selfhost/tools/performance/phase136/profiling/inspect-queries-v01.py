#!/usr/bin/env python3
"""Read-only extraction of exact qualified query QBE; never executes a target."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
QBE = ROOT / 'selfhost/build/phase130/p134-selected-self01/program.ssa'
QBE_SHA = '2c25748d8a0eae711a7dd641d372bbce9f1fb4827dbe95e781b9f1cd11668aec'
SOURCE = ROOT / 'selfhost/build/phase134/verify-selected-source01/compiler.bend'
RUNTIME = ROOT / 'selfhost/build/phase128/runtime-borrow01/runtime.c'
NAMES = ['f_find', 'lookup', 'nc_ctor_owned', 'dn', 'f_eq']

def pin(path):
    digest = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            digest.update(block)
    return {'path': str(path.relative_to(ROOT)), 'sha256': digest.hexdigest(), 'bytes': path.stat().st_size}

def symbol(name):
    return 'p113d_FID_' + ''.join(str(ord(c)) + '_' for c in '$direct.' + name)

def extract(wanted):
    result, active, lines, start = {}, None, [], None
    with QBE.open() as f:
        for number, line in enumerate(f, 1):
            if active is None:
                match = re.match(r'(?:export )?function \w+ \$(\w+)\(', line)
                if match and match[1] in wanted:
                    active, lines, start = match[1], [line], number
            else:
                lines.append(line)
                if line == '}\n':
                    assert active not in result
                    result[active] = (start, lines)
                    active = None
    assert set(result) == set(wanted), set(wanted) - set(result)
    return result

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', required=True)
    args = parser.parse_args()
    out = (ROOT / args.out).resolve()
    assert out.is_relative_to(ROOT / 'implementation/phase136/profiling')
    assert not out.exists(), 'fresh output required'
    parent = pin(QBE)
    assert parent['sha256'] == QBE_SHA
    found = extract([symbol(n) for n in NAMES])
    scc = re.findall(r'call \$(p113d_FID_\w+)\(', ''.join(found[symbol('f_find')][1]))
    assert len(scc) == 1
    found.update(extract(scc))
    labels = {symbol(n): n for n in NAMES}
    labels[scc[0]] = 'f_find-scc'
    out.mkdir(parents=True)
    rows, blocks = [], []
    ranges = {
        'f_find': [(1, 8)],
        'f_find-scc': [(23, 29), (119, 153)],
        'lookup': [(33, 76), (345, 396), (485, 511)],
        'nc_ctor_owned': [(31, 74), (165, 183), (268, 286), (405, 421), (531, 552)],
        'dn': [(1, 45)],
        'f_eq': [(1, 20)],
    }
    for sym, (start, lines) in found.items():
        name = labels[sym]
        calls = collections.Counter(re.findall(r'call \$(\w+)\(', ''.join(lines)))
        sites = []
        for i, line in enumerate(lines):
            if re.search(r'call \$p111_rt_take\(.*w 9\)', line):
                end = next(j for j in range(i + 1, len(lines)) if lines[j].startswith(('jmp ', 'ret ', 'jnz ', '@')))
                block = lines[i:end]
                sites.append({'qbeLine': start + i, 'localLine': i + 1,
                              'loadsBeforeNextBranch': sum(' =l loadl ' in x for x in block),
                              'sinkCallsBeforeNextBranch': sum('call $p111_rt_sink(' in x for x in block)})
        rows.append({'name': name, 'symbol': sym, 'qbeLine': start, 'lines': len(lines),
                     'bodySha256': hashlib.sha256(''.join(lines).encode()).hexdigest(),
                     'staticCallSites': sum(calls.values()), 'calls': dict(calls),
                     'take9Sites': sites,
                     'localLoopJumps': [start + i for i, l in enumerate(lines) if l == 'jmp @p113_loop\n'],
                     'schedulerCalls': {k: v for k, v in calls.items() if re.search(r'^(p111_(?:call|push|set_regs|finish|jump)|p111_rt_(?:call|push))', k)}})
        blocks.append(f'## {name}\n\nParent function starts at QBE line {start}; body SHA256 `{rows[-1]["bodySha256"]}`.\n')
        for lo, hi in ranges[name]:
            hi = min(hi, len(lines))
            blocks.append(f'\nParent QBE lines {start + lo - 1}–{start + hi - 1}:\n\n```text\n' +
                          ''.join(f'{start + i}: {lines[i]}' for i in range(lo - 1, hi)) + '```\n')
    runtime_lines = RUNTIME.read_text().splitlines(keepends=True)
    for lo, hi in [(879, 895), (1015, 1053), (3890, 3920), (4624, 4637)]:
        blocks.append(f'## Runtime {lo}–{hi}\n\n```c\n' + ''.join(f'{i + 1}: {runtime_lines[i]}' for i in range(lo - 1, hi)) + '```\n')
    report = {'kind': 'phase136-qualified-query-static-inspection', 'complete': True,
              'inputs': [parent, pin(SOURCE), pin(RUNTIME), pin(Path(__file__).resolve())],
              'scope': 'Static sites include mutually exclusive paths; no dynamic counts, allocation sites or speed estimates.',
              'functions': rows}
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    (out / 'extracts.md').write_text('# Exact qualified generated query extracts\n\n' +
        f'Parent QBE SHA256 `{QBE_SHA}`. All numbers below are lines in that immutable parent, not rewritten pseudocode.\n\n' + ''.join(blocks))
    print(json.dumps({'complete': True, 'report': str(out / 'report.json'), 'functions': len(rows)}))

if __name__ == '__main__':
    main()
