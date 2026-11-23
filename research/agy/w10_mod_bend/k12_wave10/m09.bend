# Module m09 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=616 laws=79 sccs=301 deps=[m00,m01,m02,m03,m04,m05,m06,m07,m08] cross_imports=743 fid_base=46080..51199

law infer_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +dem: U32
  for +sp: List<&2, KTerm>
  KChecking

# Module: src/check/kernel.bend:18
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
law tele_check:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  for +dem: U32
  KChecking

# Module: src/check/kernel.bend:72
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
law check_let_done:
  for +e: KEnv
  for +ctx: List<&2,KTerm>
  for +r: KChecking
  for +bs: List<&2, KTerm>
  for +us: List<&2, KTerm>
  for +site: KTerm
  KChecking

# Module: src/check/kernel.bend:211
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
law check_foreign:
  for +world: KWorld
  for +d: KDef
  for +depth: U32
  KChecking

# Module: src/check/kernel.bend:337
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

# Module: src/check/env-telescope.bend:10
law env_tele_check_loop:
  for +e: KEnv
  for +ctx: List<&2,KTerm>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +dem: U32
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KChecking

# Module: src/check/env-substitution.bend:7
law annotate_selected:
  for +book: List<&2, KDef>
  for +selected: List<&2, KDef>
  for +stops: List<&2, String>
  List<&2, KDef>

# Module: src/check/annotate.bend:11
law ka_defs_except:
  for +book: List<&2, KDef>
  for +ds: List<&2, KDef>
  for +stops: List<&2, String>
  List<&2, KDef>

# Module: src/check/annotate.bend:22
law ka_def:
  for +book: List<&2, KDef>
  for +d: KDef
  KDef

# Module: src/check/annotate.bend:27
law f_binary_plain:
  for +a: KTerm
  for +op: String
  for +b: KTerm
  for +opBegin: U32
  for +opEnd: U32
  for +begin: U32
  for +end: U32
  for +input: FInput
  KTerm

# Module: src/front/parser.bend:507
law fpe_render:
  for +source: String
  for +error: KTerm
  String

# Module: src/front/parser.bend:528
law f_operator_display:
  for +name: String
  for +ops: List<&2,String>
  String

# Module: src/front/validate.bend:3
law dg_trace:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +r: KChecking
  KChecking

# Module: src/diagnostic/trace.bend:29
law j_io_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/common/queries.bend:171
law j_main_error:
  for +book: List<&2, KDef>
  for +main: KDef
  String

# Module: src/back/js/validate.bend:23
law no_emit:
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +params: List<&2, NC_Binding>
  for +layouts: List<&2, NO_Layout>
  for +n: U32
  NC_Code

# Module: src/back/native/observer-adapter.bend:40
law noa_eval:
  for +ctx: NO_Context
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +stack: List<&2, String>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

# Module: src/back/native/observer-analysis.bend:166
law noa_apply:
  for +ctx: NO_Context
  for +fn: KTerm
  for +arg: KTerm
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

# Module: src/back/native/observer-analysis.bend:273
law noa_recur:
  for +ctx: NO_Context
  for +args: List<&2, KTerm>
  for +facts: List<&2, KTerm>
  for +n: U32
  for +fuel: U32
  for +k: NO_Cont
  NO_Analysis

# Module: src/back/native/observer-analysis.bend:369
@unsafe
def book_put_many(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: book
    case Con{d, rest}:
      kc(List<&2,KDef>, book_put_many_regular(defs),
        u => kc(List<&2,KDef>, book_final_names_valid(defs),
          u => kc(List<&2,KDef>, book_final_names_valid(book),
            u => book_put_many_fast(book, defs), u => book_put_many_legacy(book, defs)),
          u => book_put_many_legacy(book, defs)),
        u => book_put_many_legacy(book, defs))

# Module: src/core/normalize.bend:6
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
def w7_if_infer_ref(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>) -> KChecking:
  match ok_t:
    case True{}:
      infer_ref(e, ctx, t, dem, sp, lookup(cb(e), nm(t)))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_ann(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      ki_ann(e, ctx, t, dem, check(e, ctx, kid(t, 1), 0, typ(1)))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_all(ok_t: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      ki_all(e, ctx, t, dg_kind_check(e, ctx, kid(t, 0), qt(t), nm(t)))
    case False{}:
      w7_if_infer_ann(p88_string_eq(tag, "Ann"), e, ctx, t, dem)

@unsafe
def w7_if_infer_adt(ok_t: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      infer_adt(e, ctx, t, dem, lookup(cb(e), nm(t)))
    case False{}:
      w7_if_infer_all(p88_string_eq(tag, "All"), tag, e, ctx, t, dem)

@unsafe
def w7_if_infer_app(ok_t: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>) -> KChecking:
  match ok_t:
    case True{}:
      infer_app(e, ctx, t, dem, infer(e, ctx, kid(t, 0), dem, Con{kid(t, 1), sp}))
    case False{}:
      w7_if_infer_adt(p88_string_eq(tag, "ADT"), tag, e, ctx, t, dem)

@unsafe
def w7_if_infer_typ(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ki_one(t, typ(1), check(e, ctx, kid(t, 0), 0, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_min(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      ki_min(e, ctx, t, dem, check(e, ctx, kid(t, 0), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_eql(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ki_eql_type(e, ctx, t, check(e, ctx, kid(t, 2), 0, typ(1)))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_infer_tag(c0: U32, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>) -> KChecking:
  match c0:
    case 86:
      w7_if_infer_var(p88_string_eq(tag, "Var"), e, ctx, t, dem)
    case 65:
      w7_if_infer_app(p88_string_eq(tag, "App"), tag, e, ctx, t, dem, sp)
    case 82:
      w7_if_infer_ref(p88_string_eq(tag, "Ref"), e, ctx, t, dem, sp)
    case 84:
      w7_if_infer_typ(p88_string_eq(tag, "Typ"), e, ctx, t)
    case 81:
      w7_if_infer_qnt(p88_string_eq(tag, "Qnt"), tag, e, t)
    case 77:
      w7_if_infer_min(p88_string_eq(tag, "Min"), e, ctx, t, dem)
    case 69:
      w7_if_infer_eql(p88_string_eq(tag, "Eql"), e, ctx, t)
    case 70:
      w7_if_infer_unb(p88_string_eq(tag, "FUnboundVar"), e)
    case _:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def infer_node(e, ctx, t, dem, sp):
  match t:
    case KLiteral{_, _, _, _, _}:
      bad(cw(e), "cannot infer: annotation required")
    case KLambda{_, _, _, _, _, _, _, _}:
      bad(cw(e), "cannot infer: annotation required")
    case KTerm{tag, _, _, _, _, _, _, _}:
      w7_infer_tag(w7_char0(tag), tag, e, ctx, t, dem, sp)

# Module: src/check/kernel.bend:659
@unsafe
def w7_br_159(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      bad(cw(e), "live use of an unfilled law")
    case False{}:
      ki_ref_result(e, t, sp, infer_template(e, ctx, t, dem, sp, d))

@unsafe
def w7_br_160(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      ok(cw(e), t, dt(d), Nil{})
    case False{}:
      w7_br_159(p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent") && Bool.not(p88_string_eq(nm(t), cn(e))) && ((Bool.not(db(d)) && Bool.not(cu(e))) || (U32.is_gt(dx(d), 0) && U32.is_eq(dx(lookup(cb(e), cn(e))), 0))), e, ctx, t, dem, sp, d)

@unsafe
def w7_br_161(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      bad(cw(e), "a family requires angle-bracket parameters")
    case False{}:
      w7_br_160(U32.is_eq(dem, 0), e, ctx, t, dem, sp, d)

@unsafe
def w7_br_162(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      bad(cw(e), "undefined name")
    case False{}:
      w7_br_161(p88_string_eq(dk(d), "ADT") && U32.is_gt(da(d), 0), e, ctx, t, dem, sp, d)

@unsafe
def infer_ref(e, ctx, t, dem, sp, d):
  w7_br_162(p88_string_eq(dk(d), "Absent"), e, ctx, t, dem, sp, d)

# Module: src/check/kernel.bend:672
@unsafe
def w7_br_163(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{ct(r), cy(r), cs(r), "", rw(r), U32.sub(rx(r), 1)}
    case False{}:
      infer_app_type(ke_world(e, rw(r)), ctx, t, dem, r, wnf(kw_book(rw(r)), cy(r)))

@unsafe
def w7_br_164(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_163(U32.is_gt(rx(r), 0), e, ctx, t, dem, r)
    case False{}:
      r

@unsafe
def infer_app(e, ctx, t, dem, r):
  w7_br_164(good(r), e, ctx, t, dem, r)

# Module: src/check/kernel.bend:676
@unsafe
def w7_br_165(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +r: KChecking, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      ki_pair(t, subst(kid(ty, 1), ix(ty), kid(t, 1)), r, check(ke_world(e, rw(r)), ctx, kid(t, 1), qdem(qt(ty), dem), kid(ty, 0)), False{})
    case False{}:
      kr_from(r, dg_bad_detail(rw(r), "application requires a function type", dg_text("a function type"), cy(r)))

@unsafe
def infer_app_type(e, ctx, t, dem, r, ty):
  w7_br_165(p98_tag_eq(ty, "All"), e, ctx, t, dem, r, ty)

# Module: src/check/kernel.bend:680
@unsafe
def w7_br_166(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      infer_adt_done(t, tele_check(e, ctx, dt(d), ks(t), dem))
    case False{}:
      dg_adt_error(cw(e), t, d)

@unsafe
def infer_adt(e, ctx, t, dem, d):
  w7_br_166(p88_string_eq(dk(d), "ADT") && U32.is_eq(terms_len(ks(t)), da(d)), e, ctx, t, dem, d)

# Module: src/check/kernel.bend:684
@unsafe
def tele_check(e, ctx, tel, args, dem):
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, t}: tele_check_cached_head(e, ctx, wnf(cb(e), tel), h, t, dem)

# Module: src/check/kernel.bend:698
@unsafe
def check(e, ctx, t, dem, ty):
  dg_trace(e, ctx, t, ty, check_node(e, ctx, core_beta(t), dem, ty))

# Module: src/check/kernel.bend:718
@unsafe
def w7_check_lit(ok_lit: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match ok_lit:
    case True{}:
      ok(cw(e), t, ty, Nil{})
    case False{}:
      check(e, ctx, core_literal_step(t), dem, ty)

@unsafe
def w7_check_ctr_if(isCtr: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isCtr:
    case True{}:
      check_ctr(e, ctx, t, dem, wnf(cb(e), ty))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_mat_if(isMat: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isMat:
    case True{}:
      check_mat(e, ctx, t, dem, wnf(cb(e), ty))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_rwt_if(isRwt: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isRwt:
    case True{}:
      check_rwt(e, ctx, t, dem, ty, infer(e, ctx, kid(t, 0), dem, Nil{}))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_rfl_if(isRfl: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isRfl:
    case True{}:
      check_rfl_graph(e, t, ty)
    case False{}:
      w7_check_rwt_if(p88_string_eq(tag, "Rwt"), e, ctx, t, dem, ty)

@unsafe
def w7_check_ref_if(isRef: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isRef:
    case True{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)
    case False{}:
      w7_check_rfl_if(p88_string_eq(tag, "Rfl"), tag, e, ctx, t, dem, ty)

@unsafe
def w7_check_hol_if(isHol: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isHol:
    case True{}:
      w7_check_hol_todo(p88_string_eq(nm(t), "TODO"), e, t, ty)
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_lam_if(isLam: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isLam:
    case True{}:
      check_lam(e, ctx, t, dem, wnf(cb(e), ty))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_let_if(isLet: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isLet:
    case True{}:
      check_let(e, ctx, ctx, ks(t), dem, ty, Nil{}, Nil{}, t, Nil{})
    case False{}:
      w7_check_lam_if(p88_string_eq(tag, "Lam"), e, ctx, t, dem, ty)

@unsafe
def w7_check_tag(c0: U32, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match c0:
    case 67:
      w7_check_ctr_if(p88_string_eq(tag, "Ctr"), e, ctx, t, dem, ty)
    case 77:
      w7_check_mat_if(p88_string_eq(tag, "Mat"), e, ctx, t, dem, ty)
    case 69:
      w7_check_mat_if(p88_string_eq(tag, "Efq"), e, ctx, t, dem, ty)
    case 82:
      w7_check_ref_if(p88_string_eq(tag, "Ref"), tag, e, ctx, t, dem, ty)
    case 72:
      w7_check_hol_if(p88_string_eq(tag, "Hol"), e, ctx, t, dem, ty)
    case 76:
      w7_check_let_if(p88_string_eq(tag, "Let"), tag, e, ctx, t, dem, ty)
    case _:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def check_node(e, ctx, t, dem, ty):
  match t:
    case KLiteral{_, _, _, _, _}:
      w7_check_lit(core_literal_type(cb(e), t, wnf(cb(e), ty)), e, ctx, t, dem, ty)
    case KLambda{_, _, _, _, _, _, _, _}:
      check_lam(e, ctx, t, dem, wnf(cb(e), ty))
    case KTerm{tag, _, _, _, _, _, _, _}:
      w7_check_tag(w7_char0(tag), tag, e, ctx, t, dem, ty)

# Module: src/check/kernel.bend:730
@unsafe
def w7_br_169(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      check_lam_q(e, ctx, t, dem, ty, kc(U32, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty)))
    case False{}:
      bad(cw(e), "lambda requires a function type")

@unsafe
def check_lam(e, ctx, t, dem, ty):
  w7_br_169(p98_tag_eq(ty, "All"), e, ctx, t, dem, ty)

# Module: src/check/kernel.bend:738
@unsafe
def check_lam_q(e, ctx, t, dem, ty, q):
  ki_lam_kind(e, ctx, t, dem, ty, q, kc(KChecking, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => dg_kind_check(e, ctx, kid(ty, 0), q, nm(t)), u => ok(cw(e), t, ty, Nil{})))

# Module: src/check/kernel.bend:742
@unsafe
def w7_br_172(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      check_ctr_found(e, ctx, t, dem, ty, lookup(dc(lookup(cb(e), nm(ty))), nm(t)))
    case False{}:
      bad(cw(e), "constructor requires a datatype goal")

@unsafe
def check_ctr(e, ctx, t, dem, ty):
  w7_br_172(p98_tag_eq(ty, "ADT"), e, ctx, t, dem, ty)

# Module: src/check/kernel.bend:750
@unsafe
def w7_br_173(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +ctr: KDef) -> KChecking:
  match w7_c:
    case True{}:
      ki_args(t, ty, tele_check(e, ctx, tele_fill(cb(e), dt(ctr), ks(ty)), ks(t), dem))
    case False{}:
      dg_ctor_error(e, t, ty, ctr)

@unsafe
def check_ctr_found(e, ctx, t, dem, ty, ctr):
  w7_br_173(Bool.not(p88_string_eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))) && U32.is_eq(da(ctr), terms_len(ks(t))), e, ctx, t, dem, ty, ctr)

# Module: src/check/kernel.bend:754
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
def w7_br_176(w7_c: Bool, +e: KEnv, +outer: List<&2, KTerm>, +ctx: List<&2, KTerm>, +h: KTerm, +rest: List<&2, KTerm>, +dem: U32, +ty: KTerm, +bindings: List<&2, KTerm>, +us: List<&2, KTerm>, +site: KTerm, +out: List<&2,KTerm>, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_let_kind(ke_world(e, rw(r)), outer, ctx, h, rest, dem, ty, bindings, us, site, out, r, kc(KChecking, U32.is_eq(kindq(e, qt(h)), 2), u => dg_kind_at(ke_world(e, rw(r)), outer, cy(r), qt(h), nm(h), h), u => r))
    case False{}:
      r

@unsafe
def check_let_value(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r):
  w7_br_176(good(r), e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r)

# Module: src/check/kernel.bend:769
@unsafe
def w7_br_177(w7_c: Bool, +e: KEnv, +outer: List<&2, KTerm>, +ctx: List<&2, KTerm>, +h: KTerm, +rest: List<&2, KTerm>, +dem: U32, +ty: KTerm, +bindings: List<&2, KTerm>, +us: List<&2, KTerm>, +site: KTerm, +out: List<&2,KTerm>, +r: KChecking, +k: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_let(ke_world(e, rw(k)), outer, ctx_bind(ctx, ix(h), qt(h), nm(h), cy(r)), rest, dem, ty, Con{h, bindings}, uses_merge(us, cs(r), False{}), site, Con{k_with_children(h, Con{ct(r), Nil{}}), out})
    case False{}:
      k

@unsafe
def check_let_kind(e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r, k):
  w7_br_177(good(k), e, outer, ctx, h, rest, dem, ty, bindings, us, site, out, r, k)

# Module: src/check/kernel.bend:773
@unsafe
def check_let_done(e, ctx, r, bs, us, site):
  match bs:
    case Nil{}:
      kc(KChecking, good(r), u => KChecking{ct(r), cy(r), uses_merge(us, cs(r), False{}), "", rw(r), rx(r)}, u => r)
    case Con{h, t}:
      kc(KChecking, good(r), u => kc(KChecking, U32.is_gt(uses_get(cs(r), ix(h)), qt(h)), u => dg_trace(e, ctx, site, cy(r), kr_from(r, dg_quant_error(rw(r), "let binder consumed more than allowed", nm(h), qt(h), uses_get(cs(r), ix(h))))), u => check_let_done(e, ctx, KChecking{ct(r), cy(r), uses_del(cs(r), ix(h)), "", rw(r), rx(r)}, t, us, site)), u => r)

# Module: src/check/kernel.bend:789
@unsafe
def w7_br_178(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      dg_bad_message(cw(e), "erased scrutinee in live match", dg_text("a live scrutinee (a - scrutinee matches only in a dead region)"))
    case False{}:
      check_mat_type(e, ctx, t, dem, ty, wnf(cb(e), kid(ty, 0)))

@unsafe
def w7_br_179(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_178(Bool.not(U32.is_eq(dem, 0)) && U32.is_eq(qt(ty), 0), e, ctx, t, dem, ty)
    case False{}:
      bad(cw(e), "matcher requires a function type")

@unsafe
def check_mat(e, ctx, t, dem, ty):
  w7_br_179(p98_tag_eq(ty, "All"), e, ctx, t, dem, ty)

# Module: src/check/kernel.bend:832
@unsafe
def w7_br_181(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_180(dead_type(cb(e), a) || ctx_dead(cb(e), ctx), e, t, ty, a)
    case False{}:
      check_mat_ctr(e, ctx, t, dem, ty, a, lookup(remaining(dc(lookup(cb(e), nm(a))), rm(a)), nm(t)))

@unsafe
def w7_br_182(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_181(p98_tag_eq(t, "Efq"), e, ctx, t, dem, ty, a)
    case False{}:
      dg_bad_detail(cw(e), "match scrutinee requires a datatype", dg_text("a datatype"), kid(ty, 0))

@unsafe
def check_mat_type(e, ctx, t, dem, ty, a):
  w7_br_182(p98_tag_eq(a, "ADT") && p88_string_eq(dk(lookup(cb(e), nm(a))), "ADT"), e, ctx, t, dem, ty, a)

# Module: src/check/kernel.bend:840
@unsafe
def w7_br_183(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef) -> KChecking:
  match w7_c:
    case True{}:
      dg_bad_detail(cw(e), "unknown or duplicate match constructor", dg_text("a constructor of " ++ name_key(nm(a)) ++ " (missing, or already matched)"), t)
    case False{}:
      check_mat_filled(e, ctx, t, dem, ty, a, ctr, tele_fill(cb(e), dt(ctr), ks(a)))

@unsafe
def check_mat_ctr(e, ctx, t, dem, ty, a, ctr):
  w7_br_183(p88_string_eq(dk(ctr), "Absent"), e, ctx, t, dem, ty, a, ctr)

# A non-case fallback past the final constructor is unreachable. The checker
# and annotation pass share this choice so backends receive the same Efq.

# Module: src/check/kernel.bend:847
@unsafe
def w7_br_187(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_rwt_type(ke_world(e, rw(r)), ctx, t, dem, ty, r, wnf(kw_book(rw(r)), cy(r)))
    case False{}:
      r

@unsafe
def check_rwt(e, ctx, t, dem, ty, r):
  w7_br_187(good(r), e, ctx, t, dem, ty, r)

# Module: src/check/kernel.bend:882
@unsafe
def w7_br_188(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      ki_rwt_bound(e, ctx, t, dem, ty, r, eq, kw_temp_floor(cw(e), [t, ty, cl(e)]))
    case False{}:
      dg_trace(e, ctx, kid(t, 0), ty, kr_from(r, dg_bad_detail(rw(r), "rewrite requires equality evidence", dg_text("an equation {a == b : T}"), cy(r))))

@unsafe
def check_rwt_type(e, ctx, t, dem, ty, r, eq):
  w7_br_188(p98_tag_eq(eq, "Eql"), e, ctx, t, dem, ty, r, eq)

# Module: src/check/kernel.bend:886
@unsafe
def check_rwt_goal(e, ctx, t, dem, ty, r, eq, fresh):
  +goal = all(1, "_", fresh, kid(eq, 2), all(1, "e", U32.add(fresh, 1), kt("Eql", "", 0, 0, Con{kid(eq, 0), Con{var("_", fresh), Con{kid(eq, 2), Nil{}}}}), typ(1)))
  +next = ke_world(e, kw_temporary(cw(e), goal, U32.add(fresh, 1)))
  ki_rwt_motive(next, ctx, t, dem, ty, r, eq, check(next, ctx, kid(t, 1), 0, goal))

# Module: src/check/kernel.bend:892
@unsafe
def check_foreign(world, d, depth):
  +book = kw_book(world)
  kc(KChecking, U32.is_eq(dx(d), 0) && p98_tag_eq(foreign_head(foreign_tip(dt(d))), "Ref") && p88_string_eq(nm(foreign_head(foreign_tip(dt(d)))), "IO") && p88_string_eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u => bad(world, ""), u => dg_trace(KEnv{world, dn(d), ref(dn(d)), 0, Nil{}, du(d), depth}, Nil{}, foreign_tip(dt(d)), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(world, "foreign definition must return base IO directly", dg_text("a foreign definition returning base IO(...) directly (return type aliases are not unfolded)"), dg_text(dn(d)))))

# Module: src/check/kernel.bend:1030
@unsafe
def w7_br_207(w7_c: Bool, +e: KEnv, +d: KDef, +tel: KTerm, +ctx: List<&2, KTerm>) -> KChecking:
  match w7_c:
    case True{}:
      bad(cw(e), "")
    case False{}:
      dg_trace(e, ctx, tel, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(cw(e), "constructor result must apply family to its parameters", dg_text("a telescope tipped at " ++ name_key(dn(d)) ++ " applied to its own parameters"), tel))

@unsafe
def w7_br_211(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +sp: List<&2, KTerm>, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      ok(cw(e), t, dt(d), Nil{})
    case False{}:
      sp_live_checked(e, ctx, t, sp, d, dg_template_result(e, ctx, t, template_args(e, dt(d), sp, dx(d))))

@unsafe
def infer_template(e, ctx, t, dem, sp, d):
  w7_br_211(U32.is_eq(dem, 0) || U32.is_eq(dx(d), 0) || U32.is_gt(dx(lookup(cb(e), cn(e))), 0), e, ctx, t, sp, d)

# Module: src/check/kernel.bend:1081
@unsafe
def w7_br_212(w7_c: Bool, +e: KEnv, +ty: KTerm, +sp: List<&2, KTerm>, +n: U32) -> KChecking:
  match w7_c:
    case True{}:
      ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, ty, Nil{})
    case False{}:
      template_arg_head(e, wnf(cb(e), ty), sp, n)

@unsafe
def template_args(e, ty, sp, n):
  w7_br_212(U32.is_eq(n, 0), e, ty, sp, n)

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
def w7_br_213(w7_c: Bool, +e: KEnv, +ty: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +n: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      template_args(ke_world(e, rw(r)), subst(kid(ty, 1), ix(ty), h), rest, U32.sub(n, 1))
    case False{}:
      r

@unsafe
def template_arg_done(e, ty, h, rest, n, r):
  w7_br_213(good(r), e, ty, h, rest, n, r)

# Module: src/check/kernel.bend:1097
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
def w7_br_216(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +dem: U32) -> KChecking:
  match w7_c:
    case True{}:
      tele_check_after_head(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)))
    case False{}:
      bad(cw(e), "too many telescope arguments")

@unsafe
def tele_check_cached_head(e, ctx, tel, h, rest, dem):
  w7_br_216(p98_tag_eq(tel, "All"), e, ctx, tel, h, rest, dem)

# Module: src/check/kernel.bend:1154
@unsafe
def w7_tele_static_all(isAll: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +args: List<&2, KTerm>, +dem: U32) -> KChecking:
  match isAll:
    case True{}:
      ki_tele_static(e, ctx, tel, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)))
    case False{}:
      tele_check(e, ctx, tel, args, dem)

@unsafe
def tele_check_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})
    case Con{h, rest}:
      w7_tele_static_all(p98_tag_eq(tel, "All"), e, ctx, tel, h, rest, args, dem)

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
def w7_br_217(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +dem: U32) -> KChecking:
  match w7_c:
    case True{}:
      ki_tele_legacy(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)))
    case False{}:
      bad(cw(e), "too many telescope arguments")

@unsafe
def tele_check_legacy_head(e, ctx, tel, h, rest, dem):
  w7_br_217(p98_tag_eq(tel, "All"), e, ctx, tel, h, rest, dem)

# Module: src/check/kernel.bend:1188
@unsafe
def w7_br_218(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +dem: U32, +checked_head: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      tele_check_done(checked_head, tele_check_static(ke_world(e, rw(checked_head)), ctx, kid(tel, 1), rest, dem))
    case False{}:
      tele_check_done(checked_head, env_tele_check(ke_world(e, rw(checked_head)), ctx, subst(kid(tel, 1), ix(tel), h), rest, dem))

@unsafe
def w7_br_219(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +dem: U32, +checked_head: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_218(core_subst_stable(kid(tel, 1)), e, ctx, tel, h, rest, dem, checked_head)
    case False{}:
      checked_head

@unsafe
def tele_check_after_head(e, ctx, tel, h, rest, dem, checked_head):
  w7_br_219(good(checked_head), e, ctx, tel, h, rest, dem, checked_head)

# Module: src/check/kernel.bend:1194
@unsafe
def check_mat_filled(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm) -> KChecking:
  ki_match_bound(e, ctx, t, dem, ty, a, ctr, tel, kc(U32, U32.is_eq(cp(e), 0) || U32.is_eq(da(ctr), 0), u => 0, u => kw_temp_floor(cw(e), Con{cl(e), Con{tel, Con{t, Con{ty, ctx}}}})))

# Module: src/check/kernel.bend:1205
@unsafe
def check_definition_body(+world: KWorld, +d: KDef, +depth: U32) -> KChecking:
  kw_restore_definition(world, d, check_template_definition(kw_owner(world, dt(d), dv(d)), d, dt(d), dv(d), ref(dn(d)), dx(d), depth))

# Module: src/check/kernel.bend:1295
@unsafe
def w7_br_223(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_pair(t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, a, check(ke_world(e, rw(a)), ctx, kid(t, 1), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), False{})
    case False{}:
      a

@unsafe
def ki_min(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  w7_br_223(good(a), e, ctx, t, dem, a)

# Module: src/check/kernel.bend:1311
@unsafe
def w7_br_224(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_pair(t, typ(1), a, check(ke_world(e, rw(a)), ctx_bind(ctx, ix(t), qt(t), nm(t), kid(t, 0)), kid(t, 1), 0, typ(1)), False{})
    case False{}:
      a

@unsafe
def ki_all(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  w7_br_224(good(a), e, ctx, t, a)

# Module: src/check/kernel.bend:1315
@unsafe
def w7_br_225(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_eql_left(ke_world(e, rw(a)), ctx, t, a, check(ke_world(e, rw(a)), ctx, kid(t, 0), 0, kid(t, 2)))
    case False{}:
      a

@unsafe
def ki_eql_type(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking) -> KChecking:
  w7_br_225(good(a), e, ctx, t, a)

# Module: src/check/kernel.bend:1319
@unsafe
def w7_br_226(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking, +b: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_eql_done(t, a, b, check(ke_world(e, rw(b)), ctx, kid(t, 1), 0, kid(t, 2)))
    case False{}:
      b

@unsafe
def ki_eql_left(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +a: KChecking, +b: KChecking) -> KChecking:
  w7_br_226(good(b), e, ctx, t, a, b)

# Module: src/check/kernel.bend:1323
@unsafe
def w7_br_227(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_ann_done(t, a, check(ke_world(e, rw(a)), ctx, kid(t, 0), dem, kid(t, 1)))
    case False{}:
      a

@unsafe
def ki_ann(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +a: KChecking) -> KChecking:
  w7_br_227(good(a), e, ctx, t, dem, a)

# Module: src/check/kernel.bend:1331
@unsafe
def w7_br_228(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +q: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      check_lam_done(t, ty, q, check(lhs_step(ke_world(e, rw(r)), var(nm(t), ix(t))), ctx_bind(ctx, ix(t), q, nm(t), kid(ty, 0)), kid(t, 0), dem, subst(kid(ty, 1), ix(ty), var(nm(t), ix(t)))))
    case False{}:
      r

@unsafe
def ki_lam_kind(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +q: U32, +r: KChecking) -> KChecking:
  w7_br_228(good(r), e, ctx, t, dem, ty, q, r)

# Module: src/check/kernel.bend:1339
@unsafe
def w7_br_230(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      tele_check_done(r, tele_check_static(ke_world(e, rw(r)), ctx, kid(tel, 1), rest, dem))
    case False{}:
      r

@unsafe
def ki_tele_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  w7_br_230(good(r), e, ctx, tel, rest, dem, r)

# Module: src/check/kernel.bend:1353
@unsafe
def w7_br_231(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      tele_check_done(r, tele_check_legacy(ke_world(e, rw(r)), ctx, subst(kid(tel, 1), ix(tel), h), rest, dem))
    case False{}:
      r

@unsafe
def ki_tele_legacy(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +r: KChecking) -> KChecking:
  w7_br_231(good(r), e, ctx, tel, h, rest, dem, r)

# Module: src/check/kernel.bend:1357
@unsafe
def w7_br_232(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_pair(t, ty, r, check(ke_world(e, rw(r)), ctx, mat_rest(kw_book(rw(r)), t, a), dem, all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}, kb(a), ke(a)}, kid(ty, 1))), True{})
    case False{}:
      r

@unsafe
def ki_match_arm(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +r: KChecking) -> KChecking:
  w7_br_232(good(r), e, ctx, t, dem, ty, a, r)

# Module: src/check/kernel.bend:1361
@unsafe
def w7_br_233(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +motive: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      ki_rwt_done(t, ty, r, motive, check(ke_world(e, rw(motive)), ctx, kid(t, 2), dem, kapply(kapply(kid(t, 1), kid(eq, 0)), {KTerm{"Rfl", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})))
    case False{}:
      kr_from(motive, dg_bad_detail(rw(motive), "rewrite motive does not fit goal", ty, kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0))))

@unsafe
def w7_br_234(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +motive: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_233(compare(kw_book(rw(motive)), kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0)), ty, True{}), e, ctx, t, dem, ty, r, eq, motive)
    case False{}:
      motive

@unsafe
def ki_rwt_motive(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +motive: KChecking) -> KChecking:
  w7_br_234(good(motive), e, ctx, t, dem, ty, r, eq, motive)

# Module: src/check/kernel.bend:1367
@unsafe
def w7_br_237(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +bound: U32) -> KChecking:
  match w7_c:
    case True{}:
      check_rwt_goal(e, ctx, t, dem, ty, r, eq, U32.add(bound, 1))
    case False{}:
      kr_from(r, bad(rw(r), "fresh binder space exhausted"))

@unsafe
def ki_rwt_bound(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +r: KChecking, +eq: KTerm, +bound: U32) -> KChecking:
  w7_br_237(U32.is_le(bound, 4294967292), e, ctx, t, dem, ty, r, eq, bound)

# Module: src/check/kernel.bend:1415
@unsafe
def w7_br_238(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm, +bound: U32) -> KChecking:
  match w7_c:
    case True{}:
      ki_match_arm(e, ctx, t, dem, ty, a, check(kc(KEnv, U32.is_eq(cp(e), 0), u => e, u => ki_lhs(e, nm(t), tel, da(ctr), U32.add(bound, 1))), ctx, kid(t, 0), dem, mat_goal(cb(e), ty, tel, da(ctr), nm(t), Nil{})))
    case False{}:
      bad(cw(e), "fresh binder space exhausted")

@unsafe
def ki_match_bound(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +dem: U32, +ty: KTerm, +a: KTerm, +ctr: KDef, +tel: KTerm, +bound: U32) -> KChecking:
  w7_br_238(U32.is_eq(cp(e), 0) || U32.is_eq(da(ctr), 0) || (U32.is_lt(da(ctr), 4294967295) && U32.is_le(bound, U32.sub(4294967294, da(ctr)))), e, ctx, t, dem, ty, a, ctr, tel, bound)

# Module: src/check/env-telescope.bend:15
@unsafe
def w7_br_247(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  match w7_c:
    case True{}:
      env_tele_check_loop(e, ctx, tel, args, dem, Nil{}, 0)
    case False{}:
      tele_check_legacy(e, ctx, tel, args, dem)

@unsafe
def w7_br_248(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_247(env_tele_safe(tel), e, ctx, tel, args, dem)
    case False{}:
      tele_check_legacy(e, ctx, tel, args, dem)

@unsafe
def env_tele_check(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  w7_br_248(env_tele_many(args), e, ctx, tel, args, dem)

# Module: src/check/env-telescope.bend:109
@unsafe
def w7_br_249(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      tele_check_done(r, env_tele_check_loop(ke_world(e, rw(r)), ctx, kid(tel, 1), rest, dem, Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.add(count, 1)))
    case False{}:
      r

@unsafe
def env_tele_check_after(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32, +r: KChecking) -> KChecking:
  w7_br_249(good(r), e, ctx, tel, h, rest, dem, bindings, count, r)

# Module: src/check/env-telescope.bend:115
@unsafe
def env_tele_check_head(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32) -> KChecking:
  env_tele_check_after(e, ctx, tel, h, rest, dem, bindings, count, check(e, ctx, h, qdem(qt(tel), dem), env_tele_apply(kid(tel, 0), bindings)))

# Module: src/check/env-telescope.bend:119
@unsafe
def w7_br_250(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32) -> KChecking:
  match w7_c:
    case True{}:
      env_tele_check_head(e, ctx, tel, h, rest, dem, Nil{}, 0)
    case False{}:
      tele_check_legacy_head(e, ctx, tel, h, rest, dem)

@unsafe
def w7_br_251(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_250(env_tele_safe(tel), e, ctx, tel, h, rest, dem)
    case False{}:
      bad(cw(e), "too many telescope arguments")

@unsafe
def env_tele_check_open(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32) -> KChecking:
  w7_br_251(p98_tag_eq(tel, "All"), e, ctx, tel, h, rest, dem)

# Module: src/check/env-telescope.bend:127
@unsafe
def env_tele_check_loop(e, ctx, tel, args, dem, bindings, count):
  match args:
    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, env_tele_apply(tel, bindings), Nil{})
    case Con{h, rest}:
      kc(KChecking, env_tele_safe(h),
        u => kc(KChecking, p98_tag_eq(tel, "All") && U32.is_lt(count, 64),
          u => env_tele_check_head(e, ctx, tel, h, rest, dem, bindings, count),
          u => env_tele_check_open(e, ctx, wnf(cb(e), env_tele_apply(tel, bindings)), h, rest, dem)),
        u => tele_check_legacy(e, ctx, env_tele_apply(tel, bindings), args, dem))

# Module: src/check/env-substitution.bend:23
@unsafe
def w7_br_272(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      sp_live_args(ke_world(e, rw(r)), ctx, head, sp, d, sp_take(sp, dx(d)))
    case False{}:
      r

@unsafe
def sp_live_checked(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +r: KChecking) -> KChecking:
  w7_br_272(good(r), e, ctx, head, sp, d, r)

# Module: src/check/specialize.bend:349
@unsafe
def w7_br_273(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String) -> KChecking:
  match w7_c:
    case True{}:
      sp_live_error(e, ctx, head, "a comptime argument must stop growing", "a ~ argument that stops growing")
    case False{}:
      sp_live_memo(e, ctx, head, sp, d, xs, key, sp_find(kw_memo(cw(e)), dn(d), key))

@unsafe
def sp_live_key(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String) -> KChecking:
  w7_br_273(U32.is_gt(sp_len(key), 32768), e, ctx, head, sp, d, xs, key)

# Module: src/check/specialize.bend:353
@unsafe
def sp_live_error(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +message: String, +expected: String) -> KChecking:
  dg_trace(e, ctx, head, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dg_bad_detail(cw(e), message, dg_text(expected), head))

# Module: src/check/specialize.bend:357
@unsafe
def w7_br_274(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String) -> KChecking:
  match w7_c:
    case True{}:
      sp_live_error(e, ctx, head, "template instantiation exceeds 64 levels", "a template that stops instantiating itself (64 levels at most)")
    case False{}:
      sp_live_fresh(e, ctx, head, d, xs, key, dn(d) ++ "~" ++ U32.show(sp_ordinal(kw_memo(cw(e)), dn(d))), kw_mint_floor(cw(e), Con{cl(e), norm_join(ctx, sp)}), norm_max(norm_max_term(dt(d)), norm_max_term(dv(d))))

@unsafe
def w7_br_275(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +d: KDef, +memo: KSpecMemo) -> KChecking:
  match w7_c:
    case True{}:
      sp_live_error(e, ctx, head, "nondecreasing cross-instance template recursion", "a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)")
    case False{}:
      sp_live_ref(cw(e), head, sp_mname(memo), dx(d))

@unsafe
def w7_br_276(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String, +memo: KSpecMemo) -> KChecking:
  match w7_c:
    case True{}:
      w7_br_274(U32.is_ge(cd(e), 64), e, ctx, head, sp, d, xs, key)
    case False{}:
      w7_br_275(sp_active(memo) && Bool.not(p88_string_eq(sp_mname(memo), cn(e))), e, ctx, head, d, memo)

@unsafe
def sp_live_memo(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>, +key: String, +memo: KSpecMemo) -> KChecking:
  w7_br_276(p88_string_eq(sp_mname(memo), ""), e, ctx, head, sp, d, xs, key, memo)

# Module: src/check/specialize.bend:363
@unsafe
def w7_br_277(w7_c: Bool, +e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +d: KDef, +xs: List<&2,KTerm>, +key: String, +name: String, +bound: U32, +width: U32) -> KChecking:
  match w7_c:
    case True{}:
      sp_live_body(e, head, d, key, name, tele_fill(cb(e), sp_shift(dt(d), U32.add(bound, 1)), xs), sp_apply_template(sp_shift(dv(d), U32.add(bound, 1)), xs), U32.add(U32.add(bound, width), 2))
    case False{}:
      sp_live_error(e, ctx, head, "fresh binder space exhausted", "a representable fresh binder identity")

@unsafe
def sp_live_fresh(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +d: KDef, +xs: List<&2,KTerm>, +key: String, +name: String, +bound: U32, +width: U32) -> KChecking:
  w7_br_277(U32.is_lt(width, 4294967294) && U32.is_le(bound, U32.sub(4294967293, width)), e, ctx, head, d, xs, key, name, bound, width)

# Module: src/check/specialize.bend:373
@unsafe
def sp_live_body(+e: KEnv, +head: KTerm, +d: KDef, +key: String, +name: String, +ty: KTerm, +body: KTerm, +next: U32) -> KChecking:
  +inst: KDef = KDef{name, "Def", U32.sub(da(d), dx(d)), 0, ty, body, Nil{}, False{}, du(d)}
  +world: KWorld = KWorld{book_put(kw_bound_book(cb(e), U32.sub(next, 1)), declared(inst)), Con{KSpecMemo{dn(d), key, name, True{}}, kw_memo(cw(e))}, KFreshKnown{next}, kw_checked(cw(e))}
  sp_live_done(head, inst, dx(d), check_definition_body(world, inst, U32.add(cd(e), 1)))

# Module: src/check/specialize.bend:379
@unsafe
def sp_live_args(+e: KEnv, +ctx: List<&2,KTerm>, +head: KTerm, +sp: List<&2,KTerm>, +d: KDef, +xs: List<&2,KTerm>) -> KChecking:
  sp_live_key(e, ctx, head, sp, d, xs, sp_keys(xs))

# Module: src/check/prefix-state.bend:5
@unsafe
def base_prefix_put(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  book_put_many(book, defs)

# Module: src/check/prefix-state.bend:107
@unsafe
def base_prefix_seen(+prefix: List<&2,KDef>, +bound: U32) -> List<&2,KDef>:
  base_prefix_put(book_cached(Nil{}, bound), prefix)

# Only raw Ref/ADT names may query definitions while checking this closed seed.
# Synthetic comptime binders use the reserved ~ namespace checked on the suffix.

# Module: src/check/prefix-state.bend:113
@unsafe
def base_prefix_prepare_known(+prefix: List<&2,KDef>, +bound: U32, +result: DChecking, +world: KWorld, +next: U32) -> KBasePrefixState:
  +final = base_prefix_final(prefix)
  +checked = kw_checked(world)
  +stamp = base_prefix_stamp(kw_book(world), bound)
  +ordered = book_final_reverse(checked, Nil{})
  +patches = base_prefix_deltas(ordered, book_context(final))
  +seed = book_cached(Nil{}, bound)
  +replayed = kw_bound_book(base_prefix_put(check_declarations(prefix, seed), final), stamp)
  KBasePrefixState{bound, U32.sub(U32.sub(next, bound), 1), U32.sub(stamp, bound), patches,
    good(dg_checking_result(result)) && p88_string_eq(check_open(kw_book(world)), "") && U32.is_gt(next, bound) && U32.is_ge(stamp, bound) && U32.is_le(stamp, U32.sub(next, 1)) && base_prefix_native(prefix) && base_prefix_names(prefix) && base_prefix_closed(prefix, book_context(final)) && List.is_empty(&2, KSpecMemo, kw_memo(world)) && U32.is_le(norm_max_book(checked), bound) && U32.is_le(norm_max_book(base_prefix_world_raw(kw_book(world))), bound) && prefix_state_exact_defs(base_prefix_patch(final, book_context(patches)), ordered) && prefix_state_exact_defs(replayed, kw_book(world))}

# Module: src/check/prefix-state.bend:168
@unsafe
def base_prefix_prepare_fresh(+prefix: List<&2,KDef>, +bound: U32, +result: DChecking, +world: KWorld, +fresh: KWorldFresh) -> KBasePrefixState:
  match fresh:
    case KFreshKnown{next}: base_prefix_prepare_known(prefix, bound, result, world, next)
    case KFreshDeferred{roots}: KBasePrefixState{bound, 0, 0, Nil{}, False{}}

# Module: src/check/prefix-state.bend:188
@unsafe
def base_prefix_world_saved(+prefix: List<&2,KDef>, +state: KBasePrefixState, +final: List<&2,KDef>, +bound: U32, +world: KWorld) -> KBasePreparedWorld:
  KBasePreparedWorld{state, prefix, final, kw_book(world), kw_checked(world), base_prefix_seen(prefix, bound), driver_count_todos(final), norm_max_book(kw_checked(world))}

# Sequential declaration installation puts suffix headers first in the list,
# but prefix event publication historically puts Base definitions first. Keep
# that observable list order while retaining the already extended lookup index.
# Only list cells are copied; Base terms and index subtrees stay shared.

# Module: src/check/prefix-state.bend:291
@unsafe
def book_context_world(+book: List<&2,KDef>, +load: FPrefixLoad, +prepared: KBasePreparedWorld) -> List<&2,KDef>:
  match load:
    case FPrefixLoad{trace, prefix, suffix, ready}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{original, error, imports}:
              base_prefix_context_world(book, error, suffix, ready, prepared)

# Module: src/check/prefix-state.bend:424
@unsafe
def w7b_ka_stop_if(stop: Bool, +kw: KWorld, +d: KDef) -> KDef:
  match stop:
    case True{}: d
    case False{}: ka_def_with_kw(kw, d)

@unsafe
def agy_ka_defs_kw(+kw: KWorld, ds: List<&2, KDef>, +stops_set: KDef) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      +name = dn(d)
      +h = index_hash(name, 2166136261)
      Con{w7b_ka_stop_if(p88_string_eq(dk(index_find(stops_set, name, h, 32)), "P142JSeen"), kw, d), agy_ka_defs_kw(kw, rest, stops_set)}

@unsafe
def agy_ka_defs_indexed(+book: List<&2, KDef>, ds: List<&2, KDef>, +stops_set: KDef) -> List<&2, KDef>:
  agy_ka_defs_kw(kw_initial(book), ds, stops_set)

@unsafe
def annotate_selected(book, selected, stops):
  agy_ka_defs_indexed(book_context(book), selected, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:148
@unsafe
def ka_defs_except(book, ds, stops):
  agy_ka_defs_indexed(book, ds, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:164
@unsafe
def ka_def(book, d):
  ka_def_with_kw(kw_initial(book), d)

# Module: src/check/annotate.bend:168
@unsafe
def f_context_pattern(+pattern: KTerm, +input: FInput, +cursor: U32) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +syntax = f_context_syntax(pattern)
          f_choose(FParsed, p98_tag_eq(syntax, "Var"),
            u => f_context_pattern_named(syntax, input, cursor, f_context_resolve_table(k_with_span(syntax, cursor, cursor), scope, True{})),
            u => f_choose(FParsed, core_literal(pattern), u => f_context_pattern(core_literal_step(pattern), input, cursor), u => f_choose(FParsed, p98_tag_eq(pattern, "Ctr"), u => f_context_pattern_ctor(pattern, input, cursor, scope), u => f_context_pattern_computed(pattern, input, cursor, f_context_higher(pattern)))))

# Module: src/front/contextual.bend:101
@unsafe
def f_context_pattern_ctor(+term: KTerm, +input: FInput, +cursor: U32, +scope: FParseScope) -> FParsed:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      f_context_ctor_checked(term, input, cursor, f_valid_ctor_head(term, f_ctor_index_find(nm(term), ctorIndex)))

# Module: src/front/contextual.bend:183

@unsafe
def f_context_patterns(+owner: KTerm, +patterns: List<&2,KTerm>, +input: FInput, +cursor: U32, +acc: List<&2,KTerm>) -> FParsed:
  match patterns:
    case Nil{}: FParsed{k_with_children(owner, List.reverse(&2, KTerm, acc)), input}
    case Con{pattern, rest}: f_context_patterns_next(owner, rest, cursor, acc, f_context_pattern(pattern, input, cursor))

# Module: src/front/contextual.bend:189
@unsafe
def f_context_patterns_next(+owner: KTerm, +patterns: List<&2,KTerm>, +cursor: U32, +acc: List<&2,KTerm>, +parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, rest}: f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_patterns(owner, patterns, rest, cursor, Con{term, acc}))

# Module: src/front/contextual.bend:194
@unsafe
def f_context_ctor_checked(+term: KTerm, +input: FInput, +cursor: U32, +error: Maybe<&2,KTerm>) -> FParsed:
  match error:
    case Some{error}: f_context_error_at(error, input, cursor)
    case None{}: f_context_patterns(term, ks(term), input, cursor, Nil{})

# Module: src/front/contextual.bend:236
@unsafe
def f_context_definition_done(+p: FParsed) -> FParsed:
  match p:
    case FParsed{term, rest}:
      match rest:
        case FInput{tokens, context}:
          +checked = f_context_materialize(term)
          FParsed{checked, rest}

# Header entry resets the declaration-local fresh counter, as parse_book does.

# Module: src/front/contextual.bend:304
@unsafe
def w7_br_310(w7_c: Bool, +term: KTerm, +input: FInput, +cursor: U32) -> FParsed:
  match w7_c:
    case True{}:
      f_context_pattern(term, input, cursor)
    case False{}:
      f_context_error_at(fpe_message_at(term, "a name (a parallel or typed let binds names; destructure in its body)", "a name (a parallel or typed let binds names; destructure in its body)"), input, cursor)

@unsafe
def f_context_result(+result: FResult) -> FResult:
  match result:
    case FResult{book, error, imports}: FResult{f_context_defs(book, String.is_empty(error)), error, imports}

# Module: src/front/contextual.bend:468
@unsafe
def f_context_defs(+defs: List<&2,KDef>, +complete: Bool) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{KDef{dn(d), dk(d), da(d), dx(d), f_choose(KTerm, f_eq(tg(dt(d)), "ImportLaw"), u => dt(d), u => f_choose(KTerm, complete, u => f_context_lower(dt(d)), u => dt(d))), dv(d), f_context_defs(dc(d), complete), db(d), du(d)}, f_context_defs(rest, complete)}

# Module: src/front/contextual.bend:474
@unsafe
def f_context_signature(+term: KTerm, +input: FInput) -> KTerm:
  f_context_higher(term)

# Module: src/front/parser.bend:140
@unsafe
def w7_br_339(w7_c: Bool, +a: KTerm, +op: String, +b: KTerm, +opBegin: U32, +opEnd: U32, +begin: U32, +end: U32, +input: FInput) -> KTerm:
  match w7_c:
    case True{}:
      kt_span("Min", "", 0, 1, [a, b], begin, end)
    case False{}:
      f_app_span(kt_span("Ref", f_choose(String, Char.is_eq(f_head(f_operator(op)), '.'), u => f_operator(op), u => f_context_own(f_operator(op), input, False{})), 0, 1, Nil{}, f_choose(U32, f_eq(op, "&") || f_eq(op, "|"), u => begin, u => opBegin), f_choose(U32, f_eq(op, "&") || f_eq(op, "|"), u => end, u => opEnd)), [a, b], begin, end)

@unsafe
def w7_br_340(w7_c: Bool, +a: KTerm, +op: String, +b: KTerm, +opBegin: U32, +opEnd: U32, +begin: U32, +end: U32, +input: FInput) -> KTerm:
  match w7_c:
    case True{}:
      kt_span("Ctr", f_context_own("Con", input, True{}), 0, 1, [a, b], begin, end)
    case False{}:
      w7_br_339(f_eq(op, "<&>"), a, op, b, opBegin, opEnd, begin, end, input)

@unsafe
def w7_br_341(w7_c: Bool, +a: KTerm, +op: String, +b: KTerm, +opBegin: U32, +opEnd: U32, +begin: U32, +end: U32, +input: FInput) -> KTerm:
  match w7_c:
    case True{}:
      kt_span("All", "_", ix(a), 1, [a, b], begin, end)
    case False{}:
      w7_br_340(f_eq(op, "<>"), a, op, b, opBegin, opEnd, begin, end, input)

@unsafe
def w7_br_342(w7_c: Bool, +a: KTerm, +op: String, +b: KTerm, +opBegin: U32, +opEnd: U32, +begin: U32, +end: U32, +input: FInput) -> KTerm:
  match w7_c:
    case True{}:
      f_lambda_valid(a, b, opEnd)
    case False{}:
      w7_br_341(f_eq(op, "->"), a, op, b, opBegin, opEnd, begin, end, input)

@unsafe
def f_binary_plain(a, op, b, opBegin, opEnd, begin, end, input):
  w7_br_342(f_eq(op, "=>"), a, op, b, opBegin, opEnd, begin, end, input)

# Module: src/front/parser.bend:449
@unsafe
def w7_br_370(w7_c: Bool, +source: String, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      w7_br_369(p98_tag_eq(error, "Error") && p98_tag_eq(kid(error, 0), "ParseExpected") && p98_tag_eq(kid(error, 1), "ParseToken"), source, error)

@unsafe
def fpe_render(source, error):
  w7_br_370(p98_tag_eq(error, "Absent"), source, error)

# Module: src/front/parser.bend:569
@unsafe
def w7_br_385(w7_c: Bool, +source: String, +start: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_point_message(source, U32.sub(kb(error), start), U32.sub(ke(error), start), error, f_choose(String, f_eq(tg(kid(error, 1)), "ParseObservedPoint"), u => fpe_point_observed(source, U32.sub(kb(error), start)), u => nm(kid(error, 1))))
    case False{}:
      fpe_render(source, error)

@unsafe
def w7_br_386(w7_c: Bool, +source: String, +start: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      "Error:\n- message : " ++ nm(kid(error, 0)) ++ "\nLocation:" ++ fpe_snippet(source, U32.sub(kb(error), start), U32.sub(ke(error), start), error) ++ f_choose(String, f_eq(tg(kid(error, 1)), "ParseNote"), u => "\nNote: " ++ nm(kid(error, 1)), u => "")
    case False{}:
      w7_br_385(f_eq(tg(kid(error, 0)), "ParseExpected") && (f_eq(tg(kid(error, 1)), "ParseObserved") || f_eq(tg(kid(error, 1)), "ParseObservedPoint")), source, start, error)

@unsafe
def w7_br_387(w7_c: Bool, +source: String, +start: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      w7_br_386(f_eq(tg(kid(error, 0)), "ParseMessage"), source, start, error)
    case False{}:
      fpe_render(source, error)

@unsafe
def f_context_materialize(+term: KTerm) -> KTerm:
  f_context_lower(f_context_higher(term))

# Module: src/front/literals_arrays.bend:234
@unsafe
def w7_mat_done_app(isLam: Bool, +term: KTerm) -> KTerm:
  match isLam:
    case True{}:
      f_context_higher(f_scope_app_span(kid(term, 0), kid(term, 1), kb(term), ke(term)))
    case False{}:
      term

@unsafe
def w7_mat_done_chk(isApp: Bool, +term: KTerm) -> KTerm:
  match isApp:
    case True{}:
      w7_mat_done_app(f_eq(tg(kid(term, 0)), "Lam"), term)
    case False{}:
      term

@unsafe
def w7_mat_child_eval(lower: Bool, deferred: Bool, +head: KTerm) -> KTerm:
  match lower:
    case True{}:
      match deferred:
        case True{}:
          f_context_lower(f_context_higher(head))
        case False{}:
          f_context_lower(head)
    case False{}:
      f_context_higher(head)

@unsafe
def w7_mat_child_step(skipDef: Bool, +term: KTerm, +head: KTerm, +rest: List<&2, KTerm>, +built: List<&2, KTerm>, +lower: Bool, +deferred: Bool) -> KTerm:
  match skipDef:
    case True{}:
      f_context_material_children(term, rest, Con{head, built}, lower)
    case False{}:
      f_context_material_next(term, rest, built, lower, w7_mat_child_eval(lower, deferred, head))

@unsafe
def w7_mat_nil(+term: KTerm, +built: List<&2, KTerm>, lower: Bool) -> KTerm:
  match built:
    case Nil{}:
      f_context_material_done(term, lower)
    case Con{_, _}:
      f_context_material_done(k_with_children(term, List.reverse(&2, KTerm, built)), lower)

@unsafe
def w7_mat_hi_kids(+term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Nil{}:
      term
    case Con{_, _}:
      f_context_material_children(term, kids, Nil{}, False{})

@unsafe
def w7_mat_hi_op(isOp: Bool, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match isOp:
    case True{}:
      f_operator_error(term)
    case False{}:
      w7_mat_hi_kids(term, kids)

@unsafe
def w7_mat_hi_stop(isStop: Bool, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match isStop:
    case True{}:
      term
    case False{}:
      w7_mat_hi_kids(term, kids)

@unsafe
def w7_mat_hi_fname(isFn: Bool, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match isFn:
    case True{}:
      f_context_higher(k_with_span(kid(term, 1), kb(term), ke(term)))
    case False{}:
      w7_mat_hi_kids(term, kids)

@unsafe
def w7_mat_hi_tag(c0: U32, +tag: String, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match c0:
    case 69:
      w7_mat_hi_stop(f_context_stop(term), term, kids)
    case 70:
      w7_mat_hi_fname(f_eq(tag, "FName"), term, kids)
    case 82:
      w7_mat_hi_op(f_eq(tag, "Ref") && f_implicit_operator(nm(term)), term, kids)
    case _:
      w7_mat_hi_kids(term, kids)

@unsafe
def f_context_higher(+term: KTerm) -> KTerm:
  match term:
    case KLiteral{_, _, _, _, _}:
      term
    case KLambda{_, _, _, kids, _, _, _, _}:
      match kids:
        case Nil{}: term
        case Con{_, _}: f_context_material_children(term, kids, Nil{}, False{})
    case KTerm{tag, _, _, _, kids, _, _, _}:
      w7_mat_hi_tag(w7_char0(tag), tag, term, kids)

@unsafe
def w7c_lower_2_a(stop: Bool, +tag: String, +name: String, +id: U32, +quant: U32, +r0: KTerm, +k1: KTerm, +rem: List<&2,String>, +b: U32, +e: U32) -> KTerm:
  match stop:
    case True{}: r0
    case False{}:
      +r1 = f_context_lower(k1)
      w7c_lower_2_b(f_context_stop(r1), tag, name, id, quant, r0, r1, rem, b, e)

@unsafe
def f_context_lower(+term: KTerm) -> KTerm:
  match term:
    case KLiteral{_, _, _, _, _}:
      term
    case KLambda{name, id, quant, kids, rem, b, e, pres}:
      match kids:
        case Nil{}: term
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              +h0 = f_context_lower(k0)
              w7c_lower_1_lam(f_context_stop(h0), name, id, quant, h0, rem, b, e, pres)
            case Con{_, _}:
              f_context_material_children(term, kids, Nil{}, True{})
    case KTerm{tag, name, id, quant, kids, rem, b, e}:
      match kids:
        case Nil{}: term
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              +h0 = f_context_lower(k0)
              w7c_lower_1_term(f_context_stop(h0), tag, name, id, quant, h0, rem, b, e)
            case Con{k1, r1}:
              match r1:
                case Nil{}:
                  +h0 = f_context_lower(k0)
                  w7c_lower_2_a(f_context_stop(h0), tag, name, id, quant, h0, k1, rem, b, e)
                case Con{_, _}:
                  f_context_material_children(term, kids, Nil{}, True{})

@unsafe
def f_context_material_children(+term: KTerm, +children: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool) -> KTerm:
  match children:
    case Nil{}: w7_mat_nil(term, built, lower)
    case Con{head, rest}:
      +deferred = f_context_material_deferred(term, rest, built)
      w7_mat_child_step(Bool.not(lower) && deferred, term, head, rest, built, lower, deferred)

@unsafe
def w7_br_483(w7_c: Bool, +term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool, +head: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      head
    case False{}:
      f_context_material_children(term, rest, Con{head, built}, lower)

@unsafe
def f_context_material_next(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool, +head: KTerm) -> KTerm:
  w7_br_483(f_context_stop(head), term, rest, built, lower, head)

@unsafe
def f_context_material_done(+term: KTerm, +lower: Bool) -> KTerm:
  match lower:
    case True{}: term
    case False{}: w7_mat_done_chk(f_eq(tg(term), "App"), term)

# Module: src/front/parallel.bend:50
@unsafe
def f_operator_display(name, ops):
  match ops:
    case Nil{}:
      name
    case Con{+op, rest}:
      f_choose(String, f_eq(f_operator(op), name), u => f_choose(String, f_eq(op, ">op"), u => ">", u => f_choose(String, f_eq(op, ">>op"), u => ">>", u => op)), u => f_operator_display(name, rest))

# Do headers need the same chronological datatype quantities as written types.
# Keep their raw arguments until this pass, before choosing pure/bind/Ann.

# Module: src/front/families.bend:96
@unsafe
def f_operator_error(+t: KTerm) -> KTerm:
  +message = "a type for this operator (write (a " ++ f_operator_display(nm(t), ["+", "-", "*", "/", "%", "<", ">op", "<=", ">=", "<<", ">>op", ".&.", ".|.", ".^."]) ++ " b : Nat))"
  fpe_message_note_at(t, message, message, "we broke this after launch, sorry. Until 2.0.16 a bare operator meant Nat.\nThat was a bug: operators demand annotation. Wrap the expression and it'll work again.")

# Only failed calls revisit arguments to retain the first bad marker.

# Module: src/front/validate.bend:25
@unsafe
def w7_br_545(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      r
    case False{}:
      w7_br_544(p98_tag_eq(ct(r), "DTrace"), e, ctx, t, ty, r)

@unsafe
def dg_trace(e, ctx, t, ty, r):
  w7_br_545(good(r), e, ctx, t, ty, r)

# Module: src/diagnostic/trace.bend:78
@unsafe
def w7_br_556(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      dg_trace(e, ctx, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, kr_from(r, dg_bad_detail(rw(r), ce(r), dg_text("a template applied to closed ~ arguments (" ++ nm(kid(ct(r), 1)) ++ " is a variable here, not comptime: pass it at run time)"), t)))
    case False{}:
      r

@unsafe
def dg_template_result(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +r: KChecking) -> KChecking:
  w7_br_556(p88_string_eq(ce(r), "unbound variable") && p98_tag_eq(ct(r), "DTrace") && p98_tag_eq(kid(ct(r), 1), "Var") && Bool.not(p98_tag_eq(ctx_get(ctx, ix(kid(ct(r), 1))), "Absent")), e, ctx, t, r)

# Module: src/diagnostic/trace.bend:121
@unsafe
def dg_kind_check(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +q: U32, +name: String) -> KChecking:
  dg_kind_at(e, ctx, t, q, name, t)

# Module: src/diagnostic/trace.bend:125
@unsafe
def dg_kind_at(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +q: U32, +name: String, +site: KTerm) -> KChecking:
  +kind = typ(kindq(e, q))
  dg_kind_result(t, q, name, site, kind, check(e, ctx, t, 0, kind))

# Module: src/diagnostic/trace.bend:130
@unsafe
def w7_br_573(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm) -> Bool:
  match w7_c:
    case True{}:
      j_io_spine(wnf(j_io_shadow(book), ty), 0)
    case False{}:
      False{}

@unsafe
def j_io_type(book, ty):
  w7_br_573(p88_string_eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), book, ty)

# Module: src/back/common/queries.bend:176
@unsafe
def w7_br_597(w7_c: Bool, +book: List<&2, KDef>) -> String:
  match w7_c:
    case True{}:
      "a build needs import Base"
    case False{}:
      j_main_error(book, lookup(book, "main"))

@unsafe
def w7_br_601(w7_c: Bool, +book: List<&2, KDef>, +main: KDef) -> String:
  match w7_c:
    case True{}:
      "no main to run"
    case False{}:
      w7_br_600(j_io_type(book, dt(main)), book, main)

@unsafe
def j_main_error(book, main):
  w7_br_601(Bool.not(p88_string_eq(dk(main), "Def")) || p98_tag_eq(j_strip(dv(main)), "Absent"), book, main)

# Printability is a graph predicate. Thread successful visits across fields and
# constructor siblings so a shared child type is checked once per request.
# Insert each ADT before descending, retaining the original recursive-type rule.

# Module: src/back/js/validate.bend:31
@unsafe
def jl_checked_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> String:
  p142j_checked_error(book,defs,roots,stops)

# Module: src/back/js/validate.bend:367
@unsafe
def j_fusion_owner(+book: List<&2,KDef>, +ty: KTerm, +empty: String, +link: String) -> Bool:
  +h = wnf(book, ty)
  +d = lookup(book, nm(h))
  +c = lookup(dc(d), link)
  +z = lookup(dc(d), empty)
  +tel = wnf(book, j_specialize(book, dt(c), ks(h)))
  +tail = wnf(book, kid(tel, 1))
  p98_tag_eq(h, "ADT") && (j_fold_type(book, h) || j_list_ground_type(book, h)) &&
    U32.is_eq(j_region_def_count(dc(d)), 2) && Bool.not(p88_string_eq(empty, link)) &&
    p88_string_eq(dk(z), "Ctr") && U32.is_eq(da(z), 0) &&
    p88_string_eq(dk(c), "Ctr") && U32.is_eq(da(c), 2) &&
    p98_tag_eq(tel, "All") && Bool.not(U32.is_eq(qt(tel), 0)) && j_primitive_type(book, wnf(book, kid(tel, 0)), "U32") &&
    p98_tag_eq(tail, "All") && Bool.not(U32.is_eq(qt(tail), 0)) && j_region_same_type(book, kid(tail, 0), h) &&
    j_region_same_type(book, kid(tail, 1), h)

# Module: src/back/js/region.bend:922
@unsafe
def j_callback_factory(+book: List<&2,KDef>, +d: KDef) -> Bool:
  w7_br_624(j_fusion_def(d, 1) && p98_tag_eq(j_strip(dv(d)), "Mat"), book, d)

# Original checked source book and annotated emitter defs have distinct Lam
# metadata. The formal All telescope owns erasure (as j_lambda_bind does).
# This route admits only the original source Lam q1 spelling and proves its
# erased binder never occurs in runtime syntax; Ann type children are ignored.

# Module: src/back/js/region.bend:1253
@unsafe
def j_fold_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  +owner = lookup(book, nm(head))
  p98_tag_eq(head, "ADT") && U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)) &&
    p88_string_eq(dk(owner), "ADT") && Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_ge(j_region_def_count(dc(owner)), 2) && U32.is_le(j_region_def_count(dc(owner)), 8) &&
    j_pure_type(book, head) && j_fold_ctors(book, nm(head), dc(owner))

# Module: src/back/js/fold.bend:13
@unsafe
def nr_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  p144o_prepare_annotated(book,annotated)

@unsafe
def no_atom(+t: KTerm, +env: List<&2, NC_Binding>) -> String:
  w7_br_744(p98_tag_eq(t, "Var"), t, env)

# Module: src/back/native/observer-emitter.bend:15
@unsafe
def no_atoms_valid(ts: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: Bool.not(p88_string_eq(no_atom(h, env), "NATIVE_UNBOUND_VARIABLE")) && no_atoms_valid(rest, env)

# Module: src/back/native/observer-emitter.bend:26
@unsafe
def no_words(ts: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{no_atom(h, env), no_words(rest, env)}

# Module: src/back/native/observer-emitter.bend:32
@unsafe
def w7_br_745(w7_c: Bool, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  match w7_c:
    case True{}:
      NC_Code{nct_leaf("if (!seq && err_seen(e.mem)) { return 0; }\nnf_out[0] = " ++ no_atom(kid(t, 0), env) ++ ";\nreturn 1;\n"), Nil{}, n, "", Nil{}}
    case False{}:
      nc_fail("observer: invalid immediate return", n)

@unsafe
def no_emit_return(+t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  w7_br_745(U32.is_eq(terms_len(ks(t)), 1) && no_atoms_valid(ks(t), env), t, env, n)

# Module: src/back/native/observer-emitter.bend:82
@unsafe
def no_emit_loop(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  +words = no_words(ks(t), env)
  nt_choose(NC_Code, U32.is_eq(terms_len(ks(t)), nt_count(NC_Binding, params)) && no_atoms_valid(ks(t), env),
    u => NC_Code{nct_leaf("{\n" ++ nf_self_temps(words, 0) ++ nf_self_moves(params, words, 0) ++ "goto nf_again;\n}\n"), Nil{}, n, "", Nil{}},
    u => nc_fail("observer: invalid self-tail transition", n))

# Module: src/back/native/observer-emitter.bend:89
@unsafe
def w7_br_746(w7_c: Bool, +value: KTerm, +env: List<&2, NC_Binding>) -> String:
  match w7_c:
    case True{}:
      nd_scalar_word(nm(value), no_words(ks(value), env))
    case False{}:
      no_atom(value, env)

@unsafe
def no_scalar_value(+value: KTerm, +env: List<&2, NC_Binding>) -> String:
  w7_br_746(p98_tag_eq(value, "NOp") && nd_scalar_known(nm(value)) && U32.is_eq(terms_len(ks(value)), nc_primitive_arity(nm(value))) && no_atoms_valid(ks(value), env), value, env)

# Module: src/back/native/observer-emitter.bend:94
@unsafe
def no_emit_let(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  +word = no_scalar_value(kid(t, 0), env)
  nt_choose(NC_Code, U32.is_eq(terms_len(ks(t)), 2) && p88_string_eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE") && Bool.not(p88_string_eq(word, "NATIVE_UNBOUND_VARIABLE")),
    u => nc_prepend("Term v_" ++ U32.show(ix(t)) ++ " = " ++ word ++ ";\nif (!seq && err_seen(e.mem)) { return 0; }\n", no_emit(kid(t, 1), Con{nc_binding(ix(t)), env}, params, layouts, n)),
    u => nc_fail("observer: invalid scalar let or unsupported call", n))

# Module: src/back/native/observer-emitter.bend:101
@unsafe
def no_emit_match_layout(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32, layout: NO_Layout) -> NC_Code:
  match layout:
    case NO_Layout{key, +ctor, +storage, +width}:
      +fields = ks(kid(t, 1))
      +word = no_atom(kid(t, 0), env)
      +loc = "no_loc_" ++ U32.show(n)
      +hit = no_emit(kid(t, 2), no_bind_fields(fields, env), params, layouts, U32.inc(n))
      +miss = no_emit(kid(t, 3), env, params, layouts, nc_fresh(hit))
      +reads = nt_choose(String, p88_string_eq(storage, "Boxed"), u => "Loc " ++ loc ++ " = term_peek(e, " ++ word ++ ");\n", u => "") ++ no_field_decls(fields, storage, word, loc, 0)
      NC_Code{nct_cat(nct_leaf("if (" ++ nc_condition(ctor, word) ++ ") {\n" ++ reads), nct_cat(nc_text(hit), nct_cat(nct_leaf("} else {\n"), nct_cat(nc_text(miss), nct_leaf("}\n"))))), Nil{}, nc_fresh(miss), nc_first_error(hit, miss), List.append(&2, String, nc_calls(hit), nc_calls(miss))}

# Module: src/back/native/observer-emitter.bend:113
@unsafe
def no_emit_match_found(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32, found: Maybe<&2, NO_Layout>) -> NC_Code:
  match found:
    case None{}: nc_fail("observer: absent read descriptor", n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key, ctor, storage, width}:
          nt_choose(NC_Code, no_layout_valid(layout) && U32.is_eq(terms_len(ks(t)), 4) && p98_tag_eq(kid(t, 0), "Var") && Bool.not(p88_string_eq(no_atom(kid(t, 0), env), "NATIVE_UNBOUND_VARIABLE")) && p98_tag_eq(kid(t, 1), "NO_Fields") && U32.is_eq(terms_len(ks(kid(t, 1))), width) && no_binders_valid(ks(kid(t, 1)), env),
            u => no_emit_match_layout(t, env, params, layouts, n, layout), u => nc_fail("observer: invalid borrowed match", n))

# Module: src/back/native/observer-emitter.bend:123
@unsafe
def w7_br_748(w7_c: Bool, +t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  match w7_c:
    case True{}:
      no_emit_match_found(t, env, params, layouts, n, no_layout(nm(t), layouts))
    case False{}:
      w7_br_747(p98_tag_eq(t, "NO_Error") && p88_string_eq(nm(t), "ERR_FIDS") && List.is_empty(&2, KTerm, ks(t)), n)

@unsafe
def w7_br_749(w7_c: Bool, +t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  match w7_c:
    case True{}:
      no_emit_let(t, env, params, layouts, n)
    case False{}:
      w7_br_748(p98_tag_eq(t, "NO_Match"), t, env, params, layouts, n)

@unsafe
def w7_br_750(w7_c: Bool, +t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  match w7_c:
    case True{}:
      no_emit_loop(t, env, params, n)
    case False{}:
      w7_br_749(p98_tag_eq(t, "NO_Let"), t, env, params, layouts, n)

@unsafe
def w7_br_751(w7_c: Bool, +t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  match w7_c:
    case True{}:
      no_emit_return(t, env, n)
    case False{}:
      w7_br_750(p98_tag_eq(t, "NO_Loop"), t, env, params, layouts, n)

@unsafe
def no_emit(t, env, params, layouts, n):
  w7_br_751(p98_tag_eq(t, "NO_Return"), t, env, params, layouts, n)

# Module: src/back/native/observer-adapter.bend:14
@unsafe
def w7_br_757(w7_c: Bool, +book: List<&2, KDef>, +d: KDef, +firstFresh: U32) -> NO_Schema:
  match w7_c:
    case True{}:
      nol_params(book, dt(d), Nil{}, Nil{}, Nil{}, Nil{}, firstFresh, 32, nd_arity(book, dn(d)))
    case False{}:
      nol_failure("unsupported observer definition", firstFresh)

@unsafe
def no_schema(+book: List<&2, KDef>, +d: KDef, +firstFresh: U32) -> NO_Schema:
  w7_br_757(p88_string_eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book, dn(d)), 4) && U32.is_lt(firstFresh, 2147483600), book, d, firstFresh)

# Module: src/back/native/observer-layout.bend:143
@unsafe
def w7_br_758(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  match w7_c:
    case True{}:
      nol_failure("parameter telescope budget", fresh)
    case False{}:
      nol_param_head(book, nq_layout_type(book, ty), params, roots, specs, seen, fresh, U32.sub(fuel, 1), arity)

@unsafe
def nol_params(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  w7_br_758(U32.is_eq(fuel, 0), book, ty, params, roots, specs, seen, fresh, fuel, arity)

# Module: src/back/native/observer-layout.bend:148
@unsafe
def w7_br_759(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  match w7_c:
    case True{}:
      nol_params(book, kid(head, 1), params, roots, specs, Con{ix(head), seen}, fresh, fuel, arity)
    case False{}:
      nol_param_type(book, head, nq_layout_type(book, kid(head, 0)), params, roots, specs, seen, fresh, fuel, arity)

@unsafe
def w7_br_760(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  match w7_c:
    case True{}:
      w7_br_759(U32.is_eq(qt(head), 0), book, head, params, roots, specs, seen, fresh, fuel, arity)
    case False{}:
      nol_result(book, head, List.reverse(&2, KTerm, params), List.reverse(&2, U32, roots), specs, seen, fresh, arity)

@unsafe
def nol_param_head(+book: List<&2, KDef>, +head: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  w7_br_760(p98_tag_eq(head, "All"), book, head, params, roots, specs, seen, fresh, fuel, arity)

# Module: src/back/native/observer-layout.bend:156
@unsafe
def nol_param_type(+book: List<&2, KDef>, +head: KTerm, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +rootSpecs = nol_root_specs(book, ty)
  +isRoot = Bool.not(List.is_empty(&2, NO_Spec, rootSpecs))
  nt_choose(NO_Schema, Bool.not(nq_layout_dep(ty, seen)) && (isRoot || nol_scalar(book, ty)) && U32.is_lt(terms_len(params), arity),
    u => nol_params(book, kid(head, 1), Con{var(nm(ty), nc_id(fresh)), params}, nt_choose(List<&2, U32>, isRoot, v => Con{terms_len(params), roots}, v => roots), List.append(&2, NO_Spec, rootSpecs, specs), Con{ix(head), seen}, U32.inc(fresh), fuel, arity),
    u => nol_failure("unsupported or dependent parameter", fresh))

# Module: src/back/native/observer-layout.bend:164
@unsafe
def w7_br_761(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +fresh: U32) -> NO_Schema:
  match w7_c:
    case True{}:
      nol_finish(book, params, roots, specs, fresh, nol_wrap(book, ty, params, roots, 0, "", nc_id(fresh)))
    case False{}:
      nol_failure("observer requires one or two nondependent roots", fresh)

@unsafe
def nol_result(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +seen: List<&2, U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  w7_br_761(U32.is_eq(terms_len(params), arity) && U32.is_ge(nt_count(U32, roots), 1) && U32.is_le(nt_count(U32, roots), 2) && Bool.not(nq_layout_dep(ty, seen)), book, ty, params, roots, specs, fresh)

# Module: src/back/native/observer-layout.bend:170
@unsafe
def noa_continue(+ctx: NO_Context, k: NO_Cont, +input: NO_Input) -> NO_Analysis:
  match k:
    case NO_KFinish{}: noa_finish(ctx, input)
    case NO_KEvalArgs{terms, env, stack, acc, next}: noa_eval_args(ctx, terms, env, noa_if(input), stack, Con{noa_iv(input), acc}, noa_in(input), noa_iu(input), next)
    case NO_KApplyArgs{args, next}: noa_apply_args(ctx, noa_iv(input), args, noa_if(input), noa_in(input), noa_iu(input), next)
    case NO_KAppFunction{arg, env, stack, next}: noa_eval(ctx, arg, env, noa_if(input), stack, noa_in(input), noa_iu(input), NO_KAppArgument{noa_iv(input), next})
    case NO_KAppArgument{fn, next}: noa_apply(ctx, fn, noa_iv(input), noa_if(input), noa_in(input), noa_iu(input), next)
    case NO_KConstructor{name, next}: noa_constructor(ctx, name, input, next)
    case NO_KLetBody{body, id, env, stack, next}: noa_eval(ctx, body, noa_bind(id, noa_iv(input), env), noa_if(input), stack, noa_in(input), noa_iu(input), next)
    case NO_KApplyOne{arg, next}: noa_apply(ctx, noa_iv(input), arg, noa_if(input), noa_in(input), noa_iu(input), next)

# Module: src/back/native/observer-analysis.bend:40
@unsafe
def noa_eval_args(+ctx: NO_Context, ts: List<&2, KTerm>, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +acc: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match ts:
    case Nil{}: noa_continue(ctx, k, NO_Input{kt("OArgs", "", 0, 0, nt_reverse(KTerm, acc, Nil{})), facts, n, fuel})
    case Con{+h, +rest}: noa_eval(ctx, h, env, facts, stack, n, fuel, NO_KEvalArgs{rest, env, stack, acc, k})

# Module: src/back/native/observer-analysis.bend:195
@unsafe
def noa_apply_args(+ctx: NO_Context, +fn: KTerm, args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match args:
    case Nil{}: noa_continue(ctx, k, NO_Input{fn, facts, n, fuel})
    case Con{+arg, +rest}: noa_apply(ctx, fn, arg, facts, n, fuel, NO_KApplyArgs{rest, k})

# Module: src/back/native/observer-analysis.bend:201
@unsafe
def w7_br_765(w7_c: Bool, +ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match w7_c:
    case True{}:
      noa_fail("observer: candidate budget or fresh range", n, fuel)
    case False{}:
      noa_eval_step(ctx, t, env, facts, stack, n, U32.sub(fuel, 1), k)

@unsafe
def noa_eval(ctx, t, env, facts, stack, n, fuel, k):
  w7_br_765(U32.is_eq(fuel, 0) || U32.is_ge(n, 294967200), ctx, t, env, facts, stack, n, fuel, k)

# Module: src/back/native/observer-analysis.bend:205
@unsafe
def noa_eval_step(+ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +tag = tg(t)
  nt_choose(NO_Analysis, p88_string_eq(tag, "Var"), u => nt_choose(NO_Analysis, p98_tag_eq(noa_env(ix(t), env), "Absent"), v => noa_fail("observer: unbound source variable", n, fuel), v => noa_continue(ctx, k, NO_Input{noa_env(ix(t), env), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, core_literal(t), u => noa_literal(ctx, t, env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Lam") || p88_string_eq(tag, "Mat"), u => noa_continue(ctx, k, NO_Input{kt(nt_choose(String, p88_string_eq(tag, "Lam"), v => "OL", v => "OM"), "", 0, 0, [t, kt("OEnv", "", 0, 0, env), kt("OStack", "", 0, 0, noa_names(stack))]), facts, n, fuel}), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Ref"), u => nt_choose(NO_Analysis, U32.is_eq(qt(t), 3) || U32.is_eq(nd_arity(noa_book(ctx), nm(t)), 0), v => noa_fail("observer: bang or demanded zero-arity reference", n, fuel), v => noa_continue(ctx, k, NO_Input{kt("OR", nm(t), 0, 0, [kt("OStack", "", 0, 0, noa_names(stack))]), facts, n, fuel})), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "App"), u => noa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, NO_KAppFunction{kid(t, 1), env, stack, k}), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Ctr"), u => nt_choose(NO_Analysis, no_literal_demanding_ctor(nm(t)), v => noa_fail("observer: demanding scalar constructor", n, fuel), v => noa_eval_args(ctx, ks(t), env, facts, stack, Nil{}, n, fuel, NO_KConstructor{nm(t), k})), u =>
  nt_choose(NO_Analysis, nb_contains(["Ann", "Loc", "Src", "Cut", "Slf", "Ins"], tag), u => noa_eval(ctx, kid(t, 0), env, facts, stack, n, fuel, k), u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Efq"), u => NO_Analysis{kt("NO_Error", "ERR_FIDS", 0, 0, Nil{}), n, fuel, ""}, u =>
  nt_choose(NO_Analysis, p88_string_eq(tag, "Let") && U32.is_eq(terms_len(ks(t)), 2) && p98_tag_eq(kid(t, 0), "Bind"), u => noa_eval(ctx, kid(kid(t, 0), 0), env, facts, stack, n, fuel, NO_KLetBody{kid(t, 1), ix(kid(t, 0)), env, stack, k}), u => noa_fail("observer: unsupported evaluated core " ++ tag, n, fuel))))))))))

# Module: src/back/native/observer-analysis.bend:218
@unsafe
def noa_primitive(+ctx: NO_Context, +name: String, +args: List<&2, KTerm>, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +words = noa_scalars(ctx, args)
  +result = noa_call_result(ctx, dt(lookup(noa_book(ctx), name)), args, 8)
  +id = nc_id(n)
  nt_choose(NO_Analysis, noa_no_absent(words) && Bool.not(p98_tag_eq(result, "Absent")),
    u => noa_prepend(kt("NO_Let", "", id, 0, [kt("NOp", nc_primitive_name(name), 0, 0, words)]), noa_continue(ctx, k, NO_Input{noa_atom(nm(result), kt("OUnique", "", id, 0, Nil{}), var("", id)), facts, U32.inc(n), fuel})),
    u => noa_fail("observer: scalar primitive type", n, fuel))

# Module: src/back/native/observer-analysis.bend:283
@unsafe
def w7_br_770(w7_c: Bool, +ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match w7_c:
    case True{}:
      noa_fail("observer: candidate budget", n, fuel)
    case False{}:
      noa_apply_step(ctx, fn, arg, facts, n, U32.sub(fuel, 1), k)

@unsafe
def noa_apply(ctx, fn, arg, facts, n, fuel, k):
  w7_br_770(U32.is_eq(fuel, 0), ctx, fn, arg, facts, n, fuel, k)

# Module: src/back/native/observer-analysis.bend:287
@unsafe
def w7_br_771(w7_c: Bool, +ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match w7_c:
    case True{}:
      noa_reference(ctx, nm(fn), List.append(&2, KTerm, noa_tail(ks(fn)), [arg]), facts, noa_unames(ks(kid(fn, 0))), n, fuel, k)
    case False{}:
      noa_fail("observer: dynamic application", n, fuel)

@unsafe
def w7_br_772(w7_c: Bool, +ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match w7_c:
    case True{}:
      noa_match(ctx, fn, arg, facts, n, fuel, k)
    case False{}:
      w7_br_771(p98_tag_eq(fn, "OR"), ctx, fn, arg, facts, n, fuel, k)

@unsafe
def w7_br_773(w7_c: Bool, +ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match w7_c:
    case True{}:
      noa_eval(ctx, kid(kid(fn, 0), 0), noa_bind(ix(kid(fn, 0)), arg, ks(kid(fn, 1))), facts, noa_unames(ks(kid(fn, 2))), n, fuel, k)
    case False{}:
      w7_br_772(p98_tag_eq(fn, "OM"), ctx, fn, arg, facts, n, fuel, k)

@unsafe
def noa_apply_step(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  w7_br_773(p98_tag_eq(fn, "OL"), ctx, fn, arg, facts, n, fuel, k)

# Module: src/back/native/observer-analysis.bend:293
@unsafe
def noa_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +arity = nd_arity(noa_book(ctx),name)
  +d = lookup(noa_book(ctx),name)
  nt_choose(NO_Analysis,U32.is_lt(terms_len(args),arity),u => noa_continue(ctx,k,NO_Input{kt("OR",name,0,0,Con{kt("OStack","",0,0,noa_names(stack)),args}),facts,n,fuel}),u =>
  nt_choose(NO_Analysis,U32.is_eq(terms_len(args),arity),u =>
  nt_choose(NO_Analysis,agy_str_eq(name,noa_owner(ctx)),u => noa_recur(ctx,args,facts,n,fuel,k),u =>
  nt_choose(NO_Analysis,nt_choose(Bool,nc_native_def(d),v => nd_scalar_known(nc_primitive_name(name)),v => False{}),
    u => noa_primitive(ctx,name,args,facts,n,fuel,k),
    u => p128br_reference(ctx,name,args,facts,stack,n,fuel,k,p128br_lookup(name,p128br_helpers(ctx))))),u => noa_fail("observer: saturation",n,fuel)))

@unsafe
def noa_match(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +mat = kid(fn, 0)
  nt_choose(NO_Analysis, p98_tag_eq(arg, "OC"),
    u => nt_choose(NO_Analysis, p88_string_eq(nm(mat), nm(arg)),
      v => nt_choose(NO_Analysis, U32.is_eq(ix(mat), U32.inc(terms_len(ks(arg)))), w => noa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyArgs{ks(arg), k}), w => noa_fail("observer: virtual constructor arity", n, fuel)),
      v => noa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyOne{arg, k})),
    u => noa_match_spec(ctx, fn, arg, facts, n, fuel, k, noa_spec(nm(mat), no_schema_specs(noa_schema(ctx)))))

# Module: src/back/native/observer-analysis.bend:332
@unsafe
def noa_match_spec(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont, spec: Maybe<&2, NO_Spec>) -> NO_Analysis:
  match spec:
    case None{}: noa_fail("observer: matcher representation", n, fuel)
    case Some{NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +types}}:
      nt_choose(NO_Analysis, p98_tag_eq(arg, "OA") && p88_string_eq(nm(arg), owner) && U32.is_eq(ix(kid(fn, 0)), U32.inc(width)),
        u => noa_match_fields(ctx, fn, arg, facts, key, noa_field_values(owner, ctor, noa_origin(arg), types, 0, n), U32.add(n, width), fuel, k), u => noa_fail("observer: matcher type or width", n, fuel))

# Module: src/back/native/observer-analysis.bend:340
@unsafe
def noa_match_fields(+ctx: NO_Context, +fn: KTerm, +arg: KTerm, +facts: List<&2, KTerm>, +key: String, +fields: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +mat = kid(fn, 0)
  +yesfacts = {Con{kt("OFact", "", 0, 0, [noa_origin(arg), kt("OC", nm(mat), 0, 0, noa_origins(fields))]), facts}: List<&2, KTerm>}
  +yes = noa_eval(ctx, kid(mat, 0), ks(kid(fn, 1)), yesfacts, noa_unames(ks(kid(fn, 2))), n, fuel, NO_KApplyArgs{fields, k})
  nt_choose(NO_Analysis, p88_string_eq(noa_error(yes), ""),
    u => noa_match_join(key, kid(arg, 1), fields, yes, noa_eval(ctx, kid(mat, 1), ks(kid(fn, 1)), facts, noa_unames(ks(kid(fn, 2))), noa_fresh(yes), noa_fuel(yes), NO_KApplyOne{arg, k})), u => yes)

# Module: src/back/native/observer-analysis.bend:348
@unsafe
def noa_recur(ctx, args, facts, n, fuel, k):
  +schema = noa_schema(ctx)
  +params = no_schema_params(schema)
  +marker = var("", nc_id(n))
  +observation = noa_atom(no_schema_observation(schema), kt("ORecursive", "", nc_id(n), 0, Nil{}), marker)
  +env = noa_bind(no_schema_result(schema), observation, noa_actuals(params, args))
  nt_choose(NO_Analysis, noa_loop_valid(ctx, params, args, 0, False{}),
    u => noa_recur_done(ctx, args, marker, noa_continue(ctx, k, NO_Input{noa_virtual(no_schema_wrapper(schema), env), facts, U32.inc(n), fuel})),
    u => noa_fail("observer: recursive cursor or scalar slot", n, fuel))

# Module: src/back/native/observer-analysis.bend:457
@unsafe
def w7_br_783(w7_c: Bool, +book: List<&2,KDef>, +name: String, +schema: NO_Schema) -> NO_Analysis:
  match w7_c:
    case True{}:
      noa_analyze_ready(NO_Context{book,name,schema,[]})
    case False{}:
      noa_fail("observer: absent checked permission or schema",no_schema_fresh(schema),4096)

@unsafe
def noa_analyze(+book: List<&2,KDef>, +name: String, +schema: NO_Schema, +permission: Bool) -> NO_Analysis:
  w7_br_783(permission && String.is_empty(no_schema_error(schema)), book, name, schema)

@unsafe
def noa_analyze_ready(+ctx: NO_Context) -> NO_Analysis:
  +schema = noa_schema(ctx)
  +params = noa_entry_values(no_schema_params(schema), 0)
  +body = nc_source_body(noa_book(ctx), lookup(noa_book(ctx), noa_owner(ctx)), no_schema_fresh(schema))
  noa_eval(ctx, body, Nil{}, Nil{}, Nil{}, no_schema_fresh(schema), 4096, NO_KApplyArgs{params, NO_KFinish{}})

# Module: src/back/native/observer-analysis.bend:480
@unsafe
def noa_literal(+ctx: NO_Context, +t: KTerm, +env: List<&2, KTerm>, +facts: List<&2, KTerm>, +stack: List<&2, String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +lit = no_literal_typed(noa_book(ctx), t)
  +step = no_literal_string_step(noa_book(ctx), t)
  nt_choose(NO_Analysis, p98_tag_eq(lit, "NO_TypedWord"), u => noa_continue(ctx, k, NO_Input{noa_atom(nm(lit), kt("OConst", nm(lit), ix(lit), 0, Nil{}), kid(lit, 0)), facts, n, fuel}), u =>
    nt_choose(NO_Analysis, p98_tag_eq(step, "Absent"), v => noa_fail("observer: unsupported literal", n, fuel), v => noa_eval(ctx, step, env, facts, stack, n, fuel, k)))

# Module: src/back/native/observer-analysis.bend:487
@unsafe
def noa_constructor(+ctx: NO_Context, +name: String, +input: NO_Input, +k: NO_Cont) -> NO_Analysis:
  +args = ks(noa_iv(input))
  +valid = Bool.not(p88_string_eq(name, "Chr")) || (U32.is_eq(terms_len(args), 1) && p88_string_eq(noa_value_type(ctx, terms_at(args, 0)), "U32"))
  nt_choose(NO_Analysis, valid, u => noa_continue(ctx, k, NO_Input{kt("OC", name, 0, 0, args), noa_if(input), noa_in(input), noa_iu(input)}), u => noa_fail("observer: Char constructor type", noa_in(input), noa_iu(input)))

# Module: src/back/native/observer-plan.bend:7
@unsafe
def w7_br_786(w7_c: Bool, +book: List<&2, KDef>, +name: String, +schema: NO_Schema) -> NO_Plan:
  match w7_c:
    case True{}:
      no_plan_result(name, schema, noa_analyze(book, name, schema, True{}))
    case False{}:
      NO_Plan{name, schema, noa_fail(no_schema_error(schema), no_schema_fresh(schema), 4096), no_schema_error(schema)}

@unsafe
def p86_checked_prefix(+book: List<&2,KDef>, +checked: DChecking) -> KBasePrefixState:
  +world = rw(dg_checking_result(checked))
  base_prefix_prepare_fresh(book, norm_max_book(book), checked, world, kw_fresh(world))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:444
@unsafe
def w7_br_821(w7_c: Bool, +context: List<&2,KDef>, +changed: KDef, +result: KChecking) -> KDef:
  match w7_c:
    case True{}:
      ka_def(context,dg_event_output(changed,ct(result)))
    case False{}:
      missing()

@unsafe
def p205u_checked(+context: List<&2,KDef>, +changed: KDef, +result: KChecking) -> KDef:
  w7_br_821(good(result), context, changed, result)
@unsafe
def ctfe_run_prim_args(+op: String, args: List<&2, CtfeVal>) -> CtfeVal:
  match args:
    case Con{a, Nil{}}: ctfe_run_prim1(op, a)
    case Con{a, Con{b, Nil{}}}: ctfe_run_prim2(op, a, b)
    case _: CVFail{}

@unsafe
def ctfe_run_prim(+op: String, +args_rev: List<&2, CtfeVal>) -> CtfeVal:
  ctfe_run_prim_args(op, ctfe_rev_append(args_rev, []))

law ctfe_eval:
  for +book: List<&2, KDef>
  for +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>
  for +t: KTerm
  for +fuel: U32
  CtfeRes

law ctfe_apply:
  for +book: List<&2, KDef>
  for +fn: CtfeVal
  for +arg: CtfeVal
  for +fuel: U32
  CtfeRes

law ctfe_apply_many:
  for +book: List<&2, KDef>
  for +fn: CtfeVal
  for args: List<&2, CtfeVal>
  for +fuel: U32
  CtfeRes

@unsafe
def ctfe_apply_many_next(+book: List<&2, KDef>, rest: List<&2, CtfeVal>, r: CtfeRes) -> CtfeRes:
  match r:
    case CtfeRes{+fn2, +fuel2}:
      kc(CtfeRes, ctfe_is_fail(fn2), u => CtfeRes{CVFail{}, fuel2}, u => ctfe_apply_many(book, fn2, rest, fuel2))

@unsafe
def ctfe_apply_many(book, fn, args, fuel):
  match args:
    case Nil{}: CtfeRes{fn, fuel}
    case Con{a, rest}: ctfe_apply_many_next(book, rest, ctfe_apply(book, fn, a, fuel))

@unsafe
def ctfe_match_hit(+book: List<&2, KDef>, fields: List<&2, CtfeVal>, r: CtfeRes) -> CtfeRes:
  match r:
    case CtfeRes{+handler, +fuel2}:
      kc(CtfeRes, ctfe_is_fail(handler), w => CtfeRes{CVFail{}, fuel2}, w => ctfe_apply_many(book, handler, fields, fuel2))

@unsafe
def ctfe_match_default(+book: List<&2, KDef>, +val: CtfeVal, r: CtfeRes) -> CtfeRes:
  match r:
    case CtfeRes{+handler, +fuel2}:
      kc(CtfeRes, ctfe_is_fail(handler), w => CtfeRes{CVFail{}, fuel2}, w => ctfe_apply(book, handler, val, fuel2))

@unsafe
def ctfe_match_step(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +arm: KTerm, +cname: String, +fields: List<&2, CtfeVal>, +fuel: U32) -> CtfeRes:
  +a = j_strip(arm)
  kc(CtfeRes, p98_tag_eq(a, "Mat"),
    u => kc(CtfeRes, agy_str_eq(nm(a), cname),
      v => ctfe_match_hit(book, fields, ctfe_eval(book, env, kid(a, 0), fuel)),
      v => ctfe_match_step(book, env, kid(a, 1), cname, fields, fuel)),
    u => kc(CtfeRes, p98_tag_eq(a, "Efq"),
      v => ctfe_fail(fuel),
      v => ctfe_match_default(book, CVCtr{cname, fields}, ctfe_eval(book, env, a, fuel))))

@unsafe
def ctfe_match_str(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +arm: KTerm, s: String, +fuel: U32) -> CtfeRes:
  match s:
    case SNil{}: ctfe_match_step(book, env, arm, "SNil", [], fuel)
    case SCon{c, rest}: ctfe_match_step(book, env, arm, "SCon", [CVCtr{"Chr", [CVU32{Char.to_u32(c)}]}, CVStr{rest}], fuel)

@unsafe
def ctfe_match_val(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +arm: KTerm, v: CtfeVal, +fuel: U32) -> CtfeRes:
  match v:
    case CVCtr{cname, fields}: ctfe_match_step(book, env, arm, cname, fields, fuel)
    case CVNat{n}:
      kc(CtfeRes, U32.is_eq(n, 0),
        u => ctfe_match_step(book, env, arm, "Zero", [], fuel),
        u => ctfe_match_step(book, env, arm, "Succ", [CVNat{U32.sub(n, 1)}], fuel))
    case CVStr{s}: ctfe_match_str(book, env, arm, s, fuel)
    case CVU32{n}: ctfe_match_step(book, env, arm, "U32", [ctfe_word_bits(n, 32)], fuel)
    case CVF32{x}: ctfe_match_step(book, env, arm, "F32", [ctfe_word_bits(F32.bits(x), 32)], fuel)
    case _: ctfe_fail(fuel)

@unsafe
def ctfe_apply_go(+book: List<&2, KDef>, fn: CtfeVal, +arg: CtfeVal, +f1: U32) -> CtfeRes:
  match fn:
    case CVClo{+cenv, +term}:
      kc(CtfeRes, p98_tag_eq(term, "Lam"),
        v => ctfe_eval(book, Con{(ix(term), arg), cenv}, kid(term, 0), f1),
        v => kc(CtfeRes, p98_tag_eq(term, "Mat"),
          w => ctfe_match_val(book, cenv, term, arg, f1),
          w => ctfe_fail(f1)))
    case CVPrim{+name, +arity, +args}:
      kc(CtfeRes, U32.is_eq(arity, 1),
        v => CtfeRes{ctfe_run_prim(name, Con{arg, args}), f1},
        v => CtfeRes{CVPrim{name, U32.sub(arity, 1), Con{arg, args}}, f1})
    case _: ctfe_fail(f1)

@unsafe
def w7_br_870(w7_c: Bool, +book: List<&2, KDef>, +fn: CtfeVal, +arg: CtfeVal, +fuel: U32) -> CtfeRes:
  match w7_c:
    case True{}:
      ctfe_fail(0)
    case False{}:
      ctfe_apply_go(book, fn, arg, U32.sub(fuel, 1))

@unsafe
def ctfe_apply(book, fn, arg, fuel):
  w7_br_870(U32.is_eq(fuel, 0), book, fn, arg, fuel)

law ctfe_eval_list:
  for +book: List<&2, KDef>
  for +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>
  for xs: List<&2, KTerm>
  for +fuel: U32
  CtfeListRes

@unsafe
def ctfe_eval_list_head(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, rest: List<&2, KTerm>, r: CtfeRes) -> CtfeListRes:
  match r:
    case CtfeRes{+v, +f1}:
      kc(CtfeListRes, ctfe_is_fail(v), u => CtfeListRes{[], f1, False{}},
        u => ctfe_eval_list_join(v, ctfe_eval_list(book, env, rest, f1)))

@unsafe
def ctfe_eval_list(book, env, xs, fuel):
  match xs:
    case Nil{}: CtfeListRes{[], fuel, True{}}
    case Con{x, rest}: ctfe_eval_list_head(book, env, rest, ctfe_eval(book, env, x, fuel))

law ctfe_eval_let:
  for +book: List<&2, KDef>
  for +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>
  for +xs: List<&2, KTerm>
  for +fuel: U32
  CtfeRes

@unsafe
def ctfe_eval_let_next(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +bid: U32, +rest: List<&2, KTerm>, r: CtfeRes) -> CtfeRes:
  match r:
    case CtfeRes{+val, +f1}:
      kc(CtfeRes, ctfe_is_fail(val), w => CtfeRes{CVFail{}, f1},
        w => ctfe_eval_let(book, Con{(bid, val), env}, rest, f1))

@unsafe
def ctfe_eval_let(book, env, xs, fuel):
  match xs:
    case Con{body, Nil{}}: ctfe_eval(book, env, body, fuel)
    case Con{+b, +rest}:
      kc(CtfeRes, p98_tag_eq(b, "Bind") && U32.is_eq(terms_len(ks(b)), 1),
        u => kc(CtfeRes, U32.is_eq(qt(b), 0),
          v => ctfe_eval_let(book, Con{(ix(b), CVEra{}), env}, rest, fuel),
          v => ctfe_eval_let_next(book, env, ix(b), rest, ctfe_eval(book, env, kid(b, 0), fuel))),
        u => ctfe_fail(fuel))
    case _: ctfe_fail(fuel)

@unsafe
def ctfe_eval_ref(+book: List<&2, KDef>, +name: String, +fuel: U32) -> CtfeRes:
  +d = lookup(book, name)
  kc(CtfeRes, agy_str_eq(dk(d), "ADT"), u => CtfeRes{CVEra{}, fuel}, u =>
    +prim = kc(String, db(d) && Bool.not(du(d)) && U32.is_eq(dx(d), 0), v => nc_primitive_name(name), v => "")
    +pa = kc(U32, String.is_empty(prim), v => 0, v => ctfe_prim_arity(prim))
    kc(CtfeRes, U32.is_gt(pa, 0),
      v => CtfeRes{CVPrim{prim, pa, []}, fuel},
      v => kc(CtfeRes, agy_str_eq(dk(d), "Def") && Bool.not(du(d)) && U32.is_eq(dx(d), 0) &&
        Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) && Bool.not(p98_tag_eq(j_strip(dv(d)), "Absent")),
        w => ctfe_eval(book, [], dv(d), fuel),
        w => ctfe_fail(fuel))))

@unsafe
def ctfe_eval_app_arg(+book: List<&2, KDef>, +fn: CtfeVal, r: CtfeRes) -> CtfeRes:
  match r:
    case CtfeRes{+arg, +f2}:
      kc(CtfeRes, ctfe_is_fail(arg), w => CtfeRes{CVFail{}, f2}, w => ctfe_apply(book, fn, arg, f2))

@unsafe
def ctfe_eval_app_fn(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +t: KTerm, r: CtfeRes) -> CtfeRes:
  match r:
    case CtfeRes{+fn, +f1}:
      kc(CtfeRes, ctfe_is_fail(fn), u => CtfeRes{CVFail{}, f1},
        u => kc(CtfeRes, ctfe_is_erased_clo(fn),
          v => ctfe_apply(book, fn, CVEra{}, f1),
          v => ctfe_eval_app_arg(book, fn, ctfe_eval(book, env, kid(t, 1), f1))))

@unsafe
def ctfe_eval_app(+book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +t: KTerm, +fuel: U32) -> CtfeRes:
  ctfe_eval_app_fn(book, env, t, ctfe_eval(book, env, kid(t, 0), fuel))

@unsafe
def w7_br_872(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +t: KTerm, +fuel: U32) -> CtfeRes:
  match w7_c:
    case True{}:
      ctfe_eval_lit(t, fuel)
    case False{}:
      +tag = tg(t) +f1 = U32.sub(fuel, 1) kc(CtfeRes, agy_str_eq(tag, "Ann"), u => ctfe_eval(book, env, kid(t, 0), fuel), u => kc(CtfeRes, agy_str_eq(tag, "Var"), u => CtfeRes{ctfe_env_get(env, ix(t)), f1}, u => kc(CtfeRes, agy_str_eq(tag, "Ref"), u => kc(CtfeRes, U32.is_eq(qt(t), 3), v => ctfe_fail(f1), v => ctfe_eval_ref(book, nm(t), f1)), u => kc(CtfeRes, agy_str_eq(tag, "Lam") || agy_str_eq(tag, "Mat"), u => CtfeRes{CVClo{env, t}, f1}, u => kc(CtfeRes, agy_str_eq(tag, "App"), u => ctfe_eval_app(book, env, t, f1), u => kc(CtfeRes, agy_str_eq(tag, "Let"), u => ctfe_eval_let(book, env, ks(t), f1), u => kc(CtfeRes, agy_str_eq(tag, "Ctr"), u => ctfe_eval_ctr(nm(t), ctfe_eval_list(book, env, ks(t), f1)), u => kc(CtfeRes, agy_str_eq(tag, "ADT") || agy_str_eq(tag, "All") || agy_str_eq(tag, "Typ") || agy_str_eq(tag, "Lvl") || agy_str_eq(tag, "Qua") || agy_str_eq(tag, "Era") || agy_str_eq(tag, "Min") || agy_str_eq(tag, "Set") || agy_str_eq(tag, "Eql") || agy_str_eq(tag, "Rfl"), u => CtfeRes{CVEra{}, f1}, u => ctfe_fail(f1)))))))))

@unsafe
def w7_br_873(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +t: KTerm, +fuel: U32) -> CtfeRes:
  match w7_c:
    case True{}:
      ctfe_fail(0)
    case False{}:
      w7_br_872(core_literal(t), book, env, t, fuel)

@unsafe
def ctfe_eval(book, env, t, fuel):
  w7_br_873(U32.is_eq(fuel, 0), book, env, t, fuel)

@unsafe
def w7_br_888(w7_c: Bool, +ctx: List<&2,KDef>, +ctx_chk: List<&2,KDef>, +orig_d: KDef, +cand_def: KDef, +rest: List<&2,KDef>, +res: KChecking) -> AgyAbsResult:
  match w7_c:
    case True{}:
      agy_abs_commit_ok(ctx_chk,ka_def(ctx_chk,dg_event_output(cand_def,ct(res))),rest)
    case False{}:
      AgyAbsResult{ctx,Con{orig_d,rest},False{}}

@unsafe
def agy_abs_commit_checked(+ctx: List<&2,KDef>, +ctx_chk: List<&2,KDef>, +orig_d: KDef, +cand_def: KDef, +rest: List<&2,KDef>, +res: KChecking) -> AgyAbsResult:
  w7_br_888(good(res), ctx, ctx_chk, orig_d, cand_def, rest, res)

law p205v_range:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +fuel: U32
  W2Range

@unsafe
def w7_br_906(w7_c: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> W2Range:
  match w7_c:
    case True{}:
      p205v_range_add(p205v_range(book,a,fuel),p205v_range(book,b,fuel))
    case False{}:
      W2Range{0,0,False{}}

@unsafe
def w7_br_907(w7_c: Bool, +book: List<&2,KDef>, +op: String, +a: KTerm, +b: KTerm, +fuel: U32) -> W2Range:
  match w7_c:
    case True{}:
      p205v_range_and(j_u32(b))
    case False{}:
      w7_br_906(agy_str_eq(op,"u32_add"), book, a, b, fuel)

@unsafe
def w7_br_908(w7_c: Bool, +book: List<&2,KDef>, +op: String, +a: KTerm, +b: KTerm, +fuel: U32) -> W2Range:
  match w7_c:
    case True{}:
      p205v_range_mod(j_u32(b))
    case False{}:
      w7_br_907(agy_str_eq(op,"u32_and"), book, op, a, b, fuel)

@unsafe
def p205v_range_op(+book: List<&2,KDef>, +op: String, +a: KTerm, +b: KTerm, +fuel: U32) -> W2Range:
  w7_br_908(agy_str_eq(op,"u32_mod"), book, op, a, b, fuel)

@unsafe
def w7_br_909(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> W2Range:
  match w7_c:
    case True{}:
      p205v_range_op(book,nd_native_call(book,t),p205u_at(ks(call),0),p205u_at(ks(call),1),fuel)
    case False{}:
      W2Range{0,0,False{}}

@unsafe
def p205v_range_app(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> W2Range:
  w7_br_909(p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2), book, t, call, fuel)

@unsafe
def p205v_range_lit(+book: List<&2,KDef>, +t: KTerm, +fuel: U32, +lit: Maybe<&2,U32>) -> W2Range:
  match lit:
    case Some{n}: W2Range{n,n,True{}}
    case None{}:
      kc(W2Range,p98_tag_eq(t,"App"),u => p205v_range_app(book,t,j_call_spine(t,[]),fuel),
        u => W2Range{0,0,False{}})

@unsafe
def w5c2_p205v_range_if(z: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> W2Range:
  match z:
    case True{}: W2Range{0,0,False{}}
    case False{}:
      +s = j_strip(t)
      p205v_range_lit(book, s, U32.sub(fuel, 1), j_u32_node(s))

@unsafe
def p205v_range(book, t, fuel):
  w5c2_p205v_range_if(U32.is_eq(fuel, 0), book, t, fuel)

law p205v_pure:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +fuel: U32
  Bool

@unsafe
def p205v_pure_list(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +fuel: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: p205v_pure(book,x,fuel) && p205v_pure_list(book,rest,fuel)

@unsafe
def w5c3_pure_def_if(ok: Bool, +book: List<&2,KDef>, +d: KDef, +fuel: U32) -> Bool:
  match ok:
    case True{}: p205v_pure(book,dv(d),fuel)
    case False{}: False{}

@unsafe
def p205v_pure_def(+book: List<&2,KDef>, +name: String, +fuel: U32) -> Bool:
  +d = lookup(book,name)
  w5c3_pure_def_if(String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(p205u_refs(dv(d),name),0) && p205u_room([dv(d)],128), book, d, fuel)

@unsafe
def w5c3_pure_call_op(empty_op: Bool, +book: List<&2,KDef>, +op: String, +cname: String, +args: List<&2,KTerm>, +fuel: U32) -> Bool:
  match empty_op:
    case False{}: p205v_pure_op(op) || p205v_pure_nonzero_mod(op,args) || p205v_pure_def(book,cname,fuel)
    case True{}: p205v_pure_def(book,cname,fuel)

@unsafe
def w5c3_pure_call_bool(is_bool: Bool, +book: List<&2,KDef>, +t: KTerm, +cname: String, +args: List<&2,KTerm>, +fuel: U32) -> Bool:
  match is_bool:
    case True{}: p205v_pure_list(book,args,fuel)
    case False{}:
      +op = nd_native_call(book,t)
      w5c3_pure_call_op(String.is_empty(op), book, op, cname, args, fuel) && p205v_pure_list(book,args,fuel)

@unsafe
def w5c3_pure_call_if(is_call: Bool, +book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> Bool:
  match is_call:
    case False{}: False{}
    case True{}:
      +args = ks(call)
      +cname = nm(call)
      w5c3_pure_call_bool(String.eq(cname,"Bool.and") || String.eq(cname,"Bool.or"), book, t, cname, args, fuel)

@unsafe
def p205v_pure_call(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> Bool:
  w5c3_pure_call_if(p98_tag_eq(call,"Call"), book, t, call, fuel)

@unsafe
def w5c3_pure_app(is_app: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match is_app:
    case True{}: p205v_pure_call(book,t,j_call_spine(t,[]),fuel)
    case False{}: False{}

@unsafe
def w5c3_pure_kids(has_kids: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match has_kids:
    case True{}: p205v_pure_list(book,ks(t),fuel)
    case False{}: w5c3_pure_app(String.eq(tag,"App"), book, t, fuel)

@unsafe
def w5c3_pure_leaf(is_leaf: Bool, +tag: String, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match is_leaf:
    case True{}: True{}
    case False{}: w5c3_pure_kids(String.eq(tag,"Ctr") || String.eq(tag,"Lam") || String.eq(tag,"Let") || String.eq(tag,"Bind"), tag, book, t, fuel)

@unsafe
def p205v_pure_go(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  +tag = tg(t)
  w5c3_pure_leaf(String.eq(tag,"Var") || String.eq(tag,"Ref") || core_literal(t), tag, book, t, fuel)

@unsafe
def w5c3_pure_fuel(z: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match z:
    case True{}: False{}
    case False{}: p205v_pure_go(book,j_strip(t),U32.sub(fuel,1))

@unsafe
def p205v_pure(book, t, fuel):
  w5c3_pure_fuel(U32.is_eq(fuel,0), book, t, fuel)

@unsafe
def w5c3_fb_and3(m: Bool, +book: List<&2,KDef>, +a: KTerm, +bb: U32) -> KTerm:
  match m:
    case True{}: a
    case False{}: w5c3_fb_and4(U32.is_eq(bb,1) && p205v_pure(book,a,16))

@unsafe
def w5c3_fb_and2(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case True{}: p205v_bool(False{})
    case False{}:
      +bb = p205v_bool_val(b)
      w5c3_fb_and3(U32.is_eq(bb,2), book, a, bb)

@unsafe
def w5c3_fb_and1(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm, +ba: U32) -> KTerm:
  match m:
    case True{}: b
    case False{}: w5c3_fb_and2(U32.is_eq(ba,1) && p205v_pure(book,b,16), book, a, b)

@unsafe
def w5c3_fb_or3(m: Bool, +book: List<&2,KDef>, +a: KTerm, +bb: U32) -> KTerm:
  match m:
    case True{}: a
    case False{}: w5c3_fb_or4(U32.is_eq(bb,2) && p205v_pure(book,a,16))

@unsafe
def w5c3_fb_or2(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case True{}: p205v_bool(True{})
    case False{}:
      +bb = p205v_bool_val(b)
      w5c3_fb_or3(U32.is_eq(bb,1), book, a, bb)

@unsafe
def w5c3_fb_or1(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm, +ba: U32) -> KTerm:
  match m:
    case True{}: b
    case False{}: w5c3_fb_or2(U32.is_eq(ba,2) && p205v_pure(book,b,16), book, a, b)

@unsafe
def w5c3_fb_or(m: Bool, +book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match m:
    case False{}: atom("Absent")
    case True{}:
      +ba = p205v_bool_val(a)
      w5c3_fb_or1(U32.is_eq(ba,1), book, a, b, ba)

@unsafe
def w5c3_words_rcmp(ok: Bool, +book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm) -> KTerm:
  match ok:
    case True{}: p205v_range_cmp(op,p205v_range(book,at,8),p205v_range(book,bt,8))
    case False{}: atom("Absent")

@unsafe
def w5c3_words_nonempty(empty: Bool, +book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  match empty:
    case True{}: atom("Absent")
    case False{}:
      match a b:
        case Some{x} Some{y}: p205v_binary(op,x,y)
        case _ _: w5c3_words_rcmp(w5c3_is_range_cmp_op(op), book, op, at, bt)

@unsafe
def p205v_words(+book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  w5c3_words_nonempty(String.is_empty(op), book, op, at, bt, a, b)

@unsafe
def w5c3_fold_op(empty: Bool, +book: List<&2,KDef>, +op: String, +a: KTerm, +b: KTerm) -> KTerm:
  match empty:
    case True{}: atom("Absent")
    case False{}: p205v_words(book,op,a,b,j_u32(a),j_u32(b))

@unsafe
def p205v_has_range(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  p205v_range_ok(p205v_range(book,t,8))

@unsafe
def p205v_any_with_range(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: p205v_static(x) || p205v_has_range(book,x) || p205v_any_with_range(book,rest)

@unsafe
def w2d_plan_res(+ctx: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +defs: List<&2,KDef>, +res: AgyBFResult) -> P86Plan:
  match res:
    case AgyBFResult{ctx1,defs1,True{}}:
      kc(P86Plan,String.is_empty(jl_checked_error(ctx1,defs1,["main"],stops)),
        u => P86PlanReady{nr_prepare_annotated(ctx1,defs1),verdict},
        u => P86PlanReady{nr_prepare_annotated(ctx,defs),verdict})
    case _: P86PlanReady{nr_prepare_annotated(ctx,defs),verdict}

@unsafe
def p152c_prior_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"Ctr") || p98_tag_eq(value,"NCtr"),
    u => nt_choose(N_WordKind,p113n_constructor(book,nm(value),terms_len(ks(value))),v => N_Imm64{},v => p113n_original_value_kind(book,value,env)),
    u => p113n_original_value_kind(book,value,env))

law p111_show_nodes:
  for +book: List<&2, KDef>
  for +types: List<&2, KTerm>
  for +i: U32
  for +offset: U32
  for +offsets: List<&2, U32>
  for +cells: List<&2, P111ShowCell>
  P111ShowGraph

@unsafe
def p111_show_node(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +k = nt_choose(String, db(lookup(book, nm(ty))), u => nm(ty), u => "")
  nt_choose(P111ShowDesc, agy_str_eq(k, "U32"), u => P111ShowDesc{[P111ShowWord{0}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(k, "F32"), u => P111ShowDesc{[P111ShowWord{1}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(k, "Nat"), u => P111ShowDesc{[P111ShowWord{2}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(k, "Char"), u => P111ShowDesc{[P111ShowWord{3}, P111ShowWord{0}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(k, "String"), u => P111ShowDesc{[P111ShowWord{4}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(k, "Bool"), u => P111ShowDesc{[P111ShowWord{7}, P111ShowWord{0}, P111ShowWord{2}, P111ShowCtor{"False"}, P111ShowCtor{"False"}, P111ShowWord{0}, P111ShowCtor{"True"}, P111ShowCtor{"True"}, P111ShowWord{0}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(tg(ty), "Eql"), u => P111ShowDesc{[P111ShowWord{5}], types, ""}, u =>
  nt_choose(P111ShowDesc, agy_str_eq(k, "Array"), u => p111_show_array(p111_show_ref(book, kid(ty, 0), types)), u =>
  nt_choose(P111ShowDesc, agy_str_eq(tg(ty), "ADT") && agy_str_eq(dk(lookup(book, nm(ty))), "ADT") && Bool.not(agy_str_eq(k, "IO.OP")), u => p111_show_data(book, ty, types), u =>
    P111ShowDesc{Nil{}, types, "native readback cannot print a function, type, or dependent field"})))))))))

@unsafe
def p111_show_step(+book: List<&2, KDef>, +i: U32, +offset: U32, +offsets: List<&2, U32>, +cells: List<&2, P111ShowCell>, +d: P111ShowDesc) -> P111ShowGraph:
  +next = U32.add(offset, nt_count(P111ShowCell, p111_show_cells(d)))
  nt_choose(P111ShowGraph, agy_str_eq(p111_show_error(d), ""),
    u =>
    nt_choose(P111ShowGraph, U32.is_lt(next, offset), u => P111ShowGraph{Nil{}, Nil{}, "native readback descriptor offset overflow"}, u =>
      p111_show_nodes(book, p111_show_types(d), U32.inc(i), next, List.append(&2, U32, offsets, [offset]), List.append(&2, P111ShowCell, cells, p111_show_cells(d)))), u => P111ShowGraph{Nil{}, Nil{}, p111_show_error(d)})

@unsafe
def p111_show_nodes(book, types, i, offset, offsets, cells):
  nt_choose(P111ShowGraph, U32.is_eq(i, terms_len(types)), u => P111ShowGraph{cells, offsets, ""}, u =>
    nt_choose(P111ShowGraph, U32.is_gt(i, 4096), u => P111ShowGraph{Nil{}, Nil{}, "native readback type graph exceeds 4096 nodes"}, u =>
      p111_show_step(book, i, offset, offsets, cells, p111_show_node(book, wnf(book, terms_at(types, i)), types))))

@unsafe
def p111_show(+book: List<&2, KDef>, ty: KTerm, constructors: List<&2, N_Constructor>) -> P111Show:
  p111_show_finish(constructors, p111_show_nodes(book, [ty], 0, 0, Nil{}, Nil{}))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-catalogue.bend
# Finite authenticated runtime primitive catalogue. No C templates are read.
@unsafe
def p111v_join(+yes: P111VFlow, +no: P111VFlow) -> P111VFlow:
  match yes:
    case P111VFlow{+yl,yt,+ye}: w5c3_join_yes_err(Bool.not(String.is_empty(ye)), yes, no, yl, yt)

# Exact signatures from runtime/runtime.h and runtime/primitives.h. All results
# in this segment API are U64; process entry p111_rt_main is not callable here.
@unsafe
def w5c3_stmt_if(ok: Bool, yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match ok:
    case True{}: p111v_join(p111v_body(yes,schema,P111VFlow{live,False{},""},ids,arity,incoming,result),p111v_body(no,schema,P111VFlow{live,False{},""},ids,arity,incoming,result))
    case False{}: P111VFlow{live,False{},"condition must be a definitely assigned U32"}

@unsafe
def p111v_stmt(+stmt: N111Stmt, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match stmt:
    case N111Set{name,typ,value}: p111v_step(p111v_value(value,p111v_type(typ),live,ids),name,schema,live,"ill-typed or undefined assignment")
    case N111Bin{name,typ,op,left,right}:
      +width = p111v_type(typ)
      p111v_step(U32.is_le(width,2) && p111v_operator(op) && p111v_value(left,width,live,ids) && p111v_value(right,width,live,ids),name,schema,live,"invalid binary operation or operand")
    case N111Call{name,typ,symbol,args}:
      p111v_step(p111v_call(symbol,typ,args,live,ids,arity,incoming,result),name,schema,live,"runtime import signature/count/capacity mismatch: " ++ symbol)
    case N111If{condition,yes,no}:
      w5c3_stmt_if(p111v_value(condition,1,live,ids), yes, no, schema, live, ids, arity, incoming, result)
    case N111Return{value}:
      w5c3_stmt_ret(p111v_value(value,2,live,ids), live)
    case N111Load{name,typ,base,offset}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids),name,schema,live,"unbounded, unaligned or ill-typed load")
    case N111Store{typ,base,offset,value}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids) && p111v_value(value,p111v_type(typ),live,ids),"",schema,live,"unbounded, unaligned or ill-typed store")
    case N111Offset{name,base,bytes}: p111v_offset(name,base,bytes,live,ids)
    case N111Alloca{name,bytes,align}:
      p111v_step(U32.is_gt(bytes,0) && U32.is_le(bytes,2048) && (U32.is_eq(align,4) || U32.is_eq(align,8) || U32.is_eq(align,16)),name,schema,live,"unsupported stack allocation size/alignment")

@unsafe
def w5c3_body_term(terminal: Bool, +head: N111Stmt, rest: List<&2,N111Stmt>, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match terminal:
    case True{}: P111VFlow{live,True{},"statement follows terminal path"}
    case False{}: p111v_body(rest,schema,p111v_stmt(head,schema,live,ids,arity,incoming,result),ids,arity,incoming,result)

@unsafe
def w5c3_body_err(has_err: Bool, +flow: P111VFlow, +head: N111Stmt, rest: List<&2,N111Stmt>, +schema: KDef, +live: KDef, terminal: Bool, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match has_err:
    case True{}: flow
    case False{}: w5c3_body_term(terminal, head, rest, schema, live, ids, arity, incoming, result)

@unsafe
def p111v_body(+body: List<&2,N111Stmt>, +schema: KDef, +flow: P111VFlow, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match body:
    case Nil{}: flow
    case Con{head,rest}:
      match flow:
        case P111VFlow{live,terminal,+error}:
          w5c3_body_err(Bool.not(String.is_empty(error)), flow, head, rest, schema, live, terminal, ids, arity, incoming, result)

@unsafe
def w5c3_seg_flow_if(has_err: Bool, +error: String, +body: List<&2,N111Stmt>, +index: KDef, +seed: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match has_err:
    case True{}: error
    case False{}: p111v_finish(p111v_body(body,index,P111VFlow{seed,False{},""},ids,arity,incoming,result))

@unsafe
def p111v_segment_flow(+body: List<&2,N111Stmt>, +schema: P111VScan, +seed: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match schema:
    case P111VScan{index,+error,+count}:
      w5c3_seg_flow_if(Bool.not(String.is_empty(error)), error, body, index, seed, ids, arity, incoming, result)

@unsafe
def p111v_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      +seed = p111v_put(missing(),"state","parameter",3,2088)
      p111v_segment_flow(body,p111v_schema(body,P111VScan{seed,"",1}),seed,ids,arity,incoming,result)


# Phase111 module: selfhost/tools/performance/phase111/qbe/numbers.bend
# QBE 1.3 accepts decimal integer tokens; preserve all 64 bits without host
# floating-point conversion, hexadecimal assumptions or an auxiliary C parser.
@unsafe
def p112c_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> Maybe<&2,List<&2,N111Stmt>>:
  +buffer = p112r_head_buffer(body)
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_lt(site,8) && p112r_buffer(buffer,site),
    u => p112c_try_frame(p112c_frame(body,0,[],buffer),index,ready,site,buffer),u => None{})


@unsafe
def p112c_scan(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  p112c_scan_try(body,index,ready,site,p112c_try(body,index,ready,site))

# A successful site introduces a fresh numeric namespace, then scanning resumes
# inside that produced list with a strictly greater counter. The ready set never
# changes here. At most eight continuation copies can be introduced.


@unsafe
def p112c_scan_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32, attempt: Maybe<&2,List<&2,N111Stmt>>) -> P112FusionBody:
  match attempt:
    case Some{+fused}: p112c_more(p112c_scan(fused,index,ready,U32.inc(site)))
    case None{}: p112c_scan_next(body,index,ready,site)


@unsafe
def p112c_scan_next(body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  match body:
    case Nil{}: P112FusionBody{[],0,site}
    case Con{N111If{+condition,+yes,+no},+rest}: p112c_scan_yes(condition,no,rest,index,ready,p112c_scan(yes,index,ready,site))
    case Con{+stmt,+rest}: p112f_prepend(stmt,p112c_scan(rest,index,ready,site))


@unsafe
def p112c_scan_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, yes: P112FusionBody) -> P112FusionBody:
  match yes:
    case P112FusionBody{+body,+count,+next}: p112c_scan_no(condition,body,count,rest,index,ready,p112c_scan(no,index,ready,next))


@unsafe
def p112c_scan_no(+condition: N111Value, +yes: List<&2,N111Stmt>, +yc: U32, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, no: P112FusionBody) -> P112FusionBody:
  match no:
    case P112FusionBody{+body,+count,+next}: p112f_scan_rest(condition,yes,body,U32.add(yc,count),p112c_scan(rest,index,ready,next))

@unsafe
def p112c_plan_index(segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P112FusionBody:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112FusionBody,U32.is_eq(result,1) && U32.is_eq(flags,0),
        u => nt_choose(P112FusionBody,p112f_clean(body),
          v => p112c_scan(body,index,ready,0),v => P112FusionBody{body,0,0}),
        u => P112FusionBody{body,0,0})


@unsafe
def p112c_add(+segment: N111Segment, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry) -> P112RegionRegistry:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112RegionRegistry,p112w_ready(old,name),u => next,u =>
        p112c_fused(segment,old,symbols,rank,next,p112c_scan(body,index,old,0)))

# old and symbols are immutable for the entire pass; next is only accumulated.


@unsafe
def p112c_pass(segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, next: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: next
    case Con{P112MultiCandidate{+segment},+rest}: p112c_pass(rest,index,old,symbols,rank,p112c_add(segment,index,old,symbols,rank,next))


@unsafe
def p112c_passes(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,U32.is_eq(left,0),u => registry,u => p112c_round(segments,index,registry,rank,left))


@unsafe
def p112c_round(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112c_continue(segments,index,rank,left,workers,p112c_pass(segments,index,ready,symbols,rank,registry))


@unsafe
def p112c_continue(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +rank: U32, +left: U32, +previous: U32, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      nt_choose(P112RegionRegistry,U32.is_eq(workers,previous),u => registry,u => p112c_passes(segments,index,registry,U32.inc(rank),U32.sub(left,1)))


@unsafe
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,agy_str_eq(symbol,"p126_rt_nat_divmod"),u => p126dp_import(name,typ,args,schema,live,ids),
        u => p126dp_original_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p126dp_original_stmt(stmt,schema,live,ids,ready,arity,result)

@unsafe
def p113e_body(body: List<&2,P113DStmt>, +schema: KDef, +flow: P111VFlow, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match body flow:
    case Nil{} _: flow
    case Con{head,rest} P111VFlow{live,terminal,+error}:
      nt_choose(P111VFlow,Bool.not(String.is_empty(error)),u => flow,u =>
        nt_choose(P111VFlow,terminal,u => P111VFlow{live,True{},"statement follows direct terminal edge"},
          u => p113e_body(rest,schema,p113e_stmt(head,schema,live,ids,ready,arity,result),ids,ready,arity,result)))


@unsafe
def p113e_flow(+body: List<&2,P113DStmt>, +seed: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, scan: P111VScan) -> String:
  match scan:
    case P111VScan{schema,+error,+count}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        nt_choose(String,U32.is_gt(count,65535),u => "too many direct locals",
          u => p111v_finish(p113e_body(body,schema,P111VFlow{seed,False{},""},ids,ready,arity,result))))


@unsafe
def p113e_seeded(+body: List<&2,P113DStmt>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, +scan: P111VScan) -> String:
  match scan:
    case P111VScan{seed,error,count}: p113e_flow(body,seed,ids,ready,arity,result,p113e_schema(body,scan))


@unsafe
def p113_application_kind(+book: List<&2,KDef>, +value: KTerm, +native: String) -> N_WordKind:
  nt_choose(N_WordKind, String.is_empty(native),
    u => p113_callee_kind(book,nd_head(value),terms_len(nd_args(value,[]))),
    u => p113_primitive_kind(native,terms_len(nd_args(value,[]))))

@unsafe
def p113_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"NStatic"),
    u => nt_choose(N_WordKind,p152c_immediate(book,value),v => N_Imm64{},v => p152c_prior_kind(book,value,env)),
    u => p152c_prior_kind(book,value,env))

@unsafe
def p113_binding(+book: List<&2,KDef>, +id: U32, +value: KTerm, +env: List<&2,NC_Binding>) -> NC_Binding:
  NC_Binding{id,"v_" ++ U32.show(id),p113_value_kind(book,value,env)}


@unsafe
def w5c2_px_let_shape(is_call: Bool, +book: List<&2,KDef>, +value: KTerm, +target: P113PTarget) -> KTerm:
  match is_call:
    case True{}: nq_call_shape(book,nm(value),ks(value),p113pl_view(target))
    case False{}: p126dp_value_shape(book,value,p113pl_view(target))

@unsafe
def p113n_original_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(value,"Var") || p98_tag_eq(value,"NWord"),
    u => nk_value(value,env),
    u => nt_choose(N_WordKind, p98_tag_eq(value,"NOp"),
      v => p113_primitive_kind(nm(value),terms_len(ks(value))),
      v => nt_choose(N_WordKind, p98_tag_eq(value,"App"),
        w => p113_application_kind(book,value,nd_native_call(book,value)),
        w => nt_choose(N_WordKind, p98_tag_eq(value,"Ref"),
          z => p113_callee_kind(book,value,0), z => N_W64{}))))


@unsafe
def p113a_certificate(request: NR_Request) -> P113ACertificate:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +scalar = ns_definitions(book,names)
      P113ACertificate{scalar,nt_choose(Bool,scalar,u => nr_unshared(book,names),u => False{})}


law p113k_join_go:
  for +left: KDef
  for +right: KDef
  for +out: KDef
  KDef

law p113k_join_leaf:
  for +lh: U32
  for +lbucket: List<&2,KDef>
  for +right: KDef
  for +out: KDef
  KDef

@unsafe
def w5c2_jl_lr(go_l: Bool, +lh: U32, +lbucket: List<&2,KDef>, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_leaf(lh, lbucket, ra, out)
    case False{}: p113k_join_leaf(lh, lbucket, rb, out)

@unsafe
def w5c2_jl_sub(in_sub: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rm: U32, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match in_sub:
    case True{}: w5c2_jl_lr(U32.is_eq(U32.and(lh, rm), 0), lh, lbucket, ra, rb, out)
    case False{}: out

@unsafe
def w5c2_jl_rm0(rm0: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match rm0:
    case True{}: p113k_join_bucket_h(lbucket, lh, right, out)
    case False{}: w5c2_jl_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, lbucket, rm, ra, rb, out)

@unsafe
def p113k_join_leaf(lh, lbucket, right, out):
  match right:
    case KIndexLeaf{rh, rbucket}:
      w5c2_jl_eq(U32.is_eq(lh, rh), lh, lbucket, rbucket, out)
    case KIndexNode{rh, rm, ra, rb}:
      w5c2_jl_rm0(U32.is_eq(rm, 0), lh, lbucket, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jl_abs(String.eq(kind, "Absent"), lh, lbucket, right, out)

@unsafe
def w5c2_jg_lr(go_l: Bool, +a: KDef, +b: KDef, +other: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_go(a, other, out)
    case False{}: p113k_join_go(b, other, out)

@unsafe
def w5c2_jg_lr_r(go_l: Bool, +other: KDef, +a: KDef, +b: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_go(other, a, out)
    case False{}: p113k_join_go(other, b, out)

@unsafe
def w5c2_jnn_lt_sub(ok: Bool, +rh: U32, +lm: U32, +la: KDef, +lb: KDef, +right: KDef, +out: KDef) -> KDef:
  match ok:
    case True{}: w5c2_jg_lr(U32.is_eq(U32.and(rh, lm), 0), la, lb, right, out)
    case False{}: out

@unsafe
def w5c2_jnn_gt_sub(ok: Bool, +lh: U32, +rm: U32, +left: KDef, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match ok:
    case True{}: w5c2_jg_lr_r(U32.is_eq(U32.and(lh, rm), 0), left, ra, rb, out)
    case False{}: out

@unsafe
def w5c2_jnn_lt(lt: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match lt:
    case True{}: w5c2_jnn_lt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right, out)
    case False{}: w5c2_jnn_gt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, rm, left, ra, rb, out)

@unsafe
def p113k_join_nn_diff(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c2_jnn_lt(U32.is_lt(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jnn_same_sub(ok: Bool, +la: KDef, +lb: KDef, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match ok:
    case True{}: p113k_join_go(lb, rb, p113k_join_go(la, ra, out))
    case False{}: out

@unsafe
def w5c2_jnn_eq(eq: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match eq:
    case True{}: w5c2_jnn_same_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), la, lb, ra, rb, out)
    case False{}: w5c2_jnn_lt(U32.is_lt(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jnn_z(z: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match z:
    case True{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))
    case False{}: w5c2_jnn_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def p113k_join_nn(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c2_jnn_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jn_abs(is_abs: Bool, +la: KDef, +lb: KDef, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: out
    case False{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))

@unsafe
def p113k_join_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh, _}:
      w5c2_jnn_lt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right, out)
    case KIndexNode{rh, rm, ra, rb}:
      w5c2_jnn_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jn_abs(String.eq(kind, "Absent"), la, lb, right, out)

@unsafe
def p113k_join_go(left,right,out):
  match left:
    case KIndexLeaf{lh,lbucket}: p113k_join_leaf(lh,lbucket,right,out)
    case KIndexNode{lh,lm,la,lb}: p113k_join_node(lh,lm,la,lb,left,right,out)
    case _: out

@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  p113k_join_go(left,right,out)


@unsafe
def p113k_scalar_join(condition: N111Value, yes: P113KScalar, no: P113KScalar) -> P113KScalar:
  match yes no:
    case P113KScalar{yb,yf} P113KScalar{nb,nf}: P113KScalar{[N111If{condition,yb,nb}],p113k_join(yf,nf,missing())}


@unsafe
def w4g_scalar_join_opt(+condition: N111Value, +facts: KDef, +bits: U32, +yes: P113KScalar, +no: P113KScalar) -> P113KScalar:
  match yes no:
    case P113KScalar{Nil{},_} P113KScalar{Nil{},_}:
      P113KScalar{[],facts}
    case P113KScalar{Con{N111Set{+d1,N111U64{},N111Const{+v1,0}},Nil{}},_} P113KScalar{Con{N111Set{+d2,N111U64{},N111Const{+v2,0}},Nil{}},_}:
      nt_choose(P113KScalar,agy_str_eq(d1,d2) && U32.is_le(v1,1) && U32.is_le(v2,1) && U32.is_eq(v1,v2),
        u => P113KScalar{[N111Set{d1,N111U64{},N111Const{v1,0}}],p113k_put(facts,d1,p113k_exact(v1,0))},
        u => p113k_scalar_join(condition,yes,no))
    case _ _: p113k_scalar_join(condition,yes,no)


@unsafe
def p113k_body_join(condition: N111Value, yes: P113KBody, no: P113KBody) -> P113KBody:
  match yes no:
    case P113KBody{yb,+yf,+yt} P113KBody{nb,+nf,+nt}:
      P113KBody{[P113DIf{condition,yb,nb}],
        nt_choose(KDef,yt,u => nf,u => nt_choose(KDef,nt,v => yf,v => p113k_join(yf,nf,missing()))),yt && nt}


@unsafe
def w4g_try_diamond(+condition: N111Value, +facts: KDef, +yes: P113KBody, +no: P113KBody,
    +yb: List<&2,P113DStmt>, +yf: KDef, +nb: List<&2,P113DStmt>, +nf: KDef) -> P113KBody:
  +rel = w4k_cond_subject(facts,condition)
  +ydst = w4g_ic_last_u64_dst(yb)
  +ndst = w4g_ic_last_u64_dst(nb)
  +basic = agy_str_eq(dk(rel),"P113LRelation") && Bool.not(String.is_empty(ydst)) &&
    agy_str_eq(ydst,ndst) && w4g_ic_pure(yb,16) && w4g_ic_pure(nb,16)
  nt_choose(P113KBody,basic,
    u =>
      +subjName = nm(dv(rel))
      +yw = w4g_ic_writes(yb,missing())
      +nw = w4g_ic_writes(nb,missing())
      +yr = w4g_ic_reads(yb,missing())
      +nr = w4g_ic_reads(nb,missing())
      +ok = Bool.not(w4g_ic_has(yr,ydst)) && Bool.not(w4g_ic_has(nr,ydst)) &&
        w4g_ic_nonlast_ok(yb,ydst,subjName,facts,nr,nw) &&
        w4g_ic_nonlast_ok(nb,ydst,subjName,facts,yr,yw)
      nt_choose(P113KBody,ok,
        v =>
          +ynm = ydst ++ "_w4y"
          +nnm = ydst ++ "_w4n"
          +sel : List<&2,P113DStmt> = [
            P113DIf{condition,
              [P113DScalar{N111Set{ydst,N111U64{},N111Local{ynm}}}],
              [P113DScalar{N111Set{ydst,N111U64{},N111Local{nnm}}}]}
          ]
          +merged = nt_append(P113DStmt,w4g_ic_rename_last(yb,ynm),
            nt_append(P113DStmt,w4g_ic_rename_last(nb,nnm),sel))
          +outFacts = p113k_put(p113k_join(yf,nf,missing()),ydst,p113k_join_fact(p113k_get(yf,ydst),p113k_get(nf,ydst)))
          P113KBody{merged,outFacts,False{}},
        v => p113k_body_join(condition,yes,no)),
    u => p113k_body_join(condition,yes,no))


@unsafe
def p113e_base_stmt(stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{+scalar}:
      nt_choose(P111VFlow,p113e_scalar_safe(scalar),
        u => p111v_stmt(scalar,schema,live,ids,arity,0,result),
        u => P111VFlow{live,False{},"scheduler/state/terminal operation in direct scalar block"})
    case P113DIf{+condition,yes,no}:
      nt_choose(P111VFlow,p111v_value(condition,1,live,ids),
        u => p111v_join(p113e_body(yes,schema,P111VFlow{live,False{},""},ids,ready,arity,result),p113e_body(no,schema,P111VFlow{live,False{},""},ids,ready,arity,result)),
        u => P111VFlow{live,False{},"direct condition must be a definitely assigned U32"})
    case P113DCall{destinations,target,args}: p113e_call(destinations,target,args,schema,live,ids,ready)
    case P113DResult{values}: p113e_vector(values,result,live,ids)
    case P113DAgain{values}: p113e_vector(values,arity,live,ids)


@unsafe
def w5c2_p113l_br_rz(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value, +rf: P113KFact) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, left, False{})
    case False{}: w5c2_p113l_br_lz(p113k_zero(p113k_value(left, before)), before, after, name, op, left, right, rf)

@unsafe
def w5c2_p113l_br_oxa(is_oxa: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  match is_oxa:
    case True{}:
      +rf = p113k_value(right, before)
      w5c2_p113l_br_rz(p113k_zero(rf), before, after, name, op, left, right, rf)
    case False{}: w5c2_p113l_br_eqne(String.eq(op, "eq") || String.eq(op, "ne"), before, after, name, op, left, right)

@unsafe
def p113l_bin_relation(+before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  w5c2_p113l_br_oxa(String.eq(op, "or") || String.eq(op, "xor") || String.eq(op, "add"), before, after, name, op, left, right)


@unsafe
def p113l_record(+stmt: N111Stmt, +before: KDef, after: KDef) -> KDef:
  p123p_record(stmt,before,p123p_old_record(stmt,before,after))

@unsafe
def p114h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114HPlan,agy_p124r_known_orig(ready,name),v => p114h_refused(),
          v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),512),
            w => nt_choose(P114HPlan,p112f_clean(body),
              x => nt_choose(P114HPlan,p114h_clean_segment(segment),
                y => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),y => p114h_refused()),
              x => p114h_refused()),w => p114h_refused())),
        u => p114h_refused())

@unsafe
def w4c_bce_analyze_cnt(cntIdx: Maybe<&2,U32>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +used: U32, +sites: KDef, +seed: KDef) -> W4CBCEPlan:
  match cntIdx:
    case Some{+ci}:
      +invMask = w5_fs_inv_mask(params,0,body,seed,0)
      +cntName = w4c_nth_param_name(params,ci)
      +ivMask = w4c_fs_iv_mask(params,0,body,seed,0)
      +pbmMap = p111v_put(w4c_fs_pbm_map(params,0,body,seed,missing()),"__inv__","W5INV",invMask,1)
      w4c_bce_walk(body,0,used,sites,False{},Some{ci},cntName,params,ivMask,pbmMap,seed,missing(),[])
    case None{}:
      +invMask = w5_fs_inv_mask(params,0,body,seed,0)
      +pbmMap = p111v_put(w4c_fs_pbm_map(params,0,body,seed,missing()),"__inv__","W5INV",invMask,1)
      w4c_bce_walk(body,0,used,sites,False{},None{},"",params,0,pbmMap,seed,missing(),[])

@unsafe
def w4c_bce_analyze(+params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +used: U32, +sites: KDef) -> W4CBCEPlan:
  +seed = w4c_env_seed(params,0,missing())
  w4c_bce_analyze_cnt(w4c_fs_find_countdown(params,0,body,seed),params,body,used,sites,seed)



@unsafe
def p118b_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> P118BWorkers:
  p126bp_extend(book,owner,plan,p126bp_original_functions(book,owner,plan))

# New flat observer symbols are a necessary precondition for the extra catalogue
# preparation. All other requests retain the original compose path and work.

@unsafe
def p118c_plan(+request: NR_Request) -> P118CPlan:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      +permission = ns_definitions(book,names)
      p118c_plan_hot(request,source,book,permission,error,
        nt_choose(List<&2,String>,permission && String.is_empty(error),
          u => nh_definitions(book,names,[]),u => ["*"]))


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
  nt_choose(P121FPlan,agy_str_eq(tg(r),"Call") && U32.is_eq(terms_len(ks(r)),2) &&
    agy_str_eq(tg(m),"Call") && U32.is_eq(terms_len(ks(m)),1) &&
    agy_str_eq(tg(f),"Call") && U32.is_eq(terms_len(ks(f)),1) &&
    agy_str_eq(tg(p),"Call") && U32.is_eq(terms_len(ks(p)),2),
    u => p121f_defs(book,vars,params,r,m,f,p,lookup(book,nm(r)),lookup(book,nm(m)),lookup(book,nm(f)),lookup(book,nm(p))),
    u => P121FNone{})


@unsafe
def p121f_prefix(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm,
  +vars: List<&2,KTerm>, +params: List<&2,NC_Binding>, +at: U32, +left: U32) -> P121FPlan:
  +h = j_strip(t)
  +head = wnf(book,ty)
  nt_choose(P121FPlan,U32.is_eq(left,0),
    u => nt_choose(P121FPlan,j_primitive_type(book,head,"U32"),v => p121f_pipeline(book,vars,params,h),v => P121FNone{}),
    u => nt_choose(P121FPlan,agy_str_eq(tg(h),"Lam") && agy_str_eq(tg(head),"All") &&
      Bool.not(U32.is_eq(qt(head),0)) && j_primitive_type(book,wnf(book,kid(head,0)),"U32"),
      v => p121f_prefix(book,kid(h,0),subst(kid(head,1),ix(head),var(nm(h),ix(h))),Con{h,vars},
        nt_append(NC_Binding,params,[NC_Binding{ix(h),"p121_arg_" ++ U32.show(at),N_W32{}}]),U32.inc(at),U32.sub(left,1)),
      v => P121FNone{}))


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
    agy_str_eq(dk(lookup(book,owner)),"ADT") && U32.is_eq(da(lookup(book,owner)),0) &&
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
def w8_p121c_admitted_ok(ok: Bool, +book: List<&2,KDef>, +d: KDef) -> Bool:
  match ok:
    case False{}: False{}
    case True{}:
      +call = j_call_spine(j_fusion_after(dv(d),2),[])
      +count = j_call_spine(kid(call,0),[])
      nt_choose(Bool,agy_str_eq(tg(call),"Call") && U32.is_eq(terms_len(ks(call)),2) &&
        j_fusion_call(count,"U32.to_nat",1),u =>
        p121f_bounded(dv(d)) && p121c_signature(book,dt(d),2) &&
        agy_str_eq(tg(j_fusion_binder(dv(d),0)),"Lam") && agy_str_eq(tg(j_fusion_binder(dv(d),1)),"Lam") &&
        j_primitive_call(book,count) &&
        j_fusion_scalar(book,kid(count,0),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
        j_fusion_scalar(book,kid(call,1),[j_fusion_binder(dv(d),0),j_fusion_binder(dv(d),1)]) &&
        p121f_bounded(dv(lookup(book,nm(call)))) && p121c_factory(book,lookup(book,nm(call))),u => False{})

@unsafe
def p121c_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  w8_p121c_admitted_ok(j_fusion_def(d,2),book,d)


@unsafe
def p123p_old_record(stmt: N111Stmt, before: KDef, after: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: p113l_copy_relation(before,after,name,value,False{})
    case N111Bin{name,typ,op,left,right}: p113l_bin_relation(before,after,name,op,left,right)
    case _: after


@unsafe
def p125p_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  nt_choose(Bool,j_fusion_def(d,2) && p98_tag_eq(j_strip(dv(d)),"Mat"),u =>
    nt_choose(Bool,p121f_bounded(dv(d)),v =>
      p125p_equations(d,nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1)))) &&
      p125p_types(book,d,nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1)))),v => False{}),u => False{})

# Restrict the first prototype to the existing forwarding factory. This makes
# the reserved scratch/result namespace disjoint without trusting source names.

@unsafe
def p125p_select(+book: List<&2,KDef>, +d: KDef, +candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  nt_choose(List<&2,P113DCandidate>,p125p_admitted(book,d),u =>
    p125p_candidates(p113d_public(book,dn(d)),nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1))),candidates),u => candidates)


@unsafe
def p125p_previous_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,p118t_import(symbol),u => p118t_import_call(name,typ,symbol,args,schema,live,ids),u =>
        nt_choose(P111VFlow,agy_str_eq(symbol,"p113_rt_array_pair"),v => p113e_product_call(name,typ,symbol,args,schema,live,ids),
          v => p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)))
    case _: p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)

@unsafe
def p126s_plan(+book: List<&2,KDef>, +d: KDef) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),1) && U32.is_eq(dx(d),0) &&
    Bool.not(db(d) || nc_foreign(d)) && agy_str_eq(tg(j_strip(dv(d))),"Mat"),
    u => p126s_plan_type(book,d,wnf(book,dt(d))),u => None{})

@unsafe
def p126dp_original_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,agy_str_eq(symbol,"p125_rt_concat_typed"),u => p125p_import(name,typ,args,schema,live,ids),
        u => p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result)


@unsafe
def w5c2_p126dp_app(is_app: Bool, +book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  match is_app:
    case True{}: w5c2_p126dp_tup(String.eq(nd_native_call(book, value), "nat_divmod"), book, value, target)
    case False{}: nq_value_shape(book, value, target)

@unsafe
def w5c2_p126dp_nop(is_divmod: Bool, +tag: String, +book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  match is_divmod:
    case True{}: kt("NQShape", "Tuple", 2, 0, [])
    case False{}: w5c2_p126dp_app(String.eq(tag, "App"), book, value, target)

@unsafe
def p126dp_value_shape(+book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  +tag = tg(value)
  w5c2_p126dp_nop(String.eq(tag, "NOp") && String.eq(nm(value), "nat_divmod") && U32.is_eq(terms_len(ks(value)), 2), tag, book, value, target)

@unsafe
def p128bs_find(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{+head,rest}:
      match head:
        case P113DFunction{+name,+params,+result,+public,+body}:
          nt_choose(P118BWorkers,agy_str_eq(name,p113d_public(book,owner)),
            u => nt_choose(P118BWorkers,public && U32.is_eq(result,1) && p128bs_leaf(body) &&
              U32.is_eq(nt_count(NC_Binding,params),nt_count(KTerm,no_schema_params(no_plan_schema(plan)))),
              v => p128bs_functions(book,owner,plan,head),v => P118BWorkers{[],""}),
            u => p128bs_find(book,owner,plan,rest))

# The new guard contract is checked before structural projection. This checks
# the interface, not semantic equivalence; NO + immutable runtime identity are
# the semantic justification, as with the existing readonly field helper.

@unsafe
def p128br_call(+ctx: NO_Context, helper: P128BRHelper, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match helper:
    case P128BRHelper{owner,+params,+roots,+result,reader,+wrapper,+resultId}:
      +id = nc_id(n)
      nt_choose(NO_Analysis,p128br_arguments(ctx,params,roots,args,0) &&
        nol_scalar(noa_book(ctx),kt("ADT",result,0,0,[])) &&
        Bool.not(p131p_parameter(resultId,params)) && p131p_wrapper_ok(wrapper,params,resultId,0),
        u => noa_prepend(kt("NO_Let","",id,0,[kt("NO_ReadCall",reader,0,0,p128br_words(ctx,args,roots,0))]),
          noa_continue(ctx,k,NO_Input{p131p_virtual(wrapper,params,args,resultId,
            noa_atom(result,kt("OUnique","",id,0,[]),var("",id))),facts,U32.inc(n),fuel})),
        u => noa_fail("observer: borrowed helper type, held-origin or result wrapper",n,fuel))

# The schema alone is not authority. Require its successfully lowered private
# reader in the same worker bundle that the existing integration will emit.

@unsafe
def p128br_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, helper: Maybe<&2,P128BRHelper>) -> NO_Analysis:
  match helper:
    case Some{ready}: p131rv_reference(ctx,name,args,facts,stack,n,fuel,k,ready)
    case None{}:
      +d = lookup(noa_book(ctx),name)
      nt_choose(NO_Analysis,agy_str_eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack,name)) && U32.is_lt(nt_count(String,stack),8),
        u => noa_eval(ctx,nc_source_body(noa_book(ctx),d,n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
        u => noa_fail("observer: helper effect, cycle or depth",n,fuel))

@unsafe
def p128br_project_call(+value: KTerm, +env: List<&2,NC_Binding>) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(value),"NO_ReadCall"),
    u => nt_choose(KTerm,no_atoms_valid(ks(value),env) && Bool.not(String.is_empty(nm(value))),
      v => kt("NWord","0",0,0,[]),v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),u => value)


@unsafe
def p128br_project_residual(+t: KTerm, +env: List<&2,NC_Binding>) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(t),"NO_Let") && U32.is_eq(terms_len(ks(t)),2),
    u => k_with_children(t,[p128br_project_call(kid(t,0),env),
      p128br_project_residual(kid(t,1),Con{nc_binding(ix(t)),env})]),
    u => nt_choose(KTerm,agy_str_eq(tg(t),"NO_Match") && U32.is_eq(terms_len(ks(t)),4),
      v => k_with_children(t,[kid(t,0),kid(t,1),
        p128br_project_residual(kid(t,2),no_bind_fields(ks(kid(t,1)),env)),
        p128br_project_residual(kid(t,3),env)]),v => t))


@unsafe
def p128br_find(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, functions: List<&2,P113DFunction>) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{+head,rest}:
      match head:
        case P113DFunction{+name,+params,+result,+public,body}:
          nt_choose(P118BWorkers,agy_str_eq(name,p113d_public(book,owner)),
            u => nt_choose(P118BWorkers,public && U32.is_eq(result,1) &&
              U32.is_eq(nt_count(NC_Binding,params),nt_count(KTerm,no_schema_params(no_plan_schema(plan)))),
              v => p128bs_functions(book,owner,plan,head),v => P118BWorkers{[],""}),
            u => p128br_find(book,owner,plan,rest))


@unsafe
def p131rg_names(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,String>:
  match fields:
    case Nil{}: []
    case Con{+field,rest}:
      Con{nt_choose(String,p131rg_visible(book,field),u => nm(field),u => p131rg_opaque()),
        p131rg_names(book,rest)}


@unsafe
def p131rg_children(+book: List<&2,KDef>, fields: List<&2,KTerm>) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{+field,+rest}:
      nt_choose(List<&2,KTerm>,p131rg_visible(book,field) && Bool.not(nol_scalar(book,field)),
        u => Con{field,p131rg_children(book,rest)},u => p131rg_children(book,rest))


@unsafe
def p131rg_case(+book: List<&2,KDef>, +ty: KTerm, +ctor: KDef, +fields: KTerm) -> P128BLNode:
  +width = terms_len(ks(fields))
  +key = nc_ctor_identity(book,dn(ctor))
  nt_choose(P128BLNode,agy_str_eq(tg(fields),"NO_Types") && U32.is_eq(width,da(ctor)) && p131rg_width(width),
    u => P128BLNode{[NO_Spec{NO_Layout{key,key,
      nt_choose(String,U32.is_eq(width,0),v => "Nullary",v => "Boxed"),width},nm(ty),p131rg_names(book,ks(fields))}],
      p131rg_children(book,ks(fields)),""},
    u => P128BLNode{[],[],"shallow observer: unsupported constructor fields/width"})


@unsafe
def p131rg_ctors(+book: List<&2,KDef>, +ty: KTerm, ctors: List<&2,KDef>, +fuel: U32) -> P128BLNode:
  match ctors:
    case Nil{}: P128BLNode{[],[],""}
    case Con{+ctor,+rest}:
      nt_choose(P128BLNode,U32.is_eq(fuel,0),u => P128BLNode{[],[],"shallow observer: constructor budget"},
        u => p131rg_join(p131rg_case(book,ty,ctor,nol_ctor_fields(book,ty,ctor)),
          p131rg_ctors(book,ty,rest,U32.sub(fuel,1))))


@unsafe
def p131rg_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  nt_choose(P128BLNode,p131rg_symbol_available(book) && nol_plain(ty) && nol_owner(book,ty) &&
    Bool.not(db(owner)) && Bool.not(List.is_empty(&2,KDef,dc(owner))),
    u => p131rg_ctors(book,ty,dc(owner),8),
    u => P128BLNode{[],[],"shallow observer: nonplain/native/unknown owner"})


@unsafe
def p131rg_fallback(+book: List<&2,KDef>, +ty: KTerm, +original: P128BLNode) -> P128BLNode:
  match original:
    case P128BLNode{specs,children,+error}:
      nt_choose(P128BLNode,String.is_empty(error),u => original,u => p131rg_node(book,ty))

@unsafe
def p131rv_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, +helper: P128BRHelper) -> NO_Analysis:
  match helper:
    case P128BRHelper{owner,+params,+roots,result,reader,wrapper,resultId}:
      nt_choose(NO_Analysis,p128br_arguments(ctx,params,roots,args,0),
        u => p128br_call(ctx,helper,args,facts,n,fuel,k),
        u => nt_choose(NO_Analysis,p131rv_arguments(ctx,params,roots,args,0,False{}) && U32.is_lt(nt_count(String,stack),16),
          v => noa_eval(ctx,nc_source_body(noa_book(ctx),lookup(noa_book(ctx),name),n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
          v => p128br_call(ctx,helper,args,facts,n,fuel,k)))


@unsafe
def p140or_finish(+source: List<&2,KDef>, +names: List<&2,String>, +ctors: List<&2,N_Constructor>, compiled: P111Book) -> P111Result:
  match compiled:
    case P111Book{+segments,+fresh,+error}:
      +ty = dt(lookup(source,"main"))
      +pure = Bool.not(nc_is_io(source,ty))
      nt_choose(P111Result,agy_str_eq(error,""),
        u => p111_finish_show(segments,ctors,p111_effects(source,names),pure,
          nt_choose(P111Show,pure,u => p111_show(source,ty,ctors),u => P111Show{[0],[],""})),
        u => P111Result{p111_empty(),error})


law p142j_visit_set:
  for +book: List<&2,KDef>
  for +defs: List<&2,KDef>
  for todo: List<&2,String>
  for +seen: KDef
  for +stops: KDef
  Bool

@unsafe
def p142j_checked_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> String:
  kc(String,p142j_visit_set(book_context(book),book_cached(defs,0),roots,missing(),p142j_members(stops,missing())),
    u => "an open Array element type",u => "")


@unsafe
def p142j_def_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +d: KDef, +todo: List<&2,String>, +seen: KDef, +stops: KDef) -> Bool:
  p142j_visit_set(book,defs,w7b_p142j_def_if(p88_string_eq(dk(d),"Def") && U32.is_eq(dx(d),0),book,d,todo),seen,stops)

@unsafe
def w7b_p142j_name_if(skip: Bool, +book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef, +hash: U32) -> Bool:
  match skip:
    case True{}: p142j_visit_set(book,defs,rest,seen,stops)
    case False{}: p142j_def_set(book,defs,lookup(defs,name),rest,p142j_mark(seen,name,hash),stops)

@unsafe
def p142j_name_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef, +hash: U32) -> Bool:
  w7b_p142j_name_if(p142j_member(seen,name,hash) || p142j_member(stops,name,hash),book,defs,name,rest,seen,stops,hash)

@unsafe
def w7b_p142j_visit_if(isOpen: Bool, +book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef) -> Bool:
  match isOpen:
    case True{}: True{}
    case False{}: p142j_name_set(book,defs,name,rest,seen,stops,index_hash(name,2166136261))

@unsafe
def p142j_visit_set(book, defs, todo, seen, stops):
  match todo:
    case Nil{}: False{}
    case Con{+name,+rest}:
      w7b_p142j_visit_if(p88_string_eq(name,"$layout.open-array"),book,defs,name,rest,seen,stops)


@unsafe
def w7_br_978(w7_c: Bool, +definition: KDef, +result: KChecking, +logging: Bool) -> KWorld:
  match w7_c:
    case True{}:
      kw_put_checked(kw_with_book(rw(result),p143cp_put(kw_book(rw(result)),definition,logging)), dg_event_output(definition,ct(result)))
    case False{}:
      rw(result)

@unsafe
def p143cp_publish(+definition: KDef, next: KDef, +result: KChecking, logging: Bool) -> KWorld:
  w7_br_978(p88_string_eq(dk(next),"Absent"), definition, result, logging)

# Source events are normal KDefs, not implementation cache/index records. This
# also keeps initial materialization semantics explicit for arbitrary API tests.

@unsafe
def w7c_declare_cached(+todo: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match done:
    case Nil{}: check_declarations(todo, done)
    case Con{cache, rows}:
      w7c_declare_head(p88_string_eq(dk(cache), "BookCache"), todo, cache, rows, done)

@unsafe
def p144o_source_ready(+source: List<&2,KDef>, bound: U32, facts: P144OFacts) -> NR_Request:
  +view = p144o_view(source,facts)
  p144o_request(source,view,nr_walk(view,["main"],[],[]),Some{bound})


@unsafe
def p144o_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  +merged = nc_context_defs(book,nc_context_index(annotated))
  +bound = norm_max_book(merged)
  +source = book_cached(merged,bound)
  p144o_source_ready(source,bound,p144o_build(source))

@unsafe
def p167l_catalogue(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>,
    +ready: KDef, catalogue: P167Catalogue) -> P167Catalogue:
  match names:
    case Nil{}: catalogue
    case Con{+name,rest}:
      p167l_catalogue(book,rest,bangs,ready,
        p167l_catalogue_name(book,name,bangs,ready,catalogue))



@unsafe
def p167l_catalogue_name(+book: List<&2,KDef>, +name: String, +bangs: List<&2,String>,
    +ready: KDef, +catalogue: P167Catalogue) -> P167Catalogue:
  +arity = nd_arity(book,name)
  +allowed = p164a_allowed(book,name,bangs,ready)
  +worker = p167l_catalogue_put(p113d_public(book,name),name,"P167Worker",arity,allowed,catalogue)
  nt_choose(P167Catalogue,U32.is_eq(arity,0),u => worker,
    u => p167l_catalogue_put(nc_ref_name(book,name),name,"P167Factory",arity,allowed,worker))



# Exactly the original source factory branch, without p111_extend. Its real
# continuations are retained. No dummy base is passed to any checker or emitter.
@unsafe
def p167l_finish(+source: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, built: P167Built) -> P167Lowered:
  match built:
    case P167Built{+segments,present,adapters,fresh,families,factories,wrappers,demands,+error}:
      +ordered = nt_reverse(N111Segment,segments,[])
      +pruned = nt_choose(List<&2,N111Segment>,String.is_empty(error),
        u => w6_dedup_segments(ordered),
        u => ordered)
      p167l_finished(nodes,functions,adapters,
        [nt_count(String,names),nt_count(P113DFunction,functions),families,factories,wrappers,nt_count(N111Segment,pruned),demands],
        p140or_finish(source,names,constructors,P111Book{pruned,fresh,error}))



@unsafe
def p167v_obligation(+entry: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> Bool:
  +owner = dn(entry)
  +source = nm(dt(entry))
  +header = p111v_get(headers,owner)
  agy_str_eq(dk(entry),"P164Adapter") && agy_str_eq(tg(dt(entry)),"Ref") &&
    agy_str_eq(owner,p113d_public(book,source)) && U32.is_eq(da(entry),nd_arity(book,source)) &&
    p167v_allowed(book,source,bangs,ready) && agy_str_eq(dk(header),"function") &&
    U32.is_eq(da(header),da(entry)) && U32.is_eq(dx(header),0)



@unsafe
def p167v_bucket(entries: List<&2,KDef>, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match entries:
    case Nil{}: ""
    case Con{+head,rest}:
      nt_choose(String,p167v_obligation(head,book,bangs,headers,ready),
        u => p167v_bucket(rest,book,bangs,headers,ready),
        u => "demand adapter source/header/final-worker obligation: " ++ dn(head))



@unsafe
def p167v_obligations(tree: KDef, +book: List<&2,KDef>, +bangs: List<&2,String>, +headers: KDef, +ready: KDef) -> String:
  match tree:
    case KIndexLeaf{hash,bucket}: p167v_bucket(bucket,book,bangs,headers,ready)
    case KIndexNode{hash,mask,left,right}:
      p111_first(p167v_obligations(left,book,bangs,headers,ready),p167v_obligations(right,book,bangs,headers,ready))
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      nt_choose(String,agy_str_eq(kind,"Absent"),u => "",u => "demand invalid adapter map")



@unsafe
def p167ob_permission(+request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      nt_choose(Bool,ns_definitions(book,names),u => True{},u => p118i_permission(request))



# Private early checking claims no scheduler ABI. Real constructors are checked
# independently; empty FIDs reject any seed needing an unmaterialized identity.
# Source-derived owning wrappers keep their original public marker only while
# selecting exact source/arity substitutions; every final function is private.
@unsafe
def p167ob_remaining(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +ready: KDef) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      nt_choose(List<&2,String>,p164a_allowed(book,name,bangs,ready),
        u => p167ob_remaining(book,rest,bangs,ready),
        u => Con{name,p167ob_remaining(book,rest,bangs,ready)})



# Keep actual generic/static/adapter admission, then use the maintained borrowed
# projection checker on ALL actual final private workers and actual final IDs.
# Projection does not establish source lifetime permission; p167ob_request does.
law w7c_p112c_pass:
  for segments: List<&2,P112MultiCandidate>
  for +index: P112FusionIndex
  for +old: KDef
  for +symbols: KDef
  for +rank: U32
  for +next: P112RegionRegistry
  for +waiting: List<&2,P112MultiCandidate>
  for +added: U32
  W7C112CPass

@unsafe
def w7c_p112c_pass_next(rest: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32,
    step: W7C112CPass) -> W7C112CPass:
  match step:
    case W7C112CPass{next2,waiting2,added2}:
      w7c_p112c_pass(rest,index,old,symbols,rank,next2,waiting2,added2)

@unsafe
def w7c_p112c_pass(segments, index, old, symbols, rank, next, waiting, added):
  match segments:
    case Nil{}: W7C112CPass{next,nt_reverse(P112MultiCandidate,waiting,[]),added}
    case Con{+cand,+rest}:
      match cand:
        case P112MultiCandidate{+segment}:
          match segment:
            case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
              w7c_p112c_pass_next(rest,index,old,symbols,rank,
                w7c_p112c_fused(cand,segment,old,symbols,rank,next,waiting,added,p112c_scan(body,index,old,0)))

law w7c_p112c_passes:
  for +segments: List<&2,P112MultiCandidate>
  for +index: P112FusionIndex
  for +registry: P112RegionRegistry
  for +rank: U32
  for +left: U32
  P112RegionRegistry

@unsafe
def w7c_p112c_cont(+index: P112FusionIndex, +rank: U32, +left: U32, pass: W7C112CPass) -> P112RegionRegistry:
  match pass:
    case W7C112CPass{+reg,+waiting,+added}:
      nt_choose(P112RegionRegistry,U32.is_eq(added,0) || List.is_empty(&2,P112MultiCandidate,waiting),
        u => reg,u => w7c_p112c_passes(waiting,index,reg,U32.inc(rank),U32.sub(left,1)))

@unsafe
def w7c_p112c_round(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      w7c_p112c_cont(index,rank,left,w7c_p112c_pass(segments,index,ready,symbols,rank,registry,[],0))

@unsafe
def w7c_p112c_passes(segments, index, registry, rank, left):
  nt_choose(P112RegionRegistry,U32.is_eq(left,0) || List.is_empty(&2,P112MultiCandidate,segments),
    u => registry,u => w7c_p112c_round(segments,index,registry,rank,left))

@unsafe
def p168j_registry(segments: List<&2,N111Segment>, +index: P112FusionIndex,
    +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      w7c_p112c_passes(p168j_candidates(segments,ready,[]),index,registry,1,6)



@unsafe
def p169q_scalars(+book: List<&2,KDef>, plans: List<&2,P169ScalarPlan>,
    +original: List<&2,P113DFunction>, functions: List<&2,P113DFunction>,
    helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match plans:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),
      nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{P169ScalarPlan{+plan,eligible},rest}:
      p169q_scalar_ready(book,rest,original,functions,helpers,retry,plan,
        nt_choose(P118BWorkers,eligible,
          u => p128bs_find(book,no_plan_owner(plan),plan,original),u => P118BWorkers{[],""}))



@unsafe
def p169q_scalar_ready(+book: List<&2,KDef>, +rest: List<&2,P169ScalarPlan>,
    +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>,
    +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +plan: NO_Plan, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p169q_scalars(book,rest,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})



law w4c_zip_owners_map:
  for +book: List<&2,KDef>
  KDef

@unsafe
def p169c_selected(+request: NR_Request, +admitted: P113AProgram) -> P113AProgram:
  match admitted:
    case P113AProgram{program,certificate}:
      nt_choose(P113AProgram,p169c_scalar(certificate),
        u => p118c_apply_plan(admitted,p118c_plan(request)),u => admitted)



@unsafe
def p171sc_analyzed(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    catalogue: Maybe<&2,List<&2,NO_Spec>>, +schema: NO_Schema) -> P171SCPlan:
  P171SCPlan{no_plan_result(owner,schema,noa_analyze_ready(NO_Context{book,owner,schema,helpers})),catalogue}

@unsafe
def p171sc_cached(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    local: NO_Schema, +specs: List<&2,NO_Spec>) -> P171SCPlan:
  p171sc_analyzed(book,owner,helpers,Some{specs},p171sc_attach(local,specs))

@unsafe
def p171sc_catalogue(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    +local: NO_Schema, catalogue: Maybe<&2,List<&2,NO_Spec>>) -> P171SCPlan:
  match catalogue:
    case None{}: p171sc_cached(book,owner,helpers,local,nol_scalar_specs(book,book))
    case Some{specs}: p171sc_cached(book,owner,helpers,local,specs)

law x181_scalar:
  for +stmt: N111Stmt
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code
law x181_stmts:
  for +body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code
law x185_transient_frame:
  for +frame: X181Frame
  for +params: List<&2,String>
  for +setup: List<&2,P113DStmt>
  for +body: List<&2,P113DStmt>
  X181Frame

@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ args code:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && agy_str_eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_reuse_text(name,n,args,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U64{},rval},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967292),
        u => X181Code{Con{agy_rt_ctor_reuse_text(name,n,args,agy_ctor_cid(ctor,ids),ids,frame,next),chunks},U32.add(next,3),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_arity(symbol)
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          agy_str_eq(state,"state") && U32.is_le(next,4294967279),
        u => X181Code{Con{agy_rt_take_text(name,symbol,args,n,ids,frame,next),chunks},U32.add(next,16),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_str_eq(symbol,"p111_rt_ctor") && agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => X181Code{Con{x188_many([
          x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256))},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),chunks},next,terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},a},Con{N111Arg{N111U64{},b},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_str_eq(symbol,"p118_rt_borrow_scalar_safe") && agy_str_eq(state,"state") &&
          (U32.is_eq(cnt,1) || U32.is_eq(cnt,2)) && U32.is_le(next,4294967289),
        u => X181Code{Con{agy_rt_borrow_safe_text(name,cnt,args,ids,frame,next),chunks},U32.add(next,6),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Nil{}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_str_eq(symbol,"p111_rt_sink") &&
          agy_str_eq(state,"state") && U32.is_le(next,4294967291),
        u => X181Code{Con{agy_rt_sink_skip_text(name,args,ids,frame,next),chunks},U32.add(next,4),terminal,error},
        u => nt_choose(X181Code,agy_str_eq(symbol,"p111_rt_keep") &&
          agy_str_eq(state,"state") && U32.is_le(next,4294967291),
        v => X181Code{Con{agy_rt_keep_fast_text(name,args,ids,frame,next),chunks},U32.add(next,4),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))
    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)

@unsafe
def x185_float_call(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  agy_rt_inline_try(name,typ,symbol,args,ids,frame,code)
# Ordinary argument loads have no scratch side effects: each reads a home or
# materializes one constant/ID/address into its destination. Callee/stack/buffer
# homes are disjoint from ABI argument registers. Custom transient-source calls
# instead snapshot every value before writing any ABI register or stack arg.
# The maintained frame reserves 16 bytes per argument. Its upper half holds
# snapshots; the lower half holds outgoing stack arguments. Both are below all
# rbp-relative locals. No new allocation, spill or call ABI is introduced.

@unsafe
def x181_scalar(stmt,ids,frame,code):
  match stmt:
    case N111Set{name,typ,value}:
      x181_add(x186_set_text(name,typ,value,ids,frame),code)
    case N111Bin{name,typ,op,left,right}:
      x181_binary(name,typ,op,left,right,ids,frame,code)
    case N111Call{name,typ,symbol,args}:
      x185_float_call(name,typ,symbol,args,ids,frame,code)
    case N111If{condition,yes,no}:
      x181_stmts([P113DIf{condition,x181_scalar_rows(yes),x181_scalar_rows(no)}],ids,frame,code)
    case N111Return{value}:
      x181_return(x181_load(value,ids,frame,x188_reg(0,64)),frame,code)
    case N111Load{name,typ,base,offset}:
      x181_add(x186_load_text(name,typ,base,offset,ids,frame),code)
    case N111Store{typ,base,offset,value}:
      x181_add(x190_store_memory(typ,base,offset,value,ids,frame),code)
    case N111Offset{name,base,bytes}:
      x181_binary(name,N111Ptr{},"add",base,bytes,ids,frame,code)
    case N111Alloca{name,bytes,align}: code
# Optional placement after x181_frame, before emitting either prologue or body.
# Input is a fresh stack frame: register 0 is state, registers 1..4 are unused.
# Every chosen name keeps one global callee-saved home; there is no liveness,
# register sharing, stack compaction, or change to call/tail staging.
law x181_reads_stmts:
  for body: List<&2,P113DStmt>
  for counts: X181ReadCounts
  X181ReadCounts

@unsafe
def x181_reads_stmt(stmt: P113DStmt, counts: X181ReadCounts) -> X181ReadCounts:
  match stmt:
    case P113DScalar{scalar}: x181_reads_scalar(scalar,counts)
    case P113DIf{condition,yes,no}:
      x181_reads_stmts(no,x181_reads_stmts(yes,x181_reads_value(condition,counts)))
    case P113DCall{destinations,target,args}: x181_reads_values(args,counts)
    case P113DResult{values}: x181_reads_values(values,counts)
    case P113DAgain{values}: x181_reads_values(values,counts)

@unsafe
def x181_reads_stmts(body,counts):
  match body:
    case Nil{}: counts
    case Con{head,rest}: x181_reads_stmts(rest,x181_reads_stmt(head,counts))

# A score of two is the empty choice: only three-or-more reads can replace it.
# Strict comparison leaves the earlier encountered name in place on ties.
@unsafe
def x190_register_frame(+frame: X181Frame, +body: List<&2,P113DStmt>, +policy: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_ge(policy,1) && U32.is_le(policy,2) && x190_register_loop(body),
    u => x190_register_counted(frame,x181_reads_stmts(body,X181ReadCounts{missing(),[]}),
      nt_choose(KDef,U32.is_eq(policy,2),v => x185_copy_writes(body,missing()),v => missing()),policy),
    u => x181_register_counted(frame,x181_reads_stmts(body,X181ReadCounts{missing(),[]})))

@unsafe
def x181_register_frame(frame: X181Frame, body: List<&2,P113DStmt>) -> X181Frame:
  x190_register_frame(frame,body,x190_register_policy())

# Whole-body stable copies. Parameters count as definitions, so a parameter
# source is stable only with zero explicit assignments. Every branch and call
# result contributes; two writes saturate the counter and forbid an alias.
# Setup is counted but never rewritten: its entry snapshots must survive Again.
law x185_t_body:
  for body: List<&2,P113DStmt>
  for scan: X185TScan
  X185TScan

@unsafe
def x185_t_reads(values: List<&2,N111Value>, scan: X185TScan) -> X185TScan:
  match values:
    case Nil{}: scan
    case Con{head,rest}: x185_t_reads(rest,x185_t_read(head,scan))

@unsafe
def w4c_t_if_sel_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +a: String, +ta: N111Type, +va: N111Value, na: W4CSelArm, +scan: X185TScan) -> X185TScan:
  match na:
    case W4CSelArm{+b,+tb,+vb}:
      nt_choose(X185TScan,
        w4c_sel_val(condition) && agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          w4c_sel_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          w4c_sel_val(va) && w4c_sel_val(vb),
        u => x185_t_next(x185_t_event(a,True{},x185_t_read(vb,x185_t_read(va,x185_t_read(condition,scan))))),
        u => x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan)))))))
    case W4CSelArmNone{}:
      x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan))))))

@unsafe
def w4c_t_if_sel(condition: N111Value, yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    ya: W4CSelArm, scan: X185TScan) -> X185TScan:
  match ya:
    case W4CSelArm{a,ta,va}: w4c_t_if_sel_no(condition,yes,no,a,ta,va,w4c_sel_arm(no),scan)
    case W4CSelArmNone{}:
      x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan))))))

@unsafe
def x185_t_if(condition: N111Value, +yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, scan: X185TScan) -> X185TScan:
  w4c_t_if_sel(condition,yes,no,w4c_sel_arm(yes),scan)

# The shared F32 expansion only clobbers reserved selector temporaries. Its
# buffer is read before the destination write at this same inclusive endpoint;
# ordinary calls still exclude all arguments/results and cut the region.
@unsafe
def x186_t_inline_call(name: String, args: List<&2,N111Arg>, scan: X185TScan, operation: X186InlineOp) -> X185TScan:
  match operation:
    case X186InlineNone{}: x185_t_cut(x185_t_forbid(name,x185_t_forbid_args(args,scan)))
    case X186InlineF32{destination,id,buffer}:
      x185_t_next(x185_t_event(destination,True{},x185_t_read(N111Local{buffer},scan)))

@unsafe
def x185_t_scalar(stmt: N111Stmt, scan: X185TScan) -> X185TScan:
  match stmt:
    case N111Set{name,typ,value}: x185_t_next(x185_t_event(name,True{},x185_t_read(value,scan)))
    case N111Bin{name,typ,op,left,right}:
      x185_t_next(x185_t_event(name,True{},x185_t_read(right,x185_t_read(left,scan))))
    case N111Load{name,typ,base,offset}: x185_t_next(x185_t_event(name,True{},x185_t_read(base,scan)))
    case N111Store{typ,base,offset,value}: x185_t_next(x185_t_read(value,x185_t_read(base,scan)))
    case N111Offset{name,base,bytes}:
      x185_t_next(x185_t_event(name,True{},x185_t_read(bytes,x185_t_read(base,scan))))
    case N111Alloca{name,bytes,align}: x185_t_next(x185_t_forbid(name,scan))
    case N111Call{+name,typ,symbol,+args}:
      x186_t_inline_call(name,args,scan,x186_inline_op(N111Call{name,typ,symbol,args}))
    case N111If{condition,yes,no}: x185_t_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),scan)
    case N111Return{value}: x185_t_cut(x185_t_read(value,scan))

@unsafe
def x185_t_stmt(stmt: P113DStmt, scan: X185TScan) -> X185TScan:
  match stmt:
    case P113DScalar{scalar}: x185_t_scalar(scalar,scan)
    case P113DIf{condition,yes,no}: x185_t_if(condition,yes,no,scan)
    case P113DCall{names,target,args}: x185_t_cut(x185_t_forbid_names(names,x185_t_forbid_values(args,scan)))
    case P113DResult{values}: x185_t_cut(x185_t_reads(values,scan))
    case P113DAgain{values}: x185_t_cut(x185_t_reads(values,scan))

@unsafe
def x185_t_body(body,scan):
  match body:
    case Nil{}: scan
    case Con{head,rest}: x185_t_body(rest,x185_t_stmt(head,scan))

# First definition encounter order is interval-start order. The fixed five
# endpoint slots give constant work per candidate; full pressure keeps Stack.
@unsafe
def x185_transient_frame(frame,params,setup,body):
  nt_choose(X181Frame,x185_transient_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),
    u => x185_t_scanned(frame,x185_t_body(body,
      X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0})),u => frame)
# Backward word liveness after existing facts. Only pure Set/Bin/Offset rows
# may disappear. Loads, calls, stores, allocas and control flow stay ordered.
# Setup is untouched; every setup-defined name remains live across Again.
@unsafe
def x186_private_body(params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x186_private_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x186_m_body(body,x186_m_scan(body,x186_m_scan(setup,X186Memory{
      x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,
        p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),missing(),missing()}))),u => body)
# Acyclic full-word parallel assignment on Again edges. Scheduling is by actual
# frame home, never spelling. Self moves disappear; a destination is written
# only after every pending read of that home has been consumed. Any cycle or
# malformed/big vector refuses the whole plan and retains the snapshot path.
@unsafe
def x186_e_set(+stmt: N111Stmt, +name: String, +typ: N111Type, +value: N111Value, +state: X186ExprState) -> X186ExprStep:
  nt_choose(X186ExprStep,U32.is_eq(p111v_type(typ),1),
    u => x186_e_expression(state,stmt,name,2,N111U32{},"zext32",value,N111Const{0,0}),
    u => x186_e_set_state(state,stmt,name,typ,value))

@unsafe
def x186_e_expression(+state: X186ExprState, stmt: N111Stmt, +name: String, +kind: U32,
    +typ: N111Type, +op: String, left: N111Value, right: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      x186_e_key(stmt,name,kind,typ,op,x186_e_value_t(left,at),x186_e_value_t(right,at),ft,x186_e_written(state,name))

@unsafe
def x186_e_scalar(+stmt: N111Stmt, +state: X186ExprState) -> X186ExprStep:
  match stmt:
    case N111Set{name,typ,value}: x186_e_set(stmt,name,typ,value,state)
    case N111Bin{name,typ,op,left,right}: x186_e_expression(state,stmt,name,0,typ,op,left,right)
    case N111Offset{name,base,bytes}: x186_e_expression(state,stmt,name,1,N111Ptr{},"offset",base,bytes)
    case N111Load{name,typ,base,offset}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case N111Alloca{name,bytes,align}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case _: X186ExprStep{P113DScalar{stmt},x186_e_empty()}

law x186_e_body:
  for body: List<&2,P113DStmt>
  for state: X186ExprState
  List<&2,P113DStmt>

@unsafe
def x186_e_after(rest: List<&2,P113DStmt>, step: X186ExprStep) -> List<&2,P113DStmt>:
  match step:
    case X186ExprStep{stmt,state}: Con{stmt,x186_e_body(rest,state)}

@unsafe
def w4c_e_if_sel_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +a: String, +ta: N111Type, +va: N111Value, na: W4CSelArm,
    +rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  match na:
    case W4CSelArm{+b,+tb,+vb}:
      nt_choose(List<&2,P113DStmt>,
        w4c_sel_val(condition) && agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          w4c_sel_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          w4c_sel_val(va) && w4c_sel_val(vb),
        u => Con{P113DIf{condition,yes,no},
          x186_e_body(rest,w4c_e_kill_cond(condition,x186_e_written(state,a)))},
        u => Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())})
    case W4CSelArmNone{}:
      Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())}

@unsafe
def w4c_e_if_sel(condition: N111Value, yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    ya: W4CSelArm, rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  match ya:
    case W4CSelArm{a,ta,va}: w4c_e_if_sel_no(condition,yes,no,a,ta,va,w4c_sel_arm(no),rest,state)
    case W4CSelArmNone{}:
      Con{P113DIf{condition,x186_e_body(yes,state),x186_e_body(no,state)},x186_e_body(rest,x186_e_empty())}

@unsafe
def x186_e_if(condition: N111Value, +yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +state: X186ExprState) -> List<&2,P113DStmt>:
  w4c_e_if_sel(condition,yes,no,w4c_sel_arm(yes),rest,state)

@unsafe
def x186_e_body(body,state):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x186_e_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,state)
    case Con{P113DIf{condition,yes,no},rest}: x186_e_if(condition,yes,no,rest,state)
    case Con{P113DScalar{stmt},rest}: x186_e_after(rest,x186_e_scalar(stmt,state))
    case Con{head,rest}: Con{head,x186_e_body(rest,x186_e_empty())}

# General post-p111v pure scalar diamond hoisting to branchless cmov selects.
law w4c_dia_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +terminal: KDef
  for +seq: U32
  W4CDiaRes

@unsafe
def w4c_dia_if_yes(+cond: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +afterLive: KDef, +again: KDef, +terminal: KDef, yes: W4CDiaRes) -> W4CDiaRes:
  match yes:
    case W4CDiaRes{yb,yl,+seq1}:
      w4c_dia_if_done(cond,rest,afterLive,W4CDiaRes{yb,yl,seq1},w4c_dia_body(no,afterLive,again,terminal,seq1))

@unsafe
def w4c_dia_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match after:
    case W4CDiaRes{rest,+live,+seq0}:
      w4c_dia_if_yes(cond,no,rest,live,again,terminal,w4c_dia_body(yes,live,again,terminal,seq0))

@unsafe
def w4c_dia_scalar_go(+stmt: N111Stmt, rest: List<&2,P113DStmt>, live: KDef, +seq: U32, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match stmt:
    case N111Set{name,_,value}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(value,x185_d_kill(live,name)),seq}
    case N111Bin{name,_,_,l,r}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(r,x185_d_value(l,x185_d_kill(live,name))),seq}
    case N111Offset{name,b,by}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(by,x185_d_value(b,x185_d_kill(live,name))),seq}
    case N111Call{name,_,_,args}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_args(args,x185_d_kill(live,name)),seq}
    case N111Load{name,_,b,_}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(b,x185_d_kill(live,name)),seq}
    case N111Store{_,b,_,v}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(v,x185_d_value(b,live)),seq}
    case N111Alloca{name,_,_}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_kill(live,name),seq}
    case N111If{cond,yes,no}: w4c_dia_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),W4CDiaRes{rest,live,seq},again,terminal)
    case N111Return{v}: W4CDiaRes{Con{P113DScalar{stmt},rest},x185_d_value(v,terminal),seq}

@unsafe
def w5_dia_scalar_other(stmt: N111Stmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match after:
    case W4CDiaRes{rest,live,seq}: w4c_dia_scalar_go(stmt,rest,live,seq,again,terminal)

@unsafe
def w4c_dia_scalar(stmt: N111Stmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match stmt:
    case N111If{cond,yes,no}: w4c_dia_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),after,again,terminal)
    case _: w5_dia_scalar_other(stmt,after,again,terminal)

@unsafe
def w4c_dia_stmt(+stmt: P113DStmt, after: W4CDiaRes, +again: KDef, +terminal: KDef) -> W4CDiaRes:
  match stmt:
    case P113DScalar{sc}: w4c_dia_scalar(sc,after,again,terminal)
    case P113DIf{cond,yes,no}: w4c_dia_if(cond,yes,no,after,again,terminal)
    case P113DCall{names,_,args}:
      match after:
        case W4CDiaRes{rest,live,seq}: W4CDiaRes{Con{stmt,rest},x185_d_values(args,x185_d_kills(names,live)),seq}
    case P113DResult{vals}:
      match after:
        case W4CDiaRes{rest,_,seq}: W4CDiaRes{Con{stmt,rest},x185_d_values(vals,terminal),seq}
    case P113DAgain{vals}:
      match after:
        case W4CDiaRes{rest,_,seq}: W4CDiaRes{Con{stmt,rest},x185_d_values(vals,again),seq}

@unsafe
def w4c_dia_body(body,live,again,terminal,seq):
  match body:
    case Nil{}: W4CDiaRes{[],live,seq}
    case Con{h,rest}: w4c_dia_stmt(h,w4c_dia_body(rest,live,again,terminal,seq),again,terminal)

@unsafe
def w4c_diamond_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +base = x185_d_base()
  +again = x185_d_union(x185_copy_writes(setup,missing()),base)
  w4c_dia_out(w4c_dia_body(w5_elim_nat_fail(body),base,again,base,0))

# General adjacent self-update splitter before CSE:
# When `x = pure_bin(l1, r1)` is immediately followed by `x = bin(l2, r2)` (same `x`),
# rename the first def to a fresh local `xs` and substitute `x -> xs` in `l2, r2`.
# This exposes both expressions to `x186_e_body` CSE without changing semantics.
@unsafe
def x186_expression_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x186_expression_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),
    u => x186_e_body(w4c_su_body(w4c_diamond_body(setup,body),0),x186_e_empty()),u => body)

# Optional local word facts. Original snapshots remain until the existing
# backward dead-write pass proves them unused. Aliases are flattened on insert;
# every write kills both its own alias and aliases of the overwritten source.
@unsafe
def x190_local_values_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x190_local_values_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),2048),
    u => x190_v_body(body,x190_v_empty()),u => body)
# A private final-emission plan. The checked source IR remains P113DStmt;
# these nodes never enter the source verifier or integer value optimizers.
# Exact current scratch facts discharge the two memory reads of an admitted
# F32 operation. All other operations keep their original statement.
@unsafe
def x186_f_read_scan(params: List<&2,String>, +setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> X186Memory:
  +reads = x186_f_proven_read_footprints(nodes)
  x186_m_scan(reads,x186_m_scan(setup,X186Memory{x186_f_buffers(params,setup,reads),missing(),missing()}))

@unsafe
def x186_f_ready(params: List<&2,String>, setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  nt_choose(List<&2,X186FloatNode>,x186_private_enabled(),u => x186_f_prune(nodes,x186_f_read_scan(params,setup,nodes)),u => nodes)

law x186_f_emit_nodes:
  for nodes: List<&2,X186FloatNode>
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code

@unsafe
def x186_f_emit_if(condition: N111Value, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x186_f_emit_yes(next,no,ids,frame,x186_f_emit_nodes(yes,ids,frame,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))

@unsafe
def x186_f_emit_yes(+label: U32, no: List<&2,X186FloatNode>, ids: N111Ids,
    +frame: X181Frame, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x186_f_emit_nodes(no,ids,frame,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x186_f_emit_node(node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match node:
    case X186FloatPlain{stmt}: x181_stmt(stmt,ids,frame,code)
    case X186FloatBranch{condition,yes,no}: x186_f_emit_if(condition,yes,no,ids,frame,code)
    case X186FloatValues{+destination,+id,+left,+right}:
      nt_choose(X181Code,U32.is_eq(id,36),u => x200r_sqrt_emit(destination,left,ids,frame,missing(),code),
        u => x181_add(x186_f_values_text(destination,id,left,right,ids,frame),code))
@unsafe
def x186_f_emit_nodes(nodes,ids,frame,code):
  match nodes code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 float plan statement after terminal",code),
          u => x186_f_emit_nodes(rest,ids,frame,x186_f_emit_node(head,ids,frame,code))),u => code)

# The frame is derived only from placement metadata. Emission receives the
# distinct private nodes, never those metadata rows.
@unsafe
def x186_f_emit_frame(+symbol: String, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x186_f_emit_nodes(nodes,ids,frame,x181_add(x188_label(x181_loop_label(frame)),
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x186_x_plain(+stmt: P113DStmt, scan: X186XScan) -> X186XScan:
  match stmt scan:
    case P113DScalar{N111Set{+name,N111U64{},+value}} X186XScan{+ranges,+canonical}:
      +good = x186_x_canonical(value,canonical)
      X186XScan{x185_t_next(nt_choose(X185TScan,good,
        u => x185_t_event(name,True{},x185_t_read(value,ranges)),
        u => x185_t_forbid(name,x185_t_read(value,ranges)))),
        p111v_put(canonical,name,"X186Canonical",nt_choose(U32,good,u => 1,u => 0),0)}
    case P113DScalar{N111Bin{+name,typ,op,+left,+right}} X186XScan{+ranges,+canonical}:
      X186XScan{x185_t_next(x185_t_forbid(name,w2_x_forbid_val(right,w2_x_forbid_val(left,ranges)))),
        p111v_put(canonical,name,"X186Canonical",0,0)}
    case _ X186XScan{ranges,canonical}:
      X186XScan{x185_t_cut(x186_x_noncanonical(stmt,x185_t_stmt(stmt,x185_t_cut(ranges)))),missing()}

law x186_x_scan:
  for nodes: List<&2,X186FloatNode>
  for scan: X186XScan
  X186XScan

@unsafe
def x186_x_node(node: X186FloatNode, +scan: X186XScan) -> X186XScan:
  match node scan:
    case X186FloatValues{+destination,id,left,right} X186XScan{ranges,canonical}:
      X186XScan{x185_t_next(x185_t_event(destination,True{},x185_t_reads([left,right],ranges))),
        p111v_put(canonical,destination,"X186Canonical",1,0)}
    case X186FloatBranch{condition,yes,no} X186XScan{ranges,canonical}:
      x186_x_cut(x186_x_scan(no,x186_x_cut(x186_x_scan(yes,
        X186XScan{x185_t_cut(x185_t_read(condition,x185_t_cut(ranges))),missing()}))))
    case X186FloatPlain{stmt} _: x186_x_plain(stmt,scan)

@unsafe
def x186_x_scan(nodes,scan):
  match nodes:
    case Nil{}: scan
    case Con{head,rest}: x186_x_scan(rest,x186_x_node(head,scan))

@unsafe
def w2b_x_again_reads(vals: List<&2,N111Value>, +idx: U32, +cidxs: List<&2,U32>, +ranges: X185TScan) -> X185TScan:
  match vals:
    case Nil{}: ranges
    case Con{+v,rest}:
      +r1 = nt_choose(X185TScan,w4_u32_mem(idx,cidxs),
              u => x185_t_read(v,ranges),
              u => w2_x_forbid_val(v,ranges))
      w2b_x_again_reads(rest,U32.inc(idx),cidxs,r1)

law w2b_x_scan:
  for nodes: List<&2,X186FloatNode>
  for +cidx: List<&2,U32>
  for +scan: X186XScan
  X186XScan

@unsafe
def w2b_x_scan_node(node: X186FloatNode, +cidx: List<&2,U32>, +scan: X186XScan) -> X186XScan:
  match node scan:
    case X186FloatPlain{P113DAgain{vals}} X186XScan{ranges,canonical}:
      X186XScan{x185_t_cut(x185_t_next(w2b_x_again_reads(vals,0,cidx,ranges))),missing()}
    case X186FloatBranch{c,y,n} X186XScan{ranges,canonical}:
      w2c_x_clear_canon(w2b_x_scan(n,cidx,w2c_x_clear_canon(w2b_x_scan(y,cidx,
        X186XScan{x185_t_next(w2_x_forbid_val(c,ranges)),missing()}))))
    case _ _: x186_x_node(node,scan)

@unsafe
def w2b_x_scan(nodes,cidx,scan):
  match nodes:
    case Nil{}: scan
    case Con{X186FloatPlain{P113DScalar{N111Bin{+inside,N111U64{},+op,+val,N111Const{+last,0}}}},
         Con{X186FloatBranch{N111Local{+inside2},
               Con{X186FloatPlain{P113DScalar{N111Set{+idx1,N111U64{},+val2}}},Nil{}},
               Con{X186FloatPlain{P113DScalar{N111Set{+idx2,N111U64{},N111Const{+last2,0}}}},Nil{}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{+bytes,N111U64{},+shlop,N111Local{+idx3},N111Const{3,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Offset{+addr,N111Symbol{+sym},N111Local{+bytes2}}}},
         Con{X186FloatPlain{P113DScalar{N111Load{+dest,N111U64{},N111Local{+addr2},0}}},+rest}}}}}:
      nt_choose(X186XScan,
        agy_str_eq(inside,"p195t_inside") && agy_str_eq(inside2,"p195t_inside") &&
        agy_str_eq(op,"ult") && agy_str_eq(idx1,"p195t_index") && agy_str_eq(idx2,"p195t_index") &&
        agy_str_eq(idx3,"p195t_index") && agy_str_eq(bytes,"p195t_bytes") && agy_str_eq(bytes2,"p195t_bytes") &&
        agy_str_eq(shlop,"shl") && agy_str_eq(addr,"p195t_address") && agy_str_eq(addr2,"p195t_address") &&
        U32.is_eq(last,last2) && w2c_scan_val_eq(val,val2),
        u => w2b_x_scan(rest,cidx,w2c_x_scan_tbl(dest,val,scan)),
        u => w2b_x_scan(Con{X186FloatBranch{N111Local{inside2},
               Con{X186FloatPlain{P113DScalar{N111Set{idx1,N111U64{},val2}}},Nil{}},
               Con{X186FloatPlain{P113DScalar{N111Set{idx2,N111U64{},N111Const{last2,0}}}},Nil{}}},
             Con{X186FloatPlain{P113DScalar{N111Bin{bytes,N111U64{},shlop,N111Local{idx3},N111Const{3,0}}}},
             Con{X186FloatPlain{P113DScalar{N111Offset{addr,N111Symbol{sym},N111Local{bytes2}}}},
             Con{X186FloatPlain{P113DScalar{N111Load{dest,N111U64{},N111Local{addr2},0}}},rest}}}},cidx,
             w2b_x_scan_node(X186FloatPlain{P113DScalar{N111Bin{inside,N111U64{},op,val,N111Const{last,0}}}},cidx,scan)))
    case Con{h,rest}: w2b_x_scan(rest,cidx,w2b_x_scan_node(h,cidx,scan))

@unsafe
def x186_x_homes(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:
  x186_x_scanned(x186_x_scan(nodes,X186XScan{
    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))

@unsafe
def x186_x_copy_homes(source: Maybe<&2,X187Operand>, destination: Maybe<&2,X187Operand>,
    stmt: P113DStmt, name: String, value: N111Value, ids: N111Ids,
    frame: X181Frame, homes: KDef, code: X181Code) -> X181Code:
  match source destination:
    case Some{operand} _: x181_add(x186_x_publish(name,operand,frame,homes),code)
    case None{} None{}: x181_stmt(stmt,ids,frame,code)
    case None{} Some{operand}: x181_add(x186_float_load(value,ids,frame,operand),code)

@unsafe
def x186_x_copy(stmt: P113DStmt, +name: String, +value: N111Value, ids: N111Ids,
    frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  x186_x_copy_homes(x186_x_source(value,homes),x186_x_home(name,homes),stmt,name,value,ids,frame,homes,code)

@unsafe
def x190_l_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, +rows: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x190_l_valid(names,rows,params,1,groups),
    u => x190_l_install(names,groups,1,frame),u => x185_transient_frame(frame,params,setup,body))

@unsafe
def x190_l_graphed(frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +names: List<&2,String>, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_l_checked(frame,params,setup,body,names,graph,x190_l_color(names,graph,params,1,[0,0,0,0,0]))

@unsafe
def w5c_post_joint_transient(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, +groups: List<&2,U32>, +header: U32) -> X181Frame:
  nt_choose(X181Frame,x185_transient_enabled() && U32.is_eq(nt_count(String,names),32) &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),
    u => w5c_pj_apply(frame,names,groups,header,x185_t_body(body,
      X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0})),
    u => frame)

law x191_loop_reads:
  for body: List<&2,P113DStmt>
  for +params: List<&2,String>
  for after: Bool
  X191LoopReads

@unsafe
def x191_loop_join(+condition: N111Value, yes: X191LoopReads, no: X191LoopReads) -> X191LoopReads:
  match yes no:
    case X191LoopReads{+a,+hotA,fallA} X191LoopReads{+b,+hotB,fallB}:
      +merged = x191_reads_merge(a,b)
      +isExit = (hotA && Bool.not(hotB)) || (hotB && Bool.not(hotA))
      X191LoopReads{nt_choose(X181ReadCounts,isExit,
        u => w5b_reads_loop_cond(condition,merged),
        u => nt_choose(X181ReadCounts,hotA || hotB,
          v => x181_reads_value(condition,merged),v => merged)),hotA || hotB,fallA || fallB}

@unsafe
def x191_loop_stmt(+stmt: P113DStmt, +params: List<&2,String>, +after: Bool) -> X191LoopReads:
  match stmt:
    case P113DAgain{values}: X191LoopReads{x191_again_reads(params,values,X181ReadCounts{missing(),[]}),True{},False{}}
    case P113DResult{values}: X191LoopReads{X181ReadCounts{missing(),[]},False{},False{}}
    case P113DScalar{N111Return{value}}: X191LoopReads{X181ReadCounts{missing(),[]},False{},False{}}
    case P113DIf{condition,yes,no}:
      x191_loop_join(condition,x191_loop_reads(yes,params,after),x191_loop_reads(no,params,after))
    case P113DScalar{N111If{condition,yes,no}}:
      x191_loop_join(condition,x191_loop_reads(x181_scalar_rows(yes),params,after),x191_loop_reads(x181_scalar_rows(no),params,after))
    case _: X191LoopReads{nt_choose(X181ReadCounts,after,
      u => x181_reads_stmt(stmt,X181ReadCounts{missing(),[]}),u => X181ReadCounts{missing(),[]}),after,True{}}

@unsafe
def x191_loop_head(head: P113DStmt, params: List<&2,String>, +rest: X191LoopReads) -> X191LoopReads:
  match rest:
    case X191LoopReads{reads,hot,falls}: x191_loop_cons(x191_loop_stmt(head,params,hot),rest)

@unsafe
def x191_loop_reads(body,params,after):
  match body:
    case Nil{}: X191LoopReads{X181ReadCounts{missing(),[]},after,True{}}
    case Con{head,rest}: x191_loop_head(head,params,x191_loop_reads(rest,params,after))

@unsafe
def x191_joint_reads(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, params: List<&2,String>) -> X181ReadCounts:
  nt_choose(X181ReadCounts,x191_loop_profitability_enabled(),
    u => x191_loop_counted(x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]})),
      x191_loop_reads(body,params,False{})),
    u => x181_reads_stmts(setup,x190_j_weighted(x181_reads_stmts(body,X181ReadCounts{missing(),[]}))))

@unsafe
def x190_branch_facts_when(+reuse: Bool, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> X190BranchFacts:
  nt_choose(X190BranchFacts,x190_branch_enabled() || x191_address_enabled() || x191_memory_alu_enabled() || x192_shared_address_enabled(),u =>
    x190_branch_counted(x181_reads_stmts(body,x181_reads_stmts(setup,X181ReadCounts{missing(),[]})),
      x185_copy_writes(body,x185_copy_writes(setup,x185_copy_writes_names(params,missing()))),
      nt_choose(KDef,reuse && U32.is_lt(p113i_size(body),4096),
        v => x190_branch_pairs(body,missing()),v => missing()),
      nt_choose(KDef,reuse || x191_address_enabled() || x191_memory_alu_enabled() || x192_shared_address_enabled(),v => x185_copy_writes(setup,x185_copy_writes_names(params,missing())),v => missing())),
    u => X190BranchFacts{missing(),missing(),missing(),missing()})

@unsafe
def x190_branch_facts(params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> X190BranchFacts:
  x190_branch_facts_when(x190_branch_reuse_enabled(),params,setup,body)

# Equality between total reads and paired-condition reads is a global use
# certificate: every observable read has its own immediately preceding
# comparison. This remains true through nested branches and Again. Any use in
# an operand, continuation, call, result or backedge adds an unpaired read and
# refuses reuse. Extra writes are harmless because every read has a fresh
# paired producer. Parameter/setup/reserved names remain excluded explicitly.
law x190_stmts:
  for body: List<&2,P113DStmt>
  for +facts: X190BranchFacts
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code

@unsafe
def x190_if_prefix(prefix: X188Seq, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    +facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x190_if_yes(next,no,facts,ids,frame,x190_stmts(yes,facts,ids,frame,
        X181Code{Con{prefix,chunks},U32.add(next,2),False{},error}))

@unsafe
def x190_if_yes(+label: U32, no: List<&2,P113DStmt>, facts: X190BranchFacts,
    ids: N111Ids, +frame: X181Frame, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x190_stmts(no,facts,ids,frame,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x191_if_fallback(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      x190_if_prefix(x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
        x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
        x188_i1("jz",X187Target{x181_label(next,frame)})]),yes,no,facts,ids,frame,code)

# A chosen terminal arm must not expose the original fallthrough continuation
# as statements after Return/Again. Inspect termination without rewriting IR.
@unsafe
def x190_fused_if(+typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      x190_if_prefix(x190_branch_test(typ,op,left,right,next,ids,frame),
        x190_branch_arm(typ,op,left,right,True{},yes,facts),
        x190_branch_arm(typ,op,left,right,False{},no,facts),facts,ids,frame,code)

@unsafe
def x190_stmt(+stmt: P113DStmt, facts: X190BranchFacts, ids: N111Ids,
    frame: X181Frame, code: X181Code) -> X181Code:
  match stmt:
    case P113DIf{condition,yes,no}: x190_if(condition,yes,no,facts,ids,frame,code)
    case P113DScalar{N111If{condition,yes,no}}:
      x190_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),facts,ids,frame,code)
    case _: x181_stmt(stmt,ids,frame,code)

@unsafe
def x190_plain_step(body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match body:
    case Nil{}: code
    case Con{head,rest}: x190_stmts(rest,facts,ids,frame,x190_stmt(head,facts,ids,frame,code))

@unsafe
def x191_branch_step(+body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match body:
    case Con{P113DScalar{N111Bin{name,+typ,+op,left,right}},Con{P113DIf{condition,yes,no},rest}}:
      nt_choose(X181Code,x190_branch_allowed(name,typ,op,condition,facts),u =>
        x190_stmts(rest,facts,ids,frame,x190_fused_if(typ,op,left,right,yes,no,facts,ids,frame,code)),
        u => x190_plain_step(body,facts,ids,frame,code))
    case Con{P113DScalar{N111Bin{name,+typ,+op,left,right}},Con{P113DScalar{N111If{condition,yes,no}},rest}}:
      nt_choose(X181Code,x190_branch_allowed(name,typ,op,condition,facts),u =>
        x190_stmts(rest,facts,ids,frame,x190_fused_if(typ,op,left,right,
          x181_scalar_rows(yes),x181_scalar_rows(no),facts,ids,frame,code)),
        u => x190_plain_step(body,facts,ids,frame,code))
    case _: x190_plain_step(body,facts,ids,frame,code)

@unsafe
def x191_selected_step(pick: Maybe<&2,X191Pick>, body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match pick:
    case Some{X191Pick{rest,operation}}:
      x190_stmts(rest,facts,ids,frame,x181_add(x191_emit(operation,ids,frame),code))
    case None{}: x191_branch_step(body,facts,ids,frame,code)

# Public ABI11102 static transfers. Both arms must establish the same next FID.
# Keep the existing complete transport (including overlap snapshots and cap4
# fallback). Then perform exactly the work_loop reset and a native tail jump.
# No heap ownership, continuation stack or return transfer is changed.

@unsafe
def x198h_selected(pick: Maybe<&2,String>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match pick body:
    case Some{fid} Con{head,rest}: x198h_tail(fid,ids,frame,x190_stmt(head,facts,ids,frame,code))
    case _ _: x194_ps_step(x194_ps_pick(body),body,facts,ids,frame,code)

@unsafe
def x190_step(+body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  x198h_selected(x198h_target(body,ids,frame),body,facts,ids,frame,code)

@unsafe
def x190_stmts(body,facts,ids,frame,code):
  match body code:
    case Nil{} _: code
    case _ X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 statement after terminal",code),
          u => x190_step(body,facts,ids,frame,code)),u => code)

@unsafe
def x191_if_selected(selected: Maybe<&2,X188Seq>, condition: N111Value,
    yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, facts: X190BranchFacts,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match selected:
    case Some{sequence}: x181_add(sequence,code)
    case None{}: x191_if_fallback(condition,yes,no,facts,ids,frame,code)

@unsafe
def x190_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  x191_if_selected(x191_conditional_select(condition,yes,no,ids,frame),condition,yes,no,facts,ids,frame,code)
# A bounded selection window over verified scalar rows. The same matcher drives
# allocation metadata and final emission; metadata rows are never emitted or
# optimized. Eliminated names have one whole-function read and one definition,
# including parameters, setup, branches, continuations and backedges.
@unsafe
def x192_address_emit(rows: List<&2,X192AddressRow>, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match rows:
    case Nil{}: code
    case Con{X192AddressPlain{stmt},rest}: x192_address_emit(rest,ids,frame,x181_stmt(stmt,ids,frame,code))
    case Con{X192AddressMemory{operation},rest}: x192_address_emit(rest,ids,frame,x181_add(x191_emit(operation,ids,frame),code))

@unsafe
def x192_shared_step(pick: Maybe<&2,X192AddressPick>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match pick:
    case Some{X192AddressPick{rest,rows}}: x190_stmts(rest,facts,ids,frame,x192_address_emit(rows,ids,frame,code))
    case None{}: x191_selected_step(x191_pick(body,facts),body,facts,ids,frame,code)
# Adjacent typed frame transport only. Keep the original movq store and use
# its source for the immediately following equal-slot movq load. No dataflow
# fact survives another item, including a label, directive, call or empty item.
# Only aligned negative RBP slots and ordinary 64-bit GPRs are admitted.
# The original IR liveness, frame layout, memory effects and flags are unchanged.
@unsafe
def x199s_done(+symbol: String,result: X181Code,+eligible: Bool,frame: X181Frame) -> X181Output:
  match result:
    case X181Code{chunks,next,+terminal,+error}:
      +code = x191_frame_forward(x188_finish(chunks))
      X181Output{[x188_cat(nt_choose(X188Seq,eligible,u => x199s_frame(code,frame),u => code),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}
# Final selection over already verified, effect-free copy arms. Keep the
# original allocation graph and every original write. Both input values and
# the condition are snapshotted before any destination can overwrite a source.
@unsafe
def x194_ps_step(pick: Maybe<&2,X194Select>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match pick:
    case Some{+plan}:
      match plan:
        case X194Select{rest,typ,op,left,right,invert,selected,+names}:
          nt_choose(X181Code,x194_ps_allowed(names,facts),
            u => x190_stmts(rest,facts,ids,frame,x181_add(x194_ps_emit(plan,ids,frame),code)),
            u => x194_ps_previous(body,facts,ids,frame,code))
    case None{}: x194_ps_previous(body,facts,ids,frame,code)

@unsafe
def x194_ps_previous(+body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  nt_choose(X181Code,x191_address_enabled() || x191_memory_alu_enabled() || x192_shared_address_enabled(),
    u => x192_shared_step(x192_shared_pick(body,facts),body,facts,ids,frame,code),
    u => x191_branch_step(body,facts,ids,frame,code))
# Retain exact integer predicates through pure copy diamonds before allocation.
# Facts describe values, never aliases: each write replaces its destination fact.
# Calls and unresolved joins forget facts. No load/store/call is moved or deleted.
# Reuse the checked select shape so every original destination is still written.

@unsafe
def x181_stmts(body,ids,frame,code):
  match body code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),
        u => nt_choose(X181Code,terminal,u => x181_error("x86 statement after terminal",code),
          u => x181_stmts(rest,ids,frame,x181_stmt(head,ids,frame,code))),u => code)

@unsafe
def x181_stmt(stmt: P113DStmt, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match stmt:
    case P113DScalar{scalar}: x181_scalar(scalar,ids,frame,code)
    case P113DIf{condition,yes,no}: x181_if(condition,yes,no,ids,frame,code)
    case P113DCall{destinations,target,args}: x181_call(destinations,target,args,ids,frame,code)
    case P113DResult{values}: x181_results(values,ids,frame,code)
    case P113DAgain{values}: x181_again(values,ids,frame,code)

@unsafe
def x181_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
  +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x181_if_yes(next,no,ids,frame,x181_stmts(yes,ids,frame,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))

@unsafe
def x181_if_yes(+label: U32, +no: List<&2,P113DStmt>, +ids: N111Ids,
  +frame: X181Frame, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x181_stmts(no,ids,frame,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          X188One{PLabel{x181_label(label,frame)}}),chunks},next,False{},error}))

@unsafe
def x198a_after_sub(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String,
    +pred: String, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Alloca{+buffer,bytes,align}},rest}:
      nt_choose(List<&2,P113DStmt>,x198a_temp(buffer,params) && Bool.not(agy_str_eq(buffer,pred)),u =>
        Con{P113DScalar{N111Alloca{buffer,bytes,align}},
          x198a_scan(rest,X198ACountdown{params,fuel,pred,buffer,ids},[],8)},u => body)
    case _: x198a_scan(body,X198ACountdown{params,fuel,pred,"",ids},[],8)

@unsafe
def x198a_sub(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+pred,N111U64{},+op,+left,+right}},rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"sub") && x185_sf_source(left,fuel) &&
        x192_p_constant(right,1) && x198a_temp(pred,params),u =>
          Con{P113DScalar{N111Bin{pred,N111U64{},op,left,right}},x198a_after_sub(rest,params,fuel,pred,ids)},u => body)
    case _: body

@unsafe
def x198a_positive(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+name,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,yes,no},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
        x185_sf_source(cond,name) && x198a_temp(name,params),u =>
          [P113DScalar{N111Bin{name,N111U64{},op,left,right}},P113DIf{cond,x198a_sub(yes,params,fuel,ids),no}],
          u => body)
    case _: x198a_sub(body,params,fuel,ids)

@unsafe
def x198a_body(+body: List<&2,P113DStmt>, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body params setup:
    case Con{P113DScalar{N111Bin{+name,N111U64{},+op,N111Local{+fuel},+zero}},
        Con{P113DIf{+cond,Con{P113DResult{+values},Nil{}},positive},Nil{}}} Con{+state,extra} Nil{}:
      +args = x181_tail_skip(extra)
      nt_choose(List<&2,P113DStmt>,x198a_enabled() && agy_str_eq(state,"state") && agy_str_eq(op,"eq") &&
        x198a_temp(name,params) && x185_sf_source(cond,name) && x192_p_constant(zero,0) &&
        nb_contains(args,fuel) && U32.is_le(nt_count(String,args),16) && p113e_distinct(params) &&
        x198a_outputs(values,args),u =>
          [P113DScalar{N111Bin{name,N111U64{},op,N111Local{fuel},zero}},
           P113DIf{cond,[P113DResult{values}],x198a_positive(positive,args,fuel,ids)}],u => body)
    case _ _ _: body

# Symbolic execution of the selected path under an exact two-owner constructor
# guard. Only a private nonescaping scratch buffer and fixed-size ownership
# operations are admitted. Token zero is unavailable and always rejects.
@unsafe
def x181_function_done(+symbol: String, code: X181Code) -> X181Output:
  match code:
    case X181Code{chunks,next,+terminal,+error}:
      X181Output{[x188_cat(x191_frame_forward(x188_finish(chunks)),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}

@unsafe
def x198n_positive(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String, returned: List<&2,N111Value>) -> Maybe<&2,String>:
  match body:
    case [P113DScalar{N111Bin{+name,N111U64{},+op,+left,+right}},P113DIf{+condition,yes,no}]:
      nt_choose(Maybe<&2,String>,agy_str_eq(op,"ne") && x198n_name(name,x181_param_names(params)) && x185_sf_source(left,fuel) && x192_p_constant(right,0) && x185_sf_source(condition,name),u =>
        x198n_loop(x198n_split(yes),params,fuel,returned),u => None{})
    case _: x198n_loop(x198n_split(body),params,fuel,returned)

@unsafe
def x198n_body(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>) -> List<&2,P113DStmt>:
  match body:
    case [P113DScalar{N111Bin{+name,N111U64{},+op,N111Local{+fuel},+zero}},P113DIf{+condition,[P113DResult{+returned}],+positive}]:
      +names = x181_param_names(params)
      nt_choose(List<&2,P113DStmt>,x198n_enabled() && x198n_name(name,names) && agy_str_eq(op,"eq") && x185_sf_source(condition,name) && x192_p_constant(zero,0) && nb_contains(names,fuel) && p113e_distinct(names) && U32.is_le(nt_count(String,names),8) && U32.is_le(p113i_size(body),256) && x198n_types(params,fuel) && Bool.not(nb_contains(names,"p198n_nonzero_exit")) && x198o_names(names),u =>
        x198n_composed(x198n_positive(positive,params,fuel,returned),P113DScalar{N111Bin{name,N111U64{},op,N111Local{fuel},zero}},condition,returned,x198o_positive(positive,params,fuel,returned)),u => body)
    case _: body

@unsafe
def x198o_loop(split: Maybe<&2,X198NLoop>, +original: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  match split:
    case Some{X198NLoop{+prefix,+values}}:
      +names = x181_param_names(params)
      nt_choose(List<&2,P113DStmt>,x198n_clean(prefix,names) && Bool.not(x198o_no_fixed(prefix,params,values,fuel,counter)) && x198o_finished(x198o_eval(prefix,x198o_initial(params,fuel,counter),fuel),names,values,fuel,counter),u => x198o_emit(prefix,names,values,fuel,counter),u => original)
    case None{}: original

@unsafe
def x198o_positive(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String, returned: List<&2,N111Value>) -> List<&2,P113DStmt>:
  match returned:
    case [N111Local{+counter}]:
      +core = x198o_unwrap(body,params,fuel)
      nt_choose(List<&2,P113DStmt>,Bool.not(agy_str_eq(counter,fuel)) && nb_contains(x181_param_names(params),counter),u => x198o_loop(x198n_split(core),body,params,fuel,counter),u => body)
    case _: body

@unsafe
def x198pw_second(+book: List<&2,KDef>,+d: KDef,+one: String,+t: KTerm) -> X198PWPlan:
  nt_choose(X198PWPlan,agy_str_eq(tg(t),"Mat") && Bool.not(agy_str_eq(one,nm(t))) && U32.is_eq(terms_len(ks(t)),2),
    u => x198pw_alternative(book,dn(d),one,nm(t),x198pw_family(book,dn(d),one,nm(t))),u => X198PWNone{})

@unsafe
def x198pw_first(+book: List<&2,KDef>,+d: KDef,+t: KTerm) -> X198PWPlan:
  nt_choose(X198PWPlan,agy_str_eq(tg(t),"Mat") && U32.is_eq(terms_len(ks(t)),2),
    u => x198pw_second(book,d,nm(t),nc_unann(kid(t,1))),u => X198PWNone{})

@unsafe
def x198pw_candidate(+book: List<&2,KDef>,+d: KDef) -> X198PWPlan:
  nt_choose(X198PWPlan,agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),3) && Bool.not(db(d) || du(d)),
    u => x198pw_first(book,d,nc_unann(dv(d))),u => X198PWNone{})

# Keep preparation, ABI, tables, and all existing public or private body plans
# unchanged unless a concrete source theorem and a compatible H worker agree.
@unsafe
def x198pw_checked_plan(+book: List<&2,KDef>,+d: KDef) -> X198PWPlan:
  +ty = nm(kid(dt(d),0))
  nt_choose(X198PWPlan,U32.is_eq(da(d),3) && x198pw_tel(dt(d),[ty,ty,"Bool"],ty),
    u => x198pw_validate_data(book,ty,d,x198pw_candidate(book,d)),u => X198PWNone{})

@unsafe
def x198pw_owners(scope: List<&2,KDef>,+book: List<&2,KDef>,+acc: List<&2,X198PWPlan>) -> List<&2,X198PWPlan>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      x198pw_owners(rest,book,nt_choose(List<&2,X198PWPlan>,agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),3) &&
          agy_str_eq(tg(nc_unann(dv(d))),"Mat"),u => x198pw_add(x198pw_checked_plan(book,d),acc),u => acc))

@unsafe
def agy_zip_checked_plan(+book: List<&2,KDef>, +d: KDef) -> AgyZipPlan:
  +t = dt(d)
  # Check Nat -> U32 -> T -> T
  +ty = nm(kid(kid(kid(t,1),1),0))
  +adt = lookup(book,ty)
  nt_choose(AgyZipPlan,x198pw_tel(t,["Nat","U32",ty],ty) &&
      agy_str_eq(dk(adt),"ADT") && U32.is_eq(da(adt),0) && U32.is_eq(dx(adt),0) && Bool.not(db(adt)),
    u => agy_zip_try_ctors(book,dn(d),ty,dc(adt)),
    u => AgyZipNone{})

@unsafe
def agy_zip_owners(scope: List<&2,KDef>, +book: List<&2,KDef>, +acc: List<&2,AgyZipPlan>) -> List<&2,AgyZipPlan>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      agy_zip_owners(rest,book,nt_choose(List<&2,AgyZipPlan>,
        agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),3) && Bool.not(db(d) || du(d)) &&
        agy_str_eq(tg(dt(d)),"All") && agy_str_eq(tg(kid(dt(d),1)),"All") && agy_str_eq(tg(kid(kid(dt(d),1),1)),"All"),
        u => agy_zip_add(agy_zip_checked_plan(book,d),acc),u => acc))

@unsafe
def w4c_zip_owners_map(book):
  w4c_zip_set(agy_zip_owners(book,book,[]),missing())

@unsafe
def agy_zip_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_zip_ready(agy_zip_owners(scope,book,[]),prepared)

law agy_ro_walk_mats:
  for +book: List<&2,KDef>
  for +owner: String
  for +adt: String
  for +ctors: List<&2,KDef>
  for +t: KTerm
  for +has_x: Bool
  for +has_rec: Bool
  for +acc: List<&2,KTerm>
  for +fuel: U32
  Maybe<&2,List<&2,KTerm>>

@unsafe
def agy_ro_walk_mat_expr(+book: List<&2,KDef>, +owner: String, +adt: String, +ctors: List<&2,KDef>,
    +cname: String, +carity: U32, +inline_u32: U32, +rest: KTerm, +has_x: Bool, +has_rec: Bool, +acc: List<&2,KTerm>,
    +fuel: U32, parsed: Maybe<&2,KTerm>) -> Maybe<&2,List<&2,KTerm>>:
  match parsed:
    case None{}: None{}
    case Some{+expr}:
      +cid = nc_ctor_identity(book,cname)
      +item = kt("RoCase",cid,carity,inline_u32,[expr])
      agy_ro_walk_mats(book,owner,adt,ctors,rest,has_x,has_rec || agy_ro_expr_has_rec(expr),Con{item,acc},fuel)

@unsafe
def agy_ro_walk_mat_fields(+book: List<&2,KDef>, +owner: String, +adt: String, +ctors: List<&2,KDef>,
    +cname: String, +carity: U32, +arm: KTerm, +rest: KTerm, +has_x: Bool, +has_rec: Bool, +acc: List<&2,KTerm>,
    +fuel: U32, fields: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,KTerm>>:
  match fields:
    case None{}: None{}
    case Some{rev_fs}:
      +fs = agy_ro_rev_u32(rev_fs,[])
      agy_ro_walk_mat_expr(book,owner,adt,ctors,cname,carity,agy_ro_is_inline_u32(fs),rest,has_x,has_rec,acc,fuel,
        agy_ro_peel_arm(book,owner,arm,fs,has_x))

@unsafe
def agy_ro_walk_mat_one(+book: List<&2,KDef>, +owner: String, +adt: String, +ctors: List<&2,KDef>,
    +cname: String, +arm: KTerm, +rest: KTerm, +has_x: Bool, +has_rec: Bool, +acc: List<&2,KTerm>, +fuel: U32) -> Maybe<&2,List<&2,KTerm>>:
  +cd = agy_ro_find_ctor(ctors,cname)
  nt_choose(Maybe<&2,List<&2,KTerm>>,agy_str_eq(dk(cd),"Ctr") && U32.is_eq(dx(cd),0) && U32.is_le(da(cd),2),
    u => agy_ro_walk_mat_fields(book,owner,adt,ctors,cname,da(cd),arm,rest,has_x,has_rec,acc,fuel,
      agy_ro_ctor_fields(dt(cd),adt,[])),
    u => None{})

@unsafe
def agy_ro_walk_mats(book,owner,adt,ctors,t,has_x,has_rec,acc,fuel):
  +u = nc_unann(t)
  nt_choose(Maybe<&2,List<&2,KTerm>>,U32.is_eq(fuel,0),v => None{},v =>
    nt_choose(Maybe<&2,List<&2,KTerm>>,agy_str_eq(tg(u),"Mat") && U32.is_eq(terms_len(ks(u)),2),
      w => agy_ro_walk_mat_one(book,owner,adt,ctors,nm(u),kid(u,0),kid(u,1),has_x,has_rec,acc,U32.sub(fuel,1)),
      w => nt_choose(Maybe<&2,List<&2,KTerm>>,has_rec && Bool.not(List.is_empty(&2,KTerm,acc)),
        z => Some{acc},z => None{})))

@unsafe
def agy_ro_check_adt(+book: List<&2,KDef>, +d: KDef, +adt_name: String, +arity: U32, +has_x: Bool) -> Maybe<&2,KDef>:
  +adt = lookup(book,adt_name)
  +valid_sig = nt_choose(Bool,has_x,
    v => x198pw_tel(dt(d),[adt_name,"U32"],"U32"),
    v => x198pw_tel(dt(d),[adt_name],"U32"))
  nt_choose(Maybe<&2,KDef>,valid_sig && agy_str_eq(dk(adt),"ADT") && U32.is_eq(da(adt),0) &&
      U32.is_eq(dx(adt),0) && Bool.not(db(adt)),
    u => agy_ro_check_finish(dn(d),arity,agy_ro_walk_mats(book,dn(d),adt_name,dc(adt),dv(d),has_x,False{},[],16)),
    u => None{})

@unsafe
def agy_ro_check_def(+book: List<&2,KDef>, +d: KDef) -> Maybe<&2,KDef>:
  +arity = da(d)
  +has_x = U32.is_eq(arity,2)
  +ty_t = nc_unann(dt(d))
  nt_choose(Maybe<&2,KDef>,agy_str_eq(dk(d),"Def") && (U32.is_eq(arity,1) || U32.is_eq(arity,2)) &&
      Bool.not(db(d) || du(d)) && agy_str_eq(tg(nc_unann(dv(d))),"Mat") &&
      agy_str_eq(tg(ty_t),"All") && U32.is_eq(terms_len(ks(ty_t)),2),
    u => agy_ro_check_adt(book,d,nm(nc_unann(kid(ty_t,0))),arity,has_x),
    u => None{})

@unsafe
def agy_ro_owners(scope: List<&2,KDef>, +book: List<&2,KDef>, +acc: List<&2,KDef>) -> List<&2,KDef>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      agy_ro_owners(rest,book,agy_ro_add_entry(agy_ro_check_def(book,d),acc))

@unsafe
def agy_ro_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r prepared:
    case NR_Request{source,+book,names,paths,scope,bound} P169Prepared{forwards,+cursor,+error}:
      +entries = agy_ro_owners(scope,book,[])
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,KDef,entries)),
        u => agy_ro_cursor(entries,cursor),u => cursor),error}

@unsafe
def agy_fl_finish(+book: List<&2,KDef>, +owner: String, +ty: String, s: X198PWState) -> AgyFlowPlan:
  match s:
    case X198PWState{+roles,vars}:
      +leaf = x198pw_name(roles,"leaf")
      +node = x198pw_name(roles,"node")
      +wn = x198pw_name(roles,"wn")
      +warp = x198pw_name(roles,"warp")
      +leaf_id = nc_ctor_identity(book,leaf)
      +node_id = nc_ctor_identity(book,node)
      nt_choose(AgyFlowPlan,x198pw_data(book,ty,leaf,node) && Bool.not(String.is_empty(warp)),
        u => agy_fl_check_warp(book,owner,wn,leaf_id,node_id,warp,x198pw_checked_plan(book,lookup(book,warp))),
        u => AgyFlowNone{})
    case _: AgyFlowNone{}

@unsafe
def x193f_fused(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef, enabled: Bool) -> P112FusionBody:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      nt_choose(P112FusionBody,enabled,u => p112c_plan_index(segment,index,ready),u => P112FusionBody{body,0,0})

@unsafe
def x193f_plan(+segment: N111Segment, index: P112FusionIndex, +ready: KDef,
    available: KDef, fusion: Bool, tail: Bool) -> X193FBody:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      nt_choose(X193FBody,x193f_clean(body),u =>
        x193f_checked(x193fb_candidate(segment,ready,tail,x193f_fused(segment,index,ready,fusion)),available),
        u => X193FBody{body,0,"public helper reserved local collision"})

@unsafe
def agy_f32_certify(+params: List<&2,String>, body: List<&2,P113DStmt>) -> AgyF32Plan:
  match params body:
    case Con{state,Con{+fuel,Con{+x,Con{+h,Nil{}}}}}
         Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      nt_choose(AgyF32Plan,agy_str_eq(state,"state") && p113e_distinct(params) &&
          agy_str_eq(op,"eq") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(cond,test) && agy_f32_free(test,params) && agy_f32_result(yes,h),
        u => agy_f32_positive(no,params,fuel,x,h),
        u => AgyF32No{})
    case _ _: AgyF32No{}

# ---- XMM constant collector & expression emitter ----
# XMM allocation:
#   %xmm0: x (loop-carried!)
#   %xmm1: scratch / y_next / obs
#   %xmm2..%xmm7: expression eval stack (depth up to 6)
#   %xmm8..%xmm15: hoisted F32 constants (up to 8 distinct constants!)

@unsafe
def x201e_size_text(object: X187Object, rodata: List<&2,U32>, data: List<&2,U32>, +text: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(text,67108864),
    u => x201e_size_rodata(object,data,text,x201e_checked_size(rodata,0)),
    u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})

@unsafe
def x187_elf(+object: X187Object) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,symbols,relocations}:
      x201e_size_text(object,rodata,data,x201e_checked_size(text,0))
# Direct machine-fragment object route. Selection supplies typed instructions
# and data; production never renders or parses assembly. The text parser below
# remains a diagnostic entry only. Section buffers are explicitly bounded.

@unsafe
def w7c_fast_leaq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Mem{+b,+disp} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(b,16) && U32.is_lt(dd,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),141,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Rip{+sym,+lo,+hi} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,Bool.not(String.is_empty(sym)) && U32.is_lt(dd,16),
        u => x187_build_relocation(
          X187Relocation{1,U32.add(ts,3),2,sym,U32.sub(lo,4),U32.sub(hi,nt_choose(U32,U32.is_lt(lo,4),v => 1,v => 0))},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{U32.add(5,U32.mul(U32.and(dd,7),8)),
            Con{141,Con{U32.add(72,U32.mul(U32.shrn(dd,3n),4)),t}}}}}}},
            r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def w7c_fast_movabsq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Imm{+lo,+hi} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16),
        w => X187Build{1,w7c_u32_rev(hi,w7c_u32_rev(lo,Con{U32.add(184,U32.and(dd,7)),Con{U32.add(72,U32.shrn(dd,3n)),t}})),
          r,d,U32.add(ts,10),rs,ds,symbols,names,relocs,error},
        w => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def w7c_fast_inst_c(c0: U32, +tail: String, operands: List<&2,X187Operand>, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match c0 operands:
    case 109 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"ovq"),
        u => w7c_fast_movq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"ovabsq"),
          v => w7c_fast_movabsq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 108 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"eaq"),
        u => w7c_fast_leaq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 99 Con{X187Target{+sym},Nil{}}:
      nt_choose(X187Build,agy_str_eq(tail,"all") && Bool.not(String.is_empty(sym)),
        u => x187_build_relocation(X187Relocation{1,U32.inc(ts),4,sym,4294967292,4294967295},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{232,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 120 Con{X187Reg{+s,32,False{}},Con{X187Reg{+dd,32,False{}},Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"orl") && U32.is_lt(s,8) && U32.is_lt(dd,8),
        u => X187Build{1,Con{U32.add(192,U32.add(U32.mul(s,8),dd)),Con{49,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 114 Nil{}:
      nt_choose(X187Build,agy_str_eq(tail,"et"),
        u => X187Build{1,Con{195,t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 112 Con{X187Reg{+dd,64,False{}},Nil{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"ushq"),
        u => nt_choose(X187Build,U32.is_lt(dd,8),
          v => X187Build{1,Con{U32.add(80,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
          v => X187Build{1,Con{U32.add(80,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"opq"),
          v => nt_choose(X187Build,U32.is_lt(dd,8),
            w => X187Build{1,Con{U32.add(88,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
            w => X187Build{1,Con{U32.add(88,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  match inst build:
    case X187Instruction{SCon{+ch,+tail},+operands} X187Build{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => w7c_fast_inst_c(Char.to_u32(ch),tail,operands,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,x187_build_offset(build)),inst,build)

@unsafe
def w5b_bp_inst(sec: U32, +instruction: X187Instruction, +build: X187Build) -> X187Build:
  match sec:
    case 1: x188_build_instruction(instruction,build)
    case _: x187_build_error("instruction outside text",build)

@unsafe
def x187_build_parsed(+parsed: X187Parsed, +build: X187Build) -> X187Build:
  match parsed:
    case PEmpty{}: build
    case PError{message}: x187_build_error(message,build)
    case PSection{section}: x187_build_switch(section,build)
    case PLabel{name}: x187_build_symbol(name,1,0,build)
    case PGlobal{name}: x187_build_symbol(name,2,0,build)
    case PType{name,kind}: x187_build_symbol(name,3,kind,build)
    case PSize{name}: x187_build_symbol(name,4,0,build)
    case PBytes{bytes}: x187_build_bytes(bytes,build)
    case PDatum{datum}: x187_build_datum(datum,build)
    case PDataReloc{name,lo,hi}:
      x187_build_bytes([0,0,0,0,0,0,0,0],x187_build_relocation(
        X187Relocation{x187_build_section(build),x187_build_offset(build),1,name,lo,hi},build))
    case PAlign{+alignment}:
      nt_choose(X187Build,U32.is_eq(alignment,0) || U32.is_gt(alignment,
            nt_choose(U32,U32.is_eq(x187_build_section(build),1),w => 16,w => 8)) ||
          Bool.not(U32.is_eq(U32.and(alignment,U32.sub(alignment,1)),0)),
        v => x187_build_error("invalid object alignment",build),v =>
        x187_build_bytes(x187_build_fill(U32.mod(U32.sub(alignment,U32.mod(x187_build_offset(build),alignment)),alignment),
          nt_choose(U32,U32.is_eq(x187_build_section(build),1),w => 144,w => 0),[]),build))
    case PInst{instruction}:
      w5b_bp_inst(x187_build_section(build),instruction,build)

law w7_seq_go:
  for seq: X188Seq
  for rest: List<&2,X188Seq>
  for +build: X187Build
  for +count: U32
  X187Build

@unsafe
def w7_seq_pop(rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match rest:
    case Nil{}: build
    case Con{head,tail}: w7_seq_go(head,tail,build,count)

@unsafe
def w7_seq_after_one(ok: Bool, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: w7_seq_pop(rest,build,count)
    case False{}: build

@unsafe
def w7_seq_step(seq: X188Seq, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match seq:
    case X188Empty{}: w7_seq_pop(rest,build,count)
    case X188One{item}:
      +b2 = x187_build_parsed(item,build)
      w7_seq_after_one(String.is_empty(x187_build_message(b2)),rest,b2,count)
    case X188Join{left,right}: w7_seq_go(left,Con{right,rest},build,count)

@unsafe
def w7_seq_chk(ok: Bool, seq: X188Seq, rest: List<&2,X188Seq>, +build: X187Build, +count: U32) -> X187Build:
  match ok:
    case True{}: w7_seq_step(seq,rest,build,U32.inc(count))
    case False{}: x187_build_error("x86 object fragment count exceeds bound",build)

@unsafe
def w7_seq_go(seq,rest,build,count):
  w7_seq_chk(U32.is_lt(count,67108864),seq,rest,build,count)

@unsafe
def x188_build_fixups(names: List<&2,String>, index: KDef, sizes: X187ElfSizes,
    text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> X187ObjectResult:
  match state:
    case X188Fixups{patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => x188_build_patched(names,index,escaped,sizes,rodata,data,relocations,x188_fixup_bytes(text,patches,0,[])),
        u => X187ObjectResult{[],error})

# Preserve original symbol-count, name and string-table capacities before
# removable locals vanish. The initial byte accounts for the reserved NUL.
@unsafe
def x187_build_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          x188_build_fixups(names,symbols,X187ElfSizes{ts,rs,ds},nt_reverse(U32,t,[]),nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

# The existing forward patcher defines the order of diagnostics for unordered,
# overlapping and out-of-bounds patches. An empty plan selects that patcher.
@unsafe
def x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        x188_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => X187ObjectResult{[],error})

# The production cursor starts with x187_build_empty. Append, padding and data
# operations maintain ts == length(t). The historical generic finish stays
# available for diagnostic callers constructing a raw X187Build by hand.
@unsafe
def x201f_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

@unsafe
def agy_p114h_scan_segs(segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +view: KDef, +available: KDef, +hready: KDef, +rem: List<&2,N111Segment>, +added: Bool) -> AgyHPass:
  match segs:
    case Nil{}: AgyHPass{hready,nt_reverse(N111Segment,rem,[]),added}
    case Con{+seg,+rest}:
      match seg:
        case N111Segment{+name,+arity,result,incoming,flags,body}:
          nt_choose(AgyHPass,agy_p114h_plan_hygiene(name,available,p114h_plan(seg,index,view)),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,p111v_put(hready,name,"AgyHReady",arity,1),rem,True{}),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,hready,Con{seg,rem},added))

law agy_p114h_fixpoint_loop:
  for +segs: List<&2,N111Segment>
  for +index: P112FusionIndex
  for +direct: KDef
  for +ready: KDef
  for +available: KDef
  for +hready: KDef
  for +fuel: U32
  KDef

@unsafe
def agy_p114h_fixpoint_next(+index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +fuel: U32, pass: AgyHPass) -> KDef:
  match pass:
    case AgyHPass{+hready2,+rem,added}:
      nt_choose(KDef,added && Bool.not(List.is_empty(&2,N111Segment,rem)),
        u => agy_p114h_fixpoint_loop(rem,index,direct,ready,available,hready2,U32.sub(fuel,1)),
        u => hready2)

@unsafe
def agy_p114h_fixpoint_loop(segs,index,direct,ready,available,hready,fuel):
  nt_choose(KDef,U32.is_eq(fuel,0) || List.is_empty(&2,N111Segment,segs),u => hready,u =>
    agy_p114h_fixpoint_next(index,direct,ready,available,fuel,
      agy_p114h_scan_segs(segs,index,direct,agy_p124r_hview(ready,direct,hready),available,hready,[],False{})))

@unsafe
def agy_p114h_fixpoint(+segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +hready: KDef, +fuel: U32) -> KDef:
  agy_p114h_fixpoint_loop(agy_p114h_filter_segs(segs,direct,[]),index,direct,ready,available,hready,fuel)

@unsafe
def agy_enrich_cursor(cursor: P134Cursor, +available: KDef) -> P134Cursor:
  match cursor:
    case P134Private{fns,ctx,next}: P134Private{fns,ctx,agy_enrich_cursor(next,available)}
    case P134Legacy{es,ctx,next}: P134Legacy{es,ctx,agy_enrich_cursor(next,available)}
    case P134Public{+segs,P134Context{+ids,+index,+direct,+ready,+view,+lookups,+heap,+mode},+next}:
      nt_choose(P134Cursor,Bool.not(U32.is_eq(mode,0)) && x192h_regions_enabled(),
        u => P134Public{segs,P134Context{ids,index,direct,ready,
          agy_p124r_hview(ready,direct,agy_p114h_fixpoint(segs,index,direct,ready,available,missing(),6)),
          lookups,heap,mode},next},
        u => P134Public{segs,P134Context{ids,index,direct,ready,view,lookups,heap,mode},next})
    case other: other

@unsafe
def x181_function_fast_emit(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids) -> X181Output:
  +frame = x186_saves_frame(x181_frame(symbol,params,body))
  x181_function_fast_done(symbol,x181_stmts(body,ids,frame,
    x181_add(x188_label(x181_loop_label(frame)),X181Code{[x181_prologue(frame)],0,False{},""})))

@unsafe
def x181_function_fast_late(symbol: String, params: List<&2,String>, ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,_}: x181_function_fast_emit(symbol,params,ready,ids)

@unsafe
def w7c_public_fast_emit(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids) -> X181Output:
  +frame = x186_saves_frame(x181_frame(symbol,params,body))
  x181_function_fast_done(symbol,x181_stmts(body,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))

@unsafe
def w7c_public_fast_late(symbol: String, params: List<&2,String>, ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,_}: w7c_public_fast_emit(symbol,params,ready,ids)

law w10f_x201f_finish_any:
  for +build: X187Build
  for +is_mod: Bool
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def x202p_x201e_size_text(object: X187Object, rodata: List<&2,U32>, data: List<&2,U32>, +text: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(text,67108864),
    u => x202p_x201e_size_rodata(object,data,text,x201e_checked_size(rodata,0)),
    u => IO.die(U32,1,"invalid or oversized ELF section bytes"))

@unsafe
def x202p_x187_elf(+object: X187Object) -> IO(U32):
  match object:
    case X187Object{text,rodata,data,symbols,relocations}:
      x202p_x201e_size_text(object,rodata,data,x201e_checked_size(text,0))

@unsafe
def x202p_x187_build_symbols(+names: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object) -> IO(U32):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x202p_x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: x202p_x187_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def x202p_x187_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> IO(U32):
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(IO(U32),Bool.not(defined) && String.starts_with(name,".L"),
        u => IO.die(U32,1,"undefined local label: " ++ name),u =>
        x202p_x188_build_symbol_checked(X187Symbol{name,section,value,size,global || Bool.not(defined),kind},
          rest,index,escaped,sizes,acc,object))
    case _: IO.die(U32,1,"invalid final object symbol")

@unsafe
def x202p_x188_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> IO(U32):
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(IO(U32),x187_elf_symbol_valid(symbol,sizes),u =>
        x202p_x187_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => IO.die(U32,1,"invalid or duplicate ELF symbol"))

@unsafe
def x202p_x188_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> IO(U32):
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => x202p_x187_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => IO.die(U32,1,error))

@unsafe
def x202p_x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> IO(U32):
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        x202p_x188_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => IO.die(U32,1,error))

law agy_parcg_build_symbols:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for +object: X187Object
  X187ObjectResult

@unsafe
def agy_parcg_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>
        agy_parcg_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})

@unsafe
def agy_parcg_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        agy_parcg_build_symbol_checked(
          X187Symbol{name,section,value,size,global || Bool.not(defined) || Bool.not(String.starts_with(name,".L")),kind},
          rest,index,escaped,sizes,acc,object))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def agy_parcg_build_symbols(names, index, escaped, sizes, acc, object):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: agy_parcg_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def agy_parcg_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> X187ObjectResult:
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => agy_parcg_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => X187ObjectResult{[],error})

@unsafe
def agy_parcg_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        agy_parcg_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => X187ObjectResult{[],error})

law agy_parcg_native_build_symbols:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for +object: X187Object
  IO(U32)

@unsafe
def agy_parcg_native_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> IO(U32):
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(IO(U32),x187_elf_symbol_valid(symbol,sizes),u =>
        agy_parcg_native_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => IO.die(U32,1,"invalid or duplicate ELF symbol"))

@unsafe
def agy_parcg_native_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> IO(U32):
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(IO(U32),Bool.not(defined) && String.starts_with(name,".L"),
        u => IO.die(U32,1,"undefined local label: " ++ name),u =>
        agy_parcg_native_build_symbol_checked(
          X187Symbol{name,section,value,size,global || Bool.not(defined) || Bool.not(String.starts_with(name,".L")),kind},
          rest,index,escaped,sizes,acc,object))
    case _: IO.die(U32,1,"invalid final object symbol")

@unsafe
def agy_parcg_native_build_symbols(names, index, escaped, sizes, acc, object):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x202p_x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: agy_parcg_native_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def agy_parcg_native_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> IO(U32):
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => agy_parcg_native_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => IO.die(U32,1,error))

@unsafe
def agy_parcg_native_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> IO(U32):
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        agy_parcg_native_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => IO.die(U32,1,error))

@unsafe
def w10_x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    state: X188Fixups, +weak_set: KDef) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        w10_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[])),weak_set),u => X187ObjectResult{[],error})

@unsafe
def w10_x201f_finish(+build: X187Build, +weak_set: KDef) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          w10_x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),weak_set),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

@unsafe
def w10_x202p_x201f_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    state: X188Fixups, +weak_set: KDef) -> IO(U32):
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        w10_x202p_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[])),weak_set),u => IO.die(U32,1,error))

@unsafe
def w10_x202p_x201f_finish(+build: X187Build, +weak_set: KDef) -> IO(U32):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        nt_choose(IO(U32),x188_symbol_count(names,0,1),v =>
          w10_x202p_x201f_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),weak_set),
          v => IO.die(U32,1,"invalid or duplicate ELF symbol")),
        u => IO.die(U32,1,error))

@unsafe
def w10f_fn_emit_jcc(+code: U32, +sym: String, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String,
    +lsyms: KDef, +lrelocs: List<&2,X187Relocation>) -> W10fFnBuild:
  nt_choose(W10fFnBuild,U32.is_eq(code,0),
    u => W10fFnBuild{x188_build_instruction(inst,build),lsyms,lrelocs},
    u => nt_choose(W10fFnBuild,U32.is_eq(code,233),
      v => W10fFnBuild{
        X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{233,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error},
        lsyms,Con{X187Relocation{1,U32.inc(ts),130,sym,4294967292,4294967295},lrelocs}},
      v => W10fFnBuild{
        X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{code,Con{15,t}}}}}},r,d,U32.add(ts,6),rs,ds,symbols,names,relocs,error},
        lsyms,Con{X187Relocation{1,U32.add(ts,2),130,sym,4294967292,4294967295},lrelocs}}))

@unsafe
def w10f_fn_inst(+inst: X187Instruction, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>) -> W10fFnBuild:
  match inst build:
    case X187Instruction{SCon{+ch,+tail},Con{X187Target{+sym},Nil{}}}
         X187Build{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+error}:
      nt_choose(W10fFnBuild,U32.is_eq(Char.to_u32(ch),106) && U32.is_le(ts,134217712) && String.starts_with(sym,".L"),
        u => w10f_fn_emit_jcc(w10f_jcc_code(tail),sym,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error,lsyms,lrelocs),
        u => W10fFnBuild{x188_build_instruction(inst,build),lsyms,lrelocs})
    case _ _: W10fFnBuild{x187_build_parsed(PInst{inst},build),lsyms,lrelocs}

@unsafe
def w10f_fixups_dispatch(+names: List<&2,String>, +index: KDef, +sizes: X187ElfSizes,
    +t_rev: List<&2,U32>, +r_rev: List<&2,U32>, +d_rev: List<&2,U32>,
    +patches: List<&2,X187Relocation>, +plan: List<&2,X187Relocation>,
    +relocations: List<&2,X187Relocation>, +escaped: KDef,
    +is_mod: Bool, +weak_set: KDef) -> X187ObjectResult:
  match patches plan:
    case Con{_,_} Nil{}:
      nt_choose(X187ObjectResult,is_mod,
        u => w10_build_patched(names,index,escaped,sizes,nt_reverse(U32,r_rev,[]),nt_reverse(U32,d_rev,[]),
          relocations,x188_fixup_bytes(nt_reverse(U32,t_rev,[]),patches,0,[]),weak_set),
        u => x188_build_patched(names,index,escaped,sizes,nt_reverse(U32,r_rev,[]),nt_reverse(U32,d_rev,[]),
          relocations,x188_fixup_bytes(nt_reverse(U32,t_rev,[]),patches,0,[])))
    case _ _:
      w10f_build_symbols_rev(names,index,escaped,sizes,[],t_rev,r_rev,d_rev,plan,relocations,is_mod,weak_set)

@unsafe
def w10f_fixups_rev(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    t_rev: List<&2,U32>, r_rev: List<&2,U32>, d_rev: List<&2,U32>,
    state: X188Fixups, +is_mod: Bool, +weak_set: KDef) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w10f_fixups_dispatch(names,index,sizes,t_rev,r_rev,d_rev,patches,x201f_plan(patches,ts,0,[]),relocations,escaped,is_mod,weak_set),
        u => X187ObjectResult{[],error})

@unsafe
def w10f_x201f_finish_any(build, is_mod, weak_set):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          w10f_fixups_rev(names,symbols,X187ElfSizes{ts,rs,ds},t,r,d,
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),is_mod,weak_set),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

# --- Part C: Streaming IO `x202p` fused relocation pass ---

@unsafe
def w10_if_emit_checked(+stamp: String, +s_book: List<&2, KDef>, +s_fresh: FFreshPrefixState, +s_ready: FReadyPrefixState, +s_state: KBasePrefixState, +s_world: KBasePreparedWorld) -> IO(U32):
  match s_ready s_state:
    case FReadyPrefixState{_, _, _, True{}} KBasePrefixState{_, _, _, _, True{}}:
      +e0 = w10_if_enc_defs(w10_if_enc_empty(), s_book)
      +e1 = w10_if_enc_state(w10_if_res_enc(e0), s_state)
      +e2 = w10_if_enc_fresh(w10_if_res_enc(e1), s_fresh)
      +e3 = w10_if_enc_world(w10_if_res_enc(e2), s_world)
      +e4 = w10_if_enc_ready(w10_if_res_enc(e3), s_ready)
      w10_if_stream_carrier(stamp, w10_if_res_enc(e4), w10_if_res_id(e0), w10_if_res_id(e1), w10_if_res_id(e2), w10_if_res_id(e3), w10_if_res_id(e4))
    case _ _: IO.die(U32, 1, "x86-iface: prepared interface state was not ready")

