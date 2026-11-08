
# Module: src/check/kernel.bend:4
type KChecking is Data:
  KChecking{+term: KTerm, +typ: KTerm, +uses: List<&2, KTerm>, +error: String, +world: KWorld, +consumed: U32}

# Module: src/check/kernel.bend:7
type KEnv is Data:
  KEnv{+world: KWorld, +name: String, +lhs: KTerm, +pending: U32, +quantities: List<&2, KTerm>, +unsafe: Bool, +depth: U32}

# Module: src/check/kernel.bend:1197
type KWorldFresh is Data:
  KFreshKnown{+next: U32}
  KFreshDeferred{+roots: List<&2,KTerm>}

# Module: src/check/kernel.bend:1201
type KWorld is Data:
  KWorld{+book: List<&2,KDef>, +memo: List<&2,KSpecMemo>, +fresh: KWorldFresh, +checked: List<&2,KDef>}

# Module: src/check/kernel.bend:10
law infer_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:18
law infer_var:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:25
law infer_ref:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:34
law infer_app:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:42
law infer_app_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +r: KChecking
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:51
law infer_adt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:59
law infer_adt_done:
  for +t: KTerm
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:64
law tele_check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:72
law tele_check_done:
  for +a: KChecking
  for +b: KChecking
  KChecking

# Module: src/check/kernel.bend:77
law tele_fill_head:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:84
law check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:92
law check_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:100
law check_fits:
  for +e: KEnv
  for +r: KChecking
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:106
law check_lam:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:114
law check_lam_q:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +q: U32
  KChecking

# Module: src/check/kernel.bend:123
law check_lam_done:
  for +t: KTerm
  for +ty: KTerm
  for +q: U32
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:130
law check_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:138
law check_ctr_found:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +ctr: KDef
  KChecking

# Module: src/check/kernel.bend:147
law check_rfl:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecking

law check_rfl_graph:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:153
law check_let:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  for +out: List<&2,KTerm>
  KChecking

# Module: src/check/kernel.bend:166
law check_let_value:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  for +out: List<&2,KTerm>
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:181
law check_let_kind:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +ty: KTerm
  for +bindings: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  for +out: List<&2,KTerm>
  for +r: KChecking
  for +k: KChecking
  KChecking

# Module: src/check/kernel.bend:197
law let_cells:
  for +body: KTerm
  for +bs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:202
law check_let_done:
  for +e: KEnv
  for +ctx: List<&2,KTerm>
  for +r: KChecking
  for +bs: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  KChecking

# Module: src/check/kernel.bend:211
law dead_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/check/kernel.bend:216
law check_mat:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:224
law check_mat_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +a: KTerm
  KChecking

# Module: src/check/kernel.bend:233
law check_mat_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +a: KTerm
  for +ctr: KDef
  KChecking

# Module: src/check/kernel.bend:243
law mat_goal:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:252
law mat_goal_head:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:261
law mat_lhs:
  for +e: KEnv
  for +name: String
  for +tel: KTerm
  for +n: U32
  for +avoid: List<&2,KTerm>
  KEnv

# Module: src/check/kernel.bend:269
law check_rwt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:278
law check_rwt_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecking
  for +eq: KTerm
  KChecking

# Module: src/check/kernel.bend:288
law check_rwt_goal:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +ty: KTerm
  for +r: KChecking
  for +eq: KTerm
  for +fresh: U32
  KChecking

# Module: src/check/kernel.bend:299
law tele_quantities_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  List<&2, KTerm>

# Module: src/check/kernel.bend:305
law count_open:
  for +book: List<&2, KDef>
  U32

# Module: src/check/kernel.bend:309
law check_open_message:
  for +n: U32
  String

# Module: src/check/kernel.bend:313
law signature_fill_mode:
  for +d: KDef
  for +fill: KDef
  KDef

# Module: src/check/kernel.bend:318
law constructor_names:
  for +done: List<&2, KDef>
  for +ctrs: List<&2, KDef>
  for +names: List<&2, String>
  String

# Module: src/check/kernel.bend:324
law check_definition_type:
  for +book: List<&2, KDef>
  for +d: KDef
  for +e: KEnv
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:331
law check_foreign:
  for +world: KWorld
  for +d: KDef
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:337
law tele_tip_head:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:342
law check_adt_declaration:
  for +e: KEnv
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:347
law check_ctors:
  for +e: KEnv
  for +d: KDef
  for +ctrs: List<&2, KDef>
  for +kind: KTerm
  KChecking

# Module: src/check/kernel.bend:354
law check_ctors_next:
  for +e: KEnv
  for +d: KDef
  for +rest: List<&2, KDef>
  for +kind: KTerm
  for +err: KChecking
  KChecking

# Module: src/check/kernel.bend:362
law check_ctor_tel:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:373
law check_ctor_head:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:384
law check_ctor_domain:
  for +e: KEnv
  for +d: KDef
  for +tel: KTerm
  for +kind: KTerm
  for +params: U32
  for +fields: U32
  for +ctx: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:396
law infer_template:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:405
law template_args:
  for +e: KEnv
  for +ty: KTerm
  for +sp: List<&2, KTerm>
  for +n: U32
  KChecking

# Module: src/check/kernel.bend:412
law template_arg_head:
  for +e: KEnv
  for +ty: KTerm
  for +sp: List<&2, KTerm>
  for +n: U32
  KChecking

# Module: src/check/kernel.bend:419
law template_arg_done:
  for +e: KEnv
  for +ty: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +n: U32
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:428
law contains_self:
  for +todo: List<&2, KTerm>
  for +name: String
  Bool

# Module: src/check/kernel.bend:433
law check_template_definition:
  for +world: KWorld
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:443
law check_template_binder:
  for +world: KWorld
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:453
law check_template_open:
  for +world: KWorld
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +name: String
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:998
law check_definition_result:
  for +book: List<&2, KDef>
  for +d: KDef
  KChecking

# Module: src/check/kernel.bend:1127
law tele_check_cached_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecking

# A failed fact uses the original remaining traversal, avoiding repeated scans
# of dependent tails. The public tele_check_head retains its existing behavior.

# Module: src/check/kernel.bend:1138
law tele_check_legacy_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:1177
law tele_check_after_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +checked_head: KChecking
  KChecking

# Module: src/check/kernel.bend:465
@unsafe
def cb(
  +e: KEnv,
) -> List<&2, KDef>:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      kw_book(world)

# Module: src/check/kernel.bend:473
@unsafe
def cn(
  +e: KEnv,
) -> String:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      name

# Module: src/check/kernel.bend:481
@unsafe
def cl(
  +e: KEnv,
) -> KTerm:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      lhs

# Module: src/check/kernel.bend:489
@unsafe
def cp(
  +e: KEnv,
) -> U32:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      pending

# Module: src/check/kernel.bend:497
@unsafe
def cq(
  +e: KEnv,
) -> List<&2, KTerm>:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      quantities

# Module: src/check/kernel.bend:505
@unsafe
def cu(
  +e: KEnv,
) -> Bool:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      unsafe

# Module: src/check/kernel.bend:513
@unsafe
def ct(
  +r: KChecking,
) -> KTerm:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      term

# Module: src/check/kernel.bend:521
@unsafe
def cy(
  +r: KChecking,
) -> KTerm:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      typ

# Module: src/check/kernel.bend:529
@unsafe
def cs(
  +r: KChecking,
) -> List<&2, KTerm>:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      uses

# Module: src/check/kernel.bend:537
@unsafe
def ce(
  +r: KChecking,
) -> String:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      error

# Module: src/check/kernel.bend:545
@unsafe
def ok(
  +world: KWorld,
  +t: KTerm,
  +ty: KTerm,
  +us: List<&2, KTerm>,
) -> KChecking:
  KChecking{t, ty, us, "", world, 0}

# Module: src/check/kernel.bend:554
@unsafe
def bad(
  +world: KWorld,
  +msg: String,
) -> KChecking:
  KChecking{{KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, msg, world, 0}

# Module: src/check/kernel.bend:561
@unsafe
def good(
  +r: KChecking,
) -> Bool:
  p88_string_eq(ce(r), "")

# Module: src/check/kernel.bend:567
@unsafe
def checked(
  +r: KChecking,
  +t: KTerm,
  +ty: KTerm,
) -> KChecking:
  kc(KChecking, good(r), u => KChecking{t, ty, cs(r), "", rw(r), rx(r)}, u => r)

# Module: src/check/kernel.bend:575
@unsafe
def both(
  +a: KChecking,
  +b: KChecking,
  +t: KTerm,
  +ty: KTerm,
  +join: Bool,
) -> KChecking:
  kc(KChecking, good(a), u => kc(KChecking, good(b), u => KChecking{t, ty, uses_merge(cs(a), cs(b), join), "", rw(b), rx(b)}, u => b), u => a)

# Module: src/check/kernel.bend:585
@unsafe
def ctx_get(
  +ctx: List<&2, KTerm>,
  +id: U32,
) -> KTerm:
  match ctx:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      kc(KTerm, U32.is_eq(ix(h), id), u => h, u => ctx_get(t, id))

# Module: src/check/kernel.bend:596
@unsafe
def ctx_bind(
  +ctx: List<&2, KTerm>,
  +id: U32,
  +q: U32,
  +name: String,
  +ty: KTerm,
) -> List<&2, KTerm>:
  Con{kt("Bind", name, id, q, Con{ty, Nil{}}), ctx}

# Module: src/check/kernel.bend:606
@unsafe
def kindq(
  +e: KEnv,
  +q: U32,
) -> U32:
  kc(U32, cu(e) && U32.is_eq(q, 2), u => 1, u => q)

# Module: src/check/kernel.bend:613
@unsafe
def kapply(
  +fn: KTerm,
  +x: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(strip(fn), "Lam"), u => subst(kid(strip(fn), 0), ix(strip(fn)), x), u => app(fn, x))

# Module: src/check/kernel.bend:620
@unsafe
def lhs_step(
  +e: KEnv,
  +x: KTerm,
) -> KEnv:
  kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => KEnv{cw(e), cn(e), kapply(cl(e), x), U32.sub(cp(e), 1), cq(e), cu(e), cd(e)})

# Module: src/check/kernel.bend:627
@unsafe
def unargs(
  +t: KTerm,
  +acc: List<&2, KTerm>,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, p98_tag_eq(t, "App"), u => unargs(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

# Module: src/check/kernel.bend:634
@unsafe
def infer(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +t: KTerm,
  +dem: U32,
  +sp: List<&2, KTerm>,
) -> KChecking:
  dg_trace(e, ctx, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, infer_node(e, ctx, core_beta(t), dem, sp))

# Module: src/check/kernel.bend:644
@unsafe
def infer_node(e, ctx, t, dem, sp):
  kc(KChecking, p98_tag_eq(t, "Var"), u => infer_var(e, ctx, t, dem),
   u => kc(KChecking, p98_tag_eq(t, "Ref"), u => infer_ref(e, ctx, t, dem, sp, lookup(cb(e), nm(t))),
   u => kc(KChecking, p98_tag_eq(t, "Typ"), u => ki_one(t, typ(1), check(e, ctx, kid(t, 0), 0, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),
   u => kc(KChecking, p98_tag_eq(t, "Qnt"), u => ok(cw(e), t, typ(1), Nil{}),
   u => kc(KChecking, p98_tag_eq(t, "Qua"), u => ok(cw(e), t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}),
   u => kc(KChecking, p98_tag_eq(t, "Min"), u => ki_min(e, ctx, t, dem, check(e, ctx, kid(t, 0), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),
   u => kc(KChecking, p98_tag_eq(t, "All"), u => ki_all(e, ctx, t, dg_kind_check(e, ctx, kid(t, 0), qt(t), nm(t))),
   u => kc(KChecking, p98_tag_eq(t, "App"), u => infer_app(e, ctx, t, dem, infer(e, ctx, kid(t, 0), dem, Con{kid(t, 1), sp})),
   u => kc(KChecking, p98_tag_eq(t, "ADT"), u => infer_adt(e, ctx, t, dem, lookup(cb(e), nm(t))),
   u => kc(KChecking, p98_tag_eq(t, "Eql"), u => ki_eql_type(e, ctx, t, check(e, ctx, kid(t, 2), 0, typ(1))),
   u => kc(KChecking, p98_tag_eq(t, "Ann"), u => ki_ann(e, ctx, t, dem, check(e, ctx, kid(t, 1), 0, typ(1))),
   u => kc(KChecking, core_literal(t), u => bad(cw(e), "cannot infer: annotation required"), u => bad(cw(e), kc(String, p98_tag_eq(t, "FUnboundVar"), u => "unbound variable", u => "cannot infer: annotation required"))))))))))))))

# Module: src/check/kernel.bend:659
@unsafe
def infer_var(e, ctx, t, dem):
  +bound = ctx_get(ctx, ix(t))
  kc(KChecking, p98_tag_eq(bound, "Absent"), u => bad(cw(e), "unbound variable"), u => ok(cw(e), k_with_children(t, Nil{}), kid(bound, 0), Con{kt("Use", "", ix(t), dem, Nil{}), Nil{}}))

# Module: src/check/kernel.bend:664
@unsafe
def infer_ref(e, ctx, t, dem, sp, d):
  kc(KChecking, p88_string_eq(dk(d), "Absent"), u => bad(cw(e), "undefined name"),
   u => kc(KChecking, p88_string_eq(dk(d), "ADT") && U32.is_gt(da(d), 0), u => bad(cw(e), "a family requires angle-bracket parameters"),
   u => kc(KChecking, U32.is_eq(dem, 0), u => ok(cw(e), t, dt(d), Nil{}),
   u => kc(KChecking, p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent") && Bool.not(p88_string_eq(nm(t), cn(e))) && ((Bool.not(db(d)) && Bool.not(cu(e))) || (U32.is_gt(dx(d), 0) && U32.is_eq(dx(lookup(cb(e), cn(e))), 0))), u => bad(cw(e), "live use of an unfilled law"),
   u => ki_ref_result(e, t, sp, infer_template(e, ctx, t, dem, sp, d))))))

# Module: src/check/kernel.bend:672
@unsafe
def infer_app(e, ctx, t, dem, r):
  kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(rx(r), 0), u => KChecking{ct(r), cy(r), cs(r), "", rw(r), U32.sub(rx(r), 1)}, u => infer_app_type(ke_world(e, rw(r)), ctx, t, dem, r, wnf(kw_book(rw(r)), cy(r)))), u => r)

# Module: src/check/kernel.bend:676
@unsafe
def infer_app_type(e, ctx, t, dem, r, ty):
  kc(KChecking, p98_tag_eq(ty, "All"), u => ki_pair(t, subst(kid(ty, 1), ix(ty), kid(t, 1)), r, check(ke_world(e, rw(r)), ctx, kid(t, 1), qdem(qt(ty), dem), kid(ty, 0)), False{}), u => kr_from(r, dg_bad_detail(rw(r), "application requires a function type", dg_text("a function type"), cy(r))))

# Module: src/check/kernel.bend:680
@unsafe
def infer_adt(e, ctx, t, dem, d):
  kc(KChecking, p88_string_eq(dk(d), "ADT") && U32.is_eq(terms_len(ks(t)), da(d)), u => infer_adt_done(t, tele_check(e, ctx, dt(d), ks(t), dem)), u => dg_adt_error(cw(e), t, d))

# Module: src/check/kernel.bend:684
@unsafe
def infer_adt_done(t, r):
  ki_args(t, cy(r), r)

# Module: src/check/kernel.bend:688
@unsafe
def tele_check(e, ctx, tel, args, dem):
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, t}: tele_check_cached_head(e, ctx, wnf(cb(e), tel), h, t, dem)

# Module: src/check/kernel.bend:694
@unsafe
def tele_check_head(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32) -> KChecking:
  tele_check_cached_head(e, ctx, tel, h, rest, dem)

# Module: src/check/kernel.bend:698
@unsafe
def tele_check_done(a, b):
  both(a, b, k_with_children({KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{ct(a), ks(ct(b))}), cy(b), False{})

# Module: src/check/kernel.bend:702
@unsafe
def tele_fill(
  +book: List<&2, KDef>,
  +tel: KTerm,
  +args: List<&2, KTerm>,
) -> KTerm:
  env_tele_fill(book, tel, args)

# Module: src/check/kernel.bend:710
@unsafe
def tele_fill_head(book, tel, h, rest):
  kc(KTerm, p98_tag_eq(tel, "All"), u => tele_fill(book, subst(kid(tel, 1), ix(tel), h), rest), u => {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/check/kernel.bend:714
@unsafe
def check(e, ctx, t, dem, ty):
  dg_trace(e, ctx, t, ty, check_node(e, ctx, core_beta(t), dem, ty))

# Module: src/check/kernel.bend:718
@unsafe
def check_node(e, ctx, t, dem, ty):
  kc(KChecking, core_literal(t), u => kc(KChecking, core_literal_type(cb(e), t, wnf(cb(e), ty)), u => ok(cw(e), t, ty, Nil{}), u => check(e, ctx, core_literal_step(t), dem, ty)), u =>
  kc(KChecking, p98_tag_eq(t, "Lam"), u => check_lam(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecking, p98_tag_eq(t, "Ctr"), u => check_ctr(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecking, p98_tag_eq(t, "Mat") || p98_tag_eq(t, "Efq"), u => check_mat(e, ctx, t, dem, wnf(cb(e), ty)),
   u => kc(KChecking, p98_tag_eq(t, "Rfl"), u => check_rfl_graph(e, t, ty),
   u => kc(KChecking, p98_tag_eq(t, "Hol"), u => kc(KChecking, p88_string_eq(nm(t), "TODO"), u => ok(cw(e), t, ty, Nil{}), u => bad(cw(e), "unresolved hole")),
   u => kc(KChecking, p98_tag_eq(t, "Let"), u => check_let(e, ctx, ctx, ks(t), dem, ty, Nil{}, Nil{}, t, Nil{}),
   u => kc(KChecking, p98_tag_eq(t, "Rwt"), u => check_rwt(e, ctx, t, dem, ty, infer(e, ctx, kid(t, 0), dem, Nil{})),
   u => check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)))))))))

# Module: src/check/kernel.bend:730
@unsafe
def check_fits(e, r, ty):
  kc(KChecking, good(r), u => kc(KChecking, compare(kw_book(rw(r)), cy(r), ty, True{}), u => checked(r, ct(r), ty), u => kr_from(r, dg_bad_detail(rw(r), "type mismatch", ty, cy(r)))), u => r)

# Module: src/check/kernel.bend:734
@unsafe
def check_lam(e, ctx, t, dem, ty):
  kc(KChecking, p98_tag_eq(ty, "All"), u => check_lam_q(e, ctx, t, dem, ty, kc(U32, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty))), u => bad(cw(e), "lambda requires a function type"))

# Module: src/check/kernel.bend:738
@unsafe
def check_lam_q(e, ctx, t, dem, ty, q):
  ki_lam_kind(e, ctx, t, dem, ty, q, kc(KChecking, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => dg_kind_check(e, ctx, kid(ty, 0), q, nm(t)), u => ok(cw(e), t, ty, Nil{})))

# Module: src/check/kernel.bend:742
@unsafe
def check_lam_done(t, ty, q, r):
  kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(uses_get(cs(r), ix(t)), q), u => kr_from(r, dg_quant_error(rw(r), "affine variable consumed more than allowed", nm(t), q, uses_get(cs(r), ix(t)))), u => KChecking{k_with_children(t, Con{ct(r), Nil{}}), ty, uses_del(cs(r), ix(t)), "", rw(r), rx(r)}), u => r)

# Module: src/check/kernel.bend:746
@unsafe
def check_ctr(e, ctx, t, dem, ty):
  kc(KChecking, p98_tag_eq(ty, "ADT"), u => check_ctr_found(e, ctx, t, dem, ty, lookup(dc(lookup(cb(e), nm(ty))), nm(t))), u => bad(cw(e), "constructor requires a datatype goal"))

# Module: src/check/kernel.bend:750
@unsafe
def check_ctr_found(e, ctx, t, dem, ty, ctr):
  kc(KChecking, Bool.not(p88_string_eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))) && U32.is_eq(da(ctr), terms_len(ks(t))), u => ki_args(t, ty, tele_check(e, ctx, tele_fill(cb(e), dt(ctr), ks(ty)), ks(t), dem)), u => dg_ctor_error(e, t, ty, ctr))

# Module: src/check/kernel.bend:754
@unsafe
def check_rfl(e, t, ty):
  kc(KChecking, p98_tag_eq(ty, "Eql"), u => kc(KChecking, compare(cb(e), kid(ty, 0), kid(ty, 1), False{}), u => ok(cw(e), t, ty, Nil{}), u => dg_bad_detail(cw(e), "reflexivity endpoints differ", kid(ty, 0), kid(ty, 1))), u => bad(cw(e), "reflexivity requires equality goal"))

# Expose the goal and compare its endpoints in one private graph. Ordinary wnf
# substitutes raw let values and can expand a shared goal before comparison.
# The result retains the original goal; no heap-local cell enters KChecking.
@unsafe
def check_rfl_graph_head(+e: KEnv, +t: KTerm, +ty: KTerm,
  +fresh: U32, +r: GResult) -> KChecking:
  match r:
    case GResult{st, head}:
      kc(KChecking, p98_tag_eq(head, "Eql"),
        u => kc(KChecking, norm_convert_state(cb(e), st, kid(head, 0), kid(head, 1), False{}, fresh),
          u => ok(cw(e), t, ty, Nil{}),
          u => check_rfl(e, t, wnf(cb(e), ty))),
        u => bad(cw(e), "reflexivity requires equality goal"))

@unsafe
def check_rfl_graph(e, t, ty):
  +fresh = U32.add(1, norm_max(norm_book_bound(cb(e)), norm_max_term(ty)))
  check_rfl_graph_head(e, t, ty, fresh, g_wnf(cb(e), GState{GEmpty{}, 1}, ty))

# Module: src/check/kernel.bend:758
@unsafe
def check_let(e, outer, ctx, xs, dem, ty, bindings, us, site, out):
  match xs:
    case Nil{}: bad(cw(e), "let has no body")
    case Con{h, rest}:
      kc(KChecking, p98_tag_eq(h, "Bind"), u => check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, infer(e, outer, kid(h, 0), qdem(qt(h), dem), Nil{})), u => ki_let_finish(site, out, check_let_done(e, outer, check(e, ctx, let_cells(h, bindings), dem, ty), ki_reverse_terms(bindings, Nil{}), us, kc(KTerm, U32.is_eq(kb(site), 0), u => kid(site, 0), u => site))))

# Module: src/check/kernel.bend:765
# Inference checked the value's type at its source. Only a Data requirement
# can add an obligation here; unsafe reusable binders retain kindq's relaxation.
@unsafe
def check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r):
  kc(KChecking, good(r), u => check_let_kind(ke_world(e, rw(r)), outer, ctx, h, rest, dem, ty, bindings, us, site, out, r,
    kc(KChecking, U32.is_eq(kindq(e, qt(h)), 2),
      u => dg_kind_at(ke_world(e, rw(r)), outer, cy(r), qt(h), nm(h), h), u => r)), u => r)

# Module: src/check/kernel.bend:769
@unsafe
def check_let_kind(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r, k):
  kc(KChecking, good(k), u => check_let(ke_world(e, rw(k)), outer, ctx_bind(ctx, ix(h), qt(h), nm(h), cy(r)), rest, dem, ty, Con{h, bindings}, uses_merge(us, cs(r), False{}), site, Con{k_with_children(h, Con{ct(r), Nil{}}), out}), u => k)

# Module: src/check/kernel.bend:773
@unsafe
def let_cells(body, bs):
  match bs:
    case Nil{}:
      body
    case Con{h, t}:
      let_cells(subst(body, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), t)

# Module: src/check/kernel.bend:781
@unsafe
def check_let_done(e, ctx, r, bs, us, site):
  match bs:
    case Nil{}:
      kc(KChecking, good(r), u => KChecking{ct(r), cy(r), uses_merge(us, cs(r), False{}), "", rw(r), rx(r)}, u => r)
    case Con{h, t}:
      kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(uses_get(cs(r), ix(h)), qt(h)), u => dg_trace(e, ctx, site, cy(r), kr_from(r, dg_quant_error(rw(r), "let binder consumed more than allowed", nm(h), qt(h), uses_get(cs(r), ix(h))))), u => check_let_done(e, ctx, KChecking{ct(r), cy(r), uses_del(cs(r), ix(h)), "", rw(r), rx(r)}, t, us, site)), u => r)

# Module: src/check/kernel.bend:789
@unsafe
def remaining(
  +cs: List<&2, KDef>,
  +removed: List<&2, String>,
) -> List<&2, KDef>:
  match cs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KDef>, has_name(removed, dn(h)), u => remaining(t, removed), u => Con{h, remaining(t, removed)})

# Module: src/check/kernel.bend:800
@unsafe
def defs_empty(
  +ds: List<&2, KDef>,
) -> Bool:
  match ds:
    case Nil{}:
      True{}
    case Con{h, t}:
      False{}

# Module: src/check/kernel.bend:810
@unsafe
def ctx_dead(
  +book: List<&2, KDef>,
  +ctx: List<&2, KTerm>,
) -> Bool:
  match ctx:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, U32.is_eq(qt(h), 0), u => ctx_dead(book, t), u => dead_type(book, wnf(book, kid(h, 0))) || ctx_dead(book, t))

# Module: src/check/kernel.bend:821
@unsafe
def dead_type(book, ty):
  p98_tag_eq(ty, "ADT") && p88_string_eq(dk(lookup(book, nm(ty))), "ADT") && defs_empty(remaining(dc(lookup(book, nm(ty))), rm(ty)))

# Module: src/check/kernel.bend:825
@unsafe
def check_mat(e, ctx, t, dem, ty):
  kc(KChecking, p98_tag_eq(ty, "All"),
   u => kc(KChecking, Bool.not(U32.is_eq(dem, 0)) && U32.is_eq(qt(ty), 0), u => dg_bad_message(cw(e), "erased scrutinee in live match", dg_text("a live scrutinee (a - scrutinee matches only in a dead region)")),
   u => check_mat_type(e, ctx, t, dem, ty, wnf(cb(e), kid(ty, 0)))),
   u => bad(cw(e), "matcher requires a function type"))

# Module: src/check/kernel.bend:832
@unsafe
def check_mat_type(e, ctx, t, dem, ty, a):
  kc(KChecking, p98_tag_eq(a, "ADT") && p88_string_eq(dk(lookup(cb(e), nm(a))), "ADT"),
   u => kc(KChecking, p98_tag_eq(t, "Efq"),
   u => kc(KChecking, dead_type(cb(e), a) || ctx_dead(cb(e), ctx), u => ok(cw(e), t, ty, Nil{}), u => dg_bad_detail(cw(e), "nonexhaustive match", dg_text("cases for " ++ dg_constructor_names(remaining(dc(lookup(cb(e), nm(a))), rm(a)))), t)),
   u => check_mat_ctr(e, ctx, t, dem, ty, a, lookup(remaining(dc(lookup(cb(e), nm(a))), rm(a)), nm(t)))),
   u => dg_bad_detail(cw(e), "match scrutinee requires a datatype", dg_text("a datatype"), kid(ty, 0)))

# Module: src/check/kernel.bend:840
@unsafe
def check_mat_ctr(e, ctx, t, dem, ty, a, ctr):
  kc(KChecking, p88_string_eq(dk(ctr), "Absent"), u => dg_bad_detail(cw(e), "unknown or duplicate match constructor", dg_text("a constructor of " ++ name_key(nm(a)) ++ " (missing, or already matched)"), t),
   u => check_mat_filled(e, ctx, t, dem, ty, a, ctr, tele_fill(cb(e), dt(ctr), ks(a))))

# A non-case fallback past the final constructor is unreachable. The checker
# and annotation pass share this choice so backends receive the same Efq.

# Module: src/check/kernel.bend:847
@unsafe
def mat_rest(
  +book: List<&2, KDef>,
  +t: KTerm,
  +a: KTerm,
) -> KTerm:
  kc(KTerm, Bool.not(p98_tag_eq(kid(t, 1), "Mat")) && defs_empty(remaining(dc(lookup(book, nm(a))), Con{nm(t), rm(a)})), u => {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => kid(t, 1))

# Module: src/check/kernel.bend:855
@unsafe
def mat_goal(book, goal, tel, n, name, xs):
  kc(KTerm, U32.is_eq(n, 0), u => subst(kid(goal, 1), ix(goal), kt("Ctr", name, 0, 0, norm_join(xs, Nil{}))), u => mat_goal_head(book, goal, wnf(book, tel), n, name, xs))

# Module: src/check/kernel.bend:859
@unsafe
def mat_goal_head(book, goal, tel, n, name, xs):
  all(kc(U32, U32.is_eq(qt(tel), 0), u => 0, u => kc(U32, U32.is_eq(qt(tel), 1), u => qt(goal), u => qadd(qt(goal), qt(goal)))), nm(tel), ix(tel), kid(tel, 0), mat_goal(book, goal, kid(tel, 1), U32.sub(n, 1), name, norm_join(xs, Con{var(nm(tel), ix(tel)), Nil{}})))

# Module: src/check/kernel.bend:863
@unsafe
def lhs_ext(
  +lhs: KTerm,
  +name: String,
  +tel: KTerm,
  +n: U32,
  +xs: List<&2, KTerm>,
  +fresh: U32,
) -> KTerm:
  kc(KTerm, U32.is_eq(n, 0), u => kapply(lhs, kt("Ctr", name, 0, 0, xs)), u => k_lam(nm(tel), fresh, qt(tel), Con{lhs_ext(lhs, name, kid(tel, 1), U32.sub(n, 1), norm_join(xs, Con{var(nm(tel), fresh), Nil{}}), U32.add(fresh, 1)), Nil{}}, 0, 0, False{}))

# Module: src/check/kernel.bend:874
@unsafe
def mat_lhs(e, name, tel, n, avoid):
  kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => ki_lhs(e, name, tel, n, kc(U32, U32.is_eq(n, 0), u => 0, u => U32.add(1, kw_temp_floor(cw(e), Con{cl(e), Con{tel, avoid}})))))

# Module: src/check/kernel.bend:878
@unsafe
def check_rwt(e, ctx, t, dem, ty, r):
  kc(KChecking, good(r), u => check_rwt_type(ke_world(e, rw(r)), ctx, t, dem, ty, r, wnf(kw_book(rw(r)), cy(r))), u => r)

# Module: src/check/kernel.bend:882
@unsafe
def check_rwt_type(e, ctx, t, dem, ty, r, eq):
  kc(KChecking, p98_tag_eq(eq, "Eql"), u => ki_rwt_bound(e, ctx, t, dem, ty, r, eq, kw_temp_floor(cw(e), [t, ty, cl(e)])), u => dg_trace(e, ctx, kid(t, 0), ty, kr_from(r, dg_bad_detail(rw(r), "rewrite requires equality evidence", dg_text("an equation {a == b : T}"), cy(r)))))

# Module: src/check/kernel.bend:886
@unsafe
def check_rwt_goal(e, ctx, t, dem, ty, r, eq, fresh):
  +goal = all(1, "_", fresh, kid(eq, 2), all(1, "e", U32.add(fresh, 1), kt("Eql", "", 0, 0, Con{kid(eq, 0), Con{var("_", fresh), Con{kid(eq, 2), Nil{}}}}), typ(1)))
  +next = ke_world(e, kw_temporary(cw(e), goal, U32.add(fresh, 1)))
  ki_rwt_motive(next, ctx, t, dem, ty, r, eq, check(next, ctx, kid(t, 1), 0, goal))

# Module: src/check/kernel.bend:892
@unsafe
def tele_quantities(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => tele_quantities_head(book, wnf(book, ty), n))

# Module: src/check/kernel.bend:900
@unsafe
def tele_quantities_head(book, ty, n):
  Con{qua(kc(U32, p98_tag_eq(ty, "All"), u => qt(ty), u => 1)), tele_quantities(book, kid(ty, 1), U32.sub(n, 1))}

# Module: src/check/kernel.bend:904
@unsafe
def declared(
  +d: KDef,
) -> KDef:
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dc(d), db(d), du(d)}

# Module: src/check/kernel.bend:910
@unsafe
def check_book(
  +book: List<&2, KDef>,
) -> String:
  dg_result_error(check_book_diagnostic(book, Nil{}))

# Module: src/check/kernel.bend:916
@unsafe
def check_open(
  +book: List<&2, KDef>,
) -> String:
  check_open_message(count_open(book))

# Module: src/check/kernel.bend:922
@unsafe
def count_open(book):
  match book:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent") && Bool.not(db(d)), u => 1, u => 0), count_open(rest))

# Module: src/check/kernel.bend:930
@unsafe
def check_open_message(n):
  kc(String, U32.is_eq(n, 0), u => "", u => U32.show(n) ++ " TODO" ++ kc(String, U32.is_eq(n, 1), u => "", u => "s") ++ " found.\nThe code is incomplete, and not a valid proof yet.")

# Module: src/check/kernel.bend:934
@unsafe
def signature_mode(
  +d: KDef,
  +later: List<&2, KDef>,
) -> KDef:
  kc(KDef, p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent"), u => signature_fill_mode(d, lookup(later, dn(d))), u => d)

# Module: src/check/kernel.bend:941
@unsafe
def signature_fill_mode(d, fill):
  kc(KDef, p88_string_eq(dk(fill), "Def"), u => declared(fill), u => d)

# Every declaration is visible; only completed bodies may unfold. A separate
# event history retains duplicate/law diagnostics without hiding future types.

# Module: src/check/kernel.bend:947
@unsafe
def check_declarations(
  +todo: List<&2,KDef>,
  +done: List<&2,KDef>,
) -> List<&2,KDef>:
  match todo:
    case Nil{}: done
    case Con{d, rest}:
      check_declarations(rest, book_put(done, kc(KDef, p98_tag_eq(dv(d), "Foreign"), u => d, u => declared(d))))

# Module: src/check/kernel.bend:957
@unsafe
def check_event_install(
  +done: List<&2,KDef>,
  +d: KDef,
  +rest: List<&2,KDef>,
) -> List<&2,KDef>:
  kc(List<&2,KDef>, p88_string_eq(dk(lookup(rest, dn(d))), "Absent"), u => book_put(done, d), u => done)

# Module: src/check/kernel.bend:965
@unsafe
def event_error(
  +done: List<&2, KDef>,
  +d: KDef,
  +old: KDef,
) -> String:
  kc(String, p88_string_eq(dk(old), "Absent"), u => kc(String, p88_string_eq(dk(d), "ADT"), u => constructor_names(done, dc(d), Nil{}), u => ""), u => kc(String, p88_string_eq(dk(old), "Def") && p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(old), "Absent") && Bool.not(p98_tag_eq(dv(d), "Absent")), u => kc(String, compare(done, dt(old), dt(d), False{}) && U32.is_eq(dx(old), dx(d)), u => "", u => "definition does not match prior law signature"), u => "duplicate declaration"))

# Module: src/check/kernel.bend:973
@unsafe
def constructor_exists(
  +ds: List<&2, KDef>,
  +name: String,
) -> Bool:
  match ds:
    case Nil{}:
      False{}
    case Con{h, rest}:
      Bool.not(p88_string_eq(dk(h), "BookCache")) && Bool.not(p88_string_eq(dk(lookup(dc(h), name)), "Absent")) || constructor_exists(rest, name)

# Module: src/check/kernel.bend:984
@unsafe
def constructor_names(done, ctrs, names):
  match ctrs:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, has_name(names, dn(h)) || constructor_exists(done, dn(h)), u => "duplicate constructor name", u => constructor_names(done, rest, Con{dn(h), names}))

# Module: src/check/kernel.bend:992
@unsafe
def check_definition(
  +book: List<&2, KDef>,
  +d: KDef,
) -> String:
  ce(check_definition_result(book, d))

# Module: src/check/kernel.bend:1004
@unsafe
def check_definition_result(book, d):
  check_definition_world(kw_initial(book), d, 0)

# Module: src/check/kernel.bend:1008
@unsafe
def check_definition_type(book, d, e, r):
  kc(KChecking, good(r), u => kc(KChecking, p88_string_eq(dk(d), "ADT"), u => check_adt_declaration(ke_world(e, rw(r)), d),
   u => kc(KChecking, p98_tag_eq(dv(d), "Absent"), u => r, u => kc(KChecking, p98_tag_eq(dv(d), "Foreign"), u => check_foreign(rw(r), d, cd(e)), u => check_definition_body(rw(r), d, cd(e))))), u => r)

# Module: src/check/kernel.bend:1013
@unsafe
def foreign_tip(
  +t: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(strip(t), "All"), u => foreign_tip(kid(strip(t), 1)), u => strip(t))

# Module: src/check/kernel.bend:1019
@unsafe
def foreign_head(
  +t: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "App"), u => foreign_head(kid(t, 0)), u => t)

# Module: src/check/kernel.bend:1025
@unsafe
def check_foreign(world, d, depth):
  +book = kw_book(world)
  kc(KChecking, U32.is_eq(dx(d), 0) && p98_tag_eq(foreign_head(foreign_tip(dt(d))), "Ref") && p88_string_eq(nm(foreign_head(foreign_tip(dt(d)))), "IO") && p88_string_eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u => bad(world, ""), u => dg_trace(KEnv{world, dn(d), ref(dn(d)), 0, Nil{}, du(d), depth}, Nil{}, foreign_tip(dt(d)), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(world, "foreign definition must return base IO directly", dg_text("a foreign definition returning base IO(...) directly (return type aliases are not unfolded)"), dg_text(dn(d)))))

# Module: src/check/kernel.bend:1030
@unsafe
def tele_tip(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  tele_tip_head(book, wnf(book, t))

# Module: src/check/kernel.bend:1037
@unsafe
def tele_tip_head(book, t):
  kc(KTerm, p98_tag_eq(t, "All"), u => tele_tip(book, kid(t, 1)), u => t)

# Module: src/check/kernel.bend:1041
@unsafe
def check_adt_declaration(e, d):
  kc(KChecking, p98_tag_eq(tele_tip(cb(e), dt(d)), "Typ"), u => check_ctors(e, d, dc(d), dt(d)), u => check_adt_kind(e, d, dt(d), Nil{}))

# Module: src/check/kernel.bend:1045
@unsafe
def check_adt_kind(+e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  dg_trace(e, ctx, tel, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, check_adt_kind_head(e, d, wnf(cb(e), tel), ctx))

# Module: src/check/kernel.bend:1049
@unsafe
def check_adt_kind_head(+e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  kc(KChecking, p98_tag_eq(tel, "All"), u => check_adt_kind(e, d, kid(tel, 1), ctx_bind(ctx, ix(tel), qt(tel), nm(tel), kid(tel, 0))), u => kc(KChecking, p98_tag_eq(tel, "Typ"), u => check_ctors(e, d, dc(d), dt(d)), u => dg_trace(e, ctx, tel, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(cw(e), "datatype declaration must return a kind", dg_text("a kind (type " ++ name_key(dn(d)) ++ "<..> is Kind(g))"), tel))))

# Module: src/check/kernel.bend:1053
@unsafe
def check_ctors(e, d, ctrs, kind):
  match ctrs:
    case Nil{}:
      bad(cw(e), "")
    case Con{h, t}:
      check_ctors_next(e, d, t, kind, check_ctor_tel(KEnv{cw(e), dn(h), ref(dn(h)), 0, Nil{}, cu(e), cd(e)}, d, dt(h), kind, da(d), da(h), Nil{}, Nil{}))

# Module: src/check/kernel.bend:1061
@unsafe
def check_ctors_next(e, d, rest, kind, err):
  kc(KChecking, good(err), u => check_ctors(ke_world(e, rw(err)), d, rest, kind), u => err)

# Module: src/check/kernel.bend:1065
@unsafe
def check_ctor_tel(e, d, tel, kind, params, fields, ctx, args):
  kc(KChecking, U32.is_eq(U32.add(params, fields), 0), u => kc(KChecking, compare(cb(e), tel, kt("ADT", dn(d), 0, 0, args), False{}), u => bad(cw(e), ""), u => dg_trace(e, ctx, tel, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(cw(e), "constructor result must apply family to its parameters", dg_text("a telescope tipped at " ++ name_key(dn(d)) ++ " applied to its own parameters"), tel))), u => check_ctor_head(e, d, wnf(cb(e), tel), kind, params, fields, ctx, args))

# Module: src/check/kernel.bend:1069
@unsafe
def check_ctor_head(e, d, tel, kind, params, fields, ctx, args):
  kc(KChecking, p98_tag_eq(tel, "All"), u => check_ctor_domain(e, d, tel, kind, params, fields, ctx, args, check(e, ctx, kid(tel, 0), 0, kc(KTerm, U32.is_eq(params, 0) && U32.is_eq(qt(tel), 1), u => kind, u => typ(qt(tel))))), u => bad(cw(e), "constructor telescope missing a binder"))

# Module: src/check/kernel.bend:1073
@unsafe
def check_ctor_domain(e, d, tel, kind, params, fields, ctx, args, r):
  kc(KChecking, good(r), u => check_ctor_tel(ke_world(e, rw(r)), d, kid(tel, 1), kc(KTerm, U32.is_eq(params, 0), u => kind, u => subst(kid(wnf(kw_book(rw(r)), kind), 1), ix(wnf(kw_book(rw(r)), kind)), var(nm(tel), ix(tel)))), kc(U32, U32.is_eq(params, 0), u => 0, u => U32.sub(params, 1)), kc(U32, U32.is_eq(params, 0), u => U32.sub(fields, 1), u => fields), ctx_bind(ctx, ix(tel), qt(tel), nm(tel), kid(tel, 0)), kc(List<&2, KTerm>, U32.is_eq(params, 0), u => args, u => norm_join(args, Con{var(nm(tel), ix(tel)), Nil{}}))), u => r)

# Module: src/check/kernel.bend:1077
@unsafe
def infer_template(e, ctx, t, dem, sp, d):
  kc(KChecking, U32.is_eq(dem, 0) || U32.is_eq(dx(d), 0) || U32.is_gt(dx(lookup(cb(e), cn(e))), 0), u => ok(cw(e), t, dt(d), Nil{}), u => sp_live_checked(e, ctx, t, sp, d, dg_template_result(e, ctx, t, template_args(e, dt(d), sp, dx(d)))))

# Module: src/check/kernel.bend:1081
@unsafe
def template_args(e, ty, sp, n):
  kc(KChecking, U32.is_eq(n, 0), u => ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, ty, Nil{}), u => template_arg_head(e, wnf(cb(e), ty), sp, n))

# Module: src/check/kernel.bend:1085
@unsafe
def template_arg_head(e, ty, sp, n):
  match sp:
    case Nil{}:
      bad(cw(e), "template requires all closed comptime arguments")
    case Con{h, t}:
      kc(KChecking, p98_tag_eq(ty, "All"), u => template_arg_done(e, ty, h, t, n, check(e, Nil{}, h, 0, kid(ty, 0))), u => bad(cw(e), "invalid template telescope"))

# Module: src/check/kernel.bend:1093
@unsafe
def template_arg_done(e, ty, h, rest, n, r):
  kc(KChecking, good(r), u => template_args(ke_world(e, rw(r)), subst(kid(ty, 1), ix(ty), h), rest, U32.sub(n, 1)), u => r)

# Module: src/check/kernel.bend:1097
@unsafe
def self_pending(
  +d: KDef,
  +body: KTerm,
) -> U32:
  kc(U32, du(d), u => 0, u => kc(U32, contains_self(Con{body, Nil{}}, dn(d)), u => U32.sub(da(d), dx(d)), u => 0))

# Module: src/check/kernel.bend:1104
@unsafe
def contains_self(todo, name):
  match todo:
    case Nil{}:
      False{}
    case Con{h, rest}:
      kc(Bool, p98_tag_eq(h, "Ref") && p88_string_eq(nm(h), name), u => True{}, u => contains_self(norm_join(ks(h), rest), name))

# Module: src/check/kernel.bend:1112
@unsafe
def check_template_definition(world, d, ty, body, lhs, n, depth):
  +book = kw_book(world)
  kc(KChecking, U32.is_eq(n, 0), u => check(KEnv{world, dn(d), lhs, kc(U32, U32.is_gt(depth, 0) && Bool.not(du(d)), u => U32.sub(da(d), dx(d)), u => self_pending(d, body)), tele_quantities(book, dt(d), da(d)), du(d), depth}, Nil{}, body, 1, ty), u => check_template_binder(world, d, wnf(book, ty), body, lhs, n, depth))

# Module: src/check/kernel.bend:1117
@unsafe
def check_template_binder(world, d, ty, body, lhs, n, depth):
  +book = kw_book(world)
  kc(KChecking, p98_tag_eq(ty, "All"), u => check_template_open(world, d, ty, body, lhs, n, dn(d) ++ "~" ++ nm(ty), depth), u => bad(world, "template telescope is too short"))

# Module: src/check/kernel.bend:1122
@unsafe
def check_template_open(world, d, ty, body, lhs, n, name, depth):
  +book = kw_book(world)
  kc(KChecking, p88_string_eq(dk(lookup(book, name)), "Absent"), u => check_template_definition(kw_with_book(world, book_put(book, KDef{name, "Def", 0, 0, kid(ty, 0), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, True{}, False{}})), d, subst(kid(ty, 1), ix(ty), ref(name)), kapply(body, ref(name)), app(lhs, ref(name)), U32.sub(n, 1), depth), u => dg_trace(KEnv{world, "", ref(dn(d)), 0, Nil{}, du(d), depth}, Nil{}, ty, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(world, "duplicate comptime binder", dg_text("a fresh ~ binder name"), dg_text(nm(ty)))))

# Module: src/check/kernel.bend:1148
@unsafe
def tele_check_cached_head(e, ctx, tel, h, rest, dem):
  kc(KChecking, p98_tag_eq(tel, "All"),
    u => tele_check_after_head(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))),
    u => bad(cw(e), "too many telescope arguments"))

# Module: src/check/kernel.bend:1154
@unsafe
def tele_check_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, rest}:
      kc(KChecking, p98_tag_eq(tel, "All"), u => ki_tele_static(e, ctx, tel, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))), u => tele_check(e, ctx, tel, args, dem))

# Module: src/check/kernel.bend:1161
@unsafe
def tele_check_legacy(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +tel: KTerm,
  +args: List<&2, KTerm>,
  +dem: U32,
) -> KChecking:
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, rest}:
      tele_check_legacy_head(e, ctx, wnf(cb(e), tel), h, rest, dem)

# Module: src/check/kernel.bend:1174
@unsafe
def tele_check_legacy_head(e, ctx, tel, h, rest, dem):
  kc(KChecking, p98_tag_eq(tel, "All"), u => ki_tele_legacy(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))), u => bad(cw(e), "too many telescope arguments"))

# Module: src/check/kernel.bend:1188
@unsafe
def tele_check_after_head(e, ctx, tel, h, rest, dem, checked_head):
  kc(KChecking, good(checked_head), u => kc(KChecking, core_subst_stable(kid(tel, 1)),
    u => tele_check_done(checked_head, tele_check_static(ke_world(e, rw(checked_head)), ctx, kid(tel, 1), rest, dem)),
    u => tele_check_done(checked_head, env_tele_check(ke_world(e, rw(checked_head)), ctx, subst(kid(tel, 1), ix(tel), h), rest, dem))), u => checked_head)

# Module: src/check/kernel.bend:1194
@unsafe
def check_mat_filled(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm) -> KChecking:
  ki_match_bound(e, ctx, t, dem, ty, a, ctr, tel, kc(U32, U32.is_eq(cp(e), 0) || U32.is_eq(da(ctr), 0), u => 0, u => kw_temp_floor(cw(e), Con{cl(e), Con{tel, Con{t, Con{ty, ctx}}}})))

# Module: src/check/kernel.bend:1205
@unsafe
def kw_initial(+book: List<&2,KDef>) -> KWorld:
  KWorld{book, Nil{}, KFreshDeferred{Nil{}}, Nil{}}

# Module: src/check/kernel.bend:1209
@unsafe
def kw_book(+world: KWorld) -> List<&2,KDef>:
  match world:
    case KWorld{book, memo, fresh, checked}: book

# Module: src/check/kernel.bend:1214
@unsafe
def kw_memo(+world: KWorld) -> List<&2,KSpecMemo>:
  match world:
    case KWorld{book, memo, fresh, checked}: memo

# Module: src/check/kernel.bend:1219
@unsafe
def kw_fresh(+world: KWorld) -> KWorldFresh:
  match world:
    case KWorld{book, memo, fresh, checked}: fresh

# Module: src/check/kernel.bend:1224
@unsafe
def kw_with_book(+world: KWorld, +book: List<&2,KDef>) -> KWorld:
  KWorld{book, kw_memo(world), kw_fresh(world), kw_checked(world)}

# Module: src/check/kernel.bend:1228
@unsafe
def cw(+e: KEnv) -> KWorld:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}: world

# Module: src/check/kernel.bend:1233
@unsafe
def cd(+e: KEnv) -> U32:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}: depth

# Module: src/check/kernel.bend:1238
@unsafe
def rw(+r: KChecking) -> KWorld:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}: world

# Module: src/check/kernel.bend:1243
@unsafe
def rx(+r: KChecking) -> U32:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}: consumed

# Module: src/check/kernel.bend:1248
@unsafe
def kw_restore_definition(+world: KWorld, +d: KDef, +r: KChecking) -> KChecking:
  kc(KChecking, good(r) && U32.is_gt(dx(d), 0), u => KChecking{ct(r), cy(r), cs(r), ce(r), kw_with_book(rw(r), kw_book(world)), rx(r)}, u => r)

# Module: src/check/kernel.bend:1252
@unsafe
def check_definition_world(+world: KWorld, +d: KDef, +depth: U32) -> KChecking:
  +e: KEnv = KEnv{world, dn(d), ref(dn(d)), 0, Nil{}, du(d), depth}
  check_definition_type(kw_book(world), d, e, check(e, Nil{}, dt(d), 0, typ(1)))

# A translated failure retains the completed check's actual world and transport.

# Module: src/check/kernel.bend:1258
@unsafe
def kr_from(+origin: KChecking, +derived: KChecking) -> KChecking:
  KChecking{ct(derived), cy(derived), cs(derived), ce(derived), rw(origin), rx(origin)}

# Module: src/check/kernel.bend:1261
@unsafe
def kw_checked(+world: KWorld) -> List<&2,KDef>:
  match world:
    case KWorld{book, memo, fresh, checked}: checked

# Module: src/check/kernel.bend:1266
@unsafe
def kw_seed(+book: List<&2,KDef>, +bound: U32) -> KWorld:
  KWorld{book, Nil{}, kc(KWorldFresh, U32.is_eq(bound, 4294967295), u => KFreshDeferred{Nil{}}, u => KFreshKnown{U32.add(bound, 1)}), Nil{}}

# Module: src/check/kernel.bend:1270
@unsafe
def kw_with_checked(+world: KWorld, +checked: List<&2,KDef>) -> KWorld:
  KWorld{kw_book(world), kw_memo(world), kw_fresh(world), checked}

# Module: src/check/kernel.bend:1274
@unsafe
def kw_put_checked(+world: KWorld, +d: KDef) -> KWorld:
  kw_with_checked(world, Con{d, kw_checked(world)})

# Module: src/check/kernel.bend:1278
@unsafe
def ke_world(+e: KEnv, +world: KWorld) -> KEnv:
  KEnv{world, cn(e), cl(e), cp(e), cq(e), cu(e), cd(e)}

# Module: src/check/kernel.bend:1282
@unsafe
def kw_owner(+world: KWorld, +ty: KTerm, +body: KTerm) -> KWorld:
  kw_owner_fresh(world, ty, body, kw_fresh(world))

# Module: src/check/kernel.bend:1286
@unsafe
def kw_owner_fresh(+world: KWorld, +ty: KTerm, +body: KTerm, +fresh: KWorldFresh) -> KWorld:
  match fresh:
    case KFreshKnown{next}: world
    case KFreshDeferred{roots}: KWorld{kw_book(world), kw_memo(world), KFreshDeferred{Con{ty, Con{body, roots}}}, kw_checked(world)}

# Module: src/check/kernel.bend:1292
@unsafe
def check_definition_body(+world: KWorld, +d: KDef, +depth: U32) -> KChecking:
  kw_restore_definition(world, d, check_template_definition(kw_owner(world, dt(d), dv(d)), d, dt(d), dv(d), ref(dn(d)), dx(d), depth))

# Module: src/check/kernel.bend:1295
@unsafe
def ki_one(+t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => checked(r, k_with_children(t, [ct(r)]), ty), u => r)

# Module: src/check/kernel.bend:1299
@unsafe
def ki_pair(+t: KTerm, +ty: KTerm, +a: KChecking, +b: KChecking, +join: Bool) -> KChecking:
  both(a, b, k_with_children(t, [ct(a), ct(b)]), ty, join)

# Module: src/check/kernel.bend:1303
@unsafe
def ki_args(+t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => checked(r, k_with_children(t, ks(ct(r))), ty), u => r)

# Module: src/check/kernel.bend:1307
@unsafe
def ki_min(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_pair(t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, a, check(ke_world(e, rw(a)), ctx, kid(t, 1), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), False{}), u => a)

# Module: src/check/kernel.bend:1311
@unsafe
def ki_all(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_pair(t, typ(1), a, check(ke_world(e, rw(a)), ctx_bind(ctx, ix(t), qt(t), nm(t), kid(t, 0)), kid(t, 1), 0, typ(1)), False{}), u => a)

# Module: src/check/kernel.bend:1315
@unsafe
def ki_eql_type(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_eql_left(ke_world(e, rw(a)), ctx, t, a, check(ke_world(e, rw(a)), ctx, kid(t, 0), 0, kid(t, 2))), u => a)

# Module: src/check/kernel.bend:1319
@unsafe
def ki_eql_left(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking, +b: KChecking) -> KChecking:
  kc(KChecking, good(b), u => ki_eql_done(t, a, b, check(ke_world(e, rw(b)), ctx, kid(t, 1), 0, kid(t, 2))), u => b)

# Module: src/check/kernel.bend:1323
@unsafe
def ki_eql_done(+t: KTerm, +a: KChecking, +b: KChecking, +c: KChecking) -> KChecking:
  both(a, both(b, c, t, typ(2), False{}), k_with_children(t, [ct(b), ct(c), ct(a)]), typ(2), False{})

# Module: src/check/kernel.bend:1327
@unsafe
def ki_ann(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  kc(KChecking, good(a), u => ki_ann_done(t, a, check(ke_world(e, rw(a)), ctx, kid(t, 0), dem, kid(t, 1))), u => a)

# Module: src/check/kernel.bend:1331
@unsafe
def ki_ann_done(+t: KTerm, +a: KChecking, +b: KChecking) -> KChecking:
  both(a, b, k_with_children(t, [ct(b), kid(t, 1)]), kid(t, 1), False{})

# Module: src/check/kernel.bend:1335
@unsafe
def ki_lam_kind(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +q: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => check_lam_done(t, ty, q, check(lhs_step(ke_world(e, rw(r)), var(nm(t), ix(t))), ctx_bind(ctx, ix(t), q, nm(t), kid(ty, 0)), kid(t, 0), dem, subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))))), u => r)

# Module: src/check/kernel.bend:1339
@unsafe
def ki_reverse_terms(+xs: List<&2,KTerm>, +out: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: out
    case Con{h, rest}: ki_reverse_terms(rest, Con{h, out})

# Module: src/check/kernel.bend:1345
@unsafe
def ki_let_finish(+site: KTerm, +out: List<&2,KTerm>, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => checked(r, k_with_children(site, ki_reverse_terms(out, [ct(r)])), cy(r)), u => r)

# Module: src/check/kernel.bend:1349
@unsafe
def ki_tele_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => tele_check_done(r, tele_check_static(ke_world(e, rw(r)), ctx, kid(tel, 1), rest, dem)), u => r)

# Module: src/check/kernel.bend:1353
@unsafe
def ki_tele_legacy(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => tele_check_done(r, tele_check_legacy(ke_world(e, rw(r)), ctx, subst(kid(tel, 1), ix(tel), h), rest, dem)), u => r)

# Module: src/check/kernel.bend:1357
@unsafe
def ki_match_arm(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => ki_pair(t, ty, r, check(ke_world(e, rw(r)), ctx, mat_rest(kw_book(rw(r)), t, a), dem, all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}, kb(a), ke(a)}, kid(ty, 1))), True{}), u => r)

# Module: src/check/kernel.bend:1361
@unsafe
def ki_rwt_motive(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +motive: KChecking) -> KChecking:
  kc(KChecking, good(motive), u => kc(KChecking, compare(kw_book(rw(motive)), kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0)), ty, True{}),
    u => ki_rwt_done(t, ty, r, motive, check(ke_world(e, rw(motive)), ctx, kid(t, 2), dem, kapply(kapply(kid(t, 1), kid(eq, 0)), {KTerm{"Rfl", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))),
    u => kr_from(motive, dg_bad_detail(rw(motive), "rewrite motive does not fit goal", ty, kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0))))), u => motive)

# Module: src/check/kernel.bend:1367
@unsafe
def ki_rwt_done(+t: KTerm, +ty: KTerm, +r: KChecking, +motive: KChecking, +body: KChecking) -> KChecking:
  both(r, body, k_with_children(t, [ct(r), ct(motive), ct(body)]), ty, False{})

# Module: src/check/kernel.bend:1370
@unsafe
def ki_ref_result(+e: KEnv, +t: KTerm, +sp: List<&2,KTerm>, +r: KChecking) -> KChecking:
  kc(KChecking, good(r), u => kc(KChecking, p88_string_eq(nm(ct(r)), cn(e)) && Bool.not(cu(e)) && Bool.not(descend_spine(cq(e), sp_drop(sp, rx(r)), unargs(cl(e), Nil{}))), u => kr_from(r, bad(rw(r), "nondecreasing self-call")), u => r), u => r)

# Module: src/check/kernel.bend:1374
@unsafe
def kw_floor_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_max_walk(saved, norm_book_bound(kw_book(world))))

# Module: src/check/kernel.bend:1380
@unsafe
def kw_mint_floor(+world: KWorld, +roots: List<&2,KTerm>) -> U32:
  kw_floor_fresh(world, kw_fresh(world), roots)

# Module: src/check/kernel.bend:1384
@unsafe
def kw_temp_floor(+world: KWorld, +roots: List<&2,KTerm>) -> U32:
  kw_temp_fresh(world, kw_fresh(world), roots)

# Module: src/check/kernel.bend:1388
@unsafe
def kw_temp_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_book_bound(kw_book(world)))

# Module: src/check/kernel.bend:1394
@unsafe
def kw_bound_book(+book: List<&2,KDef>, +bound: U32) -> List<&2,KDef>:
  match book:
    case Nil{}: book_cached(book, bound)
    case Con{h, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(h), "BookCache"), u => Con{KDef{dn(h), dk(h), norm_max(da(h), bound), dx(h), dt(h), dv(h), dc(h), db(h), du(h)}, rest}, u => book_cached(book, bound))

# Module: src/check/kernel.bend:1401
@unsafe
def kw_temporary(+world: KWorld, +root: KTerm, +bound: U32) -> KWorld:
  kw_temporary_fresh(world, root, bound, kw_fresh(world))

# Module: src/check/kernel.bend:1405
@unsafe
def kw_temporary_fresh(+world: KWorld, +root: KTerm, +bound: U32, +fresh: KWorldFresh) -> KWorld:
  match fresh:
    case KFreshKnown{next}: KWorld{kw_bound_book(kw_book(world), bound), kw_memo(world), KFreshKnown{norm_max(next, U32.add(bound, 1))}, kw_checked(world)}
    case KFreshDeferred{roots}: KWorld{kw_book(world), kw_memo(world), KFreshDeferred{Con{root, roots}}, kw_checked(world)}

# Module: src/check/kernel.bend:1411
@unsafe
def ki_rwt_bound(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +bound: U32) -> KChecking:
  kc(KChecking, U32.is_le(bound, 4294967292), u => check_rwt_goal(e, ctx, t, dem, ty, r, eq, U32.add(bound, 1)), u => kr_from(r, bad(rw(r), "fresh binder space exhausted")))

# Module: src/check/kernel.bend:1415
@unsafe
def ki_lhs(+e: KEnv, +name: String, +tel: KTerm, +n: U32, +fresh: U32) -> KEnv:
  +lhs = lhs_ext(cl(e), name, tel, n, Nil{}, fresh)
  KEnv{kc(KWorld, U32.is_eq(n, 0), u => cw(e), u => kw_temporary(cw(e), lhs, U32.sub(U32.add(fresh, n), 1))), cn(e), lhs, U32.add(U32.sub(cp(e), 1), n), cq(e), cu(e), cd(e)}

# Module: src/check/kernel.bend:1420
@unsafe
def ki_match_bound(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm, +bound: U32) -> KChecking:
  kc(KChecking, U32.is_eq(cp(e), 0) || U32.is_eq(da(ctr), 0) || (U32.is_lt(da(ctr), 4294967295) && U32.is_le(bound, U32.sub(4294967294, da(ctr)))),
    u => ki_match_arm(e, ctx, t, dem, ty, a, check(kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => ki_lhs(e, nm(t), tel, da(ctr), U32.add(bound, 1))), ctx, kid(t, 0), dem, mat_goal(cb(e), ty, tel, da(ctr), nm(t), Nil{}))),
    u => bad(cw(e), "fresh binder space exhausted"))
