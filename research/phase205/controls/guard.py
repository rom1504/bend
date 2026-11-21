"""Serialize one Phase205 controls job using the existing repository supervisor."""
import argparse,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('seconds',type=int);p.add_argument('disk_mib',type=int);p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
assert a.name.replace('-','').isalnum() and a.command and a.seconds>0 and a.disk_mib>0
out=Path('selfhost/build/phase205')/a.name;guard=out.with_name(out.name+'-guard')
assert not out.exists() and not guard.exists()
command=[str(out) if s=='OUT' else s for s in a.command]
assert '--out' in command and Path(command[command.index('--out')+1]).resolve()==out.resolve()
argv=[sys.executable,'-B','selfhost/tools/build-retention/guard.py','--out',str(guard),'--run-root',str(out),'--seconds',str(a.seconds),'--disk-mib',str(a.disk_mib),'--rss-mib','3072','--available-mib','16384','--cpu','3','--',*command]
r=subprocess.run(argv)
if (guard/'retention.json').exists():
 subprocess.run([sys.executable,'-B','selfhost/tools/build-retention/close.py','--run',str(guard),'--classification','completed' if r.returncode==0 else 'failed','--keep-root',str(out),'--out',str(Path('selfhost/build-retention/phase205')/(a.name+'-close'))],check=True)
sys.exit(r.returncode)
