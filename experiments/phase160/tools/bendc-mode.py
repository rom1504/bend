#!/usr/bin/env python3
"""Bounded phase separation, not a compilation-correctness gate."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,write_json,fresh_output
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=float,required=True)
p.add_argument('--mode',choices=['check-only','parse-only','no-check'],required=True)
a=p.parse_args();out=fresh_output(a.out,ROOT)
assets=json.loads((ROOT/'selfhost/manifests/assets-native.json').read_text())
seed=ROOT/'selfhost/build/phase157/seed01/bendc'
inputs=[pin(__file__),pin(a.source),pin(seed),assets['assets']['base'],
    pin(ROOT/'selfhost/build/phase157/vendor/manifest.json')]
for i in inputs:verify(i)
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT']}
env.update(BEND_RC='0',BEND_NO_FREE='1',BEND_AUTO_PAR='0')
cmd=[seed,'--threads','1','--gpu','off','--','--'+a.mode,assets['assets']['base']['file'],a.source.resolve()]
r=dict(kind='phase160-mode-observation',complete=False,inputs=inputs,mode=a.mode,
    environment={k:v for k,v in env.items() if k.startswith('BEND_')},
    scope='Separate parsing, checking and unchecked emission. Exit/result is retained verbatim; no blanket correctness claim.')
write_json(out/'report.json',r)
r['process']=run(cmd,cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=a.seconds,env=env)
r['complete']=r['process']['complete']
for i in inputs:verify(i)
write_json(out/'report.json',r);print(json.dumps(r['process']))
sys.exit(0 if r['complete'] else 1)
