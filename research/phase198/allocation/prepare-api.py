"""Assemble a candidate API from the combined Phase197 compiler and isolated hooks."""
import argparse
from pathlib import Path
import subprocess
import sys
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
here=Path(__file__).parent
cmd=[sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',
     'selfhost/build/phase197/full-source01/compiler.bend','--assets','selfhost/build/phase194/assets.json',
     '--out',str(a.out),'--module',str(here/'frame-register.bend'),'--module',str(here/'hook.bend'),
     '--replace','x191_function_saved']
for name in ('x198fr_binary','x198fr_item','x198fr_work','x198fr_final'):cmd+=['--export',name]
subprocess.run(cmd,check=True)
