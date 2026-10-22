"""Independent varying-value producer/append benchmark; not part of original45."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def save(p,s):
 assert not p.exists() or p.read_text()==s;p.write_text(s)
values=[(3*x+1)&0xffffffff for x in range(257,1,-1)]+[17,18]
h=2166136261
for x in values:h=(h*65599+x)&0xffffffff
prefix='''import Base

def composition.make(n: Nat, +seed: U32, acc: List<&2,U32>) -> List<&2,U32>:
  match n:
    case 0n: acc
    case 1n+p: composition.make(p,U32.add(seed,1),seed <> acc)

def composition.map(xs: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: U32.add(U32.mul(h,3),1) <> composition.map(t)

def composition.append(xs: List<&2,U32>, ys: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: ys
    case h <> t: h <> composition.append(t,ys)

def composition.fold(xs: List<&2,U32>, hash: U32) -> U32:
  match xs:
    case Nil{}: hash
    case h <> t: composition.fold(t,U32.add(U32.mul(hash,65599),h))

def composition.value(seed: U32, +suffix: U32) -> U32:
  composition.fold(composition.append(composition.map(composition.make(256n,seed,Nil{})),[suffix,U32.add(suffix,1)]),2166136261)

'''
wrapperSource=ROOT/'selfhost/build/phase93/fixtures01/test-rle-roundtrip.bend'
wrapper='# Phase93:'+wrapperSource.read_text().split('# Phase93:',1)[1]
wrapper=wrapper.replace('  main.out()','  composition.value(a,b)').replace('U32.is_eq(value, 11)',f'U32.is_eq(value, {h})')
source=HERE/'map-append256-02.bend';save(source,prefix+wrapper)
expected=HERE/'map-append256-02.expected.stdout';save(expected,str(h)+'\n')
case=dict(name='p125-map-append256',source=pin(source),expectedStdoutEvidence=pin(expected),expectedStdout=str(h)+'\n',runtimeArgs=[2,17],repetitions=20000,warmups=2,ratioEligible=False,family='independent-map-append',oracle='Independent Python integer fold over descending varied mapped values and fixed suffix; original Phase93 complete result/count observer unchanged.')
save(HERE/'cases02.json',json.dumps(dict(cases=[case],inputs=[pin(__file__),pin(wrapperSource)]),indent=2)+'\n')
print(h)
