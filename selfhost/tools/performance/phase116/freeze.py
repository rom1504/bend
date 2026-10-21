from pathlib import Path
import hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[4];OUT=ROOT/'selfhost/build/phase116/manifest01.json'
def read(p):return json.loads((ROOT/p).read_text())
def pin(p):
 p=(ROOT/p).resolve();return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(x):
 y=pin(x['file']);assert all(y[k]==x[k] for k in ['bytes','sha256']),x['file'];return y
m=read('selfhost/tools/performance/phase112/benchmark45/manifest01.json');q=read('selfhost/build/phase114/final45-audit01-binding.json');c=read('selfhost/build/phase99/phase102-runtime-products04/report.json');f=read('selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json')
names=['variation-local-fold-128-0','tree-bitonic','coverage-list-pipeline-128','lexer','variation-ray-active-256-2240','scalar-region-8192','coverage-map-churn-128','editdist'];cases=[]
for n in names:
 a=next(x for x in m['cases'] if x['name']==n);b=next(x for x in c['cases'] if x['id']==n);d=q['products'][n]
 assert a['source']==d['source'] and a['source']['sha256']==b['source']['sha256'] and b['passed']
 cases.append(dict(name=n,source=verify(a['source']),expected=a['expectedStdout'],args=a['runtimeArgs'],counts=f['cases'][n],products=dict(upstream_c=verify(a['upstream']['binary']),selfhost_c=verify(b['products']['own']['binary']),qbe=verify(d['binary'])),generated=dict(upstream_c=verify(a['upstream']['generatedC']),selfhost_c=verify(b['products']['own']['c']),qbe=verify(d['qbe'])),lineage=dict(qbe=d,c=b['products']['own'])))
inputs=[pin(x) for x in ['selfhost/tools/performance/phase112/benchmark45/manifest01.json','selfhost/build/phase114/final45-audit01-binding.json','selfhost/build/phase99/phase102-runtime-products04/report.json','selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json','selfhost/tools/typed-driver.mjs','selfhost/dist/typed-api.mjs','selfhost/dist/base.bend','selfhost/.bootstrap/upstream-phase66/bend2/base.bend','selfhost/.bootstrap/upstream-phase66/bend2/bend.ts','selfhost/.bootstrap/upstream-phase66/bend2/comp.ts','selfhost/build/phase108/profiler01/sampler.so','selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py']]
assert pin('selfhost/dist/base.bend')['sha256']==pin('selfhost/.bootstrap/upstream-phase66/bend2/base.bend')['sha256']
assert not OUT.exists();OUT.write_text(json.dumps(dict(complete=True,head='e096a46',cases=cases,inputs=inputs,node=pin(shutil.which('node')),bun=pin('selfhost/.bootstrap/bun-1.4.3/bun'),scope='Same source and oracle; QBE114, selfhost C102 and JS installed producer histories differ.'),indent=2)+'\n');print(len(cases),'cases frozen')
