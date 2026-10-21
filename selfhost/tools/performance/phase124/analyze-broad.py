"""Add frozen-family weighting, descriptive round spread and emitted-size accounting."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
def read(p): return json.loads(Path(p).read_text())
def pin(p):
    p = Path(p).resolve(); data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
def gm(xs): return math.exp(statistics.mean(math.log(x) for x in xs))
p = argparse.ArgumentParser()
p.add_argument('--summary', type=Path, required=True)
p.add_argument('--emission', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); assert not a.out.exists()
manifest = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
parent = ROOT / 'selfhost/build/phase118/p123-broad-emit04/report.json'
summary = read(a.summary); assert summary['complete'] and len(summary['screens']) == 1
screen = summary['screens'][0]; raw = read(screen['file'])
assert raw['complete'] and len(raw['rows']) == 405 and all(x['correct'] for x in raw['rows'])
cases = read(manifest)['cases']; assert {x['name'] for x in cases} == {x['name'] for x in screen['cases']}
families = {c['name']:c['family'] for c in cases}
eligible = [x for x in screen['cases'] if x['ratioEligible']]
groups = {}
for row in eligible: groups.setdefault(families[row['name']], []).append(row)
family_rows = [dict(family=f, cases=[r['name'] for r in rs],
                    candidateOverBaseline=gm([r['candidateOverBaseline'] for r in rs]),
                    candidateOverUpstream=gm([r['candidateOverUpstream'] for r in rs])) for f,rs in groups.items()]
rounds = []
for rnd in sorted({r['round'] for r in raw['rows']}):
    ratios = []
    for row in eligible:
        xs = {r['role']:r['elapsedMs'] for r in raw['rows'] if r['round']==rnd and r['name']==row['name']}
        ratios.append(xs['candidate']/xs['baseline'])
    rounds.append(dict(round=rnd, candidateOverBaseline=gm(ratios)))
old, new = read(parent), read(a.emission)
assert old['complete'] and new['complete']
sizes = []
for c in cases:
    pair = [next(x for x in r['cases'] if x['name']==c['name']) for r in [old,new]]
    assert all(x['source']==c['source'] and x['verified'] for x in pair)
    sizes.append(dict(name=c['name'], parentBytes=pair[0]['qbe']['bytes'], candidateBytes=pair[1]['qbe']['bytes'], byteIdentical=pair[0]['qbe']['sha256']==pair[1]['qbe']['sha256']))
result = dict(complete=True, inputs=[pin(__file__),pin(a.summary),pin(screen['file']),pin(manifest),pin(parent),pin(a.emission)],
              equalPoint=screen, families=family_rows,
              equalFrozenFamily=dict(candidateOverBaseline=gm([x['candidateOverBaseline'] for x in family_rows]),
                                     candidateOverUpstream=gm([x['candidateOverUpstream'] for x in family_rows])),
              roundRatios=rounds, sizes=sizes,
              summedMedianBatchMs={role:sum(x['mediansMs'][role] for x in eligible) for role in ['baseline','candidate','upstream']},
              totalQbeBytes={role:sum(x[role+'Bytes'] for x in sizes) for role in ['parent','candidate']},
              scope='Original45,44 timed points. Family labels are exactly the frozen manifest. Round spread is descriptive over three observations, not a confidence interval or a sampling model for all Bend programs. Generated SSA text size is not native runtime memory.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['equalFrozenFamily','roundRatios','totalQbeBytes']},indent=2))
