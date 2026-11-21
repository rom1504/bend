"""Materialize authored fixtures and independent list-of-word expected outputs; no target runs."""
from pathlib import Path
import hashlib,json
H=Path(__file__).resolve().parent
COMMON='''import Base

# Independently named framing operation; split preserves every empty field.
def frame.push(c: Char, parts: List<&2, String>) -> List<&2, String>:
  match parts:
    case Nil{}: [SCon{c, SNil{}}]
    case h <> t: SCon{c, h} <> t

def frame.choose(x: U32, parts: List<&2, String>, hit: Bool) -> List<&2, String>:
  match hit:
    case True{}: SNil{} <> parts
    case False{}: frame.push(Chr{x}, parts)

def frame.fields(+delimiter: U32, input: String) -> List<&2, String>:
  match input:
    case SNil{}: [SNil{}]
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      frame.choose(x, frame.fields(delimiter, tail), U32.is_eq(x, delimiter))

def frame.join.rest(+separator: String, parts: List<&2, String>, head: String) -> String:
  match parts:
    case Nil{}: head
    case h <> t: String.append(head, String.append(separator, frame.join.rest(separator, t, h)))

def frame.join(separator: String, parts: List<&2, String>) -> String:
  match parts:
    case Nil{}: SNil{}
    case h <> t: frame.join.rest(separator, t, h)

def frame.emit(separator: String, x: U32, tail: String, hit: Bool) -> String:
  match hit:
    case True{}: String.append(separator, tail)
    case False{}: SCon{Chr{x}, tail}

def frame.onepass(+separator: String, +delimiter: U32, input: String) -> String:
  match input:
    case SNil{}: SNil{}
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      frame.emit(separator, x, frame.onepass(separator, delimiter, tail), U32.is_eq(x, delimiter))

def frame.repeat(n: Nat, +block: String) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p: String.append(block, frame.repeat(p, block))

# Serialize raw character words as ASCII; never pass invalid scalars to UTF-8 IO.
def frame.words(input: String) -> String:
  match input:
    case SNil{}: ""
    case SCon{Chr{x0}, tail}:
      x = {x0 : U32}
      String.append(U32.show(x), String.append(",", frame.words(tail)))
'''
rows=[]
def text(words):
 s='SNil{}'
 for w in reversed(words):s='SCon{Chr{%s}, %s}'%(w,s)
 return s

def oracle(d,s,xs):
 # Independent imperative scanner, not the right-recursive Bend implementation.
 chunks=[[]]
 for x in xs:
  if x==d:chunks.append([])
  else:chunks[-1].append(x)
 out=[]
 for i,c in enumerate(chunks):
  if i:out.extend(s)
  out.extend(c)
 return out

def encoded(xs):return ''.join(str(x)+',' for x in xs)+'\n'
def save(name,tail,output,kind,claim):
 source=H/(name+'.bend');source.write_text(COMMON+'\n'+tail)
 expected=H/(name+'.stdout');expected.write_text(output)
 rows.append({'id':name,'source':source.name,'expected':expected.name,'kind':kind,'admissionExpectation':claim,
              'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'expectedSha256':hashlib.sha256(expected.read_bytes()).hexdigest(),
              'checked':False,'executed':False})

# Independently authored telemetry packet, not the Unicode fixture's seed/block.
packet=[30,84,0,31,31,97,0x1f6f0,30,30];sep=[30,58,31]
for role in ('baseline','onepass','distributed'):
 body={'baseline':'frame.join(separator, frame.fields(30, frame.repeat(n, block)))',
       'onepass':'frame.onepass(separator, 30, frame.repeat(n, block))',
       'distributed':'frame.repeat(n, frame.onepass(separator, 30, block))'}[role]
 tail='def packet.render(n: Nat, +word: U32) -> String:\n  stem = {'+text(packet[:-1])+ ' : String}\n  block = String.append(stem, SCon{Chr{word}, SCon{Chr{30}, SNil{}}})\n  separator = {'+text(sep)+' : String}\n  '+body+'\n\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'
 pts=[(0,0),(1,30),(3,0x10ffff),(7,0xffffffff)]
 for i,(n,w) in enumerate(pts):
  call='IO.print(frame.words(packet.render(%dn, %d)))'%(n,w)
  tail+=('    Unit <- ' if i<len(pts)-1 else '    ')+call+'\n'
 save('packet-'+role,tail,''.join(encoded(oracle(30,sep,(packet[:-1]+[w,30])*n)) for n,w in pts),'positive-heldout','Same full sequence for all roles; structural rule may admit baseline join/split and invariant repeat.')

cases=[(44,[],[]),(44,[44,44],[44]),(44,[0,44],[44,44]),(0,[0xffffffff],[0,1,0]),(0xd800,[0x110000,0],[0xd7ff,0xd800,0xdfff,0xe000]),(0xffffffff,[44],[0,0x10ffff,0x110000,0xffffffff]),(0x10ffff,[0x10ffff,0x10ffff],[0x10ffff,0x1f600,0x10ffff])]
for role in ('baseline','onepass'):
 tail='def main() -> IO(Unit):\n  do IO<Unit>:\n';output=''
 for i,(d,s,xs) in enumerate(cases):
  expr=('frame.join('+text(s)+', frame.fields('+str(d)+', '+text(xs)+'))') if role=='baseline' else 'frame.onepass('+text(s)+', '+str(d)+', '+text(xs)+')'
  tail+=('    Unit <- ' if i<len(cases)-1 else '    ')+'IO.print(frame.words('+expr+'))\n';output+=encoded(oracle(d,s,xs))
 save('word-boundaries-'+role,tail,output,'positive-boundary','Arbitrary U32 character words; replacements may be empty or contain the delimiter.')

aliased=[44,65,44,44,66,44]
for role in ('baseline','onepass'):
 expr='frame.join("<> ,", frame.fields(44, input))' if role=='baseline' else 'frame.onepass("<> ,", 44, input)'
 tail='def alias.observe(+input: String) -> IO(Unit):\n  do IO<Unit>:\n    Unit <- IO.print(frame.words(input))\n    Unit <- IO.print(frame.words('+expr+'))\n    IO.print(frame.words(input))\n\ndef main() -> IO(Unit):\n  alias.observe('+text(aliased)+')\n'
 save('alias-'+role,tail,encoded(aliased)+encoded(oracle(44,list(map(ord,'<> ,')),aliased))+encoded(aliased),'positive-shared','Fusion allowed only if both separately observed aliases retain original data and lifetime.')

TAIL='''def observe.count(parts: List<&2, String>) -> Nat:
  match parts:
    case Nil{}: 0n
    case h <> t: Nat.add(1n, observe.count(t))

def main() -> IO(Unit):
  +parts = frame.fields(44, ",a,,b,")
  do IO<Unit>:
    Unit <- IO.print(Nat.show(observe.count(parts)))
    IO.print(frame.words(frame.join("|", parts)))
'''
save('observed-parts',TAIL,'5\n'+encoded(list(map(ord,'|a||b|'))),'negative-single-use','Must retain chunk observation; cannot delete split producer as a single-use fusion.')
TAIL='''def trim.keep(piece: String, tail: List<&2, String>) -> List<&2, String>:
  match piece:
    case SNil{}: tail
    case SCon{c, rest}: SCon{c, rest} <> tail

def trim.parts(parts: List<&2, String>) -> List<&2, String>:
  match parts:
    case Nil{}: Nil{}
    case h <> t: trim.keep(h, trim.parts(t))

def main() -> IO(Unit):
  IO.print(frame.words(frame.join("|", trim.parts(frame.fields(44, ",a,,b,")))))
'''
save('drop-empty-nearmiss',TAIL,encoded(list(map(ord,'a|b'))),'negative-semantics','Cannot bypass trim.parts: ordinary replacement would incorrectly yield |a||b|.')
TAIL='''def changing.render(n: Nat, +block: String) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p:
      separator = Nat.show(n)
      String.append(frame.join(separator, frame.fields(44, block)), changing.render(p, block))

def main() -> IO(Unit):
  IO.print(frame.words(changing.render(3n, ",a,,")))
'''
save('varying-separator',TAIL,encoded(list(map(ord,'3a332a221a11'))),'negative-hoist','Local join/split fusion allowed; replacement varies by iteration, so replace-once then repeat must refuse.')
TAIL='''def effect.blocks(n: Nat, +block: String) -> IO(String):
  match n:
    case 0n: IO.pure(String, SNil{})
    case 1n+p:
      do IO<String>:
        Unit <- IO.print("read")
        tail : String <- effect.blocks(p, block)
        IO.pure(String, String.append(block, tail))

def main() -> IO(Unit):
  do IO<Unit>:
    input : String <- effect.blocks(3n, "|A|")
    IO.print(frame.words(frame.join("--", frame.fields(124, input))))
'''
save('effect-boundary',TAIL,'read\n'*3+encoded(list(map(ord,'--A--'*3))),'negative-effect-motion','May fuse the pure consumer after IO; cannot remove/hoist/deduplicate three observable reads.')
(H/'manifest.json').write_text(json.dumps({'scope':'Authored source/expected-output metadata only. No source checking, compilation, target execution or admission observation has occurred.','fixtures':rows},indent=2)+'\n')
print(len(rows),'fixtures materialized')
