
# Module: src/back/js/choice.bend:3
law j_choice_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  Bool

# Module: src/back/js/choice.bend:8
law j_choice_match:
  for +t: KTerm
  Bool

# Module: src/back/js/choice.bend:12
law j_choice_arm:
  for +t: KTerm
  for +first: Bool
  Bool

# Module: src/back/js/choice.bend:17
law j_choice_leaf:
  for +t: KTerm
  for +binder: U32
  Bool

# Module: src/back/js/choice.bend:23
@unsafe
def j_choice_call(
  +book: List<&2, KDef>,
  +spine: KTerm,
) -> Bool:
  kc(Bool, p98_tag_eq(spine, "Call") && U32.is_eq(terms_len(ks(spine)), 4), u =>
    kc(Bool, p98_tag_eq(j_strip(kid(spine, 2)), "Lam") && p98_tag_eq(j_strip(kid(spine, 3)), "Lam") && p88_string_eq(j_l_name(j_strip(kid(spine, 2))), "") && p88_string_eq(j_l_name(j_strip(kid(spine, 3))), ""), u => j_choice_definition(book, lookup(book, nm(spine))), u => False{}), u => False{})

# Module: src/back/js/choice.bend:31
@unsafe
def j_choice_definition(book, d):
  kc(Bool, db(lookup(book, "Bool")) && db(lookup(book, "Unit")) && p98_tag_eq(dt(d), "All") && U32.is_eq(qt(dt(d)), 0) && p98_tag_eq(j_strip(dv(d)), "Lam"),
    u => j_choice_match(j_strip(kid(j_strip(dv(d)), 0))), u => False{})

# Module: src/back/js/choice.bend:36
@unsafe
def j_choice_match(t):
  p98_tag_eq(t, "Mat") && p88_string_eq(nm(t), "True") && j_choice_arm(j_strip(kid(t, 0)), True{}) &&
  p98_tag_eq(j_strip(kid(t, 1)), "Mat") && p88_string_eq(nm(j_strip(kid(t, 1))), "False") &&
  j_choice_arm(j_strip(kid(j_strip(kid(t, 1)), 0)), False{}) && p98_tag_eq(j_strip(kid(j_strip(kid(t, 1)), 1)), "Efq")

# Module: src/back/js/choice.bend:42
@unsafe
def j_choice_arm(t, first):
  p98_tag_eq(t, "Lam") && p98_tag_eq(j_strip(kid(t, 0)), "Lam") &&
  j_choice_leaf(j_strip(kid(j_strip(kid(t, 0)), 0)), kc(U32, first, u => ix(t), u => ix(j_strip(kid(t, 0)))))

# Module: src/back/js/choice.bend:47
@unsafe
def j_choice_leaf(t, binder):
  p98_tag_eq(t, "App") && p98_tag_eq(j_strip(kid(t, 0)), "Var") && U32.is_eq(ix(j_strip(kid(t, 0))), binder) &&
  p98_tag_eq(j_strip(kid(t, 1)), "Ctr") && p88_string_eq(nm(j_strip(kid(t, 1))), "Unit") && U32.is_eq(terms_len(ks(j_strip(kid(t, 1)))), 0)
