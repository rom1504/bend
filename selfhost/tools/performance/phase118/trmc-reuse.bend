# Compose after qualified TRMCv4. A post-lowering projection changes ONLY the
# newly admitted private TRMC body. No borrowed observer or ordinary take moves.
# One opaque U64 cell/class credit is carried through every local backedge.

def p118r_credit() -> N111Value:
  N111Local{"p118_credit"}

def p118r_out() -> N111Arg:
  N111Arg{N111Ptr{},N111Local{"p118_credit_out"}}

@unsafe
def p118r_scalar(+stmt: N111Stmt) -> List<&2,P113DStmt>:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,+args}:
      nt_choose(List<&2,P113DStmt>,String.eq(symbol,"p111_rt_take"),u => [
        P113DScalar{N111Call{"p118_credit",N111U64{},"p118_rt_reuse_take",nt_append(N111Arg,args,[p111_word(p118r_credit())])}},
        P113DScalar{N111Set{dest,N111U64{},p111v_arg(args,3)}}],u =>
      nt_choose(List<&2,P113DStmt>,String.eq(symbol,"p118_rt_extend"),u => [
        P113DScalar{N111Call{dest,N111U64{},"p118_rt_reuse_extend",nt_append(N111Arg,args,[p111_word(p118r_credit()),p118r_out()])}},
        P113DScalar{N111Load{"p118_credit",N111U64{},N111Local{"p118_credit_out"},0}}],u =>
      nt_choose(List<&2,P113DStmt>,String.eq(symbol,"p118_rt_finish"),u => [
        P113DScalar{N111Call{dest,N111U64{},"p118_rt_reuse_finish",nt_append(N111Arg,args,[p111_word(p118r_credit())])}}],
        u => [P113DScalar{stmt}])))
    case _: [P113DScalar{stmt}]

@unsafe
def p118r_body(body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: nt_append(P113DStmt,p118r_scalar(stmt),p118r_body(rest))
    case Con{P113DIf{condition,yes,no},rest}: Con{P113DIf{condition,p118r_body(yes),p118r_body(no)},p118r_body(rest)}
    case Con{P113DAgain{values},rest}: Con{P113DAgain{nt_append(N111Value,values,[p118r_credit()])},p118r_body(rest)}
    case Con{stmt,rest}: Con{stmt,p118r_body(rest)}

# Runtime destination helpers are produced only as direct scalar statements.
# Refuse unexpected nested helper imports instead of leaving an unfreed credit
# on a hidden terminal path. Ordinary scalar boolean diamonds remain accepted.
@unsafe
def p118r_nested_safe(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{N111Call{name,typ,+symbol,args},rest}:
      Bool.not(String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_finish")) && p118r_nested_safe(rest)
    case Con{N111If{condition,yes,no},rest}: p118r_nested_safe(yes) && p118r_nested_safe(no) && p118r_nested_safe(rest)
    case Con{stmt,rest}: p118r_nested_safe(rest)

@unsafe
def p118r_shape(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      p118r_nested_safe(yes) && p118r_nested_safe(no) && p118r_shape(rest)
    case Con{P113DIf{condition,yes,no},rest}: p118r_shape(yes) && p118r_shape(no) && p118r_shape(rest)
    case Con{stmt,rest}: p118r_shape(rest)

@unsafe
def p118t_ready(+name: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, code: P113DCode) -> List<&2,P113DCandidate>:
  match code:
    case P113DCode{+body,fresh,+error,+calls}:
      +private = "$p118.trmc." ++ name
      +arity = nt_count(NC_Binding,params)
      +hidden : List<&2,NC_Binding> = [NC_Binding{nc_id(arity),"p118_root",N_W64{}},
        NC_Binding{nc_id(U32.inc(arity)),"p118_parent",N_W64{}},
        NC_Binding{nc_id(U32.add(arity,2)),"p118_credit",N_W64{}}]
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p118t_has_extend(body) && p118r_shape(body),u => [
        P113DCandidate{P113DFunction{private,nt_append(NC_Binding,params,hidden),1,False{},
          Con{P113DScalar{N111Alloca{"p118_credit_out",8,8}},p118r_body(body)}},"",calls},
        P113DCandidate{P113DFunction{name,params,1,True{},[
          P113DCall{["p118_public_result"],private,nt_append(N111Value,p113pl_locals(nc_words(params)),
            [N111Const{0,0},N111Const{0,0},N111Const{0,0}])},
          P113DResult{[N111Local{"p118_public_result"}]}]},"",[private]}],u => [old])

@unsafe
def p118t_import(+symbol: String) -> Bool:
  String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_finish") ||
    String.eq(symbol,"p118_rt_reuse_take") || String.eq(symbol,"p118_rt_reuse_extend") || String.eq(symbol,"p118_rt_reuse_finish")

@unsafe
def p118r_reuse_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p118_rt_reuse_take"),u =>
    p111v_args(args,[3,2,3,1,2],live,ids) && p111v_buffer(args,2,p111v_literal(p111v_arg(args,3)),live),u =>
  nt_choose(Bool,String.eq(symbol,"p118_rt_reuse_extend"),u =>
    p118r_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
    String.eq(symbol,"p118_rt_reuse_finish") && p111v_args(args,[3,2,2,2,2],live,ids)))

@unsafe
def p118r_extend_contract(+args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +constructor: KDef) -> Bool:
  +count = p111v_literal(p111v_arg(args,4))
  p111v_args(args,[3,2,1,3,1,2,3],live,ids) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    Bool.not(String.eq(dk(constructor),"Absent")) && U32.is_eq(da(constructor),U32.inc(count)) &&
    p111v_buffer(args,3,count,live) && p111v_memory(p111v_arg(args,6),0,2,live,ids) &&
    p118r_separate(p111v_arg(args,3),p111v_arg(args,6))

@unsafe
def p118r_separate(left: N111Value, right: N111Value) -> Bool:
  match left right:
    case N111Local{a} N111Local{b}: Bool.not(String.eq(a,b))
    case _ _: False{}

@unsafe
def p118t_import_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p118_rt_extend"),u =>
    p118t_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
  nt_choose(Bool,String.eq(symbol,"p118_rt_finish"),u => p111v_args(args,[3,2,2,2],live,ids),
    u => p118r_reuse_contract(symbol,args,live,ids)))
