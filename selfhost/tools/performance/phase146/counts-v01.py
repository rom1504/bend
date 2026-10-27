#!/usr/bin/env python3
"""Prepare reversible six-entry probes, or run their guarded diagnostic workload."""
import argparse, importlib.util, json, re, sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
RUNNER = ROOT/'selfhost/tools/performance/phase145/execution/run-v01.py'
HOST = RUNNER.with_name('hosted-v01.mjs')
spec = importlib.util.spec_from_file_location('p145run', RUNNER)
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)
N = R.N
NAMES = ['p112s_verify','p111_verify_program','p113e_originals','ns_ctor_index','p113e_functions','p113e_function']
def write(path, value): path.write_text(json.dumps(value,indent=2)+'\n')
def prepare(a):
    out = a.out.resolve(); N.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase146'),'Fresh Phase146 directory')
    selection_path = ROOT/'implementation/phase144/final04/candidate.json'
    selection = json.loads(selection_path.read_text())
    old_plan_path = ROOT/'selfhost/build/phase145/execution-plan01/plan.json'
    old = json.loads(old_plan_path.read_text()); N.require(old['complete'],'Frozen fixture plan incomplete')
    inputs = [N.pin(__file__),N.pin(RUNNER),N.pin(N.__file__),N.pin(HOST),N.pin(selection_path),N.pin(old_plan_path)]
    roles = []; derivatives = []
    for role, receipt in [('parent',Path(selection['checkedApi']['file'])),('candidate',a.candidate_api.resolve())]:
        report = json.loads(receipt.read_text()); N.require(report['complete'] and report['checked'],'Checked API required')
        sources = [x for x in report['inputs'] if x['file'].endswith('/compiler.bend')]
        N.require(len(sources)==1,'Unique checked compiler source required')
        if role=='parent': N.require(report['api']==selection['api'] and sources[0]==selection['source'],'Selected parent identity changed')
        original = N.verify(report['api']).read_text(); modified = original; patches = []
        for name in NAMES:
            matches = list(re.finditer(r'^function \$'+re.escape(name)+r'\$\([^\n]*\) \{',modified,re.M))
            N.require(len(matches)==1,'Unique generated function required: '+name)
            patch = '\n  /*p146*/globalThis.__p145hit('+json.dumps(name)+',undefined);/*p146end*/'
            m = matches[0]; modified = modified[:m.end()]+patch+modified[m.end():]; patches.append(patch)
        inverse = modified
        for patch in patches:
            N.require(inverse.count(patch)==1,'Unique reversible insertion'); inverse = inverse.replace(patch,'')
        N.require(inverse==original,'Counter derivative must reverse exactly')
        inputs += [N.pin(receipt),report['api'],*report['inputs']]
        roles.append(dict(role=role,checkedApi=N.pin(receipt),compilerSource=sources[0],api=report['api']))
        derivatives.append(modified)
    cases = old['cases']; inputs += [old['bun'],old['base'],old['carrier']]
    for case in cases: inputs += [case['source'],case['expectedQbe']]
    for pin in inputs: N.verify(pin)
    out.mkdir(parents=True)
    for role, text in zip(roles,derivatives):
        p = out/(role['role']+'-diagnostic.mjs'); p.write_text(text); role['diagnosticApi']=N.pin(p)
    plan = dict(kind='phase146-six-entry-observer-plan',complete=True,targetsRun=False,inputs=inputs,roles=roles,cases=cases,
        bun=old['bun'],base=old['base'],carrier=old['carrier'],stamp=old['stamp'],hooks=NAMES,reversalExact=True,
        scope='Hosted diagnostic counts only; each role bound to its actual checked source/API. No native role or native timing claim. Entry counts exclude optimized tail iterations; complete QBE must equal frozen final04 ordinary output.')
    write(out/'plan.json',plan); print(out/'plan.json')
def run(a):
    out=a.out.resolve(); N.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase146'),'Fresh Phase146 output')
    plan=json.loads(a.plan.read_text()); N.require(plan['complete'] and plan['kind']=='phase146-six-entry-observer-plan','Wrong plan')
    inputs=[N.pin(a.plan),*plan['inputs'],*[r['diagnosticApi'] for r in plan['roles']]]
    N.require(N.pin(__file__) in inputs and N.pin(HOST) in inputs and N.pin(RUNNER) in inputs,'Frozen methods required')
    for pin in inputs: N.verify(pin)
    out.mkdir(parents=True); result=dict(kind='phase146-six-entry-observation',complete=False,inputs=inputs,rows=[],scope=plan['scope'])
    try:
        for case in plan['cases']:
            for role in plan['roles']:
                work=out/(case['name']+'-'+role['role']); work.mkdir(); product=work/'program.ssa'
                config=dict(api=role['diagnosticApi'],source=case['source'],base=plan['base'],carrier=plan['carrier'],stamp=plan['stamp'],output=str(product),observation=str(work/'observation.json'),instrumented=True)
                write(work/'input.json',config)
                process=R.child([plan['bun']['file'],str(HOST),str(work/'input.json')],work,60)
                N.require(process['stdout']['bytes']==0,'Unexpected observer stdout')
                obs=json.loads((work/'observation.json').read_text()); N.require(obs['complete'],'Observer incomplete')
                N.require(N.same_bytes(product,Path(case['expectedQbe']['file'])),'Complete ordinary QBE differs')
                counts={name:obs['counters'].get('backend',{}).get(name,{}).get('entry',0) for name in NAMES}
                result['rows'].append(dict(case=case['name'],role=role,config=N.pin(work/'input.json'),process=process,observation=N.pin(work/'observation.json'),product=N.pin(product),expectedQbe=case['expectedQbe'],byteExact=True,backendEntries=counts))
                write(out/'report.json',result)
        for pin in inputs: N.verify(pin)
        result['complete']=True
    except BaseException as error: result['error']=repr(error)
    finally: write(out/'report.json',result)
    print(json.dumps(dict(complete=result['complete'],rows=len(result['rows']),error=result.get('error'))))
    return 0 if result['complete'] else 1
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--candidate-api',type=Path); ap.add_argument('--plan',type=Path); ap.add_argument('--out',type=Path,required=True); a=ap.parse_args()
    N.require(bool(a.plan)!=bool(a.candidate_api),'Choose metadata preparation (--candidate-api) or guarded execution (--plan)')
    return run(a) if a.plan else prepare(a)
if __name__=='__main__': sys.exit(main())
