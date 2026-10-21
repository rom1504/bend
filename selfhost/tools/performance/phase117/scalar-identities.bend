# Phase117 experimental private-emitter identity. Preserve the verified IR and
# explicit U32-to-U64 extension; only an adjacent comparison supplies the 0/1
# certificate. Arbitrary U32 conditions retain the existing normalization.
# Source composition replaces only p113w_look; all new declarations are p117s_.

@unsafe
def p117s_after_predicate(+predicate: String, stmt: P113DStmt) -> P113BQDiamond:
  match stmt:
    case P113DScalar{N111If{N111Local{name},yes,no}}:
      nt_choose(P113BQDiamond,String.eq(predicate,name),u => p113bq_scalar(yes,no),u => P113BQNo{})
    case P113DIf{N111Local{name},yes,no}:
      nt_choose(P113BQDiamond,String.eq(predicate,name),u => p113bq_direct(yes,no),u => P113BQNo{})
    case _: P113BQNo{}

@unsafe
def p117s_pair(first: P113DStmt, second: P113DStmt) -> P113BQDiamond:
  match first:
    case P113DScalar{N111Bin{name,typ,op,left,right}}:
      nt_choose(P113BQDiamond,p111v_comparison(op),u => p117s_after_predicate(name,second),u => P113BQNo{})
    case _: P113BQNo{}

@unsafe
def p117s_emit_value(+condition: String, diamond: P113BQDiamond, code: P111QCode) -> P111QCode:
  match diamond code:
    case P113BQYes{+name,+invert} P111QCode{+chunks,+n,+terminal,+error}:
      nt_choose(P111QCode,invert,
        u => P111QCode{Con{p111q_local(name) ++ " =l extuw %p117_scalar_" ++ U32.show(n) ++ "\n",
          Con{"%p117_scalar_" ++ U32.show(n) ++ " =w xor " ++ p111q_local(condition) ++ ", 1\n",chunks}},U32.inc(n),terminal,error},
        u => P111QCode{Con{p111q_local(name) ++ " =l extuw " ++ p111q_local(condition) ++ "\n",chunks},n,terminal,error})
    case P113BQNo{} _: p111q_problem("invalid comparison Boolean identity",code)

@unsafe
def p117s_emit(+first: P113DStmt, diamond: P113BQDiamond, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match first:
    case P113DScalar{N111Bin{name,typ,op,left,right}}:
      p117s_emit_value(name,diamond,p113w_one(first,params,ids,code))
    case _: p111q_problem("invalid comparison Boolean producer",code)

# Exact old width-pair behavior, retained as the fallback for every other shape.
@unsafe
def p117s_original_look(+head: P113DStmt, +rest: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{second,more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p113w_stmts(more,params,ids,p113w_pair_emit(head,ids,code)),
        u => p113w_stmts(rest,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)

@unsafe
def p113w_look(+head: P113DStmt, +rest: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,+more}:
      +diamond = p117s_pair(head,second)
      nt_choose(P111QCode,p113bq_ready(diamond,code),
        u => p113w_stmts(more,params,ids,p117s_emit(head,diamond,params,ids,code)),
        u => p117s_original_look(head,rest,params,ids,code))
    case Nil{}: p113w_one(head,params,ids,code)

@unsafe
def p117s_recognized(diamond: P113BQDiamond) -> Bool:
  match diamond:
    case P113BQYes{name,invert}: True{}
    case P113BQNo{}: False{}

@unsafe
def p117s_control_report() -> List<&2,String>:
  +comparison = P113DScalar{N111Bin{"predicate",N111U64{},"eq",N111Local{"a"},N111Local{"b"}}}
  +yes = [N111Set{"value",N111U64{},N111Const{1,0}}]
  +no = [N111Set{"value",N111U64{},N111Const{0,0}}]
  +diamond = P113DScalar{N111If{N111Local{"predicate"},yes,no}}
  +ids = N111Ids{missing(),missing()}
  +code = P111QCode{[],7,False{},""}
  [p113wt_row("scalar-comparison-admitted",p117s_recognized(p117s_pair(comparison,diamond))),
   p113wt_row("scalar-direct-diamond-admitted",p117s_recognized(p117s_pair(comparison,P113DIf{N111Local{"predicate"},p113d_scalars(yes),p113d_scalars(no)}))),
   p113wt_row("scalar-unrelated-condition-refused",Bool.not(p117s_recognized(p117s_pair(comparison,P113DScalar{N111If{N111Local{"other"},yes,no}})))),
   p113wt_row("scalar-noncomparison-refused",Bool.not(p117s_recognized(p117s_pair(P113DScalar{N111Bin{"predicate",N111U64{},"add",N111Local{"a"},N111Local{"b"}}},diamond)))),
   p113wt_row("scalar-extra-arm-work-refused",Bool.not(p117s_recognized(p117s_pair(comparison,P113DScalar{N111If{N111Local{"predicate"},nt_append(N111Stmt,yes,yes),no}})))),
   p113wt_row("scalar-direct-extension",String.eq(p111q_body_text(p111q_return("0",p117s_emit(comparison,P113BQYes{"value",False{}},[],ids,code))),"%v_predicate =w ceql %v_a, %v_b\n%v_value =l extuw %v_predicate\nret 0\n")),
   p113wt_row("scalar-inverted-extension",String.eq(p111q_body_text(p111q_return("0",p117s_emit(comparison,P113BQYes{"value",True{}},[],ids,code))),"%v_predicate =w ceql %v_a, %v_b\n%p117_scalar_7 =w xor %v_predicate, 1\n%v_value =l extuw %p117_scalar_7\nret 0\n")),
   p113wt_row("scalar-counter-exhaustion-fallback",Bool.not(p113bq_ready(P113BQYes{"value",True{}},P111QCode{[],4294967295,False{},""})))]
