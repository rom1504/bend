#!/usr/bin/env python3
"""Root-owned clean native parser pairs; host observes processes and receipts only."""
import argparse,hashlib,json,math,os,re,signal,statistics,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256();size=0
 with p.open('rb')as f:
  while b:=f.read(65536):h.update(b);size+=len(b)
 return dict(file=str(p),bytes=size,sha256=h.hexdigest())
def main():
 admission_started=time.monotonic()
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['source-manifest','oracle','original-build','candidate-build','out']:ap.add_argument('--'+n,type=Path,required=True)
 ap.add_argument('--pairs',type=int,choices=[1,3],default=1)
 ap.add_argument('--extend-below-parse-seconds',type=float,default=45)
 ap.add_argument('--seconds',type=float,default=300)
 a=ap.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase144')
 assert 0<a.seconds<=600 and 0<a.extend_below_parse_seconds<=120
 assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_PROFILE_COUNTERS','BEND_PROFILE_EVENTS_OUT'])
 assert os.sched_getaffinity(0)=={3},'Run inside root CPU3 guard'
 read=lambda p:json.loads(Path(p).read_text());manifest=read(a.source_manifest);oracle=read(a.oracle)
 assert manifest['complete']and oracle['complete']and oracle['completeParseAndSeedEqual']and oracle['request']==manifest['request']
 selected_path=ROOT/'implementation/phase143/candidate.json';selected=read(selected_path)
 assert selected['complete']and selected['nativeQualified']
 carrier=read(selected['preferredCarrierReceipt']['file']);base=next(p for p in carrier['inputs']if p['file'].endswith('/bend2/base.bend'))
 inputs={}
 def add(p):assert pin(p['file'])==p;inputs[p['file']]=p
 for f in [__file__,a.source_manifest,a.oracle,a.original_build,a.candidate_build,selected_path,selected['preferredCarrierReceipt']['file'],sys.executable]:add(pin(f))
 for p in [*manifest['inputs'],*oracle['inputs'],manifest['request'],base,selected['preferredCarrier'],selected['native'],selected['runtime']]:add(p)
 builds={role:read(p)for role,p in [('original',a.original_build),('candidate',a.candidate_build)]};commands={}
 for role,b in builds.items():
  assert b['kind']=='phase134-supervised-qbe-stdin-build'and b['complete']and b['compilerExitCode']==0 and b['qbeExitCode']==0
  assert b['source']==manifest['sourcePair'][role]['source']and b['image']==selected['native']and b['runtime']==selected['runtime']
  assert all(j['exitCode']==0 for j in b['jobs'])and not b['compilerStderr']['bytes']and not b['qbeStderr']['bytes']
  assert b['compilerCommand']==[selected['native']['file'],'--threads','1','--gpu','off','--','phase111',b['source']['file'],base['file'],'cache',selected['preferredCarrier']['file'],selected['preferredStamp']]
  for p in [*b['inputs'],b['binary']]:add(p)
  commands[role]=[b['binary']['file'],'--threads','1','--gpu','off','--',manifest['request']['file'],base['file'],selected['preferredCarrier']['file'],selected['preferredStamp']]
 out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes());start=time.monotonic();deadline=start+a.seconds
 r=dict(kind='phase144-native-parser-pairs',complete=False,request=manifest['request'],expectedHash=oracle['expectedHash'],observations=[],pairs=[],pairsRequested=a.pairs,commands=commands,
  admissionSeconds=start-admission_started,inputs=list(inputs.values()),clockPolicy='parse_ms excludes prepared-Base decoding, file input, checksum and observation/reclamation. processSeconds includes all native process work and IO; observer-reported times are milliseconds. Acquisition/check/oracle costs are separate.',
  scope='Extracted complete parser on actual fixed compiler source, identical qualified producer/runtime. No whole compiler speedup, N1/N2 qualification or upstream comparison inferred. First pair is original/candidate; following pair reverses order. Extension is conditional on observed cost, not performance advantage.')
 def save():r['seconds']=time.monotonic()-start;r['totalSecondsIncludingAdmission']=time.monotonic()-admission_started;(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 def run(role,index):
  stem=out/(f'{index:02d}-'+role);before=time.monotonic();child=None;status=None;usage=None
  with Path(str(stem)+'.stdout').open('xb')as so,Path(str(stem)+'.stderr').open('xb')as se:
   child=subprocess.Popen(commands[role],cwd=ROOT,stdout=so,stderr=se,start_new_session=True)
   try:
    while True:
     pid,status,usage=os.wait4(child.pid,os.WNOHANG)
     if pid:break
     if time.monotonic()>=deadline:raise TimeoutError('Whole paired measurement deadline')
     time.sleep(.01)
   except BaseException:
    os.killpg(child.pid,signal.SIGKILL);pid,status,usage=os.wait4(child.pid,0);child.returncode=os.waitstatus_to_exitcode(status);raise
   child.returncode=os.waitstatus_to_exitcode(status)
  elapsed=time.monotonic()-before;stdout=pin(str(stem)+'.stdout');stderr=pin(str(stem)+'.stderr')
  row=dict(role=role,index=index,command=commands[role],processSeconds=elapsed,cpuSeconds=usage.ru_utime+usage.ru_stime,peakRssBytes=usage.ru_maxrss*1024,exitCode=child.returncode,stdout=stdout,stderr=stderr)
  r['observations'].append(row);save();assert child.returncode==0 and stderr['bytes']==0
  text=Path(stdout['file']).read_text();m=re.fullmatch(r'phase144 prepare_ms (\d+)\nphase144 parse_ms (\d+)\nphase144 observe_ms (\d+)\nphase144 hash (\d+)\n',text)
  assert m,'Unexpected diagnostic protocol';prepare,parse,observe,value=map(int,m.groups());assert value==oracle['expectedHash']
  assert prepare+parse+observe<=elapsed*1000+20,'Local intervals exceed process clock'
  row.update(prepareSeconds=prepare/1000,parseSeconds=parse/1000,observeSeconds=observe/1000,hash=value,exactOracleHash=True)
  save();return row
 save()
 try:
  for i in range(a.pairs):
   order=['original','candidate']if i%2==0 else ['candidate','original'];rows={role:run(role,2*i+j)for j,role in enumerate(order)}
   pair=dict(index=i,order=order,parseRatio=rows['candidate']['parseSeconds']/rows['original']['parseSeconds'],processRatio=rows['candidate']['processSeconds']/rows['original']['processSeconds'])
   r['pairs'].append(pair);save()
   if i==0 and a.pairs>1:
    pair_cost=sum(v['processSeconds']for v in rows.values())
    if max(v['parseSeconds']for v in rows.values())>=a.extend_below_parse_seconds or pair_cost*2>deadline-time.monotonic()-15:
     r['extensionSkipped']='First pair exceeded parse threshold or remaining complete-process budget';break
  r['pairsCompleted']=len(r['pairs']);r['parseRatioGeometric']=math.exp(statistics.mean(math.log(p['parseRatio'])for p in r['pairs']));r['processRatioGeometric']=math.exp(statistics.mean(math.log(p['processRatio'])for p in r['pairs']))
  r['medians']={role:{field:statistics.median(v[field]for v in r['observations']if v['role']==role)for field in ['prepareSeconds','parseSeconds','observeSeconds','processSeconds','cpuSeconds','peakRssBytes']}for role in commands}
  for p in inputs.values():assert pin(p['file'])==p
  r['complete']=True
 except BaseException as e:r['error']=repr(e)
 finally:save()
 print(json.dumps({k:r.get(k)for k in ['complete','pairsCompleted','parseRatioGeometric','processRatioGeometric','seconds','error']}));return 0 if r['complete']else 1
if __name__=='__main__':sys.exit(main())
