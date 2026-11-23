# Wave 10 Phase 1 (M2): Pure-Bend ELF64 Symbol Visibility for `x86-module`.
# Eliminates `objcopy -L` and `objcopy -W` completely by emitting proper ELF64
# symbol bindings (`STB_LOCAL=0`, `STB_GLOBAL=1`, `STB_WEAK=2`) with exact
# local-before-nonlocal `.symtab` ordering and `.symtab` `sh_info` directly
# inside the self-hosted Bend ELF builder.
#
# Visibility rules for defined (`section != 0`) symbols in `x86-module` mode:
#   1. `STB_LOCAL` (binding=0, index < sh_info):
#        - `.L*` local labels (existing)
#        - `$p111.k.*` module-private CPS continuations
#          (`p111_FID_36_112_49_49_49_46_107_46_*` / `p113d_FID_36_112_49_49_49_46_107_46_*`)
#        - per-module `def main` (`p111_FID_109_97_105_110_` / `p113d_FID_109_97_105_110_`)
#        - non-exported data tables (`p111_cid_*`, `p111_static_image`, etc.)
#   2. `STB_WEAK` (binding=2, index >= sh_info):
#        - Any defined function symbol originating from the imported `P86Seed.book`
#          (Base helpers such as `U32.*`, `List.*`, `String.*` AND imported module
#          interface stubs). Strong `STB_GLOBAL` definitions in the owning module
#          always override `STB_WEAK` stubs regardless of link order, and duplicate
#          `STB_WEAK` Base helpers merge cleanly in GNU `ld`.
#   3. `STB_GLOBAL` (binding=1, index >= sh_info):
#        - Module-owned definitions (defined in the module's own source, not in `seed.book`)
#        - Module table exports (`p111_mod_<M>_fid_base`, `p111_mod_<M>_program`,
#          `p111_mod_<M>_p111_segments`, `p111_mod_<M>_p111_fid_*`)
#        - Undefined external references (`section == 0`)
#   4. C `main` (`x181_program_main`) is omitted in `x86-module` mode (provided by
#      the link merge driver `p111_link_merge.c`).

@unsafe
def w10_is_mod_local_sym(+name: String) -> Bool:
  String.starts_with(name,"p111_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_49_49_46_107_46_") ||
    agy_str_eq(name,"p111_FID_109_97_105_110_") ||
    agy_str_eq(name,"p113d_FID_109_97_105_110_")

@unsafe
def w10_weak_add_def(+name: String, +acc: KDef) -> KDef:
  +dname = "$direct." ++ name
  +s1 = p111q_symbol(dname)
  +s2 = p113e_symbol(dname)
  +s3 = p111q_symbol(name)
  +s4 = p113e_symbol(name)
  p111v_put(p111v_put(p111v_put(p111v_put(acc,s1,"W10Weak",1,0),s2,"W10Weak",1,0),s3,"W10Weak",1,0),s4,"W10Weak",1,0)

@unsafe
def w10_weak_from_book(book: List<&2,KDef>, +acc: KDef) -> KDef:
  match book:
    case Nil{}: acc
    case Con{KDef{+name,+kind,arity,templates,typ,value,ctors,native,unsafe},+rest}:
      nt_choose(KDef,agy_str_eq(kind,"Def"),
        u => w10_weak_from_book(rest,w10_weak_add_def(name,acc)),
        u => w10_weak_from_book(rest,acc))
    case Con{_,rest}: w10_weak_from_book(rest,acc)

@unsafe
def w10_weak_from_seed(seed: P86Seed) -> KDef:
  match seed:
    case P86Seed{src,book,fresh,ready,world}:
      w10_weak_from_book(book,missing())

@unsafe
def w10_is_weak_sym(+weak_set: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(weak_set,name)),"W10Weak")

# Encode 24-byte Elf64_Sym with exact st_info = (bind << 4) | kind:
#   STB_LOCAL  = 0 -> 0
#   STB_GLOBAL = 1 -> 16
#   STB_WEAK   = 2 -> 32  (only for defined symbols in weak_set)
@unsafe
def w10_elf_symbol_bytes(symbol: X187Symbol, nameOffset: U32, +weak_set: KDef) -> List<&2,U32>:
  match symbol:
    case X187Symbol{+name,+section,value,size,+global,kind}:
      +bind : U32 = nt_choose(U32,global,
        u => nt_choose(U32,Bool.not(U32.is_eq(section,0)) && w10_is_weak_sym(weak_set,name),
          v => 32,
          v => 16),
        u => 0)
      x187_elf_cat(x187_elf_u32(nameOffset),
        Con{U32.add(kind,bind),Con{0,
          x187_elf_cat(x187_elf_u16(section),
            x187_elf_cat(x187_elf_u64(value,0),x187_elf_u64(size,0)))}})

@unsafe
def w10_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, +weak_set: KDef, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,section,value,size,global,kind}
      X187ElfSymbols{+index,+count,+firstGlobal,+table,+strings,+stringSize,+error}:
      +encoded = x187_elf_ascii(name,[])
      +length = U32.inc(nt_count(U32,encoded))
      nt_choose(X187ElfSymbols,String.is_empty(error) && x187_elf_symbol_valid(symbol,sizes) &&
          agy_str_eq(dk(p111v_get(index,name)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p111v_put(index,name,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          nt_reverse(U32,w10_elf_symbol_bytes(symbol,stringSize,weak_set),table),
          Con{0,x187_elf_cat(encoded,strings)},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})

law w10_elf_symbols_step:
  for +head: X187Symbol
  for +rest: List<&2,X187Symbol>
  for +globals: Bool
  for +sizes: X187ElfSizes
  for +weak_set: KDef
  for +state: X187ElfSymbols
  X187ElfSymbols

@unsafe
def w10_elf_symbols(items: List<&2,X187Symbol>, +globals: Bool, +sizes: X187ElfSizes,
    +weak_set: KDef, +state: X187ElfSymbols) -> X187ElfSymbols:
  match items:
    case Nil{}: state
    case Con{+head,rest}:
      w10_elf_symbols_step(head,rest,globals,sizes,weak_set,state)

@unsafe
def w10_elf_symbols_step(head, rest, globals, sizes, weak_set, state):
  match head:
    case X187Symbol{name,section,value,size,+global,kind}:
      w10_elf_symbols(rest,globals,sizes,weak_set,
        nt_choose(X187ElfSymbols,(global && globals) || (Bool.not(global) && Bool.not(globals)),
          u => w10_elf_symbol_add(head,sizes,weak_set,state),u => state))

@unsafe
def w10_elf_globals(items: List<&2,X187Symbol>, sizes: X187ElfSizes, +weak_set: KDef, state: X187ElfSymbols) -> X187ElfSymbols:
  match state:
    case X187ElfSymbols{index,+count,firstGlobal,table,strings,stringSize,error}:
      w10_elf_symbols(items,True{},sizes,weak_set,X187ElfSymbols{index,count,count,table,strings,stringSize,error})

# --- X187ObjectResult path (used by JS API `w10_module_prepared`) ---

@unsafe
def w10_elf_sized(+object: X187Object, +sizes: X187ElfSizes, +weak_set: KDef) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,+symbols,relocations}:
      x187_elf_checked(object,sizes,w10_elf_globals(symbols,sizes,weak_set,
        w10_elf_symbols(symbols,False{},sizes,weak_set,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})))

law w10_build_symbols:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for +object: X187Object
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def w10_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object, +weak_set: KDef) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>
        w10_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object,weak_set),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})

@unsafe
def w10_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef, +weak_set: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        +sym_global : Bool = nt_choose(Bool,defined && w10_is_mod_local_sym(name),
          v => False{},
          v => global || Bool.not(defined))
        w10_build_symbol_checked(X187Symbol{name,section,value,size,sym_global,kind},
          rest,index,escaped,sizes,acc,object,weak_set))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def w10_build_symbols(names, index, escaped, sizes, acc, object, weak_set):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          w10_elf_sized(X187Object{text,rodata,data,acc,relocations},sizes,weak_set)
    case Con{+name,rest}: w10_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name),weak_set)

@unsafe
def w10_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>,
    patched: X187Encoded, +weak_set: KDef) -> X187ObjectResult:
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w10_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations},weak_set),
        u => X187ObjectResult{[],error})

@unsafe
def w10_x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    state: X188Fixups, +weak_set: KDef) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        w10_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[])),weak_set),u => X187ObjectResult{[],error})

@unsafe
def w10_x201f_finish(+build: X187Build, +weak_set: KDef) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          w10_x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),weak_set),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

law w10_module_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def w10_module_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x201f_finish(build,weak_set)
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def w10_module_cursor(cursor, available, build, weak_set):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_good(cursor,available,build,weak_set),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def w10_module_prepared(+prepared: P169Prepared, seed: P86Seed, +fid_base: U32, +mod_name: String) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      +weak_set = w10_weak_from_seed(seed)
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => nt_choose(X187ObjectResult,U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor(w8_relocate_cursor(agy_enrich_cursor(cursor,avail),fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => X187ObjectResult{[],"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"}),
        u => X187ObjectResult{[],error})

# --- IO(U32) streaming path (used by native `x86-module` CLI) ---

@unsafe
def w10_x202p_elf_sized(+object: X187Object, +sizes: X187ElfSizes, +weak_set: KDef) -> IO(U32):
  match object:
    case X187Object{text,rodata,data,+symbols,relocations}:
      x202p_x187_elf_checked(object,sizes,w10_elf_globals(symbols,sizes,weak_set,
        w10_elf_symbols(symbols,False{},sizes,weak_set,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})))

law w10_x202p_build_symbols:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for +object: X187Object
  for +weak_set: KDef
  IO(U32)

@unsafe
def w10_x202p_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object, +weak_set: KDef) -> IO(U32):
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(IO(U32),x187_elf_symbol_valid(symbol,sizes),u =>
        w10_x202p_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object,weak_set),
        u => IO.die(U32,1,"invalid or duplicate ELF symbol"))

@unsafe
def w10_x202p_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef, +weak_set: KDef) -> IO(U32):
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(IO(U32),Bool.not(defined) && String.starts_with(name,".L"),
        u => IO.die(U32,1,"undefined local label: " ++ name),u =>
        +sym_global : Bool = nt_choose(Bool,defined && w10_is_mod_local_sym(name),
          v => False{},
          v => global || Bool.not(defined))
        w10_x202p_build_symbol_checked(X187Symbol{name,section,value,size,sym_global,kind},
          rest,index,escaped,sizes,acc,object,weak_set))
    case _: IO.die(U32,1,"invalid final object symbol")

@unsafe
def w10_x202p_build_symbols(names, index, escaped, sizes, acc, object, weak_set):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          w10_x202p_elf_sized(X187Object{text,rodata,data,acc,relocations},sizes,weak_set)
    case Con{+name,rest}: w10_x202p_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name),weak_set)

@unsafe
def w10_x202p_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>,
    patched: X187Encoded, +weak_set: KDef) -> IO(U32):
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => w10_x202p_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations},weak_set),
        u => IO.die(U32,1,error))

@unsafe
def w10_x202p_x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    state: X188Fixups, +weak_set: KDef) -> IO(U32):
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        w10_x202p_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[])),weak_set),u => IO.die(U32,1,error))

@unsafe
def w10_x202p_x201f_finish(+build: X187Build, +weak_set: KDef) -> IO(U32):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        nt_choose(IO(U32),x188_symbol_count(names,0,1),v =>
          w10_x202p_x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),weak_set),
          v => IO.die(U32,1,"invalid or duplicate ELF symbol")),
        u => IO.die(U32,1,error))

law w10_module_cursor_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)

@unsafe
def w10_module_cursor_io_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor_io(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor_io(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor_io(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor_io(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_io(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x202p_x201f_finish(build,weak_set)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w10_module_cursor_io(cursor, available, build, weak_set):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_io_good(cursor,available,build,weak_set),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w10_module_prepared_io(+prepared: P169Prepared, +weak_set: KDef, +fid_base: U32, +mod_name: String) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor_io(w8_relocate_cursor(agy_enrich_cursor(cursor,avail),fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)")),
        u => IO.die(U32,1,error))

@unsafe
def w10_module_prep_run(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_io(x198pw_plan(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)

@unsafe
def w10_module_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +prep : P86Preparation = nt_choose(P86Preparation,cached,
      u => p88_cache_prepare(base_path,base,carrier,stamp),
      u => p86_prepare(base_path,base))
    w10_module_prep_run(path,source,fid_base,mod_name,prep)
