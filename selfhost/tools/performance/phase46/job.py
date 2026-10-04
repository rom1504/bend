#!/usr/bin/env python3
"""Run one serial resource-limited experiment job using the maintained guard."""
import argparse, importlib.util, json, time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
support=importlib.util.module_from_spec(spec); spec.loader.exec_module(support)
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path)
p.add_argument('--seconds',type=float,default=120);p.add_argument('command',nargs=argparse.REMAINDER)
a=p.parse_args();cmd=a.command[1:] if a.command[:1]==['--'] else a.command
with support.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
    r=guard.run(['taskset','-c','3',*cmd],a.out,time.monotonic()+a.seconds)
print(json.dumps(r))
for name in ['stdout.log','stderr.log']:
    f=a.out/name
    if f.exists() and f.stat().st_size: print(name+':\n'+f.read_text()[-2500:])
raise SystemExit(0 if r['complete'] else 1)
