"""Authenticate new policy replay products, build once per identity, bind old evaluator."""
import argparse,hashlib,importlib.util,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('frozen_measure',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
pin,verify=old.pin,old.verify
p=argparse.ArgumentParser();p.add_argument('--replays',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase115');out.mkdir()
m=old.read(HERE/'manifest02.json');frozen=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';fm=old.read(frozen);checked=old.read(verify(m['apiReport']));assert checked['checked'] and checked['complete'] and checked['api']==m['api']
builder=ROOT/'selfhost/tools/performance/phase111/build.py'
base_inputs=[pin(__file__),pin(HERE/'manifest02.json'),pin(builder),pin(ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py'),pin(ROOT/'experiments/phase115/P115-002-policy-quality-and-cost.md'),m['api'],m['apiReport'],m['referenceApi'],m['runtime'],m['parent']]
for r in base_inputs:verify(r)
report=dict(complete=False,inputs=base_inputs,jobs=[],bindings=[],adapterScope='New checked Bend policy replay producer, with independent original final verifier and exact policy0 reference. Original build and measurement methods unchanged. No original binder success is asserted.');save=lambda:old.save(out/'report.json',report);save();start=time.monotonic()
products=[{} for _ in range(4)];inputs=[list(base_inputs) for _ in range(4)]
try:
 control=out/'route-controls.json'
 command=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(HERE/'route-controls.mjs'),str(control)]
 subprocess.run(command,cwd=ROOT,check=True,timeout=20)
 assert old.read(control)['complete']
 report['controls']=pin(control);report['inputs'] += [pin(HERE/'route-controls.mjs'),pin(control)];save()
 for case in m['cases']:
  name=case['name'];rp=a.replays/name/'report.json';r=old.read(rp)
  assert r['complete'] and r['warmupExact'] and r['name']==name
  assert len(r['rows'])==27 and all(x.get('outputExact',True) for x in r['rows'])
  assert r['products']['0']['sha256']==r['reference']['sha256']
  required=[m['api'],m['apiReport'],m['referenceApi'],m['runtime'],m['parent'],case['source'],case['expectedStdoutEvidence'],fm['base'],fm['carrier']]
  assert all(x in r['inputs'] for x in required)
  for row in r['inputs']:verify(row)
  seen={}
  for policy in range(4):
   qbe=r['products'][str(policy)];verify(qbe);sha=qbe['sha256']
   if sha not in seen:
    dest=ROOT/'selfhost/build/phase111'/('p115-'+name+'-p'+str(policy)+'-build01')
    cmd=['python3','-B',str(builder),'--source',qbe['file'],'--runtime',m['runtime']['file'],'--out',str(dest),'--seconds','20']
    t=time.monotonic()
    with (out/(name+'-'+str(policy)+'.stdout')).open('xb') as so,(out/(name+'-'+str(policy)+'.stderr')).open('xb') as se:
     child=subprocess.run(cmd,cwd=ROOT,stdout=so,stderr=se,timeout=65)
    report['jobs'].append(dict(name=name,policy=policy,seconds=time.monotonic()-t,command=cmd,status=child.returncode));save()
    assert child.returncode==0
    br=dest/'report.json';b=old.read(br);assert b['complete'] and not b['perProgramC'] and not b['cproc']
    for row in b['inputs']:verify(row)
    jobs={j['label']:j for j in b['jobs']};qc,ac,lc=[jobs[k]['command'] for k in ['qbe','assemble','link']]
    assert len(qc)==6 and qc[1:4]==['-t','amd64_sysv','-o'] and qc[-1]==qbe['file']
    assert len(ac)==4 and ac[1]=='-o' and ac[-1]==qc[4]
    assert len(lc)==8 and lc[1]=='-no-pie' and lc[2]==ac[2] and lc[3]==m['runtime']['file'] and lc[-4:-2]==['-pthread','-lm']
    assert b['binary']['file']==lc[-1]
    for key,cmd in [('qbe',qc),('assembler',ac),('linker',lc)]:assert pin(cmd[0])==fm['directToolchain'][key]
    verify(b['binary']);seen[sha]=(br,b,qbe)
   br,b,built_qbe=seen[sha]
   products[policy][name]=dict(binary=b['binary'],source=case['source'],qbe=qbe,build=pin(br),buildQbe=built_qbe,emission=pin(rp),runtime=m['runtime'],producerKind='phase115-checked-policy-replay',policy=policy,api=m['api'],sharedIdenticalBuild=qbe['file']!=built_qbe['file'])
   inputs[policy]+=[pin(rp),*r['inputs'],qbe,pin(br),*b['inputs'],b['binary']]
  print(name,'distinct builds',len(seen),flush=True)
 for policy in range(4):
  unique={x['file']:x for x in inputs[policy]}
  for row in unique.values():verify(row)
  bp=out/('policy'+str(policy)+'-binding.json')
  old.save(bp,dict(kind='phase112-matched-product-binding',complete=True,label='policy'+str(policy),manifest=pin(frozen),inputs=list(unique.values()),products=products[policy],adapter=pin(__file__),scope=report['adapterScope']))
  report['bindings'].append(pin(bp))
 report['complete']=True
finally:report['totalSeconds']=time.monotonic()-start;save()
