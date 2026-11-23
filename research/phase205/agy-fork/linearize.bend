# AGY-001: General Binary-Fork Nat-Depth U32.add Reduction Linearization.
# Rewrites checked binary-fork U32.add reductions:
#   f(0n, x, a...)   = BASE(x, a...)
#   f(1n+p, x, a...) = let a = f(p, x, a...); b = f(p, x + (STEP << p), a...) in a + b
# into a guarded tail-recursive Nat loop for d < 32n, preserving exact fallback for d >= 32n.

type AgyPeel is Data:
  AgyPeel{+lams: List<&2,KTerm>, +body: KTerm, +ok: Bool}

type AgyStep is Data:
  AgyStep{+step: U32, +ok: Bool}

type AgyBFResult is Data:
  AgyBFResult{+context: List<&2,KDef>, +defs: List<&2,KDef>, +changed: Bool}

@unsafe
def agy_bf_lam(+name: String, +id: U32, +q: U32, +body: KTerm) -> KTerm:
  KLambda{name,id,q,[body],[],0,0,True{}}

@unsafe
def agy_bf_u32(+n: U32) -> KTerm:
  KLiteral{"U32",n,"",0,0}

@unsafe
def agy_bf_nat(+n: U32) -> KTerm:
  KLiteral{"Nat",n,"",0,0}

@unsafe
def agy_bf_apps(+f: KTerm, args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: f
    case Con{a,rest}: agy_bf_apps(app(f,a),rest)

@unsafe
def agy_bf_type_rest(+t: KTerm, +count: U32) -> U32:
  +ty = j_strip(t)
  kc(U32,p98_tag_eq(ty,"All") && U32.is_lt(count,18),
    u => kc(U32,U32.is_eq(qt(ty),2),
      v => agy_bf_type_rest(kid(ty,1),U32.inc(count)),
      v => 0),
    u => kc(U32,p198e_owner(ty,"U32"),v => count,v => 0))

@unsafe
def agy_bf_type_second(+t: KTerm) -> U32:
  +t1 = j_strip(t)
  kc(U32,p98_tag_eq(t1,"All") && U32.is_eq(qt(t1),2) && p198e_owner(kid(t1,0),"U32"),
    u => agy_bf_type_rest(kid(t1,1),2),
    u => 0)

@unsafe
def agy_bf_type_arity(+t: KTerm) -> U32:
  +t0 = j_strip(t)
  kc(U32,p98_tag_eq(t0,"All") && U32.is_eq(qt(t0),2) && p198e_owner(kid(t0,0),"Nat"),
    u => agy_bf_type_second(kid(t0,1)),
    u => 0)

@unsafe
def agy_bf_peel_cons(+lam_t: KTerm, +rest: AgyPeel) -> AgyPeel:
  match rest:
    case AgyPeel{lams,body,ok}: AgyPeel{Con{lam_t,lams},body,ok}

@unsafe
def agy_bf_peel(+t: KTerm, +n: U32) -> AgyPeel:
  kc(AgyPeel,U32.is_eq(n,0),u => AgyPeel{[],t,True{}},
    u => kc(AgyPeel,p98_tag_eq(t,"Lam"),
      v => agy_bf_peel_cons(t,agy_bf_peel(kid(t,0),U32.sub(n,1))),
      v => AgyPeel{[],t,False{}}))

@unsafe
def agy_bf_is_var(+t: KTerm, +id: U32) -> Bool:
  p98_tag_eq(t,"Var") && U32.is_eq(ix(t),id)

@unsafe
def agy_bf_vars_match(args: List<&2,KTerm>, lams: List<&2,KTerm>) -> Bool:
  match args lams:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{l,lr}: agy_bf_is_var(a,ix(l)) && agy_bf_vars_match(ar,lr)
    case _ _: False{}

@unsafe
def agy_bf_is_shln_args(+a0: KTerm, +a1: KTerm, +pid: U32) -> AgyStep:
  kc(AgyStep,core_literal(a0) && String.eq(nm(a0),"U32") && agy_bf_is_var(a1,pid),
    u => AgyStep{kl_number(a0),True{}},
    u => AgyStep{0,False{}})

@unsafe
def agy_bf_is_shln(+t: KTerm, +pid: U32) -> AgyStep:
  +c = j_call_spine(t,[])
  kc(AgyStep,p98_tag_eq(c,"Call") && String.eq(nm(c),"U32.shln") && U32.is_eq(terms_len(ks(c)),2),
    u => agy_bf_is_shln_args(kid(c,0),kid(c,1),pid),
    u => AgyStep{0,False{}})

@unsafe
def agy_bf_step_pair(+a0: KTerm, +a1: KTerm, +xid: U32, +pid: U32) -> AgyStep:
  kc(AgyStep,agy_bf_is_var(a0,xid),
    u => agy_bf_is_shln(a1,pid),
    u => kc(AgyStep,agy_bf_is_var(a1,xid),v => agy_bf_is_shln(a0,pid),v => AgyStep{0,False{}}))

@unsafe
def agy_bf_step_expr(+t: KTerm, +xid: U32, +pid: U32) -> AgyStep:
  +c = j_call_spine(t,[])
  kc(AgyStep,p98_tag_eq(c,"Call") && String.eq(nm(c),"U32.add") && U32.is_eq(terms_len(ks(c)),2),
    u => agy_bf_step_pair(kid(c,0),kid(c,1),xid,pid),
    u => AgyStep{0,False{}})

@unsafe
def agy_bf_check_add(+t: KTerm, +aid: U32, +bid: U32) -> Bool:
  +c = j_call_spine(t,[])
  p98_tag_eq(c,"Call") && String.eq(nm(c),"U32.add") && U32.is_eq(terms_len(ks(c)),2) &&
    ((agy_bf_is_var(kid(c,0),aid) && agy_bf_is_var(kid(c,1),bid)) ||
     (agy_bf_is_var(kid(c,0),bid) && agy_bf_is_var(kid(c,1),aid)))

@unsafe
def agy_bf_check_left(+call: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> Bool:
  +c = j_call_spine(call,[])
  p98_tag_eq(c,"Call") && String.eq(nm(c),fname) && agy_bf_vars_match(ks(c),lams1)

@unsafe
def agy_bf_check_right_args(args: List<&2,KTerm>, lams1: List<&2,KTerm>) -> AgyStep:
  match args lams1:
    case Con{ap,Con{ax,arest}} Con{+lp,Con{lx,lrest}}:
      kc(AgyStep,agy_bf_is_var(ap,ix(lp)) && agy_bf_vars_match(arest,lrest),
        u => agy_bf_step_expr(ax,ix(lx),ix(lp)),
        u => AgyStep{0,False{}})
    case _ _: AgyStep{0,False{}}

@unsafe
def agy_bf_check_right(+call: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  +c = j_call_spine(call,[])
  kc(AgyStep,p98_tag_eq(c,"Call") && String.eq(nm(c),fname),
    u => agy_bf_check_right_args(ks(c),lams1),
    u => AgyStep{0,False{}})

@unsafe
def agy_bf_check_succ_let(+b0: KTerm, +b1: KTerm, +ret: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  kc(AgyStep,p98_tag_eq(b0,"Bind") && p98_tag_eq(b1,"Bind") &&
      agy_bf_check_add(ret,ix(b0),ix(b1)) && agy_bf_check_left(kid(b0,0),fname,lams1),
    u => agy_bf_check_right(kid(b1,0),fname,lams1),
    u => AgyStep{0,False{}})

@unsafe
def agy_bf_check_succ(+succ_body: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  kc(AgyStep,p98_tag_eq(succ_body,"Let") && U32.is_eq(terms_len(ks(succ_body)),3),
    u => agy_bf_check_succ_let(kid(succ_body,0),kid(succ_body,1),kid(succ_body,2),fname,lams1),
    u => AgyStep{0,False{}})

law agy_bf_rename_list:
  for xs: List<&2,KTerm>
  for +old: String
  for +nw: String
  List<&2,KTerm>

@unsafe
def agy_bf_rename_ref(+t: KTerm, +old: String, +nw: String) -> KTerm:
  kc(KTerm,p98_tag_eq(t,"Ref") && String.eq(nm(t),old),
    u => ref(nw),
    u => k_with_children(t,agy_bf_rename_list(ks(t),old,nw)))

@unsafe
def agy_bf_rename_list(xs, old, nw):
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{agy_bf_rename_ref(x,old,nw),agy_bf_rename_list(rest,old,nw)}

@unsafe
def agy_bf_lams_to_vars(lams: List<&2,KTerm>) -> List<&2,KTerm>:
  match lams:
    case Nil{}: []
    case Con{+l,rest}: Con{var(nm(l),ix(l)),agy_bf_lams_to_vars(rest)}

@unsafe
def agy_bf_wrap_lams(lams: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match lams:
    case Nil{}: body
    case Con{+l,rest}: agy_bf_lam(nm(l),ix(l),2,agy_bf_wrap_lams(rest,body))

@unsafe
def agy_bf_fresh_lams(+n: U32, +base_id: U32, +idx: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>,U32.is_eq(idx,n),u => [],
    u => Con{var("agy_p" ++ U32.show(idx),U32.add(base_id,idx)),agy_bf_fresh_lams(n,base_id,U32.inc(idx))})

@unsafe
def agy_bf_wrap_vars(vs: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match vs:
    case Nil{}: body
    case Con{+v,rest}: agy_bf_lam(nm(v),ix(v),2,agy_bf_wrap_vars(rest,body))

@unsafe
def agy_bf_loop_type(+orig_ty: KTerm, +acc_id: U32) -> KTerm:
  +t0 = j_strip(orig_ty)
  +t1 = j_strip(kid(t0,1))
  all(2,nm(t0),ix(t0),kid(t0,0),
    all(2,nm(t1),ix(t1),kid(t1,0),
      all(2,"agy_acc",acc_id,ref("U32"),kid(t1,1))))

@unsafe
def agy_bf_build_loop(+hname: String, +orig_ty: KTerm, +arity: U32, +lams0: List<&2,KTerm>, +base_expr: KTerm, +step: U32, +bid: U32) -> KDef:
  +zvars = agy_bf_fresh_lams(arity,U32.add(bid,1),0)
  +acc_z = p205u_at(zvars,1)
  +zero_case = agy_bf_wrap_vars(zvars,acc_z)
  +qid = U32.add(bid,30)
  +acc_id = U32.add(bid,31)
  +x0 = p205u_at(lams0,0)
  +tail_lams0 = List.tail(&2,KTerm,lams0)
  +x_next = app(app(ref("U32.add"),var(nm(x0),ix(x0))),agy_bf_u32(step))
  +acc_next = app(app(ref("U32.add"),var("agy_acc",acc_id)),base_expr)
  +rec_call = agy_bf_apps(ref(hname),Con{var("agy_q",qid),Con{x_next,Con{acc_next,agy_bf_lams_to_vars(tail_lams0)}}})
  +succ_inner = agy_bf_lam(nm(x0),ix(x0),2,agy_bf_lam("agy_acc",acc_id,2,agy_bf_wrap_lams(tail_lams0,rec_call)))
  +succ_case = agy_bf_lam("agy_q",qid,2,succ_inner)
  +body = kt("Mat","Zero",0,0,[zero_case,kt("Mat","Succ",0,0,[succ_case,atom("Efq")])])
  KDef{hname,"Def",U32.inc(arity),0,agy_bf_loop_type(orig_ty,bid),body,[],False{},False{}}

@unsafe
def agy_bf_disp_type(+orig_ty: KTerm, +cond_id: U32) -> KTerm:
  all(1,"$agy_c",cond_id,ref("Nat"),j_strip(orig_ty))

@unsafe
def agy_bf_build_disp_helper(+dname: String, +orig_ty: KTerm, +hname: String, +oname: String, +arity: U32, +bid: U32) -> KDef:
  +zvs = agy_bf_fresh_lams(arity,U32.add(bid,60),0)
  +zvd = p205u_at(zvs,0)
  +zvx = p205u_at(zvs,1)
  +zvrest = List.tail(&2,KTerm,List.tail(&2,KTerm,zvs))
  +rem = app(ref("U32.to_nat"),app(app(ref("U32.shln"),agy_bf_u32(1)),zvd))
  +fast = agy_bf_apps(ref(hname),Con{rem,Con{zvx,Con{agy_bf_u32(0),zvrest}}})
  +zero_case = agy_bf_wrap_vars(zvs,fast)
  +svs = agy_bf_fresh_lams(arity,U32.add(bid,90),0)
  +slow = agy_bf_apps(ref(oname),svs)
  +succ_case = agy_bf_lam("$agy_u",U32.add(bid,89),1,agy_bf_wrap_vars(svs,slow))
  +body = kt("Mat","Zero",0,0,[zero_case,kt("Mat","Succ",0,0,[succ_case,atom("Efq")])])
  KDef{dname,"Def",U32.inc(arity),0,agy_bf_disp_type(orig_ty,U32.add(bid,59)),body,[],False{},False{}}

@unsafe
def agy_bf_build_dispatch(+raw: KDef, +dname: String, +arity: U32, +bid: U32) -> KDef:
  +vs = agy_bf_fresh_lams(arity,U32.add(bid,120),0)
  +vd = p205u_at(vs,0)
  +cond = app(app(ref("Nat.sub"),vd),app(ref("U32.to_nat"),agy_bf_u32(31)))
  +call = agy_bf_apps(ref(dname),Con{cond,vs})
  dg_event_output(raw,agy_bf_wrap_vars(vs,call))

@unsafe
def agy_bf_check_one(+context: List<&2,KDef>, +d: KDef) -> KDef:
  +res = check_definition_body(kw_initial(context),d,0)
  kc(KDef,good(res),u => ka_def(context,dg_event_output(d,ct(res))),u => missing())

@unsafe
def agy_bf_strip_cache(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+h,+rest}:
      kc(List<&2,KDef>,p88_string_eq(dk(h),"BookCache"),u => rest,u => Con{h,rest})

@unsafe
def agy_bf_add_def(+context: List<&2,KDef>, +d: KDef) -> List<&2,KDef>:
  +raw_list = {Con{d,agy_bf_strip_cache(context)} : List<&2,KDef>}
  book_cached(raw_list,norm_max_defs([d],norm_book_bound(context)))

@unsafe
def agy_bf_commit_call(+orig_ctx: List<&2,KDef>, +ctx3: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +dname: String, +arity: U32, +bid: U32, +chk_orig: KDef, +chk_loop: KDef, +chk_dh: KDef) -> AgyBFResult:
  +disp_def = agy_bf_build_dispatch(raw,dname,arity,bid)
  +ctx4 = p205z_advance(ctx3,disp_def)
  +chk_disp = agy_bf_check_one(ctx4,disp_def)
  kc(AgyBFResult,String.eq(dk(chk_disp),"Absent"),
    u => AgyBFResult{orig_ctx,Con{orig_d,rest},False{}},
    u => AgyBFResult{p205z_advance(ctx4,chk_disp),Con{chk_orig,Con{chk_loop,Con{chk_dh,Con{chk_disp,rest}}}},True{}})

@unsafe
def agy_bf_commit_disp(+orig_ctx: List<&2,KDef>, +ctx2: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +hname: String, +oname: String, +dname: String, +arity: U32, +bid: U32, +chk_orig: KDef, +chk_loop: KDef) -> AgyBFResult:
  +dh_def = agy_bf_build_disp_helper(dname,dt(raw),hname,oname,arity,bid)
  +ctx3 = agy_bf_add_def(ctx2,dh_def)
  +chk_dh = agy_bf_check_one(ctx3,dh_def)
  kc(AgyBFResult,String.eq(dk(chk_dh),"Absent"),
    u => AgyBFResult{orig_ctx,Con{orig_d,rest},False{}},
    u => agy_bf_commit_call(orig_ctx,agy_bf_add_def(ctx2,chk_dh),orig_d,raw,rest,dname,arity,bid,chk_orig,chk_loop,chk_dh))

@unsafe
def agy_bf_commit_loop(+orig_ctx: List<&2,KDef>, +ctx1: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +hname: String, +oname: String, +dname: String, +arity: U32, +lams0: List<&2,KTerm>, +base_expr: KTerm, +step: U32, +bid: U32, +chk_orig: KDef) -> AgyBFResult:
  +loop_def = agy_bf_build_loop(hname,dt(raw),arity,lams0,base_expr,step,bid)
  +ctx2 = agy_bf_add_def(ctx1,loop_def)
  +chk_loop = agy_bf_check_one(ctx2,loop_def)
  kc(AgyBFResult,String.eq(dk(chk_loop),"Absent"),
    u => AgyBFResult{orig_ctx,Con{orig_d,rest},False{}},
    u => agy_bf_commit_disp(orig_ctx,agy_bf_add_def(ctx1,chk_loop),orig_d,raw,rest,hname,oname,dname,arity,bid,chk_orig,chk_loop))

@unsafe
def agy_bf_commit(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +hname: String, +oname: String, +dname: String, +arity: U32, +clean: KTerm, +lams0: List<&2,KTerm>, +base_expr: KTerm, +step: U32, +bid: U32) -> AgyBFResult:
  +orig_def = {KDef{oname,"Def",arity,0,dt(raw),agy_bf_rename_ref(clean,fname,oname),[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(context,orig_def)
  +chk_orig = agy_bf_check_one(ctx1,orig_def)
  kc(AgyBFResult,String.eq(dk(chk_orig),"Absent"),
    u => AgyBFResult{context,Con{orig_d,rest},False{}},
    u => agy_bf_commit_loop(context,agy_bf_add_def(context,chk_orig),orig_d,raw,rest,hname,oname,dname,arity,lams0,base_expr,step,bid,chk_orig))

@unsafe
def agy_bf_emit(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm, +lams0: List<&2,KTerm>, +base_expr: KTerm, +st: AgyStep) -> AgyBFResult:
  match st:
    case AgyStep{step,ok}:
      +hname = fname ++ "$agy_bf"
      +oname = fname ++ "$agy_orig"
      +dname = fname ++ "$agy_disp"
      kc(AgyBFResult,ok && String.eq(dk(lookup(context,hname)),"Absent") && String.eq(dk(lookup(context,oname)),"Absent") && String.eq(dk(lookup(context,dname)),"Absent"),
        u => agy_bf_commit(context,orig_d,raw,rest,fname,hname,oname,dname,arity,clean,lams0,base_expr,step,U32.inc(norm_book_bound(context))),
        u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_match_peels(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm, +zp: AgyPeel, +sp: AgyPeel) -> AgyBFResult:
  match zp sp:
    case AgyPeel{lams0,base_expr,ok0} AgyPeel{lams1,succ_body,ok1}:
      kc(AgyBFResult,ok0 && ok1 && U32.is_eq(p205u_refs(base_expr,fname),0),
        u => agy_bf_emit(context,orig_d,raw,rest,fname,arity,clean,lams0,base_expr,agy_bf_check_succ(succ_body,fname,lams1)),
        u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_match_succ(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm, +zbr: KTerm, +msucc: KTerm) -> AgyBFResult:
  kc(AgyBFResult,p98_tag_eq(msucc,"Mat") && String.eq(nm(msucc),"Succ") && U32.is_eq(terms_len(ks(msucc)),2) && p98_tag_eq(kid(msucc,1),"Efq"),
    u => agy_bf_match_peels(context,orig_d,raw,rest,fname,arity,clean,agy_bf_peel(zbr,U32.sub(arity,1)),agy_bf_peel(kid(msucc,0),arity)),
    u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_match_body(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +clean: KTerm) -> AgyBFResult:
  kc(AgyBFResult,p98_tag_eq(clean,"Mat") && String.eq(nm(clean),"Zero") && U32.is_eq(terms_len(ks(clean)),2),
    u => agy_bf_match_succ(context,orig_d,raw,rest,fname,arity,clean,kid(clean,0),kid(clean,1)),
    u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_try_def(+context: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>) -> AgyBFResult:
  +fname = dn(raw)
  +arity = kc(U32,String.eq(dk(raw),"Def") && Bool.not(db(raw) || du(raw)) && U32.is_eq(dx(raw),0),
    u => agy_bf_type_arity(dt(raw)),u => 0)
  kc(AgyBFResult,U32.is_ge(arity,2),
    u => agy_bf_match_body(context,orig_d,raw,rest,fname,arity,p205u_clean(dv(raw))),
    u => AgyBFResult{context,Con{orig_d,rest},False{}})

@unsafe
def agy_bf_join(+ch1: Bool, +step_res: AgyBFResult) -> AgyBFResult:
  match step_res:
    case AgyBFResult{ctx2,out2,ch2}: AgyBFResult{ctx2,out2,ch1 || ch2}

@unsafe
def agy_bf_pass_step(+d: KDef, +tail_res: AgyBFResult) -> AgyBFResult:
  match tail_res:
    case AgyBFResult{ctx1,out1,ch1}:
      agy_bf_join(ch1,kc(AgyBFResult,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => agy_bf_try_def(ctx1,d,lookup(ctx1,dn(d)),out1),
        u => AgyBFResult{ctx1,Con{d,out1},False{}}))

@unsafe
def agy_bf_pass(+context: List<&2,KDef>, defs: List<&2,KDef>) -> AgyBFResult:
  match defs:
    case Nil{}: AgyBFResult{context,[],False{}}
    case Con{+d,rest}: agy_bf_pass_step(d,agy_bf_pass(context,rest))

@unsafe
def agy_bf_plan_go(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>, +res: AgyBFResult) -> P86Plan:
  match res:
    case AgyBFResult{ctx1,defs1,changed}:
      kc(P86Plan,changed && String.is_empty(jl_checked_error(ctx1,defs1,["main"],stops)),
        u => p205_ready(ctx1,stops,verdict,defs1,p205u_decls(ctx1,defs1,missing(),False{})),
        u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{})))

@unsafe
def agy_bf_plan(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  agy_bf_plan_go(context,stops,verdict,annotated,agy_bf_pass(context,annotated))
