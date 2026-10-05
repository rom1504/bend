# Match lowering consumes a live scrutinee once, opens live constructor fields
# in source order, and leaves arm execution under the selected branch. Nested
# blocks and lexical environment depth give every matcher a hygienic temporary.

@unsafe
def jd_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> String:
  kc(String, String.eq(tg(t), "Efq"), u => "throw \"bend: runtime fail-stop\";",
    u => jd_match_args(book, env, t, wnf(book, ty), args))

@unsafe
def jd_match_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>) -> String:
  match args:
    case Nil{}: "return " ++ jd_fail("matcher without a live argument") ++ ";"
    case Con{arg, rest}:
      kc(String, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)),
        u => jd_match_type(book, env, t, ty, wnf(book, kid(ty, 0)), arg, rest),
        u => "return " ++ jd_fail("matcher needs a live function telescope") ++ ";")

@unsafe
def jd_match_type(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +arg: String, +rest: List<&2,String>) -> String:
  kc(String, String.eq(tg(domain), "ADT"),
    u => kc(String, jd_native_layout(book, domain) && String.eq(nm(domain), "Nat"),
      v => jd_nat_start(book, env, t, ty, arg, rest),
      v => jd_match_ctor(book, env, t, ty, domain, arg, rest, j_layout_ctor(book, domain, nm(t)))),
    u => "return " ++ jd_fail("matcher needs a checked datatype") ++ ";")

@unsafe
def jd_match_ctor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +arg: String, +rest: List<&2,String>, +ctor: KDef) -> String:
  kc(String, String.eq(dk(ctor), "Ctr"),
    u => jd_match_emit(book, env, t, ty, domain, arg, rest,
      j_specialize(book, dt(ctor), ks(domain))),
    u => "return " ++ jd_fail("missing match constructor telescope") ++ ";")

@unsafe
def jd_match_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +arg: String, +rest: List<&2,String>, +tel: KTerm) -> String:
  jd_match_emit_at(book, Con{kt("$JD.MatchScope", "", 4294967294, 0, Nil{}), env}, t, ty, domain, arg, rest, tel, "$match" ++ U32.show(terms_len(env)))

@unsafe
def jd_match_emit_at(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +domain: KTerm, +arg: String, +rest: List<&2,String>, +tel: KTerm, +value: String) -> String:
  +native = jd_native_layout(book, domain)
  +condition = kc(String, native, u => jd_match_test(nm(domain), nm(t), value), u => value ++ ".$===" ++ j_quote(nm(t)))
  +fields = kc(List<&2,String>, native, u => jd_match_views(nm(domain), nm(t), value), u => jd_match_fields(tel, value))
  +arm = kc(String, native && (String.eq(nm(domain), "U32") || String.eq(nm(domain), "F32")) && j_u32_native_book(book),
    u => jd_word_start(book, env, kid(t, 0), j_arm_tel(book, tel, kid(ty, 1)), rest, value, String.eq(nm(domain), "F32")),
    u => jd_body(book, env, kid(t, 0), j_arm_tel(book, tel, kid(ty, 1)), List.append(&2,String, fields, rest)))
  "{const " ++ value ++ "=" ++ arg ++ ";" ++
    kc(String, String.eq(nm(domain), "IO.OP"), u => "if(" ++ value ++ ".$===\"$FFI\")throw " ++ value ++ ";", u => "") ++
    kc(String, U32.is_eq(j_constructor_count(book, domain), 1) || String.eq(condition, ""),
      u => arm,
      u => "if(" ++ condition ++ "){" ++ arm ++ "}else{" ++ jd_body(book, env, kid(t, 1), ty, Con{value, rest}) ++ "}") ++ "}"

@unsafe
def jd_match_fields(+tel: KTerm, +value: String) -> List<&2,String>:
  kc(List<&2,String>, String.eq(tg(tel), "All"),
    u => kc(List<&2,String>, U32.is_eq(qt(tel), 0),
      v => jd_match_fields(kid(tel, 1), value),
      v => Con{value ++ "[" ++ j_quote(nm(tel)) ++ "]", jd_match_fields(kid(tel, 1), value)}),
    u => Nil{})

@unsafe
def jd_match_test(+owner: String, +name: String, +value: String) -> String:
  kc(String, String.eq(owner, "Nat"),
    u => kc(String, String.eq(name, "Zero"), v => value ++ "===0", v => value ++ "!==0"), u =>
  kc(String, String.eq(owner, "Bool"),
    u => kc(String, String.eq(name, "True"), v => value, v => "!" ++ value), u =>
  kc(String, String.eq(owner, "String"),
    u => kc(String, String.eq(name, "SNil"), v => value ++ "===\"\"", v => value ++ "!==\"\""), u =>
  kc(String, String.eq(owner, "Array"),
    u => kc(String, String.eq(name, "ALeaf"), v => value ++ ".length===1", v => value ++ ".length!==1"),
    u => ""))))

@unsafe
def jd_match_views(+owner: String, +name: String, +value: String) -> List<&2,String>:
  kc(List<&2,String>, String.eq(owner, "Nat"),
    u => kc(List<&2,String>, String.eq(name, "Zero"), v => Nil{}, v => ["(" ++ value ++ "-1)"]), u =>
  kc(List<&2,String>, String.eq(owner, "Bool"), u => Nil{}, u =>
  kc(List<&2,String>, String.eq(owner, "U32"), u => ["u32_to_word(" ++ value ++ ")"], u =>
  kc(List<&2,String>, String.eq(owner, "F32"), u => ["u32_to_word(f32_bits(" ++ value ++ "))"], u =>
  kc(List<&2,String>, String.eq(owner, "Char"), u => [value ++ ".codePointAt(0)"], u =>
  kc(List<&2,String>, String.eq(owner, "String"),
    u => kc(List<&2,String>, String.eq(name, "SNil"), v => Nil{},
      v => ["(" ++ value ++ ".codePointAt(0)>0xFFFF?" ++ value ++ ".slice(0,2):" ++ value ++ "[0])", "(" ++ value ++ ".codePointAt(0)>0xFFFF?" ++ value ++ ".slice(2):" ++ value ++ ".slice(1))"]), u =>
  kc(List<&2,String>, String.eq(owner, "Array"),
    u => kc(List<&2,String>, String.eq(name, "ALeaf"), v => [value ++ "[0]"],
      v => [value ++ ".slice(0," ++ value ++ ".length>>1)", value ++ ".slice(" ++ value ++ ".length>>1)"]),
    u => [jd_fail("unsupported native match")])))))))

# Numeric rows mirror upstream mat_lits: a row records the known low bits,
# original arm/type, and its demanded Word fields. Inherited default coverage
# is compared after replaying constructor-prefix substitution, avoiding a
# duplicated default at each bit. F32 conversion stays at each demanded row
# condition/view; it is never cached across rows.
type JDWordRow is Data:
  JDWordRow{+term: KTerm, +typ: KTerm, +depth: U32, +value: U32, +fields: U32}

type JDWordCover is Data:
  JDWordCover{+term: KTerm, +fields: U32, +prefix: List<&2,KTerm>}

# Native Nat rows compare the original scrutinee at every literal alternative.
# A predecessor subtraction is a demanded arm view, never an intermediate test.
# This mirrors mat_nats, including the final unconditional fallback row.
@unsafe
def jd_nat_start(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>) -> String:
  +value = "$match" ++ U32.show(terms_len(env))
  "{const " ++ value ++ "=" ++ arg ++ ";" ++
    jd_nat_emit(book, Con{kt("$JD.MatchScope", "", 4294967294, 0, Nil{}), env}, rest, value,
      jd_nat_rows(book, j_strip(t), ty, 0)) ++ "}"

@unsafe
def jd_nat_rows(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +level: U32) -> List<&2,JDWordRow>:
  jd_nat_parts(book, ty, level, jd_nat_arm(t, "Zero"), jd_nat_arm(t, "Succ"), jd_word_end(t))

@unsafe
def jd_nat_arm(+t: KTerm, +name: String) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Mat"),
    u => kc(KTerm, String.eq(nm(t), name), v => kid(t, 0), v => jd_nat_arm(j_strip(kid(t, 1)), name)),
    u => atom("Absent"))

@unsafe
def jd_nat_parts(+book: List<&2,KDef>, +ty: KTerm, +level: U32, +zero: KTerm, +succ: KTerm, +end: KTerm) -> List<&2,JDWordRow>:
  +head: JDWordRow = kc(JDWordRow, String.eq(tg(zero), "Absent"),
    u => JDWordRow{end, ty, 64, level, 1},
    u => JDWordRow{zero, j_arm_type(book, wnf(book, ty), "Zero"), 64, level, 0})
  Con{head, kc(List<&2,JDWordRow>, String.eq(tg(succ), "Absent"),
    u => [JDWordRow{end, ty, 0, level, 1}],
    u => jd_nat_next(book, j_strip(succ), j_arm_type(book, wnf(book, ty), "Succ"), U32.inc(level)))}

@unsafe
def jd_nat_next(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +level: U32) -> List<&2,JDWordRow>:
  kc(List<&2,JDWordRow>, String.eq(tg(t), "Mat"),
    u => jd_nat_rows(book, t, ty, level), u => [JDWordRow{t, ty, 0, level, 1}])

@unsafe
def jd_nat_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,String>, +value: String, +rows: List<&2,JDWordRow>) -> String:
  match rows:
    case Nil{}: "throw \"bend: runtime fail-stop\";"
    case Con{row, Nil{}}: jd_nat_row_body(book, env, rest, value, row)
    case Con{row, more}:
      "if(" ++ jd_nat_row_test(value, row) ++ "){" ++ jd_nat_row_body(book, env, rest, value, row) ++
        "}else{" ++ jd_nat_emit(book, env, rest, value, more) ++ "}"

@unsafe
def jd_nat_row_test(+value: String, +row: JDWordRow) -> String:
  match row:
    case JDWordRow{term, typ, depth, number, fields}: value ++ "===" ++ U32.show(number)

@unsafe
def jd_nat_row_body(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,String>, +value: String, +row: JDWordRow) -> String:
  match row:
    case JDWordRow{term, typ, depth, number, fields}:
      jd_body(book, env, term, typ, List.append(&2,String,
        kc(List<&2,String>, U32.is_eq(fields, 0), u => Nil{}, u => ["(" ++ value ++ "-" ++ U32.show(number) ++ ")"]), rest))

@unsafe
def jd_word_start(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +rest: List<&2,String>, +value: String, +float: Bool) -> String:
  jd_word_emit(book, env, rest, kc(String, float, u => "f32_bits(" ++ value ++ ")", u => value),
    jd_word_rows(book, j_strip(t), ty, 0, 0, JDWordCover{atom("Absent"), 0, Nil{}}))

@unsafe
def jd_word_rows(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +depth: U32, +value: U32, +cover: JDWordCover) -> List<&2,JDWordRow>:
  kc(List<&2,JDWordRow>, String.eq(tg(t), "Mat"),
    u => kc(List<&2,JDWordRow>, U32.is_eq(depth, 32),
      v => [JDWordRow{kid(t, 0), j_arm_type(book, wnf(book, ty), nm(t)), depth, value, 0}],
      v => jd_word_parts(book, j_strip(kid(t, 0)), j_arm_type(book, wnf(book, ty), nm(t)), depth, value, 2, cover)),
    u => jd_word_parts(book, t, ty, depth, value, 1, cover))

@unsafe
def jd_word_parts(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +depth: U32, +value: U32, +fields: U32, +cover: JDWordCover) -> List<&2,JDWordRow>:
  +end = jd_word_end(t)
  +own = kc(Bool, U32.is_lt(jd_word_arms(t), 2),
    u => jd_word_cover_diff(cover, JDWordCover{end, fields, Nil{}}), u => False{})
  List.append(&2, JDWordRow,
    jd_word_branches(book, t, ty, depth, value,
      kc(JDWordCover, own, u => JDWordCover{end, fields, Nil{}}, u => cover)),
    kc(List<&2,JDWordRow>, own, u => [JDWordRow{end, ty, depth, value, fields}], u => Nil{}))

@unsafe
def jd_word_branches(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +depth: U32, +value: U32, +cover: JDWordCover) -> List<&2,JDWordRow>:
  kc(List<&2,JDWordRow>, String.eq(tg(t), "Mat"),
    u => List.append(&2, JDWordRow,
      jd_word_rows(book, j_strip(kid(t, 0)), j_arm_type(book, wnf(book, ty), nm(t)), U32.inc(depth),
        U32.add(value, kc(U32, String.eq(nm(t), "True"),
          v => U32.shln(1, U32.to_nat(depth)), v => 0)), jd_word_cover_push(cover, nm(t))),
      jd_word_branches(book, j_strip(kid(t, 1)), ty, depth, value, cover)),
    u => Nil{})

@unsafe
def jd_word_arms(+t: KTerm) -> U32:
  kc(U32, String.eq(tg(t), "Mat"), u => U32.inc(jd_word_arms(j_strip(kid(t, 1)))), u => 0)

@unsafe
def jd_word_end(+t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Mat"), u => jd_word_end(j_strip(kid(t, 1))), u => t)

@unsafe
def jd_word_cover_push(+cover: JDWordCover, +name: String) -> JDWordCover:
  match cover:
    case JDWordCover{term, fields, prefix}:
      JDWordCover{term, fields, List.append(&2,KTerm, prefix, [kt("Ctr", name, 0, 0, Nil{})])}

@unsafe
def jd_word_cover_diff(+outer: JDWordCover, +inner: JDWordCover) -> Bool:
  match outer:
    case JDWordCover{term, fields, prefix}:
      kc(Bool, String.eq(tg(term), "Absent"), u => True{}, u =>
        Bool.not(String.eq(jd_word_cover_key(outer), jd_word_cover_key(inner))))

@unsafe
def jd_word_cover_key(+cover: JDWordCover) -> String:
  term_key(jd_word_unann(jd_word_cover_apply(cover,
    kt("Ctr", "WCon", 0, 0, [var("$bit", 4294967264), var("$tail", 4294967265)]))))

@unsafe
def jd_word_cover_apply(+cover: JDWordCover, +word: KTerm) -> KTerm:
  match cover:
    case JDWordCover{term, fields, prefix}:
      jd_word_cover_args(term, fields, jd_word_prefix(prefix, word))

@unsafe
def jd_word_cover_args(+t: KTerm, +fields: U32, +word: KTerm) -> KTerm:
  kc(KTerm, U32.is_eq(fields, 1), u => core_apply(j_strip(t), word),
    u => core_apply(j_strip(core_apply(j_strip(t), kid(word, 0))), kid(word, 1)))

@unsafe
def jd_word_prefix(+prefix: List<&2,KTerm>, +tail: KTerm) -> KTerm:
  match prefix:
    case Nil{}: tail
    case Con{bit, rest}: kt("Ctr", "WCon", 0, 0, [bit, jd_word_prefix(rest, tail)])

@unsafe
def jd_word_unann(+t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u => jd_word_unann(kid(t, 0)),
    u => k_rebuild(t, nm(t), ix(t), qt(t), jd_word_unanns(ks(t)), rm(t), kb(t), ke(t)))

@unsafe
def jd_word_unanns(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{jd_word_unann(t), jd_word_unanns(rest)}

@unsafe
def jd_word_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,String>, +bits: String, +rows: List<&2,JDWordRow>) -> String:
  match rows:
    case Nil{}: "throw \"bend: runtime fail-stop\";"
    case Con{row, Nil{}}: jd_word_row_body(book, env, rest, bits, row)
    case Con{row, more}:
      "if(" ++ jd_word_row_test(bits, row) ++ "){" ++ jd_word_row_body(book, env, rest, bits, row) ++
        "}else{" ++ jd_word_emit(book, env, rest, bits, more) ++ "}"

@unsafe
def jd_word_row_test(+bits: String, +row: JDWordRow) -> String:
  match row:
    case JDWordRow{term, typ, depth, value, fields}:
      kc(String, U32.is_eq(depth, 32), u => bits ++ "==" ++ U32.show(value),
        u => "(" ++ bits ++ "&" ++ U32.show(U32.sub(U32.shln(1, U32.to_nat(depth)), 1)) ++ ")==" ++ U32.show(value))

@unsafe
def jd_word_row_body(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,String>, +bits: String, +row: JDWordRow) -> String:
  match row:
    case JDWordRow{term, typ, depth, value, fields}:
      jd_body(book, env, term, typ, List.append(&2,String,
        kc(List<&2,String>, U32.is_eq(fields, 0), u => Nil{}, u =>
          kc(List<&2,String>, U32.is_eq(fields, 1), v => [jd_word_view(bits, depth)],
            v => [jd_word_view(bits, depth) ++ "[\"head\"]", jd_word_view(bits, U32.inc(depth))])), rest))

@unsafe
def jd_word_view(+bits: String, +depth: U32) -> String:
  "u32_to_word(" ++ bits ++ ")" ++ jd_word_tails(depth)

@unsafe
def jd_word_tails(+depth: U32) -> String:
  kc(String, U32.is_eq(depth, 0), u => "", u => "[\"tail\"]" ++ jd_word_tails(U32.sub(depth, 1)))
