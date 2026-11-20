from pathlib import Path
import argparse
import subprocess
import sys

p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--parent',type=Path,default=Path('selfhost/build/phase198/selected-source01/compiler.bend'))
a=p.parse_args()
here=Path(__file__).parent
subprocess.run([sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',a.parent,
    '--assets','selfhost/build/phase194/assets.json','--out',a.out,'--module',here/'recognize.bend',
    '--module',here/'emit.bend','--replace','p121f_selected','--export','p198e_inspect','--export','p198e_candidates'],check=True)
