"""Independently authored pure character homomorphism; source/oracle metadata only."""
from pathlib import Path
import hashlib,json,runpy
H=Path(__file__).resolve().parent
# Read shared fixture definitions as source data, avoiding executing its materializer.
import ast
module=ast.parse((H/'build-fixtures.py').read_text())
COMMON=next(ast.literal_eval(n.value) for n in module.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='COMMON' for t in n.targets))
EXTRA='''# Fixed literal expansion by character, with a direct SCon continuation.
# No split, join, delimiter, String.append or captured separator in this encoder.
def wire.prefix(word: U32, rest: String) -> String:
  match word:
    case 0: SCon{Chr{92}, SCon{Chr{48}, rest}}
    case 10: SCon{Chr{92}, SCon{Chr{110}, rest}}
    case 34: SCon{Chr{92}, SCon{Chr{34}, rest}}
    case 92: SCon{Chr{92}, SCon{Chr{92}, rest}}
    case other: SCon{Chr{other}, rest}

def wire.escape(input: String) -> String:
  match input:
    case SNil{}: SNil{}
    case SCon{Chr{raw}, tail}:
      word = {raw : U32}
      wire.prefix(word, wire.escape(tail))

# Consume the complete transformed sequence; no encoded-text output in timing kernel.
def wire.hash(input: String, h: U32) -> U32:
  match input:
    case SNil{}: h
    case SCon{Chr{raw}, tail}:
      word = {raw : U32}
      wire.hash(tail, U32.add(U32.mul(h, 65599), word))
'''
def literal(words):
 out='SNil{}'
 for w in reversed(words):out='SCon{Chr{%d}, %s}'%(w,out)
 return out

def escaped(words):
 table={0:[92,48],10:[92,110],34:[92,34],92:[92,92]}
 return [y for x in words for y in table.get(x,[x])]
def hashword(words):
 h=17
 for x in words:h=(h*65599+x)&0xffffffff
 return h
prefix=[34,115,101,110,115,111,114,34,0,10,92,0x3b1,0x1f6f0]
points=[(0,0),(1,92),(5,0xffffffff),(64,0x10ffff)]
manifest=json.loads((H/'manifest.json').read_text());manifest['fixtures']=[r for r in manifest['fixtures'] if not r['id'].startswith('escape-')]
for role in ['baseline','distributed']:
 body='wire.escape(frame.repeat(n, block))' if role=='baseline' else 'frame.repeat(n, wire.escape(block))'
 source=COMMON+'\n'+EXTRA+'\ndef wire.render(n: Nat, word: U32) -> String:\n  prefix = {'+literal(prefix)+' : String}\n  block = String.append(prefix, SCon{Chr{word}, SNil{}})\n  '+body+'\n\ndef bench(size: U32, seed: U32) -> U32:\n  wire.hash(wire.render(U32.to_nat(size), seed), 17)\n\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'
 calls=[];output=''
 for n,w in points:
  words=escaped((prefix+[w])*n)
  calls+=['IO.print(frame.words(wire.render(%dn, %d)))'%(n,w),'IO.print(U32.show(bench(%d, %d)))'%(n,w)]
  output+=''.join(str(x)+',' for x in words)+'\n'+str(hashword(words))+'\n'
 source+='\n'.join(('    Unit <- ' if i<len(calls)-1 else '    ')+call for i,call in enumerate(calls))+'\n'
 name='escape-'+role;p=H/(name+'.bend');p.write_text(source);e=H/(name+'.stdout');e.write_text(output)
 manifest['fixtures'].append({'id':name,'source':p.name,'expected':e.name,'kind':'independent-pure-homomorphism','admissionExpectation':'Only distributed role moves pure fixed character expansion before repeat; requires separate generic homomorphism certificate.','sourceSha256':hashlib.sha256(p.read_bytes()).hexdigest(),'expectedSha256':hashlib.sha256(e.read_bytes()).hexdigest(),'checked':False,'executed':False})
(H/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(H/'escape-points.json').write_text(json.dumps({'points':[{'size':n,'seed':w,'digest':hashword(escaped((prefix+[w])*n)),'words':len(escaped((prefix+[w])*n))} for n,w in points],'timingEntry':'bench(size: U32, seed: U32) -> U32','scope':'Independent expected full words and hash; no target execution or timing.'},indent=2)+'\n')
