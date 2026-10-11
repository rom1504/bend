#!/usr/bin/env python3
"""Freeze the nine independent static/cold fixtures and literal source goldens."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def pin(p):
    p = p.resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', required=True, type=Path)
a = p.parse_args()
rows, sources = [], []
for family, expected in [('static-data', 3), ('node-reuse', 6)]:
    files = sorted((HERE.parent/family/'fixtures').glob('*.bend'))
    assert len(files) == expected, (family, len(files), expected)
    for file in files:
        source = pin(file)
        if any(x['source']['file'] == source['file'] for x in sources):
            assert any(x['source'] == source for x in sources)
            continue
        golden = [line[2:] for line in file.read_text().splitlines() if line.startswith('#|')]
        assert golden, file
        name = 'phase69/'+family+'/'+file.name
        rows.append(dict(id=name, file=source['file'], lanes=['native']))
        sources.append(dict(id=name, source=source, goldenLines=golden))
assert len(rows) == 9
with a.out.open('x') as f:
    json.dump(dict(cases=rows), f, indent=2)
    f.write('\n')
with a.out.with_suffix('.manifest.json').open('x') as f:
    json.dump(dict(kind='phase69-static-cold-native-selection', producer=pin(Path(__file__)),
                   selection=pin(a.out), expectedCases=9, sources=sources,
                   dataOnly=True, targetsExecuted=False), f, indent=2)
    f.write('\n')
print(json.dumps(dict(selection=pin(a.out), expectedCases=9, targetsExecuted=False)))
