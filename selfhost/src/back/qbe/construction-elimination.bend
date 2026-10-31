
@unsafe
def p121f_children(xs: List<&2,KTerm>, +depth: U32) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{head,rest}: Con{kt("P121Depth","",depth,0,[head]),p121f_children(rest,depth)}

# Finite syntax budget before recursive shape/scalar checks. Worklist depth is
# explicit and covers every child, including annotations. Exhaustion refuses.

@unsafe
def p121f_budget(todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{+item,rest}:
      nt_choose(Bool,U32.is_gt(fuel,0) && U32.is_lt(ix(item),64),u =>
        p121f_budget(nt_append(KTerm,p121f_children(ks(kid(item,0)),U32.inc(ix(item))),rest),U32.sub(fuel,1)),u => False{})


@unsafe
def p121f_bounded(term: KTerm) -> Bool:
  p121f_budget([kt("P121Depth","",0,0,[term])],2048)


@unsafe
def p121f_defs(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +params: List<&2,NC_Binding>,
  +rc: KTerm, +mc: KTerm, +fc: KTerm, +pc: KTerm,
  +r: KDef, +m: KDef, +f: KDef, +p: KDef) -> P121FPlan:
  +owner = j_fold_root_result(book,dt(p),da(p))
  +empty = nm(j_fusion_after(j_fusion_empty(p),1))
  +link = nm(j_fusion_after(j_fusion_link(p),2))
  +n = j_call_spine(kid(pc,0),[])
  nt_choose(P121FPlan,p121f_bounded(dv(p)) && p121f_bounded(dv(f)) && p121f_bounded(dv(m)) && p121f_bounded(dv(r)) &&
    j_fusion_owner(book,owner,empty,link) &&
    j_region_same_type(book,kid(wnf(book,dt(r)),0),owner) &&
    j_region_same_type(book,kid(wnf(book,dt(m)),0),owner) &&
    j_region_same_type(book,j_fold_root_result(book,dt(m),da(m)),owner) &&
    j_region_same_type(book,kid(wnf(book,dt(f)),0),owner) &&
    j_region_same_type(book,j_fold_root_result(book,dt(f),da(f)),owner) &&
    j_primitive_type(book,j_fold_root_result(book,dt(r),da(r)),"U32") &&
    j_fusion_producer(book,p,empty,link) && j_fusion_filter(book,f,empty,link) &&
    j_fusion_map(book,m,empty,link) && j_fusion_fold(book,r,empty,link) &&
    j_fusion_call(n,"U32.to_nat",1) && j_primitive_call(book,n) &&
    j_fusion_scalar(book,kid(n,0),vars) && j_fusion_scalar(book,kid(pc,1),vars) &&
    j_fusion_scalar(book,kid(rc,1),vars),
    u => P121FPlan{params,p,f,m,r,kid(n,0),kid(pc,1),kid(rc,1)},u => P121FNone{})


@unsafe
def p121f_pipeline(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +params: List<&2,NC_Binding>, +t: KTerm) -> P121FPlan:
  +r = j_call_spine(t,[])
  +m = j_call_spine(kid(r,0),[])
  +f = j_call_spine(kid(m,0),[])
  +p = j_call_spine(kid(f,0),[])
  nt_choose(P121FPlan,String.eq(tg(r),"Call") && U32.is_eq(terms_len(ks(r)),2) &&
    String.eq(tg(m),"Call") && U32.is_eq(terms_len(ks(m)),1) &&
    String.eq(tg(f),"Call") && U32.is_eq(terms_len(ks(f)),1) &&
    String.eq(tg(p),"Call") && U32.is_eq(terms_len(ks(p)),2),
    u => p121f_defs(book,vars,params,r,m,f,p,lookup(book,nm(r)),lookup(book,nm(m)),lookup(book,nm(f)),lookup(book,nm(p))),
    u => P121FNone{})


@unsafe
def p121f_prefix(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm,
  +vars: List<&2,KTerm>, +params: List<&2,NC_Binding>, +at: U32, +left: U32) -> P121FPlan:
  +h = j_strip(t)
  +head = wnf(book,ty)
  nt_choose(P121FPlan,U32.is_eq(left,0),
    u => nt_choose(P121FPlan,j_primitive_type(book,head,"U32"),v => p121f_pipeline(book,vars,params,h),v => P121FNone{}),
    u => nt_choose(P121FPlan,String.eq(tg(h),"Lam") && String.eq(tg(head),"All") &&
      Bool.not(U32.is_eq(qt(head),0)) && j_primitive_type(book,wnf(book,kid(head,0)),"U32"),
      v => p121f_prefix(book,kid(h,0),subst(kid(head,1),ix(head),var(nm(h),ix(h))),Con{h,vars},
        nt_append(NC_Binding,params,[NC_Binding{ix(h),"p121_arg_" ++ U32.show(at),N_W32{}}]),U32.inc(at),U32.sub(left,1)),
      v => P121FNone{}))


@unsafe
def p121f_plan(+book: List<&2,KDef>, +d: KDef) -> P121FPlan:
  +body = j_fusion_after(dv(d),da(d))
  +r = j_call_spine(body,[])
  +m = j_call_spine(kid(r,0),[])
  nt_choose(P121FPlan,j_fusion_def(d,da(d)) && U32.is_gt(da(d),0) && U32.is_le(da(d),8) &&
    String.eq(tg(r),"Call") && U32.is_eq(terms_len(ks(r)),2) &&
    String.eq(tg(m),"Call") && U32.is_eq(terms_len(ks(m)),1),
    u => nt_choose(P121FPlan,p121f_bounded(dv(d)),v => p121f_prefix(book,dv(d),dt(d),[],[],0,da(d)),v => P121FNone{}),u => P121FNone{})


@unsafe
def p121f_expr(+book: List<&2,KDef>, +term: KTerm, +env: List<&2,NC_Binding>, +dest: String, +n: U32) -> P113DCode:
  p113d_lower(book,nc_compact(nc_erase(book,term)),env,"$p121.scalar",P113DLocal{dest},n)


def p121f_ref(name: String) -> N111Value:
  N111Local{name}


@unsafe
def p121f_env(binder: KTerm, word: String) -> NC_Binding:
  NC_Binding{ix(binder),word,N_W32{}}


def p121f_again(acc: String) -> P113DCode:
  P113DCode{[P113DAgain{[p121f_ref("p121_next_n"),p121f_ref("p121_next_seed"),p121f_ref(acc)]}],9000,"",[]}


@unsafe
def p121f_step(+book: List<&2,KDef>, +p: KDef, +f: KDef, +m: KDef, +r: KDef) -> P113DCode:
  +ps = j_fusion_link(p)
  +pb = j_fusion_after(ps,2)
  +pc = j_call_spine(kid(pb,1),[])
  +fs = j_fusion_link(f)
  +fc = j_call_spine(j_fusion_unlet(j_fusion_after(fs,2),8),[])
  +ms = j_fusion_link(m)
  +rs = j_fusion_link(r)
  +rc = j_call_spine(j_fusion_after(rs,3),[])
  +head = p121f_expr(book,kid(pb,0),[p121f_env(j_fusion_binder(ps,1),"p121_seed")],"p121_head",1000)
  +next = p121f_expr(book,kid(pc,1),[p121f_env(j_fusion_binder(ps,1),"p121_seed")],"p121_next_seed",p113d_fresh(head))
  +pred = p121f_expr(book,kid(fc,2),[p121f_env(j_fusion_binder(fs,0),"p121_head")],"p121_pred",p113d_fresh(next))
  +mapped = p121f_expr(book,kid(j_fusion_after(ms,2),0),[p121f_env(j_fusion_binder(ms,0),"p121_head")],"p121_mapped",p113d_fresh(pred))
  +folded = p121f_expr(book,kid(rc,1),[p121f_env(j_fusion_binder(rs,0),"p121_mapped"),p121f_env(j_fusion_binder(rs,2),"p121_acc")],"p121_next_acc",p113d_fresh(mapped))
  p113d_join(head,p113d_join(next,p113d_join(pred,
    p113d_prepend([N111Bin{"p121_next_n",N111U64{},"sub",p121f_ref("p121_n"),N111Const{1,0}},
      N111Bin{"p121_keep",N111U64{},"ne",p121f_ref("p121_pred"),N111Const{0,0}}],
      p113d_branch(p121f_ref("p121_keep"),p113d_join(mapped,p113d_join(folded,p121f_again("p121_next_acc"))),p121f_again("p121_acc"))))))


@unsafe
def p121f_loop(book: List<&2,KDef>, p: KDef, f: KDef, m: KDef, r: KDef) -> P113DCode:
  p113d_prepend([N111Bin{"p121_nonzero",N111U64{},"ne",p121f_ref("p121_n"),N111Const{0,0}}],
    p113d_branch(p121f_ref("p121_nonzero"),p121f_step(book,p,f,m,r),
      P113DCode{[P113DResult{[p121f_ref("p121_acc")]}],9000,"",[]}))


@unsafe
def p121f_functions(+book: List<&2,KDef>, +name: String, plan: P121FPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P121FNone{}: []
    case P121FPlan{+params,p,f,m,r,count,seed,initial}:
      +private = "$p121.stream." ++ name
      +loop = p121f_loop(book,p,f,m,r)
      +count_code = p121f_expr(book,count,params,"p121_count",1000)
      +seed_code = p121f_expr(book,seed,params,"p121_seed0",p113d_fresh(count_code))
      +initial_code = p121f_expr(book,initial,params,"p121_acc0",p113d_fresh(seed_code))
      +entry = p113d_join(count_code,p113d_join(seed_code,p113d_join(initial_code,
        P113DCode{[P113DCall{["p121_result"],private,[p121f_ref("p121_count"),p121f_ref("p121_seed0"),p121f_ref("p121_acc0")]},
          P113DResult{[p121f_ref("p121_result")]}],p113d_fresh(initial_code),"",[private]})))
      [P113DCandidate{P113DFunction{private,[NC_Binding{0,"p121_n",N_W32{}},NC_Binding{1,"p121_seed",N_W32{}},
        NC_Binding{2,"p121_acc",N_W32{}}],1,False{},p113d_body(loop)},p113d_error(loop),p113d_calls(loop)},
       P113DCandidate{P113DFunction{p113d_public(book,name),params,1,True{},p113d_body(entry)},p113d_error(entry),p113d_calls(entry)}]


@unsafe
def p121f_selected(+book: List<&2,KDef>, +name: String, signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  p125p_select(book,lookup(book,name),p125p_previous_selected(book,name,signatures,plan))

# Exact new import contract. The original generic verifier is unchanged.

@unsafe
def p121f_inspect(request: NR_Request, name: String) -> P121FPlan:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: p121f_plan(book,lookup(book,name))

@unsafe
def p121c_source_prefix(+book: List<&2,KDef>, +ty: KTerm, +term: KTerm, +left: U32) -> KTerm:
  +h = wnf(book,ty)
  +t = j_strip(term)
  nt_choose(KTerm,U32.is_eq(left,0),u => t,u =>
    nt_choose(KTerm,String.eq(tg(h),"All") && U32.is_eq(qt(h),0) && j_callback_type_domain(book,kid(h,0)) &&
      String.eq(tg(t),"Lam") && U32.is_eq(qt(t),0) && U32.is_eq(terms_len(ks(t)),1) &&
      j_callback_runtime_absent(kid(t,0),ix(t),2048),v =>
      k_rebuild(t,nm(t),ix(t),1,[p121c_source_prefix(book,kid(h,1),kid(t,0),U32.sub(left,1))],rm(t),0,0),
      v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


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
def p121c_inspect(request: NR_Request, name: String) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: p121c_admitted(book,lookup(book,name))
