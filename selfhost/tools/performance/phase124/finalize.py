"""Authenticate final evidence and pin an experimental source, never an installed compiler."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=(ROOT/p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads((ROOT/p).read_text())
def complete(p):
 r=read(p);assert r['complete'],p;return r
out=ROOT/'implementation/phase124';out.mkdir(exist_ok=True)
assert not (out/'candidate.json').exists() and not (out/'results.json').exists()
paths=dict(source='selfhost/build/phase124/ready-source02/manifest.json',api='selfhost/build/phase111/p124-ready-api02/report.json',
 emission='selfhost/build/phase118/p124-broad-emit02/report.json',broad='selfhost/build/phase124/broad-analysis02.json',
 deficit='selfhost/build/phase124/deficit02.json',fast='selfhost/build/phase124/fast-summary01.json',
 frame='selfhost/build/phase124/frame-summary03.json',cost='selfhost/build/phase118/p124-ready-cost02/report.json',
 controls='selfhost/build/phase118/p124-final-controls-run02/report.json',finite='selfhost/build/phase124/finite01/report.json')
r={k:complete(v) for k,v in paths.items()};s,a,e=r['source'],r['api'],r['emission']
assert a['checked'] and e['source']==s['source'] and e['api']==a['api']
for item in [s['source'],a['api'],e['runtime']]:assert pin(item['file'])==item
fast=complete('selfhost/build/phase124/ready-fast-prefix01/report.json');bridge=[]
for x in fast['cases']:
 y=next(y for y in e['cases'] if y['name']==x['name']);assert x['source']==y['source'] and x['qbe']['sha256']==y['qbe']['sha256']
 bridge.append(dict(name=x['name'],sha256=x['qbe']['sha256'],bytes=x['qbe']['bytes']))
for row in r['cost']['summaries']:
 y=next(y for y in e['cases'] if y['name']==row['name']);assert y['qbe']['sha256']==row['candidate']['output']['sha256']
ordinary=complete('selfhost/build/phase118/p124-final-controls-emit02/report.json')
old=complete('selfhost/build/phase118/p124-ready-controls-emit01/report.json')
assert ordinary['source']==s['source'] and ordinary['api']==a['api']
for x in old['cases']:
 y=next(y for y in ordinary['cases'] if y['name']==x['name']);assert x['source']==y['source'] and x['qbe']['sha256']==y['qbe']['sha256']
selection=dict(complete=True,experimental=True,installed=False,nativeQualified=False,source=s['source'],api=a['api'],runtime=e['runtime'],
 sourceManifest=pin(paths['source']),checkedApi=pin(paths['api']),emission=pin(paths['emission']),
 controls=[pin(paths['controls']),pin(paths['finite'])],timing=pin(paths['broad']),compilerCost=pin(paths['cost']),
 recipe=pin('selfhost/tools/performance/phase124/candidate-recipe.json'),
 machineBuild=dict(method=pin('selfhost/tools/performance/phase123/build-aligned.py'),assemblerOption='-mbranches-within-32B-boundaries'),
 scope='Checked-hosted ready-resume source02 over Phase123. Original45 outputs/runtime, ordinary retained-alias/depth controls and finite predicates. Frame ablation excluded. Runtime unchanged. No native image/N1/N2 qualification or installed promotion.')
result=dict(complete=True,inputs=[pin(__file__),*[pin(v) for v in paths.values()]],broad=r['broad'],positiveLogDeficit=r['deficit'],
 focused=r['fast'],excludedFrameAblation=r['frame'],compilerCost={k:r['cost'][k] for k in ['summaries','geometricCandidateOverParent','geometricAdmittedCandidateOverParent','seconds']},
 exactFastFinalBridge=bridge,exactOrdinaryFinalBridge=True,source=dict(parentLines=s['parentLines'],candidateLines=s['physicalLines'],addedLines=s['physicalLines']-s['parentLines'],parentBytes=s['parent']['bytes'],candidateBytes=s['source']['bytes']),scope=selection['scope'])
for name,data in [('candidate.json',selection),('results.json',result)]:(out/name).write_text(json.dumps(data,indent=2)+'\n')
print(json.dumps(dict(complete=True,source=result['source'],runtime=r['broad']['equalPoint']['candidateOverUpstream'],cost=r['cost']['geometricCandidateOverParent'])))
