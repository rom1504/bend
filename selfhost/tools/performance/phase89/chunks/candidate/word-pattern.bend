# Lower fixed-width scalar patterns as rows of known low bits. Coverage compares
# the flattener's reconstructed defaults modulo bound-variable names. No source
# names are special: U32/F32 wrappers supply the same 32-bit Word representation.
type NW_Rows is Data:
  NW_Rows{+valid: Bool, +rows: List<&2, KTerm>}

type NW_Arms is Data:
  NW_Arms{+zero: KTerm, +one: KTerm, +end: KTerm, +hasZero: Bool, +hasOne: Bool, +valid: Bool}

type NW_Cover is Data:
  NW_None{}
  NW_Cover{+body: KTerm, +bits: List<&2, KTerm>, +fields: U32}

@unsafe
def nw_var_same(+a: U32, +b: U32, pairs: List<&2, KTerm>) -> Bool:
  match pairs:
    case Nil{}: U32.is_eq(a, b)
    case Con{+p, rest}:
      nt_choose(Bool, U32.is_eq(ix(p), a), u => U32.is_eq(qt(p), b),
        u => nt_choose(Bool, U32.is_eq(qt(p), b), v => False{}, v => nw_var_same(a, b, rest)))

law nw_same:
  for +a: KTerm
  for +b: KTerm
  for +pairs: List<&2, KTerm>
  Bool

@unsafe
def nw_same_list(as: List<&2, KTerm>, bs: List<&2, KTerm>, +pairs: List<&2, KTerm>) -> Bool:
  match as, bs:
    case Nil{}, Nil{}: True{}
    case Con{a, ar}, Con{b, br}: nt_choose(Bool, nw_same(a, b, pairs), u => nw_same_list(ar, br, pairs), u => False{})
    case _, _: False{}

@unsafe
def nw_same(a, b, pairs):
  nt_choose(Bool, String.eq(tg(a), tg(b)) && U32.is_eq(qt(a), qt(b)),
    u => nt_choose(Bool, String.eq(tg(a), "Var"),
      v => nw_var_same(ix(a), ix(b), pairs) && List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b)),
      v => nt_choose(Bool, String.eq(tg(a), "Lam") && U32.is_eq(terms_len(ks(a)), 1) && U32.is_eq(terms_len(ks(b)), 1),
        w => nw_same(kid(a, 0), kid(b, 0), Con{kt("NWPair", "", ix(a), ix(b), Nil{}), pairs}),
        w => norm_exact_head(a, b) && nw_same_list(ks(a), ks(b), pairs))), u => False{})

@unsafe
def nw_arms(+t: KTerm, +zero: KTerm, +one: KTerm, +hasZero: Bool, +hasOne: Bool) -> NW_Arms:
  nt_choose(NW_Arms, String.eq(tg(t), "Mat"),
    u => nt_choose(NW_Arms, U32.is_eq(ix(t), 1) && U32.is_eq(terms_len(ks(t)), 2),
      v => nt_choose(NW_Arms, String.eq(nm(t), "False") && Bool.not(hasZero),
        w => nw_arms(kid(t, 1), kid(t, 0), one, True{}, hasOne),
        w => nt_choose(NW_Arms, String.eq(nm(t), "True") && Bool.not(hasOne),
          x => nw_arms(kid(t, 1), zero, kid(t, 0), hasZero, True{}),
          x => NW_Arms{zero, one, t, hasZero, hasOne, False{}})),
      v => NW_Arms{zero, one, t, hasZero, hasOne, False{}}),
    u => NW_Arms{zero, one, t, hasZero, hasOne, True{}})

@unsafe
def nw_word(+bit: KTerm, +tail: KTerm) -> KTerm:
  kt("Ctr", "WCon", 0, 1, [bit, tail])

@unsafe
def nw_rebuild(bits: List<&2, KTerm>, +word: KTerm) -> KTerm:
  match bits:
    case Nil{}: word
    case Con{h, rest}: nw_rebuild(rest, nw_word(h, word))

@unsafe
def nw_apply(+body: KTerm, +word: KTerm, +fields: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(fields, 2),
    u => core_apply(core_apply(body, kid(word, 0)), kid(word, 1)),
    u => core_apply(body, word))

@unsafe
def nw_covered(+body: KTerm, +fields: U32, cover: NW_Cover) -> Bool:
  match cover:
    case NW_None{}: False{}
    case NW_Cover{prior, bits, priorFields}:
      +word = nw_word(atom("NWBitProbe"), atom("NWTailProbe"))
      nw_same(nw_apply(body, word, fields), nw_apply(prior, nw_rebuild(bits, word), priorFields), Nil{})

@unsafe
def nw_descend(cover: NW_Cover, +bit: U32) -> NW_Cover:
  match cover:
    case NW_None{}: NW_None{}
    case NW_Cover{body, bits, fields}: NW_Cover{body, Con{kt("NWord", U32.show(bit), 0, 0, Nil{}), bits}, fields}

@unsafe
def nw_join(a: NW_Rows, b: NW_Rows) -> NW_Rows:
  match a, b:
    case NW_Rows{av, ar}, NW_Rows{bv, br}: NW_Rows{av && bv, List.append(&2, KTerm, ar, br)}

@unsafe
def nw_row(+body: KTerm, +depth: U32, +value: U32, +fields: U32) -> KTerm:
  kt("NWRow", U32.show(value), depth, fields, [body])

law nw_walk:
  for +t: KTerm
  for +depth: U32
  for +value: U32
  for +cover: NW_Cover
  NW_Rows

@unsafe
def nw_branch(+t: KTerm, +depth: U32, +value: U32, +cover: NW_Cover, +bit: U32, +present: Bool) -> NW_Rows:
  nt_choose(NW_Rows, present,
    u => nw_walk(t, U32.inc(depth), U32.or(value, U32.shln(bit, U32.to_nat(depth))), nw_descend(cover, bit)),
    u => NW_Rows{True{}, Nil{}})

@unsafe
def nw_bits(+depth: U32, +value: U32, +cover: NW_Cover, arms: NW_Arms) -> NW_Rows:
  match arms:
    case NW_Arms{zero, one, +end, +hasZero, +hasOne, valid}:
      nt_choose(NW_Rows, valid && (hasZero || hasOne),
        u => nw_bits_ready(zero, one, end, hasZero, hasOne, depth, value, cover, Bool.not(hasZero && hasOne) && Bool.not(nw_covered(end, 2, cover))),
        u => NW_Rows{False{}, Nil{}})

@unsafe
def nw_bits_ready(+zero: KTerm, +one: KTerm, +end: KTerm, +hasZero: Bool, +hasOne: Bool, +depth: U32, +value: U32, +cover: NW_Cover, +own: Bool) -> NW_Rows:
  +next = nt_choose(NW_Cover, own, u => NW_Cover{end, Nil{}, 2}, u => cover)
  nw_join(nw_join(nw_branch(zero, depth, value, next, 0, hasZero), nw_branch(one, depth, value, next, 1, hasOne)),
    NW_Rows{True{}, nt_choose(List<&2, KTerm>, own, u => [nw_row(end, depth, value, 2)], u => Nil{})})

@unsafe
def nw_walk(t, depth, value, cover):
  nt_choose(NW_Rows, U32.is_eq(depth, 32),
    u => nt_choose(NW_Rows, String.eq(tg(t), "Mat") && String.eq(nm(t), "WNil") && U32.is_eq(ix(t), 1) && U32.is_eq(terms_len(ks(t)), 2),
      v => NW_Rows{True{}, [nw_row(kid(t, 0), depth, value, 0)]}, v => NW_Rows{False{}, Nil{}}),
    u => nt_choose(NW_Rows, String.eq(tg(t), "Mat") && String.eq(nm(t), "WCon") && U32.is_eq(ix(t), 3) && U32.is_eq(terms_len(ks(t)), 2),
      v => nw_bits(depth, value, cover, nw_arms(kid(t, 0), atom("Absent"), atom("Absent"), False{}, False{})),
      v => nt_choose(NW_Rows, String.eq(tg(t), "Lam"),
        w => NW_Rows{True{}, nt_choose(List<&2, KTerm>, nw_covered(t, 1, cover), x => Nil{}, x => [nw_row(t, depth, value, 1)])},
        w => NW_Rows{False{}, Nil{}})))

@unsafe
def nw_applicable(+mat: KTerm) -> Bool:
  nt_choose(Bool, String.eq(tg(mat), "Mat"),
    u => nt_choose(Bool, String.eq(nm(mat), "U32") || String.eq(nm(mat), "F32"),
      v => U32.is_eq(ix(mat), 2) && U32.is_eq(terms_len(ks(mat)), 2) && String.eq(tg(kid(mat, 1)), "Efq"), v => False{}), u => False{})

@unsafe
def nw_condition(+word: String, +row: KTerm) -> String:
  nt_choose(String, U32.is_eq(ix(row), 32), u => "((u32)" ++ word ++ " == " ++ nm(row) ++ "u)",
    u => "(((u32)" ++ word ++ " & " ++ U32.show(U32.sub(U32.shln(1, U32.to_nat(ix(row))), 1)) ++ "u) == " ++ nm(row) ++ "u)")

@unsafe
def nw_tail(+word: String, +depth: U32, +id: U32) -> String:
  "Term v_" ++ U32.show(id) ++ " = term_pak(CID_WNIL, 0);\nfor (u32 wi = 32; wi > " ++ U32.show(depth) ++ "; wi--) {\nLoc wp = heap_alloc(e, 1);\ne.mem[wp] = ((u32)" ++ word ++ " >> (wi - 1)) & 1;\ne.mem[wp + 1] = rfc_seal(e, v_" ++ U32.show(id) ++ ");\nv_" ++ U32.show(id) ++ " = term_ctr(CID_WCON, wp);\n}\n"

# Under a row's bit constraints, reconstructing its original scalar wrapper is
# the original low 32-bit value. Keep the value; materialize an escaping Word
# tail only if it remains used after beta substitution and this local rewrite.
@unsafe
def nw_prefix(+depth: U32, +value: U32, +tail: KTerm) -> KTerm:
  nt_choose(KTerm, U32.is_eq(depth, 0), u => tail,
    u => nw_prefix(U32.sub(depth, 1), value, nw_word(kt("NWord", U32.show(U32.and(U32.shrn(value, U32.to_nat(U32.sub(depth, 1))), 1)), 0, 0, Nil{}), tail)))

@unsafe
def nw_value(row: KTerm) -> U32:
  nw_value_result(U32.read(nm(row)))

@unsafe
def nw_value_result(parsed: Maybe<&2, U32>) -> U32:
  match parsed:
    case None{}: 0
    case Some{value}: value

@unsafe
def nw_restore(+t: KTerm, +word: KTerm, +id: U32) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "Ctr") && (String.eq(nm(t), "U32") || String.eq(nm(t), "F32")) && U32.is_eq(terms_len(ks(t)), 1),
    u => nt_choose(KTerm, nw_same(kid(t, 0), word, Nil{}), v => var("", id), v => nw_restore_children(t, word, id)),
    u => nw_restore_children(t, word, id))

@unsafe
def nw_restore_children(+t: KTerm, +word: KTerm, +id: U32) -> KTerm:
  k_rebuild(t, nm(t), ix(t), qt(t), nw_restore_list(ks(t), word, id), rm(t), kb(t), ke(t))

@unsafe
def nw_restore_list(ts: List<&2, KTerm>, +word: KTerm, +id: U32) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{nw_restore(t, word, id), nw_restore_list(rest, word, id)}

@unsafe
def nw_code(+book: List<&2, KDef>, +row: KTerm, +word: String, +rest: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, U32.is_eq(qt(row), 0), u => nc_lower_to(book, nd_reapply(kid(row, 0), rest), env, n, target),
    u => nw_code_body(book, row, word, env, n, target,
      nd_reapply(nw_restore(nd_beta(kid(row, 0), nt_choose(List<&2, KTerm>, U32.is_eq(qt(row), 1),
        v => [var("", nc_id(U32.add(n, 2)))], v => [var("", nc_id(U32.inc(n))), var("", nc_id(U32.add(n, 2)))])),
        nw_prefix(ix(row), nw_value(row), nt_choose(KTerm, U32.is_eq(qt(row), 1),
          v => var("", nc_id(U32.add(n, 2))), v => nw_word(var("", nc_id(U32.inc(n))), var("", nc_id(U32.add(n, 2)))))), nc_id(n)), rest)))

@unsafe
def nw_code_body(+book: List<&2, KDef>, +row: KTerm, +word: String, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +body: KTerm) -> NC_Code:
  +uses = nc_uses(body)
  +bit = nc_id(U32.inc(n))
  +tail = nc_id(U32.add(n, 2))
  +hasBit = nc_uses_has(uses, bit)
  +hasTail = nc_uses_has(uses, tail)
  +bindings = nt_choose(List<&2, NC_Binding>, hasTail, u => Con{nc_binding(tail), env}, u => env)
  +bindings = nt_choose(List<&2, NC_Binding>, hasBit, u => Con{NC_Binding{bit, "v_" ++ U32.show(bit), N_W32{}}, bindings}, u => bindings)
  nc_prepend("Term v_" ++ U32.show(nc_id(n)) ++ " = (u32)" ++ word ++ ";\n" ++
    nt_choose(String, hasBit, u => "Term v_" ++ U32.show(bit) ++ " = ((u32)" ++ word ++ " >> " ++ U32.show(ix(row)) ++ ") & 1;\n", u => "") ++
    nt_choose(String, hasTail, u => nw_tail(word, U32.add(ix(row), nt_bool(U32.is_eq(qt(row), 2))), tail), u => ""),
    nc_lower_to(book, body, Con{NC_Binding{nc_id(n), "v_" ++ U32.show(nc_id(n)), N_W32{}}, bindings}, U32.add(n, 3), target))

law nw_emit:
  for +book: List<&2, KDef>
  for rows: List<&2, KTerm>
  for +word: String
  for +rest: List<&2, KTerm>
  for +env: List<&2, NC_Binding>
  for +n: U32
  for +target: NC_Target
  NC_Code

@unsafe
def nw_emit_more(+book: List<&2, KDef>, +row: KTerm, +rows: List<&2, KTerm>, +word: String, +rest: List<&2, KTerm>, +env: List<&2, NC_Binding>, +target: NC_Target, +code: NC_Code) -> NC_Code:
  nw_emit_join(nw_condition(word, row), code, nw_emit(book, rows, word, rest, env, nc_fresh(code), target))

@unsafe
def nw_emit_join(+condition: String, +code: NC_Code, +tail: NC_Code) -> NC_Code:
  NC_Code{nct_cat(nct_leaf("if (" ++ condition ++ ") {\n"), nct_cat(nc_text(code), nct_cat(nct_leaf("} else {\n"), nct_cat(nc_text(tail), nct_leaf("}\n"))))), nt_append(N_Segment, nc_segs(code), nc_segs(tail)), nc_fresh(tail), nc_first_error(code, tail), List.append(&2, String, nc_calls(code), nc_calls(tail))}

@unsafe
def nw_emit(book, rows, word, rest, env, n, target):
  match rows:
    case Nil{}: NC_Code{nct_leaf("err_post(e.mem, ERR_FIDS); return 0;\n"), Nil{}, n, "", Nil{}}
    case Con{+row, +more}: nw_emit_more(book, row, more, word, rest, env, target, nw_code(book, row, word, rest, env, n, target))

@unsafe
def nw_match(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, rows: NW_Rows) -> NC_Code:
  match rows:
    case NW_Rows{valid, +rs}:
      nt_choose(NC_Code, valid && Bool.not(List.is_empty(&2, KTerm, rs)),
        u => nw_emit(book, rs, nc_word(ix(kid(t, 1)), env), nd_match_rest(t), nc_remove_env(env, ix(kid(t, 1))), n, target),
        u => nc_match_apply_original_to(book, t, env, n, target))

# Store reduced rows once in the private native tree, after typed erasure and
# static preparation. Source/ABI terms never carry this marker; static input
# rejects it. Analyses now see retained row bodies instead of expanded defaults.
@unsafe
def nw_prepare(+t: KTerm) -> KTerm:
  nt_choose(KTerm, nw_applicable(t),
    u => nw_prepared(t, nw_walk(kid(t, 0), 0, 0, NW_None{})), u => t)

@unsafe
def nw_prepared(+t: KTerm, rows: NW_Rows) -> KTerm:
  match rows:
    case NW_Rows{valid, +rs}:
      nt_choose(KTerm, valid && Bool.not(List.is_empty(&2, KTerm, rs)),
        u => kt("NWPattern", nm(t), 2, 0, rs), u => t)

@unsafe
def nw_uses(rows: List<&2, KTerm>, +id: U32) -> U32:
  match rows:
    case Nil{}: 0
    case Con{row, rest}: U32.max(nq_uses(kid(row, 0), id), nw_uses(rest, id))
