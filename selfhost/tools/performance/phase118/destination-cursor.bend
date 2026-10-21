# Isolated private destination representation. Hidden p118_parent now carries
# slot | seal-bit, never a source Term; p118_root remains the owned raw Term.
# Compose after trmc-v4. Every admitted worker uses this one representation.

@unsafe
def p118t_finish(values: List<&2,N111Value>, +n: U32) -> P113DCode:
  match values:
    case Con{word,Nil{}}:
      +result = "p118_finished_" ++ U32.show(n)
      P113DCode{[
        P113DScalar{N111Call{result,N111U64{},"p118_rt_finish_cursor",
          [p111_state(),p111_word(N111Local{"p118_root"}),p111_word(N111Local{"p118_parent"}),p111_word(word)]}},
        P113DResult{[N111Local{result}]}],U32.inc(n),"",[]}
    case _: p113d_fail("TRMC terminal result must be boxed",n)

@unsafe
def p118t_extend(+t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +values = p111_values(ks(t),env)
  +count = ix(t)
  +node = "p118_node_" ++ U32.show(n)
  +cursor = "p118_cursor_" ++ U32.show(n)
  +root = "p118_next_root_" ++ U32.show(n)
  +empty = "p118_root_empty_" ++ U32.show(n)
  +valid = p118t_target(target) && nd_match_vars(ks(t)) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    U32.is_eq(terms_len(ks(t)),U32.add(count,ix(p113pl_shape(target)))) && U32.is_eq(p111_special(nm(t)),0)
  nt_choose(P113DCode,valid,u =>
    p113d_prepend(nt_append(N111Stmt,p111_store(p118t_prefix(values,count),0),[
      N111Call{node,N111U64{},"p118_rt_extend_cursor",[p111_state(),p111_word(N111Local{"p118_parent"}),
        N111Arg{N111U32{},N111CtorId{nm(t)}},p111_scratch(),p111_u32(count)]},
      N111Load{cursor,N111U64{},N111Local{"scratch"},0},
      N111Bin{empty,N111U64{},"eq",N111Local{"p118_root"},N111Const{0,0}},
      N111If{N111Local{empty},[N111Set{root,N111U64{},N111Local{node}}],[N111Set{root,N111U64{},N111Local{"p118_root"}}]}]),
      P113DCode{[P113DAgain{nt_append(N111Value,p118t_rest(values,count),[N111Local{root},N111Local{cursor}])}],U32.inc(n),"",[]}),
    u => p113d_fail("TRMC invalid private construction",n))

@unsafe
def p118t_has_extend(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{name,typ,+symbol,args}},rest}:
      String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_extend_cursor") || p118t_has_extend(rest)
    case Con{P113DIf{condition,yes,no},rest}: p118t_has_extend(yes) || p118t_has_extend(no) || p118t_has_extend(rest)
    case Con{stmt,rest}: p118t_has_extend(rest)

@unsafe
def p118t_import(+symbol: String) -> Bool:
  String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_finish") ||
    String.eq(symbol,"p118_rt_extend_cursor") || String.eq(symbol,"p118_rt_finish_cursor")

@unsafe
def p118t_import_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_extend_cursor"),u =>
    p118t_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
    (String.eq(symbol,"p118_rt_finish") || String.eq(symbol,"p118_rt_finish_cursor")) && p111v_args(args,[3,2,2,2],live,ids))
