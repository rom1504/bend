#!/usr/bin/env python3
"""Check the new pure partition helpers against closed Phase59 saved data only."""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
assert len(sys.argv) == 2
out = Path(sys.argv[1]).resolve()
assert ROOT/'selfhost/build/phase60' in out.parents and not out.exists()
inputs = {}
def read(path, expected=None):
    path = Path(path).resolve()
    data = path.read_bytes()
    value = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert value['sha256'] == expected
    inputs[str(path)] = value
    return json.loads(data)
source = Path(__file__).with_name('summarize.py')
assert hashlib.sha256(source.read_bytes()).hexdigest() == 'e268d35ee730e0b4f06267150ba56cce877fe8df5790e3ea23f1f1faf846d231'
spec = importlib.util.spec_from_file_location('phase60_partition_helpers', source)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)  # Its guarded main is not called; no compiler imported.
stages = read(ROOT/'selfhost/build/phase59/stages01/report.json')
known = read(ROOT/'selfhost/build/phase59/stages-analysis01/report.json',
             'ec046a8fc893e091805461e2f5c15cdbf9984bda6b1e884a35b529b4cef536da')
checks = []
for row in stages['rows']:
    expected = next(x for x in known['samples'] if all(x[k] == row[k] for k in ['case','role','sample']))
    actual = module.wall_partition(row['observation']['stages'])
    assert actual['groupsMs'] == expected['groupsMs'] and actual['totalMs'] == expected['totalMs']
    checks.append(dict(kind='exclusive-wall', case=row['case'], role=row['role'], sample=row['sample'], equal=True))
known = read(ROOT/'selfhost/tools/performance/phase59/evidence/profile-stage-attribution-v1.json',
             '55e71c37afc2afac5817983873a4aca84e8bde1a0b3c5f4f701531dbacc30454')
for row in known['rows']:
    raw = read(row['raw']['file'], row['raw']['sha256'])
    roots = {(r['url'],r['functionName']):r['stage'] for r in row['rootPolicy']}
    api_url = next((url for url,name in roots if name.startswith('$jd$')), None)
    actual = module.profile_partition(raw,row['mode'],roots,api_url)
    assert actual['total'] == row['total'] and actual['sampleEvents'] == row['sampleEvents']
    assert {x['name']:x['mass'] for x in actual['ancestorStages']} == {x['stage']:x['mass'] for x in row['partitions']}
    checks.append(dict(kind='exact-ancestor', campaign=row['campaign'], case=row['case'], role=row['role'], mode=row['mode'], equal=True))
for identity in inputs.values():
    assert hashlib.sha256(Path(identity['file']).read_bytes()).hexdigest() == identity['sha256']
report = dict(kind='phase60-saved-partition-regression-check', complete=True, dataOnly=True,
              targetExecuted=False, checks=checks, inputs=list(inputs.values()),
              analyzer=dict(file=str(source),sha256=hashlib.sha256(source.read_bytes()).hexdigest()),
              producer=dict(file=str(Path(__file__).resolve()),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()))
report['pass'] = True
out.mkdir(parents=True)
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(output=str(out),checks=len(checks),pass_=True)))
