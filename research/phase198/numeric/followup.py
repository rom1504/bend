from pathlib import Path
import subprocess,sys,argparse
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True)
subprocess.run(['selfhost/.assets/bin/bun','research/phase198/numeric/capture.mjs','--out',str(a.out/'capture')],check=True,timeout=50)
subprocess.run([sys.executable,'-B','research/phase198/numeric/escape-screen.py','--out',str(a.out/'screen')],check=True,timeout=20)
