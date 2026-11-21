"""Prepare authenticated actual-source ray emission; no target execution."""
import argparse,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--api',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
method=ROOT/'selfhost/tests/phase195/prepared-emission/prepare.py';sp=importlib.util.spec_from_file_location('prepared',method);m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m)
candidate=m.authority(a.api)
np=ROOT/'selfhost/build/phase198/p199-integrated-native45-01/programs.manifest.json';cp=ROOT/'selfhost/build/phase195/references01/manifest.json'
native=m.read(np);crefs=m.read(cp);n={x['id']:x for x in native['cases']};c={x['id']:x for x in crefs['cases']}
ids=['raytrace','variation-ray-active-64-2440','variation-ray-active-256-2240'];cases=[];rows=[]
for name in ids:
 x=n[name];assert x['source']==c[name]['source'] and x['expectedFile']==c[name]['expectedFile']
 cases.append(dict(id=name,partition='numeric-runtime-transfer',source=x['source'],expectedFile=x['expectedFile']))
 rows.append(dict(id=name,source=x['source'],point=x['point'],baselineObject=x['products']['candidate']['generatedSource'],baselineBinary=x['products']['candidate']['artifact'],c=c[name]['products']['c'],extra=[[16,0],[32,17]] if name=='raytrace' else [[1,0],[31,2240]]))
expected=a.out/'sqrt-hold.expected';expected.write_text('1112014848\n')
# main computes ((sqrt(9)*10)+2)+18 = 50.0f, bit pattern 0x42480000.
cases.append(dict(id='sqrt-hold',partition='independent-negative-path-control',source=m.pin(HERE/'sqrt-hold.bend'),expectedFile=m.pin(expected)))
assets=ROOT/'selfhost/build/phase194/assets.json';av=m.read(assets)
runtime=m.read(ROOT/'selfhost/build/phase199/runtime-bundle01/report.json')['variants']['live']['bundle']
helper=m.read(ROOT/'selfhost/build/phase198/p200-ray-runtime01/report.json')['helper']
fixture=a.out/'cases.json';fixture.write_text(json.dumps(dict(cases=cases),indent=2)+'\n')
inputs=[m.pin(__file__),m.pin(method),m.pin(method.with_name('driver.mjs')),m.pin(np),m.pin(cp),m.pin(assets),runtime,helper,m.pin(fixture),*candidate['inputs'],*[r[k] for r in cases for k in ['source','expectedFile']]]
unique={r['file']:r for r in inputs}
for r in unique.values():m.verify(r)
emit=dict(kind='phase195-shared-preparation-plan',version=1,complete=True,targetsRun=False,producer=candidate,roles=[dict(name='sqrt',**candidate)],cases=cases,catalog=m.pin(fixture),partition=m.pin(fixture),runtime=runtime,assets=m.pin(assets),compareOrdinary=False,inputs=list(unique.values()),scope='Three unchanged ordinary ray sources plus a typed FP liveness control. No source/assembly patch to target programs.')
(a.out/'emission.json').write_text(json.dumps(emit,indent=2)+'\n')
study=dict(complete=True,targetsRun=False,cases=rows,inputs=list(unique.values()),candidateApi=m.pin(a.api),runtime=runtime,helper=helper,assets=m.pin(assets),rounds=6,targetMs=140,minimumMs=90,scope='Same-runtime/helper matched baseline and candidate whole programs; mature C oracle and independent typed negative-sqrt dataflow control.')
(a.out/'study.json').write_text(json.dumps(study,indent=2)+'\n');print(a.out)
