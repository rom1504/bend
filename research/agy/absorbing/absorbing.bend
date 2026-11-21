# AGY-005b: General Absorbing-State Early-Exit for Fueled Tail-Recursive Loops.
# Recognizes pure, safe fueled tail-recursive loops:
#   f(0n,   a..., st, b...) = st
#   f(1n+p, a..., st, b...) = f(p, a..., step(inv..., st), b...)
# where `step` is a pure, non-recursive Def whose arguments before `st` are
# invariant parameters of `f`. Inlines `step` into `f`'s Succ branch, tracks
# the matched pattern of `st` across nested `Mat`/`Lam` nodes, and whenever a
# match arm returns the exact reconstructed/unchanged `st`, emits an immediate
# early return instead of recursing `f(p, ..., st)`. Rechecks with
# `check_definition_body` + `ka_def`.

type AgyAbsPeel is Data:
  AgyAbsPeel{+lams: List<&2,KTerm>, +body: KTerm, +ok: Bool}

type AgyAbsWalk is Data:
  AgyAbsWalk{+term: KTerm, +hit: Bool, +ok: Bool}

type AgyAbsResult is Data:
  AgyAbsResult{+context: List<&2,KDef>, +defs: List<&2,KDef>, +changed: Bool}

@unsafe
def agy_abs_lam(+name: String, +id: U32, +q: U32, +body: KTerm) -> KTerm:
  KLambda{name,id,q,[body],[],0,0,True{}}

@unsafe
def agy_abs_apps(+f: KTerm, args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: f
    case Con{a,rest}: agy_abs_apps(app(f,a),rest)

@unsafe
def agy_abs_is_var(+t: KTerm, +id: U32) -> Bool:
  p98_tag_eq(t,"Var") && U32.is_eq(ix(t),id)

@unsafe
def agy_abs_peel_cons(+lam_t: KTerm, +rest: AgyAbsPeel) -> AgyAbsPeel:
  match rest:
    case AgyAbsPeel{lams,body,ok}: AgyAbsPeel{Con{lam_t,lams},body,ok}

@unsafe
def agy_abs_peel(+t: KTerm, +n: U32) -> AgyAbsPeel:
  kc(AgyAbsPeel,U32.is_eq(n,0),u => AgyAbsPeel{[],t,True{}},
    u => kc(AgyAbsPeel,p98_tag_eq(t,"Lam"),
      v => agy_abs_peel_cons(t,agy_abs_peel(kid(t,0),U32.sub(n,1))),
      v => AgyAbsPeel{[],t,False{}}))

@unsafe
def agy_abs_find_var(lams: List<&2,KTerm>, +id: U32, +idx: U32) -> U32:
  match lams:
    case Nil{}: 999999
    case Con{+l,rest}:
      kc(U32,U32.is_eq(ix(l),id),u => idx,u => agy_abs_find_var(rest,id,U32.inc(idx)))

@unsafe
def agy_abs_in_inv(lams: List<&2,KTerm>, +st_idx: U32, +cur: U32, +id: U32) -> Bool:
  match lams:
    case Nil{}: False{}
    case Con{+l,rest}:
      kc(Bool,Bool.not(U32.is_eq(cur,st_idx)) && U32.is_eq(ix(l),id),
        u => True{},
        u => agy_abs_in_inv(rest,st_idx,U32.inc(cur),id))

@unsafe
def agy_abs_check_rest_inv(args: List<&2,KTerm>, r_lams: List<&2,KTerm>) -> Bool:
  match args r_lams:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+l,lr}: agy_abs_is_var(a,ix(l)) && agy_abs_check_rest_inv(ar,lr)
    case _ _: False{}

@unsafe
def agy_abs_check_call_args(+args: List<&2,KTerm>, +r_lams: List<&2,KTerm>, +st_idx: U32, +cur: U32) -> KTerm:
  match args r_lams:
    case Nil{} Nil{}: atom("Absent")
    case Con{+a,+ar} Con{+l,+lr}:
      kc(KTerm,U32.is_eq(cur,st_idx),
        u => kc(KTerm,agy_abs_check_rest_inv(ar,lr),v => a,v => atom("Absent")),
        u => kc(KTerm,agy_abs_is_var(a,ix(l)),
          v => agy_abs_check_call_args(ar,lr,st_idx,U32.inc(cur)),
          v => atom("Absent")))
    case _ _: atom("Absent")

@unsafe
def agy_abs_check_step_args(+sargs: List<&2,KTerm>, +r_lams: List<&2,KTerm>, +st_idx: U32, +st_id: U32) -> Bool:
  match sargs:
    case Nil{}: False{}
    case Con{+a,Nil{}}: agy_abs_is_var(a,st_id)
    case Con{+a,+rest}:
      p98_tag_eq(a,"Var") && agy_abs_in_inv(r_lams,st_idx,0,ix(a)) && agy_abs_check_step_args(rest,r_lams,st_idx,st_id)

@unsafe
def agy_abs_subst_lams(+body: KTerm, lams: List<&2,KTerm>, sargs: List<&2,KTerm>) -> KTerm:
  match lams sargs:
    case Nil{} _: body
    case Con{+l,lr} Con{+a,ar}: agy_abs_subst_lams(subst(body,ix(l),a),lr,ar)
    case _ _: body

@unsafe
def agy_abs_hole(+hid: U32) -> KTerm:
  kt("AgyHole","",hid,0,[])

@unsafe
def agy_abs_make_holes(+start: U32, +n: U32) -> List<&2,U32>:
  kc(List<&2,U32>,U32.is_eq(n,0),u => [],
    u => Con{start,agy_abs_make_holes(U32.inc(start),U32.sub(n,1))})

@unsafe
def agy_abs_hole_terms(hs: List<&2,U32>) -> List<&2,KTerm>:
  match hs:
    case Nil{}: []
    case Con{h,rest}: Con{agy_abs_hole(h),agy_abs_hole_terms(rest)}

law agy_abs_fill_list:
  for xs: List<&2,KTerm>
  for +hid: U32
  for +val: KTerm
  List<&2,KTerm>

@unsafe
def agy_abs_fill(+pat: KTerm, +hid: U32, +val: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(pat,"AgyHole") && U32.is_eq(ix(pat),hid),
    u => val,
    u => k_with_children(pat,agy_abs_fill_list(ks(pat),hid,val)))

@unsafe
def agy_abs_fill_list(xs, hid, val):
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{agy_abs_fill(x,hid,val),agy_abs_fill_list(rest,hid,val)}

law agy_abs_eq_list:
  for xs: List<&2,KTerm>
  for ys: List<&2,KTerm>
  Bool

@unsafe
def agy_abs_eq(+t: KTerm, +pat: KTerm) -> Bool:
  kc(Bool,p98_tag_eq(pat,"Var"),
    u => p98_tag_eq(t,"Var") && U32.is_eq(ix(t),ix(pat)),
    u => kc(Bool,p98_tag_eq(pat,"Ctr"),
      v => p98_tag_eq(t,"Ctr") && String.eq(nm(t),nm(pat)) && agy_abs_eq_list(ks(t),ks(pat)),
      v => False{}))

@unsafe
def agy_abs_eq_list(xs, ys):
  match xs ys:
    case Nil{} Nil{}: True{}
    case Con{x,xr} Con{y,yr}: agy_abs_eq(x,y) && agy_abs_eq_list(xr,yr)
    case _ _: False{}

@unsafe
def agy_abs_build_args(r_lams: List<&2,KTerm>, +st_idx: U32, +cur: U32, +next_st: KTerm) -> List<&2,KTerm>:
  match r_lams:
    case Nil{}: []
    case Con{+l,rest}:
      Con{kc(KTerm,U32.is_eq(cur,st_idx),u => next_st,u => var(nm(l),ix(l))),
        agy_abs_build_args(rest,st_idx,U32.inc(cur),next_st)}

@unsafe
def agy_abs_rec_call(+fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +next_st: KTerm) -> KTerm:
  agy_abs_apps(ref(fname),Con{var(nm(p_lam),ix(p_lam)),agy_abs_build_args(r_lams,st_idx,0,next_st)})

law agy_abs_wrap_let_kids:
  for xs: List<&2,KTerm>
  for +fname: String
  for +p_lam: KTerm
  for +r_lams: List<&2,KTerm>
  for +st_idx: U32
  List<&2,KTerm>

@unsafe
def agy_abs_wrap_tail(+t: KTerm, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32) -> KTerm:
  kc(KTerm,p98_tag_eq(t,"Let") && U32.is_gt(terms_len(ks(t)),0),
    u => k_with_children(t,agy_abs_wrap_let_kids(ks(t),fname,p_lam,r_lams,st_idx)),
    u => agy_abs_rec_call(fname,p_lam,r_lams,st_idx,t))

@unsafe
def agy_abs_wrap_let_kids(xs, fname, p_lam, r_lams, st_idx):
  match xs:
    case Nil{}: []
    case Con{x,Nil{}}: [agy_abs_wrap_tail(x,fname,p_lam,r_lams,st_idx)]
    case Con{x,rest}: Con{x,agy_abs_wrap_let_kids(rest,fname,p_lam,r_lams,st_idx)}

@unsafe
def agy_abs_ctor_arity_def(+cdef: KDef) -> U32:
  kc(U32,String.eq(dk(cdef),"Absent"),u => 999999,u => da(cdef))

@unsafe
def agy_abs_ctor_arity(+ctx: List<&2,KDef>, +cname: String) -> U32:
  +parent = kr_parent(ctx,cname)
  kc(U32,String.eq(dk(parent),"Absent"),u => 999999,u => agy_abs_ctor_arity_def(lookup(dc(parent),cname)))

law agy_abs_walk:
  for +ctx: List<&2,KDef>
  for +m: KTerm
  for +pat: KTerm
  for +pending: List<&2,U32>
  for +next_h: U32
  for +fname: String
  for +p_lam: KTerm
  for +r_lams: List<&2,KTerm>
  for +st_idx: U32
  AgyAbsWalk

@unsafe
def agy_abs_walk_mat_join(+m: KTerm, +w_arm: AgyAbsWalk, +w_rest: AgyAbsWalk) -> AgyAbsWalk:
  match w_arm w_rest:
    case AgyAbsWalk{arm2,h1,ok1} AgyAbsWalk{rest2,h2,ok2}:
      AgyAbsWalk{k_with_children(m,[arm2,rest2]),h1 || h2,ok1 && ok2}

@unsafe
def agy_abs_walk_mat_go(+ctx: List<&2,KDef>, +m: KTerm, +pat: KTerm, +h0: U32, +hrest: List<&2,U32>, +next_h: U32, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +cname: String, +carity: U32) -> AgyAbsWalk:
  +new_hs = agy_abs_make_holes(next_h,carity)
  +cpat = kt("Ctr",cname,0,1,agy_abs_hole_terms(new_hs))
  +pat_arm = agy_abs_fill(pat,h0,cpat)
  +pend_arm = List.append(&2,U32,new_hs,hrest)
  +w_arm = agy_abs_walk(ctx,kid(m,0),pat_arm,pend_arm,U32.add(next_h,carity),fname,p_lam,r_lams,st_idx)
  +w_rest = agy_abs_walk(ctx,kid(m,1),pat,Con{h0,hrest},next_h,fname,p_lam,r_lams,st_idx)
  agy_abs_walk_mat_join(m,w_arm,w_rest)

@unsafe
def agy_abs_walk_mat(+ctx: List<&2,KDef>, +m: KTerm, +pat: KTerm, +h0: U32, +hrest: List<&2,U32>, +next_h: U32, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32) -> AgyAbsWalk:
  +cname = nm(m)
  +carity = agy_abs_ctor_arity(ctx,cname)
  kc(AgyAbsWalk,U32.is_lt(carity,100) && U32.is_eq(terms_len(ks(m)),2),
    u => agy_abs_walk_mat_go(ctx,m,pat,h0,hrest,next_h,fname,p_lam,r_lams,st_idx,cname,carity),
    u => AgyAbsWalk{m,False{},False{}})

@unsafe
def agy_abs_walk_lam_join(+m: KTerm, +w_body: AgyAbsWalk) -> AgyAbsWalk:
  match w_body:
    case AgyAbsWalk{body2,hit,ok}:
      AgyAbsWalk{agy_abs_lam(nm(m),ix(m),qt(m),body2),hit,ok}

@unsafe
def agy_abs_walk(ctx, m, pat, pending, next_h, fname, p_lam, r_lams, st_idx):
  match pending:
    case Nil{}:
      kc(AgyAbsWalk,agy_abs_eq(m,pat),
        u => AgyAbsWalk{m,True{},True{}},
        u => AgyAbsWalk{agy_abs_wrap_tail(m,fname,p_lam,r_lams,st_idx),False{},True{}})
    case Con{+h0,+hrest}:
      kc(AgyAbsWalk,p98_tag_eq(m,"Mat"),
        u => agy_abs_walk_mat(ctx,m,pat,h0,hrest,next_h,fname,p_lam,r_lams,st_idx),
        u => kc(AgyAbsWalk,p98_tag_eq(m,"Efq"),
          v => AgyAbsWalk{m,False{},True{}},
          v => kc(AgyAbsWalk,p98_tag_eq(m,"Lam"),
            w => agy_abs_walk_lam_join(m,agy_abs_walk(ctx,kid(m,0),agy_abs_fill(pat,h0,var(nm(m),ix(m))),hrest,next_h,fname,p_lam,r_lams,st_idx)),
            w => AgyAbsWalk{m,False{},False{}})))

@unsafe
def agy_abs_wrap_lams(lams: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match lams:
    case Nil{}: body
    case Con{+l,rest}: agy_abs_lam(nm(l),ix(l),qt(l),agy_abs_wrap_lams(rest,body))

@unsafe
def agy_abs_drop_last(lams: List<&2,KTerm>) -> List<&2,KTerm>:
  match lams:
    case Nil{}: []
    case Con{_,Nil{}}: []
    case Con{l,rest}: Con{l,agy_abs_drop_last(rest)}

@unsafe
def agy_abs_build_sbr_app(+p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> KTerm:
  +st_lam = p205u_at(r_lams,st_idx)
  agy_abs_lam(nm(p_lam),ix(p_lam),qt(p_lam),agy_abs_wrap_lams(r_lams,app(m2,var(nm(st_lam),ix(st_lam)))))

@unsafe
def agy_abs_build_sbr(+arity: U32, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> KTerm:
  kc(KTerm,U32.is_eq(st_idx,U32.sub(arity,2)),
    u => agy_abs_lam(nm(p_lam),ix(p_lam),qt(p_lam),agy_abs_wrap_lams(agy_abs_drop_last(r_lams),m2)),
    u => agy_abs_build_sbr_app(p_lam,r_lams,st_idx,m2))

@unsafe
def agy_abs_commit_ok(+ctx_chk: List<&2,KDef>, +chk: KDef, +rest: List<&2,KDef>) -> AgyAbsResult:
  AgyAbsResult{p205z_advance(ctx_chk,chk),Con{chk,rest},True{}}

@unsafe
def agy_abs_commit_checked(+ctx: List<&2,KDef>, +ctx_chk: List<&2,KDef>, +orig_d: KDef, +cand_def: KDef, +rest: List<&2,KDef>, +res: KChecking) -> AgyAbsResult:
  kc(AgyAbsResult,good(res),
    v => agy_abs_commit_ok(ctx_chk,ka_def(ctx_chk,dg_event_output(cand_def,ct(res))),rest),
    v => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_commit_go(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> AgyAbsResult:
  +new_sbr = agy_abs_build_sbr(arity,p_lam,r_lams,st_idx,m2)
  +new_body = kt("Mat","Zero",0,1,[zbr,kt("Mat","Succ",0,1,[new_sbr,atom("Efq")])])
  +cand_def = dg_event_output(raw,new_body)
  +ctx_chk = p205z_advance(ctx,cand_def)
  agy_abs_commit_checked(ctx,ctx_chk,orig_d,cand_def,rest,check_definition_body(kw_initial(ctx_chk),cand_def,0))

@unsafe
def agy_abs_commit(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +walk_res: AgyAbsWalk) -> AgyAbsResult:
  match walk_res:
    case AgyAbsWalk{m2,hit,ok}:
      kc(AgyAbsResult,hit && ok,
        u => agy_abs_commit_go(ctx,orig_d,raw,rest,arity,zbr,p_lam,r_lams,st_idx,m2),
        u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_inline_peeled(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +sargs: List<&2,KTerm>, +peel: AgyAbsPeel) -> AgyAbsResult:
  match peel:
    case AgyAbsPeel{slams,smat,ok}:
      kc(AgyAbsResult,ok,
        v => agy_abs_commit(ctx,orig_d,raw,rest,arity,zbr,p_lam,r_lams,st_idx,
          agy_abs_walk(ctx,agy_abs_subst_lams(smat,slams,sargs),agy_abs_hole(0),[0],1,fname,p_lam,r_lams,st_idx)),
        v => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_inline_fresh(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +step_arity: U32, +sargs: List<&2,KTerm>, +ff: FFresh) -> AgyAbsResult:
  match ff:
    case FFresh{fresh_step,_}:
      agy_abs_inline_peeled(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,sargs,agy_abs_peel(fresh_step,U32.sub(step_arity,1)))

@unsafe
def agy_abs_inline_step(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +step_def: KDef, +sargs: List<&2,KTerm>) -> AgyAbsResult:
  +step_clean = p205u_clean(dv(step_def))
  +step_arity = da(step_def)
  kc(AgyAbsResult,U32.is_eq(p205u_refs(step_clean,fname),0) && U32.is_eq(p205u_refs(step_clean,dn(step_def)),0),
    u => agy_abs_inline_fresh(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,step_arity,sargs,f_fresh_term(step_clean,Nil{},U32.inc(norm_book_bound(ctx)))),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_check_step(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +next_st: KTerm) -> AgyAbsResult:
  +sc = j_call_spine(next_st,[])
  +sname = nm(sc)
  +sargs = ks(sc)
  +sdef = kc(KDef,p98_tag_eq(sc,"Call") && Bool.not(String.eq(sname,fname)),u => lookup(ctx,sname),u => missing())
  +st_id = ix(p205u_at(r_lams,st_idx))
  kc(AgyAbsResult,String.eq(dk(sdef),"Def") && Bool.not(db(sdef) || du(sdef)) && U32.is_eq(dx(sdef),0) &&
      U32.is_ge(da(sdef),1) && U32.is_eq(terms_len(sargs),da(sdef)) &&
      agy_abs_check_step_args(sargs,r_lams,st_idx,st_id),
    u => agy_abs_inline_step(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,sdef,sargs),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_match_sbody_call(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +st_idx: U32, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +cargs: List<&2,KTerm>) -> AgyAbsResult:
  +next_st = kc(KTerm,agy_abs_is_var(p205u_at(cargs,0),ix(p_lam)),
    v => agy_abs_check_call_args(List.tail(&2,KTerm,cargs),r_lams,st_idx,0),
    v => atom("Absent"))
  kc(AgyAbsResult,Bool.not(p98_tag_eq(next_st,"Absent")),
    v => agy_abs_check_step(ctx,orig_d,raw,rest,fname,arity,zbr,p_lam,r_lams,st_idx,next_st),
    v => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_match_sbody(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +st_idx: U32, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +sbody: KTerm) -> AgyAbsResult:
  +c = j_call_spine(sbody,[])
  kc(AgyAbsResult,p98_tag_eq(c,"Call") && String.eq(nm(c),fname) && U32.is_eq(terms_len(ks(c)),arity),
    u => agy_abs_match_sbody_call(ctx,orig_d,raw,rest,fname,arity,zbr,st_idx,p_lam,r_lams,ks(c)),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_match_peels_go(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +st_idx: U32, lams1: List<&2,KTerm>, +sbody: KTerm) -> AgyAbsResult:
  match lams1:
    case Con{p_lam,r_lams}: agy_abs_match_sbody(ctx,orig_d,raw,rest,fname,arity,zbr,st_idx,p_lam,r_lams,sbody)
    case Nil{}: AgyAbsResult{ctx,Con{orig_d,rest},False{}}

@unsafe
def agy_abs_match_peels(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +zp: AgyAbsPeel, +sp: AgyAbsPeel) -> AgyAbsResult:
  match zp sp:
    case AgyAbsPeel{lams0,zbody,ok0} AgyAbsPeel{lams1,sbody,ok1}:
      +st_idx = kc(U32,ok0 && ok1 && p98_tag_eq(zbody,"Var"),u => agy_abs_find_var(lams0,ix(zbody),0),u => 999999)
      kc(AgyAbsResult,U32.is_lt(st_idx,U32.sub(arity,1)),
        u => agy_abs_match_peels_go(ctx,orig_d,raw,rest,fname,arity,zbr,st_idx,lams1,sbody),
        u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_match_succ(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +fname: String, +arity: U32, +zbr: KTerm, +msucc: KTerm) -> AgyAbsResult:
  kc(AgyAbsResult,p98_tag_eq(msucc,"Mat") && String.eq(nm(msucc),"Succ") && U32.is_eq(terms_len(ks(msucc)),2) && p98_tag_eq(kid(msucc,1),"Efq"),
    u => agy_abs_match_peels(ctx,orig_d,raw,rest,fname,arity,zbr,agy_abs_peel(zbr,U32.sub(arity,1)),agy_abs_peel(kid(msucc,0),arity)),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_try_body(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +arity: U32, +clean: KTerm) -> AgyAbsResult:
  kc(AgyAbsResult,p98_tag_eq(clean,"Mat") && String.eq(nm(clean),"Zero") && U32.is_eq(terms_len(ks(clean)),2),
    v => agy_abs_match_succ(ctx,orig_d,raw,rest,dn(raw),arity,kid(clean,0),kid(clean,1)),
    v => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_try_def(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>) -> AgyAbsResult:
  +t0 = j_strip(dt(raw))
  +arity = da(raw)
  +ok_sig = String.eq(dk(raw),"Def") && Bool.not(db(raw) || du(raw)) && U32.is_eq(dx(raw),0) &&
    U32.is_ge(arity,2) && p98_tag_eq(t0,"All") && p198e_owner(kid(t0,0),"Nat")
  kc(AgyAbsResult,ok_sig,
    u => agy_abs_try_body(ctx,orig_d,raw,rest,arity,p205u_clean(dv(raw))),
    u => AgyAbsResult{ctx,Con{orig_d,rest},False{}})

@unsafe
def agy_abs_join(+ch1: Bool, +step_res: AgyAbsResult) -> AgyAbsResult:
  match step_res:
    case AgyAbsResult{ctx2,out2,ch2}: AgyAbsResult{ctx2,out2,ch1 || ch2}

@unsafe
def agy_abs_pass_step(+d: KDef, +tail_res: AgyAbsResult) -> AgyAbsResult:
  match tail_res:
    case AgyAbsResult{ctx1,out1,ch1}:
      +raw = lookup(ctx1,dn(d))
      agy_abs_join(ch1,kc(AgyAbsResult,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => agy_abs_try_def(ctx1,d,raw,out1),
        u => AgyAbsResult{ctx1,Con{d,out1},False{}}))

@unsafe
def agy_abs_pass(+context: List<&2,KDef>, defs: List<&2,KDef>) -> AgyAbsResult:
  match defs:
    case Nil{}: AgyAbsResult{context,[],False{}}
    case Con{+d,rest}: agy_abs_pass_step(d,agy_abs_pass(context,rest))

@unsafe
def agy_abs_plan_go(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>, +res: AgyAbsResult) -> P86Plan:
  match res:
    case AgyAbsResult{ctx1,defs1,changed}:
      kc(P86Plan,changed && String.is_empty(jl_checked_error(ctx1,defs1,["main"],stops)),
        u => p205_ready(ctx1,stops,verdict,defs1,p205u_decls(ctx1,defs1,missing(),False{})),
        u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{})))

@unsafe
def agy_abs_plan(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +annotated: List<&2,KDef>) -> P86Plan:
  agy_abs_plan_go(context,stops,verdict,annotated,agy_abs_pass(context,annotated))
