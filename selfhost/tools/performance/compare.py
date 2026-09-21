#!/usr/bin/env python3
"""Compare explicit frozen artifacts. Usage: compare.py CONFIG.json NEW_OUTPUT_DIR"""
import hashlib,json,os,pathlib,platform,resource,statistics,subprocess,sys,time
from datetime import datetime,timezone
ROOT=pathlib.Path(__file__).resolve().parents[2]
CONFIG=pathlib.Path(sys.argv[1]).resolve();config=json.loads(CONFIG.read_text())
OUT=pathlib.Path(sys.argv[2]).resolve();OUT.mkdir(parents=True,exist_ok=False)
NODE=str(pathlib.Path(config['node']).resolve());UP=pathlib.Path(config['upstream']).resolve()
CPU=str(config.get('cpu',2));FLAGS=config.get('flags',['--stack-size=4096','--max-old-space-size=4096'])
ENV=dict(os.environ);ENV.pop('NODE_OPTIONS',None);ENV.pop('NODE_COMPILE_CACHE',None);ENV['NODE_DISABLE_COMPILE_CACHE']='1'
def now():return datetime.now(timezone.utc).isoformat()
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def run(cmd,timeout=180):return subprocess.run(list(map(str,cmd)),cwd=ROOT,env=ENV,capture_output=True,text=True,timeout=timeout)
def git(*args):
 r=run(['git','-C',UP,*args]);r.check_returncode();return r.stdout.strip()
assert git('rev-parse','HEAD')=='6018e28ecc67cf1fffc0c20c64b11023474c2df8' and not git('status','--porcelain')
variants=config['variants'];names=[v['name'] for v in variants];assert len(names)==len(set(names))
artifacts={}
for v in variants:
 if v['kind']=='upstream':continue
 for key in ['api','runtime','driver']:
  p=pathlib.Path(v[key]).resolve();v[key]=str(p);artifacts[str(p)]=sha(p)
 driver=pathlib.Path(v['driver']);v['cacheDirectory']=str(driver.parent.parent/'build/typed/cache')
 for name in ['compiler-abi.mjs','assemble.mjs','native-build.mjs']:
  p=driver.parent/name;artifacts[str(p)]=sha(p)
 for p in v.get('sourceFiles',[]):artifacts[str(pathlib.Path(p).resolve())]=sha(p)
for p in [CONFIG,pathlib.Path(__file__).resolve(),ROOT/'tools/performance/compare-worker.mjs',pathlib.Path(NODE),UP/'bend2/bend.ts',UP/'bend2/comp.ts',UP/'bend2/base.bend']:artifacts[str(p)]=sha(p)
for w in config['workloads']:
 w['input']=str(pathlib.Path(w['input']).resolve());artifacts[w['input']]=sha(w['input'])
report=dict(started=now(),config=config,artifacts=artifacts,node=run([NODE,'--version']).stdout.strip(),platform=platform.platform(),stack=resource.getrlimit(resource.RLIMIT_STACK),loadStart=os.getloadavg(),cpuInfo=pathlib.Path('/proc/cpuinfo').read_text(),memoryInfo=pathlib.Path('/proc/meminfo').read_text(),method='serial fresh processes; rotating variant order; measured priming separate from cached samples; output validation outside compilation',samples=[],primes=[])
def save():(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def invoke(request,stem,timeout):
 req=OUT/(stem+'.request.json');result=OUT/(stem+'.result.json');req.write_text(json.dumps(request))
 cmd=['taskset','-c',CPU,NODE,*FLAGS,ROOT/'tools/performance/compare-worker.mjs',req,result]
 t=time.perf_counter()
 try:r=run(cmd,timeout)
 except subprocess.TimeoutExpired as e:
  for suffix,data in [('stdout',e.stdout),('stderr',e.stderr)]:
   (OUT/(stem+'.'+suffix)).write_text(data.decode(errors='replace') if isinstance(data,bytes) else data or '')
  return dict(status='timeout',processMs=(time.perf_counter()-t)*1000,command=list(map(str,cmd)))
 wall=(time.perf_counter()-t)*1000
 (OUT/(stem+'.stdout')).write_text(r.stdout);(OUT/(stem+'.stderr')).write_text(r.stderr)
 row=dict(status='ok' if r.returncode==0 else 'failed',exitCode=r.returncode,processMs=wall,command=list(map(str,cmd)))
 if r.returncode==0:row.update(json.loads(result.read_text()))
 return row
def clear_cache(v):
 # Only generated Base cache entries in the explicitly selected compiler host.
 p=pathlib.Path(v['cacheDirectory'])
 if p.exists():
  for f in p.glob('base-*.json'):f.unlink()
save()
for w in config['workloads']:
 for policy in w.get('caches',['off']):
  for rnd in range(config.get('repetitions',7)):
   for j in range(len(variants)):
    v=variants[(rnd+j)%len(variants)]
    if v['kind']=='upstream' and policy!='off':continue
    stem=f"{w['id']}-{policy}-{rnd}-{v['name']}";mode=w.get('mode','compile');timeout=w.get('timeout',config.get('timeout',180))
    output=OUT/(stem+('.cjs' if v['kind']=='upstream' and mode=='compile' else '.mjs' if mode in ['compile','library'] else '.txt'))
    req=dict(variant=v,input=w['input'],output=str(output),mode=mode,cache=policy,upstream=str(UP))
    if policy in ['cold','warm']:
     clear_cache(v)
     if policy=='warm':
      primed=invoke(dict(req,mode='prime'),stem+'-prime',timeout);primed.update(workload=w['id'],variant=v['name'],round=rnd);report['primes'].append(primed);save()
      if primed['status']!='ok':raise RuntimeError('Cache priming failed: '+stem)
    row=invoke(req,stem,timeout);row.update(workload=w['id'],variant=v['name'],round=rnd,cache=policy,mode=mode)
    if row['status']=='ok':
     row['outputSha256']=sha(output)
     if mode=='compile':
      try:
       executed=run(['taskset','-c',CPU,NODE,*FLAGS,output],w.get('runTimeout',15))
       row['validation']=dict(exitCode=executed.returncode,stdout=executed.stdout,stderr=executed.stderr,expected=w['expected'])
       if executed.returncode or executed.stdout.strip()!=w['expected']:row['status']='wrong-output'
      except subprocess.TimeoutExpired:row['status']='runtime-timeout'
     elif mode=='library':
      parsed=run([NODE,'--check',output]);row['validation']=dict(syntaxExitCode=parsed.returncode)
      if parsed.returncode:row['status']='invalid-js'
     else:
      expected='parsed' if mode=='parse' else 'checked'
      if output.read_text()!=expected:row['status']='wrong-result'
    report['samples'].append(row);save()
    print(json.dumps({k:row.get(k) for k in ['workload','variant','cache','round','status','compileMs','processMs']}),flush=True)
report['summary']=[]
for w in config['workloads']:
 for policy in w.get('caches',['off']):
  for v in variants:
   rows=[r for r in report['samples'] if r['workload']==w['id'] and r['cache']==policy and r['variant']==v['name']]
   if not rows:continue
   ok=[r for r in rows if r['status']=='ok'];s=dict(workload=w['id'],cache=policy,variant=v['name'],attempted=len(rows),successful=len(ok))
   if len(ok)==len(rows):
    for k in ['compileMs','processMs','cpuMs','maxRssKiB']:
     a=[r[k] for r in rows];s[k]=dict(median=statistics.median(a),min=min(a),max=max(a))
   report['summary'].append(s)
assert all(sha(p)==h for p,h in artifacts.items()),'An input changed during measurement'
assert not git('status','--porcelain')
report.update(finished=now(),loadEnd=os.getloadavg(),inputsUnchanged=True);save()
sys.exit(int(any(r['status']!='ok' for r in report['samples'])))
