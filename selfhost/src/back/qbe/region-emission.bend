

@unsafe
def p114p_original_constructor(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +kind = p111_special(name)
  +call = nt_choose(N111Stmt, U32.is_eq(kind, 0),
    u => N111Call{"value", N111U64{}, "p111_rt_ctor", [p111_state(), N111Arg{N111U32{}, N111CtorId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]},
    u => N111Call{"value", N111U64{}, "p111_rt_special_ctor", [p111_state(), p111_u32(kind), p111_scratch(), p111_u32(nt_count(N111Value, values))]})
  P111ValueCode{nt_append(N111Stmt, p111_store(values, 0), [call]), N111Local{"value"}, ""}


@unsafe
def p114p_ordinary(+name: String) -> Bool:
  String.starts_with(name,"$ctor.") && U32.is_eq(p111_special(name),0)

# Exact mature ne_single guard: all bits outside LOC_MASK are zero. This
# excludes every owning tag and RFC bit without truncating the original word.
# Both branches preserve the already-evaluated payload and return full U64.


@unsafe
def p114p_single(+name: String, field: N111Value) -> P111ValueCode:
  P111ValueCode{[
    N111Set{"p114p_payload",N111U64{},field},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"p114p_payload"}},
    N111Bin{"p114p_fits",N111U64{},"ule",N111Local{"p114p_payload"},N111Const{4294967295,255}},
    N111If{N111Local{"p114p_fits"},[
      N111Bin{"p114p_metadata",N111U64{},"shl",N111CtorId{name},N111Const{40,0}},
      N111Bin{"p114p_metadata",N111U64{},"or",N111Local{"p114p_metadata"},N111Const{0,16777216}},
      N111Bin{"value",N111U64{},"or",N111Local{"p114p_metadata"},N111Local{"p114p_payload"}}],[
      N111Call{"value",N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{name}},p111_scratch(),p111_u32(1)]}]}],
    N111Local{"value"},""}


@unsafe
def p114p_constructor(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+field,Nil{}}:
      nt_choose(P111ValueCode,p114p_ordinary(name),
        u => p114p_single(name,field),u => p114p_original_constructor(name,values))
    case _: p114p_original_constructor(name,values)


@unsafe
def p114t_original_stmt(+stmt: N111Stmt, +ids: N111Ids, code: P111QCode) -> P111QCode:
  p112fp_after_accessors(stmt,ids,p112fp_expand(stmt,code))


@unsafe
def p114t_original_verify(program: P113AProgram) -> String:
  match program:
    case P113AProgram{+original,certificate}: p113a_verify_after(original,certificate,p113d_verify(original))


@unsafe
def p114t_name(site: U32, role: String) -> String:
  "p114t_" ++ U32.show(site) ++ "_" ++ role


@unsafe
def p114t_local(site: U32, role: String) -> N111Value:
  N111Local{p114t_name(site,role)}

# Only stack allocations from the authenticated ordinary/fusion/inlining
# factories are supported. This is not an arbitrary pointer-alias certificate.


@unsafe
def p114t_fusion_buffer(+name: String, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,8),u => False{},u =>
    nt_choose(Bool,String.eq(name,"p112f_" ++ U32.show(site) ++ "_local_scratch"),
      v => True{},v => p114t_fusion_buffer(name,U32.inc(site))))


@unsafe
def p114t_buffer(+name: String) -> Bool:
  p113j_buffer_origin(name,True{}) || p114t_fusion_buffer(name,0)


@unsafe
def p114t_known_fid(+name: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      String.eq(dk(index_find(functions,name,index_hash(name,2166136261),32)),"N111Id")

# Exact unsigned two's complement byte offset. Count zero must have high zero.


@unsafe
def p114t_negative_bytes(+count: U32) -> N111Value:
  nt_choose(N111Value,U32.is_eq(count,0),u => N111Const{0,0},
    u => N111Const{U32.sub(0,U32.mul(count,8)),4294967295})

# Preserve the runtime's ordered source-load/destination-store pairs. We do not
# replace this loop with memmove or reorder all loads ahead of all stores.


@unsafe
def p114t_captures(+buffer: String, +count: U32, +index: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"capture"),N111U64{},N111Local{buffer},U32.mul(index,8)},
    Con{N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(index,8),p114t_local(site,"capture")},
      p114t_captures(buffer,count,U32.inc(index),site)}})


@unsafe
def p114t_frame(+dest: String, fid: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  Con{N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
    nt_append(N111Stmt,p114t_captures(buffer,count,0,site),[
      N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(count,8),N111FuncId{fid}},
      N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),N111Const{U32.mul(U32.inc(count),8),0}},
      N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
      N111Set{dest,N111U64{},N111Const{0,0}}])}


@unsafe
def p114t_pop(dest: String, count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
   N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),p114t_negative_bytes(count)},
   N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
   N111Set{dest,N111U64{},N111Const{0,0}}]


@unsafe
def p114t_get(dest: String, index: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
   N111Load{dest,N111U64{},p114t_local(site,"sp"),U32.mul(index,8)}]


@unsafe
def p114t_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_lt(count,256) && p114t_buffer(buffer) && p114t_known_fid(fid,ids),
          u => P114TExpansion{p114t_frame(dest,fid,buffer,count,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}:
        nt_choose(P114TExpansion,String.eq(state,"state") && U32.is_eq(high,0) && U32.is_lt(count,256),
          u => nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_stack_pop"),
            v => P114TExpansion{p114t_pop(dest,count,site),True{}},
            v => nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_stack_get"),
              w => P114TExpansion{p114t_get(dest,count,site),True{}},
              w => P114TExpansion{[stmt],False{}})),
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}


@unsafe
def p114t_local_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114t_"))


@unsafe
def p114t_names(names: List<&2,String>) -> Bool:
  p114ts_names(names,True{})

@unsafe
def p114t_params(params: List<&2,NC_Binding>) -> Bool:
  p114ts_params(params,True{})

@unsafe
def p114t_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114t_local_name(name)
    case N111Bin{name,typ,op,left,right}: p114t_local_name(name)
    case N111Call{name,typ,symbol,args}: p114t_local_name(name)
    case N111If{condition,yes,no}: p114t_scalar_list_names(yes) && p114t_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p114t_local_name(name)
    case N111Offset{name,base,bytes}: p114t_local_name(name)
    case N111Alloca{name,bytes,align}: p114t_local_name(name)
    case _: True{}


@unsafe
def p114t_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  p114ts_scalar_list(body,True{})

@unsafe
def p114t_body_names(body: List<&2,P113DStmt>) -> Bool:
  p114ts_body(body,True{})

@unsafe
def p114t_function_names(functions: List<&2,P113DFunction>) -> Bool:
  p114ts_functions(functions,True{})

@unsafe
def p114t_segment_names(segments: List<&2,N111Segment>) -> Bool:
  p114ts_segments(segments,True{})

@unsafe
def p114t_namespace(program: P113AProgram) -> Bool:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      p114t_segment_names(segments) && p114t_function_names(functions)


@unsafe
def p114t_verify_done(+program: P113AProgram, +error: String) -> String:
  nt_choose(String,String.is_empty(error),u =>
    nt_choose(String,p114t_namespace(program),v => "",v => "reserved transport-template local"),u => error)


@unsafe
def p114t_words(body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{head,rest}: p114t_words(rest,ids,p114t_original_stmt(head,ids,code))

# Reserve one fresh site even when the underlying zero-offset memory emitter
# would not advance its counter. Original If rendering advances the same counter
# through both branches; its child statements still visit the global hook.


@unsafe
def p114t_expanded(expansion: P114TExpansion, ids: N111Ids, code: P111QCode) -> P111QCode:
  match expansion code:
    case P114TExpansion{body,changed} P111QCode{chunks,+next,terminal,error}:
      p114t_words(body,ids,P111QCode{chunks,nt_choose(U32,changed,u => U32.inc(next),u => next),terminal,error})


@unsafe
def p114t_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{58,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}
      P111QCode{chunks,+next,terminal,error}:
        nt_choose(P111QCode,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          p114t_buffer(buffer) && U32.is_le(next,4294967292),
          u => p118f_to_u32(dest,buffer,next,code),
          u => p118f_original_stmt(stmt,ids,code))
    case _ _: p118f_original_stmt(stmt,ids,code)
