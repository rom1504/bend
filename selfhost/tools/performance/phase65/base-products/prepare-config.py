#!/usr/bin/env python3
"""Data-only: bind the closed Phase65 preparation to a small product census."""
import hashlib
import json
import pathlib
import sys

source, target, *wanted = sys.argv[1:]
assert wanted, 'Select real source IDs explicitly'
source, target = pathlib.Path(source).resolve(), pathlib.Path(target).resolve()
assert '/selfhost/build/phase65/' in str(source)
assert '/selfhost/' in str(target) and '/phase65/' in str(target) and not target.exists()


def pin(file):
    file = pathlib.Path(file).resolve()
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


report = json.loads(source.read_text())
assert report['complete']
preparations = [r['observation'] for r in report['preparations'] if r['observation']['role'] == 'baseline']
assert len(preparations) == 1
observation = preparations[0]
assert observation['complete'] and observation['pass'] and observation['image']['strictExact']
config = json.loads(pathlib.Path(report['config']['file']).read_text())
image = observation['image']
selected = [r for r in observation['outputs'] if r['id'] in wanted]
assert len(selected) == len(wanted)
result = dict(kind='phase65-base-product-census-input', generation='genuine-B2-diagnostic-derivative',
              provenance=[pin(source), report['config'], image['source'], image['emission'], image['checkedGenerator']],
              image={k: image[k] for k in ['api', 'driver', 'runtime', 'base']})
result['image']['node'] = config['node']
result['sources'] = [dict(id=r['id'], **r['source'], expectedOutput=r['output']) for r in selected]
for entry in result['provenance'] + list(result['image'].values()) + result['sources']:
    assert pin(entry['file'])['sha256'] == entry['sha256'], entry['file']
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(file=str(target), sources=[r['id'] for r in selected], api=image['api']['sha256'])))
