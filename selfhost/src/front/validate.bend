
# Module: src/front/validate.bend:3
law f_reserved:
  for +s: String
  Bool

# Module: src/front/validate.bend:7
law f_ctor_lookup:
  for +name: String
  for +book: List<&2,KDef>
  KDef

# Module: src/front/validate.bend:12
law f_ctor_more:
  for +name: String
  for +found: KDef
  for +rest: List<&2,KDef>
  KDef

# Module: src/front/validate.bend:18
law f_lambda_valid:
  for +a: KTerm
  for +body: KTerm
  for +cursor: U32
  KTerm

# Module: src/front/validate.bend:82
law f_alias_valid:
  for +s: String
  Bool

# Module: src/front/validate.bend:86
law f_alias_chars:
  for +s: String
  Bool

# Module: src/front/validate.bend:90
law f_validate_param:
  for +ts: FInput
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

# Module: src/front/validate.bend:136
law f_valid_name:
  for +s: String
  Bool

# Module: src/front/validate.bend:140
law f_name_chars:
  for +s: String
  Bool

# Module: src/front/validate.bend:152
law f_bang:
  for +n: KTerm
  for +ts: FInput
  for +min: U32
  FParsed

# Module: src/front/validate.bend:194
law f_foreign_path_valid:
  for +ts: FInput
  Bool

# Only failed calls revisit arguments to retain the first bad marker.

# Module: src/front/validate.bend:25
@unsafe
def f_reserved(s):
  f_eq(s, "def") || f_eq(s, "type") || f_eq(s, "law") || f_eq(s, "match") || f_eq(s, "case") || f_eq(s, "do") || f_eq(s, "return") || f_eq(s, "for") || f_eq(s, "exs") || f_eq(s, "where") || f_eq(s, "is") || f_eq(s, "import") || f_eq(s, "Type") || f_eq(s, "Data") || f_eq(s, "Kind") || f_eq(s, "Quant")

# Module: src/front/validate.bend:29
@unsafe
def f_ctor_lookup(name, book):
  match book:
    case Nil{}:
      f_find(name, Nil{})
    case Con{+d, ds}:
      f_ctor_named(name, d, ds, f_eq(dk(d), "Ctr") && f_eq(dn(d), name))

# Module: src/front/validate.bend:37
@unsafe
def f_ctor_named(+name: String, +d: KDef, +rest: List<&2,KDef>, +same: Bool) -> KDef:
  match same:
    case True{}: d
    case False{}: f_ctor_children(name, dc(d), rest)

# Module: src/front/validate.bend:43
@unsafe
def f_ctor_children(+name: String, +children: List<&2,KDef>, +rest: List<&2,KDef>) -> KDef:
  match children:
    case Nil{}: f_ctor_lookup(name, rest)
    case Con{child, tail}: f_ctor_more(name, f_ctor_lookup(name, children), rest)

# Module: src/front/validate.bend:49
@unsafe
def f_ctor_more(name, found, rest):
  f_choose(KDef, f_eq(dk(found), "Missing"), u => f_ctor_lookup(name, rest), u => found)

# Parser scopes retain the first depth-first constructor for each exact name.

# Module: src/front/validate.bend:54
@unsafe
def f_ctor_index(+book: List<&2,KDef>, +tree: KDef) -> KDef:
  match book:
    case Nil{}: tree
    case Con{d, rest}: f_ctor_index_def(d, f_ctor_index(rest, tree))

# Module: src/front/validate.bend:60
@unsafe
def f_ctor_index_def(+d: KDef, +tree: KDef) -> KDef:
  +children = f_ctor_index(dc(d), tree)
  f_choose(KDef, f_eq(dk(d), "Ctr"), u => index_set(children, d, index_hash(dn(d), 2166136261), 32), u => children)

# Module: src/front/validate.bend:65
@unsafe
def f_ctor_index_find(+name: String, +tree: KDef) -> KDef:
  +found = index_find(tree, name, index_hash(name, 2166136261), 32)
  f_choose(KDef, f_eq(dk(found), "Absent"), u => f_find(name, Nil{}), u => found)

# Module: src/front/validate.bend:70
@unsafe
def f_valid_ctor_head(+p: KTerm, +ctr: KDef) -> Maybe<&2,KTerm>:
  f_choose(Maybe<&2,KTerm>, f_eq(dk(ctr), "Missing"), u => Some{fpe_message_at(p, "unknown constructor pattern: " ++ nm(p), "a declared constructor (unknown: " ++ name_key(nm(p)) ++ ")")},
    u => f_choose(Maybe<&2,KTerm>, U32.is_eq(da(ctr), terms_len(ks(p))), u => None{}, u => Some{fpe_message_at(p, "constructor pattern field count differs: " ++ nm(p), "a " ++ name_key(nm(p)) ++ " pattern with " ++ U32.show(da(ctr)) ++ f_choose(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields"))}))

# Module: src/front/validate.bend:75
@unsafe
def f_lambda_valid(a, body, cursor):
  f_choose(KTerm, f_eq(tg(a), "Ref") && f_valid_name(nm(a)),
    u => f_choose(KTerm, String.contains(nm(a), "."),
      u => kt_span("FLambda", nm(a), ix(a), qt(a), [body, a, kt_span("LambdaCursor", "", 0, 0, Nil{}, cursor, cursor)], kb(a), ke(a)),
      u => k_lam(nm(a), ix(a), qt(a), [body], kb(a), ke(a), True{})),
    u => fpe_point_at(kt_span("LambdaCursor", "", 0, 0, Nil{}, cursor, cursor), "a lambda binder must be a non-reserved name", "a lambda binder (one name: k => body)"))

# Module: src/front/validate.bend:97
@unsafe
def f_alias_valid(s):
  (Char.is_alpha(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_alias_chars(s) && Bool.not(f_reserved(s))

# Module: src/front/validate.bend:101
@unsafe
def f_alias_chars(s):
  f_choose(Bool, String.is_empty(s), u => True{}, u => (Char.is_alpha(f_head(s)) || Char.is_digit(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_alias_chars(f_tail(s)))

# Module: src/front/validate.bend:105
@unsafe
def f_validate_param(ts, end, acc):
  f_choose(FParsed, f_eq(f_tx(ts), "~") && Bool.not(f_eq(end, ")")), u => fpe_name_error(ts), u => f_choose(FParsed, Bool.not(f_valid_name(f_tx(f_unmark(ts)))), u => fpe_name_error(f_choose(FInput, f_eq(f_tx(ts), "->"), u => f_prepend(FToken{">", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts)), u => f_unmark(ts))), u => f_choose(FParsed, f_eq(end, "}") && f_named_field(f_tx(f_unmark(ts)), acc), u => fpe_word(f_unmark(ts), "duplicate constructor field", "a fresh field name (duplicate declaration: " ++ f_tx(f_unmark(ts)) ++ ")"), u => f_choose(FParsed, f_eq(f_tx(ts), "~") && U32.is_lt(f_templates(acc), terms_len(acc)), u => fpe_error(ts, "only leading parameters may use ~", "a plain binder (only leading binders take ~)"), u => f_tele_binder(kt_span("Bind", f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), Nil{}, f_begin(f_unmark(ts)), f_end(f_unmark(ts))), f_eq(f_tx(ts), "~"), f_tl(f_unmark(ts)), end, acc)))))

# Module: src/front/validate.bend:130
@unsafe
def f_named_field(+name: String, +fields: List<&2,KTerm>) -> Bool:
  match fields:
    case Nil{}: False{}
    case Con{field, rest}: f_eq(name, nm(field)) || f_named_field(name, rest)

# Module: src/front/validate.bend:145
@unsafe
def f_valid_name(s):
  (f_ascii_alpha(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_name_chars(s) && Bool.not(f_reserved(s))

# Module: src/front/validate.bend:149
@unsafe
def f_name_chars(s):
  f_choose(Bool, String.is_empty(s), u => True{}, u => f_ident(f_head(s)) && (Bool.not(Char.is_eq(f_head(s), '.')) || f_ascii_alpha(f_head(f_tail(s))) || Char.is_eq(f_head(f_tail(s)), '_')) && f_name_chars(f_tail(s)))

# Module: src/front/validate.bend:164
@unsafe
def f_bare_params(
  +params: List<&2, KTerm>,
) -> Bool:
  match params:
    case Nil{}:
      True{}
    case Con{+p, rest}:
      f_eq(tg(kid(p, 0)), "Qnt") && Bool.not(f_eq(tg(p), "Template")) && f_bare_params(rest)

# Module: src/front/validate.bend:174
@unsafe
def f_bang(n, ts, min):
  f_choose(FParsed, f_eq(tg(n), "Ref") && f_eq(f_tx(f_tl(ts)), "("), u => f_grow(FParsed{kt_span("Ref", nm(n), ix(n), 3, ks(n), kb(n), ke(n)), f_tl(ts)}, min), u => fpe_error(ts, "! must follow a named definition and precede call parentheses", "a named def before ! (only f!(..) offloads)"))

# Module: src/front/validate.bend:203
@unsafe
def f_foreign_path_valid(ts):
  U32.is_eq(f_kind(f_tl(ts)), 2) && Char.is_eq(f_head(f_tx(f_tl(ts))), '"') && (String.ends_with(f_unquote(f_tx(f_tl(ts))), ".c") || String.ends_with(f_unquote(f_tx(f_tl(ts))), ".js"))


# Row quantity is internal flattening metadata: zero proves the body contains
# no Var nodes, so every later column substitution is the identity. Open rows
# remain conservatively marked even if their remaining variables disappear.

# Module: src/front/validate.bend:211
@unsafe
def f_import_used(+name: String, +imports: List<&2,KTerm>) -> Bool:
  match imports:
    case Nil{}: False{}
    case Con{im, rest}: p88_string_eq(name, nm(kid(im, 0))) || f_import_used(name, rest)

# Module: src/front/validate.bend:217
@unsafe
def f_match_error(+head: KTerm, +origin: KTerm) -> KTerm:
  +legacy : String = "match requires an unconsumed parameter or constructor field"
  f_choose(KTerm, f_eq(tg(head), "Var") || f_eq(tg(head), "Ref"),
    u => fpe_match_at(head, head, legacy, 0),
    u => f_choose(KTerm, f_eq(tg(head), "Ctr") || f_eq(tg(head), "Literal") || core_literal(head),
      u => fpe_match_at(head, origin, legacy, 1),
      u => fpe_message_at(f_choose(KTerm, U32.is_gt(kb(head), 0), u => head, u => origin), legacy, "a parameter or field scrutinee (a match cannot scrutinize a computed value: give it its own def)")))

# Module: src/front/validate.bend:226
@unsafe
def f_valid_var_pattern(+p: KTerm, +constructor: KDef) -> Maybe<&2,KTerm>:
  f_choose(Maybe<&2,KTerm>, f_valid_name(nm(p)), u => f_choose(Maybe<&2,KTerm>, f_eq(dk(constructor), "Missing"), u => None{}, u => Some{fpe_message_at(p, "a constructor pattern requires braces: " ++ nm(p), "a braced constructor pattern (" ++ name_key(nm(p)) ++ " is a constructor: write " ++ name_key(nm(p)) ++ "{}, or rename the binder)")}),
    u => Some{kt("Error", "reserved pattern binder: " ++ nm(p), 0, 0, Nil{})})

# Module: src/front/validate.bend:231
@unsafe
def f_computed_pattern_error(+pattern: KTerm, +observed: KTerm) -> KTerm:
  fpe_expected_at(pattern, "expected a binder or constructor pattern", "a pattern (a binder or a constructor)", kp_show(observed))
