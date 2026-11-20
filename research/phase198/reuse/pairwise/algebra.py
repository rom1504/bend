"""Independently evaluate source constructor equations and pointwise value specification."""
from itertools import product
from pathlib import Path
import json
HERE=Path(__file__).parent

def old(a,b,down):
    if isinstance(a,int) and isinstance(b,int):return (b,a) if down^(a>b) else (a,b)
    if isinstance(a,int) or isinstance(b,int):return 0
    x=old(a[0],b[0],down)
    y=old(a[1],b[1],down)
    if isinstance(x,int) or isinstance(y,int):return 0
    return ((x[0],y[0]),(x[1],y[1]))

def pointed(a,b,f):
    if isinstance(a,int):return f(a,b)
    return tuple(pointed(x,y,f) for x,y in zip(a,b))

def fill(t,values):
    return next(values) if isinstance(t,int) else tuple(fill(x,values) for x in t)

def terminals(t):
    return 1 if isinstance(t,int) else sum(map(terminals,t))

def main():
    rows=[]; values=[0,1,2**32-1]
    for sh in [0,(0,0),(0,(0,0)),((0,0),0),((0,0),(0,0))]:
        n=terminals(sh);trees=[fill(sh,iter(v)) for v in product(values,repeat=n)]
        cases=0
        for x,y,desc in product(trees,trees,(False,True)):
            ops=(max,min) if desc else (min,max)
            assert old(x,y,desc)==tuple(pointed(x,y,o) for o in ops)
            cases+=1
        rows.append(dict(shape=sh,trees=len(trees),checks=cases))
    out={'finiteChecks':sum(r['checks'] for r in rows),'examples':rows}
    (HERE/'algebra.json').write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
