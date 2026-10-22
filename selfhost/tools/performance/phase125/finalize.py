"""Bind final experimental evidence; never change an installed selection."""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
    p=(ROOT/p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads((ROOT/p).read_text())
def complete(p):
    r=read(p);assert r['complete'],p;return r
p=argparse.ArgumentParser();p.add_argument('--native-qualified',action='store_true');a=p.parse_args()
out=ROOT/'implementation/phase125';assert not (out/'candidate.json').exists()
paths=dict(source='selfhost/build/phase125/verified-source06/manifest.json',api='selfhost/build/phase111/p125-verified06-api/report.json',
 runtime='selfhost/build/phase125/runtime-verified01/report.json',emission='selfhost/build/phase125/broad-emission06.json',
 broad='selfhost/build/phase125/broad-analysis06.json',deficit='selfhost/build/phase125/deficit06.json',
 cost='selfhost/build/phase118/p125-final-cost06/report.json',controls='selfhost/build/phase118/p125-final-controls-run06/report.json',
 finiteAppend='selfhost/build/phase125/final-append-finite06/report.json',finiteIdentity='selfhost/build/phase125/final-identity-finite06/report.json',
 finiteVerified='selfhost/build/phase125/verified-finite06/report.json',transfer='selfhost/build/phase125/final-transfer-screen06/report.json',
 ablation='selfhost/build/phase125/ablation06b/report.json')
r={k:complete(v) for k,v in paths.items()};s,api,e=r['source'],r['api'],r['emission']
assert api['checked'] and e['source']==s['source'] and e['api']==api['api'] and e['runtime']==r['runtime']['object']
for x in [s['source'],api['api'],e['runtime']]:assert pin(x['file'])==x
assert len(e['cases'])==45 and all(x['verified'] for x in e['cases'])
for x in r['cost']['summaries']:
    expected=next(y['qbe'] for y in e['cases'] if y['name']==x['name'])
    assert x['candidate']['output']['sha256']==expected['sha256']
native=None
if a.native_qualified:
    plan='selfhost/build/phase125/native06-plan.json';jobs='selfhost/build/phase113/p125-native06-qualification/report.json'
    comparison='selfhost/build/phase125/p125-native06-qbe-comparison.json'
    j=complete(jobs);c=complete(comparison);assert len(j['jobs'])==8 and all(x['status']==0 for x in j['jobs']) and c['byteExact']
    native=dict(plan=pin(plan),jobs=pin(jobs),comparison=pin(comparison),n1=c['n1'],n2=c['n2'],qbe=c['hostedQbe'],
                scope='Hosted→N1→N2; exact raw QBE reproduction, focused19 on N1/N2 and original45 correctness on N2. No N2→N3 or installed promotion.')
selection=dict(complete=True,experimental=True,installed=False,nativeQualified=bool(native),source=s['source'],api=api['api'],runtime=e['runtime'],
 sourceManifest=pin(paths['source']),checkedApi=pin(paths['api']),runtimeReport=pin(paths['runtime']),emission=pin(paths['emission']),
 controls=[pin(paths[k]) for k in ['controls','finiteAppend','finiteIdentity','finiteVerified']],timing=pin(paths['broad']),compilerCost=pin(paths['cost']),
 nativeCheckpoint=native,machineBuild=dict(method=pin('selfhost/tools/performance/phase123/build-aligned.py'),assemblerOption='-mbranches-within-32B-boundaries'),
 scope='Checked Bend source06: typed owned-prefix append, primitive identities, verified sized runtime ABI. Original45 runtime and separate independent transfer. Runtime additions preserve Phase118 prefix. Installed selections unchanged.')
results=dict(complete=True,inputs=[pin(__file__),*[pin(v) for v in paths.values()]],broad=r['broad'],positiveLogDeficit=r['deficit'],
 compilerCost={k:r['cost'][k] for k in ['summaries','geometricCandidateOverParent','geometricAdmittedCandidateOverParent','seconds']},
 transfer=r['transfer'],matchedAblation=r['ablation'],nativeCheckpoint=native,
 source=dict(parentLines=s['parentLines'],candidateLines=s['physicalLines'],addedLines=s['physicalLines']-s['parentLines'],parentBytes=s['parent']['bytes'],candidateBytes=s['source']['bytes']),
 scope=selection['scope'])
for name,data in [('candidate.json',selection),('results.json',results)]:
    with (out/name).open('x') as f:json.dump(data,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,nativeQualified=bool(native),source=results['source'],runtime=r['broad']['equalPoint']['candidateOverUpstream'],cost=r['cost']['geometricCandidateOverParent'])))
