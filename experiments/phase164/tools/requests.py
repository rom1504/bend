#!/usr/bin/env python3
"""Cold-process native requests, exact hosted QBE comparison, bounded pairs."""
import argparse
import json
import statistics
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, run, write_json, fresh_output

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--emission', type=Path, required=True)
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--cases', help='Explicit comma-separated subset')
a = p.parse_args()
emission = json.loads(a.emission.read_text())
require(emission['complete'], 'Incomplete hosted control')
parent_path = ROOT / 'selfhost/build/phase152/native-n2/report.json'
parent = json.loads(parent_path.read_text())
candidate = json.loads(a.candidate.read_text())
require(parent['complete'] and candidate['complete'], 'Incomplete native acquisition')
images = {'baseline': parent['binary'], 'candidate': candidate['binary']}
base_request_path = ROOT / 'selfhost/build/phase163/reverse-baseline01/request.json'
base_request = json.loads(base_request_path.read_text())
base, carrier, stamp = (base_request[k] for k in ['base', 'carrier', 'stamp'])
for item in [base, carrier, *images.values()]:
    verify(item)
names = a.cases.split(',') if a.cases else [row['name'] for row in emission['rows']]
cases = [row for row in emission['rows'] if row['name'] in names]
require(len(cases) == len(set(names)), 'Unknown/duplicate case')
out = fresh_output(a.out, ROOT)
report = dict(complete=False, inputs=[pin(__file__), pin(a.emission), pin(a.candidate),
    pin(parent_path), pin(base_request_path), base, carrier, *images.values()], rows=[],
    scope='Fresh processes, same source/Base/carrier/CPU/runtime. Complete source-to-QBE '
    'including startup/frontend/output; excludes machine build. Exact independent hosted '
    'output per role, not a claim of baseline/candidate byte equality.')

def save():
    write_json(out / 'report.json', report)

def normalized(path):
    return b'\n'.join(line for line in Path(path).read_bytes().splitlines() if line.strip())

try:
    for index, case in enumerate(cases):
        source = case['source']; verify(source); report['inputs'].append(source)
        expected = {}
        for role in images:
            ir = case['products'][role]['ir']; verify(ir); report['inputs'].append(ir)
            expected[role] = normalized(ir['file'])
        row = dict(name=case['name'], source=source, complete=False, samples=[])
        report['rows'].append(row); save()
        for pair in range(2):
            for role in (['baseline', 'candidate'] if (index + pair) % 2 == 0 else ['candidate', 'baseline']):
                stem = f'{case["name"]}-{pair}-{role}'
                command = [images[role]['file'], '--threads', '1', '--gpu', 'off', '--',
                           'phase164', source['file'], base['file'], 'cache', carrier['file'], stamp]
                job = run(command, cwd=ROOT, stdout=out / (stem + '.ssa'),
                          stderr=out / (stem + '.stderr'), seconds=45)
                require(job['complete'] and job['stderr']['bytes'] == 0, 'Native request failed ' + stem)
                require(normalized(job['stdout']['file']) == expected[role],
                        'QBE differs from independent hosted execution ' + stem)
                row['samples'].append(dict(role=role, pair=pair, **job)); save()
        row['medianSeconds'] = {role: statistics.median(s['seconds'] for s in row['samples']
            if s['role'] == role) for role in images}
        row['ratio'] = row['medianSeconds']['candidate'] / row['medianSeconds']['baseline']
        row['complete'] = True; save()
    report['complete'] = True
except Exception as error:
    report['error'] = str(error)
    raise
finally:
    save()
    print(json.dumps(dict(complete=report['complete'], rows=len(report['rows']), error=report.get('error'))))
