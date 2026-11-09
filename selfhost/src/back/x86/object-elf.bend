# ELF64 little-endian ET_REL for AMD64. The encoder supplies actual bytes and
# named RELA records; this module neither parses assembly nor selects opcodes.
# Section identities are fixed: 1=text, 2=rodata, 3=data. Symbol values and
# relocation offsets are section-relative. Addends retain all 64 raw bits.
# Section base alignments are fixed at 16/8/8. The builder must refuse input
# requesting stronger alignment; byte padding alone cannot promise that ABI.
# Limits keep every file offset below U32 overflow; ELF fields remain 64-bit.
type X187ElfSizes is Data:
  X187ElfSizes{+text: U32, +rodata: U32, +data: U32}

type X187ElfSymbols is Data:
  X187ElfSymbols{+index: KDef, +count: U32, +firstGlobal: U32,
    +table: List<&2,U32>, +strings: List<&2,U32>, +stringSize: U32, +error: String}

type X187ElfSection is Data:
  X187ElfSection{+name: U32, +kind: U32, +flags: U32, +alignment: U32,
    +entry: U32, +link: U32, +info: U32, +bytes: List<&2,U32>}

type X187ElfLayout is Data:
  X187ElfLayout{+offset: U32, +body: List<&2,U32>, +headers: List<&2,U32>}

law x187_elf_symbols_step:
  for +head: X187Symbol
  for +rest: List<&2,X187Symbol>
  for +globals: Bool
  for +sizes: X187ElfSizes
  for +state: X187ElfSymbols
  X187ElfSymbols
law x187_elf_reloc_step:
  for +head: X187Relocation
  for +rest: List<&2,X187Relocation>
  for +section: U32
  for +index: KDef
  for +acc: List<&2,U32>
  List<&2,U32>
law x187_elf_layout_step:
  for +head: X187ElfSection
  for +rest: List<&2,X187ElfSection>
  for +layout: X187ElfLayout
  X187ElfLayout

@unsafe
def x187_elf_cat(a: List<&2,U32>, b: List<&2,U32>) -> List<&2,U32>:
  nt_append(U32,a,b)

@unsafe
def x187_elf_zero(+count: U32, +tail: List<&2,U32>) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(count,0),u => tail,
    u => x187_elf_zero(U32.sub(count,1),Con{0,tail}))

def x187_elf_u16(+value: U32) -> List<&2,U32>:
  [U32.and(value,255),U32.and(U32.shrn(value,8n),255)]

def x187_elf_u32(+value: U32) -> List<&2,U32>:
  [U32.and(value,255),U32.and(U32.shrn(value,8n),255),
   U32.and(U32.shrn(value,16n),255),U32.shrn(value,24n)]

@unsafe
def x187_elf_u64(lo: U32, hi: U32) -> List<&2,U32>:
  x187_elf_cat(x187_elf_u32(lo),x187_elf_u32(hi))

@unsafe
def x187_elf_bytes(bytes: List<&2,U32>, +count: U32) -> Bool:
  match bytes:
    case Nil{}: True{}
    case Con{head,rest}: U32.is_le(head,255) && U32.is_lt(count,67108864) &&
      x187_elf_bytes(rest,U32.inc(count))

@unsafe
def x187_elf_name(name: String, +count: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(count,0)
    case SCon{+head,rest}: U32.is_lt(count,4096) && U32.is_gt(Char.to_u32(head),0) &&
      U32.is_lt(Char.to_u32(head),128) && x187_elf_name(rest,U32.inc(count))

@unsafe
def x187_elf_ascii(text: String, acc: List<&2,U32>) -> List<&2,U32>:
  match text:
    case SNil{}: acc
    case SCon{head,rest}: x187_elf_ascii(rest,Con{Char.to_u32(head),acc})

@unsafe
def x187_elf_section_size(+section: U32, sizes: X187ElfSizes) -> U32:
  match sizes:
    case X187ElfSizes{text,rodata,data}:
      nt_choose(U32,U32.is_eq(section,1),u => text,
        u => nt_choose(U32,U32.is_eq(section,2),v => rodata,
          v => nt_choose(U32,U32.is_eq(section,3),w => data,w => 0)))

@unsafe
def x187_elf_symbol_valid(symbol: X187Symbol, sizes: X187ElfSizes) -> Bool:
  match symbol:
    case X187Symbol{+name,+section,+value,+size,+global,kind}:
      +limit = x187_elf_section_size(section,sizes)
      x187_elf_name(name,0) && U32.is_le(section,3) && U32.is_le(kind,2) &&
        U32.is_le(value,limit) && U32.is_le(size,U32.sub(limit,value)) &&
        (Bool.not(U32.is_eq(section,0)) || (global && U32.is_eq(value,0) && U32.is_eq(size,0)))

@unsafe
def x187_elf_symbol_bytes(symbol: X187Symbol, nameOffset: U32) -> List<&2,U32>:
  match symbol:
    case X187Symbol{name,section,value,size,global,kind}:
      x187_elf_cat(x187_elf_u32(nameOffset),
        Con{U32.add(kind,nt_choose(U32,global,u => 16,u => 0)),Con{0,
          x187_elf_cat(x187_elf_u16(section),
            x187_elf_cat(x187_elf_u64(value,0),x187_elf_u64(size,0)))}})

@unsafe
def x187_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,section,value,size,global,kind}
      X187ElfSymbols{+index,+count,+firstGlobal,+table,+strings,+stringSize,+error}:
      +encoded = x187_elf_ascii(name,[])
      +length = U32.inc(nt_count(U32,encoded))
      nt_choose(X187ElfSymbols,String.is_empty(error) && x187_elf_symbol_valid(symbol,sizes) &&
          String.eq(dk(p111v_get(index,name)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p111v_put(index,name,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          nt_reverse(U32,x187_elf_symbol_bytes(symbol,stringSize),table),
          Con{0,x187_elf_cat(encoded,strings)},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})

@unsafe
def x187_elf_symbols(items: List<&2,X187Symbol>, +globals: Bool, +sizes: X187ElfSizes,
    +state: X187ElfSymbols) -> X187ElfSymbols:
  match items:
    case Nil{}: state
    case Con{+head,rest}:
      x187_elf_symbols_step(head,rest,globals,sizes,state)

@unsafe
def x187_elf_symbols_step(head, rest, globals, sizes, state):
  match head:
    case X187Symbol{name,section,value,size,+global,kind}:
      x187_elf_symbols(rest,globals,sizes,
        nt_choose(X187ElfSymbols,(global && globals) || (Bool.not(global) && Bool.not(globals)),
          u => x187_elf_symbol_add(head,sizes,state),u => state))

@unsafe
def x187_elf_globals(items: List<&2,X187Symbol>, sizes: X187ElfSizes, state: X187ElfSymbols) -> X187ElfSymbols:
  match state:
    case X187ElfSymbols{index,+count,firstGlobal,table,strings,stringSize,error}:
      x187_elf_symbols(items,True{},sizes,X187ElfSymbols{index,count,count,table,strings,stringSize,error})

@unsafe
def x187_elf_reloc_valid(relocation: X187Relocation, +sizes: X187ElfSizes, +index: KDef) -> Bool:
  match relocation:
    case X187Relocation{+section,+offset,+kind,symbol,addendLo,addendHi}:
      +limit = x187_elf_section_size(section,sizes)
      +width = nt_choose(U32,U32.is_eq(kind,1),u => 8,u => 4)
      U32.is_ge(section,1) && U32.is_le(section,3) &&
        (U32.is_eq(kind,1) || U32.is_eq(kind,2) || U32.is_eq(kind,4)) &&
        U32.is_le(offset,limit) && U32.is_le(width,U32.sub(limit,offset)) &&
        String.eq(dk(p111v_get(index,symbol)),"X187Symbol")

@unsafe
def x187_elf_relocs_valid(items: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{head,rest}: U32.is_lt(count,1048576) && x187_elf_reloc_valid(head,sizes,index) &&
      x187_elf_relocs_valid(rest,sizes,index,U32.inc(count))

@unsafe
def x187_elf_reloc_bytes(relocation: X187Relocation, index: KDef) -> List<&2,U32>:
  match relocation:
    case X187Relocation{section,offset,kind,symbol,lo,hi}:
      x187_elf_cat(x187_elf_u64(offset,0),
        x187_elf_cat(x187_elf_u64(kind,da(p111v_get(index,symbol))),x187_elf_u64(lo,hi)))

@unsafe
def x187_elf_relocs(items: List<&2,X187Relocation>, +section: U32, +index: KDef, acc: List<&2,U32>) -> List<&2,U32>:
  match items:
    case Nil{}: nt_reverse(U32,acc,[])
    case Con{+head,rest}: x187_elf_reloc_step(head,rest,section,index,acc)

@unsafe
def x187_elf_reloc_step(head, rest, section, index, acc):
  match head:
    case X187Relocation{current,offset,kind,symbol,lo,hi}:
      x187_elf_relocs(rest,section,index,nt_choose(List<&2,U32>,U32.is_eq(current,section),
        u => nt_reverse(U32,x187_elf_reloc_bytes(head,index),acc),u => acc))

@unsafe
def x187_elf_section_header(section: X187ElfSection, offset: U32, size: U32) -> List<&2,U32>:
  match section:
    case X187ElfSection{name,kind,flags,alignment,entry,link,info,bytes}:
      x187_elf_cat(x187_elf_u32(name),x187_elf_cat(x187_elf_u32(kind),
      x187_elf_cat(x187_elf_u64(flags,0),x187_elf_cat(x187_elf_u64(0,0),
      x187_elf_cat(x187_elf_u64(offset,0),x187_elf_cat(x187_elf_u64(size,0),
      x187_elf_cat(x187_elf_u32(link),x187_elf_cat(x187_elf_u32(info),
      x187_elf_cat(x187_elf_u64(alignment,0),x187_elf_u64(entry,0))))))))))

def x187_elf_align(+offset: U32, +alignment: U32) -> U32:
  U32.and(U32.add(offset,U32.sub(alignment,1)),U32.xor(U32.sub(alignment,1),4294967295))

@unsafe
def x187_elf_layout(sections: List<&2,X187ElfSection>, layout: X187ElfLayout) -> X187ElfLayout:
  match sections:
    case Nil{}: layout
    case Con{head,rest}: x187_elf_layout_step(head,rest,layout)

@unsafe
def x187_elf_layout_step(head, rest, layout):
  match head layout:
    case X187ElfSection{name,kind,flags,alignment,entry,link,info,+bytes} X187ElfLayout{+offset,body,headers}:
      +start = x187_elf_align(offset,alignment)
      +size = nt_count(U32,bytes)
      x187_elf_layout(rest,X187ElfLayout{U32.add(start,size),
        nt_reverse(U32,bytes,x187_elf_zero(U32.sub(start,offset),body)),
        nt_reverse(U32,x187_elf_section_header(head,start,size),headers)})

@unsafe
def x187_elf_header(sectionOffset: U32) -> List<&2,U32>:
  x187_elf_cat([127,69,76,70,2,1,1,0,0,0,0,0,0,0,0,0,1,0,62,0,1,0,0,0],
    x187_elf_cat(x187_elf_zero(16,[]),x187_elf_cat(x187_elf_u64(sectionOffset,0),
      [0,0,0,0,64,0,0,0,0,0,64,0,11,0,9,0])))

@unsafe
def x187_elf_finish(layout: X187ElfLayout) -> X187ObjectResult:
  match layout:
    case X187ElfLayout{+offset,body,headers}:
      +sectionOffset = x187_elf_align(offset,8)
      X187ObjectResult{x187_elf_cat(x187_elf_header(sectionOffset),
        nt_reverse(U32,body,x187_elf_zero(U32.sub(sectionOffset,offset),nt_reverse(U32,headers,[])))),""}

@unsafe
def x187_elf_sections(object: X187Object, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object symbols:
    case X187Object{text,rodata,data,items,+relocations}
      X187ElfSymbols{+index,count,firstGlobal,table,strings,stringSize,error}:
      x187_elf_finish(x187_elf_layout([
        X187ElfSection{1,1,6,16,0,0,0,text},
        X187ElfSection{7,1,2,8,0,0,0,rodata},
        X187ElfSection{15,1,3,8,0,0,0,data},
        X187ElfSection{21,4,0,8,24,7,1,x187_elf_relocs(relocations,1,index,[])},
        X187ElfSection{32,4,0,8,24,7,2,x187_elf_relocs(relocations,2,index,[])},
        X187ElfSection{45,4,0,8,24,7,3,x187_elf_relocs(relocations,3,index,[])},
        X187ElfSection{56,2,0,8,24,8,firstGlobal,nt_reverse(U32,table,[])},
        X187ElfSection{64,3,0,1,0,0,0,nt_reverse(U32,strings,[])},
        X187ElfSection{72,3,0,1,0,0,0,nt_reverse(U32,x187_elf_ascii(
          "\0.text\0.rodata\0.data\0.rela.text\0.rela.rodata\0.rela.data\0.symtab\0.strtab\0.shstrtab\0.note.GNU-stack\0",[]),[])},
        X187ElfSection{82,1,0,1,0,0,0,[]}],X187ElfLayout{64,[],x187_elf_zero(64,[])}))

@unsafe
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error) && x187_elf_relocs_valid(relocations,sizes,index,0),
        u => x187_elf_sections(object,symbols),
        u => X187ObjectResult{[],p111_first(error,"invalid ELF relocation")})

@unsafe
def x187_elf_sized(+object: X187Object, +sizes: X187ElfSizes) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,+symbols,relocations}:
      x187_elf_checked(object,sizes,x187_elf_globals(symbols,sizes,
        x187_elf_symbols(symbols,False{},sizes,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})))

@unsafe
def x187_elf(+object: X187Object) -> X187ObjectResult:
  match object:
    case X187Object{+text,+rodata,+data,symbols,relocations}:
      nt_choose(X187ObjectResult,x187_elf_bytes(text,0) && x187_elf_bytes(rodata,0) && x187_elf_bytes(data,0),
        u => x187_elf_sized(object,X187ElfSizes{nt_count(U32,text),nt_count(U32,rodata),nt_count(U32,data)}),
        u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})
