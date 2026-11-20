"""Independent source-level iteration incidence; no native executable is run."""
from pathlib import Path
import json

def step(cr,ci,zr,zi,esc,it):
 def asr(x):return (x>>8)|(0xff000000 if x&0x80000000 else 0)
 r2=asr((zr*zr)&0xffffffff);i2=asr((zi*zi)&0xffffffff)
 e2=esc|int(((r2+i2)&0xffffffff)>1024)
 nr=(r2-i2+cr)&0xffffffff;ni=(asr((2*zr*zi)&0xffffffff)+ci)&0xffffffff
 return (zr if e2 else nr,zi if e2 else ni,e2,(it+int(not e2))&0xffffffff)

def analyze(ids,n):
 hist={};saved=0
 for i in ids:
  cr=((((i&4095)*768)//4096)-512)&0xffffffff
  ci=((((i>>12)*768)//4096)-384)&0xffffffff
  state=(0,0,0,0);first=n
  for j in range(n):
   state=step(cr,ci,*state)
   if state[2]:first=j+1;break
  saved+=n-first;hist[first]=hist.get(first,0)+1
 return dict(pixels=len(ids),iterations=n,firstEscapeOrExhausted=hist,originalBodies=len(ids)*n,remainingFrozenBodies=saved,savedBodyFraction=saved/(len(ids)*n))
rows={'mandelbrot':analyze(list(range(256)),7)}
for depth,n in [(4,7),(5,31)]:
 side=1<<depth;stride=4096//side
 ids=[((i//side)*stride+stride//2)*4096+(i%side)*stride+stride//2 for i in range(side*side)]
 rows[f'variation-mandelbrot-grid-{depth}-{n}']=analyze(ids,n)
out=Path(__file__).parent/'incidence.json';out.write_text(json.dumps(dict(kind='independent-source-incidence-v1',nativeTargetsRun=False,scope='Exact documented input enumeration and modular U32 step, not hardware profiling or a speed estimate. Histogram/recolor source repeats the ordinary pixel set twice; ratios unchanged.',rows=rows),indent=2)+'\n')
print(json.dumps(rows))
