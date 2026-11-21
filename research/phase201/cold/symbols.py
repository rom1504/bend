"""Fuse the ELF builder's name membership, hash and symbol update on its production route."""
from pathlib import Path


def replace_once(source, before, after):
    if source.count(before) != 1:
        raise ValueError("unexpected source shape: " + before[:100])
    return source.replace(before, after)


def apply(source):
    begin = source.index('@unsafe\ndef x187_build_symbol_update(')
    end = source.index('@unsafe\ndef x187_build_relocation(', begin)
    original = source[begin:end]
    fused = replace_once(original, 'def x187_build_symbol_update(', 'def x201s_update(+hash: U32, ')
    fused = replace_once(fused, 'index_hash(name,2166136261),32)', 'hash,32)')
    # On a previously missing name, a mode-4 refusal historically records the
    # unresolved name before reporting the error. Use the original path for it.
    extra = """
@unsafe
def x201s_found(+name: String, +mode: U32, +value: U32, +hash: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,String.eq(dk(old),"Absent"),u =>
        nt_choose(X187Build,U32.is_eq(mode,4),v =>
          x187_build_symbol_known(name,mode,value,x187_build_name(name,build)),v =>
          x201s_update(hash,name,mode,value,X187Build{s,t,r,d,ts,rs,ds,symbols,Con{name,names},relocs,error},
            KDef{name,"X187Sym",0,0,KTerm{"","",0,0,[],[],0,0},atom("Absent"),[],False{},False{}})),
        u => x201s_update(hash,name,mode,value,build,old))

@unsafe
def x201s_symbol(+name: String, mode: U32, value: U32, +hash: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      x201s_found(name,mode,value,hash,build,index_find(symbols,name,hash,32))

"""
    anchor = '@unsafe\ndef x187_build_relocation('
    source = replace_once(source,anchor,fused + extra + anchor)
    hook = '  x187_build_symbol_known(name,mode,value,x187_build_name(name,build))\n'
    return replace_once(source,hook,'  x201s_symbol(name,mode,value,index_hash(name,2166136261),build)\n')
