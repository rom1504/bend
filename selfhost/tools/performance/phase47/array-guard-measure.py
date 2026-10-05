#!/usr/bin/env python3
"""ROOT ONLY: five rotated fresh-process rounds of saved guard variants.
Usage: array-guard-measure.py PROBE_DIR NEW_OUT [NODE]
Uses maintained execute.mjs, 1000-ms warmup, 50-ms calibration, 200-ms target.
45 processes: expect about 60–90s, not 30s. No compiler builds or profiling.
"""
import importlib.util
import json
import statistics
import sys
import time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('p47_guard_support', ROOT/'selfhost/tools/performance/programs/support.py')
s = importlib.util.module_from_spec(spec); spec.loader.exec_module(s)
probe, out = (Path(x).resolve() for x in sys.argv[1:3])
node = Path(sys.argv[3] if len(sys.argv) > 3 else '/home/ai/.nvm/versions/node/v24.18.0/bin/node').resolve()
manifest = json.loads((probe/'manifest.json').read_text())
assert manifest['complete'] and manifest['diagnosticOnly'] and not manifest['productionSafe']
for row in manifest['inputs']: assert s.identity(row['path']) == row
for row in manifest['variants'].values(): assert s.identity(row['path']) == row
for row in manifest['points']: assert s.identity(row['config']['path']) == row['config']
driver = ROOT/'selfhost/tools/performance/programs/execute.mjs'
inputs = [s.identity(x) for x in [__file__, probe/'manifest.json', driver, node]]
inputs += list(manifest['variants'].values()) + [x['config'] for x in manifest['points']]
out.mkdir(parents=True, exist_ok=False)
report = dict(kind='phase47-array04-guard-timing', complete=False, passed=False,
    diagnosticOnly=True, productionSafe=False, inputs=inputs, records=[],
    protocol=dict(rounds=5, cpu=3, warmupMs=1000, targetMs=200, calibrationMs=50,
                  scope='Guard-only derivatives; canonical input and localGuard preserved.'))
s.save(out/'report.json', report)
started = time.monotonic(); deadline = started + 180
names = list(manifest['variants']); points = manifest['points']
with s.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
    for r in range(5):
        for point in points[r % 3:] + points[:r % 3]:
            for name in names[r % 3:] + names[:r % 3]:
                label = f'r{r}-{point["id"]}-{name}'
                result = out/(label+'.json')
                cmd = ['taskset','-c','3',str(node),'--stack-size=4096','--max-old-space-size=1024',
                       str(driver),manifest['variants'][name]['path'],point['config']['path'],str(result)]
                proc = guard.run(cmd, out/('job-'+label), min(deadline, time.monotonic()+15))
                row = dict(round=r, point=point['id'], variant=name, process=proc)
                report['records'].append(row); s.save(out/'report.json', report)
                assert proc['complete'], label
                row['result'] = json.loads(result.read_text())
                assert row['result']['complete'] and row['result']['pass'], label
                s.save(out/'report.json', report)
                print(json.dumps(dict(label=label, msPerCall=row['result']['msPerCall'])), flush=True)
report['summary'] = {}
for point in points:
    rows = {}
    for name in names:
        values = [x['result']['msPerCall'] for x in report['records'] if x['point']==point['id'] and x['variant']==name]
        rows[name] = dict(medianMs=statistics.median(values), minimumMs=min(values), maximumMs=max(values), samplesMs=values)
    report['summary'][point['id']] = rows
for row in inputs: assert s.identity(row['path']) == row
for row in manifest['inputs']: assert s.identity(row['path']) == row
report.update(complete=True, passed=True, wallSeconds=time.monotonic()-started)
s.save(out/'report.json', report)
