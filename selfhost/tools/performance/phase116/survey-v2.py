"""Matched clean timings and unchanged-binary leaf samples; no compiler mutation."""
import argparse,bisect,collections,hashlib,importlib.util,json,math,os,re,statistics,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase116'
def read(p):return json.loads(Path(p).read_text())
def save(p,v):Path(p).write_text(json.dumps(v,indent=2)+'\n')
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(r):
 p=pin(r['file']);assert p==r,r['file'];return p
spec=importlib.util.spec_from_file_location('analysis',ROOT/'selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py');A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
def decode(name):
 def f(m):
  try:return ''.join(chr(int(x)) for x in m[0].strip('_').split('_'))
  except ValueError:return m[0]
 return re.sub(r'(?:\d+_){3,}',f,name)
def analyze(samples,binary):
 h,maps,pcs=A.parse(samples);assert Path(h['exe']).resolve()==Path(binary);segments=A.load_segments(binary)
 syms=[]
 for line in subprocess.check_output(['nm','-n','-S','--defined-only',binary],text=True).splitlines():
  x=line.split()
  if len(x)==4 and x[2] in ['t','T']:syms.append((int(x[0],16),int(x[1],16),x[3]))
  elif len(x)==3 and x[1] in ['t','T']:syms.append((int(x[0],16),0,x[2]))
 syms.sort();keys=[x[0] for x in syms];counts=collections.Counter();rows=[]
 for pc,n in pcs.items():
  m=next((m for m in maps if m['start']<=pc<m['end']),None);v=A.virtual_address(pc,m,segments) if m and m['path']==h['exe'] else None
  name='<mapping:'+m['path']+'>' if m else '<unmapped>';offset=None
  if v is not None:
   i=bisect.bisect_right(keys,v)-1
   end=(syms[i][0]+syms[i][1] if syms[i][1] else keys[i+1] if i+1<len(keys) else syms[i][0]) if i>=0 else 0
   if i>=0 and v<end:name=syms[i][2];offset=v-syms[i][0]
   else:name='<unresolved-executable>'
  counts[name]+=n;rows.append(dict(pc=hex(pc),address=hex(v) if v is not None else None,symbol=name,offset=offset,samples=n))
 cov=A.coverage_summary(h);valid=h['overruns']==0 and h['dropped']==0 and cov['near_complete_process_cpu_coverage']
 return dict(header=h,coverage=cov,zeroLoss=h['overruns']==0 and h['dropped']==0,usable=valid,scope='Physical instruction leaves, not inclusive stacks or allocation counts. Unsized QBE text symbols extend to the next text symbol; ranges are inferred. Profile clocks are not clean performance.',symbols=[dict(name=k,decoded=decode(k),samples=n,fraction=n/h['samples']) for k,n in counts.most_common()],pcs=rows)
def command(role,product,c,reps,warm,node,profile=None):
 args=list(map(str,[reps,warm,*c['args']]))
 if role.endswith('_js'):
  flags=['--stack-size=4096','--max-old-space-size=1536']
  if profile:flags+=['--cpu-prof','--cpu-prof-interval=1000','--cpu-prof-dir='+str(profile.parent),'--cpu-prof-name='+profile.name]
  return [node,*flags,product['file'],*args]
 return [product['file'],'--threads','1','--gpu','off','--',*args]
def main():
 p=argparse.ArgumentParser();p.add_argument('mode',choices=['clean','native','js']);p.add_argument('--out',required=True);p.add_argument('--names',nargs='*');a=p.parse_args()
 assert sorted(os.sched_getaffinity(0))==[3]
 out=Path(a.out).resolve();assert not out.exists() and out.is_relative_to(BASE);out.mkdir()
 m=read(BASE/'manifest01.json');js=read(BASE/'js01/report.json');assert js['complete'];jcases={x['name']:x for x in js['cases']}
 for r in m['inputs']:verify(r)
 for c in m['cases']:
  c['products'].update(jcases[c['name']]['products']);verify(c['source'])
  for v in c['products'].values():verify(v)
 selected=[c for c in m['cases'] if not a.names or c['name'] in a.names];assert len(selected)==len(a.names) if a.names else True
 node=m['node']['file'];verify(m['node']);sampler=ROOT/'selfhost/build/phase108/profiler01/sampler.so'
 report=dict(complete=False,mode=a.mode,inputs=[pin(__file__),pin(BASE/'manifest01.json'),pin(BASE/'js01/report.json'),pin(sampler),pin(A.__file__)],cases=[c['name'] for c in selected],rows=[],cpu=3,started=time.time(),scope='Eight diagnostic historical programs; not broad45 score. Identical source/arguments/output oracle; backend producers differ.')
 save(out/'report.json',report)
 clean=read(BASE/'clean01/report.json') if a.mode!='clean' else None
 for ci,c in enumerate(selected):
  roles=['upstream_c','selfhost_c','qbe','upstream_js','selfhost_js'] if a.mode=='clean' else ['upstream_c','selfhost_c','qbe'] if a.mode=='native' else ['upstream_js','selfhost_js']
  rounds=range(3) if a.mode=='clean' else [8000,13000] if a.mode=='native' else [1000]
  for rnd in rounds:
   shift=(ci+rnd)%len(roles);order=roles[shift:]+roles[:shift]
   for role in order:
    reps=c['counts']['repetitions']*4;warm=32;product=c['products'][role]
    if clean:
     old=[r for r in clean['rows'] if r['case']==c['name'] and r['role']==role];median=statistics.median(r['elapsedMs'] for r in old)
     target=4500 if a.mode=='native' else 2000
     reps=max(1,math.ceil(reps*target/median));assert reps<2**31
    stem=c['name']+'-'+role+'-'+str(rnd);prof=out/(stem+('.samples' if a.mode=='native' else '.cpuprofile'))
    cmd=command(role,product,c,reps,warm,node,prof if a.mode=='js' else None);env=dict(os.environ)
    if a.mode=='native':env.update(LD_PRELOAD=str(sampler),BEND_SAMPLE_OUT=str(prof),BEND_SAMPLE_PERIOD_US=str(rnd))
    start=time.monotonic();r=subprocess.run(cmd,capture_output=True,env=env,cwd=ROOT,timeout=35);wall=time.monotonic()-start
    (out/(stem+'.stdout')).write_bytes(r.stdout);(out/(stem+'.stderr')).write_bytes(r.stderr)
    prefix=(c['expected']+str(warm)+'\n'+str(reps)+'\n').encode();tail=r.stdout[len(prefix):]
    correct=r.returncode==0 and not r.stderr and r.stdout.startswith(prefix) and re.fullmatch(rb'[0-9]+\n',tail) is not None
    row=dict(case=c['name'],role=role,round=rnd,product=product,source=c['source'],command=cmd,repetitions=reps,warmups=warm,status=r.returncode,correct=correct,wallSeconds=wall,stdout=pin(out/(stem+'.stdout')),stderr=pin(out/(stem+'.stderr')))
    if correct:row['elapsedMs']=int(tail);assert int(tail)<=wall*1000+2
    report['rows'].append(row);save(out/'report.json',report)
    if not correct:raise ValueError('Complete output rejected: '+stem)
    if a.mode=='native':
     analysis=analyze(prof,product['file']);save(out/(stem+'.analysis.json'),analysis);row.update(profile=pin(prof),analysis=pin(out/(stem+'.analysis.json')),samples=analysis['header']['samples'],overruns=analysis['header']['overruns'],usable=analysis['usable'])
    elif a.mode=='js':row['profile']=pin(prof)
    save(out/'report.json',report);print(stem,row.get('elapsedMs'),row.get('samples'),row.get('overruns'),flush=True)
 report.update(complete=True,wallSeconds=time.time()-report['started']);save(out/'report.json',report)
if __name__=='__main__':main()
