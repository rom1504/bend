#!/usr/bin/env python3
"""Measure one explicit external command with the maintained wait4 recorder."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import run
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--seconds',type=int,required=True)
p.add_argument('command',nargs=argparse.REMAINDER)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
cmd=a.command[1:] if a.command[:1]==['--'] else a.command
r=run(cmd,cwd=ROOT,stdout=a.out/'stdout',stderr=a.out/'stderr',seconds=a.seconds)
(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['complete'] else 1)
