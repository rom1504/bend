"""Prepare a full semantic checked zipper and its independent control exports."""
from pathlib import Path
import argparse, subprocess, sys
here=Path(__file__).parent
a=argparse.ArgumentParser()
a.add_argument('--out',type=Path,required=True)
a.add_argument('--include-entry',action='store_true')
a.add_argument('--parent',type=Path,default=Path('selfhost/build/phase197/baseline-source01/compiler.bend'))
p=a.parse_args()
cmd=[sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',p.parent,
     '--assets','selfhost/build/phase194/assets.json','--out',p.out]
for f in ['machine.bend','proof.bend','attach.bend','hook.bend','entry.bend']:
    cmd+=['--module',here/f]
for n in ['x181_request','x192h_emit_checked']:cmd+=['--replace',n]
for n in ['x198pw_plan','x198pw_probe','x198pw_symbolic','x198pw_descriptor','x198pw_family','x198pw_root_leaf','x198pw_root_node','x198pw_join','x198pw_leaf_function','x198pw_order','x198pw_def','x198pw_owners','x198pw_has_cid','x198pw_machine','x198pw_emit_wrapper','x198pw_get_mark']:
    cmd+=['--export',n]
if p.include_entry:cmd+=['--export','x181_request']
subprocess.run(cmd,check=True)
