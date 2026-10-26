"""Root-only clean paired screen; exact frozen Phase131 counts and output oracle."""
import argparse, importlib.util, json, os, statistics, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
ORACLE=ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py'
spec=importlib.util.spec_from_file_location('O',ORACLE);O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--builds',type=Path,required=True);ap.add_argument('--out',type=Path,required=True)
a=ap.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
assert sorted(os.sched_getaffinity(0))==[3]
assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_PROFILE_COUNTERS','BEND_PROFILE_EVENTS_OUT'])
b=O.read(a.builds);m=O.read(HERE/'bench-cases-v01.json');assert b['complete'] and len(b['smokes'])==8 and all(r['correct'] for r in b['smokes'])
inputs=[O.pin(__file__),O.pin(ORACLE),O.pin(a.builds),O.pin(HERE/'bench-cases-v01.json'),*m['inputs'],*b['inputs']]
for x in b['builds']:inputs.extend([x['binary'],x['build'],x['qbe'],x['runtime']])
for p in inputs:O.verify(p)
out.mkdir();report=dict(kind='phase144-append-frozen-count-screen',complete=False,inputs=inputs,rounds=4,rows=[],summary=[],scope='Four-case diagnostic subset, four balanced baseline/candidate pairs. Exact Phase131 argument vectors and complete output/count oracle. Not the full44-point historical score; no historical times mixed in.')
save=lambda:O.save(out/'report.json',report);save();started=time.monotonic()
try:
 for rnd in range(4):
  for c in m['cases']:
   for role in (['baseline','candidate'] if rnd%2==0 else ['candidate','baseline']):
    binary=next(x['binary'] for x in b['builds'] if x['role']==role and x['name']==c['name'])
    command=[binary['file'],'--threads','1','--gpu','off','--',*c['historicalArgumentVector']]
    t=time.monotonic();p=subprocess.run(command,cwd=ROOT,capture_output=True,timeout=30);wall=time.monotonic()-t
    stem=f"{rnd}-{role}-{c['name']}";so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(p.stdout);se.write_bytes(p.stderr)
    row=dict(name=c['name'],role=role,round=rnd,command=command,binary=binary,status=p.returncode,wallSeconds=wall,stdout=O.pin(so),stderr=O.pin(se));report['rows'].append(row);save()
    row['elapsedMs']=O.observation(p.stdout,p.stderr,p.returncode,c,wall);row['correct']=True;save()
 for c in m['cases']:
  a0=[r['elapsedMs'] for r in report['rows'] if r['name']==c['name'] and r['role']=='baseline'];a1=[r['elapsedMs'] for r in report['rows'] if r['name']==c['name'] and r['role']=='candidate']
  report['summary'].append(dict(name=c['name'],baselineMs=a0,candidateMs=a1,medianRatio=statistics.median(a1)/statistics.median(a0),pairedRatios=[y/x for x,y in zip(a0,a1)],shortInterval=min(a0+a1)<100))
 for p in inputs:O.verify(p)
 report['complete']=True
except BaseException as err:report['error']=repr(err);raise
finally:report['seconds']=time.monotonic()-started;save()
print(json.dumps(dict(complete=True,summary=report['summary'],seconds=report['seconds'])))
