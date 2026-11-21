#!/usr/bin/env python3
"""Compile both gzip images, authenticate native45 outputs, then time all roles."""
import argparse,fcntl,gzip,hashlib,json,os,subprocess,sys,time
from pathlib import Path
from types import SimpleNamespace
sys.dont_write_bytecode=True
from support import B,ROOT,HERE,P,R,S,L,NATIVE,CATALOG,checked_bytes,c_reference

def load_image(binding):
 B.verify(binding['gzip']);B.verify(binding['receipt']);B.verify(binding['source'])
 receipt=B.read(binding['receipt']['file']);assert len(receipt['runs'])==1 and receipt['runs'][0]['elfSha256']==binding['elfSha256'] and receipt['sourceSha256']==binding['source']['sha256']
 fd=os.memfd_create('phase205-compiler',os.MFD_CLOEXEC|os.MFD_ALLOW_SEALING);digest=hashlib.sha256();size=0
 try:
  with gzip.open(binding['gzip']['file'],'rb') as src,os.fdopen(os.dup(fd),'wb') as dst:
   while True:
    chunk=src.read(1024*1024)
    if not chunk:break
    size+=len(chunk);assert size<=128*1024*1024,'Compiler image exceeds bound';digest.update(chunk);dst.write(chunk)
  assert digest.hexdigest()==binding['elfSha256'] and size>64
  with open('/proc/self/fd/'+str(fd),'rb') as src:assert src.read(6)==b'\x7fELF\x02\x01'
  fcntl.fcntl(fd,fcntl.F_ADD_SEALS,fcntl.F_SEAL_WRITE|fcntl.F_SEAL_GROW|fcntl.F_SEAL_SHRINK|fcntl.F_SEAL_SEAL)
  return fd,dict(bytes=size,sha256=digest.hexdigest())
 except BaseException:os.close(fd);raise

def build(plan,binding,fd,source,folder,deadline):
 folder.mkdir(parents=True,exist_ok=False);obj=folder/'program.o';elf=folder/'program';err=folder/'compiler.stderr'
 command=[('/proc/self/fd/'+str(fd)) if x=='{image}' else source['file'] if x=='{source}' else x for x in plan['compilerCommand']]
 started=time.monotonic()
 with obj.open('xb') as stdout,err.open('xb') as stderr:
  proc=subprocess.run(command,stdout=stdout,stderr=stderr,pass_fds=(fd,),cwd=ROOT,timeout=max(.001,min(45,deadline-time.monotonic())))
 emitted=time.monotonic();assert proc.returncode==0 and err.stat().st_size==0,'Native compiler failed; see '+str(err)
 header=NATIVE.x86_object_header(obj);object_pin=B.pin(obj);assert object_pin['bytes']<=128*1024*1024
 # The linker sees the same object argument for both producers, avoiding STT_FILE path drift.
 with obj.open('rb') as stream:
  stable=fcntl.fcntl(stream.fileno(),fcntl.F_DUPFD_CLOEXEC,90);assert stable==90,'Reserved object descriptor90 unavailable'
  try:
   values={'{object}':'/proc/self/fd/90','{runtime}':plan['runtime']['file'],'{output}':str(elf)};link=[values.get(x,x) for x in plan['linkCommand']]
   with (folder/'link.stdout').open('xb') as stdout,(folder/'link.stderr').open('xb') as stderr:
    linked=subprocess.run(link,stdout=stdout,stderr=stderr,pass_fds=(stable,),cwd=ROOT,timeout=max(.001,min(20,deadline-time.monotonic())))
   assert linked.returncode==0,'Link failed; see '+str(folder/'link.stderr')
  finally:os.close(stable)
 end=time.monotonic();record=dict(complete=True,source=source,image=binding,object=object_pin,binary=B.pin(elf),runtime=plan['runtime'],compilerCommand=command,compilerExit=proc.returncode,compilerStderr=B.pin(err),objectHeader=header,linkCommand=link,linkExit=linked.returncode,emitSeconds=emitted-started,linkSeconds=end-emitted)
 B.save(folder/'build.json',record,fresh=True)
 return dict(artifact=record['binary'],generatedSource=object_pin,runtimeArgumentConvention='bend-rts-v1',inputs=[B.pin(folder/'build.json'),source,binding['gzip'],binding['receipt'],binding['source'],plan['runtime']]),record

def run(args):
 assert os.sched_getaffinity(0)=={3} and 'BENDRTS' not in os.environ
 plan=B.read(args.plan);assert plan['kind']=='phase205-frozen-dual-native-screen' and plan['rounds']==3 and plan['minimumAcceptedMs']==100
 for pin in plan['inputs']:B.verify(pin)
 assert args.out.resolve().parent==ROOT/'selfhost/build/phase205'
 out=args.out.resolve();out.mkdir(parents=True,exist_ok=False);deadline=time.monotonic()+plan['guardSeconds']-5
 _,cm,ccases=c_reference();assert B.pin(plan['cReference']['file'])==plan['cReference']
 catalog={c['id']:c for c in B.catalog(CATALOG)['cases']};assert set(plan['cases'])<=catalog.keys()
 descriptors={};records={};inputs=B.unique_inputs([B.pin(args.plan),*plan['inputs']]);report=dict(kind='phase205-dual-native-preparation',complete=False,inputs=inputs,plan=B.pin(args.plan),images={},cases={},controls={},timingPolicy='All roles, including identical objects and allocated layouts, are freshly timed.')
 B.save(out/'preparation.json',report)
 try:
  for role,binding in plan['images'].items():
   fd,identity=load_image(binding);descriptors[role]=fd;report['images'][role]=dict(binding=binding,nativeImage=identity)
  roles=dict(c=cm['roles']['c'])
  for role in ['baseline','candidate']:
   roles[role]=dict(host='native',stage='replay-image',target='x86',emit='object',preparation='cache',policy='ordinary',status='phase205-experimental-gzip-native',emitter='selfhost',compilerSource=plan['images'][role]['source'],compressedCompiler=plan['images'][role]['gzip'],nativeImage=report['images'][role]['nativeImage'],runtime=plan['runtime'],inputs=inputs)
  recipe=dict(kind='programs',cwd=str(ROOT),catalog=str(CATALOG),reference='c',roles=roles,cases=[])
  for index,name in enumerate(plan['cases']):
   case=catalog[name];folder=out/'cases'/name;folder.mkdir(parents=True);arms={'c':ccases[name]['products']['c']};builds={}
   # Alternate cold compilation order independently of later balanced timing.
   order=['baseline','candidate'] if index%2==0 else ['candidate','baseline']
   for role in order:arms[role],builds[role]=build(plan,plan['images'][role],descriptors[role],case['source'],folder/role,deadline)
   equal_object=all(arms['baseline']['generatedSource'][k]==arms['candidate']['generatedSource'][k] for k in ('bytes','sha256'))
   if name in plan['expectUnchanged']:assert equal_object,'Expected unchanged object differs: '+name
   equal_elf=all(arms['baseline']['artifact'][k]==arms['candidate']['artifact'][k] for k in ('bytes','sha256'))
   equal_layout=L.loaded_layout(arms['baseline']['artifact']['file'])==L.loaded_layout(arms['candidate']['artifact']['file'])
   if equal_object:assert equal_layout,'Identical objects with fixed runtime/link policy must preserve loaded layout'
   oracles={}
   for role in ['c','baseline','candidate']:
    product=arms[role];B.verify(product['artifact']);point=dict(case['point'],repetitions=1,warmups=0)
    command=[product['artifact']['file'],*B.native_runtime_arguments(product),'1','0',*map(str,point['runtimeArgs'])]
    child=B.child(command,folder/('oracle-'+role),min(deadline,time.monotonic()+20),str(ROOT));assert not child['timedOut']
    elapsed=B.observation(checked_bytes(child['stdout']),checked_bytes(child['stderr']),child['exitCode'],point,child['seconds']);oracles[role]=dict(process=child,elapsedMs=elapsed)
    arms[role]=dict(product,inputs=B.unique_inputs([*product['inputs'],child['stdout'],child['stderr'],B.pin(folder/('oracle-'+role)/'process.json')]))
   recipe['cases'].append(dict(id=name,products=arms));report['cases'][name]=dict(builds=builds,oracles=oracles,objectsIdentical=equal_object,elfBytesIdentical=equal_elf,loadedLayoutsIdentical=equal_layout)
   B.save(out/'preparation.json',report)
  for control in plan['controls']:
   assert '/' not in control['id'] and control['id'] not in ('.','..');folder=out/'controls'/control['id'];folder.mkdir(parents=True);rows={}
   for role in ['baseline','candidate']:
    product,built=build(plan,plan['images'][role],descriptors[role],control['source'],folder/role,deadline)
    command=[product['artifact']['file'],*B.native_runtime_arguments(product)]
    child=B.child(command,folder/('oracle-'+role),min(deadline,time.monotonic()+20),str(ROOT))
    assert child['exitCode']==0 and not child['timedOut'] and checked_bytes(child['stdout'])==checked_bytes(control['expected']) and checked_bytes(child['stderr'])==b''
    rows[role]=dict(build=built,process=child)
   report['controls'][control['id']]=dict(fixture=control,roles=rows);B.save(out/'preparation.json',report)
  B.save(out/'recipe.json',recipe);B.freeze(out/'recipe.json',out/'manifest.json');report.update(complete=True,manifest=B.pin(out/'manifest.json'));B.save(out/'preparation.json',report)
 finally:
  for fd in descriptors.values():os.close(fd)
 remaining=min(plan['timingSeconds'],deadline-time.monotonic());assert remaining>0
 result=P.checkpointed_run(SimpleNamespace(manifest=out/'manifest.json',out=out/'timing',cases=None,rounds=3,target_ms=plan['targetMs'],cpu=3,seconds=remaining,guarded=True));assert result['complete']
 summary=S.S.summarize(SimpleNamespace(report=out/'timing/report.json',references=out/'manifest.json',c_role='c',baseline_role='baseline',spread_limit=1.10,emission=[]))
 assert summary['positionBalanced'] and summary['oracleRevalidated']['samples']==9*len(plan['cases']) and summary['subsets']['all']['caseCount']==len(plan['cases'])
 frozen={c['id']:c for c in B.read(out/'manifest.json')['cases']}
 for row in summary['cases']:
  assert all(row['artifacts'][role]==frozen[row['id']]['products'][role]['artifact'] for role in summary['roles'])
  for role,check in report['cases'][row['id']]['oracles'].items():
   proc=check['process'];point=dict(catalog[row['id']]['point'],repetitions=1,warmups=0)
   assert B.observation(checked_bytes(proc['stdout']),checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds'])==check['elapsedMs']
 for control in report['controls'].values():
  for row in control['roles'].values():
   proc=row['process'];assert proc['exitCode']==0 and not proc['timedOut']
   assert checked_bytes(proc['stdout'])==checked_bytes(control['fixture']['expected']) and checked_bytes(proc['stderr'])==b''
   B.verify(row['build']['object']);B.verify(row['build']['binary'])
 for pin in inputs:B.verify(pin)
 summary.update(inheritedSummaryMethod=summary['method'],method=B.pin(__file__),checkpointMethod=B.pin(P.__file__),extraControlObservations=2*len(report['controls']),kind='phase205-authenticated-dual-image-screen',complete=True,plan=B.pin(args.plan),preparation=B.pin(out/'preparation.json'),images=report['images'],runtime=plan['runtime'],identityControls={k:{f:r[f] for f in ['objectsIdentical','elfBytesIdentical','loadedLayoutsIdentical']} for k,r in report['cases'].items()},extraControls=list(report['controls']),compilerCostSeconds={role:{field:sum(row['builds'][role][field] for row in report['cases'].values()) for field in ['emitSeconds','linkSeconds']} for role in ['baseline','candidate']})
 summary['scope']+=' Both native image products compiled from real frozen sources in this run; no semantic output or timing copied from matching objects. Identical layouts remain fresh timing controls. Gzip acquisition provenance is explicit, not installed/N2 qualification.'
 B.save(out/'summary.json',summary);(out/'summary.md').write_text(S.markdown(summary).replace('# Phase193 runtime summary','# Phase205 dual native images',1));print(json.dumps(dict(summary=str(out/'summary.json'),candidate=summary['subsets']['all']['roles']['candidate'],warnings=summary['warnings'])))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();run(a)
