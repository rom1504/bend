#!/usr/bin/env python3
"""Serial bounded Phase86 job; retain success/failure and command identities."""
import argparse, importlib.util, json, shutil, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=int,required=True)
p.add_argument('--cpu',default='3');p.add_argument('command',nargs=argparse.REMAINDER)
a=p.parse_args();cmd=a.command
if cmd and cmd[0]=='--':cmd=cmd[1:]
assert cmd and shutil.disk_usage(ROOT).free>160*1024**2,'Need command and160MiB disk headroom'
out=a.out.resolve();out.parent.mkdir(parents=True,exist_ok=True)
identities=[S.identity(f) for f in cmd if Path(f).is_file()]
command=['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase86','taskset','-c',a.cpu,*cmd]
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
    r=guard.run(command,out,time.monotonic()+a.seconds)
S.save(out/'inputs.json',identities)
S.save(out/'method.json',dict(method=S.identity(__file__),support=S.identity(ROOT/'selfhost/tools/performance/programs/support.py'),cpu=a.cpu,diskFreeBytes=shutil.disk_usage(ROOT).free))
print(json.dumps(r),flush=True)
sys.exit(0 if r['complete'] else 1)
