#!/usr/bin/env python3
"""Independent expected stdout and alternating fresh-process runtime samples."""
import argparse,json,sys,statistics,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,run,write_json,fresh_output
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,action='append',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--expected',required=True);p.add_argument('--rounds',type=int,default=4);a=p.parse_args();out=fresh_output(a.out,ROOT)
report=dict(complete=False,inputs=[pin(__file__)],rows=[],samples=[]);builds=[]
try:
 for f in a.build:
  r=json.loads(f.read_text());require(r['complete'],'Incomplete build');verify(r['binary']);builds.append((r['role'],r['binary']));report['inputs'] += [pin(f),r['binary']]
 for k in range(a.rounds):
  for role,binary in builds if k%2==0 else reversed(builds):
   job=run([binary['file'],'--threads','1','--gpu','off'],cwd=ROOT,stdout=out/f'{k}-{role}.stdout',stderr=out/f'{k}-{role}.stderr',seconds=20)
   require(job['complete'],'Execution failed '+role);actual=Path(job['stdout']['file']).read_text();require(actual==a.expected+'\n','Independent output mismatch '+repr(actual));report['samples'].append(dict(role=role,round=k,**job));write_json(out/'report.json',report)
 for role,_ in builds:
  vals=[x['seconds'] for x in report['samples'] if x['role']==role];report['rows'].append(dict(role=role,median=statistics.median(vals),samples=vals))
 report['complete']=True
finally:write_json(out/'report.json',report);print(json.dumps(report))
