"""Reuse authenticated shared-emission transport with an explicit new source universe."""
from pathlib import Path
import importlib.util,json,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
method=ROOT/'selfhost/tests/phase195/prepared-emission/prepare.py'
spec=importlib.util.spec_from_file_location('transport',method);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
producer=m.authority(ROOT/'selfhost/build/phase197/combined-api02/report.json')
roles=[]
for name,job in [('baseline','numeric-api03'),('orbit','numeric-api05')]:
 a=m.authority(ROOT/'selfhost/build/phase198'/job/'report.json');assert a['preparationIdentity']==producer['preparationIdentity'] and a['bindingIdentity']==producer['bindingIdentity'];roles.append(dict(name=name,**a))
frozen=json.loads((HERE/'frozen.json').read_text())
cases=[dict(id=c['id'],partition='new-source-heldout',source=m.pin(HERE/c['source']),expectedFile=m.pin(HERE/c['expectedFile'])) for c in frozen['cases']]
assets=m.pin(ROOT/'selfhost/build/phase194/assets.json');runtime=m.read(assets['file'])['assets']['qbe-runtime']
inputs=[m.pin(Path(__file__)),m.pin(method),m.pin(method.with_name('driver.mjs')),m.pin(HERE/'frozen.json'),m.pin(HERE/'partition.json'),assets,runtime,*producer['inputs'],*[i for r in roles for i in r['inputs']],*[x[k] for x in cases for k in ['source','expectedFile']]]
unique={x['file']:x for x in inputs}
for x in unique.values():m.verify(x)
r=dict(kind='phase195-shared-preparation-plan',version=1,complete=True,targetsRun=False,producer=producer,roles=roles,cases=cases,catalog=m.pin(HERE/'frozen.json'),partition=m.pin(HERE/'partition.json'),runtime=runtime,assets=assets,compareOrdinary=False,inputs=list(unique.values()),scope='Explicit independently authored source-heldout universe. No native45 membership claim. Existing checked transport only; all source/checking/emission decisions remain in authenticated Bend APIs.')
out=ROOT/'selfhost/build/phase198/numeric-heldout-plan01.json';assert not out.exists();out.write_text(json.dumps(r,indent=2)+'\n');print(m.pin(out))
