import argparse,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',required=True);a=p.parse_args()
d=Path(__file__).resolve().parent
subprocess.run([sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',
                'selfhost/build/phase198/p199-integrated01/compiler.bend','--assets','selfhost/build/phase194/assets.json',
                '--out',a.out,'--module',d/'spill.bend','--replace','x191_function_saved','--export','x199s_apply',
                '--export','x199s_owned','--export','x199s_window'],check=True)
