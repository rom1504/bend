"""Optional tiny actual-loop model; same authenticated tool/CPU as tree MCA."""
from pathlib import Path
import hashlib,json,os,re,subprocess,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def verify(p):
 q=ROOT/p['file'];assert q.stat().st_size==p['bytes']and hashlib.sha256(q.read_bytes()).hexdigest()==p['sha256'];return q
def run(out,deadline):
 assert os.sched_getaffinity(0)=={3};out.mkdir()
 cpu=Path('/proc/cpuinfo').read_text().split('\n\n')[0];assert re.search(r'^cpu family\s*:\s*6$',cpu,re.M)and re.search(r'^model\s*:\s*58$',cpu,re.M)
 receipt=json.loads((ROOT/'selfhost/build/phase195/hardware-tool01/acquisition.json').read_text());tool=verify(receipt['tool'])
 for lib in receipt['libraries']:verify(lib)
 plan=json.loads((HERE/'model-plan.json').read_text());rows=[]
 result=dict(complete=False,tool=receipt['tool'],libraries=receipt['libraries'],cpu=re.search(r'^model name\s*:\s*(.+)$',cpu,re.M)[1],model='ivybridge',plan=plan,rows=rows)
 try:
  for case in plan['cases']:
   verify(case['program']);source=verify(case['source'])
   for noalias in plan['aliasModes']:
    left=deadline-time.monotonic();assert left>0.1
    argv=[str(tool),'-mtriple=x86_64-unknown-linux-gnu','-mcpu=ivybridge','-iterations=100','-noalias='+str(noalias).lower(),str(source)]
    t=time.monotonic();p=subprocess.run(argv,capture_output=True,text=True,timeout=min(2,left));stem=case['role']+'-'+str(noalias)
    (out/(stem+'.stdout')).write_text(p.stdout);(out/(stem+'.stderr')).write_text(p.stderr);assert p.returncode==0 and not p.stderr,p.stderr
    metrics={}
    for key in ['Iterations','Instructions','Total Cycles','Total uOps','Block RThroughput']:
     m=re.search(r'^'+key+r':\s*([\d.]+)',p.stdout,re.M);assert m;metrics[key]=float(m[1])
    assert metrics['Instructions']==100*case['instructions']
    rows.append(dict(role=case['role'],noAlias=noalias,argv=argv,seconds=time.monotonic()-t,metrics=metrics,cyclesPerCell=metrics['Total Cycles']/(100*case['cellsPerIteration']),throughputPerCell=metrics['Block RThroughput']/case['cellsPerIteration']))
  result['complete']=True
 finally:(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
 return result
