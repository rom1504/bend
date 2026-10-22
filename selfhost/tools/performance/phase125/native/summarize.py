"""Summarize qualified native requests without conflating clocks or generations."""
import hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
    p=(ROOT/p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads((ROOT/p).read_text())
def done(p):
    r=read(p);assert r['complete'],p;return r
paths=dict(qualification='selfhost/build/phase113/p125-native06-qualification/report.json',
 comparison='selfhost/build/phase125/p125-native06-qbe-comparison.json',guard='selfhost/build/phase125/p125-native06-qualification-guard/process.json',
 current='selfhost/build/phase112/p125-native06-transport/report.json',prior='selfhost/build/phase112/p125-native06-transport-phase118/report.json',
 hosted='selfhost/build/phase111/p125-native06-full-emit/report.json',native='selfhost/build/phase111/p125-native06-self/report.json',
 sourceArchive='implementation/phase125/source06/manifest.json')
r={k:done(p) for k,p in paths.items()}
assert r['comparison']['byteExact'] and len(r['qualification']['jobs'])==8 and all(x['status']==0 for x in r['qualification']['jobs'])
for k in ['current','prior']:assert r[k]['passed'] and len(r[k]['rows'])==27
new,old=[r[k]['summary']['cache']['cases'] for k in ['current','prior']];assert set(new)==set(old)
metrics=['requestSeconds','readyExecutableStageSumSeconds']
ratios={role:{m:math.exp(statistics.mean(math.log(new[c]['roles'][role][m]['median']/old[c]['roles'][role][m]['median']) for c in new)) for m in metrics} for role in ['phase111','phase112','upstream']}
result=dict(complete=True,inputs=[pin(__file__),*[pin(p) for p in paths.values()]],qualified=True,
 source=read('implementation/phase125/candidate.json')['source'],n1=r['comparison']['n1'],n2=r['comparison']['n2'],qbe=r['comparison']['hostedQbe'],
 acquisition=dict(wallSeconds=r['guard']['wallSeconds'],peakTreeRssBytes=r['guard']['peakTreeRssBytes'],minimumAvailableBytes=r['guard']['minimumAvailableBytes'],jobs=r['qualification']['jobs'],hostedStages=r['hosted']['stages'],nativeStages=r['native']['jobs']),
 current=r['current']['summary']['cache'],contemporaneousPrior=r['prior']['summary']['cache'],directMedianCurrentOverPrior=ratios,
 scope='Phase125 N1/N2, original focused19 and one-shot45; exact raw QBE, no ELF/N2→N3 claim. Two sequential three-source/three-round timing blocks,54 correct observations. Request includes ordinary native source reading/checking/compilation/output/exit; ready stage sum adds QBE/as/link or C/Clang children, excludes harness/execution. Native uses prepared Base/cached runtime; upstream rebuilds runtime. Different compiler sources and block drift prevent causal generated-compiler speed or recursive-acceleration claims. Installed selections unchanged.')
out=ROOT/'implementation/phase125/native-results.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,currentRatios=result['current']['threeCaseGeometricRatios'],directMedianCurrentOverPrior=ratios),indent=2))
