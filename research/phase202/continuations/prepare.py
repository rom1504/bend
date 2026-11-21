"""Compose the template at the ordinary typed segment entry; no compiler execution."""
from pathlib import Path
import argparse,hashlib
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BASE=ROOT/'selfhost/build/phase201/source02/compiler.bend'
HOOK=b'u => x181_function(p111q_symbol(name),["state"],x181_scalar_rows(body),ids),'
ANCHOR=b'@unsafe\ndef x181_segment(segment,ids):'

def apply(old):
    assert old.count(HOOK)==1 and old.count(ANCHOR)==1 and b'def x202k_' not in old
    module=(HERE/'template.bend').read_bytes().rstrip()+b'\n\n'
    head=b'case N111Segment{name,arity,result,incoming,flags,+body}:'
    begin=old.index(ANCHOR);tail=old[begin:];assert tail.startswith(ANCHOR+b'\n  match segment:\n    '+head)
    tail=tail.replace(head,head.replace(b'{name,',b'{+name,'),1)
    return old[:begin]+module+tail.replace(HOOK,b'u => nt_choose(X181Output,x202k_shape(body),v => x202k_template(p111q_symbol(name)),v => x181_function(p111q_symbol(name),["state"],x181_scalar_rows(body),ids)),',1)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',type=Path,default=BASE);p.add_argument('--out',type=Path,required=True);a=p.parse_args();s=apply(a.source.read_bytes());a.out.parent.mkdir(parents=True,exist_ok=True)
    with a.out.open('xb') as f:f.write(s)
    print(len(s),hashlib.sha256(s).hexdigest())
