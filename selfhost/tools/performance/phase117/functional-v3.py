"""Build checked emissions and run unchanged Phase112 exact ordinary oracle."""
import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(r):assert pin(r['file'])==r
p=argparse.ArgumentParser();p.add_argument('--emission',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--label',required=True);a=p.parse_args();assert sorted(os.sched_getaffinity(0))==[3]
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase117');out.mkdir();m=read(Path(__file__).parent/'controls03.json');e=read(a.emission);assert e['complete'];r=dict(complete=False,inputs=[pin(__file__),pin(a.emission),pin(Path(__file__).parent/'controls03.json'),*e['inputs']],rows=[]);save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');save();start=time.monotonic()
for x in r['inputs']:verify(x)
for c in e['cases']:
 name=c['name'];f=next(f for f in m['cases'] if f['name']==name);verify(f['source']);verify(f['expected']);verify(c['qbe']);dest=ROOT/'selfhost/build/phase111'/('p117-'+a.label+'-'+name+'-build');row=dict(name=name,certificate=c['certificate']);r['rows'].append(row);save()
 cmd=['python3','-B',str(ROOT/'selfhost/tools/performance/phase111/build.py'),'--source',c['qbe']['file'],'--runtime',e['runtime']['file'],'--out',str(dest),'--seconds','30'];row['buildCommand']=cmd
 result=subprocess.run(cmd,capture_output=True,timeout=55);(out/(name+'.build.stdout')).write_bytes(result.stdout);(out/(name+'.build.stderr')).write_bytes(result.stderr);assert result.returncode==0
 b=read(dest/'report.json');assert b['complete'];row['build']=pin(dest/'report.json');verify(b['binary'])
 cmd=['python3','-B',str(ROOT/'selfhost/tools/performance/phase112/observe.py'),'--binary',b['binary']['file'],'--expected',f['expected']['file'],'--out',str(out/(name+'-observe'))];row['observeCommand']=cmd
 result=subprocess.run(cmd,capture_output=True,timeout=15);(out/(name+'.observe.stdout')).write_bytes(result.stdout);(out/(name+'.observe.stderr')).write_bytes(result.stderr);row['status']=result.returncode;row['observation']=pin(out/(name+'-observe')/'report.json');save();assert result.returncode==0;print(name,'passed',flush=True)
r.update(complete=True,seconds=time.monotonic()-start);save()
