"""Extract an isolated checked Bend API from the actual Phase198 source snapshot."""
from pathlib import Path
import argparse,subprocess,sys
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
here=Path(__file__).parent
cmd=[sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source','selfhost/build/phase198/selected-source01/compiler.bend','--assets','selfhost/build/phase194/assets.json','--out',str(a.out)]
for module in ['numeric-orbit.bend','orbit-selective.bend','progress.bend','hook.bend']:cmd+=['--module',str(here/module)]
for name in ['x198n_body','x198n_bin','x198n_eval','x198n_types','x198n_positive','x198o_eval','x198o_bin','x198o_positive','x198o_no_fixed','x198o_progress_eval','x181_direct']:cmd+=['--export',name]
subprocess.run([*cmd,'--replace','x181_direct'],check=True)
