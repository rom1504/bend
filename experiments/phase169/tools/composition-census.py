#!/usr/bin/env python3
"""Offline comparison of retained editdist IR/assembly; executes no targets."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PRODUCTS = {
    'phase152': ('selfhost/build/phase152/programs45-acquire01/editdist/phase152', 'emission'),
    'early': ('selfhost/build/phase169/program-screen-acquire01/editdist/candidate', 'emission'),
    'arrays': ('selfhost/build/phase169/certified-editdist01', 'emit'),
    'composition': ('selfhost/build/phase169/ordinary-editdist01', 'emit'),
}
OWNERS = ['$product.row', '$direct.row', '$product.cell', '$direct.cell',
          *['$product.cell.f' + str(i) for i in range(1, 5)],
          '$direct.init', '$direct.gen', '$product.dp.row']


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def decoded(symbol):
    if '_FID_' not in symbol:
        return symbol
    family, name = symbol.split('_FID_', 1)
    return family + ':' + ''.join(chr(int(x)) for x in name.rstrip('_').split('_'))


def functions(text):
    return {match[1]: match[0] for match in re.finditer(
        r'^(?:export )?function [wl] \$([A-Za-z0-9_]+)\([^\n]*\n.*?^}\n',
        text, re.M | re.S)}


def calls(text, pattern):
    return dict(sorted(collections.Counter(decoded(x) for x in re.findall(pattern, text)).items()))


def inspect(role, root, emission):
    ir = root / emission / 'program.ssa'
    machine = root / 'machine/report.json'
    report = json.loads(machine.read_text())
    assert report['complete']
    actual = pin(ir)
    assert actual['sha256'] == report['irDigest']['sha256']
    assert actual['bytes'] == report['irDigest']['bytes']
    assembly = root / 'machine/program.s'
    text, asm = ir.read_text(), assembly.read_text()
    fs = functions(text)
    descriptor = re.search(r'^export data \$p111_program = align 8 \{ (.*?) \}$', text, re.M)[1]
    selected = {}
    for symbol, body in fs.items():
        key = decoded(symbol)
        if key not in ['p113d:' + owner for owner in OWNERS]:
            continue
        start = asm.index('\n' + symbol + ':\n') + 1
        end = asm.index('/* end function ' + symbol + ' */', start)
        machine_body = asm[start:end]
        selected[key] = dict(qbeBytes=len(body.encode()), qbeSha256=hashlib.sha256(body.encode()).hexdigest(),
            qbeCalls=calls(body, r'\bcall \$([A-Za-z0-9_]+)'),
            arrayTemplateReferences=body.count('p113a_'),
            asmBytes=len(machine_body.encode()), asmSha256=hashlib.sha256(machine_body.encode()).hexdigest(),
            asmInstructions=len(re.findall(r'^\t[a-z][a-z0-9]*\b', machine_body, re.M)),
            asmCalls=calls(machine_body, r'^\tcallq? ([A-Za-z0-9_]+)'))
    return dict(role=role, ir=actual, machine=pin(machine), assembly=pin(assembly),
        runtime=report['runtime'], descriptor=descriptor, capability=int(descriptor.split(', ')[11][2:]),
        functions=len(fs), families=dict(collections.Counter(decoded(x).split(':')[0] for x in fs)),
        selected=selected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    products = {role: inspect(role, ROOT / root, emission) for role, (root, emission) in PRODUCTS.items()}
    assert len({p['runtime']['sha256'] for p in products.values()}) == 1
    timings = {}
    for role, name in [('early', 'program-screen-timing01'), ('arrays', 'certified-editdist-timing02'),
                       ('composition', 'ordinary-editdist-timing01')]:
        path = ROOT / 'selfhost/build/phase169' / name / 'report.json'
        report = json.loads(path.read_text())
        assert report['complete'] and report['aggregate']['complete']
        case = next(c for c in report['cases'] if c['id'] == 'editdist')
        assert all(s['correct'] for s in case['samples'])
        timings[role] = dict(report=pin(path), summary=case['summary'],
                            correctObservations=len(case['samples']))
    result = dict(complete=True, targetsRun=False, method=pin(Path(__file__)), products=products, timings=timings,
        scope='Static selected function shapes plus independent retained timing receipts; no new benchmark.')
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({role: dict(capability=p['capability'], functions=p['functions'],
        row=p['selected']['p113d:$product.row']) for role, p in products.items()}, indent=2))


if __name__ == '__main__':
    main()
