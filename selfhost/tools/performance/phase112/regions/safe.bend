# Only the authenticated fusion transform can introduce these names: original
# p112f_clean is required before planning, including zero-site candidates.
@unsafe
def p112r_buffer_sites(+name: String, +sites: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,sites),u => False{},u =>
    String.eq(name,"p112f_" ++ U32.show(index) ++ "_local_scratch") || p112r_buffer_sites(name,sites,U32.inc(index)))

@unsafe
def p112r_buffer(+name: String, +sites: U32) -> Bool:
  U32.is_le(sites,8) && (String.eq(name,"scratch") || p112r_buffer_sites(name,sites,0))

@unsafe
def p112r_buffers(args: List<&2,N111Arg>, +sites: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},N111Local{+name}},+rest}: p112r_buffer(name,sites) && p112r_buffers(rest,sites)
    case Con{N111Arg{N111Ptr{},+value},+rest}: False{}
    case Con{+arg,+rest}: p112r_buffers(rest,sites)

@unsafe
def p112r_runtime_args(args: List<&2,N111Arg>, +sites: U32) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+name}},+rest}: String.eq(name,"state") && p112r_buffers(rest,sites)
    case _: False{}

@unsafe
def p112r_words(args: List<&2,N111Arg>, +count: U32) -> Bool:
  match args:
    case Nil{}: U32.is_eq(count,0)
    case Con{N111Arg{N111U64{},+value},+rest}: U32.is_gt(count,0) && p112r_words(rest,U32.sub(count,1))
    case _: False{}

@unsafe
def p112r_private_call(stmt: N111Stmt, +symbols: KDef) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},+rest}}:
      +record = p111v_get(symbols,symbol)
      String.eq(state,"state") && String.eq(dk(record),"P112RegionSymbol") && p112r_words(rest,da(record))
    case _: False{}

@unsafe
def p112r_scalar(+stmt: N111Stmt, +symbols: KDef, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      (p112t_runtime_call(symbol) && p112r_runtime_args(args,sites)) || p112r_private_call(stmt,symbols)
    case N111Load{+name,N111U64{},N111Local{+base},+offset}: p112r_buffer(base,sites)
    case N111Store{N111U64{},N111Local{+base},+offset,+value}: p112r_buffer(base,sites)
    case N111Alloca{+name,2048,8}: Bool.not(String.eq(name,"scratch")) && p112r_buffer(name,sites)
    case _: p112t_scalar_safe(stmt)

@unsafe
def p112r_failure_frame(stmt: N111Stmt, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+target}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && p112r_buffer(scratch,sites) && U32.is_le(count,255)
    case _: False{}

# The exact CPU fail-stop runtime prerequisite is inherited, never generalized.
@unsafe
def p112r_failure(body: List<&2,N111Stmt>, +symbols: KDef, +sites: U32) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,+args},Con{N111Return{N111Local{+word}},Nil{}}}:
      String.eq(symbol,"p111_rt_fail") && String.eq(dest,word) && p112t_failure_args(args)
    case Con{+stmt,+rest}: (p112r_scalar(stmt,symbols,sites) || p112r_failure_frame(stmt,sites)) && p112r_failure(rest,symbols,sites)
    case _: False{}
