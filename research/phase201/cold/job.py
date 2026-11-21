"""Use the repository resource supervisor and seal each fresh Phase201 run."""
import argparse
from pathlib import Path
import subprocess
import sys

p=argparse.ArgumentParser()
p.add_argument("name")
p.add_argument("seconds",type=int)
p.add_argument("disk_mib",type=int)
p.add_argument("command",nargs=argparse.REMAINDER)
a=p.parse_args()
if not a.name.isalnum() or not a.command: p.error("expected simple run name and command")
out=Path("selfhost/build/phase201")/a.name
guard=out.with_name(out.name+"-guard")
if out.exists() or guard.exists(): raise FileExistsError(out)
cmd=[str(out) if x=="OUT" else x for x in a.command]
args=[sys.executable,"-B","selfhost/tools/build-retention/guard.py","--out",str(guard),"--run-root",str(out),
      "--seconds",str(a.seconds),"--disk-mib",str(a.disk_mib),"--rss-mib","3072",
      "--available-mib","16384","--cpu","3","--",*cmd]
r=subprocess.run(args)
if (guard/"retention.json").exists():
    subprocess.run([sys.executable,"-B","selfhost/tools/build-retention/close.py","--run",str(guard),
                    "--classification","failed" if r.returncode else "completed","--keep-root",str(out),
                    "--out",str(Path("selfhost/build-retention/phase201")/(a.name+"-close"))],check=True,stdout=subprocess.DEVNULL)
sys.exit(r.returncode)
