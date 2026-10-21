"""Summarize clean paired screens without changing their benchmark population."""
import argparse, hashlib, json, math, statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]

def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

p = argparse.ArgumentParser()
p.add_argument('--out', type=Path, required=True)
p.add_argument('screens', type=Path, nargs='+')
a = p.parse_args()
assert not a.out.exists()
manifest_file = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
manifest = json.loads(manifest_file.read_text())
eligible = {x['name']: x['ratioEligible'] for x in manifest['cases']}
result = dict(complete=True, inputs=[pin(__file__), pin(manifest_file)], screens=[],
              scope='Clean original-source program execution medians. Each screen has its own same-run parent/upstream controls. Geometric ratios are comparable only for the same population; no bootstrap or compiler-speed inference.')
for file in a.screens:
    screen = json.loads(file.read_text())
    assert screen['complete'] and all(x['correct'] for x in screen['rows'])
    result['inputs'].append(pin(file))
    summary = dict(file=str(file), observations=len(screen['rows']), cases=[])
    for name in dict.fromkeys(x['name'] for x in screen['rows']):
        samples = {role: [x['elapsedMs'] for x in screen['rows'] if x['name'] == name and x['role'] == role]
                   for role in ['candidate', 'baseline', 'upstream']}
        medians = {role: statistics.median(xs) for role, xs in samples.items()}
        row = dict(name=name, ratioEligible=eligible[name], samplesMs=samples, mediansMs=medians)
        if eligible[name]:
            assert all(x > 0 for x in medians.values())
            row.update(candidateOverBaseline=medians['candidate'] / medians['baseline'],
                       candidateOverUpstream=medians['candidate'] / medians['upstream'],
                       baselineOverUpstream=medians['baseline'] / medians['upstream'])
        summary['cases'].append(row)
    timed = [x for x in summary['cases'] if x['ratioEligible']]
    summary['timedCases'] = len(timed)
    for key in ['candidateOverBaseline', 'candidateOverUpstream', 'baselineOverUpstream']:
        summary[key] = math.exp(statistics.mean(math.log(x[key]) for x in timed))
    result['screens'].append(summary)
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps([{k: v for k, v in x.items() if k != 'cases'} for x in result['screens']], indent=2))
