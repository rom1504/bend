"""Independent finite sequence controls; no Bend/compiler/machine equivalence claim."""
import argparse, hashlib, itertools, json
from pathlib import Path

def split_reference(d, xs):
    # Forward mutable scanner, independent of Lean's recursive right fold.
    chunks=[[]]
    for x in xs:
        if x==d:chunks.append([])
        else:chunks[-1].append(x)
    return chunks

def join_reference(s,chunks):
    out=[]
    for i,c in enumerate(chunks):
        if i:out.extend(s)
        out.extend(c)
    return out

def fused(d,s,xs):
    return [y for x in xs for y in (s if x==d else [x])]

def repeat_by_doubling(xs,n):
    out=[];block=list(xs)
    while n:
        if n&1:out+=block
        block+=block;n>>=1
    return out

def run():
    alphabet=[0,44,0xffffffff];samples=[];count=0;repetition=0
    for length in range(7):
      for t in itertools.product(alphabet,repeat=length):
       xs=list(t)
       for d in alphabet+[0x10ffff,0x110000]:
        for s in ([],[0],[44],[0xffffffff],[44,44],[0x110000,0,44]):
          a=join_reference(s,split_reference(d,xs));b=fused(d,s,xs)
          assert a==b,(d,s,xs)
          count+=1
          for n in (0,1,2,3,7):
            whole=join_reference(s,split_reference(d,repeat_by_doubling(xs,n)))
            separately=repeat_by_doubling(a,n)
            assert whole==separately,(d,s,xs,n)
            repetition+=1
    for xs in ([],[44],[44,44],[44,0,44],[0,44,44,0],[0xffffffff,44,0x110000]):
      samples.append({'delimiter':44,'replacement':[44,0], 'input':xs,
                      'chunks':split_reference(44,xs),'output':fused(44,[44,0],xs)})
    # Negative convention: dropping empty pieces changes edge/consecutive semantics.
    assert join_reference([9],[c for c in split_reference(44,[44,44]) if c]) != fused(44,[9],[44,44])
    return {'complete':True,'scope':'Finite independent sequence models only; no Bend/compiler/machine execution.',
      'baseChecks':count,'repetitionChecks':repetition,'edgeSamples':samples,
      'emptySegmentDroppingMutantRejected':True,'arbitraryWordValuesInclude':[0xffffffff,0x110000]}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    assert not args.out.exists();r=run();r['methodSha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    args.out.write_text(json.dumps(r,indent=2)+'\n');print(r['baseChecks'],r['repetitionChecks'])
