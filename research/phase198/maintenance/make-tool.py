#!/usr/bin/env python3
"""Reconstruct the isolated proposed tool from the pinned live tool and patch."""
from pathlib import Path
import argparse,hashlib,json,subprocess,tempfile
here=Path(__file__).resolve().parent
root=here.parents[2]
source=root/'selfhost/tools/build/source.py'
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--recipe',type=Path,default=here/'replay.json')
args=parser.parse_args();recipe=json.loads(args.recipe.read_text())
assert hashlib.sha256(source.read_bytes()).hexdigest()==recipe['originalTool']['sha256'],'Original transport tool changed; rebase the proposal explicitly'
with tempfile.TemporaryDirectory(prefix='policy-tool-',dir=here) as tmp:
 out=Path(tmp)/'source.py'
 subprocess.run(['patch','--batch','--fuzz=0','--no-backup-if-mismatch','--output',str(out),str(source)],input=(root/recipe['toolPatch']['file']).read_bytes(),check=True,stdout=subprocess.PIPE)
 data=out.read_bytes()
 assert hashlib.sha256(data).hexdigest()==recipe['proposedTool']['sha256']
 (here/'source-proposed.py').write_bytes(data)
print('Reconstructed source-proposed.py; live source.py unchanged')
