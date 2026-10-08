#!/usr/bin/env python3
"""Prepare a fresh paired gate for explicitly repaired Phase68 fixtures; no targets."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]

def pin(value):
    item = value if isinstance(value, dict) else None
    path = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert result['sha256'] == item['sha256'], path
        if 'bytes' in item:
            assert result['bytes'] == item['bytes'], path
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('parent', 'manifest', 'selection', 'out'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    parent_pin, manifest_pin, selection_pin = map(pin, (args.parent, args.manifest, args.selection))
    parent, manifest, selection = (json.loads(Path(p['file']).read_text()) for p in (parent_pin, manifest_pin, selection_pin))
    assert parent['kind'] == 'phase68-native-selected-control-plan' and parent['targetExecuted'] is False
    assert manifest['targetExecuted'] is False
    assert selection['cases'] and len({r['id'] for r in selection['cases']}) == len(selection['cases'])
    inputs = [pin(p) for p in parent['inputs']] + [parent_pin, manifest_pin, selection_pin, pin(__file__)]
    for key in ('parent', 'candidate', 'failedObservation'):
        inputs.append(pin(manifest[key]))
    assert len(selection['cases']) == 1
    row = selection['cases'][0]
    assert row['lanes'] == ['native'] and row['file'] == manifest['candidate']['file']
    golden = [line[2:] for line in Path(row['file']).read_text().splitlines() if line.startswith('#|')]
    assert golden == manifest['goldenLines']
    output = args.out.resolve()
    output.relative_to(ROOT / 'selfhost/build/phase68')
    assert not output.exists()
    old = str(args.parent.resolve().parent)
    assert sum(old in word for word in parent['command']) == 3
    command = [word.replace(old, str(output)) for word in parent['command']]
    output.mkdir(parents=True)
    (output / 'selection.json').write_text(json.dumps(selection, indent=2) + '\n')
    result = dict(kind='phase68-repaired-fixture-plan', targetExecuted=False, complete=False,
        producer=pin(__file__), parent=parent_pin, repair=manifest_pin, attempt=parent['attempt'],
        selectedApi=parent['selectedApi'], selection=pin(output / 'selection.json'), expectedCases=1,
        command=command, report=str(output / 'execution/report.json'), inputs=inputs,
        scope='Fresh paired observation of one repaired source fixture. Original failed source, selection and observation remain unchanged; no prior failure is relabelled passing.')
    for item in inputs:
        pin(item)
    (output / 'plan.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(plan=pin(output / 'plan.json'), targetsExecuted=False)))

if __name__ == '__main__':
    main()
