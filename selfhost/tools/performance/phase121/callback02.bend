# Native request definitions carry checked erased Lam quantities (q0), whereas
# JS helper lookup retains source Lam q1. Adapt only the analysis view, after
# proving exact erased formals and absence from runtime syntax. Never emit it.
@unsafe
def p121c_source_prefix(+book: List<&2,KDef>, +ty: KTerm, +term: KTerm, +left: U32) -> KTerm:
  +h = wnf(book,ty)
  +t = j_strip(term)
  nt_choose(KTerm,U32.is_eq(left,0),u => t,u =>
    nt_choose(KTerm,String.eq(tg(h),"All") && U32.is_eq(qt(h),0) && j_callback_type_domain(book,kid(h,0)) &&
      String.eq(tg(t),"Lam") && U32.is_eq(qt(t),0) && U32.is_eq(terms_len(ks(t)),1) &&
      j_callback_runtime_absent(kid(t,0),ix(t),2048),v =>
      k_rebuild(t,nm(t),ix(t),1,[p121c_source_prefix(book,kid(h,1),kid(t,0),U32.sub(left,1))],rm(t),0,0),
      v => atom("Absent")))

@unsafe
def p121c_factory(+book: List<&2,KDef>, +factory: KDef) -> Bool:
  +body = j_fusion_after(j_fusion_link(factory),1)
  +call = j_call_spine(kid(body,1),[])
  +c = lookup(book,nm(call))
  nt_choose(Bool,j_callback_factory(book,factory),u => True{},u =>
    nt_choose(Bool,j_fusion_def(c,5) && p121f_bounded(dv(c)),v =>
      j_callback_factory(book_put(book,KDef{dn(c),dk(c),da(c),dx(c),dt(c),
        p121c_source_prefix(book,dt(c),dv(c),3),dc(c),db(c),du(c)}),factory),v => False{}))

# Eliminate private total scalar closure construction/application. Reuse the
# existing checked JS factory/composition recognizers, not source names.
@unsafe
def p121c_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book,ty)
  nt_choose(Bool,U32.is_eq(left,0),u => j_primitive_type(book,head,"U32"),u =>
    String.eq(tg(head),"All") && Bool.not(U32.is_eq(qt(head),0)) &&
    j_primitive_type(book,wnf(book,kid(head,0)),"U32") && p121c_signature(book,kid(head,1),U32.sub(left,1)))

@unsafe
def p121c_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +call = j_call_spine(j_fusion_after(dv(d),2),[])
  +count = j_call_spine(kid(call,0),[])
  nt_choose(Bool,j_fusion_def(d,2) && String.eq(tg(call),"Call") && U32.is_eq(terms_len(ks(call)),2) &&
    j_fusion_call(count,"U32.to_nat",1),u =>
    p121f_bounded(dv(d)) && p121c_signature(book,dt(d),2) &&
    String.eq(tg(j_fusion_binder(dv(d),0)),"Lam") && String.eq(tg(j_fusion_binder(dv(d),1)),"Lam") &&
    j_primitive_call(book,count) &&
    j_fusion_scalar(book,kid(count,0),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
    j_fusion_scalar(book,kid(call,1),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
    p121f_bounded(dv(lookup(book,nm(call)))) && p121c_factory(book,lookup(book,nm(call))),u => False{})

@unsafe
def p121c_step(+book: List<&2,KDef>, +factory: KDef) -> P113DCode:
  +s = j_fusion_link(factory)
  +pred = j_fusion_binder(s,0)
  +body = j_fusion_after(s,1)
  +binding = kid(body,0)
  +call = j_call_spine(kid(body,1),[])
  +leaf = j_strip(kid(call,3))
  +capture = p121f_expr(book,j_callback_capture_u32(kid(binding,0)),
    [p121f_env(pred,"p121_predecessor")],"p121_capture",1000)
  +value = p121f_expr(book,kid(leaf,0),
    [p121f_env(binding,"p121_capture"),p121f_env(leaf,"p121_value")],"p121_next_value",p113d_fresh(capture))
  p113d_prepend([N111Bin{"p121_predecessor",N111U64{},"sub",p121f_ref("p121_n"),N111Const{1,0}}],
    p113d_join(capture,p113d_join(value,P113DCode{[
      P113DAgain{[p121f_ref("p121_predecessor"),p121f_ref("p121_next_value")]}],p113d_fresh(value),"",[]})))

@unsafe
def p121c_functions(+book: List<&2,KDef>, +d: KDef) -> List<&2,P113DCandidate>:
  +call = j_call_spine(j_fusion_after(dv(d),2),[])
  +count = j_call_spine(kid(call,0),[])
  +private = "$p121.callback." ++ dn(d)
  +params : List<&2,NC_Binding> = [p121f_env(j_fusion_binder(dv(d),0),"p121_arg0"),p121f_env(j_fusion_binder(dv(d),1),"p121_arg1")]
  +loop = p113d_prepend([N111Bin{"p121_nonzero",N111U64{},"ne",p121f_ref("p121_n"),N111Const{0,0}}],
    p113d_branch(p121f_ref("p121_nonzero"),p121c_step(book,lookup(book,nm(call))),
      P113DCode{[P113DResult{[p121f_ref("p121_value")]}],0,"",[]}))
  +count_code = p121f_expr(book,kid(count,0),params,"p121_count",1000)
  +seed_code = p121f_expr(book,kid(call,1),params,"p121_initial",p113d_fresh(count_code))
  +entry = p113d_join(count_code,p113d_join(seed_code,P113DCode{[
    P113DCall{["p121_result"],private,[p121f_ref("p121_count"),p121f_ref("p121_initial")]},
    P113DResult{[p121f_ref("p121_result")]}],p113d_fresh(seed_code),"",[private]}))
  [P113DCandidate{P113DFunction{private,[NC_Binding{0,"p121_n",N_W32{}},NC_Binding{1,"p121_value",N_W32{}}],
    1,False{},p113d_body(loop)},p113d_error(loop),p113d_calls(loop)},
   P113DCandidate{P113DFunction{p113d_public(book,dn(d)),params,1,True{},p113d_body(entry)},p113d_error(entry),p113d_calls(entry)}]

@unsafe
def p121f_selected(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P121FNone{}:
      +d = lookup(book,name)
      nt_choose(List<&2,P113DCandidate>,p121c_admitted(book,d),u => p121c_functions(book,d),
        u => p118t_retry(book,name,p113pl_boxed_candidate(book,name,signatures)))
    case _: p121f_functions(book,name,plan)

@unsafe
def p121c_inspect(request: NR_Request, name: String) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: p121c_admitted(book,lookup(book,name))
