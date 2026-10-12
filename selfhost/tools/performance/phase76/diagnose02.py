#!/usr/bin/env python3
"""Freeze an observational B2 diagnostic with per-definition native timings."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend')
OUT=ROOT/'selfhost/build/phase76/diagnostic02'
OUT.mkdir()
parent=ROOT/'selfhost/build/phase75/compiler14-compilation/plan.json'
plan=json.loads(parent.read_text());role=plan['roles']['b2']
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
api=Path(role['api']['file']);assert pin(api)==role['api']
source=api.read_text()
names={'nd_compile_entry':2,'nf_candidate':1,'nq_candidate_mode':1,'no_route_one':1,
       'nr_compile':None,'ns_prepare':None,'nf_plan':None,'ne_program':None,
       'nh_macros':None,'nc_uses':None,'nq_uses':None,'nq_min_uses':None}
wrappers=[]
for name,at in names.items():
 target='$jd$'+name.replace('_','_95_');old='function '+target+'('
 assert source.count(old)==1,(name,source.count(old))
 orig='$p76original_'+name;source=source.replace(old,'function '+orig+'(',1)
 wrappers.append('function '+target+'(...a){return $p76call('+json.dumps(name)+','+str(at if at is not None else -1)+','+orig+',a);}')
source+='''
const $p76={active:false,rows:{},stack:[]};
function $p76call(name,at,fn,args){
 if(!$p76.active)return fn(...args);
 if(name==='nd_compile_entry'&&args[2]==='Nat.read.trim')$p76.rows.trimBody=args[1];
 const key=name+(at<0?'':':'+args[at]);
 const r=$p76.rows[key]??={calls:0,inclusiveMs:0,exclusiveMs:0};r.calls++;
 const f={start:performance.now(),children:0};$p76.stack.push(f);
 try{return fn(...args);}finally{const dt=performance.now()-f.start;$p76.stack.pop();
  if($p76.stack.length)$p76.stack.at(-1).children+=dt;
  r.inclusiveMs+=dt;r.exclusiveMs+=dt-f.children;}
}
globalThis.__p76Start=()=>{$p76.active=true;};
globalThis.__p76Results=()=>{$p76.active=false;return $p76.rows;};
'''+ '\n'.join(wrappers)+'\n'
image=OUT/'diagnostic.mjs';image.write_text(source)
project=OUT/'project';shutil.copytree(role['project'],project,ignore=shutil.ignore_patterns('build'))
role.update(project=str(project),api=pin(image),driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str(OUT/'runs/prepare-b2/report.json'))
plan['inputs'] += [pin(parent),pin(__file__),pin(image),*[pin(p) for p in project.rglob('*') if p.is_file()]]
plan['inputs'] += [pin(ROOT/'selfhost/tools/performance/phase76/compilation'/n) for n in ['worker.mjs','run.py']]
plan['jobs']=[dict(name='prepare-b2',role='b2',action='prepare',profile=False)]+[dict(name='clean-'+case+'-b2',role='b2',action='request',case=case,profile=False) for case in ['numeric']]
plan['diagnostic']={'parent':pin(parent),'rules':names,'scope':'Observational wrappers only. Complete C must equal Phase75. Instrumented times are diagnostic, not clean speed measurements.'}
(OUT/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
print(OUT/'plan.json')
