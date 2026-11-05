#!/usr/bin/env python3
"""Pinned bendc frontend observation; type checking and proof verdict are distinct."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
from run import pin,verify,save,execute
p=argparse.ArgumentParser()
p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
p.add_argument('--mode',choices=['parse-only','check-only'],required=True)
p.add_argument('--expect',choices=['empty','unsafe-verdict','type-error','parse-error'],required=True)
p.add_argument('--image',type=Path,default=ROOT/'selfhost/build/phase160/capped-seed01/bendc')
p.add_argument('--seconds',type=int,default=90)
a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
base=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend';source=a.source.resolve();image=a.image.resolve()
inputs=[pin(x) for x in [__file__,ROOT/'selfhost/tools/profiler/run.py',source,base,image,ROOT/'selfhost/build/phase160/capped-seed01/report.json']]
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT']}
env.update(BEND_RC='0',BEND_NO_FREE='1',BEND_AUTO_PAR='0')
cmd=[str(image),'--threads','1','--gpu','off','--','--'+a.mode,str(base),str(source)]
r=dict(kind='phase162-bendc-frontend-observation',complete=False,source=pin(source),base=pin(base),image=pin(image),inputs=inputs,mode=a.mode,expect=a.expect,environment={k:v for k,v in env.items() if k.startswith('BEND_')},scope='Whole fresh process including live Base. Empty parse output is provisional admission, not a structural AST oracle. Unsafe proof verdict is separate from successful body type checking.')
save(out/'report.json',r)
r['process']=execute(cmd,out/'child',str(ROOT),a.seconds,env)
q=r['process'];stdout=Path(q['stdout']['file']).read_text();stderr=Path(q['stderr']['file']).read_text()
if a.expect=='empty':passed=q['returncode']==0 and stdout==stderr==''
elif a.expect=='unsafe-verdict':passed=q['returncode']==1 and stdout=='' and stderr.startswith('SOME PROOFS FAIL\nError: ') and ' on unsafe or foreign code:' in stderr
else:passed=q['returncode']==1 and stdout=='' and len(stderr)>0 and not stderr.startswith('SOME PROOFS FAIL')
r.update(complete=passed and not q['timedOut'],observationPassed=passed)
for row in inputs:verify(row)
save(out/'report.json',r);print(json.dumps(dict(complete=r['complete'],seconds=q['wallSeconds'],cpuSeconds=q['cpuSeconds'],rssKiB=q['peakRssKiB'],stdout=stdout[:200],stderr=stderr[:300])))
raise SystemExit(0 if r['complete'] else 1)
