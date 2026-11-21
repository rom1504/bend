"""Exercise the exact matcher on a real checked segment and independent mutations."""
import importlib.util
import json
from pathlib import Path
import sys
import subprocess
from prepare import ROOT,HERE
out=Path(sys.argv[1]).resolve()
out.mkdir(parents=True)
source=Path(sys.argv[2])
spec=importlib.util.spec_from_file_location("fixture",ROOT/'research/phase201/elf/standalone.py')
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
name=b'x202k_shape'
data,_=mod.slice_source(source.read_bytes(),name)
(out/'selector.bend').write_bytes(data[:-len(name)])
(out/'exports.json').write_text(json.dumps(dict(kind='bend-hosted-api-exports',version=1,protocol='typed-api-v1',targets=['qbe'],exports=[name.decode()])))
bun=ROOT/'selfhost/.assets/bin/bun'
subprocess.run([bun,'selfhost/tools/build/hosted.mjs','acquire','--source',out/'selector.bend','--out',out/'api','--exports',out/'exports.json','--engine',bun,'--upstream','selfhost/.bootstrap/upstream-phase182'],check=True)
subprocess.run([bun,HERE/'contract.mjs',out,sys.argv[3]],check=True)
