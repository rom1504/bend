# A fold arm interprets either one word, or two recursive subtrees.
# Names of the fold, datatype and constructors come from checked definitions.
@unsafe
def p198e_op(+book: List<&2,KDef>, +arm: KTerm, +name: String) -> String:
  +first = j_fusion_binder(arm,0)
  +second = j_fusion_binder(arm,1)
  +call = j_call_spine(j_fusion_after(arm,2),[])
  +l = j_call_spine(kid(call,0),[])
  +r = j_call_spine(kid(call,1),[])
  nt_choose(String,p98_tag_eq(first,"Lam") && j_fusion_var(j_fusion_after(arm,1),ix(first)),
    u => "leaf",u => nt_choose(String,p98_tag_eq(first,"Lam") && p98_tag_eq(second,"Lam") &&
      (String.eq(nm(call),"U32.add") || String.eq(nm(call),"U32.sub") || String.eq(nm(call),"U32.mul")) &&
      j_primitive_call(book,call) && j_fusion_call(l,name,1) && j_fusion_var(kid(l,0),ix(first)) &&
      j_fusion_call(r,name,1) && j_fusion_var(kid(r,0),ix(second)), v => nm(call),v => ""))

@unsafe
def p198e_arm(+cases: KTerm, +name: String, +fuel: U32) -> KTerm:
  +h = j_strip(cases)
  nt_choose(KTerm,U32.is_gt(fuel,0) && p98_tag_eq(h,"Mat") && U32.is_eq(terms_len(ks(h)),2),
    u => nt_choose(KTerm,String.eq(nm(h),name),v => kid(h,0),v => p198e_arm(kid(h,1),name,U32.sub(fuel,1))),
    u => kt("Absent","",0,0,[]))

@unsafe
def p198e_apply(+op: String, +a: KTerm, +b: KTerm) -> KTerm:
  app(app(ref(op),a),b)

# Evaluate a finite, closed constructor expression in the checked word algebra.
# The sole allowed free variable is the actual word argument of this case.
@unsafe
def p198e_scalar(+book: List<&2,KDef>, +fold: KDef, +tree: KTerm, +seed: KTerm, +fuel: U32) -> KTerm:
  +h = j_strip(tree)
  nt_choose(KTerm,p98_tag_eq(h,"Ctr") && U32.is_gt(fuel,0),u =>
    p198e_field(book,fold,h,seed,U32.sub(fuel,1),p198e_op(book,p198e_arm(dv(fold),nm(h),12),dn(fold))),
    u => kt("Absent","",0,0,[]))

@unsafe
def p198e_field(+book: List<&2,KDef>, +fold: KDef, +h: KTerm, +seed: KTerm, +fuel: U32, +op: String) -> KTerm:
  nt_choose(KTerm,String.eq(op,"leaf") && U32.is_eq(terms_len(ks(h)),1) && j_fusion_scalar(book,kid(h,0),[seed]),
    u => kid(h,0),u =>
    nt_choose(KTerm,Bool.not(String.is_empty(op)) && Bool.not(String.eq(op,"leaf")) && U32.is_eq(terms_len(ks(h)),2),
      v => p198e_apply(op,p198e_scalar(book,fold,kid(h,0),seed,fuel),p198e_scalar(book,fold,kid(h,1),seed,fuel)),
      v => kt("Absent","",0,0,[])))

type P198EArm is Data:
  P198ENoArm{}
  P198EArm{+op: String, +left: Bool, +value: KTerm, +seed: KTerm}

@unsafe
def p198e_choice(+book: List<&2,KDef>, +fold: KDef, +branch: KTerm, +skip: U32) -> P198EArm:
  +slot = j_fusion_binder(branch,skip)
  +seed = j_fusion_binder(branch,U32.inc(skip))
  +tree = j_fusion_after(branch,U32.add(skip,2))
  +left = j_fusion_var(kid(tree,0),ix(slot))
  +op = p198e_op(book,p198e_arm(dv(fold),nm(tree),12),dn(fold))
  nt_choose(P198EArm,p98_tag_eq(slot,"Lam") && p98_tag_eq(seed,"Lam") && p98_tag_eq(tree,"Ctr") &&
    U32.is_eq(terms_len(ks(tree)),2) && (String.eq(op,"U32.add") || String.eq(op,"U32.sub") || String.eq(op,"U32.mul")) &&
    (left || j_fusion_var(kid(tree,1),ix(slot))),u =>
    p198e_finish_arm(book,op,left,seed,p198e_scalar(book,fold,nt_choose(KTerm,left,v => kid(tree,1),v => kid(tree,0)),seed,8)),
    u => P198ENoArm{})

@unsafe
def p198e_finish_arm(+book: List<&2,KDef>, +op: String, +left: Bool, +seed: KTerm, +value: KTerm) -> P198EArm:
  nt_choose(P198EArm,j_fusion_scalar(book,value,[seed]),u => P198EArm{op,left,value,seed},u => P198ENoArm{})

@unsafe
def p198e_word(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  j_primitive_type(book,wnf(book,ty),name)

@unsafe
def p198e_domain(+ty: KTerm, +at: U32) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(ty,"All") && Bool.not(U32.is_eq(qt(ty),0)),u =>
    nt_choose(KTerm,U32.is_eq(at,0),v => kid(ty,0),v => p198e_domain(kid(ty,1),U32.sub(at,1))),u => kt("Absent","",0,0,[]))

# Restrict representation equality to a closed, unapplied datatype reference.
# Excludes indexed/dependent products and implicit type arguments.
@unsafe
def p198e_owner(+t: KTerm, +name: String) -> Bool:
  +h = j_strip(t)
  p98_tag_eq(h,"Ref") && String.eq(nm(h),name) && U32.is_eq(terms_len(ks(h)),0)

type P198EPlan is Data:
  P198ERefused{}
  P198EReady{+params: List<&2,NC_Binding>, +entryCount: KTerm, +entrySeed: KTerm, +stepSeed: KTerm,
    +baseValue: KTerm, +baseBinder: KTerm, +nextSeed: KTerm, +key: KTerm, +branchSeed: KTerm,
    +a: P198EArm, +b: P198EArm, +c: P198EArm}

@unsafe
def p198e_triple(+a: P198EArm, +b: P198EArm, +c: P198EArm) -> Bool:
  match a b c:
    case P198EArm{oa,la,va,sa} P198EArm{ob,lb,vb,sb} P198EArm{oc,lc,vc,sc}: True{}
    case _ _ _: False{}

# Probe short syntactic spines before paying the full bounded body/type checks.
@unsafe
def p198e_spine(+t: KTerm, +args: List<&2,KTerm>, +fuel: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(fuel,0),u => kt("Absent","",0,0,[]),u =>
    nt_choose(KTerm,p98_tag_eq(t,"Ann"),v => p198e_spine(kid(t,0),args,U32.sub(fuel,1)),v =>
    nt_choose(KTerm,p98_tag_eq(t,"App"),w => p198e_spine(kid(t,0),Con{kid(t,1),args},U32.sub(fuel,1)),w =>
    nt_choose(KTerm,p98_tag_eq(t,"Ref"),z => kt("Call",nm(t),0,0,args),z => kt("Absent","",0,0,[])))))

@unsafe
def p198e_plan(+book: List<&2,KDef>, +d: KDef) -> P198EPlan:
  nt_choose(P198EPlan,j_fusion_def(d,2),u => p198e_entry(book,d),u => P198ERefused{})

@unsafe
def p198e_entry(+book: List<&2,KDef>, +d: KDef) -> P198EPlan:
  +outer = p198e_spine(j_fusion_after(dv(d),2),[],10)
  +inner = p198e_spine(kid(outer,0),[],10)
  +n = p198e_spine(kid(inner,0),[],10)
  nt_choose(P198EPlan,p98_tag_eq(outer,"Call") && U32.is_eq(terms_len(ks(outer)),1) &&
    p98_tag_eq(inner,"Call") && U32.is_eq(terms_len(ks(inner)),2) && j_fusion_call(n,"U32.to_nat",1) &&
    p121f_bounded(dv(d)),
    u => p198e_defs(book,d,lookup(book,nm(outer)),lookup(book,nm(inner)),n,kid(inner,1)),u => P198ERefused{})

@unsafe
def p198e_defs(+book: List<&2,KDef>, +d: KDef, +fold: KDef, +prod: KDef, +n: KTerm, +initial: KTerm) -> P198EPlan:
  nt_choose(P198EPlan,j_fusion_def(fold,1) && j_fusion_def(prod,2) && p121f_bounded(dv(fold)) && p121f_bounded(dv(prod)),
    u => p198e_shapes(book,d,fold,prod,n,initial),u => P198ERefused{})

@unsafe
def p198e_shapes(+book: List<&2,KDef>, +d: KDef, +fold: KDef, +prod: KDef, +n: KTerm, +initial: KTerm) -> P198EPlan:
  +arg0 = j_fusion_binder(dv(d),0)
  +arg1 = j_fusion_binder(dv(d),1)
  +owner = nm(p198e_domain(dt(fold),0))
  +branch = j_fusion_link(prod)
  +call = j_call_spine(j_fusion_after(branch,2),[])
  nt_choose(P198EPlan,p121c_signature(book,dt(d),2) &&
    p98_tag_eq(arg0,"Lam") && p98_tag_eq(arg1,"Lam") && j_primitive_call(book,n) &&
    j_fusion_scalar(book,kid(n,0),[arg0,arg1]) && j_fusion_scalar(book,initial,[arg0,arg1]) &&
    String.eq(dk(lookup(book,owner)),"ADT") && U32.is_eq(da(lookup(book,owner)),0) &&
    p198e_owner(p198e_domain(dt(fold),0),owner) && p198e_word(book,kid(dt(fold),1),"U32") &&
    p198e_owner(kid(kid(dt(prod),1),1),owner) && p198e_word(book,p198e_domain(dt(prod),0),"Nat") &&
    p198e_word(book,p198e_domain(dt(prod),1),"U32") && j_fusion_cases(dv(prod),"Zero","Succ") &&
    p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),3),
    u => p198e_builder(book,fold,prod,lookup(book,nm(call)),call,owner,kid(n,0),initial,[p121f_env(arg0,"ea"),p121f_env(arg1,"eb")]),
    u => P198ERefused{})

@unsafe
def p198e_builder(+book: List<&2,KDef>, +fold: KDef, +prod: KDef, +pick: KDef, +call: KTerm,
    +owner: String, +n: KTerm, +initial: KTerm, +params: List<&2,NC_Binding>) -> P198EPlan:
  nt_choose(P198EPlan,j_fusion_def(pick,3) && p121f_bounded(dv(pick)) && j_fusion_cases(dv(pick),"Zero","Succ"),
    u => p198e_arms(book,fold,prod,pick,call,owner,n,initial,params),u => P198ERefused{})

@unsafe
def p198e_arms(+book: List<&2,KDef>, +fold: KDef, +prod: KDef, +pick: KDef, +call: KTerm,
    +owner: String, +n: KTerm, +initial: KTerm, +params: List<&2,NC_Binding>) -> P198EPlan:
  +loop = j_fusion_link(prod)
  +pred = j_fusion_binder(loop,0)
  +seed = j_fusion_binder(loop,1)
  +base = j_fusion_empty(prod)
  +leaf = j_fusion_binder(base,0)
  +end = p198e_scalar(book,fold,j_fusion_after(base,1),leaf,8)
  +disc = j_call_spine(kid(call,0),[])
  +rec = j_call_spine(kid(call,1),[])
  +node = j_fusion_link(pick)
  +a = p198e_choice(book,fold,j_fusion_empty(pick),0)
  +b = p198e_choice(book,fold,kid(j_strip(node),0),0)
  +c = p198e_choice(book,fold,kid(j_strip(kid(j_strip(node),1)),0),1)
  nt_choose(P198EPlan,j_fusion_cases(node,"Zero","Succ") && p198e_word(book,p198e_domain(dt(pick),0),"Nat") &&
    p198e_owner(p198e_domain(dt(pick),1),owner) && p198e_word(book,p198e_domain(dt(pick),2),"U32") &&
    p198e_owner(kid(kid(kid(dt(pick),1),1),1),owner) && p98_tag_eq(pred,"Lam") && p98_tag_eq(seed,"Lam") &&
    p98_tag_eq(leaf,"Lam") && j_fusion_scalar(book,end,[leaf]) &&
    j_fusion_call(rec,dn(prod),2) && j_fusion_var(kid(rec,0),ix(pred)) &&
    j_fusion_scalar(book,kid(rec,1),[seed]) && j_fusion_scalar(book,kid(call,2),[seed]) &&
    j_fusion_call(disc,"U32.to_nat",1) && j_primitive_call(book,disc) && j_fusion_scalar(book,kid(disc,0),[seed]) &&
    p198e_triple(a,b,c),
    u => P198EReady{params,n,initial,seed,end,leaf,kid(rec,1),kid(disc,0),kid(call,2),a,b,c},u => P198ERefused{})
