# The existing forward patcher defines the order of diagnostics for unordered,
# overlapping and out-of-bounds patches. An empty plan selects that patcher.
@unsafe
def x201f_plan(patches: List<&2,X187Relocation>, +size: U32, end: U32,
    +acc: List<&2,X187Relocation>) -> List<&2,X187Relocation>:
  match patches:
    case Nil{}: acc
    case Con{+patch,rest}:
      match patch:
        case X187Relocation{s,+offset,k,n,lo,hi}:
          nt_choose(List<&2,X187Relocation>,U32.is_le(end,offset) && U32.is_le(offset,size) && U32.is_le(4,U32.sub(size,offset)),
            u => x201f_plan(rest,size,U32.add(offset,4),Con{patch,acc}),u => [])

@unsafe
def x201f_apply(+raw: List<&2,U32>, +patches: List<&2,X187Relocation>, end: U32,
    +acc: List<&2,U32>) -> X187Encoded:
  match patches:
    case Nil{}: X187Encoded{nt_reverse(U32,raw,acc),[],""}
    case Con{X187Relocation{s,+offset,k,n,word,hi},rest}:
      x201f_span(raw,U32.sub(U32.sub(end,offset),4),rest,offset,word,acc)

# end is the first byte above the unconsumed raw prefix. The descending input
# list supplies ordinary bytes high-address first. Consing each byte produces
# the final forward-order suffix and consumes each original cell once.
@unsafe
def x201f_span(raw: List<&2,U32>, +count: U32, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match count:
    case 0:
      match raw:
        case Con{0,Con{0,Con{0,Con{0,rest}}}}:
          x201f_apply(rest,patches,offset,x187_elf_cat(x187_elf_u32(word),acc))
        case _: X187Encoded{[],[],"invalid local branch placeholder"}
    case _:
      match raw:
        case Nil{}: X187Encoded{[],[],"local branch fixup outside text"}
        case Con{head,rest}: x201f_span(rest,U32.sub(count,1),patches,offset,word,Con{head,acc})

@unsafe
def x201f_selected(+raw: List<&2,U32>, patches: List<&2,X187Relocation>, +size: U32,
    +plan: List<&2,X187Relocation>) -> X187Encoded:
  match plan:
    case Nil{}: x188_fixup_bytes(nt_reverse(U32,raw,[]),patches,0,[])
    case Con{head,rest}: x201f_apply(raw,plan,size,[])

@unsafe
def x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> X187ObjectResult:
  match state sizes:
    case X188Fixups{+patches,relocations,escaped,+error} X187ElfSizes{+ts,rs,ds}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        x188_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => X187ObjectResult{[],error})

# The production cursor starts with x187_build_empty. Append, padding and data
# operations maintain ts == length(t). The historical generic finish stays
# available for diagnostic callers constructing a raw X187Build by hand.
@unsafe
def x201f_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})
