#!/usr/bin/env python3
"""Stage exact prepared04 B1 with private public-API boundary tracing only."""
import argparse
import hashlib
import json
import shutil
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6];RAW=ROOT/'selfhost/build/phase66'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists();inputs={}
def pin(value):
    item=value if isinstance(value,dict) else None;file=Path(item['file'] if item else value).resolve(strict=True)
    row=dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:assert row['sha256']==item['sha256'],file
    inputs[str(file)]=row;return row
prep_file=RAW/'b1-04-full-latency/preparation/prepare-candidate.result.json';prep=json.loads(prep_file.read_text());pin(prep_file)
assert prep['complete'] and prep['pass'] and prep['image']['kind']=='checked'
image=prep['image'];assert pin(image['api'])['sha256']=='1ed7deccc250732402fb3aebda4c0852adacdf983a8bcfe12b12658dfda23094'
project=Path(image['driver']['file']).parent.parent;clone=out/'project';out.mkdir(parents=True)
before={str(f.relative_to(project)):pin(f) for f in project.rglob('*') if f.is_file()}
shutil.copytree(project,clone);copies=[]
for relative,row in before.items():
    after=pin(clone/relative);assert after['sha256']==row['sha256'];copies.append(dict(before=row,after=after))
driver=clone/'tools/typed-driver.mjs';old=driver.read_text()
prefix="""const observeApi=api=>Object.fromEntries(Object.entries(api).map(([name,value])=>[name,typeof value==='function'?function(...args){
  const file=process.env.BEND_PHASE66_API_TRACE,begin=performance.now();
  const emit=event=>{if(file)fs.appendFileSync(file,JSON.stringify({name,event,ms:performance.now(),durationMs:performance.now()-begin})+'\\n');};
  emit('enter');try{return value.apply(api,args);}finally{emit('exit');}
}:value]));
"""
edits=[('async function loadApiForIdentity(identity=null) {',prefix+'async function loadApiForIdentity(identity=null) {'),
       ('if(!module.G) return module.default;','if(!module.G) return observeApi(module.default);'),
       ('return createCompilerAbi({fields,ctor:module.ctor,','return observeApi(createCompilerAbi({fields,ctor:module.ctor,'),
       ('}).wrap(module.default);','}).wrap(module.default));')]
text=old
for x,y in edits:assert text.count(x)==1;text=text.replace(x,y)
driver.write_text(text);inputs.pop(str(driver));driver_pin=pin(driver)
source_report=RAW/'conformance-final04-direct-js01/bend-candidate-new-base/js/report.json';report=json.loads(source_report.read_text());pin(source_report)
cases=[]
for name in ['reg/const_shared_layout.bend','reg/show_shared_layout.bend']:
    row=next(x for x in report['results'] if x['id']==name);assert row['status']=='timeout'
    request=json.loads(Path(row['artifacts'],'request.json').read_text());pin(Path(row['artifacts'],'request.json'))
    cases.append(dict(id=name,source=pin(dict(file=request['test']['file'],sha256=request['test']['sha256'])),expected=request['test']['expected']))
attempt=json.loads(Path(image['checkedGenerator']['file']).read_text());pin(image['checkedGenerator'])
worker=pin(Path(__file__).with_name('worker.mjs'));controller=pin(Path(__file__).with_name('run.py'));pin(__file__)
manifest=dict(kind='phase66-shared-layout-diagnostic-plan',complete=True,dataOnly=True,targetExecuted=False,
    diagnosticOnly=True,productionQualified=False,producer=pin(__file__),parentPreparation=pin(prep_file),
    node=pin(attempt['node']),api=pin(clone/'dist/api.mjs'),base=pin(image['base']),runtime=pin(clone/'src/runtime.mjs'),
    driver=driver_pin,worker=worker,controller=controller,cases=cases,copies=copies,
    driverDerivation=dict(before=pin(project/'tools/typed-driver.mjs'),after=driver_pin,edits=[dict(old=x,new=y,occurrences=1) for x,y in edits]),
    inputs=list(inputs.values()),resources=dict(cpu=3,heapMiB=1024,treeRssMiB=2048,availableMiB=4096,perCaseSeconds=60,totalSeconds=180),
    command=[sys.executable,'-B',controller['file'],str(out/'manifest.json'),str(out/'results')],
    scope='Private copied already prepared cache/products and exact04 B1; ordinary owned driver path is retained. Only public API entry/exit markers plus existing trace are added. Original frozen projects and all compiler/source/API/cache bytes remain unchanged.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(dict(manifest=pin(out/'manifest.json'),command=manifest['command'])))
