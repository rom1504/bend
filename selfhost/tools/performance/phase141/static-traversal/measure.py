"""Bounded serial comparison of three implementations in one native binary."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import time

ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase141')
assert sorted(os.sched_getaffinity(0))==[3]
def pin(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes())
r=dict(kind='phase141-static-comparison-proxy',complete=False,inputs=[pin(__file__),pin(a.binary),pin(a.binary.parent/'report.json')],calibration=[],rows=[],
 scope='Same binary and dynamic inputs. List construction outside internal timing; repeated comparisons and one result print inside. Compiler-IR argument shapes, not whole-compiler throughput. Independent expected digest25.')
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(size,mode,repeats,label):
 cmd=[str(a.binary.resolve()),'--threads','1','--gpu','off','--',str(repeats),'2',str(size),str(mode)]
 started=time.monotonic();c=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=15);wall=time.monotonic()-started
 (out/(label+'.stdout')).write_bytes(c.stdout);(out/(label+'.stderr')).write_bytes(c.stderr)
 values=c.stdout.decode().splitlines();assert c.returncode==0 and not c.stderr and len(values)==4,(label,c.returncode,c.stdout,c.stderr)
 assert list(map(int,values[:3]))==[25,50,(25*repeats)%2**32],(label,values)
 return dict(size=size,mode=mode,repeats=repeats,milliseconds=int(values[3]),wallSeconds=wall,command=cmd,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')))
save();started=time.monotonic()
try:
 for size in [32,256,2048]:
  repeats=32
  while True:
   row=run(size,1,repeats,f'cal-{size}-{repeats}');r['calibration'].append(row);save()
   if row['milliseconds']>=40 or repeats>=32768:break
   repeats=min(32768,repeats*4)
  repeats=min(32768,max(repeats,math.ceil(repeats*100/max(row['milliseconds'],1))))
  for rnd in range(6):
   modes=[0,1,2];modes=modes[rnd%3:]+modes[:rnd%3]
   if rnd>=3:modes=list(reversed(modes))
   for mode in modes:
    row=run(size,mode,repeats,f'{size}-{rnd}-{mode}');row['round']=rnd;r['rows'].append(row);save()
 r['summary']=[]
 for size in [32,256,2048]:
  med={m:statistics.median(x['milliseconds'] for x in r['rows'] if x['size']==size and x['mode']==m)for m in [0,1,2]}
  assert med[1]>0
  r['summary'].append(dict(size=size,medianMs=med,staticOverHand=med[2]/med[1],callbackOverHand=med[0]/med[1]))
 for x in r['inputs']:assert pin(x['file'])==x
 r['complete']=True
except BaseException as e:r['error']=repr(e)
finally:r['seconds']=time.monotonic()-started;save()
print(json.dumps({k:r.get(k)for k in ['complete','summary','error','seconds']}));raise SystemExit(0 if r['complete'] else 1)
