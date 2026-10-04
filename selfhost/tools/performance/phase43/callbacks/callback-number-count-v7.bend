# The source proof admits from_nat only on the predecessor. Inside a bounded
# U32 countdown its exact U32 image is the already numeric predecessor.
@unsafe
def j_callback_capture_u32(+t: KTerm) -> KTerm:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(KTerm, j_fusion_call(s, "U32.from_nat", 1), u => kid(s, 0), u =>
    kc(KTerm, String.eq(tg(s), "Call"),
      u => k_with_children(s, j_callback_capture_u32_terms(ks(s))), u => h))

@unsafe
def j_callback_capture_u32_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_callback_capture_u32(h), j_callback_capture_u32_terms(rest)}

# Both paths reuse original scalar source expressions and semantic n-to-1 order.
@unsafe
def j_callback_application_loop(+book: List<&2,KDef>, +factory: KDef, +number: Bool) -> String:
  +s = j_fusion_link(factory)
  +p = j_fusion_binder(s, 0)
  +body = j_fusion_after(s, 1)
  +binding = kid(body, 0)
  +call = j_call_spine(kid(body, 1), Nil{})
  +leaf = j_strip(kid(call, 3))
  +capture = kc(KTerm, number, u => j_callback_capture_u32(kid(binding, 0)), u => kid(binding, 0))
  +capture_env = {[kt("Env", "", ix(p), 0, [ref(kc(String, number, u => "U32", u => "Nat"))])] : List<&2,KTerm>}
  "while($cb_n!==" ++ kc(String, number, u => "0", u => "0n") ++ "){const " ++ j_local(ix(p)) ++
    "=$cb_n-" ++ kc(String, number, u => "1", u => "1n") ++ ";const $cb_capture=" ++
    j_expr(book, capture_env, capture, ref("U32"), False{}) ++ ";const " ++ j_local(ix(binding)) ++ "=$cb_capture;const " ++
    j_local(ix(leaf)) ++ "=$cb_value;$cb_value=" ++ j_fusion_expr(book, kid(leaf, 0), [binding, leaf]) ++
    ";$cb_n=" ++ j_local(ix(p)) ++ ";}"

@unsafe
def j_callback_private_body(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +factory: KDef, +count: KTerm, +seed: KTerm) -> String:
  "/* private total-U32 callback construction/application fusion */const $cb_count=" ++ j_fusion_expr(book, count, vars) ++
    ";let $cb_value=" ++ j_fusion_expr(book, seed, vars) ++ ";" ++
    "if(typeof $cb_count===\"number\"&&Number.isInteger($cb_count)&&$cb_count>=0&&$cb_count<=4294967295){" ++
    "/* private callback U32 countdown */let $cb_n=$cb_count;" ++ j_callback_application_loop(book, factory, True{}) ++
    "}else{/* private callback BigInt countdown fallback */let $cb_n=BigInt($cb_count);" ++
    j_callback_application_loop(book, factory, False{}) ++ "}return $cb_value;"
