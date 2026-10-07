#!/usr/bin/env python3
"""Relocate frozen qualification methods; data only, no imports of target code."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
TOOLS = ROOT / 'selfhost/tools/performance'
RAW = ROOT / 'selfhost/build/phase61'
BASELINE = ROOT / 'selfhost/build/phase58/checked-last01/attempt.json'
BASELINE_SHA = 'e500b277beb16202d1e16aa5f24ebbd6964ca8ba3eaed41e7ff0b988cd266de1'
BASELINE_API = '641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a'
OLD_API = '128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea'
PARENTS = {
    'bootstrap/prepare-candidate.py': 'b494389a40a0492be9cbded64cd5f8ce0289b807e49cf7e1c67da3c90821bbde',
    'bootstrap/setup.mjs': 'cce0fbb0ef8e3714bee1c789d9ba390db4801478416129c6b37ffddb2e5b35dd',
    'bootstrap/reproduce.mjs': 'eda7079a89b1995260cd9e8e896e027580e362518e0c7303904ee0d250ef6a37',
    'qualification/plan.py': '248f0ee0653426a2bc3f54ec48342e9637dec035b5ba332fca6bb5e6e8173f59',
    'qualification/b2-plan.py': '25d44830d44b6b45ad6344c04dc332a68651dd3f0d3faf8661b697071e848718',
    'qualification/final-orchestration-v2.py': 'f4a45b4f345c37e00be47b360071dd3006ffdb22fb5f75ee61d610c9550ffbf5',
    'qualification/direct-census.py': 'f60828cd97569a68a03f781ebc0fb0cbc4b0b4466689e37f1d8321eb0ef0e5d9',
    'qualification/checked-image.mjs': '0ef9377235127a2e170e0ce5b8ea2edcbc4850ed2a4fe974ad0bd8531bbc6984',
    'qualification/paired-fixtures-v2.mjs': '6a2947f7a3c9fd84f7a78215c607fd5f90773e1edddf31376828d2d1f7fe0fe7',
    'qualification/native3.mjs': '41b9dae213c57596f76821c549fdc07713917d5a53d203c1a650ce5bb45d25f5',
    'qualification/self-check.mjs': '41f7ddb91f12aec3090a602e8ae762c1c0d6fe477a3e894180ab167909e1d977',
    'qualification/acquire.mjs': 'ff0401ff8f887a988da5ae258a69fa00b5bb58368f5008da334f17e4873acbac',
    'qualification/image-provenance.mjs': '2612e640364545c435a5351fb9d9abf0dd7449ad334642c3af95d1be81f63b68',
    'qualification/composition-controls.mjs': 'e87340fdad71999fe7954e91d2b49b671e40db0979fd5cf8df69cc148f1f5b0a',
    'qualification/overapplication-controls.mjs': 'f42e3eaf13a38b3ada2f6c49f905b0e3cfd79c97512d28c51a63c8f5f6e27aa3',
    'qualification/numeric-controls.mjs': '5edf683d8c9b877b79bf4ed5bfcbe2c1d4f32ff4fa7d2a7e6ad8d52944d1f747',
    'qualification/source-controls.mjs': '82661103d43b1642e813642d64c9c620eda509638baf12e34f62195df5ee725a',
    'qualification/benchmark-equality.mjs': '694d1713a8e4bad4d3367131e0d5413367bc92acad6b056dddc0d371789b2164',
}


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def derive(relative, text):
    edits = []

    def change(old, new, required=False):
        nonlocal text
        count = text.count(old)
        if required:
            assert count, (relative, old)
        if count:
            text = text.replace(old, new)
            edits.append(dict(old=old, new=new, occurrences=count))

    change('selfhost/build/phase58', 'selfhost/build/phase61')
    change('inside Phase58', 'inside Phase61')
    change('stay in Phase58', 'stay in Phase61')
    change('Phase58 candidate own-source generation', 'Phase61 candidate own-source generation')
    # Output is exactly RAW/<one fresh directory>/{qualification,bootstrap},
    # preserving ROOT/parent-depth logic; the historical TOOLS ancestor differs.
    if relative in ['qualification/plan.py', 'qualification/final-orchestration-v2.py']:
        change('TOOLS=HERE.parents[1]', 'TOOLS=HERE.parents[4]/\'selfhost/tools/performance\'', True)
    if relative == 'qualification/direct-census.py':
        change("HERE.parents[1]/", "(ROOT/'selfhost/tools/performance')/", True)
    if relative == 'qualification/plan.py':
        change('selfhost/build/phase56/checked-string01/attempt.json',
               'selfhost/build/phase58/checked-last01/attempt.json', True)
        change(OLD_API, BASELINE_API, True)
    if relative == 'qualification/native3.mjs':
        change(OLD_API, BASELINE_API, True)
    if relative.endswith('.mjs'):
        for old, destination in [
            ('../../../development/workflow.mjs', ROOT/'selfhost/tools/development/workflow.mjs'),
            ('../../../development/process.mjs', ROOT/'selfhost/tools/development/process.mjs'),
            ('../../../conformance/inventory.mjs', ROOT/'selfhost/tools/conformance/inventory.mjs'),
            ('../../phase54/bootstrap/adapter.mjs', TOOLS/'phase54/bootstrap/adapter.mjs'),
            ('../../phase56/qualification/string-controls-v2.mjs', TOOLS/'phase56/qualification/string-controls-v2.mjs'),
        ]:
            change("from '"+old+"'", 'from '+json.dumps(destination.as_uri()))
            change("new URL('"+old+"',import.meta.url)", 'new URL('+json.dumps(destination.as_uri())+')')
        change("path.resolve(import.meta.dirname,'../../phase53')", json.dumps(str(TOOLS/'phase53')))
        change("path.resolve(import.meta.dirname,'../../../../build/phase58')", json.dumps(str(RAW)))
    return text, edits


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.parent == RAW.resolve() and not out.exists(), 'Fresh immediate Phase61 raw child required'
    baseline = identity(BASELINE)
    assert baseline['sha256'] == BASELINE_SHA
    b = json.loads(BASELINE.read_text())
    assert b['checked'] is True and b['config']['strictExact'] is True
    assert b['api']['sha256'] == BASELINE_API
    inputs = [identity(__file__), baseline]
    rows = []
    # Verify every source and prepare every transform before creating output.
    for relative, expected in PARENTS.items():
        parent = TOOLS/'phase58'/relative
        pin = identity(parent)
        assert pin['sha256'] == expected, relative
        original = parent.read_text()
        text, edits = derive(relative, original)
        replay = original
        for edit in edits:
            assert replay.count(edit['old']) == edit['occurrences']
            replay = replay.replace(edit['old'], edit['new'])
        assert replay == text
        if relative.endswith('.py'):
            ast.parse(text, filename=relative)
        inputs.append(pin)
        rows.append(dict(relative=relative, parent=pin, edits=edits, text=text))
    out.mkdir(parents=True)
    for row in rows:
        dest = out/row['relative']
        dest.parent.mkdir(parents=True, exist_ok=True)
        with dest.open('x') as stream:
            stream.write(row.pop('text'))
        row['output'] = identity(dest)
    for pin in inputs:
        assert identity(pin['file']) == pin
    result = dict(kind='phase61-frozen-validation-methods', complete=True, targetsExecuted=False,
                  producer=inputs[0], baseline=baseline, inputs=inputs, rows=rows,
                  scope='Metadata/path/baseline relocation only. Historical report kinds retain method lineage; no generated compiler imports, checked attempts or target results are manufactured.')
    for dest in [out/'methods.json', out/'qualification/b2-methods-derivation.json']:
        with dest.open('x') as stream:
            json.dump(result, stream, indent=2)
            stream.write('\n')
    print(json.dumps(dict(methods=identity(out/'methods.json'), count=len(rows), targetsExecuted=False)))


if __name__ == '__main__':
    main()
