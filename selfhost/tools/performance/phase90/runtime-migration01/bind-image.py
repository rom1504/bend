#!/usr/bin/env python3
"""Bind actual native07 build after full independent new-runtime C equality; no targets."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from image_support import bind,pin
p=argparse.ArgumentParser(description=__doc__)
for name in ['native','js','js_guard','build_guard','image']:p.add_argument(name,type=Path)
a=p.parse_args();result=bind(a.native,a.js,a.js_guard,a.build_guard,a.image)
destination=Path(str(a.image.resolve())+'.native-build.json')
with destination.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(receipt=pin(destination),source=result['source'],c=result['c'],cPatched=False,publicAdmitted=False)))
