# Optional direct consumer of the unchanged mature Word-row recognizer and
# Phase112 flow/tail guards. No Word constructor is introduced by this path.
@unsafe
def p113pm_row(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +fresh: U32) -> P113DCode:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),
    u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p113d_prepend(prefix,p113pl_lower(book,kid(row,0),bindings,target,fresh))

law p113pm_rows:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +base: U32
  for +fresh: U32
  P113DCode

@unsafe
def p113pm_join(+row: KTerm, +base: U32, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  p113d_prepend([N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}}],p113d_branch(N111Local{condition},yes,no))

@unsafe
def p113pm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  p113pm_join(row,base,yes,p113pm_rows(book,rows,env,target,base,p113d_fresh(yes)))

@unsafe
def p113pm_rows(book,rows,env,target,base,fresh):
  match rows:
    case Nil{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,fresh))
    case Con{+row,more}: p113pm_more(book,row,more,env,target,base,p113pm_row(book,row,env,target,base,fresh))

@unsafe
def p113pm_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, plan: NW_Rows) -> P113DCode:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P113DCode,valid,
        u => p113d_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p113pm_rows(book,rows,nc_remove_env(env,ix(kid(t,1))),target,n,U32.add(n,3))),
        u => p113d_fail("product: escaping Word tail retains generic recovery",n))

@unsafe
def p113pm_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, recognized: NW_Rows) -> P113DCode:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P113DCode,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p113pm_planned(book,t,env,target,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p113d_fail("product: unrecognized Word rows retain generic recovery",n))

@unsafe
def p113pm_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nw_applicable(kid(t,0)),
    u => nt_choose(P113DCode,U32.is_lt(n,4294967293) && p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p113pm_recognized(book,t,env,target,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p113d_fail("product: Word row freshness refusal",n)),
    u => p113pm_original_match(book,t,env,target,n))
