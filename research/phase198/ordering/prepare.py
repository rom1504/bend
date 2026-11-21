"""Prepare the checked API against the incumbent without changing its source."""
import argparse
from pathlib import Path
import subprocess
import sys
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args()
subprocess.run([sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',
 'selfhost/build/phase198/selected-source01/compiler.bend','--assets','selfhost/build/phase194/assets.json',
 '--out',a.out,'--module',Path(__file__).with_name('select.bend'),'--replace','x186_u32_float_probe',
 '--export','x198ord_id','--export','x198ord_eval'],check=True)
