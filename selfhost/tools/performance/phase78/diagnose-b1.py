#!/usr/bin/env python3
"""Observational coarse B1 cost decomposition; never a clean speed claim."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('parent',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
out=a.out.resolve();out.mkdir();plan=json.loads(a.parent.read_text());r=plan['roles']['b1'];api=Path(r['api']['file']);assert pin(api)==r['api'];source=api.read_text()
names={'ka_def':1,'nf_candidate':1,'nq_candidate_mode':1,'nd_compile_entry':2,'no_route_one':1,'nr_prepare':-1,'nr_compile':-1,'nf_plan':-1,'ns_prepare':-1,'ne_program':-1,'nh_macros':-1,'nc_compile_error':-1,'jl_checked_error':-1,'nr_unshared':-1}
wrappers=[]
for name,at in names.items():
 target='$'+name+'$';old='function '+target+'(';assert source.count(old)==1,name
 original='$p78original_'+name;source=source.replace(old,'function '+original+'(',1)
 wrappers.append('function '+target+'(...a){return $p78call('+json.dumps(name)+','+str(at)+','+original+',a);}')
source+='''
const $p78={active:false,rows:{},stack:[]};
function $p78call(name,at,fn,args){
 if(!$p78.active)return fn(...args);
 const arg=at<0?'':args[at],label=typeof arg==='string'?arg:arg?.name;
 const key=name+(at<0?'':':'+label),row=$p78.rows[key]??={calls:0,inclusiveMs:0,exclusiveMs:0};row.calls++;
 const f={start:performance.now(),children:0};$p78.stack.push(f);
 try{return run_loop(fn(...args));}finally{const dt=performance.now()-f.start;$p78.stack.pop();if($p78.stack.length)$p78.stack.at(-1).children+=dt;row.inclusiveMs+=dt;row.exclusiveMs+=dt-f.children;}
}
globalThis.__p76Start=()=>{$p78.active=true;};
globalThis.__p76Results=()=>{$p78.active=false;return $p78.rows;};
'''+ '\n'.join(wrappers)+'\n'
image=out/'diagnostic.mjs';image.write_text(source)
project=out/'project';shutil.copytree(r['project'],project,ignore=shutil.ignore_patterns('build'))
r.update(project=str(project),api=pin(image),driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str(out/'runs/prepare-b1/report.json'))
plan['inputs'] += [pin(a.parent),pin(__file__),pin(image),*[pin(f) for f in project.rglob('*') if f.is_file()]]
plan['jobs']=[dict(name='prepare-b1',role='b1',action='prepare',profile=False)]+[dict(name='profile-'+c+'-b1',role='b1',action='request',case=c,profile=True) for c in plan['cases']]
plan['diagnostic']={'scope':'Coarse named wrappers drain original B1 trampolines for attribution. Exact C is required; these are not clean timings. Recursive inclusive clocks overlap.','functions':names}
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
