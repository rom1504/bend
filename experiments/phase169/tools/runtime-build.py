#!/usr/bin/env python3
"""Execute a pinned private runtime build plan; no Bend lowering lives here."""
import argparse, json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, verify, require, run, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
plan = json.loads(a.plan.read_text())
require(plan['inverseExact'] and not plan['targetsRun'], 'Source-only exact plan required')
inputs = [pin(__file__), pin(a.plan), *plan['inputs'], plan['source'], *plan['headers']]
for item in inputs:
    verify(item)
out = fresh_output(a.out, ROOT)
report = dict(complete=False, inputs=inputs, variants=[], checks=[])
save = lambda: write_json(out / 'report.json', report)
try:
    for spec in plan['jobs']:
        label = spec['label']
        row = dict(label=label, flags=spec['flags'], jobs=[])
        report['variants'].append(row)
        obj, binary = out / (label + '.o'), out / label
        compile_command = [*spec['compile'][:-1], str(obj)]
        link_command = [str(obj) if value == spec['compile'][-1] else value
                        for value in spec['link']]
        link_command[-1] = str(binary)
        for step, command in [('compile', compile_command), ('link', link_command)]:
            job = run(command, cwd=ROOT, stdout=out / (label + '-' + step + '.stdout'),
                      stderr=out / (label + '-' + step + '.stderr'), seconds=30)
            row['jobs'].append(dict(step=step, **job)); save()
            require(job['complete'], label + ' ' + step + ' failed')
        row.update(object=pin(obj), binary=pin(binary)); save()
    rows = {r['label']: r for r in report['variants']}
    parent = json.loads((ROOT / 'selfhost/build/phase152/native-n2/report.json').read_text())
    for name, left, right in [
        ('disabled-runtime-equals-qualified', rows['baseline']['object'], parent['runtime']),
        ('disabled-image-equals-qualified', rows['baseline']['binary'], parent['binary']),
        ('atomic-flags-have-no-effect', rows['atomic-control']['object'], rows['atomic-flags']['object']),
    ]:
        equal = left['bytes'] == right['bytes'] and left['sha256'] == right['sha256']
        report['checks'].append(dict(name=name, equal=equal, left=left, right=right)); save()
        require(equal, name)
    for item in inputs:
        verify(item)
    report['complete'] = True
finally:
    save()
    print(json.dumps(dict(complete=report['complete'], variants=len(report['variants']), checks=report['checks'])))
