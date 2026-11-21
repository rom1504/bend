"""Shared pinned Base declarations and key literals for Map source-generation experiments."""
from pathlib import Path
import re
from hashlib import sha256

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BASE=ROOT/'selfhost/.bootstrap/upstream-phase182/bend2/base.bend'
SCOPES=('put.go','put','ins.splice','ins.go','ins','seek.go','seek','set.fin.go','set.fin','set.go','set','pop.go','pop','del')
CALL=re.compile(r'\bMap\.('+'|'.join(re.escape(k) for k in sorted(SCOPES,key=len,reverse=True))+r')\(')
EDGE_KEYS=('', 'a\x00b', 'abcdefg', 'abcdefgh', 'abcé', 'xᵢ', 'abcdefg🙂', 'x\x00', 'a\x00\x00b', 'ÿ\x00x')


def pin(file):
    b=file.read_bytes()
    return dict(file=str(file.resolve()),sha256=sha256(b).hexdigest(),bytes=len(b))


def copy_body(text,name):
    pattern=r'^def Map\.'+re.escape(name)+r'\('
    m=re.search(pattern,text,re.M);assert m,name
    chunk=text[m.start():].split('\n\n',1)[0]
    assert chunk.startswith('def ') and '\n  ' in chunk
    return chunk


def edge_generator(keys=EDGE_KEYS):
    def literal(s):
        result='SNil{}'
        for c in reversed(s):result='SCon{Chr{'+str(c if isinstance(c,int) else ord(c))+'}, '+result+'}'
        return result
    result=[]
    for i,key in enumerate(keys[:-1]):
        rest=f'kp.edge{i+1}(p)' if i+1<len(keys)-1 else literal(keys[-1])
        result.append(f'def kp.edge{i}(n: Nat) -> String:\n  match n:\n    case 0n: {literal(key)}\n    case 1n+p: {rest}')
    return '\n\n'.join(reversed(result))+'\n\n'
