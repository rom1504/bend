"""Extract the bound checked x86 experiment API, retaining the original compiler source."""
from pathlib import Path
import argparse
import subprocess
import sys

here=Path(__file__).parent
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--parent',type=Path,default=Path('selfhost/build/phase197/baseline-source01/compiler.bend'))
a=p.parse_args()
cmd=[sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',a.parent,
     '--assets','selfhost/build/phase194/assets.json','--out',a.out]
for m in ['recognize.bend','select.bend','hook.bend']:
    cmd+=['--module',here/m]
for f in ['x198_perm_pick','x198_perm_spec','x198_perm_selected','x185_function_copied']:
    cmd+=['--export',f]
subprocess.run([*cmd,'--replace','x185_function_copied'],check=True)
