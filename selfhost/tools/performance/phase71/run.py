#!/usr/bin/env python3
"""One guarded target at a time; explicit physical-CPU affinity for scaling."""
import argparse,importlib.util,json,time,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
s=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--cpus',default='3');p.add_argument('--seconds',type=float,default=90);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
cmd=a.command[1:] if a.command[:1]==['--'] else a.command
assert not a.out.exists();assert set(a.cpus.replace('-',',').split(','))<=set('0123')
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 r=guard.run(['taskset','-c',a.cpus,*cmd],a.out,time.monotonic()+a.seconds)
print(json.dumps({k:r[k] for k in ['complete','returncode','wallSeconds','peakTreeRssBytes']}))
for n in ['stdout.log','stderr.log']:
 f=a.out/n
 if f.exists() and f.stat().st_size:print(n+': '+f.read_text()[-1200:])
raise SystemExit(0 if r['complete'] else 1)
