"""Link checked objects under explicit runtime/helper arms and validate outputs."""
import argparse,hashlib,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import execute,bench
sp=importlib.util.spec_from_file_location('layouts',ROOT/'research/phase198/qualification/compare-source-products.py');L=importlib.util.module_from_spec(sp);sp.loader.exec_module(L)
p=argparse.ArgumentParser();p.add_argument('--study',type=Path,required=True);p.add_argument('--emission',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert os.sched_getaffinity(0)=={3};a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
inputs={}
def verify(p):
 q=pin(p['file']);assert q['bytes']==p['bytes'] and q['sha256']==p['sha256'],p['file'];inputs[q['file']]=q;return q['file']
s=read(a.study);e=read(a.emission);assert s['complete'] and e['complete'] and not e.get('error') and not e.get('changedInputs')
verify(pin(a.study));verify(pin(a.emission));verify(pin(__file__))
for v in s['inputs']+e['inputs']:verify(v)
helper=read(verify(s['helperReceipt']));assert helper['complete'];simd=verify(helper['helperObject'])
assets=read(verify(s['assets']));cc=verify(assets['assets']['linker']);delegate=verify(s['delegateSource'])
r=dict(complete=False,method=pin(__file__),study=pin(a.study),emission=pin(a.emission),commands=[],cases={},oracles={},inputs=[])
def save():r['inputs']=list(inputs.values());(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,limit=15):
 c=subprocess.run(list(map(str,cmd)),capture_output=True,timeout=limit);i=len(r['commands']);o=a.out/(str(i)+'.stdout');er=a.out/(str(i)+'.stderr');o.write_bytes(c.stdout);er.write_bytes(c.stderr);r['commands'].append(dict(argv=list(map(str,cmd)),exit=c.returncode,stdout=pin(o),stderr=pin(er)));save();assert c.returncode==0,(cmd,c.stderr[-3000:]);return c
start=time.monotonic()
try:
 scalar=a.out/'delegate.o';run([cc,'-std=c11','-O3','-msse2','-mno-avx','-c',delegate,'-o',scalar]);r['delegateObject']=pin(scalar)
 objdump=verify(assets['assets']['objdump']) if 'objdump' in assets['assets'] else '/usr/bin/objdump'
 verify(pin(objdump));d=run([objdump,'-dr',scalar]);assert b'%xmm' not in d.stdout and b'%ymm' not in d.stdout,'Delegate unexpectedly vectorized'
 emitted={x['id']:x for x in e['rows']};assert set(emitted)=={x['id'] for x in s['cases']}
 for case in s['cases']:
  name=case['id'];row=emitted[name];assert row['complete'] and row['verified'] and row['source']==case['source']
  obj=verify(row['product']);base=verify(case['baselineObject']);verify(case['source']);verify(case['baselineBinary']);cexe=verify(case['c']['artifact']);conv=case['c']['runtimeArgumentConvention']
  unchanged=pin(obj)['sha256']==case['baselineObject']['sha256'] and pin(obj)['bytes']==case['baselineObject']['bytes']
  assert unchanged != case['active'],name+' unexpected activation/refusal'
  dis=run([objdump,'-dr',obj]);calls=dis.stdout.count(b'p199_rt_u32_scan4');assert bool(calls)==case['active'],name+' helper reference mismatch'
  points=[dict(args=case['point']['runtimeArgs'],expected=case['point']['expectedStdout'],reps=1)]
  if 'transferOracles' in case:points=[dict(args=x['inputs'],expected=x['output'],reps=int(i<2)) for i,x in enumerate(case['transferOracles'])]
  else:
   for args in case['extra']:
    obs,want=execute(cexe,args,0,0,None,conv);points.append(dict(args=args,expected=want,reps=0,cObservation=obs))
  for point in points:
   point['cObservation']=execute(cexe,point['args'],point['reps'],0,point['expected'],conv)[0]
  r['oracles'][name]=points
  r['cases'][name]=dict(source=case['source'],point=case['point'],candidateObject=row['product'],baselineObject=case['baselineObject'],objectUnchanged=unchanged,helperReferences=calls,arms={})
  for arm,runtime in s['runtimes'].items():
   rt=verify(runtime)
   for layout in s['layouts']:
    directory=a.out/name/arm/layout;directory.mkdir(parents=True)
    products={'c':case['c']}
    for role,program,extra in [('stored',base,None),('baseline',base,simd),('delegate',obj,str(scalar)),('simd',obj,simd)]:
     exe=directory/role;objects=[program]+(([extra,rt] if layout=='program-helper-runtime' else [rt,extra]) if extra else [rt])
     run([cc,'-no-pie',*objects,'-pthread','-lm','-o',exe]);products[role]=dict(artifact=pin(exe),runtimeArgumentConvention='bend-rts-v1')
    if unchanged:assert L.loaded_layout(products['baseline']['artifact']['file'])==L.loaded_layout(products['simd']['artifact']['file']),name+' unchanged loaded image differs'
    checks=[]
    for role,product in products.items():
     for point in points:
      observation=execute(product['artifact']['file'],point['args'],point['reps'],0,point['expected'],product['runtimeArgumentConvention'])[0]
      checks.append(dict(role=role,args=point['args'],expected=point['expected'],observation=observation))
    r['cases'][name]['arms'][arm+'/'+layout]=dict(runtime=runtime,products=products,checks=checks)
  save()
 for v in inputs.values():assert pin(v['file'])==v
 r.update(complete=True,seconds=time.monotonic()-start);save()
except BaseException as error:r.update(error=repr(error),seconds=time.monotonic()-start);save();raise
