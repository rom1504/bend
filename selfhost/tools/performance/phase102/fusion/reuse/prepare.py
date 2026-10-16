#!/usr/bin/env python3
"""Prepare a counted cell-reuse derivative of a frozen emitted-app catalog."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
from transform import transform


def pin(path):
    path = path.resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    parent = json.loads(args.catalog.read_text()); assert parent['complete']
    methods = [pin(p) for p in sorted(Path(__file__).parent.iterdir()) if p.suffix in ('.py','.c')]
    for item in methods:
        (out/('snapshot-'+Path(item['file']).name)).write_bytes(Path(item['file']).read_bytes())
    report = dict(complete=False, targetsRun=False, parent=pin(args.catalog), methods=methods,
                  compilerSource=parent['compilerSource'], api=parent['api'], programs=[],
                  scope='General private cell-reuse C prototype on complete Bend-emitted products; no compiler-emission or release claim.')
    for row in parent['programs']:
        for item in [row['source'], row['baselineC'], row['candidateC'], row['emissionReceipt']]:
            assert pin(Path(item['file'])) == item
        original = Path(row['candidateC']['file']).read_text()
        candidate, counts = transform(original)
        target = out/(row['id']+'.c'); target.write_text(candidate)
        report['programs'].append(dict(id=row['id'], source=row['source'], baselineC=row['baselineC'],
            emittedC=row['candidateC'], candidateC=pin(target), emissionReceipt=row['emissionReceipt'], counts=counts))
    report['complete'] = True
    (out/'catalog.json').write_text(json.dumps(report,indent=2)+'\n')
    (out/'prepare.py').write_text('''# Frozen general C-prototype product adapter.
from pathlib import Path
import hashlib
import json

def transform(source):
    catalog=json.loads(Path(__file__).with_name('catalog.json').read_text())
    digest=hashlib.sha256(source.encode()).hexdigest()
    rows=[r for r in catalog['programs'] if r['baselineC']['sha256']==digest]
    assert len(rows)==1
    row=rows[0]; data=Path(__file__).with_name(row['id']+'.c').read_bytes()
    assert hashlib.sha256(data).hexdigest()==row['candidateC']['sha256']
    return data.decode(),dict(parent=catalog['parent'],counts=row['counts'],scope=catalog['scope'])
''')
    print(json.dumps(dict(catalog=pin(out/'catalog.json'),workers={r['id']:len(r['counts']['workers']) for r in report['programs']})))


if __name__ == '__main__': main()
