"""Stage standalone old/new decoder controls and timing workloads; never execute targets."""
import argparse,hashlib,importlib.util,json,re,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(HERE));from oracle import cases,table,mix
spec=importlib.util.spec_from_file_location('elf_standalone',ROOT/'research/phase201/elf/standalone.py');s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
spec=importlib.util.spec_from_file_location('opcode_prepare',HERE/'prepare.py');p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)

def string(x):
    if '\0' not in x:return json.dumps(x,ensure_ascii=False)
    body='SNil{}'
    for c in reversed(x):body='SCon{Char.from_u32('+str(ord(c))+'),'+body+'}'
    return body

def harness(rounds):
    rows=cases();parts=[]
    # Bounded 24-case declarations keep typechecker expression depth modest.
    for start in range(0,len(rows),24):
        body='p202o_cases_'+str(start+24)+'()' if start+24<len(rows) else 'Nil{}'
        for name,fields in reversed(rows[start:start+24]):body='Con{P202OCase{'+string(name)+','+','.join(map(str,fields))+'},'+body+'}'
        parts.append('def p202o_cases_'+str(start)+'() -> List<&2,P202OCase>:\n  '+body+'\n')
    return ('''
type P202OCase is Data:
  P202OCase{+name: String, +family: U32, +width: U32, +code: U32, +extra: U32, +prefix: U32}
type P202OResult is Data:
  P202OResult{bad: U32, hash: U32}
def p202o_mix(acc: U32, word: U32) -> U32:
  U32.mul(U32.xor(acc,word),16777619)
def p202o_fields(+f: U32,+w: U32,+c: U32,+e: U32,+p: U32, expected: P202OCase, bad: U32, hash: U32) -> P202OResult:
  match expected:
    case P202OCase{name,ef,ew,ec,ee,ep}:
      P202OResult{U32.add(bad,nt_choose(U32,U32.is_eq(f,ef) && U32.is_eq(w,ew) && U32.is_eq(c,ec) && U32.is_eq(e,ee) && U32.is_eq(p,ep),u => 0,u => 1)),p202o_mix(p202o_mix(p202o_mix(p202o_mix(p202o_mix(hash,f),w),c),e),p)}
def p202o_observe(value: X187Op, expected: P202OCase, bad: U32, hash: U32) -> P202OResult:
  match value:
    case X187OpNone{}: p202o_fields(0,0,0,0,0,expected,bad,hash)
    case X187Op{f,w,c,e,p}: p202o_fields(f,w,c,e,p,expected,bad,hash)
def p202o_rows(rows: List<&2,P202OCase>, bad: U32, hash: U32) -> P202OResult:
  match rows:
    case Nil{}: P202OResult{bad,hash}
    case Con{+head,tail}:
      match head:
        case P202OCase{name,f,w,c,e,p}:
          p202o_rows_next(tail,p202o_observe(x187_e_spec(name),head,bad,hash))
def p202o_rows_next(tail: List<&2,P202OCase>, result: P202OResult) -> P202OResult:
  match result:
    case P202OResult{next,acc}: p202o_rows(tail,next,acc)
def p202o_loop(n: U32,+rows: List<&2,P202OCase>,bad: U32,hash: U32) -> P202OResult:
  match n:
    case 0: P202OResult{bad,hash}
    case _:
      p202o_loop_next(U32.sub(n,1),rows,p202o_rows(rows,bad,hash))
def p202o_loop_next(n: U32,rows: List<&2,P202OCase>,result: P202OResult) -> P202OResult:
  match result:
    case P202OResult{next,acc}: p202o_loop(n,rows,next,acc)
'''+ '\n'.join(parts)+f'''
def p202o_print(result: P202OResult) -> IO(Unit):
  match result:
    case P202OResult{{bad,hash}}:
      do IO<Unit>:
        Unit <- IO.print(U32.show(bad))
        IO.print(U32.show(hash))
def main() -> IO(Unit):
  p202o_print(p202o_loop({rounds},p202o_cases_0(),0,2166136261))
''').encode()

def run(a):
    raw=a.source.read_text();a.out.mkdir(parents=True,exist_ok=False)
    # Independently reject missing/additional spellings before target work.
    decls=p.declaration(raw,'x187_e_spec')+p.declaration(raw,'x191cm_spec')
    names=set(re.findall(r'String.eq\(op,"([^"]+)"\)',decls));assert names==set(table()),(names-set(table()),set(table())-names)
    expected=2166136261
    for _ in range(a.rounds):
        for _,fields in cases():expected=mix(expected,fields)
    report=dict(complete=True,status='offline preparation only',caseCount=len(cases()),validSpellings=len(table()),rounds=a.rounds,expectedStdout=f'0\n{expected}\n',cases=cases(),roles={})
    for role,text in [('old',raw),('new',p.apply(raw))]:
        rows=s.source.blocks(text.encode())[1]; selected=[r['data'] for r in rows if r['name'] in ('nt_choose','X187Op','x187_e_spec','x191cm_spec','x202o_dispatch')]; assert len(selected)==(4 if role=='old' else 5); h=re.sub(rb'(?m)^def ',b'@unsafe\ndef ',harness(a.rounds)); data=b'import Base\n\n'+b'\n'.join(selected)+h; n=len(selected); dst=a.out/(role+'.bend');dst.write_bytes(data)
        report['roles'][role]=dict(file=str(dst.resolve()),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data),declarations=n)
    report['parent']=dict(file=str(a.source.resolve()),sha256=hashlib.sha256(raw.encode()).hexdigest())
    report['methods']={name:hashlib.sha256((HERE/name).read_bytes()).hexdigest() for name in ['prepare.py','standalone.py','oracle.py','screen.py']}
    (a.out/'report.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');print(json.dumps({k:v for k,v in report.items() if k not in ('cases','roles')}))
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--source',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--rounds',type=int,default=32);run(ap.parse_args())
