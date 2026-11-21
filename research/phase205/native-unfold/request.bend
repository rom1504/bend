# One fresh-id-producing edit per request. Text-only edits do not use this slot.
type P205UPick is Data:
  P205UPick{+change: KDef, +used: Bool}
@unsafe
def p205u_check(+context: List<&2,KDef>, +raw: KDef, +body: KTerm) -> KDef:
  kc(KDef,p98_tag_eq(body,"Absent"),u => missing(),u =>
    p205u_checked(context,dg_event_output(raw,body),check_definition_body(kw_initial(context),dg_event_output(raw,body),0)))
@unsafe
def p205u_checked(+context: List<&2,KDef>, +changed: KDef, +result: KChecking) -> KDef:
  kc(KDef,good(result),u => ka_def(context,dg_event_output(changed,ct(result))),u => missing())
@unsafe
def p205u_record(+change: KDef, +used: Bool) -> P205UPick:
  P205UPick{change,used || Bool.not(String.eq(dk(change),"Absent"))}
@unsafe
def p205u_pick(+context: List<&2,KDef>, +raw: KDef, +used: Bool) -> P205UPick:
  +text = kc(KTerm,p205_returns_string(dt(raw)),u => p205_tail(context,dv(raw)),u => atom("Absent"))
  kc(P205UPick,p98_tag_eq(text,"Absent"),u =>
    kc(P205UPick,used,v => P205UPick{missing(),True{}},v =>
      p205u_record(p205u_select(context,raw),used)),u =>
      P205UPick{p205u_check(context,raw,text),used})
@unsafe
def p205u_decls(+context: List<&2,KDef>, +defs: List<&2,KDef>, +edits: KDef, +used: Bool) -> KDef:
  match defs:
    case Nil{}: edits
    case Con{d,rest}:
      p205u_next_decl(context,rest,edits,kc(P205UPick,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => p205u_pick(context,lookup(context,dn(d)),used),u => P205UPick{missing(),used}))
@unsafe
def p205u_next_decl(+context: List<&2,KDef>, +rest: List<&2,KDef>, +edits: KDef, +pick: P205UPick) -> KDef:
  match pick:
    case P205UPick{change,used}:
      p205u_decls(context,rest,kc(KDef,String.eq(dk(change),"Absent"),u => edits,u =>
        index_set(edits,change,index_hash(dn(change),2166136261),32)),used)
@unsafe
def p205u_list(+context: List<&2,KDef>, +defs: List<&2,KDef>, +used: Bool) -> List<&2,KDef>:
  match defs:
    case Nil{}: []
    case Con{d,rest}:
      p205u_next_list(context,d,rest,kc(P205UPick,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => p205u_pick(context,lookup(context,dn(d)),used),u => P205UPick{missing(),used}))
@unsafe
def p205u_next_list(+context: List<&2,KDef>, +original: KDef, +rest: List<&2,KDef>, +pick: P205UPick) -> List<&2,KDef>:
  match pick:
    case P205UPick{change,used}:
      Con{kc(KDef,String.eq(dk(change),"Absent"),u => original,u => change),p205u_list(context,rest,used)}
