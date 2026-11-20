"""Prepare the standalone, tracked Bend module as a checked API source."""
import argparse
from pathlib import Path
import subprocess
from hashlib import sha256
import sys

p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--parent',type=Path,default=Path('selfhost/build/phase197/baseline-source01/compiler.bend'))
a=p.parse_args()
here=Path(__file__).parent
print('parent',sha256(a.parent.read_bytes()).hexdigest(),flush=True)
cmd=[sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source',a.parent,
     '--assets','selfhost/build/phase194/assets.json','--out',a.out]
for module in ['absorbing.bend','hook.bend','test-api.bend']:
    cmd+=['--module',here/module]
for name in ['x198a_body','x185_function_copied','p198a_plain','p198a_test_ids']:
    cmd+=['--export',name]
subprocess.run([*cmd,'--replace','x185_function_copied'],check=True)
