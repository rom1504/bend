# Derived renderer identity; original structured IR and its verification remain.
# low32(sar64(shl64(x,32),32+k)) = extuw(sar32(low32(x),k)), 1<=k<=31.
@unsafe
def p120wp_triple(first: P113DStmt, second: P113DStmt, +third: P113DStmt) -> Bool:
  match first second:
    case P113DScalar{N111Bin{+name,N111U64{},op1,source,N111Const{32,0}}}
         P113DScalar{N111Bin{destination,N111U64{},op2,N111Local{word},N111Const{+amount,0}}}:
      String.eq(op1,"shl") && String.eq(op2,"sar") && String.eq(name,destination) &&
        String.eq(name,word) && U32.is_gt(amount,32) && U32.is_lt(amount,64) && p113w_mask_of(third,name)
    case _ _: False{}

@unsafe
def p120wp_emit(first: P113DStmt, second: P113DStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match first second:
    case P113DScalar{N111Bin{name,typ1,op1,source,left}}
         P113DScalar{N111Bin{destination,typ2,op2,word,N111Const{amount,high}}}:
      p113w_word(name,"sar " ++ p111q_value(source,ids) ++ ", " ++ U32.show(U32.sub(amount,32)),ids,code)
    case _ _: p111q_problem("invalid private signed-word triple",code)

@unsafe
def p120wp_original_look(+head: P113DStmt, +rest: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{second,more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p113w_stmts(more,params,ids,p113w_pair_emit(head,ids,code)),
        u => p113w_stmts(rest,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)

@unsafe
def p113w_look(+head: P113DStmt, +rest: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,Con{third,more}}:
      nt_choose(P111QCode,p113w_room(code) && p120wp_triple(head,second,third),
        u => p113w_stmts(more,params,ids,p120wp_emit(head,second,ids,code)),
        u => p120wp_original_look(head,rest,params,ids,code))
    case _: p120wp_original_look(head,rest,params,ids,code)
