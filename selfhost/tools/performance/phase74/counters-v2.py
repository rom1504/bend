#!/usr/bin/env python3
"""Derive an unshipped entry-counter image and an independent cache project."""
import argparse, hashlib, json, re, shutil
from pathlib import Path

p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
a.out=a.out.resolve();a.out.mkdir(exist_ok=False)
plan=json.loads(a.plan.read_text());role=plan['roles']['b2'];parent=Path(role['api']['file'])
source=parent.read_text();assert hashlib.sha256(parent.read_bytes()).hexdigest()==role['api']['sha256']
names=['nc_compile_def','nf_candidate','nc_compact_definition','nc_definition','nc_erase',
       'nc_live_names','nc_uses','nq_uses','ns_prepare','nd_compile_entry',
       'nc_finish','nf_finish_ready','no_route','ne_program']
prefix=r'''
// P74 diagnostic only: counts object identities, never caches compiler results.
const $p74 = {active:false, rows:{}, stack:[], notes:[]};
let $p74ids = new WeakMap(), $p74id = 0;
function $p74key(v) {
 if(v!==null && (typeof v==='object'||typeof v==='function')) {
  if(!$p74ids.has(v))$p74ids.set(v,++$p74id);return '@'+$p74ids.get(v);
 }
 return typeof v+':'+String(v);
}
function $p74list(v) {
 const out=[];while(v?.$==='Con'){out.push(v.head);v=v.t??v.tail??v.rest;
  if(out.length>1000000)throw Error('diagnostic list guard');}return out;
}
function $p74segments(v) {return $p74list(v).map(s=>({name:s.name,
 bytes:(s.body??'').length, refs:$p74list(s.refs)}));}
function $p74call(name,fn,args) {
 if(!$p74.active)return fn(...args);
 const row=$p74.rows[name]??= {calls:0,keys:new Set(),names:{},inclusiveMs:0,exclusiveMs:0};
 row.calls++;row.keys.add(args.map($p74key).join('|'));
 if(name==='nc_compile_def'||name==='nf_candidate')row.names[args[1]]=(row.names[args[1]]??0)+1;
 if(name==='nc_finish')$p74.notes.push({stage:name,segments:$p74segments(args[3].segments)});
 if(name==='nf_finish_ready')$p74.notes.push({stage:name,
  workers:$p74list(args[7]).map(w=>({name:w.name,error:w.code?.error,bytes:w.code?.body?.length})),
  ready:$p74list(args[8])});
 if(name==='ne_program')$p74.notes.push({stage:name,segments:$p74segments(args[1].segments),
  declarationsBytes:args[1].declarations.length});
 const f={start:performance.now(),children:0};$p74.stack.push(f);
 try {const result=fn(...args);
  if(name==='no_route')$p74.notes.push({stage:name,workers:$p74list(result.workers).map(w=>w.name),ready:$p74list(result.ready)});
  return result;
 } finally {const ms=performance.now()-f.start;$p74.stack.pop();
  if($p74.stack.length)$p74.stack.at(-1).children+=ms;
  row.inclusiveMs+=ms;row.exclusiveMs+=ms-f.children;}
}
globalThis.__p74Start=()=>{$p74.active=true;};
globalThis.__p74Results=()=>{ $p74.active=false;return {
 rows:Object.fromEntries(Object.entries($p74.rows).map(([k,v])=>[k,{...v,keys:undefined,distinctArgumentTuples:v.keys.size}])),
 notes:$p74.notes,scope:'Entry calls only; compiler tail loops and SCC internal dispatch do not re-enter wrappers. Times include instrumentation overhead; never speedup evidence.'};};
'''
wrappers=[]
for name in names:
    target='$jd$'+name.replace('_','_95_');old='function '+target+'('
    assert source.count(old)==1,(name,source.count(old))
    original='$p74original_'+name
    source=source.replace(old,'function '+original+'(',1)
    wrappers.append('function '+target+'(...args){return $p74call('+json.dumps(name)+','+original+',args);}')
image=a.out/'counter-api.mjs';image.write_text(source+prefix+'\n'+'\n'.join(wrappers)+'\n')
def pin(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
project=a.out/'project';shutil.copytree(role['project'],project,ignore=shutil.ignore_patterns('build'))
role['project']=str(project);role['api']=pin(image)
role['driver']=pin(project/'tools/typed-driver.mjs');role['runtime']=pin(project/'src/runtime.mjs')
role['preparation']=str(a.out/'runs/prepare-b2/report.json')
plan['inputs'] += [pin(image),pin(__file__),*[pin(f) for f in project.rglob('*') if f.is_file()]]
plan['diagnostic']={'parentPlan':pin(a.plan),'parentApi':pin(parent),'names':names,
 'rule':'Exact declaration renames plus counter wrappers; no memoization or result changes. Independent prepared Base.'}
plan['jobs']=[dict(name='prepare-b2',role='b2',action='prepare',profile=False)]
(a.out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
print(json.dumps(dict(plan=pin(a.out/'plan.json'),api=pin(image))))
