#!/usr/bin/env python3
"""Bind Bend-produced C to the frozen application benchmark input identities."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[4]
ACQUISITIONS = dict(zip(('source-index','image-render','dependency-plan'),
                       ('source-acquire01','image-acquire01','dependency-acquire02')))


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emission', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = json.loads(a.emission.read_text()); assert report['complete']
    rows = []
    for program in report['programs']:
        app = program['id']
        if app not in ACQUISITIONS: continue
        acquisition = ROOT/'selfhost/build/phase100'/ACQUISITIONS[app]/'report.json'
        old = json.loads(acquisition.read_text()); assert old['complete']
        original = next(v for v in old['apps'] if v['id'] == app)
        assert original['source'] == program['source']
        for value in [program['source'], program['c'], program['receipt'], original['products']['b2']['c']]:
            assert pin(value['file']) == value
        target = out/(app+'.c'); shutil.copyfile(program['c']['file'], target)
        rows.append(dict(id=app, source=program['source'], baselineC=original['products']['b2']['c'],
                         candidateC=pin(target), emittedC=program['c'], emissionReceipt=program['receipt']))
    assert rows
    manifest = dict(complete=True, method=pin(__file__), emission=pin(a.emission),
                    compilerSource=report['compilerSource'], api=report['api'], programs=rows,
                    scope=report['scope'])
    (out/'catalog.json').write_text(json.dumps(manifest, indent=2)+'\n')
    (out/'prepare.py').write_text('''# Exact-product adapter, no generated-C optimization here.
from pathlib import Path
import hashlib
import json

def transform(source):
    catalog = json.loads(Path(__file__).with_name('catalog.json').read_text())
    digest = hashlib.sha256(source.encode()).hexdigest()
    matches = [r for r in catalog['programs'] if r['baselineC']['sha256'] == digest]
    assert len(matches) == 1
    row = matches[0]; file = Path(__file__).with_name(row['id'] + '.c')
    data = file.read_bytes(); assert hashlib.sha256(data).hexdigest() == row['candidateC']['sha256']
    return data.decode(), dict(kind='Bend-produced C: exact product adapter, no C rewrite',
        compilerSource=catalog['compilerSource'], api=catalog['api'],
        emission=catalog['emission'], emissionReceipt=row['emissionReceipt'], scope=catalog['scope'])
''')
    print(json.dumps(dict(catalog=pin(out/'catalog.json'), products=len(rows))))


if __name__ == '__main__': main()
