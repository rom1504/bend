#!/usr/bin/env python3
"""One-policy ablation: disable bendc unboxing; preserve all other probe policy."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,write_json,fresh_output,same_bytes
p=argparse.ArgumentParser()
for key in ['source','seed','base','out']:p.add_argument('--'+key,type=Path,required=True)
p.add_argument('--cwd',type=Path,default=ROOT);p.add_argument('--input',type=Path,action='append',default=[])
p.add_argument('--expected',type=Path);p.add_argument('--seconds',type=float,required=True)
p.add_argument('--mode',choices=['checked','check-only','parse-only','no-check','ast'],required=True)
a=p.parse_args();out=fresh_output(a.out,ROOT)
inputs=[pin(x) for x in [__file__,a.source,a.seed,a.base,*a.input,*([a.expected] if a.expected else [])]]
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT']}
env.update(BEND_RC='0',BEND_NO_FREE='1',BEND_AUTO_PAR='0',BEND_UNBOX='0')
cmd=[a.seed.resolve(),'--threads','1','--gpu','off','--']
if a.mode!='checked':cmd.append('--'+a.mode)
if a.mode!='ast':cmd.append(a.base.resolve())
cmd.append(a.source.resolve())
r=dict(kind='phase160-bendc-probe',complete=False,inputs=inputs,mode=a.mode,
    environment={k:v for k,v in env.items() if k.startswith('BEND_')},
    scope='Pinned compiler-mode observation; only an explicit expected product establishes an output gate.')
write_json(out/'report.json',r)
r['process']=run(cmd,cwd=a.cwd.resolve(),stdout=out/'stdout',stderr=out/'stderr',seconds=a.seconds,env=env)
r['complete']=r['process']['complete']
if a.expected:
    r['expectedProduct']=pin(a.expected);r['exactOutput']=same_bytes(out/'stdout',a.expected)
    r['complete']=r['complete'] and r['exactOutput']
for i in inputs:verify(i)
write_json(out/'report.json',r)
print(json.dumps(dict(complete=r['complete'],exactOutput=r.get('exactOutput'),process=r['process'])))
sys.exit(0 if r['complete'] else 1)
