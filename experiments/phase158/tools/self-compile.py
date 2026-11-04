#!/usr/bin/env python3
"""Reproduce pinned bendc self-emission; checking boundaries stay explicit."""
import argparse,json,os,statistics,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,require,write_json,same_bytes
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--modes',nargs='+',choices=['no-check','checked','check-only'],default=['no-check'])
p.add_argument('--rounds',type=int,default=1);p.add_argument('--seconds',type=float,default=60)
p.add_argument('--budget',type=float,default=240);p.add_argument('--workers',type=int,default=1)
p.add_argument('--check-rounds',type=int,default=5)
p.add_argument('--check-oracle',type=Path)
a=p.parse_args();require(1<=a.rounds<=9 and 1<=a.workers<=8,'Bounded experiment required')
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
tree=ROOT/'selfhost/build/phase158/historical';base=ROOT/'selfhost/build/phase158/upstream-2.0.32/bend2'
binary=ROOT/'selfhost/build/phase158/seed01/bendc';seed=tree/'seed/bendc.c'
inputs=[pin(binary),pin(seed),pin(__file__),pin(ROOT/'selfhost/tools/build/common.py'),pin(ROOT/'selfhost/build/phase158/seed01/report.json')]
inputs +=[pin(f)for f in sorted(tree.rglob('*'))if f.is_file()and f.suffix in ['.bend','.c','.h']]
inputs +=[pin(f)for f in sorted(base.rglob('*'))if f.is_file()and f.suffix in ['.bend','.c','.js','.ts']]
if a.check_oracle:inputs.append(pin(a.check_oracle))
env={k:v for k,v in os.environ.items()if not k.startswith('BEND_')and k not in ['LD_PRELOAD','LD_AUDIT']};env['BEND_NO_FREE']='1'
report=dict(kind='phase158-self-compilation',complete=False,inputs=inputs,calls=[],environment={'BEND_NO_FREE':'1'},workers=a.workers,affinity=sorted(os.sched_getaffinity(0)),rounds=a.rounds,scope='Historical published-source reconstruction; ordinary checking, unchecked emission and machine construction remain separate. No native AArch64 timing on x86.')
start=time.monotonic()
def save():write_json(out/'report.json',report)
save()
try:
 for i in range(a.rounds):
  active=[m for m in a.modes if m!='check-only'or i<a.check_rounds]
  modes=active if i%2==0 else list(reversed(active))
  for mode in modes:
   remaining=a.budget-(time.monotonic()-start);require(remaining>0,'Whole experiment budget exceeded')
   d=out/str(len(report['calls']));d.mkdir()
   cmd=[binary,'--threads',str(a.workers),'--gpu','off','--']+([]if mode=='checked'else ['--'+mode])+[base/'base.bend','bendc.bend']
   process=run(cmd,cwd=tree,stdout=d/'stdout',stderr=d/'stderr',seconds=min(a.seconds,remaining),env=env)
   row=dict(round=i,mode=mode,process=process,passed=False);report['calls'].append(row);save()
   if mode=='check-only':
    require(a.check_oracle is not None,'Check-only observation retained but not qualified without an independently established report')
    oracle=json.loads(a.check_oracle.read_text())
    require(not process['timedOut']and process['exitCode']==oracle['exitCode'],'Checker exit differs')
    for key in ['stdout','stderr']:require(same_bytes(d/key,verify(oracle[key])),'Checker report differs')
   else:
    require(process['complete']and process['stderr']['bytes']==0,'Self-emission failed')
    require(same_bytes(d/'stdout',seed),'Self-emitted C differs from committed seed')
   row['passed']=True;save()
 for x in inputs:verify(x)
 report['summary']={}
 for mode in a.modes:
  rows=[r['process']for r in report['calls']if r['mode']==mode]
  report['summary'][mode]=dict(bestSeconds=min(r['seconds']for r in rows),medianSeconds=statistics.median(r['seconds']for r in rows),medianCpuSeconds=statistics.median(r['userSeconds']+r['systemSeconds']for r in rows),maxRssKiB=max(r['peakRssKiB']for r in rows),times=[r['seconds']for r in rows])
 report['complete']=True
except Exception as e:report['error']=repr(e)
report['totalSeconds']=time.monotonic()-start;save();print(json.dumps({k:v for k,v in report.items()if k not in ['inputs','calls']}));sys.exit(0 if report['complete']else 1)
