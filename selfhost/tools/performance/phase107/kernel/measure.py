#!/usr/bin/env python3
"""Compare the identical Bend IR kernel under native and JS hosting, serially."""
import argparse, hashlib, json, os, random, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]
def pin(file):
 p=Path(file).resolve(strict=True);data=p.read_bytes();return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',type=Path,required=True);p.add_argument('--native',type=Path,required=True);p.add_argument('--api',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=3);a=p.parse_args()
 assert 1<=a.rounds<=10;out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun';adapter=HERE/'kernel.mjs'
 (out/'method.py').write_bytes(Path(__file__).read_bytes())
 (out/'adapter.mjs').write_bytes(adapter.read_bytes())
 report=dict(kind='phase107-native-js-ir-kernel',complete=False,started=time.time(),rounds=a.rounds,affinity=sorted(os.sched_getaffinity(0)),inputs=[pin(f) for f in [__file__,adapter,a.source,a.native,a.api,bun]],jobs=[],comparisons=[],scope='Identical Bend IR construction/optimization/verification/emission; complete process wall time. Not a Bend-source frontend or full compiler benchmark. Native phase times unavailable; JS adapter phase times supplementary.')
 def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 def run(host,name,policy,fmt,round):
  label=f'{name}-{policy}-{fmt}-{host}-{round}';product=out/(label+'.out');err=out/(label+'.stderr');meta=out/(label+'.json')
  cmd=[str(a.native.resolve()),name,policy,fmt] if host=='native' else [str(bun),str(adapter),str(a.api.resolve()),name,policy,fmt,str(product),str(meta)]
  before=time.perf_counter()
  r=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=20)
  wall=time.perf_counter()-before
  (product if host=='native' else out/(label+'.stdout')).write_bytes(r.stdout);err.write_bytes(r.stderr)
  assert r.returncode==0 and r.stderr==b'',(label,r.returncode,r.stderr)
  row=dict(host=host,name=name,policy=policy,format=fmt,round=round,seconds=wall,command=cmd,output=pin(product),stderr=pin(err))
  if host=='js':row['phases']=json.loads(meta.read_text());row['receipt']=pin(meta)
  report['jobs'].append(row);save();return row
 try:
  pairs=[(name,policy,fmt) for name in ['many','shared','shared_borrow','text','closure','tree','list','tail'] for policy in ['raw','pure','memory'] for fmt in ['json','qbe']]
  random.Random(10703).shuffle(pairs)
  for round in range(a.rounds):
   for i,(name,policy,fmt) in enumerate(pairs):
    rows=[run(host,name,policy,fmt,round) for host in (['native','js'] if (i+round)%2==0 else ['js','native'])]
    assert Path(rows[0]['output']['file']).read_bytes()==Path(rows[1]['output']['file']).read_bytes(),(name,policy,fmt)
    report['comparisons'].append(dict(name=name,policy=policy,format=fmt,round=round,sha256=rows[0]['output']['sha256']))
   save();pairs.reverse()
  report['summary']=[]
  for name,policy,fmt in sorted(pairs):
   samples={h:[r['seconds'] for r in report['jobs'] if (r['name'],r['policy'],r['format'],r['host'])==(name,policy,fmt,h)] for h in ['native','js']}
   med={h:statistics.median(v) for h,v in samples.items()};report['summary'].append(dict(name=name,policy=policy,format=fmt,samples=samples,median=med,nativeRatio=med['native']/med['js']))
  for f in report['inputs']:assert pin(f['file'])==f
  report.update(complete=True,passed=True)
 finally:report.update(finished=time.time(),wallSeconds=time.time()-report['started']);save()
 print(json.dumps(dict(complete=report['complete'],comparisons=len(report['comparisons']),wallSeconds=report['wallSeconds'])))
if __name__=='__main__':main()
