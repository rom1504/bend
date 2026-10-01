# Closed two-result structural components share the existing scalar proof.
# Original typed prefixes and tagged values remain; only self calls use frames.
@unsafe
def j_component_plan(+book: List<&2,KDef>, +d: KDef) -> JPure:
  +head = wnf(book, dt(d))
  kc(JPure, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) && String.eq(tg(head), "All"), u =>
    kc(JPure, String.eq(tg(wnf(book, kid(head, 0))), "ADT") && Bool.not(db(lookup(book, nm(wnf(book, kid(head, 0)))))), u =>
    kc(JPure, j_u32_bounded([dv(d)], 512) && Bool.not(j_l_deep(dv(d), 0)), u =>
    kc(JPure, U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u =>
    kc(JPure, j_region_capture_eligible(book, d) &&
      j_component_prefix(book, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0), u =>
        j_component_closed(d, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}})),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}})

# Reject mutual backedges into this worker: forcing such a leaf could otherwise
# nest native worker calls instead of remaining in the runtime tail trampoline.
@unsafe
def j_component_closed(+d: KDef, +pure: JPure) -> JPure:
  kc(JPure, j_pure_valid(pure) && j_component_backedges(j_pure_defs(pure), dn(d)), u => pure,
    u => JPure{Nil{}, 0, False{}})

@unsafe
def j_component_backedges(+ds: List<&2,KDef>, +name: String) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, String.eq(dn(d), name) || U32.is_eq(j_component_refs([dv(d)], name, 8192, 0), 0),
        u => j_component_backedges(rest, name), u => False{})

@unsafe
def j_component_refs(+todo: List<&2,KTerm>, +name: String, +fuel: U32, +count: U32) -> U32:
  match todo:
    case Nil{}: count
    case Con{t, rest}:
      kc(U32, U32.is_eq(fuel, 0) || U32.is_ge(count, 3), u => 3, u =>
        j_component_refs(List.append(&2, KTerm, ks(t), rest), name, U32.sub(fuel, 1),
          U32.add(count, kc(U32, String.eq(tg(t), "Ref") && String.eq(nm(t), name), u => 1, u => 0))))

@unsafe
def j_component_slots(+at: U32, +total: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => Nil{}, u =>
    Con{kc(String, U32.is_eq(at, 0), u => "@root", u => ""), j_component_slots(U32.inc(at), total)})

@unsafe
def j_component_fields(+origin: String, +left: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(left, 0), u => rest, u =>
    Con{kc(String, String.eq(origin, ""), u => "", u => "@child"), j_component_fields(origin, U32.sub(left, 1), rest)})

# Every recursive first argument is a proper field descendant of the first
# original ADT. No caller-provided value is admitted by this compile-time test.
@unsafe
def j_component_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +slots: List<&2,String>, +d: KDef, +depth: U32) -> Bool:
  match slots:
    case Nil{}: j_component_leaf(book, env, j_strip(t), d)
    case Con{origin, rest}:
      +body = j_strip(t)
      +head = wnf(book, ty)
      kc(Bool, U32.is_lt(depth, 32) && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)), u =>
        kc(Bool, String.eq(tg(body), "Lam") && String.eq(j_l_name(body), ""), u =>
          j_component_prefix(book, Con{kt("Env", origin, ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
            subst(kid(head, 1), ix(head), var(nm(body), ix(body))), rest, d, U32.inc(depth)), u =>
        kc(Bool, String.eq(tg(body), "Efq"), u => True{}, u =>
          j_component_match(book, env, body, head, slots, d, depth))), u => False{})

@unsafe
def j_component_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +slots: List<&2,String>, +d: KDef, +depth: U32) -> Bool:
  match slots:
    case Nil{}: False{}
    case Con{origin, rest}:
      +arg = wnf(book, kid(ty, 0))
      +owner = lookup(book, nm(arg))
      +c = lookup(dc(owner), nm(t))
      kc(Bool, String.eq(tg(t), "Mat") && String.eq(j_l_name(t), "") && U32.is_eq(terms_len(ks(t)), 2) &&
        String.eq(dk(c), "Ctr") && (j_primitive_type(book, arg, "Bool") || (Bool.not(db(owner)) && Bool.not(db(c)))), u =>
        j_component_prefix(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), j_component_fields(origin, da(c), rest), d, U32.inc(depth)) &&
        j_component_prefix(book, env, kid(t, 1), ty, slots, d, U32.inc(depth)), u => False{})

@unsafe
def j_component_origin(+env: List<&2,KTerm>, +id: U32) -> String:
  match env:
    case Nil{}: ""
    case Con{h, rest}: kc(String, U32.is_eq(ix(h), id), u => nm(h), u => j_component_origin(rest, id))

@unsafe
def j_component_self(+env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  +spine = j_call_spine(j_strip(t), Nil{})
  +first = j_strip(kid(spine, 0))
  String.eq(tg(spine), "Call") && String.eq(nm(spine), dn(d)) && U32.is_eq(terms_len(ks(spine)), da(d)) &&
    String.eq(tg(first), "Var") && String.eq(j_component_origin(env, ix(first)), "@child")

@unsafe
def j_component_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  +calls = j_component_refs([t], dn(d), 1024, 0)
  kc(Bool, U32.is_eq(calls, 0), u => True{}, u =>
    kc(Bool, U32.is_eq(calls, 2) && String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 3), u =>
      j_nat_loop_bindings(ks(t), 0, Nil{}) && Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) && Bool.not(U32.is_eq(qt(kid(t, 1)), 0)) &&
      j_component_self(env, kid(kid(t, 0), 0), d) && j_component_self(env, kid(kid(t, 1), 0), d), u => False{}))

# Calls keep the existing generic fallback and require the COMPLETE graph,
# rather than just the immediate function's descriptor, in the active proof.
@unsafe
def j_component_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String) -> String:
  +d = lookup(book, nm(spine))
  kc(String, U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    j_component_call(book, env, spine, generic, j_component_plan(book, d)), u => generic)

@unsafe
def j_component_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    "(regionProof!==null&&regionProofCovers([" ++ j_region_names(j_pure_defs(pure)) ++ "])?" ++
      j_region_name(nm(spine)) ++ "$tree(" ++ j_apply_args(book, env, ks(spine), dt(lookup(book, nm(spine)))) ++ "):" ++ generic ++ ")", u => generic)

@unsafe
def j_component_declaration(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    "function " ++ j_region_name(dn(d)) ++ "$tree(" ++ j_region_parameters(0, da(d)) ++ "){/* private structural component */" ++
    j_region_nested_slots(0, da(d)) ++ "const $frames=[];let $top=0,$value;$visit:for(;;){$step:{" ++
    j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 0) ++ "}" ++
    "while($top){const $frame=$frames[$top-1];" ++ j_component_restore(0, da(d)) ++
    "if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++
    j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 1) ++ "}else{" ++
    j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 2) ++ "--$top;}}return $value;}}\n", u => "")

@unsafe
def j_component_values(+at: U32, +total: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => Nil{}, u => Con{"$s" ++ U32.show(at), j_component_values(U32.inc(at), total)})

@unsafe
def j_component_restore(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => "$s" ++ U32.show(at) ++ "=$frame.args[" ++ U32.show(at) ++ "];" ++ j_component_restore(U32.inc(at), total))

@unsafe
def j_component_save(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => "$s" ++ U32.show(at) ++ "," ++ j_component_save(U32.inc(at), total))

# Prefix emission repeats only inert private reads on resume. Leaf work occurs
# once; each child argument vector is evaluated at its original source phase.
@unsafe
def j_component_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>, +d: KDef, +phase: U32) -> String:
  match args:
    case Nil{}: j_component_finish(book, env, j_strip(t), wnf(book, ty), d, phase)
    case Con{arg, rest}:
      +body = j_strip(t)
      +head = wnf(book, ty)
      kc(String, String.eq(tg(body), "Lam"), u =>
        "const " ++ j_local(ix(body)) ++ "=" ++ arg ++ ";" ++
        j_component_emit(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
          subst(kid(head, 1), ix(head), var(nm(body), ix(body))), rest, d, phase), u =>
      kc(String, String.eq(tg(body), "Mat"), u => j_component_emit_match(book, env, body, head, arg, rest, d, phase),
        u => "return bad('private component prefix invariant');"))

@unsafe
def j_component_emit_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>, +d: KDef, +phase: U32) -> String:
  +input = wnf(book, kid(ty, 0))
  +c = lookup(dc(lookup(book, nm(input))), nm(t))
  "if(" ++ kc(String, j_primitive_type(book, input, "Bool"),
    u => "(" ++ arg ++ ")===" ++ kc(String, String.eq(nm(t), "True"), u => "true", u => "false"),
    u => "(" ++ arg ++ ").$===" ++ j_quote(nm(t))) ++ "){" ++
    j_component_emit(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), j_finite_fields(arg, 0, da(c), rest), d, phase) ++ "}else{" ++
    j_component_emit(book, env, kid(t, 1), ty, Con{arg, rest}, d, phase) ++ "}"

@unsafe
def j_component_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32) -> String:
  kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 0), u =>
    kc(String, U32.is_eq(phase, 0), u => "$value=" ++ j_expr(book, env, t, ty, False{}) ++ ";break $step;",
      u => "return bad('private component continuation invariant');"), u =>
    kc(String, U32.is_eq(phase, 2), u =>
      "const " ++ j_local(ix(kid(t, 0))) ++ "=$frame.left;const " ++ j_local(ix(kid(t, 1))) ++ "=$value;" ++
      "$value=" ++ j_expr(book, j_context(book, env, ks(t)), kid(t, 2), ty, False{}) ++ ";", u =>
      j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase)))

@unsafe
def j_component_enter(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +d: KDef, +phase: U32) -> String:
  "const $next=[" ++ j_apply_args(book, env, ks(spine), dt(d)) ++ "];" ++
    kc(String, U32.is_eq(phase, 0), u =>
      "let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={args:null,left:null,phase:0};" ++
      "$saved.args=[" ++ j_component_save(0, da(d)) ++ "];$saved.left=null;$saved.phase=0;++$top;", u => "") ++
    j_component_assign(0, da(d)) ++ "continue $visit;"

@unsafe
def j_component_assign(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => "$s" ++ U32.show(at) ++ "=$next[" ++ U32.show(at) ++ "];" ++ j_component_assign(U32.inc(at), total))
