"""Pin the measured experimental candidate without promoting any installed selection."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=(ROOT/p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads((ROOT/p).read_text())
def verified(p):
 r=read(p);assert r['complete'],p;return r
out=ROOT/'implementation/phase123';out.mkdir(exist_ok=True)
assert not (out/'candidate.json').exists() and not (out/'results.json').exists()
source='selfhost/build/phase123/scaled-source04/manifest.json';api='selfhost/build/phase111/p123-scaled-api04/report.json';emission='selfhost/build/phase118/p123-broad-emit04/report.json';broad='selfhost/build/phase123/broad-analysis05.json';fast='selfhost/build/phase123/fast-analysis04.json';cost='selfhost/build/phase118/p123-final-cost04/report.json';ordinary='selfhost/build/phase118/p123-final-controls-run04/report.json'
s=verified(source);a=verified(api);e=verified(emission);b=verified(broad);f=verified(fast);c=verified(cost);o=verified(ordinary)
assert a['checked'] and e['source']==s['source'] and e['api']==a['api']
for item in [s['source'],a['api'],e['runtime']]:assert pin(item['file'])==item
bridge=[]
for x in verified('selfhost/build/phase118/p123-scaled-emit04/report.json')['cases']:
 y=next(y for y in e['cases'] if y['name']==x['name']);assert x['source']==y['source'] and x['qbe']['sha256']==y['qbe']['sha256'];bridge.append(dict(name=x['name'],sha256=x['qbe']['sha256'],bytes=x['qbe']['bytes']))
controls=['selfhost/build/phase123/final-predicate-controls04/report.json','selfhost/build/phase123/address-controls04/report.json',ordinary]
for p in controls:verified(p)
selection=dict(complete=True,experimental=True,installed=False,nativeQualified=False,source=s['source'],api=a['api'],runtime=e['runtime'],sourceManifest=pin(source),checkedApi=pin(api),emission=pin(emission),controls=[pin(p) for p in controls],timing=pin(broad),longTiming=pin('selfhost/build/phase123/ablation04/report.json'),compilerCost=pin(cost),machine=pin('selfhost/build/phase123/scaled-machine04/report.json'),recipe=pin('selfhost/tools/performance/phase123/candidate-recipe.json'),machineBuild=dict(method=pin('selfhost/tools/performance/phase123/build-aligned.py'),assemblerOption='-mbranches-within-32B-boundaries',scope='Measured amd64 SysV experimental policy; installed selection unchanged.'),scope='Checked-hosted candidate on experimental Phase121 source04 and unchanged Phase118 runtime. Original45 outputs/runtime and finite controls. No native image acquisition, N1/N2 measurement or installed promotion.')
result=dict(complete=True,inputs=[pin(__file__),*[pin(p) for p in [source,api,emission,broad,fast,cost,ordinary]]],broad=b,focused=f,compilerCost={k:c[k] for k in ['summaries','geometricCandidateOverParent','geometricAdmittedCandidateOverParent','seconds']},positiveLogDeficit=verified('selfhost/build/phase123/deficit05.json'),ordinaryControls=pin(ordinary),unalignedBroad=verified('selfhost/build/phase123/broad-analysis04.json'),alignmentDiagnostic=pin('selfhost/build/phase123/alignment-screen04/report.json'),longListRegression=pin('selfhost/build/phase123/list-long04/report.json'),exactFastBroadBridge=bridge,compilerSource=dict(parentLines=s['parentLines'],candidateLines=s['physicalLines'],addedLines=s['physicalLines']-s['parentLines'],parentBytes=s['parent']['bytes'],candidateBytes=s['source']['bytes']),scope=selection['scope'])
for name,data in [('candidate.json',selection),('results.json',result)]:(out/name).write_text(json.dumps(data,indent=2)+'\n')
print(json.dumps(dict(complete=True,source=result['compilerSource'],runtime=b['equalPoint']['candidateOverUpstream'],cost=c['geometricCandidateOverParent'])))
