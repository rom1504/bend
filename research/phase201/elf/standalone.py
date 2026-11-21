"""Extract and stage a native old/new ELF writer microbenchmark without running either compiler."""
import argparse,hashlib,json,re,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source

BASE=ROOT/'selfhost/build/phase198/progress-portfolio01/compiler.bend'
CAND=ROOT/'selfhost/build/phase201/source02/compiler.bend'
N=4096
ROW=bytes(8)+bytes(range(8,64))

def harness(finish):
    body='acc'
    for b in ROW:body='Con{'+str(b)+','+body+'}'
    return ('''
@unsafe
def x201b_row(acc: List<&2,U32>) -> List<&2,U32>:
  '''+body+'''

@unsafe
def x201b_work(+i: U32, raw: List<&2,U32>, relocs: List<&2,X187Relocation>, index: KDef, names: List<&2,String>) -> X187ObjectResult:
  match i:
    case '''+str(N)+''': '''+finish+'''(X187Build{1,raw,[],[],'''+str(N*64)+''',0,0,index,names,relocs,""})
    case _:
      +off = U32.mul(i,64)
      x201b_work(U32.inc(i),x201b_row(raw),Con{X187Relocation{1,U32.add(off,4),4,"external",4294967292,4294967295},
        Con{X187Relocation{1,off,130,".Ltarget",4294967292,4294967295},relocs}},index,names)

@unsafe
def x201b_start(build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,index,names,relocs,error}: x201b_work(0,[],[],index,names)

@unsafe
def main() -> IO(U32):
  x187_print_result(x201b_start(x187_build_name("external",x187_build_symbol(".Ltarget",1,0,x187_build_empty()))))
''').encode()

TOKEN=re.compile(rb'[A-Za-z_][A-Za-z0-9_.]*')
STR=re.compile(rb'"(?:\\.|[^"\\])*"|#[^\n]*')

def slice_source(raw,h):
    rows=source.blocks(raw)[1];ids={};keys={};
    for i,r in enumerate(rows):
        keys.setdefault(r['name'].encode(),[]).append(i)
        if r['kind']=='type':
            for c in re.findall(rb'(?m)^  ([A-Za-z_][A-Za-z0-9_.]*)\{',r['data']):keys.setdefault(c,[]).append(i)
    seen=set();queue=[h];
    while queue:
        new=queue.pop()
        for token in set(TOKEN.findall(STR.sub(b' ',new))):
            if token==b'main':continue
            for i in keys.get(token,[]):
                if i not in seen:seen.add(i);queue.append(rows[i]['data'])
    return b'import Base\n\n'+b'\n'.join(rows[i]['data'] for i in sorted(seen))+h,len(seen)


def run(out):
    out.mkdir(parents=True,exist_ok=False);report={}
    for name,src,finish in [('old',BASE,'x187_build_finish'),('new',CAND,'x201f_finish')]:
        raw=src.read_bytes();data,n=slice_source(raw,harness(finish));p=out/(name+'.bend');p.write_bytes(data);report[name]=dict(parent=source.pin(src),standalone=source.pin(p),declarations=n,finish=finish)
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);run(p.parse_args().out)
