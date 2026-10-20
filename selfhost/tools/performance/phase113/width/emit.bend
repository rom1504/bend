# Private rendering of already verified direct IR. The original U64 graph is
# unchanged. Only a same-destination adjacent modulo-2^32 pair is combined.
@unsafe
def p113w_ring(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
    String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor")

@unsafe
def p113w_mask_of(stmt: P113DStmt, +source: String) -> Bool:
  match stmt:
    case P113DScalar{N111Bin{destination,N111U64{},op,N111Local{word},N111Const{4294967295,0}}}:
      String.eq(destination,source) && String.eq(word,source) && String.eq(op,"and")
    case _: False{}

@unsafe
def p113w_pair(first: P113DStmt, +second: P113DStmt) -> Bool:
  match first:
    case P113DScalar{N111Bin{name,N111U64{},op,left,right}}:
      p113w_ring(op) && p113w_mask_of(second,name)
    case _: False{}

def p113w_mask(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{N111Bin{name,N111U64{},op,left,N111Const{4294967295,0}}}: String.eq(op,"and")
    case _: False{}

@unsafe
def p113w_room(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_lt(next,4294967295)

@unsafe
def p113w_word(+name: String, +operation: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,terminal,error}:
      +temporary = "%p113_width_" ++ U32.show(next)
      P111QCode{Con{p111q_local(name) ++ " =l extuw " ++ temporary ++ "\n",
        Con{temporary ++ " =w " ++ operation ++ "\n",chunks}},U32.inc(next),terminal,error}

@unsafe
def p113w_pair_emit(first: P113DStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match first:
    case P113DScalar{N111Bin{name,N111U64{},op,left,right}}:
      p113w_word(name,op ++ " " ++ p111q_value(left,ids) ++ ", " ++ p111q_value(right,ids),ids,code)
    case _: p111q_problem("invalid private width pair",code)

@unsafe
def p113w_mask_emit(stmt: P113DStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P113DScalar{N111Bin{name,N111U64{},op,left,mask}}:
      p113w_word(name,"copy " ++ p111q_value(left,ids),ids,code)
    case _: p111q_problem("invalid private width mask",code)

@unsafe
def p113w_one(+head: P113DStmt, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,p113w_mask(head) && p113w_room(code),
    u => p113w_mask_emit(head,ids,code),u => p113e_stmt_emit(head,params,ids,code))

@unsafe
def p113w_look(+head: P113DStmt, +rest: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{second,more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p113w_stmts(more,params,ids,p113w_pair_emit(head,ids,code)),
        u => p113w_stmts(rest,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)

@unsafe
def p113w_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{head,rest} P111QCode{chunks,next,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p113w_look(head,rest,params,ids,code)))
