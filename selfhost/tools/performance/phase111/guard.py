#!/usr/bin/env python3
"""Phase111 guard: unchanged process-tree limits, bounded large assembly files.

The full direct image produced more than the historical64MiB assembly limit.
This preserves the shared lock/RSS/deadline supervisor and records an explicit
per-file cap plus enough disk for two maximum-size output files and160MiB slack.
"""
import argparse, importlib.util, json, shutil, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=int,required=True)
p.add_argument('--rss-mib',type=int,default=2048);p.add_argument('--available-mib',type=int,default=4096)
p.add_argument('--file-mib',type=int,default=128)
p.add_argument('--cpu',default='3');p.add_argument('command',nargs=argparse.REMAINDER)
a=p.parse_args();cmd=a.command
if cmd and cmd[0]=='--':cmd=cmd[1:]
assert 64<=a.file_mib<=256,'File cap must be64..256MiB'
assert cmd and shutil.disk_usage(ROOT).free>(160+2*a.file_mib)*1024**2,'Need command and bounded output disk headroom'
out=a.out.resolve();out.parent.mkdir(parents=True,exist_ok=True)
identities=[S.identity(f) for f in cmd if Path(f).is_file()]
command=['bash','-c',f'ulimit -f {a.file_mib*1024}; ulimit -c 0; exec "$@"','phase111','taskset','-c',a.cpu,*cmd]
assert 0<a.rss_mib<=6144 and a.available_mib>=4096
assert a.rss_mib<=3072 or a.available_mib>=16384
with S.ExecutionGuard(rss_mib=a.rss_mib,available_mib=a.available_mib) as guard:
    r=guard.run(command,out,time.monotonic()+a.seconds)
S.save(out/'inputs.json',identities)
S.save(out/'method.json',dict(method=S.identity(__file__),support=S.identity(ROOT/'selfhost/tools/performance/programs/support.py'),cpu=a.cpu,fileLimitBytes=a.file_mib*1024**2,diskFreeBytes=shutil.disk_usage(ROOT).free))
print(json.dumps(r),flush=True)
sys.exit(0 if r['complete'] else 1)
