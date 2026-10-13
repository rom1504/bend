#!/usr/bin/env python3
"""Observe exact-argument reuse; never replace an analysis result or claim clean speed."""
import argparse,hashlib,json,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('parent',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
out=a.out.resolve();out.mkdir();plan=json.loads(a.parent.read_text());r=plan['roles']['baseline'];api=Path(r['api']['file']);assert pin(api)==r['api'];source=api.read_text()
names=['nc_uses','nc_occurs','nq_uses','nd_arity','nc_compact_definition','wnf','nc_refs','nc_erase','subst']
wrappers=[]
for name in names:
 target='$'+name+'$';old='function '+target+'(';assert source.count(old)==1,name
 original='$p80original_'+name;source=source.replace(old,'function '+original+'(',1)
 wrappers.append('function '+target+'(...a){return $p80call('+json.dumps(name)+','+original+',a);}')
source+='''
const $p80={active:false,rows:{},seen:{},ids:new WeakMap(),next:0,stack:[]};
function $p80key(x){if(x!==null&&(typeof x==='object'||typeof x==='function')){let i=$p80.ids.get(x);if(i===undefined){i=++$p80.next;$p80.ids.set(x,i);}return 'o'+i;}return typeof x+':'+String(x);}
function $p80call(name,fn,args){
 if(!$p80.active)return fn(...args);
 const key=args.map($p80key).join('|'),seen=$p80.seen[name]??=new Set(),repeat=seen.has(key);seen.add(key);
 const row=$p80.rows[name]??={calls:0,unique:0,repeated:0,inclusiveMs:0,exclusiveMs:0,repeatedInclusiveMs:0,repeatedExclusiveMs:0};row.calls++;row[repeat?'repeated':'unique']++;
 const f={start:performance.now(),children:0};$p80.stack.push(f);
 try{return run_loop(fn(...args));}finally{const dt=performance.now()-f.start;$p80.stack.pop();if($p80.stack.length)$p80.stack.at(-1).children+=dt;row.inclusiveMs+=dt;row.exclusiveMs+=dt-f.children;if(repeat){row.repeatedInclusiveMs+=dt;row.repeatedExclusiveMs+=dt-f.children;}}
}
globalThis.__p76Start=()=>{$p80.active=true;};
globalThis.__p76Results=()=>{$p80.active=false;return $p80.rows;};
'''+ '\n'.join(wrappers)+'\n'
image=out/'diagnostic.mjs';image.write_text(source)
project=out/'project';shutil.copytree(r['project'],project,ignore=shutil.ignore_patterns('build'))
r.update(project=str(project),api=pin(image),driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str(out/'runs/prepare-baseline/report.json'))
plan['inputs'] += [pin(a.parent),pin(__file__),pin(image),*[pin(f) for f in project.rglob('*') if f.is_file()]]
plan['jobs']=[dict(name='prepare-baseline',role='baseline',action='prepare',profile=False),dict(name='clean-counts-numeric-baseline',role='baseline',action='request',case='numeric',profile=False)]
plan['diagnostic']={'scope':'Observational wrappers drain original B1 trampolines, counting all exact arguments (including book identity). Original results always computed. Timings overlap and are heavily instrumented; not a clean speed or memoization benefit claim.','functions':names}
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
