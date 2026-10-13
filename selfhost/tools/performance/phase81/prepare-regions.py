#!/usr/bin/env python3
"""Observation-only B2 derivative: time coarse internal boundaries, never cache."""
import hashlib,json,re,shutil
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend');HERE=Path(__file__).resolve().parent
OUT=ROOT/'selfhost/build/phase81/regions01'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
parent=ROOT/'selfhost/build/phase81/survey01/plan.json';plan=json.loads(parent.read_text());old=plan['roles']['b2']
OUT.mkdir(exist_ok=False);source=Path(old['project']);project=OUT/'project';project.mkdir()
shutil.copytree(source/'tools',project/'tools');shutil.copytree(source/'src',project/'src')
api=OUT/'diagnostic.mjs';text=Path(old['api']['file']).read_text()
names=['ns_checked_runtime','nc_compile_error','ns_definitions','nr_unshared','ns_prepare','nf_plan','nc_compile_defs','nc_finish','ne_program','ne_template_scan','nh_macros','no_route','nq_signatures','nc_ctor_prepare','nc_constructors','norm_max_book','book_final_fast','index_build','f_context_definition','jl_checked_error']
tail=['let p81active=false; const p81stack=[]; let p81stats={}; globalThis.__p76Start=()=>{p81stats={};p81active=true;}; globalThis.__p76Results=()=>{p81active=false;return {scope:"Diagnostic derivative; nested clocks overlap; no memoization or semantic substitution",regions:p81stats};};']
for name in names:
 fn='$jd$'+name.replace('_','_95_'); original='$p81_original$'+name
 text,n=re.subn(r'function '+re.escape(fn)+r'\(',lambda _: 'function '+original+'(',text);assert n==1,(name,n)
 tail.append('function '+fn+'(...args){if(!p81active)return '+original+'(...args);const f={start:performance.now(),child:0};p81stack.push(f);try{return '+original+'(...args);}finally{const t=performance.now()-f.start;p81stack.pop();if(p81stack.length)p81stack.at(-1).child+=t;const row=p81stats['+json.dumps(name)+']??={calls:0,inclusiveMs:0,exclusiveMs:0};row.calls++;row.inclusiveMs+=t;row.exclusiveMs+=t-f.child;}}')
api.write_text(text+'\n'+'\n'.join(tail)+'\n')
plan['roles']={'b2':{**old,'project':str(project),'api':pin(api),'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'preparation':str(OUT/'runs/prepare-b2/report.json')}}
plan['jobs']=[dict(name='prepare-b2',role='b2',action='prepare',profile=False)]+[dict(name='clean-region-'+c,role='b2',case=c,action='request',profile=False) for c in plan['cases']]
plan['inputs'] += [pin(parent),pin(__file__),pin(api)]+[pin(p) for p in project.rglob('*') if p.is_file()]
plan['scope']='Phase81 observation-only derivative of genuine Phase78 B2; original algorithms retained. Coarse nested boundaries; do not treat diagnostic clocks as clean gain estimates.'
(OUT/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
(OUT/'derivation.json').write_text(json.dumps(dict(original=old['api'],derived=pin(api),method=pin(__file__),functions=names),indent=2)+'\n')
print(OUT/'plan.json')
