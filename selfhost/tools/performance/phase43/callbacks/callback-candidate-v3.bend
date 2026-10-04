# Candidate source fragment for region.bend. No source-name specialization.
# Successor with exact root aliases; root owns checked acquisition and runtime qualification.
@unsafe
def j_callback_fun_type(+book: List<&2,KDef>, +ty: KTerm, +arg: String) -> Bool:
  +h = wnf(book, ty)
  String.eq(tg(h), "All") && U32.is_eq(qt(h), 1) &&
    j_primitive_type(book, wnf(book, kid(h, 0)), arg) &&
    j_primitive_type(book, wnf(book, kid(h, 1)), "U32")

@unsafe
def j_callback_factory_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  String.eq(tg(h), "All") && Bool.not(U32.is_eq(qt(h), 0)) &&
    j_primitive_type(book, wnf(book, kid(h, 0)), "Nat") &&
    j_callback_fun_type(book, kid(h, 1), "U32")

@unsafe
def j_callback_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>, +pred: U32, +fuel: U32) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(h), "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
      kc(Bool, String.eq(tg(h), "Lit"), u => String.eq(nm(h), "U32"), u =>
        kc(Bool, j_fusion_call(s, "U32.from_nat", 1) && j_primitive_call(book, s),
          u => j_fusion_var(kid(s, 0), pred), u =>
          kc(Bool, String.eq(tg(s), "Call") && U32.is_eq(terms_len(ks(s)), 2) &&
            (String.eq(nm(s), "U32.add") || String.eq(nm(s), "U32.sub") || String.eq(nm(s), "U32.mul") || String.eq(nm(s), "U32.mod")) &&
            j_primitive_call(book, s), u =>
            kc(Bool, j_callback_scalar(book, kid(s, 0), vars, pred, U32.sub(fuel, 1)),
              u => j_callback_scalar(book, kid(s, 1), vars, pred, U32.sub(fuel, 1)), u => False{}), u => False{})))), u => False{})

# The exact generic composition domain is Type&1, with three erased q0
# binders. Type&2 native U32 is specialized only after that formal proof.
@unsafe
def j_callback_type_domain(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  String.eq(tg(h), "Typ") && String.eq(nm(h), "") && U32.is_eq(ix(h), 0) && U32.is_eq(qt(h), 0) &&
    List.is_empty(&2, String, rm(h)) && U32.is_eq(terms_len(ks(h)), 1) &&
    String.eq(tg(kid(h, 0)), "Qua") && String.eq(nm(kid(h, 0)), "") && U32.is_eq(ix(kid(h, 0)), 0) &&
    U32.is_eq(qt(kid(h, 0)), 1) && List.is_empty(&2, String, rm(kid(h, 0))) && U32.is_eq(terms_len(ks(kid(h, 0))), 0)

@unsafe
def j_callback_erased_prefix(+book: List<&2,KDef>, +ty: KTerm, +body: KTerm, +left: U32) -> Bool:
  +h = wnf(book, ty)
  +t = j_strip(body)
  kc(Bool, U32.is_eq(left, 0), u => True{}, u =>
    String.eq(tg(h), "All") && U32.is_eq(qt(h), 0) && j_callback_type_domain(book, kid(h, 0)) &&
    String.eq(tg(t), "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) &&
    j_callback_runtime_absent(kid(t, 0), ix(t), 2048) &&
    j_callback_erased_prefix(book, kid(h, 1), kid(t, 0), U32.sub(left, 1)))

@unsafe
def j_callback_live_compose_type(+book: List<&2,KDef>, +ty: KTerm, +body: KTerm, +left: U32) -> Bool:
  +h = wnf(book, ty)
  +t = j_strip(body)
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, h, "U32"), u =>
    String.eq(tg(h), "All") && U32.is_eq(qt(h), 1) && String.eq(tg(t), "Lam") &&
    U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) &&
    kc(Bool, U32.is_eq(left, 1), u => j_primitive_type(book, wnf(book, kid(h, 0)), "U32"),
      u => j_callback_fun_type(book, kid(h, 0), "U32")) &&
    j_callback_live_compose_type(book, kid(h, 1), kid(t, 0), U32.sub(left, 1)))

# Check exact composition lambda binders, including erased prefix positions.
@unsafe
def j_callback_compose_on(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +f = j_fusion_binder(dv(d), 3)
  +g = j_fusion_binder(dv(d), 4)
  +x = j_fusion_binder(dv(d), 5)
  +body = j_fusion_after(dv(d), 6)
  +inner = j_strip(kid(body, 1))
  j_fusion_def(d, 5) && j_u32_bounded([dt(d), dv(d)], 2048) &&
    j_callback_erased_prefix(book, dt(d), dv(d), 3) &&
    j_callback_live_compose_type(book, j_specialize(book, dt(d), [ref("U32"), ref("U32"), ref("U32")]), j_fusion_after(dv(d), 3), 3) &&
    String.eq(tg(f), "Lam") && String.eq(tg(g), "Lam") && String.eq(tg(x), "Lam") &&
    String.eq(tg(body), "App") && U32.is_eq(terms_len(ks(body)), 2) &&
    j_fusion_var(kid(body, 0), ix(g)) && String.eq(tg(inner), "App") && U32.is_eq(terms_len(ks(inner)), 2) &&
    j_fusion_var(kid(inner, 0), ix(f)) && j_fusion_var(kid(inner, 1), ix(x))

@unsafe
def j_callback_factory_on(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +z = j_strip(j_fusion_empty(d))
  +s = j_fusion_link(d)
  +p = j_fusion_binder(s, 0)
  +body = j_fusion_after(s, 1)
  +binding = kid(body, 0)
  +call = j_call_spine(kid(body, 1), Nil{})
  +leaf = j_strip(kid(call, 3))
  +recur = j_call_spine(kid(call, 4), Nil{})
  j_fusion_def(d, 1) && j_callback_factory_type(book, dt(d)) && j_u32_bounded([dt(d), dv(d)], 4096) &&
    j_fusion_cases(dv(d), "Zero", "Succ") && String.eq(tg(z), "Lam") &&
    U32.is_eq(terms_len(ks(z)), 1) && j_fusion_var(kid(z, 0), ix(z)) &&
    String.eq(tg(p), "Lam") && String.eq(tg(body), "Let") && U32.is_eq(terms_len(ks(body)), 2) &&
    String.eq(tg(binding), "Bind") && Bool.not(U32.is_eq(qt(binding), 0)) && U32.is_eq(terms_len(ks(binding)), 1) &&
    j_callback_scalar(book, kid(binding, 0), Nil{}, ix(p), 256) &&
    String.eq(tg(call), "Call") && U32.is_eq(terms_len(ks(call)), 5) &&
    j_callback_compose(book, lookup(book, nm(call))) &&
    j_primitive_type(book, wnf(book, kid(call, 0)), "U32") &&
    j_primitive_type(book, wnf(book, kid(call, 1)), "U32") &&
    j_primitive_type(book, wnf(book, kid(call, 2)), "U32") &&
    String.eq(tg(leaf), "Lam") && U32.is_eq(terms_len(ks(leaf)), 1) &&
    j_fusion_scalar(book, kid(leaf, 0), [leaf, binding]) &&
    j_fusion_call(recur, dn(d), 1) && j_fusion_var(kid(recur, 0), ix(p))

@unsafe
def j_callback_private_body(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +factory: KDef, +count: KTerm, +seed: KTerm) -> String:
  +s = j_fusion_link(factory)
  +p = j_fusion_binder(s, 0)
  +body = j_fusion_after(s, 1)
  +binding = kid(body, 0)
  +call = j_call_spine(kid(body, 1), Nil{})
  +leaf = j_strip(kid(call, 3))
  +capture_env = {[kt("Env", "", ix(p), 0, [ref("Nat")])] : List<&2,KTerm>}
  "/* private materialized callback environment */const $cb_pending=[];let $cb_n=BigInt(" ++ j_fusion_expr(book, count, vars) ++ ");" ++
    "while($cb_n!==0n){const " ++ j_local(ix(p)) ++ "=$cb_n-1n;const $cb_capture=" ++
    j_expr(book, capture_env, kid(binding, 0), ref("U32"), False{}) ++ ";$cb_pending.push({tag:1,capture:$cb_capture});$cb_n=" ++ j_local(ix(p)) ++ ";}" ++
    "let $cb_environment={tag:0};while($cb_pending.length){$cb_environment={tag:2,left:$cb_pending.pop(),right:$cb_environment};}" ++
    "let $cb_value=" ++ j_fusion_expr(book, seed, vars) ++ ";while($cb_environment.tag===2){const " ++ j_local(ix(binding)) ++
    "=$cb_environment.left.capture;const " ++ j_local(ix(leaf)) ++ "=$cb_value;$cb_value=" ++
    j_fusion_expr(book, kid(leaf, 0), [binding, leaf]) ++ ";$cb_environment=$cb_environment.right;}return $cb_value;"

@unsafe
def j_callback_root_body(+book: List<&2,KDef>, +d: KDef) -> String:
  +vars = {[j_fusion_binder(dv(d), 0), j_fusion_binder(dv(d), 1)] : List<&2,KTerm>}
  +call = j_call_spine(j_fusion_after(dv(d), 2), Nil{})
  +count = j_call_spine(kid(call, 0), Nil{})
  +factory = lookup(book, nm(call))
  kc(String, j_fusion_def(d, 2) && j_fold_root_signature(book, dt(d), 2) &&
    j_primitive_type(book, j_fold_root_result(book, dt(d), 2), "U32") &&
    String.eq(tg(call), "Call") && U32.is_eq(terms_len(ks(call)), 2) &&
    j_fusion_call(count, "U32.to_nat", 1) && j_primitive_call(book, count) &&
    j_callback_scalar(book, kid(count, 0), vars, 4294967295, 256) &&
    j_callback_scalar(book, kid(call, 1), vars, 4294967295, 256) && j_callback_factory(book, factory),
    u => j_callback_private_body(book, vars, factory, kid(count, 0), kid(call, 1)), u => "")

@unsafe
def j_callback_root(+book: List<&2,KDef>, +d: KDef) -> String:
  +body = kc(String, j_fusion_def(d, 2) && j_region_capture_eligible(book, d) && j_u32_bounded([dt(d), dv(d)], 8192), u => j_callback_root_body(book, d), u => "")
  +call = j_call_spine(j_fusion_after(dv(d), 2), Nil{})
  +factory = lookup(book, nm(call))
  +compose = lookup(book, nm(j_call_spine(kid(j_fusion_after(j_fusion_link(factory), 1), 1), Nil{})))
  +helpers = {[factory, compose] : List<&2,KDef>}
  kc(String, Bool.not(String.eq(body, "")), u =>
    "(()=>{const $guards=[" ++ j_quote(dn(d)) ++ "," ++ j_region_names(helpers) ++ "];return fn(2,exactCode(function(a,$entered){" ++
    j_nat_loop_slots(2, 0) ++ "if($entered&&regionHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, 2, False{}) ++ "&&localGuard($guards)){" ++
    "const $previousProof=regionProofOpen($guards);try{const " ++ j_local(ix(j_fusion_binder(dv(d), 0))) ++ "=$s0;const " ++
    j_local(ix(j_fusion_binder(dv(d), 1))) ++ "=$s1;" ++ body ++ "}finally{regionProofClose($previousProof);}}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()", u => "")

# Snapshot only cheap structurally eligible callable families; do not rerun the
# full new proof on every unrelated emitted definition.
@unsafe
def j_callback_capture_eligible(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, j_fusion_def(d, 1) && String.eq(tg(j_strip(dv(d))), "Mat"), u => j_callback_factory(book, lookup(book, dn(d))), u =>
    kc(Bool, j_fusion_def(d, 5) && String.eq(tg(j_strip(dv(d))), "Lam"), u => j_callback_compose(book, lookup(book, dn(d))), u => False{}))

@unsafe
def j_callback_compose(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, j_fusion_def(d, 5) && String.eq(tg(j_strip(dv(d))), "Lam"),
    u => kc(Bool, j_u32_bounded([dt(d), dv(d)], 2048), u => j_callback_compose_on(book, d), u => False{}), u => False{})

@unsafe
def j_callback_factory(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, j_fusion_def(d, 1) && String.eq(tg(j_strip(dv(d))), "Mat"),
    u => kc(Bool, j_u32_bounded([dt(d), dv(d)], 4096), u => j_callback_factory_on(book, d), u => False{}), u => False{})

# Original checked source book and annotated emitter defs have distinct Lam
# metadata. The formal All telescope owns erasure (as j_lambda_bind does).
# This route admits only the original source Lam q1 spelling and proves its
# erased binder never occurs in runtime syntax; Ann type children are ignored.
@unsafe
def j_callback_runtime_absent(+t: KTerm, +id: U32, +fuel: U32) -> Bool:
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(t), "Ann"), u => j_callback_runtime_absent(kid(t, 0), id, U32.sub(fuel, 1)), u =>
      kc(Bool, String.eq(tg(t), "Var"), u => Bool.not(U32.is_eq(ix(t), id)),
        u => j_callback_runtime_absent_terms(ks(t), id, U32.sub(fuel, 1)))), u => False{})

@unsafe
def j_callback_runtime_absent_terms(+ts: List<&2,KTerm>, +id: U32, +fuel: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, j_callback_runtime_absent(h, id, fuel),
        u => j_callback_runtime_absent_terms(rest, id, fuel), u => False{})
