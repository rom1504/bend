# Recover fixed-width literal patterns through the mature semantic recognizer.
# Rows are planned completely before changing lowering; any escaping Word tail
# refuses the whole match. No Word allocation or new runtime ABI is introduced.
@unsafe
def p112m_fresh_terms(ts: List<&2,KTerm>, +low: U32, +high: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{+t,+rest}:
      (Bool.not(String.eq(tg(t),"Var") || String.eq(tg(t),"Lam") || String.eq(tg(t),"Bind")) || U32.is_lt(ix(t),low) || U32.is_gt(ix(t),high)) &&
        p112m_fresh_terms(ks(t),low,high) && p112m_fresh_terms(rest,low,high)

@unsafe
def p112m_fresh_env(env: List<&2,NC_Binding>, +n: U32) -> Bool:
  match env:
    case Nil{}: True{}
    case Con{NC_Binding{+id,+word,kind},rest}:
      (U32.is_lt(id,nc_id(U32.add(n,2))) || U32.is_gt(id,nc_id(n))) &&
        Bool.not(String.eq(word,"v_" ++ U32.show(nc_id(n))) || String.eq(word,"v_" ++ U32.show(nc_id(U32.inc(n)))) || String.eq(word,"v_" ++ U32.show(nc_id(U32.add(n,2))))) && p112m_fresh_env(rest,n)

@unsafe
def p112m_body(+row: KTerm, +rest: List<&2,KTerm>, +n: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(qt(row),0),u => nd_reapply(kid(row,0),rest),
    u => nd_reapply(nw_restore(nd_beta(kid(row,0),nt_choose(List<&2,KTerm>,U32.is_eq(qt(row),1),
      v => [var("",nc_id(U32.add(n,2)))],v => [var("",nc_id(U32.inc(n))),var("",nc_id(U32.add(n,2)))])),
      nw_prefix(ix(row),nw_value(row),nt_choose(KTerm,U32.is_eq(qt(row),1),
        v => var("",nc_id(U32.add(n,2))),v => nw_word(var("",nc_id(U32.inc(n))),var("",nc_id(U32.add(n,2)))))),nc_id(n)),rest))

@unsafe
def p112m_planned_row(+row: KTerm, +body: KTerm, +n: U32) -> NW_Rows:
  +uses = nc_uses(body)
  NW_Rows{Bool.not(nc_uses_has(uses,nc_id(U32.add(n,2)))),
    [kt("P112MRow",nm(row),ix(row),Bool.to_u32(nc_uses_has(uses,nc_id(U32.inc(n)))),[body])]}

@unsafe
def p112m_plan_rows(rows: List<&2,KTerm>, +rest: List<&2,KTerm>, +n: U32) -> NW_Rows:
  match rows:
    case Nil{}: NW_Rows{True{},[]}
    case Con{+row,more}: nw_join(p112m_planned_row(row,p112m_body(row,rest,n),n),p112m_plan_rows(more,rest,n))

@unsafe
def p112m_mask(+depth: U32) -> U32:
  nt_choose(U32,U32.is_eq(depth,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(depth)),1))

@unsafe
def p112m_row_code(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +base: U32, +fresh: U32) -> P111Code:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p111_prepend(prefix,p111_lower(book,kid(row,0),bindings,fresh))

law p112m_emit:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +base: U32
  for +fresh: U32
  P111Code

@unsafe
def p112m_join(+row: KTerm, +base: U32, +yes: P111Code, +no: P111Code) -> P111Code:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  P111Code{[N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}},
    N111If{N111Local{condition},p111_body(yes),p111_body(no)}],
    nt_append(N111Segment,p111_segments(yes),p111_segments(no)),p111_fresh(no),p111_first(p111_error(yes),p111_error(no))}

@unsafe
def p112m_emit_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +base: U32, +yes: P111Code) -> P111Code:
  p112m_join(row,base,yes,p112m_emit(book,rows,env,base,p111_fresh(yes)))

@unsafe
def p112m_emit(book,rows,env,base,fresh):
  match rows:
    case Nil{}: P111Code{[N111Call{"reply",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]},N111Return{N111Local{"reply"}}],[],fresh,""}
    case Con{+row,more}: p112m_emit_more(book,row,more,env,base,p112m_row_code(book,row,env,base,fresh))

@unsafe
def p112m_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32, plan: NW_Rows) -> P111Code:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P111Code,valid,
        u => p111_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p112m_emit(book,rows,nc_remove_env(env,ix(kid(t,1))),n,U32.add(n,3))),
        u => p112m_original_match_apply(book,t,env,n))

@unsafe
def p112m_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32, recognized: NW_Rows) -> P111Code:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P111Code,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p112m_planned(book,t,env,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p112m_original_match_apply(book,t,env,n))

@unsafe
def p112m_match_apply(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,nw_applicable(kid(t,0)) && U32.is_lt(n,4294967293),
    u => nt_choose(P111Code,p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p112m_recognized(book,t,env,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p112m_original_match_apply(book,t,env,n)),
    u => p112m_original_match_apply(book,t,env,n))
