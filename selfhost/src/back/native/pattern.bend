
# Module: src/back/native/pattern.bend:4
type NPLevel is Data:
  NPLevel{+zero: KTerm, +successor: KTerm, +fallback: KTerm, +hasZero: Bool, +hasSucc: Bool, +valid: Bool}

# Module: src/back/native/pattern.bend:7
type NPRow is Data:
  NPRow{+index: U32, +body: KTerm, +residual: U32, +apply: Bool, +last: Bool}

# Module: src/back/native/pattern.bend:10
law np_level_mat:
  for +term: KTerm
  for +zero: KTerm
  for +successor: KTerm
  for +hasZero: Bool
  for +hasSucc: Bool
  NPLevel

# Module: src/back/native/pattern.bend:17
law np_collect_level:
  for +term: KTerm
  for +depth: U32
  for +built: List<&2,NPRow>
  for +level: NPLevel
  List<&2,NPRow>

# Module: src/back/native/pattern.bend:23
law np_emit:
  for +book: List<&2,KDef>
  for +rows: List<&2,NPRow>
  for +word: String
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:30
law np_emit_row:
  for +book: List<&2,KDef>
  for +row: NPRow
  for +rest: List<&2,NPRow>
  for +word: String
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:38
law np_emit_done:
  for +book: List<&2,KDef>
  for +index: U32
  for +last: Bool
  for +rest: List<&2,NPRow>
  for +word: String
  for +env: List<&2,NC_Binding>
  for +code: NC_Code
  NC_Code

# Module: src/back/native/pattern.bend:47
law np_emit_join:
  for +index: U32
  for +last: Bool
  for +word: String
  for +code: NC_Code
  for +tail: NC_Code
  NC_Code

# Module: src/back/native/pattern.bend:54
law np_row_code:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +residual: U32
  for +apply: Bool
  for +word: String
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:63
law np_match_apply:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +env: List<&2,NC_Binding>
  for +next: U32
  NC_Code

# Module: src/back/native/pattern.bend:128
law np_can_match:
  for +term: KTerm
  Bool

# Module: src/back/native/pattern.bend:70
@unsafe
def np_supported(
  +term: KTerm,
) -> Bool:
  p98_tag_eq(term, "Mat") && ((p88_string_eq(nm(term), "Zero") && (U32.is_eq(ix(term), 0) || U32.is_eq(ix(term), 1))) || (p88_string_eq(nm(term), "Succ") && (U32.is_eq(ix(term), 0) || U32.is_eq(ix(term), 2))))

# Module: src/back/native/pattern.bend:75
@unsafe
def np_level(
  +term: KTerm,
  +zero: KTerm,
  +successor: KTerm,
  +hasZero: Bool,
  +hasSucc: Bool,
) -> NPLevel:
  nt_choose(NPLevel, p98_tag_eq(term, "Mat"), u => np_level_mat(term, zero, successor, hasZero, hasSucc), u => NPLevel{zero, successor, term, hasZero, hasSucc, True{}})

# Module: src/back/native/pattern.bend:84
@unsafe
def np_level_mat(term, zero, successor, hasZero, hasSucc):
  nt_choose(NPLevel, np_supported(term) && p88_string_eq(nm(term), "Zero") && Bool.not(hasZero), u => np_level(kid(term, 1), kid(term, 0), successor, True{}, hasSucc), u =>
    nt_choose(NPLevel, np_supported(term) && p88_string_eq(nm(term), "Succ") && Bool.not(hasSucc), u => np_level(kid(term, 1), zero, kid(term, 0), hasZero, True{}), u => NPLevel{zero, successor, term, hasZero, hasSucc, False{}}))

# Module: src/back/native/pattern.bend:88
@unsafe
def np_collect(
  +term: KTerm,
  +depth: U32,
  +built: List<&2,NPRow>,
) -> List<&2,NPRow>:
  np_collect_level(term, depth, built, np_level(term, {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, False{}, False{}))

# Module: src/back/native/pattern.bend:95
@unsafe
def np_collect_level(term, depth, built, level):
  match level:
    case NPLevel{+zero, +successor, +fallback, +hasZero, +hasSucc, valid}:
      nt_choose(List<&2,NPRow>, valid && (hasZero || hasSucc),
        u => np_collect(nt_choose(KTerm, hasSucc, u => successor, u => fallback), nt_choose(U32, hasSucc, u => U32.inc(depth), u => depth), Con{NPRow{depth, nt_choose(KTerm, hasZero, u => zero, u => fallback), depth, Bool.not(hasZero), False{}}, built}),
        u => nt_reverse(NPRow, Con{NPRow{depth, term, depth, True{}, True{}}, built}, Nil{}))

# Module: src/back/native/pattern.bend:102
@unsafe
def np_match_apply(book, term, env, next):
  np_emit(book, np_collect(kid(term, 0), 0, Nil{}), nc_word(ix(kid(term, 1)), env), nc_remove_env(env, ix(kid(term, 1))), next)

# Module: src/back/native/pattern.bend:105
@unsafe
def np_emit(book, rows, word, env, next):
  match rows:
    case Nil{}:
      nc_fail("empty Nat pattern chain", next)
    case Con{row, rest}:
      np_emit_row(book, row, rest, word, env, next)

# Module: src/back/native/pattern.bend:112
@unsafe
def np_emit_row(book, row, rest, word, env, next):
  match row:
    case NPRow{index, body, residual, apply, last}:
      np_emit_done(book, index, last, rest, word, env, np_row_code(book, body, residual, apply, word, env, next))

# Module: src/back/native/pattern.bend:117
@unsafe
def np_emit_done(book, index, last, rest, word, env, code):
  nt_choose(NC_Code, last, u => NC_Code{nct_cat(nct_leaf("{\n"), nct_cat(nc_text(code), nct_leaf("}\n"))), nc_segs(code), nc_fresh(code), nc_error(code), List.append(&2, String, nc_calls(code), Nil{})}, u => np_emit_join(index, last, word, code, np_emit(book, rest, word, env, nc_fresh(code))))

# Module: src/back/native/pattern.bend:120
@unsafe
def np_emit_join(index, last, word, code, tail):
  NC_Code{nct_cat(nct_leaf("if (" ++ word ++ " == " ++ U32.show(index) ++ "ull) {\n"), nct_cat(nc_text(code), nct_cat(nct_leaf("} else "), nc_text(tail)))), nt_append(N_Segment, nc_segs(code), nc_segs(tail)), nc_fresh(tail), nc_first_error(code, tail), List.append(&2, String, nc_calls(code), List.append(&2, String, nc_calls(tail), Nil{}))}

# Module: src/back/native/pattern.bend:123
@unsafe
def np_row_code(book, body, residual, apply, word, env, next):
  nt_choose(NC_Code, apply,
    u => nc_prepend("Term v_" ++ U32.show(nc_id(next)) ++ " = (" ++ word ++ " - " ++ U32.show(residual) ++ "ull);\n", nc_lower(book, app(body, var("", nc_id(next))), Con{nc_binding(nc_id(next)), env}, U32.inc(next))),
    u => nc_lower(book, body, env, next))

# Module: src/back/native/pattern.bend:133
@unsafe
def np_level_valid(
  +level: NPLevel,
) -> Bool:
  match level:
    case NPLevel{zero, successor, fallback, hasZero, hasSucc, valid}:
      valid && (hasZero || hasSucc)

# Module: src/back/native/pattern.bend:140
@unsafe
def np_can_match(term):
  np_supported(term) && np_level_valid(np_level(term, {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, False{}, False{}))
