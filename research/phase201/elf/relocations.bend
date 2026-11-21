def x201e_u32_reverse(+value: U32, tail: List<&2,U32>) -> List<&2,U32>:
  Con{U32.shrn(value,24n),Con{U32.and(U32.shrn(value,16n),255),
    Con{U32.and(U32.shrn(value,8n),255),Con{U32.and(value,255),tail}}}}

@unsafe
def x187_elf_reloc_step(head, rest, section, index, acc):
  match head:
    case X187Relocation{current,offset,kind,symbol,lo,hi}:
      x187_elf_relocs(rest,section,index,nt_choose(List<&2,U32>,U32.is_eq(current,section),
        u => x201e_u32_reverse(hi,x201e_u32_reverse(lo,x201e_u32_reverse(da(p111v_get(index,symbol)),
          x201e_u32_reverse(kind,Con{0,Con{0,Con{0,Con{0,x201e_u32_reverse(offset,acc)}}}})))),u => acc))
