# Optional hosted probe only. Calls the actual installed Bend pass and compares its emitted cache facts.
@unsafe
def p205t_term_has(+todo: List<&2,KTerm>,+target: String) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{+h,+rest}:
      (String.eq(nm(h),target) && (String.eq(tg(h),"Mat") || String.eq(tg(h),"Ctr"))) ||
        p205t_term_has(nt_choose(List<&2,KTerm>,String.eq(tg(h),"Var"),u => rest,u => nt_append(KTerm,ks(h),rest)),target)

@unsafe
def p205t_observe_names(+old: List<&2,KDef>,+book: List<&2,KDef>,+ns: List<&2,String>,+count: U32) -> String:
  match ns:
    case Nil{}: "changed:" ++ U32.show(count)
    case Con{+n,+t}:
      +changed = p205t_term_has([dv(ns_body(book,n))],p205t_left_tag()) && p205t_term_has([dv(ns_body(book,n))],p205t_right_tag()) &&
        Bool.not(p205t_term_has([dv(ns_body(old,n))],p205t_left_tag()))
      p205t_observe_names(old,book,t,U32.add(count,nt_bool(changed)))

@unsafe
def p205t_observe_product(+old: List<&2,KDef>,+names: List<&2,String>,+p: P205TProduct) -> String:
  match p:
    case P205TProduct{+book,+cs}:
      nt_choose(String,nc_has_ctor(cs,p205t_left_tag()) && nc_has_ctor(cs,p205t_right_tag()),
        u => p205t_observe_names(old,book,names,0),u => "unchanged")

@unsafe
def p205t_observe_request(+r: NR_Request) -> String:
  match r:
    case NR_Request{+source,+book,+names,+paths,+scope,Some{+bound}}:
      +cs = nc_add_ctors(nc_default_ctors(),p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))
      p205t_observe_product(book,names,p205t_apply(book,names,cs,bound))
    case _: "unbounded"

@unsafe
def p205t_probe(+p: P86Plan) -> String:
  match p:
    case P86PlanReady{+r,+v}: p205t_observe_request(r)
    case P86PlanError{+e}: "frontend error " ++ e
