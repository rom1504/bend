#!/usr/bin/env python3
"""Root-run saved pair-state discriminator, preserving every stage and receipt."""
import argparse,hashlib,json,shutil,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
PROGRAMS=ROOT/'selfhost/tools/performance/programs'
sys.path.insert(0,str(PROGRAMS))
from support import ExecutionGuard,identity,save
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('baseline',type=Path)
p.add_argument('typescript',type=Path)
p.add_argument('out',type=Path)
p.add_argument('--actual',type=Path)
p.add_argument('--node',required=True)
p.add_argument('--cpu',type=int,default=3)
p.add_argument('--budget',type=int,choices=[20,60,300],default=60)
a=p.parse_args()
begin=time.monotonic();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
tools=Path(__file__).resolve().parent
inputs=[identity(x)for x in [__file__,tools/'derive.mjs',tools/'oracle.mjs',a.baseline,a.typescript,a.node]]
if a.actual:inputs.append(identity(a.actual))
for file in [Path(__file__),tools/'derive.mjs',tools/'oracle.mjs']:shutil.copyfile(file,out/('consumed-'+file.name))
report=dict(kind='phase43-pairs-discriminator',complete=False,passed=False,inputs=inputs,stages=[],scope='saved-JS controlled pair-state allocation screen; not compiler qualification')
save(out/'controller.json',report)
try:
    # Static derivation and bounded semantic oracle precede any timing worker.
    # Release the lock before maintained compare.py acquires its own guard.
    with ExecutionGuard(1536,2048)as guard:
        for name,command in [
            ('derive',[a.node,'--max-old-space-size=1024',str(tools/'derive.mjs'),str(a.baseline.resolve()),str(out/'derived')]),
            ('oracle',[a.node,'--stack-size=4096','--max-old-space-size=1024',str(tools/'oracle.mjs'),str(out/'derived')])]:
            result=guard.run(command,out/name,begin+min(a.budget,30))
            report['stages'].append(dict(name=name,command=command,process=result));save(out/'controller.json',report)
            assert result['complete'],name+' failed'
    d=json.loads((out/'derived/derive.json').read_text());oracle=json.loads((out/'derived/oracle.json').read_text())
    assert oracle['passed'] and d['kind']=='phase43-products-saved-js' and d['parentChecked'] and not d['checked']
    variants={r['variant']:r for r in d['variants']}
    for r in variants.values():assert hashlib.sha256(Path(r['path']).read_bytes()).hexdigest()==r['sha256']
    cases=[]
    for name,args,expected in [('coverage-bst-32',[32,0],1802825775),('coverage-bst-64',[64,17],861157620)]:
        modules={name:variants[name]['path']for name in ['direct','pairs','products']}
        if a.actual:modules['actual']=str(a.actual.resolve())
        modules['typescript']=str(a.typescript.resolve())
        cases.append(dict(id=name,point=dict(exportName='bench',args=args,expected=expected),modules=modules))
    config=dict(cases=cases,inputs=[str(out/'derived/derive.json'),str(out/'derived/oracle.json')])
    save(out/'compare.json',config)
    report['compareCommand']=[sys.executable,str(ROOT/'selfhost/tools/performance/phase35/compare.py'),str(out/'compare.json'),str(out/'screen'),'--node',a.node,'--cpu',str(a.cpu),'--budget',str(a.budget)]
    save(out/'controller.json',report)
    import subprocess
    with(out/'compare.stdout.log').open('w')as stdout,(out/'compare.stderr.log').open('w')as stderr:
        child=subprocess.run(report['compareCommand'],cwd=ROOT,stdout=stdout,stderr=stderr)
    assert child.returncode==0,'compare failed'
    screen=json.loads((out/'screen/report.json').read_text());assert screen['complete']and screen['passed']
    report.update(complete=True,passed=True,screen=str(out/'screen/report.json'))
    for x in inputs:assert identity(x['path'])==x,'input changed'
except Exception as error:report['error']=repr(error)
finally:
    report['wallSeconds']=time.monotonic()-begin;save(out/'controller.json',report)
    print(json.dumps(report))
if not report['passed']:sys.exit(1)
