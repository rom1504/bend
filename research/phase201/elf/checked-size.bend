@unsafe
def x201e_checked_size(bytes: List<&2,U32>, +count: U32) -> U32:
  match bytes:
    case Nil{}: count
    case Con{a,Con{b,Con{c,Con{d,rest}}}}:
      nt_choose(U32,U32.is_le(count,67108860) && U32.is_le(U32.or(U32.or(a,b),U32.or(c,d)),255),
        u => x201e_checked_size(rest,U32.add(count,4)),u => 4294967295)
    case Con{a,rest}:
      nt_choose(U32,U32.is_lt(count,67108864) && U32.is_le(a,255),
        u => x201e_checked_size(rest,U32.inc(count)),u => 4294967295)

@unsafe
def x201e_size_data(object: X187Object, text: U32, rodata: U32, +data: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(data,67108864),
    u => x187_elf_sized(object,X187ElfSizes{text,rodata,data}),
    u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})

@unsafe
def x201e_size_rodata(object: X187Object, data: List<&2,U32>, text: U32, +rodata: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(rodata,67108864),
    u => x201e_size_data(object,text,rodata,x201e_checked_size(data,0)),
    u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})

@unsafe
def x201e_size_text(object: X187Object, rodata: List<&2,U32>, data: List<&2,U32>, +text: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(text,67108864),
    u => x201e_size_rodata(object,data,text,x201e_checked_size(rodata,0)),
    u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})

@unsafe
def x187_elf(+object: X187Object) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,symbols,relocations}:
      x201e_size_text(object,rodata,data,x201e_checked_size(text,0))
