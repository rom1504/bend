"""Run one stage in a fresh output directory under the existing resource guard."""
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[3]
name, seconds, disk, *command = sys.argv[1:]
assert name.isalnum() and command
out = root/'selfhost/build/phase197'/name
guard = out.with_name(name+'-guard')
base = [sys.executable, '-B']
retention = root/'selfhost/tools/build-retention'
cmd = [*base,str(retention/'guard.py'),'--out',str(guard),'--run-root',str(out),
       '--seconds',seconds,'--disk-mib',disk,'--rss-mib','2048','--file-mib','128',
       '--available-mib','16384','--cpu','3','--',*base,*command,'--out',str(out)]
r = subprocess.run(cmd, cwd=root)
subprocess.run([*base,str(retention/'close.py'),'--run',str(guard),'--classification',
                'completed' if r.returncode==0 else 'failed','--keep-root',str(out),'--out',
                str(root/'selfhost/build-retention/phase197'/(name+'-close'))],cwd=root,check=True,
                stdout=subprocess.DEVNULL)
if r.returncode:
    print((guard/'stderr.log').read_text()[-2400:])
sys.exit(r.returncode)
