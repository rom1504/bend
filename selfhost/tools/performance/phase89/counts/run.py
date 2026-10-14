#!/usr/bin/env python3
"""Run a bound diagnostic derivative; never admit it as a production consumer."""
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
P = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(P / 'phase88'))
from broad import guard, pin, save
from native_support import authenticate, native_args, DEFAULT_CACHE, verify

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
p.add_argument('--cases', default='map_closed,lexer_original,numeric_closed')
a = p.parse_args()
out = a.out.resolve()
out.mkdir(parents=True, exist_ok=False)
auth = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
build = ROOT / 'selfhost/build/phase89'
derivation_path = build / 'counts-source01/derivation.json'
derivation = json.loads(derivation_path.read_text())
assert derivation['complete'] and verify(derivation['source']) == auth['c']
inputs = [verify(derivation[k]) for k in ['output', 'method', 'header']]
inputs.extend([pin(derivation_path), pin(__file__)])
image = pin(build / 'compiler-counts01')
build_guard = build / 'counts-build01-guard'
process = json.loads((build_guard / 'process.json').read_text())
assert process['complete'] and process['returncode'] == 0
bound = json.loads((build_guard / 'inputs.json').read_text())
assert any(x['sha256'] == inputs[0]['sha256'] for x in bound)
assert any(str(x).endswith('/compiler-counts01') for x in process['command'])
inputs.extend([image, pin(build_guard / 'process.json')])
baseline = json.loads((ROOT / 'selfhost/build/phase88/screen01/report.json').read_text())
report = dict(complete=False, passed=False, kind='phase89-counter-derivative',
              baseline=auth, inputs=inputs, rows=[],
              limitation='Experimental derivative; unchanged external assets are authenticated through the canonical image. No cache-consumer or speed promotion.')
save(out / 'report.json', report)
for name in a.cases.split(','):
    source = pin(baseline['cases'][name])
    prefix = out / name
    cmd = native_args(auth, source['file'], prefix, 5)
    cmd[0] = image['file']  # Explicit diagnostic derivative, bound above.
    job = guard(Path(str(prefix) + '-guard'), cmd, 90)
    oracle = next(r['outputs'][0]['sha256'] for r in baseline['rows'] if r['case'] == name and r['role'] == 'b2')
    outputs = [pin(Path(str(prefix) + f'.{i}.c')) for i in range(1, 6) if Path(str(prefix) + f'.{i}.c').exists()]
    exact = len(outputs) == 5 and all(x['sha256'] == oracle for x in outputs)
    row = dict(case=name, source=source, job=job, outputs=outputs, exact=exact)
    report['rows'].append(row)
    save(out / 'report.json', report)
    assert job['pass_'] and exact, 'Diagnostic target/output failed; evidence retained'
    counts = out / f'{name}-counts.json'
    subprocess.run([sys.executable, '-B', str(Path(__file__).with_name('analyze.py')),
                    str(Path(job['guard']) / 'stderr.log'), str(counts)], check=True)
    row['counts'] = pin(counts)
    assert pin(source['file']) == source
    save(out / 'report.json', report)
for x in inputs:
    assert pin(x['file']) == x
assert authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE) == auth
report.update(complete=True, passed=True)
save(out / 'report.json', report)
