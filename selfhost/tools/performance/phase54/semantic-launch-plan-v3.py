#!/usr/bin/env python3
"""Materialize reviewable argv commands only; never run compiler or target processes."""
import argparse,json,hashlib
from pathlib import Path

def ident(p):
    p=Path(p).resolve(strict=True)
    return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--attempt',required=True);p.add_argument('--out-base',required=True);p.add_argument('--plan-file',type=Path,required=True);a=p.parse_args();assert not a.plan_file.exists()
    root=Path(__file__).resolve().parents[4];tools=root/'selfhost/tools/performance';out=Path(a.out_base).absolute();attempt=Path(a.attempt).absolute();node='/home/ai/.nvm/versions/node/v24.18.0/bin/node';commands=[]
    def add(name,args,guard):commands.append(dict(name=name,command=list(map(str,args)),guard=guard))
    def acq(name,catalog):add('acquire-'+name,['python3',tools/'phase52/acquire-semantics-v2.py','--role','direct','--selection',attempt,'--catalog',tools/catalog,'--out',out/(name+'-acquisition')],'internal sole ExecutionGuard')
    def bounded(name,script,args,seconds=60):add(name,['python3',tools/'phase32/bounded-run.py','--seconds',seconds,'--rss-mib',2048,'--available-mib',4096,out/(name+'-supervisor'),'--','taskset','-c',3,node,'--max-old-space-size=1024','--stack-size=4096',tools/script,*args],'outer bounded supervisor only')
    acq('composition','phase53/semantic-composition-catalog-v8.json');bounded('composition-controls','phase53/semantic-composition-v3.mjs',[out/'composition-acquisition/manifest.json',root/'selfhost/build/phase53/semantic-composition-reference-rebind01.json',out/'composition-controls'])
    acq('overapplication','phase53/semantic-overapplication-catalog-v1.json');bounded('overapplication-controls','phase53/semantic-overapplication-v1.mjs',[out/'overapplication-acquisition/manifest.json',root/'selfhost/build/phase53/semantic-overapplication-upstream01/manifest.json',out/'overapplication-controls'])
    acq('source','phase52/semantic-catalog-v8.json')
    join=['python3',tools/'phase52/semantic-full-join-v4.py','--direct',out/'source-acquisition/manifest.json','--catalog',tools/'phase52/semantic-catalog-v8.json']
    for name in ['semantic-upstream04','semantic-f32-upstream01','semantic-successor-upstream02','semantic-native-upstream01']:join.extend(['--typescript',root/'selfhost/build/phase52'/name/'manifest.json'])
    for flag,name in [('reference-controls','semantic-reference-controls03'),('successor-reference-controls','semantic-successor-reference-controls01'),('native-reference-controls','semantic-native-reference-controls01')]:join.extend(['--'+flag,root/'selfhost/build/phase52'/name/'report.json'])
    join.extend(['--out',out/'source-join.json']);add('source-role-join',join,'data only')
    bounded('source-controls','phase53/semantic-source-v1.mjs',[out/'source-join.json',out/'source-controls'],110)
    acq('numeric','phase53/semantic-numeric-catalog-v3.json');bounded('numeric-controls','phase53/semantic-runtime-v2.mjs',[out/'source-join.json',out/'numeric-acquisition/manifest.json',root/'selfhost/build/phase53/semantic-numeric-reference-rebind01.json',out/'numeric-controls'])
    for name,prior in [('source','semantic-ordered02-acquisition01'),('numeric','semantic-numeric-ordered02'),('composition','semantic-composition-ordered02'),('overapplication','semantic-overapplication-ordered02')]:add('exact-bytes-'+name,['python3',tools/'phase54/semantic-byte-compare-v2.py','--format','semantic','--baseline',root/'selfhost/build/phase53'/prior/'manifest.json','--candidate',out/(name+'-acquisition')/'manifest.json','--out',out/(name+'-byte-comparison.json')],'data only')
    add('direct-census',['python3',tools/'phase54/semantic-census-v1.py',attempt,out/'direct-census'],'internal sole ExecutionGuard')
    add('maintained-legacy',['python3',tools/'phase47/qualify.py',attempt,out/'maintained-legacy'],'internal sole ExecutionGuard')
    add('production-js45-acquisition',['python3',tools/'phase53/acquire.py','--attempt',attempt,'--set','full','--role','candidate','--backend','direct','--cpu',3,'--heap-mib',1024,'--rss-mib',2048,'--available-mib',4096,'--out',out/'production-js45','--node',node],'internal sole ExecutionGuard')
    add('production-js45-exact-bytes',['python3',tools/'phase54/semantic-byte-compare-v2.py','--format','production','--baseline',tools/'phase53/bundles/current/manifest.json','--candidate',out/'production-js45/manifest.json','--out',out/'production-js45-byte-comparison.json'],'data only')
    bounded('native-representatives','phase54/semantic-native-v1.mjs',[attempt,out/'native-representatives'],240)
    config=dict(kind='phase54-semantic-launch-plan',executed=False,attempt=str(attempt),outBase=str(out),cwd=str(root),producer=ident(__file__),parentProducer=ident(tools/'phase54/semantic-launch-plan-v2.py'),policy=ident(tools/'phase54/semantic-plan-v2.json'),commands=commands,scope='Reviewable argv only. Root explicitly grants target slot and runs serially; stop on failure. Byte equality does not replace independent semantics. No historical files or outputs edited.')
    if (attempt/'attempt.json').exists():config['attemptIdentity']=ident(attempt/'attempt.json')
    a.plan_file.parent.mkdir(parents=True,exist_ok=True)
    with a.plan_file.open('x')as f:f.write(json.dumps(config,indent=2)+'\n')
    print(json.dumps(dict(executed=False,commands=len(commands),plan=ident(a.plan_file))))
if __name__=='__main__':main()
