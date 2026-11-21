"""Overlay sized section planning on the separately retained segmented writer."""
from pathlib import Path
import argparse,json,sys
from prepare import apply as segmented,BASE,HERE,ROOT,source
from focus import standalone

def apply(source_bytes):
    raw=segmented(source_bytes);rows={r['name']:r for r in source.blocks(raw)[1] if r['kind']=='def'}
    def subonce(src,before,after):
        assert src.count(before)==1,before
        return src.replace(before,after,1)
    a=rows['x202p_x187_elf_sections'];old=a['data'];new=subonce(old,b'symbols: X187ElfSymbols) -> IO(U32)',b'symbols: X187ElfSymbols, rawSizes: X187ElfSizes) -> IO(U32)')
    begin=new.index(b'nt_reverse(U32,x187_elf_ascii(');end=new.index(b',[])',new.index(b'",[])',begin)+4)+4;expr=new[begin:end];assert expr.startswith(b'nt_reverse(U32,x187_elf_ascii(') and expr.endswith(b'",[]),[])'),expr
    new=subonce(new,expr,b'sectionNames');new=subonce(new,b'x202e_plan([',b'+sectionNames = '+expr+b'\n      x202t_plan([');new=subonce(new,b'],64,[],x187_elf_zero(64,[]))',b'],x202t_sizes(rawSizes,x202t_rela_counts(relocations,0,0,0),count,stringSize,nt_count(U32,sectionNames)),64,[],x187_elf_zero(64,[]))')
    raw=subonce(raw,old,b'\n'+(HERE/'sized.bend').read_bytes()+b'\n'+new);raw=subonce(raw,b'x202p_x187_elf_sections(object,symbols)',b'x202p_x187_elf_sections(object,symbols,sizes)');return raw

def run(out,fixture):
    raw=BASE.read_bytes();new=apply(raw);out.mkdir(parents=True,exist_ok=False);q=out/'compiler.bend';q.write_bytes(new)
    if fixture:
        import focus
        focus.apply=apply;focus.run(fixture)
    print(source.pin(q))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--fixture',type=Path);a=p.parse_args();run(a.out,a.fixture)
