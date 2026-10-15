#!/usr/bin/env python3
"""Offline correction: strict source-level name predicates, not target timings."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('manifest',type=Path);p.add_argument('generated_js',type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
def pin(path):
 b=path.read_bytes();return dict(file=str(path.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads(a.manifest.read_text());js=a.generated_js.read_text()
assert 'const _x_0 = ($p88_string_eq$(_h_0, _k_0));\n    const _x_1 = ($nb_contains$(_t_0, _k_0));' in js
assert 'const _x_0 = ($nb_contains$(_roots_0, _h_0));\n    const _x_1 = ($nb_reaches$(_t_0, _roots_0));' in js
rows=[]
for product,diagnostic in zip(m['expected'],m['diagnostics']):
 f=product['fields'];roots=list(f[8]);segments=[dict(name=x['fields'][0],refs=x['fields'][5],fork=x['fields'][8]['tag']=='True') for x in f[9]]
 total=0;candidate_queries=0;passes=0
 for _ in range(diagnostic['fuel']):
  before=len(roots);passes+=1
  for x in segments:
   candidate_queries+=1+len(x['refs'])
   if not x['fork']:
    total+=(1+len(x['refs']))*len(roots)
    if x['name'] not in roots and any(n in roots for n in x['refs']):roots.insert(0,x['name'])
  if len(roots)==before:break
 assert roots==f[2]
 rows.append(dict(label=f[1],oldPythonShortCircuitCount=diagnostic['legacyNameComparisons'],strictSourceNameComparisons=total,strictSourcePasses=passes,strictCandidateMembershipQueries=candidate_queries,strictFlagNameComparisons=sum(not x['fork'] for x in segments)*len(roots)))
report=dict(kind='phase90-fork-demand-diagnostic-correction',complete=True,targetExecuted=False,correctnessProductsUnchanged=True,inputs=[pin(a.manifest),pin(a.generated_js),pin(Path(__file__))],reason='Upstream generated JS evaluates both Bool.and/or arguments. Frozen legacyNameComparisons numbers model Python short-circuit demand; do not treat them as Bend counts. Complete ordered output products were separately proved by four guarded executions.',limitations='These are strict source-level predicate counts, not measured target counters or timings; downstream compiler optimizations may alter actual execution.',rows=rows)
with a.out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(rows[-4:]))
