"""Freeze one authenticated checked-API emission and matched product study."""
import argparse,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser();p.add_argument('--api',type=Path,required=True);p.add_argument('--transfer',type=Path);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert not a.out.exists();a.out.mkdir(parents=True)
method=ROOT/'selfhost/tests/phase195/prepared-emission/prepare.py';sp=importlib.util.spec_from_file_location('prepared',method);m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m)
baseline=m.authority(ROOT/'selfhost/build/phase199/baseline-api01/report.json');candidate=m.authority(a.api)
assert baseline['preparationIdentity']==candidate['preparationIdentity'] and baseline['bindingIdentity']==candidate['bindingIdentity']
np=ROOT/'selfhost/build/phase198/progress-native45-02/programs.manifest.json';cp=ROOT/'selfhost/build/phase195/references01/manifest.json'
native=m.read(np);crefs=m.read(cp);n={x['id']:x for x in native['cases']};c={x['id']:x for x in crefs['cases']}
ids=['local-fold','variation-local-fold-128-0','variation-local-fold-8192-123','editdist','mandelbrot']
rows=[];cases=[]
for name in ids:
 x=n[name];assert x['source']==c[name]['source'] and x['expectedFile']==c[name]['expectedFile']
 active='local-fold' in name
 cases.append(dict(id=name,partition='development' if active else 'unchanged-control',source=x['source'],expectedFile=x['expectedFile']))
 rows.append(dict(id=name,active=active,source=x['source'],point=x['point'],baselineObject=x['products']['candidate']['generatedSource'],baselineBinary=x['products']['candidate']['artifact'],c=c[name]['products']['c'],extra=[[0,0],[1,4294967295],[129,17]] if active else []))
if a.transfer:
 tr=m.read(a.transfer);assert tr['complete'] and set(tr['products'])=={'native','c'}
 oracles=m.read(m.verify(tr['oracles']))['transfer'];first=oracles[0];expected=a.out/'packet-window.expected';expected.write_text(first['output'])
 name='packet-window';cases.append(dict(id=name,partition='independently-authored-transfer',source=tr['source'],expectedFile=m.pin(expected)))
 rows.append(dict(id=name,active=True,source=tr['source'],point=dict(runtimeArgs=first['inputs'],expectedStdout=first['output'],repetitions=1,warmups=4,ratioEligible=True),baselineObject=tr['products']['native']['object'],baselineBinary=tr['products']['native']['binary'],c=dict(artifact=tr['products']['c']['binary'],runtimeArgumentConvention='bend-rts-v1'),transferOracles=oracles,extra=[]))
assets=ROOT/'selfhost/build/phase194/assets.json';av=m.read(assets);runtime=av['assets']['qbe-runtime'];live=m.read(ROOT/'research/phase198/runtime-broad/portfolio-pins.json')['live']
fixture=a.out/'cases.json';fixture.write_text(json.dumps(dict(cases=cases),indent=2)+'\n')
inputs=[m.pin(__file__),m.pin(method),m.pin(method.with_name('driver.mjs')),m.pin(np),m.pin(cp),m.pin(assets),runtime,live,m.pin(fixture),*baseline['inputs'],*candidate['inputs'],*[r[k] for r in cases for k in ['source','expectedFile']]]
if a.transfer:inputs += [m.pin(a.transfer),tr['oracles']]
unique={r['file']:r for r in inputs}
for r in unique.values():m.verify(r)
emit=dict(kind='phase195-shared-preparation-plan',version=1,complete=True,targetsRun=False,producer=baseline,roles=[dict(name='scan',**candidate)],cases=cases,catalog=m.pin(fixture),partition=m.pin(fixture),runtime=runtime,assets=m.pin(assets),compareOrdinary=False,inputs=list(unique.values()),scope='Explicit5native45 points plus optional independently-authored transfer. No all45 coverage claim; checked Bend owns lowering/emission.')
(a.out/'emission.json').write_text(json.dumps(emit,indent=2)+'\n')
config=dict(complete=True,targetsRun=False,cases=rows,inputs=list(unique.values()),candidateApi=m.pin(a.api),baselineSource=m.pin(ROOT/'selfhost/build/phase198/progress-portfolio01/compiler.bend'),nativeManifest=m.pin(np),cManifest=m.pin(cp),assets=m.pin(assets),runtimes=dict(original=runtime,live=live),helperReceipt=m.pin(ROOT/'selfhost/build/phase198/p199-scan-runtime01/report.json'),delegateSource=m.pin(Path(__file__).with_name('delegate.c')),roles=['c','stored','baseline','delegate','simd'],layouts=['program-helper-runtime','program-runtime-helper'],primaryRuntime='live',rounds=5,targetMs=160,minimumMs=100,scope='Same-runtime matched baseline/candidate links and same-candidate-object scalar delegate. Live two-layout primary, original-runtime fold3 cross-check. Reuses qualified Phase198 program objects; no source patches to emitted machines.')
(a.out/'study.json').write_text(json.dumps(config,indent=2)+'\n');print(a.out)
