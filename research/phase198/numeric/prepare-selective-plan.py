"""Mixed fixed catalog/source-heldout inputs, existing authenticated transport."""
from pathlib import Path
import importlib.util,json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
method=ROOT/'selfhost/tests/phase195/prepared-emission/prepare.py';spec=importlib.util.spec_from_file_location('transport',method);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
producer=m.authority(ROOT/'selfhost/build/phase197/combined-api02/report.json');role=m.authority(ROOT/'selfhost/build/phase198/numeric-api06/report.json');assert role['preparationIdentity']==producer['preparationIdentity'] and role['bindingIdentity']==producer['bindingIdentity']
old=m.read(ROOT/'selfhost/build/phase198/numeric-emission-plan02.json');new=m.read(ROOT/'selfhost/build/phase198/numeric-heldout-plan01.json');cases=[*old['cases'],*new['cases']]
partition=HERE/'selective-partition.json';partition.write_text(json.dumps({'development':[],'heldout':[x['id'] for x in cases]},indent=2)+'\n')
inputs=[m.pin(Path(__file__)),m.pin(method),m.pin(method.with_name('driver.mjs')),m.pin(partition),old['assets'],old['runtime'],*producer['inputs'],*role['inputs'],*[x[k] for x in cases for k in ['source','expectedFile']]]
unique={x['file']:x for x in inputs}
for x in unique.values():m.verify(x)
r=dict(kind='phase195-shared-preparation-plan',version=1,complete=True,targetsRun=False,producer=producer,roles=[dict(name='selective',**role)],cases=cases,catalog=m.pin(HERE/'selective-frozen.json'),partition=m.pin(partition),runtime=old['runtime'],assets=old['assets'],compareOrdinary=False,inputs=list(unique.values()),scope='Four explicit cases, two ordinary catalog and two newly authored source controls; no broad-universe membership inference. All compiler decisions use independently checked APIs.')
out=ROOT/'selfhost/build/phase198/numeric-selective-plan01.json';assert not out.exists();out.write_text(json.dumps(r,indent=2)+'\n');print(m.pin(out))
