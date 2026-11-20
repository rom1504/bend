from pathlib import Path
import argparse
import subprocess
import sys
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
subprocess.run([sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source','selfhost/build/phase198/selected-source01/compiler.bend',
    '--assets','selfhost/build/phase194/assets.json','--out',a.out,'--module',Path(__file__).with_name('rule.bend'),
    '--replace','p125i_previous_fallback','--export','p198q_plan','--export','p125i_previous_fallback'],check=True)
