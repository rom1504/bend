# Direct machine-fragment object route. Selection supplies typed instructions
# and data; production never renders or parses assembly. The text parser below
# remains a diagnostic entry only. Section buffers are explicitly bounded.

type X187Build is Data:
  X187Build{+section: U32, +text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +textSize: U32, +rodataSize: U32, +dataSize: U32, +symbols: KDef,
    +names: List<&2,String>, +relocations: List<&2,X187Relocation>, +error: String}

type X188Fixups is Data:
  X188Fixups{+patches: List<&2,X187Relocation>, +relocations: List<&2,X187Relocation>,
    +escaped: KDef, +error: String}

def x187_build_empty() -> X187Build:
  X187Build{1,[],[],[],0,0,0,missing(),[],[],""}

def x187_build_error(+error: String, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,old}:
      X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,p111_first(old,error)}

def x187_build_offset(+build: X187Build) -> U32:
  match build:
    case X187Build{section,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      match section:
        case 1: ts
        case 2: rs
        case _: ds

@unsafe
def x187_build_bytes(+bytes: List<&2,U32>, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+section,t,r,d,+ts,+rs,+ds,symbols,names,relocs,error}:
      +count = nt_count(U32,bytes)
      nt_choose(X187Build,U32.is_gt(count,33554432) || U32.is_gt(x187_build_offset(build),U32.sub(33554432,count)),
        u => x187_build_error("x86 object section exceeds 32 MiB bound",build),u =>
      nt_choose(X187Build,U32.is_eq(section,1),
        v => X187Build{section,nt_reverse(U32,bytes,t),r,d,U32.add(ts,count),rs,ds,symbols,names,relocs,error},v =>
      nt_choose(X187Build,U32.is_eq(section,2),
        w => X187Build{section,t,nt_reverse(U32,bytes,r),d,ts,U32.add(rs,count),ds,symbols,names,relocs,error},w =>
      nt_choose(X187Build,U32.is_eq(section,3),
        z => X187Build{section,t,r,nt_reverse(U32,bytes,d),ts,rs,U32.add(ds,count),symbols,names,relocs,error},
        z => x187_build_error("invalid object section",build)))))

# Symbol fields: arity=section, templates=value, typ.id=size, typ.quant=kind,
# native=global, unsafe=defined. Every name is entered once, definitions may
# follow references. Duplicate definitions and unresolved local labels fail.
@unsafe
def x187_build_name(+name: String, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,+symbols,names,relocs,error}:
      nt_choose(X187Build,String.eq(dk(p111v_get(symbols,name)),"Absent"),
        u => X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",0,0,KTerm{"","",0,0,[],[],0,0},atom("Absent"),[],False{},False{}},
          index_hash(name,2166136261),32),Con{name,names},relocs,error},u => build)

@unsafe
def x187_build_symbol(+name: String, +mode: U32, +value: U32, +build: X187Build) -> X187Build:
  x187_build_symbol_known(name,mode,value,x187_build_name(name,build))

@unsafe
def x187_build_symbol_known(+name: String, +mode: U32, +value: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{+s,t,r,d,ts,rs,ds,+symbols,names,relocs,error}:
      x187_build_symbol_update(name,mode,value,build,p111v_get(symbols,name))

@unsafe
def x187_build_symbol_update(+name: String, +mode: U32, +value: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build old:
    case X187Build{+s,t,r,d,ts,rs,ds,symbols,names,relocs,error}
      KDef{on,ok,+section,+offset,KTerm{tk,tn,+size,+kind,kids,removed,begin,end},ov,oc,+global,+defined}:
      nt_choose(X187Build,(U32.is_eq(mode,1) && defined) ||
          (U32.is_eq(mode,4) && (Bool.not(defined) || Bool.not(U32.is_eq(s,section)) || U32.is_lt(x187_build_offset(build),offset))),
        u => x187_build_error("duplicate symbol or invalid size: " ++ name,build),u =>
        X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",nt_choose(U32,U32.is_eq(mode,1),v => s,v => section),
            nt_choose(U32,U32.is_eq(mode,1),v => x187_build_offset(build),v => offset),
            KTerm{"","",nt_choose(U32,U32.is_eq(mode,4),v => U32.sub(x187_build_offset(build),offset),v => size),
              nt_choose(U32,U32.is_eq(mode,3),v => value,v => kind),[],[],0,0},atom("Absent"),[],
            global || U32.is_eq(mode,2),defined || U32.is_eq(mode,1)},index_hash(name,2166136261),32),names,relocs,error})
    case _ _: x187_build_error("invalid object symbol record",build)

@unsafe
def x187_build_relocation(+reloc: X187Relocation, +build: X187Build) -> X187Build:
  match reloc:
    case X187Relocation{s,o,k,name,lo,hi}: x187_build_relocation_known(reloc,x187_build_name(name,build))

def x187_build_relocation_known(+reloc: X187Relocation, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      X187Build{s,t,r,d,ts,rs,ds,symbols,names,Con{reloc,relocs},error}

@unsafe
def x187_build_relocations(+relocs: List<&2,X187Relocation>, +build: X187Build) -> X187Build:
  match relocs:
    case Nil{}: build
    case Con{head,rest}: x187_build_relocations(rest,x187_build_relocation(head,build))

@unsafe
def x187_build_encoded(+encoded: X187Encoded, +build: X187Build) -> X187Build:
  match encoded:
    case X187Encoded{bytes,relocs,+error}:
      nt_choose(X187Build,String.is_empty(error),u => x187_build_relocations(relocs,x187_build_bytes(bytes,build)),
        u => x187_build_error(error,build))

# Tag only an encoder-authenticated local branch. RIP address loads and calls
# retain their ordinary relocation kinds and therefore retain symbol identity.
# Kind 130 is private to this builder and must never reach the ELF validator.
@unsafe
def x188_branch_encoded(inst: X187Instruction, +encoded: X187Encoded) -> X187Encoded:
  match inst encoded:
    case X187Instruction{op,Con{X187Target{+name},Nil{}}}
      X187Encoded{bytes,Con{X187Relocation{s,o,2,symbol,4294967292,4294967295},Nil{}},error}:
      nt_choose(X187Encoded,String.starts_with(op,"j") && String.starts_with(name,".L"),
        u => X187Encoded{bytes,[X187Relocation{s,o,130,symbol,4294967292,4294967295}],error},
        u => encoded)
    case _ _: encoded

@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  x187_build_encoded(x188_branch_encoded(inst,x187_encode(inst,x187_build_offset(build))),build)

@unsafe
def x187_build_fill(+count: U32, +byte: U32, +acc: List<&2,U32>) -> List<&2,U32>:
  match count:
    case 0: acc
    case _: x187_build_fill(U32.sub(count,1),byte,Con{byte,acc})

def x187_build_section(+build: X187Build) -> U32:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}: s

def x187_build_switch(+section: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      X187Build{section,t,r,d,ts,rs,ds,symbols,names,relocs,error}

@unsafe
def x187_build_datum(datum: P111QDatum, +build: X187Build) -> X187Build:
  match datum:
    case P111QByte{+value}:
      nt_choose(X187Build,U32.is_le(value,255),u => x187_build_bytes([value],build),
        u => x187_build_error("data width overflow",build))
    case P111QWord{value}: x187_build_bytes(x187_elf_u32(value),build)
    case P111QLong{lo,hi}: x187_build_bytes(x187_elf_u64(lo,hi),build)
    case P111QReloc{name,offset}:
      x187_build_bytes([0,0,0,0,0,0,0,0],x187_build_relocation(
        X187Relocation{x187_build_section(build),x187_build_offset(build),1,name,offset,0},build))
    case P111QZeros{+count}:
      nt_choose(X187Build,U32.is_gt(count,8388608),
        u => x187_build_error("zero directive exceeds 8MiB",build),u =>
        nt_choose(X187Build,U32.is_gt(x187_build_offset(build),U32.sub(33554432,count)),
          v => x187_build_error("x86 object section exceeds 32 MiB bound",build),
          v => x187_build_bytes(x187_build_fill(count,0,[]),build)))

@unsafe
def x187_build_parsed(+parsed: X187Parsed, +build: X187Build) -> X187Build:
  match parsed:
    case PEmpty{}: build
    case PError{message}: x187_build_error(message,build)
    case PSection{section}: x187_build_switch(section,build)
    case PLabel{name}: x187_build_symbol(name,1,0,build)
    case PGlobal{name}: x187_build_symbol(name,2,0,build)
    case PType{name,kind}: x187_build_symbol(name,3,kind,build)
    case PSize{name}: x187_build_symbol(name,4,0,build)
    case PBytes{bytes}: x187_build_bytes(bytes,build)
    case PDatum{datum}: x187_build_datum(datum,build)
    case PDataReloc{name,lo,hi}:
      x187_build_bytes([0,0,0,0,0,0,0,0],x187_build_relocation(
        X187Relocation{x187_build_section(build),x187_build_offset(build),1,name,lo,hi},build))
    case PAlign{+alignment}:
      nt_choose(X187Build,U32.is_eq(alignment,0) || U32.is_gt(alignment,
            nt_choose(U32,U32.is_eq(x187_build_section(build),1),w => 16,w => 8)) ||
          Bool.not(U32.is_eq(U32.and(alignment,U32.sub(alignment,1)),0)),
        v => x187_build_error("invalid object alignment",build),v =>
        x187_build_bytes(x187_build_fill(U32.mod(U32.sub(alignment,U32.mod(x187_build_offset(build),alignment)),alignment),
          nt_choose(U32,U32.is_eq(x187_build_section(build),1),w => 144,w => 0),[]),build))
    case PInst{instruction}:
      nt_choose(X187Build,U32.is_eq(x187_build_section(build),1),
        v => x188_build_instruction(instruction,build),
        v => x187_build_error("instruction outside text",build))

@unsafe
def x187_build_text_next(+text: String, +build: X187Build) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => x187_build_text(text,"",build),u => build)

@unsafe
def x187_build_text(+text: String, +line: String, +build: X187Build) -> X187Build:
  match text:
    case SNil{}: x187_build_parsed(x187_parse_line(String.reverse(line)),build)
    case SCon{+head,+rest}:
      nt_choose(X187Build,U32.is_eq(Char.to_u32(head),10),
        u => x187_build_text_next(rest,x187_build_parsed(x187_parse_line(String.reverse(line)),build)),
        u => x187_build_text(rest,SCon{head,line},build))

def x187_build_message(build: X187Build) -> String:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}: error

# An explicit pending-fragment stack bounds host call depth even for a deeply
# left- or right-associated selector sequence. Left is consumed before right.
@unsafe
def x187_build_seq_work(+todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => x187_build_seq_next(todo,build,count),u => build)

@unsafe
def x187_build_seq_next(todo: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match todo:
    case Nil{}: build
    case Con{head,rest}:
      nt_choose(X187Build,U32.is_lt(count,67108864),
        u => x187_build_seq_item(head,rest,build,U32.inc(count)),
        u => x187_build_error("x86 object fragment count exceeds bound",build))

@unsafe
def x187_build_seq_item(seq: X188Seq, rest: List<&2,X188Seq>, build: X187Build, count: U32) -> X187Build:
  match seq:
    case X188Empty{}: x187_build_seq_work(rest,build,count)
    case X188One{item}: x187_build_seq_work(rest,x187_build_parsed(item,build),count)
    case X188Join{left,right}: x187_build_seq_work(Con{left,Con{right,rest}},build,count)

@unsafe
def x187_build_seq(seq: X188Seq, build: X187Build) -> X187Build:
  x187_build_seq_work([seq],build,0)

@unsafe
def x187_build_chunks(+chunks: List<&2,X188Seq>, +build: X187Build) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => x187_build_chunks_good(chunks,build),u => build)

@unsafe
def x187_build_chunks_good(+chunks: List<&2,X188Seq>, +build: X187Build) -> X187Build:
  match chunks:
    case Nil{}: build
    case Con{head,rest}: x187_build_chunks(rest,x187_build_seq(head,build))

# Relocations arrive in reverse creation order. Prepending selected patches
# restores monotonically increasing text offsets, even across section switches.
# Remaining references form the exact escape set for local symbol retention.
@unsafe
def x188_fixup_keep(+reloc: X187Relocation, state: X188Fixups) -> X188Fixups:
  match reloc state:
    case X187Relocation{s,o,k,+name,lo,hi} X188Fixups{patches,relocations,+escaped,error}:
      X188Fixups{patches,Con{reloc,relocations},
        nt_choose(KDef,String.starts_with(name,".L"),
          u => p111v_put(escaped,name,"X188Escaped",0,0),u => escaped),error}

@unsafe
def x188_fixup_symbol(+reloc: X187Relocation, +size: U32, +state: X188Fixups, symbol: KDef) -> X188Fixups:
  match reloc symbol:
    case X187Relocation{+section,+offset,kind,+name,+lo,+hi}
      KDef{n,k,+targetSection,+value,typ,v,c,+global,+defined}:
      nt_choose(X188Fixups,defined && Bool.not(global) && String.starts_with(name,".L") &&
          U32.is_eq(section,1) && U32.is_eq(targetSection,1),u =>
        nt_choose(X188Fixups,U32.is_eq(lo,4294967292) && U32.is_eq(hi,4294967295) &&
            U32.is_le(value,size) && U32.is_le(offset,size) && U32.is_le(4,U32.sub(size,offset)),
          v => x188_fixup_add(X187Relocation{1,offset,2,name,U32.sub(value,U32.add(offset,4)),0},state),
          v => x188_fixup_error("invalid local branch fixup",state)),u =>
        x188_fixup_keep(X187Relocation{section,offset,2,name,lo,hi},state))
    case X187Relocation{section,offset,kind,name,lo,hi} _:
      x188_fixup_keep(X187Relocation{section,offset,2,name,lo,hi},state)

def x188_fixup_add(patch: X187Relocation, state: X188Fixups) -> X188Fixups:
  match state:
    case X188Fixups{patches,relocations,escaped,error}:
      X188Fixups{Con{patch,patches},relocations,escaped,error}

def x188_fixup_error(message: String, state: X188Fixups) -> X188Fixups:
  match state:
    case X188Fixups{patches,relocations,escaped,error}:
      X188Fixups{patches,relocations,escaped,p111_first(error,message)}

@unsafe
def x188_fixup_item(+reloc: X187Relocation, +index: KDef, +size: U32, +state: X188Fixups) -> X188Fixups:
  match reloc:
    case X187Relocation{section,offset,+kind,name,lo,hi}:
      nt_choose(X188Fixups,U32.is_eq(kind,130),
        u => x188_fixup_symbol(reloc,size,state,p111v_get(index,name)),
        u => x188_fixup_keep(reloc,state))

@unsafe
def x188_fixup_scan(items: List<&2,X187Relocation>, +index: KDef, +size: U32,
    +count: U32, +state: X188Fixups) -> X188Fixups:
  match items:
    case Nil{}: state
    case Con{head,rest}:
      nt_choose(X188Fixups,U32.is_lt(count,1048576),
        u => x188_fixup_scan(rest,index,size,U32.inc(count),x188_fixup_item(head,index,size,state)),
        u => x188_fixup_error("invalid ELF relocation",state))

@unsafe
def x188_fixup_word(bytes: List<&2,U32>, patches: List<&2,X187Relocation>, position: U32,
    word: U32, acc: List<&2,U32>) -> X187Encoded:
  match bytes:
    case Con{0,Con{0,Con{0,Con{0,rest}}}}:
      x188_fixup_bytes(rest,patches,U32.add(position,4),nt_reverse(U32,x187_elf_u32(word),acc))
    case _: X187Encoded{[],[],"invalid local branch placeholder"}

@unsafe
def x188_fixup_advance(bytes: List<&2,U32>, patches: List<&2,X187Relocation>, position: U32,
    acc: List<&2,U32>) -> X187Encoded:
  match bytes:
    case Nil{}: X187Encoded{[],[],"local branch fixup outside text"}
    case Con{head,rest}: x188_fixup_bytes(rest,patches,U32.inc(position),Con{head,acc})

@unsafe
def x188_fixup_at(+bytes: List<&2,U32>, +patches: List<&2,X187Relocation>, +position: U32,
    +acc: List<&2,U32>, patch: X187Relocation, rest: List<&2,X187Relocation>) -> X187Encoded:
  match patch:
    case X187Relocation{section,+offset,kind,name,word,hi}:
      nt_choose(X187Encoded,U32.is_lt(offset,position),
        u => X187Encoded{[],[],"overlapping or unordered local branch fixup"},u =>
        nt_choose(X187Encoded,U32.is_eq(offset,position),
          v => x188_fixup_word(bytes,rest,position,word,acc),
          v => x188_fixup_advance(bytes,patches,position,acc)))

@unsafe
def x188_fixup_bytes(bytes: List<&2,U32>, +patches: List<&2,X187Relocation>, position: U32,
    acc: List<&2,U32>) -> X187Encoded:
  match patches:
    case Nil{}: X187Encoded{nt_reverse(U32,acc,bytes),[],""}
    case Con{head,rest}: x188_fixup_at(bytes,patches,position,acc,head,rest)

@unsafe
def x187_build_symbols(+names: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object) -> X187ObjectResult:
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: x187_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def x187_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        x188_build_symbol_checked(X187Symbol{name,section,value,size,global || Bool.not(defined),kind},
          rest,index,escaped,sizes,acc,object))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def x188_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>
        x187_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              String.eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})

@unsafe
def x188_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> X187ObjectResult:
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => x187_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => X187ObjectResult{[],error})

@unsafe
def x188_build_fixups(names: List<&2,String>, index: KDef, sizes: X187ElfSizes,
    text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> X187ObjectResult:
  match state:
    case X188Fixups{patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => x188_build_patched(names,index,escaped,sizes,rodata,data,relocations,x188_fixup_bytes(text,patches,0,[])),
        u => X187ObjectResult{[],error})

# Preserve original symbol-count, name and string-table capacities before
# removable locals vanish. The initial byte accounts for the reserved NUL.
@unsafe
def x188_symbol_count(names: List<&2,String>, +count: U32, +bytes: U32) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head,rest}:
      nt_choose(Bool,U32.is_lt(count,1048575),
        u => x188_symbol_name(head,rest,count,bytes,0),u => False{})

@unsafe
def x188_symbol_name(name: String, rest: List<&2,String>, count: U32, +bytes: U32, +length: U32) -> Bool:
  match name:
    case SNil{}:
      nt_choose(Bool,U32.is_gt(length,0) && U32.is_le(U32.inc(length),U32.sub(67108864,bytes)),
        u => x188_symbol_count(rest,U32.inc(count),U32.add(bytes,U32.inc(length))),u => False{})
    case SCon{+head,tail}:
      nt_choose(Bool,U32.is_lt(length,4096) && U32.is_gt(Char.to_u32(head),0) && U32.is_lt(Char.to_u32(head),128),
        u => x188_symbol_name(tail,rest,count,bytes,U32.inc(length)),u => False{})

@unsafe
def x187_build_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          x188_build_fixups(names,symbols,X187ElfSizes{ts,rs,ds},nt_reverse(U32,t,[]),nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

@unsafe
def x187_assemble(+text: String) -> X187ObjectResult:
  x187_build_finish(x187_build_text(text,"",x187_build_empty()))

@unsafe
def x187_output(+output: X181Output, +build: X187Build) -> X187Build:
  match output:
    case X181Output{chunks,+error}:
      nt_choose(X187Build,String.is_empty(error),u => x187_build_chunks(chunks,build),u => x187_build_error(error,build))

# Consume a function at a time; do not collect a complete assembly program.
@unsafe
def x187_cursor(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => x187_cursor_good(cursor,available,build),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def x187_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: x187_cursor(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x187_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build))
    case P134Legacy{entries,context,next}: x187_cursor(next,available,build)
    case P134Public{Nil{},context,next}: x187_cursor(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x187_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build))
    case P134Tables{Nil{}}: x187_cursor(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x187_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x187_build_finish(x187_build_seq(x181_program_main(),build))
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def x187_prepared(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor(cursor,x181_cursor_index(cursor,missing()),x187_build_empty()),
        u => X187ObjectResult{[],error})

@unsafe
def x187_print_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  (file,result) = pair
  do IO<U32>:
    Unit <- File.close(file)
    x187_print_status(result)

@unsafe
def x187_print_result(result: X187ObjectResult) -> IO(U32):
  match result:
    case X187ObjectResult{bytes,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => do IO<U32>:
        file : File <- IO.try(File,File.open("/dev/stdout","w"))
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write_bytes(file,bytes)
        x187_print_written(pair),u => IO.die(U32,1,error))

@unsafe
def x187_print(prepared: P169Prepared) -> IO(U32):
  x187_print_result(x187_prepared(prepared))

@unsafe
def x187_print_status(result: Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  match result:
    case Done{unit}: IO.pure(U32,0)
    case Fail{error}: IO.pass(U32,Fail{error})
