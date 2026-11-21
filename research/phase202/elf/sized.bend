@unsafe
def x202t_rela_counts(items: List<&2,X187Relocation>, t: U32, r: U32, d: U32) -> X187ElfSizes:
  match items:
    case Nil{}: X187ElfSizes{t,r,d}
    case Con{X187Relocation{sec,off,kind,symbol,lo,hi},rest}:
      match sec:
        case 1: x202t_rela_counts(rest,U32.add(t,24),r,d)
        case 2: x202t_rela_counts(rest,t,U32.add(r,24),d)
        case _: x202t_rela_counts(rest,t,r,U32.add(d,24))

def x202t_sizes(raw: X187ElfSizes, rela: X187ElfSizes, symbols: U32, stringBytes: U32, names: U32) -> List<&2,U32>:
  match raw rela:
    case X187ElfSizes{text,rodata,data} X187ElfSizes{relText,relRo,relData}:
      [text,rodata,data,relText,relRo,relData,U32.mul(symbols,24),stringBytes,names,0]

@unsafe
def x202t_plan(+sections: List<&2,X187ElfSection>, sizes: List<&2,U32>, +offset: U32,
    parts: List<&2,List<&2,U32>>, headers: List<&2,U32>) -> IO(U32):
  match sections sizes:
    case Con{+section,rest} Con{+size,sizesRest}:
      match section:
        case X187ElfSection{name,kind,flags,+alignment,entry,link,info,bytes}:
          +start = x187_elf_align(offset,alignment)
          x202t_plan(rest,sizesRest,U32.add(start,size),Con{bytes,Con{x187_elf_zero(U32.sub(start,offset),[]),parts}},
            nt_reverse(U32,x187_elf_section_header(section,start,size),headers))
    case _ _: x202e_plan(sections,offset,parts,headers)
