#!/usr/bin/env python3
"""Derive final Phase64 qualification methods; bind no candidate and run no targets."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT/'selfhost/build/phase64'
PARENT = ROOT/'selfhost/build/phase63/qualification-method01/methods.json'
PARENT_SHA = '70e582d0c45da927b1e01424e4427446865eedd5b35f9f3aee42a4629ab957e6'
CORRECTION = ROOT/'selfhost/build/phase63/qualification-provenance-method02/derivation.json'
CORRECTION_SHA = 'e09ed6b80705461066eb1733d5b2e067189f33b15442c2ecfd870144a6495633'
CORRECTED_SHA = 'a346afcf8a44ec661acf1c675e802cccf541ef0b89148f9d6833f929cc4fcd54'
BOOTSTRAP = Path(__file__).resolve().parents[1]/'prepare-bootstrap.py'
BOOTSTRAP_SHA = 'f334bce3799ec89410a3ac29b42034b2a9f796c84ec7159de8906757291a36cf'


def pin(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    actual = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert actual['sha256'] == value['sha256'], str(file)
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.parent == RAW.resolve() and not out.exists()
    assert pin(PARENT)['sha256'] == PARENT_SHA
    assert pin(CORRECTION)['sha256'] == CORRECTION_SHA
    assert pin(BOOTSTRAP)['sha256'] == BOOTSTRAP_SHA
    parent, correction = [json.loads(file.read_text()) for file in [PARENT, CORRECTION]]
    assert parent['complete'] and parent['targetsExecuted'] is False
    assert correction['complete'] and correction['parentMethods'] == pin(PARENT)
    corrected_rows = {}
    inputs = [pin(__file__), pin(PARENT), pin(CORRECTION), pin(BOOTSTRAP),
              pin(Path(__file__).with_name('derivation.json'))]
    for row in correction['rows']:
        source, target = pin(row['parent']), pin(row['output'])
        text = Path(source['file']).read_text()
        for edit in row['edits']:
            assert text.count(edit['old']) == 1
            text = text.replace(edit['old'], edit['new'])
        assert text == Path(target['file']).read_text()
        corrected_rows[Path(target['file']).name] = row
        inputs.extend([source, target])
    assert corrected_rows['image-provenance.mjs']['output']['sha256'] == CORRECTED_SHA
    assert all(row['parent']['sha256'] == row['output']['sha256'] and not row['edits']
               for name, row in corrected_rows.items() if name != 'image-provenance.mjs')
    rows = []
    for original in parent['rows']:
        relative = original['relative']
        source = pin(original['output'])
        if relative == 'qualification/image-provenance.mjs':
            corrected = corrected_rows['image-provenance.mjs']
            assert corrected['parent'] == source
            source = pin(corrected['output'])
        text = Path(source['file']).read_text()
        edits = []

        def change(old, new):
            nonlocal text
            assert old in text, (relative, old)
            count = text.count(old)
            text = text.replace(old, new)
            edits.append(dict(old=old, new=new, occurrences=count))

        if 'selfhost/build/phase63' in text:
            change('selfhost/build/phase63', 'selfhost/build/phase64')
        for old, new in [('inside Phase63', 'inside Phase64'), ('stay in Phase63', 'stay in Phase64')]:
            if old in text:
                change(old, new)
        if relative == 'qualification/final-plan.py':
            change("BOOTSTRAP_PRODUCER=TOOLS/'phase63/latency/prepare-bootstrap.py'",
                   "BOOTSTRAP_PRODUCER=TOOLS/'phase64/latency/prepare-bootstrap.py'")
            change("BOOTSTRAP_SHA='85d412656f7abd44688e0799013b4c9284a5d2c4df6cc09e221abbab600b8ead'",
                   'BOOTSTRAP_SHA='+repr(BOOTSTRAP_SHA))
            change("FACTORY=Path('/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase63/latency/qualification/make-method.py')",
                   'FACTORY=Path('+repr(str(Path(__file__).resolve()))+')')
            change("FACTORY_SHA='2d0ac676c2eee36b658334ffd97fdb707fc18b2f928fde3ba5d00cd6f938dfe4'",
                   'FACTORY_SHA='+repr(pin(__file__)['sha256']))
            change("method['kind']=='phase63-final-qualification-methods'",
                   "method['kind']=='phase64-final-qualification-methods'")
        replay = Path(source['file']).read_text()
        for edit in edits:
            assert replay.count(edit['old']) == edit['occurrences']
            replay = replay.replace(edit['old'], edit['new'])
        assert replay == text
        if relative.endswith('.py'):
            ast.parse(text, filename=relative)
        inputs.append(source)
        rows.append(dict(relative=relative, parent=source, edits=edits, text=text))
    assert len(rows) == 17
    for item in inputs:
        pin(item)
    out.mkdir(parents=True)
    for row in rows:
        dest = out/row['relative']
        dest.parent.mkdir(parents=True, exist_ok=True)
        with dest.open('x') as stream:
            stream.write(row.pop('text'))
        row['output'] = pin(dest)
    result = dict(kind='phase64-final-qualification-methods', complete=True, targetsExecuted=False,
        producer=pin(__file__), parent=pin(PARENT), provenanceCorrection=pin(CORRECTION),
        baseline=parent['baseline'], inputs=inputs, rows=rows,
        scope='Phase64 writable boundaries and exact producer/factory bindings. Corrected optional '
        'canonicalPath/bytes validation precedes normalized file+sha256 identities from the first run. '
        'Four semantic controller bodies remain unchanged. Graph-helper/frame3 admission and JDPlan '
        'reproduction are inherited. No candidate source/API is bound, target run or release admitted. '
        'The preserved release-preparation command is not invoked by this factory.')
    for file in [out/'methods.json', out/'qualification/b2-methods-derivation.json']:
        with file.open('x') as stream:
            stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(methods=pin(out/'methods.json'), files=len(rows), targetsExecuted=False)))


if __name__ == '__main__':
    main()
