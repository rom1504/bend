
# Module: src/back/js/validate.bend:11
law j_main_error:
  for +book: List<&2, KDef>
  for +main: KDef
  String

# Module: src/back/js/validate.bend:23
law j_printable:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:40
law j_printable_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:51
law j_printable_adt:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:62
law j_printable_ctors:
  for +book: List<&2, KDef>
  for +ctors: List<&2, KDef>
  for +params: List<&2, KTerm>
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:86
law j_printable_fields:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:110
law j_layout_error:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  for +roots: List<&2, String>
  for +stops: List<&2, String>
  String

# Module: src/back/js/validate.bend:121
law j_layout_visit:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  Bool

# Module: src/back/js/validate.bend:136
law j_layout_def:
  for +book: List<&2, KDef>
  for +defs: List<&2, KDef>
  for +d: KDef
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  Bool

# Module: src/back/js/validate.bend:163
law j_layout_open_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/js/validate.bend:172
law j_layout_term:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:184
law j_layout_kind:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  for +key: String
  List<&2, String>

# Module: src/back/js/validate.bend:204
law j_layout_lam:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:216
law j_layout_match:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:228
law j_layout_app:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +fty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:240
law j_layout_function:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:260
law j_layout_array_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  Bool

# Module: src/back/js/validate.bend:269
law j_layout_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  for +element: KTerm
  Bool

# Module: src/back/js/validate.bend:286
law j_layout_fields:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tel: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:301
law j_layout_let:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:313
law j_layout_bindings:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:360
law jl_term:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:6
@unsafe
def j_compile_error(
  +book: List<&2, KDef>,
) -> String:
  kc(String, p88_string_eq(dk(lookup(book, "IO")), "Absent"), u => "a build needs import Base", u => j_main_error(book, lookup(book, "main")))

# Module: src/back/js/validate.bend:17
@unsafe
def j_main_error(book, main):
  kc(String, Bool.not(p88_string_eq(dk(main), "Def")) || p98_tag_eq(j_strip(dv(main)), "Absent"), u => "no main to run", u => kc(String, j_io_type(book, dt(main)), u => kc(String, p98_tag_eq(j_strip(dv(main)), "Foreign"), u => "main must be a filled def: a foreign main cannot anchor IO", u => ""), u => kc(String, j_printable(book, dt(main), Nil{}, 0), u => "", u => "main's type " ++ kp_show(dt(main)) ++ " cannot be printed (a function, a Type, an erased or dependent field)")))

# Printability is a graph predicate. Thread successful visits across fields and
# constructor siblings so a shared child type is checked once per request.
# Insert each ADT before descending, retaining the original recursive-type rule.

# Module: src/back/js/validate.bend:31
@unsafe
def j_printable(book, ty, seen, fuel):
  j_printable_done(j_printable_head(book, wnf(book, ty), seen, fuel))

# Module: src/back/js/validate.bend:35
@unsafe
def j_printable_done(+done: Maybe<&2,List<&2,String>>) -> Bool:
  match done:
    case None{}: False{}
    case Some{visited}: True{}

# Module: src/back/js/validate.bend:48
@unsafe
def j_printable_head(book, ty, seen, fuel):
  kc(Maybe<&2, List<&2, String>>, p98_tag_eq(ty, "Eql"), u => Some{seen}, u => kc(Maybe<&2, List<&2, String>>, p98_tag_eq(ty, "ADT") && Bool.not(p88_string_eq(nm(ty), "IO.OP")) && p88_string_eq(dk(lookup(book, nm(ty))), "ADT"), u => j_printable_adt(book, ty, seen, fuel), u => None{}))

# Module: src/back/js/validate.bend:59
@unsafe
def j_printable_adt(book, ty, seen, fuel):
  kc(Maybe<&2, List<&2, String>>, String.contains("|U32|F32|Nat|Char|String|", "|" ++ nm(ty) ++ "|") || has_name(seen, term_key(ty)), u => Some{seen}, u => kc(Maybe<&2, List<&2, String>>, p88_string_eq(nm(ty), "Array"), u => j_printable_head(book, wnf(book, kid(ty, 0)), seen, fuel), u => j_printable_ctors(book, dc(lookup(book, nm(ty))), ks(ty), Con{term_key(ty), seen}, fuel)))

# Module: src/back/js/validate.bend:71
@unsafe
def j_printable_ctors(book, ctors, params, seen, fuel):
  match ctors:
    case Nil{}:
      Some{seen}
    case Con{d, rest}:
      j_printable_ctors_more(book, rest, params, fuel,
        j_printable_fields(book, j_specialize(book, dt(d), params), seen, fuel))

# Module: src/back/js/validate.bend:80
@unsafe
def j_printable_ctors_more(+book: List<&2,KDef>, +ctors: List<&2,KDef>,
  +params: List<&2,KTerm>, +fuel: U32, +done: Maybe<&2,List<&2,String>>) -> Maybe<&2,List<&2,String>>:
  match done:
    case None{}: None{}
    case Some{seen}: j_printable_ctors(book, ctors, params, seen, fuel)

# Module: src/back/js/validate.bend:94
@unsafe
def j_printable_fields(book, ty, seen, fuel):
  kc(Maybe<&2, List<&2, String>>, p98_tag_eq(ty, "All"), u =>
    kc(Maybe<&2, List<&2, String>>, U32.is_eq(qt(ty), 0), u => None{}, u =>
      j_printable_fields_more(book, kid(ty, 1), fuel,
        j_printable_head(book, wnf(book, kid(ty, 0)), seen, fuel))), u => Some{seen})

# Module: src/back/js/validate.bend:101
@unsafe
def j_printable_fields_more(+book: List<&2,KDef>, +ty: KTerm,
  +fuel: U32, +done: Maybe<&2,List<&2,String>>) -> Maybe<&2,List<&2,String>>:
  match done:
    case None{}: None{}
    case Some{seen}: j_printable_fields(book, ty, seen, fuel)

# Layout validation follows executable references, not type dependencies or
# erased expressions. An Array representation is needed at elimination,
# construction, and element-sensitive native operations.

# Module: src/back/js/validate.bend:118
@unsafe
def j_layout_error(book, defs, roots, stops):
  kc(String, j_layout_visit(book_context(book), book_cached(defs, 0), roots, Nil{}, stops), u => "an open Array element type", u => "")

# Module: src/back/js/validate.bend:130
@unsafe
def j_layout_visit(book, defs, todo, seen, stops):
  match todo:
    case Nil{}: False{}
    case Con{h, rest}:
      kc(Bool, p88_string_eq(h, "$layout.open-array"), u => True{}, u => kc(Bool, has_name(seen, h) || has_name(stops, h), u => j_layout_visit(book, defs, rest, seen, stops), u => j_layout_def(book, defs, lookup(defs, h), rest, Con{h, seen}, stops)))

# Module: src/back/js/validate.bend:146
@unsafe
def j_layout_def(book, defs, d, todo, seen, stops):
  j_layout_visit(book, defs, kc(List<&2, String>, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0), u => j_layout_term(book, Nil{}, dv(d), dt(d), todo), u => todo), seen, stops)

# Module: src/back/js/validate.bend:150
@unsafe
def j_layout_mark(
  +bad: Bool,
  +todo: List<&2, String>,
) -> List<&2, String>:
  kc(List<&2, String>, bad, u => Con{"$layout.open-array", todo}, u => todo)

# Module: src/back/js/validate.bend:157
@unsafe
def j_layout_open(
  +book: List<&2, KDef>,
  +ty: KTerm,
) -> Bool:
  j_layout_open_head(book, wnf(book, ty))

# Module: src/back/js/validate.bend:169
@unsafe
def j_layout_open_head(book, ty):
  kc(Bool, p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Array"), u => j_layout_element_open(book, kid(ty, 0)), u => False{})

# Module: src/back/js/validate.bend:181
@unsafe
def j_layout_term(book, env, t, ty, todo):
  j_layout_kind(book, env, t, ty, todo, tg(t))

# Module: src/back/js/validate.bend:194
@unsafe
def j_layout_kind(book, env, t, ty, todo, key):
  kc(List<&2, String>, p88_string_eq(key, "Ann"), u => j_layout_term(book, env, kid(t, 0), kid(t, 1), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ref"), u => j_layout_mark(j_layout_array_intrinsic(book, t), Con{nm(t), todo}), u =>
  kc(List<&2, String>, p88_string_eq(key, "App"), u => j_layout_app(book, env, t, wnf(book, j_type(book, env, kid(t, 0))), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Lam"), u => j_layout_lam(book, env, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Mat"), u => j_layout_match(book, env, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ctr"), u => kc(List<&2, String>, Bool.not(p88_string_eq(kc(String, j_layout_native_nat(book, t, wnf(book, ty)), u => "", u => j_literal_typed(book, t, ty)), "")), u => todo, u => j_layout_mark(j_layout_open(book, ty), j_layout_fields(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))), todo))), u =>
  kc(List<&2, String>, p88_string_eq(key, "Let"), u => j_layout_let(book, env, ks(t), ty, todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Rwt"), u => j_layout_term(book, env, kid(t, 2), ty, todo), u => todo))))))))

# Module: src/back/js/validate.bend:213
@unsafe
def j_layout_lam(book, env, t, ty, todo):
  j_layout_term(book, Con{kt("Env", "", ix(t), 0, Con{kid(ty, 0), Nil{}}), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), todo)

# Module: src/back/js/validate.bend:225
@unsafe
def j_layout_match(book, env, t, ty, todo):
  j_layout_mark(j_layout_open(book, kid(ty, 0)), j_layout_term(book, env, kid(t, 0), j_arm_tel(book, j_specialize(book, dt(j_layout_ctor(book, wnf(book, kid(ty, 0)), nm(t))), ks(wnf(book, kid(ty, 0)))), kid(ty, 1)), kc(List<&2, String>, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => todo, u => j_layout_term(book, env, kid(t, 1), ty, todo))))

# Module: src/back/js/validate.bend:237
@unsafe
def j_layout_app(book, env, t, fty, todo):
  j_layout_mark(j_layout_intrinsic(book, j_strip(kid(t, 0)), kid(t, 1)), j_layout_function(book, env, kid(t, 0), fty, kc(List<&2, String>, p98_tag_eq(fty, "All") && U32.is_eq(qt(fty), 0), u => todo, u => j_layout_term(book, env, kid(t, 1), kid(fty, 0), todo))))

# Module: src/back/js/validate.bend:249
@unsafe
def j_layout_function(book, env, t, ty, todo):
  kc(List<&2, String>, p98_tag_eq(j_strip(t), "Ref"), u => Con{nm(j_strip(t)), todo}, u => j_layout_term(book, env, t, ty, todo))

# Module: src/back/js/validate.bend:253
@unsafe
def j_layout_array_name(+name: String) -> Bool:
  kc(Bool, p88_string_eq(name, "Array.new") || p88_string_eq(name, "Array.set") || p88_string_eq(name, "Array.get") || p88_string_eq(name, "Array.swap") || p88_string_eq(name, "Array.size"),
    u => True{},
    u => kc(Bool, String.contains(name, "|"),
      v => String.contains("|Array.new|Array.set|Array.get|Array.swap|Array.size|", "|" ++ name ++ "|"),
      v => False{}))

# Module: src/back/js/validate.bend:266
@unsafe
def j_layout_array_intrinsic(book, f):
  p98_tag_eq(f, "Ref") && db(lookup(book, nm(f))) && j_layout_array_name(nm(f))

# Module: src/back/js/validate.bend:276
@unsafe
def j_layout_intrinsic(book, f, element):
  kc(Bool, j_layout_array_intrinsic(book, f), u => j_layout_element_open(book, j_strip(element)), u => False{})

# An equality has no live layout, even when its two sides remain open.
# Keep normalization inside the original demanded Array branch.

# Module: src/back/js/validate.bend:282
@unsafe
def j_layout_element_open(+book: List<&2,KDef>, +element: KTerm) -> Bool:
  +tag = tg(wnf(book, element))
  Bool.not(p88_string_eq(tag, "ADT") || p88_string_eq(tag, "Eql"))

# Module: src/back/js/validate.bend:295
@unsafe
def j_layout_fields(book, env, args, tel, todo):
  match args:
    case Nil{}: todo
    case Con{h, rest}:
      j_layout_fields(book, env, rest, j_app_type(tel, h), kc(List<&2, String>, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 0), u => todo, u => j_layout_term(book, env, h, kid(tel, 0), todo)))

# Module: src/back/js/validate.bend:310
@unsafe
def j_layout_let(book, env, xs, ty, todo):
  j_layout_bindings(book, env, xs, j_layout_term(book, j_context(book, env, xs), j_body(xs), ty, todo))

# Module: src/back/js/validate.bend:321
@unsafe
def j_layout_bindings(book, env, xs, todo):
  match xs:
    case Nil{}: todo
    case Con{h, Nil{}}: todo
    case Con{h, rest}:
      j_layout_bindings(book, env, rest, kc(List<&2, String>, U32.is_eq(qt(h), 0), u => todo, u => j_layout_term(book, env, kid(h, 0), j_type(book, env, kid(h, 0)), todo)))

# Checked constructor terms identify their ADT; its local telescope lookup avoids
# repeatedly scanning every unrelated definition. Unknown shapes retain fallback.
# A checked native Nat layer has no layout-sensitive fields. Visit its field
# normally, preserving dynamic-tail references, instead of rescanning its suffix.

# Module: src/back/js/validate.bend:333
@unsafe
def j_layout_native_nat(
  +book: List<&2, KDef>,
  +t: KTerm,
  +ty: KTerm,
) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Nat") && db(lookup(book, "Nat")) && ((p88_string_eq(nm(t), "Zero") && U32.is_eq(terms_len(ks(t)), 0)) || (p88_string_eq(nm(t), "Succ") && U32.is_eq(terms_len(ks(t)), 1)))

# Private checked path. Its definitions have just passed annotate_selected;
# field quantities and every child goal come from that same book/context.
# Raw layout callers retain j_layout_error and its original reconstruction.

# Module: src/back/js/validate.bend:344
@unsafe
def jl_checked_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> String:
  p142j_checked_error(book,defs,roots,stops)

@unsafe
def jl_visit(+book: List<&2, KDef>, +defs: List<&2, KDef>, todo: List<&2, String>, +seen: List<&2, String>, +stops: List<&2, String>) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{+name, +rest}:
      kc(Bool, p88_string_eq(name, "$layout.open-array"), u => True{}, u =>
        kc(Bool, has_name(seen, name) || has_name(stops, name), u => jl_visit(book, defs, rest, seen, stops), u =>
          jl_def(book, defs, lookup(defs, name), rest, Con{name, seen}, stops)))

# Module: src/back/js/validate.bend:357
@unsafe
def jl_def(+book: List<&2, KDef>, +defs: List<&2, KDef>, +d: KDef, +todo: List<&2, String>, +seen: List<&2, String>, +stops: List<&2, String>) -> Bool:
  jl_visit(book, defs, kc(List<&2, String>, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0), u => jl_term(book, dv(d), todo), u => todo), seen, stops)

# Module: src/back/js/validate.bend:367
@unsafe
def jl_term(book, t, todo):
  kc(List<&2, String>, p98_tag_eq(t, "Ann"), u => jl_node(book, kid(t, 0), kid(t, 1), todo),
    u => j_layout_term(book, Nil{}, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, todo))

# Module: src/back/js/validate.bend:372
@unsafe
def jl_node(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +key = tg(t)
  kc(List<&2, String>, p88_string_eq(key, "Ann"), u => jl_term(book, t, todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ref"), u => j_layout_mark(j_layout_array_intrinsic(book, t), Con{nm(t), todo}), u =>
  kc(List<&2, String>, p88_string_eq(key, "App"), u => jl_app(book, t, wnf(book, j_type(book, Nil{}, kid(t, 0))), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Lam"), u => jl_term(book, kid(t, 0), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Mat"), u => jl_match(book, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ctr"), u => kc(List<&2, String>, p88_string_eq(kc(String, j_layout_native_nat(book, t, wnf(book, ty)), u => "", u => j_literal_typed(book, t, ty)), ""), u => j_layout_mark(j_layout_open(book, ty), jl_fields(book, ks(t), todo)), u => todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Let"), u => jl_bindings(book, ks(t), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Rwt"), u => jl_term(book, kid(t, 2), todo), u => todo))))))))

# Module: src/back/js/validate.bend:384
@unsafe
def jl_match(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  j_layout_mark(j_layout_open(book, kid(ty, 0)), jl_term(book, kid(t, 0), kc(List<&2, String>, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => todo, u => jl_term(book, kid(t, 1), todo))))

# Module: src/back/js/validate.bend:388
@unsafe
def jl_app(+book: List<&2, KDef>, +t: KTerm, +fty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  j_layout_mark(j_layout_intrinsic(book, j_strip(kid(t, 0)), kid(t, 1)), jl_function(book, kid(t, 0), kc(List<&2, String>, p98_tag_eq(fty, "All") && U32.is_eq(qt(fty), 0), u => todo, u => jl_term(book, kid(t, 1), todo))))

# Module: src/back/js/validate.bend:392
@unsafe
def jl_function(+book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  kc(List<&2, String>, p98_tag_eq(j_strip(t), "Ref"), u => Con{nm(j_strip(t)), todo}, u => jl_term(book, t, todo))

# Module: src/back/js/validate.bend:396
@unsafe
def jl_fields(+book: List<&2, KDef>, args: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match args:
    case Nil{}: todo
    case Con{+h, +rest}:
      jl_fields(book, rest, kc(List<&2, String>, U32.is_eq(qt(h), 0), u => todo, u => jl_term(book, h, todo)))

# Module: src/back/js/validate.bend:403
@unsafe
def jl_bindings(+book: List<&2, KDef>, xs: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: todo
    case Con{h, Nil{}}: jl_term(book, h, todo)
    case Con{+h, +rest}:
      kc(List<&2, String>, U32.is_eq(qt(h), 0), u => jl_bindings(book, rest, todo), u => jl_term(book, kid(h, 0), jl_bindings(book, rest, todo)))
