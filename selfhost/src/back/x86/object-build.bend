# Initial integrated object route. Selection remains the maintained x86
# selector; its finite text dialect is converted to structured instructions.
# No host assembler is used. Section buffers are explicitly bounded.

type X187Build is Data:
  X187Build{+section: U32, +text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +textSize: U32, +rodataSize: U32, +dataSize: U32, +symbols: KDef,
    +names: List<&2,String>, +relocations: List<&2,X187Relocation>, +error: String}

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
        v => x187_build_encoded(x187_encode(instruction,x187_build_offset(build)),build),
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

@unsafe
def x187_build_chunks(+chunks: List<&2,String>, +build: X187Build) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => x187_build_chunks_good(chunks,build),u => build)

@unsafe
def x187_build_chunks_good(+chunks: List<&2,String>, +build: X187Build) -> X187Build:
  match chunks:
    case Nil{}: build
    case Con{head,rest}: x187_build_chunks(rest,x187_build_text(head,"",build))

@unsafe
def x187_build_symbols(+names: List<&2,String>, +index: KDef, +acc: List<&2,X187Symbol>, +object: X187Object) -> X187ObjectResult:
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: x187_build_symbol_final(name,rest,index,acc,object,p111v_get(index,name))

@unsafe
def x187_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        x187_build_symbols(rest,index,Con{X187Symbol{name,section,value,size,global || Bool.not(defined),kind},acc},object))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def x187_build_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        x187_build_symbols(names,symbols,[],X187Object{nt_reverse(U32,t,[]),nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),[],nt_reverse(X187Relocation,relocs,[])}),
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
    case P134Main{}: x187_build_finish(x187_build_text(x181_program_main(),"",build))
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
