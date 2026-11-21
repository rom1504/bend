"""Build a catalog-independent dynamic packet fixture and scalar-word oracle."""
import hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent;ROOT=H.parents[2]
base=(ROOT/'research/phase205/controls/packet-baseline.bend').read_text().split('def packet.render(')[0]
body='''def packet.word.choose(index: U32, seed: U32, hit: Bool) -> U32:
  match hit:
    case True{}: 30
    case False{}: U32.xor(seed, U32.mul(index, 2654435761))

def packet.word(+index: U32, seed: U32) -> U32:
  packet.word.choose(index, seed, U32.is_eq(U32.and(index, 3), 0))

def packet.block(n: Nat, +seed: U32, +index: U32) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p: SCon{Chr{packet.word(index, seed)}, packet.block(p, seed, U32.add(index, 1))}

def packet.render(n: Nat, +block: String) -> String:
  separator = {SCon{Chr{30}, SCon{Chr{58}, SCon{Chr{31}, SNil{}}}} : String}
  frame.join(separator, frame.fields(30, frame.repeat(n, block)))

# Hash every raw U32 word, including non-Unicode values; also report exact length.
def packet.digest(input: String, h: U32, g: U32, n: U32) -> String:
  match input:
    case SNil{}: String.append(U32.show(n), String.append(":", String.append(U32.show(h), String.append(":", U32.show(g)))))
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      packet.digest(tail, U32.mul(U32.xor(h, x), 16777619), U32.add(U32.mul(g, 33), x), U32.add(n, 1))

def packet.value(n: U32, block: String) -> String:
  packet.digest(packet.render(U32.to_nat(n), block), 2166136261, 5381, 0)
'''
lexer=(ROOT/'selfhost/tools/bench/catalogs/native45/fixtures/lexer.bend').read_text();parse=lexer[lexer.index('def p93.parsed('):lexer.index('def p93.arguments(')]
harness='''def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & (U32 & U32)):
  match args:
    case repetitions <> warmups <> count <> size <> seed <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(count, 16), (p93.word(size, 16), p93.word(seed, 17))))
    case head <> rest: p93.arguments(rest)
    case Nil{}: ((8n, 2n), (16, (16, 17)))

def p93.loop(repetitions: Nat, +n: U32, +block: String, +expected: String, h: U32) -> U32:
  match repetitions:
    case 0n: h
    case 1n+p:
      value = packet.value(n, block)
      valid = String.eq(value, expected)
      p93.loop(p, n, block, expected, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +n: U32, size: U32, seed: U32) -> IO(Unit):
  # Original dynamic argument evaluation occurs once before all timed invocations.
  +block = {packet.block(U32.to_nat(size), seed, 0) : String}
  +expected = {packet.value(n, block) : String}
  do IO<Unit>:
    Unit <- IO.print(expected)
    Unit <- IO.print(U32.show(p93.loop(warmups, n, block, expected, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, n, block, expected, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & (U32 & U32))) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (n, rest) = arguments
  (size, seed) = rest
  p93.execute(repetitions, warmups, n, size, seed)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
'''
source=H/'packet.bend';source.write_text(base+body+'\n'+parse+harness)
def oracle(n,size,seed):
 # Imperative scalar expansion: no join/split/repeat functions from Bend.
 block=[30 if i%4==0 else seed ^ ((i*2654435761)&0xffffffff) for i in range(size)]
 h=2166136261;g=5381;count=0
 for _ in range(n):
  for word in block:
   for x in ([30,58,31] if word==30 else [word]):
    h=((h^x)*16777619)&0xffffffff;g=(g*33+x)&0xffffffff;count+=1
 return f'{count}:{h}:{g}\n'
points=[('packet-16-17',16,16,17),('packet-128-17',128,16,17),('packet-16-123',16,31,123),('packet-128-123',128,31,123),('packet-zero-long-17',0,65536,17),('packet-zero-long-max',0,65536,4294967295)]
rows=[]
for name,n,size,seed in points:
 expected=H/(name+'.stdout');expected.write_text(oracle(n,size,seed));rows.append(dict(id=name,args=[n,size,seed],point=dict(expectedStdout=expected.read_text(),repetitions=100,warmups=2,runtimeArgs=[n,size,seed],ratioEligible=True),expected=dict(file=str(expected.resolve()),bytes=expected.stat().st_size,sha256=hashlib.sha256(expected.read_bytes()).hexdigest())))
(H/'cases.json').write_text(json.dumps(dict(kind='phase205-packet-independent-oracle',source=dict(file=str(source.resolve()),bytes=source.stat().st_size,sha256=hashlib.sha256(source.read_bytes()).hexdigest()),cases=rows,scope='Authored scalar oracle; no Bend source check or target execution yet. Long dynamic block is precomputed before timed packet.render, including n=0.'),indent=2)+'\n')
print(json.dumps({'source':str(source),'cases':len(rows),'targetsRun':False}))
