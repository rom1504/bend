#!/usr/bin/env python3
"""Four bounded fresh processes, same source/API/Base policy; one serial lane."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import run,pin,write_json,fresh_output,require
p=argparse.ArgumentParser();p.add_argument('--receipt',required=True);p.add_argument('--source',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=fresh_output(a.out,ROOT)
r=dict(complete=False,inputs=[pin(__file__),pin(a.receipt),pin(a.source)],rows=[])
try:
 for role in ['live','plain-live','baseline','plain']:
  job=run([sys.executable,'-B','experiments/phase167/tools/one-build-v2.py','--receipt',a.receipt,'--source',a.source,'--role',role,'--preparation','cache','--out',str(out/role)],cwd=ROOT,stdout=out/(role+'.stdout'),stderr=out/(role+'.stderr'),seconds=150)
  r['rows'].append(dict(role=role,**job));write_json(out/'report.json',r);require(job['complete'],'Build failed '+role)
 r['complete']=True
finally:write_json(out/'report.json',r);print(json.dumps(r))
