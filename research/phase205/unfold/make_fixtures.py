"""Construct the independently specified packet workload and stage four inputs."""
import json
from pathlib import Path
from stage import transform
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
FIX=ROOT/'selfhost/tools/bench/catalogs/native45/fixtures'
PACKET='H|LEN:Ω|PAY||CRC:.'
W=(1<<32)-1

def oracle(count,seed):
    state=seed
    for _ in range(count):
        for c in PACKET:
            state=(state^0xa5a5a5a5) if c=='|' else (state*33+ord(c))&W
    return str(state)+'\n'

def run():
    source='''import Base

# A packet header updates a caller-supplied rolling word. A delimiter changes
# the high and low bits without contributing a payload byte. A non-ASCII
# payload occupies one code point in the String stream.
def packet.choose(delimiter: Bool, state: U32, code: U32) -> U32:
  match delimiter:
    case True{}: U32.xor(state, 2779096485)
    case False{}: U32.add(U32.mul(state, 33), code)

def packet.step(+code: U32, state: U32) -> U32:
  packet.choose(U32.is_eq(code, 124), state, code)

def packet.fold(bytes: String, state: U32) -> U32:
  match bytes:
    case SNil{}: state
    case SCon{Chr{byte}, tail}: packet.fold(tail, packet.step(byte, state))

def packet.apply(state: U32) -> U32:
  packet.fold('''+json.dumps(PACKET,ensure_ascii=False)+''', state)

def packet.batch(n: Nat, state: U32) -> U32:
  match n:
    case 0n: state
    case 1n+k: packet.batch(k, packet.apply(state))

def bench(count: U32, state: U32) -> U32:
  packet.batch(U32.to_nat(count), state)

'''
    harness=(FIX/'lexer.bend').read_text().split('# Phase93:',1)[1]
    source+='# Phase93:'+harness.replace('1822208108',oracle(512,17).strip())
    (HERE/'packet.bend').write_text(source)
    rows={}
    for n in ('lexer','variation-lexer-6-17','variation-lexer-10-123','packet'):
        original=(HERE/'packet.bend') if n=='packet' else FIX/(n+'.bend')
        staged,rec=transform(original.read_text());assert len(rec)==1 and staged!=original.read_text()
        output=HERE/(n+'-staged.bend');output.write_text(staged);rows[n]=dict(original=str(original.relative_to(ROOT)),staged=str(output.relative_to(ROOT)),sites=rec)
    (HERE/'fixtures.json').write_text(json.dumps(rows,indent=2)+'\n')

if __name__=='__main__':run()
