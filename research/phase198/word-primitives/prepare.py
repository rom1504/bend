from pathlib import Path
import argparse,subprocess,sys
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args()
h=Path(__file__).parent
subprocess.run([sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',
    'selfhost/build/phase198/selected-source01/compiler.bend','--assets','selfhost/build/phase194/assets.json',
    '--out',a.out,'--module',h/'select.bend','--module',h/'machine.bend','--replace','x185_sf_body',
    '--replace','x186_u32_float_probe','--export','x198w_op','--export','x198w_known','--export','x198w_calc'],check=True)
