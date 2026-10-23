#!/usr/bin/env python3
"""Count exact frozen compiler sources and classify their added declarations.

Lexical dependency groups explain source growth; they are not a semantic proof
of executable reachability. No compiler or generated program is executed.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
PAT = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
STRING = re.compile(r'"(?:[^"\\]|\\.)*"')
WORD = re.compile(r'\b[A-Za-z_][A-Za-z0-9_.]*\b')


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        while b := f.read(1048576):
            h.update(b)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def code_lines(text):
    return sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in text.splitlines())


def inventory(text):
    hits = list(PAT.finditer(text))
    bodies = collections.defaultdict(str)
    for i, hit in enumerate(hits):
        bodies[hit[2]] += text[hit.start():hits[i+1].start() if i+1 < len(hits) else len(text)]
    return dict(bodies), dict(collections.Counter(h[1] for h in hits))


def norm(text):
    return '\n'.join(x.rstrip() for x in text.splitlines() if x.strip() and not x.lstrip().startswith('#'))


def refs(text):
    return set(WORD.findall(re.sub(r'#[^\n]*', '', STRING.sub('""', text))))


def closure(roots, bodies, admitted):
    todo, seen = list(roots), set()
    while todo:
        name = todo.pop()
        for dep in refs(bodies[name]) & admitted - seen:
            seen.add(dep)
            todo.append(dep)
    return seen


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131')
    parent = ROOT / 'selfhost/build/phase130/mode-source01/compiler.bend'
    before_text = parent.read_text()
    before, kinds = inventory(before_text)
    rows = []
    base = dict(name='Phase130', source=pin(parent), physicalLines=len(before_text.splitlines()),
                codeLines=code_lines(before_text), declarationHeads=kinds, uniqueDeclarationNames=len(before),
                unsafeMarkers=len(re.findall(r'^@unsafe$', before_text, re.M)))
    for name in ['combined-fast-source02', 'combined-first-order-source01', 'combined-codegen-source01', 'combined-regions-source01']:
        manifest_path = ROOT / 'selfhost/build/phase131' / name / 'manifest.json'
        m = json.loads(manifest_path.read_text())
        source = Path(m['source']['file'])
        assert pin(source) == m['source'] and m['parent'] == base['source']
        text = source.read_text()
        bodies, kinds = inventory(text)
        added = set(bodies) - set(before)
        changed = {n for n in before if norm(bodies[n]) != norm(before[n])}
        assert added == set(m['added']) and changed <= set(m['overrides'])
        production = closure(changed, bodies, added)
        control_roots = set()
        modules = []
        for p in m['inputs']:
            path = Path(p['file'])
            if path.suffix != '.bend' or path.name == 'compiler.bend':
                continue
            assert pin(path) == p
            names = set(inventory(path.read_text())[0]) & added
            controls = 'controls' in path.name
            if controls:
                control_roots.update(names)
            modules.append(dict(source=p, controlModule=controls, addedNames=sorted(names)))
        control_roots.update(n for n in added if 'controls' in n)
        control = (control_roots | closure(control_roots, bodies, added)) - production
        remaining = added - production - control
        delta_existing = sum(code_lines(bodies[n]) - code_lines(before[n]) for n in changed)
        groups = {}
        for label, names in [('productionConnectedHelpers', production), ('controlsAndReferenceHelpers', control), ('unconnectedAdditions', remaining)]:
            groups[label] = dict(count=len(names), codeLines=sum(code_lines(bodies[n]) for n in names), names=sorted(names))
        assert code_lines(text) - base['codeLines'] == delta_existing + sum(x['codeLines'] for x in groups.values())
        rows.append(dict(name=name, manifest=pin(manifest_path), source=m['source'],
            physicalLines=len(text.splitlines()), codeLines=code_lines(text), declarationHeads=kinds,
            uniqueDeclarationNames=len(bodies), unsafeMarkers=len(re.findall(r'^@unsafe$', text, re.M)),
            physicalLineDelta=len(text.splitlines()) - base['physicalLines'], codeLineDelta=code_lines(text) - base['codeLines'],
            declaredOverrides=m['overrides'], changedExistingNames=sorted(changed),
            existingCodeLineDelta=delta_existing, additions=groups, modules=modules,
            status='Source inventory only; manifest composition is not source checking/native qualification.'))
    products = []
    for f in ['selfhost/build/phase111/p130-full-emit01/report.json', 'selfhost/build/phase130/p131-fast-acquire01/report.json',
              'selfhost/build/phase111/p130-native01-n1/report.json', 'selfhost/build/phase111/p131-fast-native01-n1/report.json']:
        p = ROOT / f
        r = json.loads(p.read_text())
        assert r['complete']
        product = r.get('product') or r['binary']
        assert pin(product['file']) == product
        item = dict(receipt=pin(p), product=product)
        if product['file'].endswith('.ssa'):
            with Path(product['file']).open('rb') as stream:
                item['physicalQbeLines'] = sum(1 for _ in stream)
        products.append(item)
    report = dict(complete=True, method=pin(__file__), parent=base, candidates=rows, nativeProducts=products,
        scope='Counts only the actual complete compiler.bend files and separately pinned complete products. '
        'No external law, benchmark, host harness or experiment document contributes to compiler line totals. '
        'Code lines exclude blank/full-line comments; physical lines retain both. Declaration heads count '
        'forward law signatures separately from definitions, not proved theorems or concepts. Added helper '
        'classification is lexical dependency reachability from changed existing declarations after string/comment '
        'removal, with control-module seeds. It is auditable source accounting, not dynamic reachability or proof.')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    print(json.dumps(dict(complete=True, parent=base, candidates=[{k:r[k] for k in ['name','physicalLines','codeLines','uniqueDeclarationNames','existingCodeLineDelta','additions']} for r in rows]), indent=2))


if __name__ == '__main__':
    main()
