#!/usr/bin/env python3
"""Exact-source disposable wrapper: count actual binding predicate decisions."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
parent=ROOT/'selfhost/build/phase84/screen05/plan.json'
plan=json.loads(parent.read_text());old=plan['roles']['candidate']
out=ROOT/'selfhost/build/phase84/refusal-counts01';out.mkdir(exist_ok=False)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
project=out/'project'
for directory in ['src','tools']:shutil.copytree(Path(old['project'])/directory,project/directory)
text=Path(old['api']['file']).read_text();token='function $nf_binding_self_call$('
assert text.count(token)==1
text=text.replace(token,'function $p84_original_binding$(')
text+='''
let p84active=false,p84counts={};
globalThis.__p76Start=()=>{p84active=true;p84counts={calls:0,hits:0,byOwner:{},byTag:{}}};
globalThis.__p76Results=()=>{p84active=false;return {scope:'Instrumented predicate decisions only; no clean timing claim.',...p84counts}};
function $nf_binding_self_call$(...args){
 const result=run_loop($p84_original_binding$(...args));
 if(p84active){
  const target=args[2],tag=args[1].tag;const key=target.owner??target.$;
  p84counts.calls++;if(result)p84counts.hits++;
  const row=p84counts.byOwner[key]??={calls:0,hits:0};row.calls++;if(result)row.hits++;
  const kind=p84counts.byTag[tag]??={calls:0,hits:0};kind.calls++;if(result)kind.hits++;
 }
 return result;
}
'''
api=out/'diagnostic.mjs';api.write_text(text)
plan['roles']={'candidate':{**old,'api':pin(api),'project':str(project),'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'preparation':str(out/'runs/prepare-candidate/report.json')}}
plan['jobs']=[dict(name='prepare-candidate',role='candidate',action='prepare',profile=False)]+[dict(name='clean-counts-'+case,role='candidate',case=case,action='request',profile=False,diagnostic=True) for case in plan['cases']]
plan['inputs'] += [pin(parent),pin(__file__),pin(api)]+[pin(p) for p in project.rglob('*') if p.is_file()]
plan['scope']='Phase84 actual binding-refusal predicate counters from disposable B1 derivative. Complete C must match frozen oracle; all timings instrumented.'
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
(out/'derivation.json').write_text(json.dumps(dict(original=old['api'],derived=pin(api),method=pin(__file__),change='Rename exact single B1 function declaration and wrap return via existing run_loop; preserve boolean result. Record actual owner/tag decisions.'),indent=2)+'\n')
print(out/'plan.json')
