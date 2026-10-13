#!/usr/bin/env python3
"""Observation-only derivative: measure planning and discarded worker products."""
import hashlib
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT/'selfhost/build/phase83/regions01'
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


parent = ROOT/'selfhost/build/phase83/survey01/plan.json'
plan = json.loads(parent.read_text())
old = plan['roles']['b2']
OUT.mkdir(exist_ok=False)
project = OUT/'project'
for directory in ['src', 'tools']:
    shutil.copytree(Path(old['project'])/directory, project/directory)
text = Path(old['api']['file']).read_text()
names = ['nf_plan', 'nq_signatures', 'nf_candidates', 'nf_candidate',
    'nq_candidates_mode', 'nq_candidate_mode', 'nf_admit', 'nf_retry',
    'ns_definitions', 'nr_unshared', 'ns_prepare', 'no_route',
    'nc_compile_defs', 'nc_finish', 'norm_max_book', 'book_final_fast',
    'driver_report_data', 'f_context_definition']
tail = [r'''
let p83active=false, p83stats={}, p83workers=[], p83plans=[];const p83stack=[];
globalThis.__p76Start=()=>{p83active=true;p83stats={};p83workers=[];p83plans=[];};
globalThis.__p76Results=()=>{p83active=false;return {scope:"Observation-only B2 derivative. Nested inclusive clocks overlap. Wrapper calls do not count internal SCC/tail-loop iterations. Worker bytes are JS UTF-16 code units, not allocation totals.",regions:p83stats,workers:p83workers,plans:p83plans};};
function p83list(xs){const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}if(xs.$!=='Nil')throw Error('Bad diagnostic list');return out;}
function p83observe(name,result,ms){
 if(name==='nf_candidate'||name==='nq_candidate_mode')p83workers.push({route:name,name:result.name,error:result.code.error,bodyUnits:result.code.body.length,segments:p83list(result.code.segments).length,ms});
 if(name==='nf_plan'){const ready=p83list(result.ready);p83plans.push({ready,workers:p83list(result.workers).map(w=>({name:w.name,accepted:ready.includes(w.name),error:w.code.error,bodyUnits:w.code.body.length,segments:p83list(w.code.segments).length}))});}
}
''']
for name in names:
    function = '$jd$'+name.replace('_', '_95_')
    original = '$p83_original$'+name
    text, count = re.subn(r'function '+re.escape(function)+r'\(', lambda _: 'function '+original+'(', text)
    assert count == 1, (name, count)
    tail.append('function '+function+'(...args){if(!p83active)return '+original+'(...args);const f={start:performance.now(),child:0};p83stack.push(f);let result;try{result='+original+'(...args);return result;}finally{const t=performance.now()-f.start;p83stack.pop();if(p83stack.length)p83stack.at(-1).child+=t;const row=p83stats['+json.dumps(name)+']??={calls:0,inclusiveMs:0,exclusiveMs:0};row.calls++;row.inclusiveMs+=t;row.exclusiveMs+=t-f.child;if(result)p83observe('+json.dumps(name)+',result,t);}}')
api = OUT/'diagnostic.mjs'
api.write_text(text+'\n'+'\n'.join(tail)+'\n')
plan['roles'] = {'b2': {**old, 'api': pin(api), 'project': str(project),
    'driver': pin(project/'tools/typed-driver.mjs'), 'runtime': pin(project/'src/runtime.mjs'),
    'preparation': str(OUT/'runs/prepare-b2/report.json')}}
plan['jobs'] = [dict(name='prepare-b2', role='b2', action='prepare', profile=False)]
for case in ['numeric', 'map', 'small', 'functions65']:
    plan['jobs'].append(dict(name='clean-region-'+case, role='b2', case=case,
        action='request', profile=False, diagnostic=True))
plan['inputs'] += [pin(parent), pin(__file__), pin(api)]+[pin(p) for p in project.rglob('*') if p.is_file()]
plan['scope'] = 'Phase83 observation-only B2 planning derivative; exact original C required. Internal clocks and product sizes, not clean speed measurements.'
(OUT/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
(OUT/'derivation.json').write_text(json.dumps(dict(original=old['api'], derived=pin(api), method=pin(__file__), functions=names), indent=2)+'\n')
print(OUT/'plan.json')
