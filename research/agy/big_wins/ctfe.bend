# AGY-005a: General Bounded Pure Closed-Term Evaluator (CTFE)
# Evaluates pure, safe, 0-arg definitions returning ground Data values
# (U32, Nat, Bool, Char, String, F32) under strict step fuel, rechecking every
# rewritten body with check_definition_body + ka_def.

type CtfeVal is Data:
  CVU32{+n: U32}
  CVNat{+n: U32}
  CVF32{+x: F32}
  CVStr{+s: String}
  CVCtr{+name: String, +fields: List<&2, CtfeVal>}
  CVClo{+env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +term: KTerm}
  CVPrim{+name: String, +arity: U32, +args: List<&2, CtfeVal>}
  CVEra{}
  CVFail{}

type CtfeRes is Data:
  CtfeRes{+val: CtfeVal, +fuel: U32}

type CtfeListRes is Data:
  CtfeListRes{+vals: List<&2, CtfeVal>, +fuel: U32, +ok: Bool}

def ctfe_bits_to_f32(u: U32) -> F32:
  match u:
    case U32{w}: F32{w}

@unsafe
def ctfe_fail(+fuel: U32) -> CtfeRes:
  CtfeRes{CVFail{}, fuel}

@unsafe
def ctfe_is_fail(+v: CtfeVal) -> Bool:
  match v:
    case CVFail{}: True{}
    case _: False{}

@unsafe
def ctfe_bool(+b: Bool) -> CtfeVal:
  CVCtr{kc(String, b, u => "True", u => "False"), []}

@unsafe
def ctfe_cmp(+c: Cmp) -> CtfeVal:
  match c:
    case LT{}: CVCtr{"LT", []}
    case EQ{}: CVCtr{"EQ", []}
    case GT{}: CVCtr{"GT", []}

@unsafe
def ctfe_env_get(+env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +id: U32) -> CtfeVal:
  match env:
    case Nil{}: CVFail{}
    case Con{(bid, val), rest}:
      kc(CtfeVal, U32.is_eq(bid, id), u => val, u => ctfe_env_get(rest, id))

@unsafe
def ctfe_rev_append(xs: List<&2, CtfeVal>, acc: List<&2, CtfeVal>) -> List<&2, CtfeVal>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: ctfe_rev_append(t, Con{h, acc})

@unsafe
def ctfe_prim_arity(+name: String) -> U32:
  kc(U32,
    String.eq(name, "u32_add") || String.eq(name, "u32_sub") || String.eq(name, "u32_mul") ||
    String.eq(name, "u32_div") || String.eq(name, "u32_mod") || String.eq(name, "u32_and") ||
    String.eq(name, "u32_or") || String.eq(name, "u32_xor") || String.eq(name, "u32_shln") ||
    String.eq(name, "u32_shrn") || String.eq(name, "u32_is_eq") || String.eq(name, "u32_is_ne") ||
    String.eq(name, "u32_is_lt") || String.eq(name, "u32_is_le") || String.eq(name, "u32_is_gt") ||
    String.eq(name, "u32_is_ge") || String.eq(name, "u32_cmp") ||
    String.eq(name, "nat_add") || String.eq(name, "nat_sub") || String.eq(name, "nat_mul") ||
    String.eq(name, "nat_div") || String.eq(name, "nat_mod") ||
    String.eq(name, "nat_is_eq") || String.eq(name, "nat_is_lt") || String.eq(name, "nat_is_le") ||
    String.eq(name, "nat_cmp") ||
    String.eq(name, "f32_add") || String.eq(name, "f32_sub") || String.eq(name, "f32_mul") ||
    String.eq(name, "f32_div") || String.eq(name, "f32_is_eq") || String.eq(name, "f32_is_ne") ||
    String.eq(name, "f32_is_lt") || String.eq(name, "f32_is_le") || String.eq(name, "f32_is_gt") ||
    String.eq(name, "f32_is_ge"),
    u => 2,
    u => kc(U32,
      String.eq(name, "u32_inc") || String.eq(name, "u32_dec") || String.eq(name, "u32_is_zero") ||
      String.eq(name, "u32_to_nat") || String.eq(name, "u32_from_nat") || String.eq(name, "u32_to_f32") ||
      String.eq(name, "f32_to_u32") || String.eq(name, "f32_neg") || String.eq(name, "f32_abs") ||
      String.eq(name, "f32_bits"),
      v => 1, v => 0))

law ctfe_as_nat:
  for +v: CtfeVal
  for +acc: U32
  Maybe<&2, U32>

@unsafe
def ctfe_as_nat_succ(fields: List<&2, CtfeVal>, +acc: U32) -> Maybe<&2, U32>:
  match fields:
    case Con{inner, Nil{}}: ctfe_as_nat(inner, U32.inc(acc))
    case _: None{}

@unsafe
def ctfe_as_nat(v, acc):
  match v:
    case CVNat{n}: Some{U32.add(acc, n)}
    case CVCtr{name, fields}:
      kc(Maybe<&2, U32>, String.eq(name, "Zero"), u => Some{acc},
        u => kc(Maybe<&2, U32>, String.eq(name, "Succ"), v => ctfe_as_nat_succ(fields, acc), v => None{}))
    case _: None{}

@unsafe
def ctfe_run_u32_bin(+op: String, +a: U32, +b: U32) -> CtfeVal:
  kc(CtfeVal, String.eq(op, "u32_add"), u => CVU32{U32.add(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "u32_sub"), u => CVU32{U32.sub(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "u32_mul"), u => CVU32{U32.mul(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "u32_div"), u => kc(CtfeVal, U32.is_eq(b, 0), v => CVFail{}, v => CVU32{U32.div(a, b)}), u =>
  kc(CtfeVal, String.eq(op, "u32_mod"), u => kc(CtfeVal, U32.is_eq(b, 0), v => CVFail{}, v => CVU32{U32.mod(a, b)}), u =>
  kc(CtfeVal, String.eq(op, "u32_and"), u => CVU32{U32.and(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "u32_or"), u => CVU32{U32.or(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "u32_xor"), u => CVU32{U32.xor(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "u32_is_eq"), u => ctfe_bool(U32.is_eq(a, b)), u =>
  kc(CtfeVal, String.eq(op, "u32_is_ne"), u => ctfe_bool(U32.is_ne(a, b)), u =>
  kc(CtfeVal, String.eq(op, "u32_is_lt"), u => ctfe_bool(U32.is_lt(a, b)), u =>
  kc(CtfeVal, String.eq(op, "u32_is_le"), u => ctfe_bool(U32.is_le(a, b)), u =>
  kc(CtfeVal, String.eq(op, "u32_is_gt"), u => ctfe_bool(U32.is_gt(a, b)), u =>
  kc(CtfeVal, String.eq(op, "u32_is_ge"), u => ctfe_bool(U32.is_ge(a, b)), u =>
  kc(CtfeVal, String.eq(op, "u32_cmp"), u => ctfe_cmp(U32.cmp(a, b)), u => CVFail{})))))))))))))))

@unsafe
def ctfe_run_nat_bin(+op: String, +a: U32, +b: U32) -> CtfeVal:
  kc(CtfeVal, String.eq(op, "nat_add"), u => kc(CtfeVal, U32.is_le(a, U32.sub(4294967295, b)), v => CVNat{U32.add(a, b)}, v => CVFail{}), u =>
  kc(CtfeVal, String.eq(op, "nat_sub"), u => CVNat{kc(U32, U32.is_lt(a, b), v => 0, v => U32.sub(a, b))}, u =>
  kc(CtfeVal, String.eq(op, "nat_mul"), u => kc(CtfeVal, U32.is_eq(a, 0) || U32.is_le(b, U32.div(4294967295, a)), v => CVNat{U32.mul(a, b)}, v => CVFail{}), u =>
  kc(CtfeVal, String.eq(op, "nat_div"), u => kc(CtfeVal, U32.is_eq(b, 0), v => CVFail{}, v => CVNat{U32.div(a, b)}), u =>
  kc(CtfeVal, String.eq(op, "nat_mod"), u => kc(CtfeVal, U32.is_eq(b, 0), v => CVFail{}, v => CVNat{U32.mod(a, b)}), u =>
  kc(CtfeVal, String.eq(op, "nat_is_eq"), u => ctfe_bool(U32.is_eq(a, b)), u =>
  kc(CtfeVal, String.eq(op, "nat_is_lt"), u => ctfe_bool(U32.is_lt(a, b)), u =>
  kc(CtfeVal, String.eq(op, "nat_is_le"), u => ctfe_bool(U32.is_le(a, b)), u =>
  kc(CtfeVal, String.eq(op, "nat_cmp"), u => ctfe_cmp(U32.cmp(a, b)), u => CVFail{})))))))))

@unsafe
def ctfe_run_f32_bin(+op: String, +a: F32, +b: F32) -> CtfeVal:
  kc(CtfeVal, String.eq(op, "f32_add"), u => CVF32{F32.add(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "f32_sub"), u => CVF32{F32.sub(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "f32_mul"), u => CVF32{F32.mul(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "f32_div"), u => CVF32{F32.div(a, b)}, u =>
  kc(CtfeVal, String.eq(op, "f32_is_eq"), u => ctfe_bool(F32.is_eq(a, b)), u =>
  kc(CtfeVal, String.eq(op, "f32_is_ne"), u => ctfe_bool(F32.is_ne(a, b)), u =>
  kc(CtfeVal, String.eq(op, "f32_is_lt"), u => ctfe_bool(F32.is_lt(a, b)), u =>
  kc(CtfeVal, String.eq(op, "f32_is_le"), u => ctfe_bool(F32.is_le(a, b)), u =>
  kc(CtfeVal, String.eq(op, "f32_is_gt"), u => ctfe_bool(F32.is_gt(a, b)), u =>
  kc(CtfeVal, String.eq(op, "f32_is_ge"), u => ctfe_bool(F32.is_ge(a, b)), u => CVFail{}))))))))))

@unsafe
def ctfe_nat_to_u32(m: Maybe<&2, U32>) -> CtfeVal:
  match m:
    case Some{n}: CVU32{n}
    case None{}: CVFail{}

@unsafe
def ctfe_run_prim1(+op: String, +a: CtfeVal) -> CtfeVal:
  match a:
    case CVU32{x}:
      kc(CtfeVal, String.eq(op, "u32_inc"), u => CVU32{U32.inc(x)}, u =>
      kc(CtfeVal, String.eq(op, "u32_dec"), u => CVU32{U32.sub(x, 1)}, u =>
      kc(CtfeVal, String.eq(op, "u32_is_zero"), u => ctfe_bool(U32.is_eq(x, 0)), u =>
      kc(CtfeVal, String.eq(op, "u32_to_nat"), u => CVNat{x}, u =>
      kc(CtfeVal, String.eq(op, "u32_to_f32"), u => CVF32{U32.to_f32(x)}, u => CVFail{})))))
    case CVF32{x}:
      kc(CtfeVal, String.eq(op, "f32_to_u32"), u => CVU32{F32.to_u32(x)}, u =>
      kc(CtfeVal, String.eq(op, "f32_neg"), u => CVF32{F32.neg(x)}, u =>
      kc(CtfeVal, String.eq(op, "f32_abs"), u => CVF32{F32.abs(x)}, u =>
      kc(CtfeVal, String.eq(op, "f32_bits"), u => CVU32{F32.bits(x)}, u => CVFail{}))))
    case _:
      kc(CtfeVal, String.eq(op, "u32_from_nat"), u => ctfe_nat_to_u32(ctfe_as_nat(a, 0)), u => CVFail{})

@unsafe
def ctfe_run_shift(+op: String, a: CtfeVal, mb: Maybe<&2, U32>) -> CtfeVal:
  match a mb:
    case CVU32{+x} Some{+n}:
      kc(CtfeVal, String.eq(op, "u32_shln"),
        v => CVU32{U32.shln(x, U32.to_nat(n))},
        v => CVU32{U32.shrn(x, U32.to_nat(n))})
    case _ _: CVFail{}

@unsafe
def ctfe_run_nat_opt(+op: String, ma: Maybe<&2, U32>, mb: Maybe<&2, U32>) -> CtfeVal:
  match ma mb:
    case Some{x} Some{y}: ctfe_run_nat_bin(op, x, y)
    case _ _: CVFail{}

@unsafe
def ctfe_run_prim2_vals(+op: String, +a: CtfeVal, +b: CtfeVal) -> CtfeVal:
  match a b:
    case CVU32{x} CVU32{y}: ctfe_run_u32_bin(op, x, y)
    case CVF32{x} CVF32{y}: ctfe_run_f32_bin(op, x, y)
    case _ _: ctfe_run_nat_opt(op, ctfe_as_nat(a, 0), ctfe_as_nat(b, 0))

@unsafe
def ctfe_run_prim2(+op: String, +a: CtfeVal, +b: CtfeVal) -> CtfeVal:
  kc(CtfeVal, String.eq(op, "u32_shln") || String.eq(op, "u32_shrn"),
    u => ctfe_run_shift(op, a, ctfe_as_nat(b, 0)),
    u => ctfe_run_prim2_vals(op, a, b))

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
    u => kc(CtfeRes, String.eq(nm(a), cname),
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
def ctfe_word_bits(+n: U32, +bits: U32) -> CtfeVal:
  kc(CtfeVal, U32.is_eq(bits, 0), u => CVCtr{"WNil", []},
    u => CVCtr{"WCon", [ctfe_bool(U32.is_ne(U32.and(n, 1), 0)), ctfe_word_bits(U32.shrn(n, 1n), U32.sub(bits, 1))]})

law ctfe_bits_to_u32:
  for v: CtfeVal
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

@unsafe
def ctfe_bits_wcon(fields: List<&2, CtfeVal>, +at: U32, +acc: U32) -> Maybe<&2, U32>:
  match fields:
    case Con{CVCtr{+bn, Nil{}}, Con{+rest, Nil{}}}:
      kc(Maybe<&2, U32>, String.eq(bn, "True"),
        z => ctfe_bits_to_u32(rest, U32.inc(at), U32.or(acc, U32.shln(1, U32.to_nat(at)))),
        z => kc(Maybe<&2, U32>, String.eq(bn, "False"),
          q => ctfe_bits_to_u32(rest, U32.inc(at), acc),
          q => None{}))
    case _: None{}

@unsafe
def ctfe_bits_to_u32(v, at, acc):
  match v:
    case CVCtr{+cname, fields}:
      kc(Maybe<&2, U32>, String.eq(cname, "WNil"),
        u => kc(Maybe<&2, U32>, U32.is_eq(at, 32), w => Some{acc}, w => None{}),
        u => kc(Maybe<&2, U32>, String.eq(cname, "WCon") && U32.is_lt(at, 32),
          w => ctfe_bits_wcon(fields, at, acc),
          w => None{}))
    case _: None{}

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
def ctfe_apply(book, fn, arg, fuel):
  kc(CtfeRes, U32.is_eq(fuel, 0), u => ctfe_fail(0), u => ctfe_apply_go(book, fn, arg, U32.sub(fuel, 1)))

law ctfe_eval_list:
  for +book: List<&2, KDef>
  for +env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>
  for xs: List<&2, KTerm>
  for +fuel: U32
  CtfeListRes

@unsafe
def ctfe_eval_list_join(+v: CtfeVal, r: CtfeListRes) -> CtfeListRes:
  match r:
    case CtfeListRes{vs, f2, ok}: CtfeListRes{Con{v, vs}, f2, ok}

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
  kc(CtfeRes, String.eq(dk(d), "ADT"), u => CtfeRes{CVEra{}, fuel}, u =>
    +prim = kc(String, db(d) && Bool.not(du(d)) && U32.is_eq(dx(d), 0), v => nc_primitive_name(name), v => "")
    +pa = kc(U32, String.is_empty(prim), v => 0, v => ctfe_prim_arity(prim))
    kc(CtfeRes, U32.is_gt(pa, 0),
      v => CtfeRes{CVPrim{prim, pa, []}, fuel},
      v => kc(CtfeRes, String.eq(dk(d), "Def") && Bool.not(du(d)) && U32.is_eq(dx(d), 0) &&
        Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) && Bool.not(p98_tag_eq(j_strip(dv(d)), "Absent")),
        w => ctfe_eval(book, [], dv(d), fuel),
        w => ctfe_fail(fuel))))

@unsafe
def ctfe_is_erased_clo(fn: CtfeVal) -> Bool:
  match fn:
    case CVClo{cenv, term}: p98_tag_eq(term, "Lam") && U32.is_eq(qt(term), 0)
    case _: False{}

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
def ctfe_pack_word(+cname: String, +vs: List<&2, CtfeVal>, m: Maybe<&2, U32>) -> CtfeVal:
  match m:
    case Some{+n}: kc(CtfeVal, String.eq(cname, "U32"), u => CVU32{n}, u => CVF32{ctfe_bits_to_f32(n)})
    case None{}: CVCtr{cname, vs}

@unsafe
def ctfe_pack_ctr_one(+cname: String, +vs: List<&2, CtfeVal>) -> CtfeVal:
  match vs:
    case Con{w, Nil{}}: ctfe_pack_word(cname, vs, ctfe_bits_to_u32(w, 0, 0))
    case _: CVCtr{cname, vs}

@unsafe
def ctfe_pack_ctr(+cname: String, +vs: List<&2, CtfeVal>) -> CtfeVal:
  kc(CtfeVal, String.eq(cname, "U32") || String.eq(cname, "F32"),
    u => ctfe_pack_ctr_one(cname, vs),
    u => CVCtr{cname, vs})

@unsafe
def ctfe_eval_ctr(+cname: String, r: CtfeListRes) -> CtfeRes:
  match r:
    case CtfeListRes{+vs, +f2, ok}:
      kc(CtfeRes, ok, v => CtfeRes{ctfe_pack_ctr(cname, vs), f2}, v => CtfeRes{CVFail{}, f2})

@unsafe
def ctfe_eval_lit(+t: KTerm, +fuel: U32) -> CtfeRes:
  +k = nm(t)
  kc(CtfeRes, String.eq(k, "U32"), u => CtfeRes{CVU32{kl_number(t)}, fuel}, u =>
  kc(CtfeRes, String.eq(k, "Nat"), u => CtfeRes{CVNat{kl_number(t)}, fuel}, u =>
  kc(CtfeRes, String.eq(k, "F32"), u => CtfeRes{CVF32{ctfe_bits_to_f32(kl_number(t))}, fuel}, u =>
  kc(CtfeRes, String.eq(k, "String"), u => CtfeRes{CVStr{kl_text(t)}, fuel}, u => ctfe_fail(fuel)))))

@unsafe
def ctfe_eval(book, env, t, fuel):
  kc(CtfeRes, U32.is_eq(fuel, 0), u => ctfe_fail(0), u =>
  kc(CtfeRes, core_literal(t), u => ctfe_eval_lit(t, fuel), u =>
    +tag = tg(t)
    +f1 = U32.sub(fuel, 1)
    kc(CtfeRes, String.eq(tag, "Ann"), u => ctfe_eval(book, env, kid(t, 0), fuel), u =>
    kc(CtfeRes, String.eq(tag, "Var"), u => CtfeRes{ctfe_env_get(env, ix(t)), f1}, u =>
    kc(CtfeRes, String.eq(tag, "Ref"), u => kc(CtfeRes, U32.is_eq(qt(t), 3), v => ctfe_fail(f1), v => ctfe_eval_ref(book, nm(t), f1)), u =>
    kc(CtfeRes, String.eq(tag, "Lam") || String.eq(tag, "Mat"), u => CtfeRes{CVClo{env, t}, f1}, u =>
    kc(CtfeRes, String.eq(tag, "App"), u => ctfe_eval_app(book, env, t, f1), u =>
    kc(CtfeRes, String.eq(tag, "Let"), u => ctfe_eval_let(book, env, ks(t), f1), u =>
    kc(CtfeRes, String.eq(tag, "Ctr"), u => ctfe_eval_ctr(nm(t), ctfe_eval_list(book, env, ks(t), f1)), u =>
    kc(CtfeRes, String.eq(tag, "ADT") || String.eq(tag, "All") || String.eq(tag, "Typ") || String.eq(tag, "Lvl") || String.eq(tag, "Qua") || String.eq(tag, "Era") || String.eq(tag, "Min") || String.eq(tag, "Set") || String.eq(tag, "Eql") || String.eq(tag, "Rfl"),
      u => CtfeRes{CVEra{}, f1},
      u => ctfe_fail(f1)))))))))))

law ctfe_str_val:
  for +v: CtfeVal
  for +limit: U32
  Maybe<&2, String>

@unsafe
def ctfe_str_cons(+code: U32, tail: Maybe<&2, String>) -> Maybe<&2, String>:
  match tail:
    case Some{s}: Some{SCon{Chr{code}, s}}
    case None{}: None{}

@unsafe
def ctfe_str_scon(fields: List<&2, CtfeVal>, +limit: U32) -> Maybe<&2, String>:
  match fields:
    case Con{CVCtr{cn2, Con{CVU32{code}, Nil{}}}, Con{rest, Nil{}}}:
      kc(Maybe<&2, String>, String.eq(cn2, "Chr"),
        w => ctfe_str_cons(code, ctfe_str_val(rest, U32.sub(limit, 1))),
        w => None{})
    case _: None{}

@unsafe
def ctfe_str_val_go(v: CtfeVal, +limit: U32) -> Maybe<&2, String>:
  match v:
    case CVStr{+s}: kc(Maybe<&2, String>, U32.is_le(U32.from_nat(String.length(s)), limit), w => Some{s}, w => None{})
    case CVCtr{+cname, fields}:
      kc(Maybe<&2, String>, String.eq(cname, "SNil"), u => Some{""},
        u => kc(Maybe<&2, String>, String.eq(cname, "SCon"), w => ctfe_str_scon(fields, limit), w => None{}))
    case _: None{}

@unsafe
def ctfe_str_val(v, limit):
  kc(Maybe<&2, String>, U32.is_eq(limit, 0), u => None{}, u => ctfe_str_val_go(v, limit))

@unsafe
def ctfe_reify_u32(v: CtfeVal) -> KTerm:
  match v:
    case CVU32{n}: KLiteral{"U32", n, "", 0, 0}
    case _: atom("Absent")

@unsafe
def ctfe_reify_nat(m: Maybe<&2, U32>) -> KTerm:
  match m:
    case Some{n}: KLiteral{"Nat", n, "", 0, 0}
    case None{}: atom("Absent")

@unsafe
def ctfe_reify_f32(v: CtfeVal) -> KTerm:
  match v:
    case CVF32{x}: KLiteral{"F32", F32.bits(x), "", 0, 0}
    case _: atom("Absent")

@unsafe
def ctfe_reify_bool(v: CtfeVal) -> KTerm:
  match v:
    case CVCtr{+cn, Nil{}}: kc(KTerm, String.eq(cn, "True") || String.eq(cn, "False"), w => kt("Ctr", cn, 0, 1, []), w => atom("Absent"))
    case _: atom("Absent")

@unsafe
def ctfe_reify_char(v: CtfeVal) -> KTerm:
  match v:
    case CVCtr{cn, Con{CVU32{code}, Nil{}}}: kc(KTerm, String.eq(cn, "Chr"), w => kt("Ctr", "Chr", 0, 1, [KLiteral{"U32", code, "", 0, 0}]), w => atom("Absent"))
    case _: atom("Absent")

@unsafe
def ctfe_reify_str(m: Maybe<&2, String>) -> KTerm:
  match m:
    case Some{s}: KLiteral{"String", 0, s, 0, 0}
    case None{}: atom("Absent")

@unsafe
def ctfe_reify(+owner: String, +v: CtfeVal) -> KTerm:
  kc(KTerm, String.eq(owner, "U32"), u => ctfe_reify_u32(v), u =>
  kc(KTerm, String.eq(owner, "Nat"), u => ctfe_reify_nat(ctfe_as_nat(v, 0)), u =>
  kc(KTerm, String.eq(owner, "F32"), u => ctfe_reify_f32(v), u =>
  kc(KTerm, String.eq(owner, "Bool"), u => ctfe_reify_bool(v), u =>
  kc(KTerm, String.eq(owner, "Char"), u => ctfe_reify_char(v), u =>
  kc(KTerm, String.eq(owner, "String"), u => ctfe_reify_str(ctfe_str_val(v, 256)), u => atom("Absent")))))))

@unsafe
def ctfe_is_owner(+t: KTerm, +name: String) -> Bool:
  +h = j_strip(t)
  (p98_tag_eq(h, "Ref") || p98_tag_eq(h, "ADT")) && String.eq(nm(h), name) && U32.is_eq(terms_len(ks(h)), 0)

@unsafe
def ctfe_ground_owner(+ty: KTerm) -> String:
  +t = j_strip(ty)
  kc(String, ctfe_is_owner(t, "U32"), u => "U32", u =>
  kc(String, ctfe_is_owner(t, "Nat"), u => "Nat", u =>
  kc(String, ctfe_is_owner(t, "F32"), u => "F32", u =>
  kc(String, ctfe_is_owner(t, "Bool"), u => "Bool", u =>
  kc(String, ctfe_is_owner(t, "Char"), u => "Char", u =>
  kc(String, ctfe_is_owner(t, "String"), u => "String", u => ""))))))

@unsafe
def ctfe_already_lit(+t: KTerm) -> Bool:
  +s = j_strip(t)
  core_literal(s) || (p98_tag_eq(s, "Ctr") && (String.eq(nm(s), "True") || String.eq(nm(s), "False")))

@unsafe
def ctfe_try_finish(+context: List<&2, KDef>, +raw: KDef, +owner: String, r: CtfeRes) -> KDef:
  match r:
    case CtfeRes{val, rem}:
      +lit = ctfe_reify(owner, val)
      kc(KDef, p98_tag_eq(lit, "Absent"), v => missing(), v => p205u_check(context, raw, lit))

@unsafe
def ctfe_try_def(+context: List<&2, KDef>, +raw: KDef) -> KDef:
  +owner = kc(String, U32.is_eq(da(raw), 0) && Bool.not(ctfe_already_lit(dv(raw))),
    u => ctfe_ground_owner(dt(raw)), u => "")
  kc(KDef, String.is_empty(owner), u => missing(),
    u => ctfe_try_finish(context, raw, owner, ctfe_eval(context, [], dv(raw), 262144)))

@unsafe
def ctfe_decls(+context: List<&2, KDef>, defs: List<&2, KDef>, +edits: KDef) -> KDef:
  match defs:
    case Nil{}: edits
    case Con{+d, rest}:
      +change = kc(KDef, String.eq(dk(d), "Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d), 0) && U32.is_eq(da(d), 0),
        u => ctfe_try_def(context, lookup(context, dn(d))),
        u => missing())
      ctfe_decls(p205z_advance(context, change), rest,
        kc(KDef, String.eq(dk(change), "Absent"), u => edits,
          u => index_set(edits, change, index_hash(dn(change), 2166136261), 32)))

@unsafe
def agy_ctfe_plan(+context: List<&2, KDef>, +stops: List<&2, String>, +verdict: String, +annotated: List<&2, KDef>) -> P86Plan:
  +e1 = ctfe_decls(context, annotated, missing())
  +has_e1 = Bool.not(String.eq(dk(e1), "Absent"))
  +ctx1 = kc(List<&2, KDef>, has_e1, u => p205z_advance(context, e1), u => context)
  +ann1 = kc(List<&2, KDef>, has_e1, u => p205_overlay(annotated, e1), u => annotated)
  +ok1 = has_e1 && String.is_empty(jl_checked_error(ctx1, ann1, ["main"], stops))
  +ctx2 = kc(List<&2, KDef>, ok1, u => ctx1, u => context)
  +ann2 = kc(List<&2, KDef>, ok1, u => ann1, u => annotated)
  p205_ready(ctx2, stops, verdict, ann2, p205u_decls(ctx2, ann2, missing(), False{}))
