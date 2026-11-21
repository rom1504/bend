"""Materialize the validated Phase201 workload with old and segmented writer entrypoints."""
from pathlib import Path
import sys, argparse, json
from prepare import apply,BASE,ROOT,source
sys.path.insert(0,str(ROOT/'research/phase201/elf'))
import standalone

def run(out):
    out.mkdir(parents=True,exist_ok=False);old=BASE.read_bytes();new=apply(old);records={}
    for name,data,finish in [('old',old,'x201f_finish'),('new',new,'x202p_x201f_finish')]:
        h=standalone.harness(finish)
        if name=='new':
            before=b'x187_print_result(x201b_start(x187_build_name("external",x187_build_symbol(".Ltarget",1,0,x187_build_empty()))))';assert h.count(before)==1
            h=h.replace(before,b'x201b_start(x187_build_name("external",x187_build_symbol(".Ltarget",1,0,x187_build_empty())))').replace(b'X187ObjectResult',b'IO(U32)')
        src,n=standalone.slice_source(data,h);f=out/(name+'.bend');f.write_bytes(src);records[name]=dict(parentSha256=standalone.hashlib.sha256(data).hexdigest(),standalone=source.pin(f),declarations=n)
    (out/'report.json').write_text(json.dumps(records,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);run(p.parse_args().out)
