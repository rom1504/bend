#!/usr/bin/env python3
"""Serial checked hosted acquisition of explicit native45 pilots, under one guard."""
import argparse
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, fresh_output, run, require, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--receipt', type=Path, required=True)
p.add_argument('--cases', required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
catalog_path = ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'
catalog = json.loads(catalog_path.read_text())
cases = {row['id']:row for row in catalog['cases']}
names = a.cases.split(',')
require(len(names) == len(set(names)) and all(name in cases for name in names), 'Invalid cases')
inputs = [pin(__file__), pin(a.receipt), pin(catalog_path), pin(Path(__file__).with_name('one-build.py'))]
sources = {}
for name in names:
    source = dict(cases[name]['source'])
    source['file'] = str(ROOT/'selfhost/tools/bench'/source['file'])
    verify(source)
    inputs.append(source)
    sources[name] = source
out = fresh_output(a.out, ROOT)
report = dict(complete=False, inputs=inputs, cases=names, rows=[],
    scope='Hosted checked pilot acquisition only; independent program-output gates follow.')
try:
    for name in names:
        command = [sys.executable, '-B', str(Path(__file__).with_name('one-build.py')),
            '--receipt', str(a.receipt.resolve()), '--source', sources[name]['file'],
            '--role', 'stream', '--preparation', 'cache', '--out', str(out/name)]
        job = run(command, cwd=ROOT, stdout=out/(name+'.stdout'), stderr=out/(name+'.stderr'), seconds=60)
        report['rows'].append(dict(name=name, process=job))
        write_json(out/'report.json', report)
        require(job['complete'], 'Pilot build failed: '+name)
        built = json.loads((out/name/'report.json').read_text())
        require(built['complete'], 'Incomplete build: '+name)
        report['rows'][-1]['receipt'] = pin(out/name/'report.json')
    for item in inputs:
        verify(item)
    report['complete'] = True
finally:
    write_json(out/'report.json', report)
    print(json.dumps(dict(complete=report['complete'], cases=len(report['rows']))))
