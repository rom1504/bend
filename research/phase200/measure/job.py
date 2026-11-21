#!/usr/bin/env python3
"""Phase200 names around the existing shared-lane disk guard and retention closer."""
import argparse,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('seconds');p.add_argument('disk_mib');p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
assert a.command and a.name and '/' not in a.name and a.name not in ('.','..')
root=Path('selfhost/build/phase200');out=root/a.name;guard=root/(a.name+'-guard')
assert '--out' in a.command and Path(a.command[a.command.index('--out')+1]).resolve()==out.resolve()
args=[sys.executable,'-B','selfhost/tools/build-retention/guard.py','--out',str(guard),'--run-root',str(out),'--seconds',a.seconds,'--disk-mib',a.disk_mib,'--rss-mib','2048','--available-mib','16384','--file-mib','128','--cpu','3','--',*a.command]
r=subprocess.run(args)
subprocess.run([sys.executable,'-B','selfhost/tools/build-retention/close.py','--run',str(guard),'--classification','completed' if r.returncode==0 else 'failed','--keep-root',str(out),'--out','selfhost/build-retention/phase200/'+a.name+'-close'],check=True,stdout=subprocess.DEVNULL)
sys.exit(r.returncode)
