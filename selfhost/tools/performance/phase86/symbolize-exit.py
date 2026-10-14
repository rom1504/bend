#!/usr/bin/env python3
"""Attribute a saved native fail-stop using unmodified binary symbols."""
import argparse,bisect,hashlib,json,re,subprocess
from pathlib import Path
ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('binary',type=Path);ap.add_argument('log',type=Path)
ap.add_argument('library',type=Path);ap.add_argument('out',type=Path);a=ap.parse_args()
def pin(f):
    f=f.resolve();b=f.read_bytes();return dict(path=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
binary=a.binary.resolve();bound=Path(str(binary)+'.build.json')
assert pin(binary)==json.loads(bound.read_text())['binary']
symbols=[]
for line in subprocess.check_output(['nm','-n',str(binary)],text=True).splitlines():
    row=line.split()
    if len(row)==3:
        try:symbols.append((int(row[0],16),row[2]))
        except ValueError:pass
symbols.sort();addresses=[s[0] for s in symbols];frames=[]
for pc in re.findall(re.escape(str(binary))+r'\(\+0x([0-9a-f]+)\)',a.log.read_text()):
    pc=int(pc,16);start,name=symbols[bisect.bisect_right(addresses,pc-1)-1]
    frames.append(dict(returnPC=hex(pc),lookupPC=hex(pc-1),symbol=name,symbolAddress=hex(start),returnOffset=pc-start))
assert frames
out=dict(method='Return PCs follow the call; use PC-1 to avoid next-function boundary attribution. Optimized musttail calls omit earlier semantic frames. No debug line tables or root-cause proof.',
    inputs=[pin(p) for p in (binary,bound,a.log,a.library,Path(__file__),Path(__file__).with_name('exit-trace.c'))],frames=frames)
with a.out.open('x') as f:json.dump(out,f,indent=2);f.write('\n')
print(json.dumps(frames))
