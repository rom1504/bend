"""Lift the frozen production writer to IO, leaving all original pure object API definitions intact."""
from pathlib import Path
import sys,re,hashlib,json,argparse
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source
BASE=ROOT/'selfhost/build/phase201/source02/compiler.bend'
NAMES='x187_elf_sections x187_elf_checked x187_elf_sized x201e_size_data x201e_size_rodata x201e_size_text x187_elf x187_build_symbols x187_build_symbol_final x188_build_symbol_checked x188_build_patched x201f_fixups x201f_finish x187_cursor x187_cursor_good x187_prepared'.split()
PAT=re.compile(rb'\b('+b'|'.join(n.encode() for n in NAMES)+rb')\b')

def apply(data):
    assert b'x202e_write(' not in data
    rows={r['name']:r for r in source.blocks(data)[1] if r['kind']=='def'};bodies=[]
    for key in NAMES:
        row=rows[key];body=row['data'][row['headerOffset']-row['offset']:].strip()
        body=PAT.sub(lambda m:b'x202p_'+m[0],body)
        if key=='x187_elf_sections':
            old=b'x187_elf_finish(x187_elf_layout([';assert body.count(old)==1;body=body.replace(old,b'x202e_plan([')
            old=b'],X187ElfLayout{64,[],x187_elf_zero(64,[])}))';assert body.count(old)==1;body=body.replace(old,b'],64,[],x187_elf_zero(64,[]))')
        body=re.sub(rb'X187ObjectResult\{\[\],([^{}]+?)\}',rb'IO.die(U32,1,\1)',body)
        assert b'X187ObjectResult{' not in body
        body=body.replace(b'X187ObjectResult',b'IO(U32)');bodies.append(body)
    old=b'x187_print_result(x187_prepared(prepared))';assert data.count(old)==1
    idx=rows['x187_print']['offset'];out=data[:idx]+b'\n'+(HERE/'parts.bend').read_bytes()+b'\n\n'+b'\n\n'.join(bodies)+b'\n'+data[idx:].replace(old,b'x202p_x187_prepared(prepared)',1)
    return out

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--source',type=Path,default=BASE);p.add_argument('--out',type=Path,required=True);a=p.parse_args();d=apply(a.source.read_bytes());a.out.mkdir(parents=True,exist_ok=False);q=a.out/'compiler.bend';q.write_bytes(d);print(source.pin(q))
