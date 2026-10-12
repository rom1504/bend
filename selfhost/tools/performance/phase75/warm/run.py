#!/usr/bin/env python3
"""Serial guarded diagnostics; target clocks and instrumentation stay separate."""
import argparse,importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--override',type=Path)
a=p.parse_args();a.out.mkdir(exist_ok=False);plan=json.loads(a.plan.read_text())
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 for ci,case in enumerate(['numeric','array','lexer']):
  roles=['b1','b2','typescript'];roles=roles[ci:]+roles[:ci]
  if a.override:roles=['b2']
  for role in roles:
   name=case+'-'+role
   command=['taskset','-c','3',plan['roles'][role]['node']['file'],
    '--max-old-space-size=1024','--stack-size=4096',str(HERE/'request.mjs'),
    str(a.plan.resolve()),role,case,str((a.out/name).resolve())]
   if a.override:command.append(str(a.override.resolve()))
   result=guard.run(command,a.out/(name+'-guard'),time.monotonic()+180)
   report=json.loads((a.out/name/'report.json').read_text())
   print(json.dumps(dict(case=case,role=role,complete=result['complete'],pass_=report['pass'],
    requestMs=[round(r['requestMs'],1) for r in report['records']])),flush=True)
   assert result['complete'] and report['complete'] and report['pass']
