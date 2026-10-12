#!/usr/bin/env python3
"""Combine the unchanged integration gate and corrected new native witnesses."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
PHASE = HERE.parent

def pin(path):
    path = Path(path).resolve(strict=True)
    return dict(file=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest())

sources = [
    ROOT/'selfhost/tools/performance/phase68/controls/integration-v3/integration-selection.json',
    PHASE/'reachability/selection-v1.json',
    PHASE/'closure-factory/selection-v3.json',
    PHASE/'closure-factory/selection-v5.json',
    HERE/'static-cold-selection-v1.json',
    PHASE/'node-reuse/selection-refusal-v2.json',
    PHASE/'node-reuse/typed-selection-v2.json',
    PHASE/'static-data/resource-controls/long-selection-v1.json',
]
replaced = {
    'phase69/node-reuse/captured-user-refusal.bend',
    'phase69/node-reuse/container-user-refusal.bend',
    'phase69/node-reuse/shared-user-refusal.bend',
}
cases, removed, duplicates, seen = [], [], [], {}
for source in sources:
    for item in json.loads(source.read_text())['cases']:
        if item['id'] in replaced:
            removed.append(item)
            continue
        item = dict(item)
        file = Path(item.get('file', ROOT/'selfhost/.bootstrap/upstream-phase66/tests'/item['id'])).resolve(strict=True)
        assert file.suffix == '.bend' and item['lanes'] == ['native']
        assert any(line.startswith('#|') for line in file.read_text().splitlines())
        item['file'] = str(file)
        if str(file) in seen:
            duplicates.append(dict(omitted=item, retained=seen[str(file)]))
            continue
        assert item['id'] not in {case['id'] for case in cases}
        seen[str(file)] = item['id']
        cases.append(item)
assert len(removed) == 3
output = HERE/'final-selection-v2.json'
manifest = HERE/'final-selection-v2.manifest.json'
assert not output.exists() and not manifest.exists()
output.write_text(json.dumps(dict(cases=cases), indent=2)+'\n')
manifest.write_text(json.dumps(dict(
    producer=pin(__file__), inputs=[pin(p) for p in sources],
    output=pin(output), cases=len(cases), replacedInvalidFixtures=removed,
    identicalFileDuplicates=duplicates,
    sourcePins=[pin(Path(case['file'])) for case in cases],
    targetsExecuted=False), indent=2)+'\n')
print(json.dumps(dict(selection=str(output), cases=len(cases), duplicates=len(duplicates))))
