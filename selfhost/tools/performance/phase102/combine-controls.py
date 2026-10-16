#!/usr/bin/env python3
"""Combine independent control manifests without changing their oracles."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--manifest', nargs='+', required=True, help='LABEL=PATH')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
report = dict(complete=True, targetsRun=False, records=[], pins=[R.pin(__file__)], parents=[])
for value in a.manifest:
    label, name = value.split('=', 1); manifest = R.read(name)
    parent = R.pin(name); report['parents'].append(parent); report['pins'].append(parent)
    for row in manifest['records']:
        report['records'].append(dict(row, id=label+'-'+row['id']))
        report['pins'].append(R.pin(row['source']))
        if 'expected' in row: report['pins'].append(R.pin(row['expected']))
    for pin in manifest.get('pins', []):
        actual = R.pin(pin.get('file', pin.get('path')))
        assert all(actual[k] == pin[k] for k in ('sha256', 'bytes'))
        report['pins'].append(actual)
assert len({r['id'] for r in report['records']}) == len(report['records'])
report['pins'] = list({v['file']:v for v in report['pins']}.values())
report['scope'] = 'Only IDs prefixed; source, arguments, expected bytes, workers and refusal/activation requirements unchanged.'
R.save(out/'controls.json', report)
print(R.json.dumps(dict(records=len(report['records']), sources=len({r['source'] for r in report['records']}))))
