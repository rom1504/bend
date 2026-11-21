@unsafe
def x201e_layout_bytes(bytes: List<&2,U32>, +size: U32, body: List<&2,U32>,
    +start: U32, meta: X187ElfSection, rest: List<&2,X187ElfSection>, headers: List<&2,U32>) -> X187ElfLayout:
  match bytes:
    case Nil{}:
      x187_elf_layout(rest,X187ElfLayout{U32.add(start,size),body,
        nt_reverse(U32,x187_elf_section_header(meta,start,size),headers)})
    case Con{a,Con{b,Con{c,Con{d,more}}}}:
      x201e_layout_bytes(more,U32.add(size,4),Con{d,Con{c,Con{b,Con{a,body}}}},start,meta,rest,headers)
    case Con{a,more}:
      x201e_layout_bytes(more,U32.inc(size),Con{a,body},start,meta,rest,headers)

@unsafe
def x187_elf_layout_step(head, rest, layout):
  match head layout:
    case X187ElfSection{name,kind,flags,+alignment,entry,link,info,bytes} X187ElfLayout{+offset,body,headers}:
      +start = x187_elf_align(offset,alignment)
      x201e_layout_bytes(bytes,0,x187_elf_zero(U32.sub(start,offset),body),start,
        X187ElfSection{name,kind,flags,alignment,entry,link,info,[]},rest,headers)
