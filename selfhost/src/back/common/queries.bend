
# Module: src/back/common/queries.bend:17
law j_type:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/back/common/queries.bend:27
law j_type_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +key: String
  KTerm

# Module: src/back/common/queries.bend:38
law j_app_type:
  for +ty: KTerm
  for +arg: KTerm
  KTerm

# Module: src/back/common/queries.bend:47
law j_call_spine:
  for +t: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:56
law j_context:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/common/queries.bend:72
law j_body:
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:85
law j_find_ctor:
  for +book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/back/common/queries.bend:110
law j_found_ctor:
  for +found: KDef
  for +rest: List<&2, KDef>
  for +name: String
  KDef

# Module: src/back/common/queries.bend:120
law j_specialize:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:134
law j_arm_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +name: String
  KTerm

# Module: src/back/common/queries.bend:153
law j_arm_tel:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +ret: KTerm
  KTerm

# Module: src/back/common/queries.bend:162
law j_io_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/common/queries.bend:171
law j_io_shadow:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/back/common/queries.bend:179
law j_io_shadow_def:
  for +book: List<&2, KDef>
  for +d: KDef
  List<&2, KDef>

# Module: src/back/common/queries.bend:188
law j_io_spine:
  for +t: KTerm
  for +args: U32
  Bool

# Module: src/back/common/queries.bend:197
law j_constructor_count:
  for +book: List<&2, KDef>
  for +ty: KTerm
  U32

# Module: src/back/common/queries.bend:206
law j_count_constructors:
  for +ctors: List<&2, KDef>
  for +removed: List<&2, String>
  U32

# Module: src/back/common/queries.bend:7
@unsafe
def j_env(
  +env: List<&2, KTerm>,
  +id: U32,
) -> KTerm:
  match env:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      kc(KTerm, U32.is_eq(ix(h), id), u => kid(h, 0), u => j_env(rest, id))

# Module: src/back/common/queries.bend:24
@unsafe
def j_type(book, env, t):
  j_type_on(book, env, t, tg(t))

# Module: src/back/common/queries.bend:35
@unsafe
def j_type_on(book, env, t, key):
  kc(KTerm, p88_string_eq(key, "Ann"), u => kid(t, 1), u => kc(KTerm, p88_string_eq(key, "Var"), u => j_env(env, ix(t)), u => kc(KTerm, p88_string_eq(key, "Ref"), u => dt(lookup(book, nm(t))), u => kc(KTerm, p88_string_eq(key, "App"), u => j_app_type(wnf(book, j_type(book, env, kid(t, 0))), kid(t, 1)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))))

# Module: src/back/common/queries.bend:44
@unsafe
def j_app_type(ty, arg):
  kc(KTerm, p98_tag_eq(ty, "All"), u => subst(kid(ty, 1), ix(ty), arg), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/common/queries.bend:53
@unsafe
def j_call_spine(t, args):
  kc(KTerm, p98_tag_eq(t, "Ann"), u => j_call_spine(kid(t, 0), args), u => kc(KTerm, p98_tag_eq(t, "App"), u => j_call_spine(kid(t, 0), Con{kid(t, 1), args}), u => kc(KTerm, p98_tag_eq(t, "Ref"), u => kt("Call", nm(t), 0, 0, args), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})))

# Module: src/back/common/queries.bend:63
@unsafe
def j_context(book, env, xs):
  match xs:
    case Nil{}:
      env
    case Con{h, Nil{}}:
      env
    case Con{h, rest}:
      Con{kt("Env", "", ix(h), 0, Con{j_type(book, env, kid(h, 0)), Nil{}}), j_context(book, env, rest)}

# Module: src/back/common/queries.bend:77
@unsafe
def j_body(xs):
  match xs:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, Nil{}}:
      h
    case Con{h, rest}:
      j_body(rest)

# Module: src/back/common/queries.bend:91
@unsafe
def j_find_ctor(book, name):
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      j_find_ctor_children(dc(d), rest, name)

# A failed child scan continues with the next owner without constructing Absent.
# A cached child list retains lookup's cache-stop semantics, including a miss.

# Module: src/back/common/queries.bend:101
@unsafe
def j_find_ctor_children(+children: List<&2,KDef>, +rest: List<&2,KDef>, +name: String) -> KDef:
  match children:
    case Nil{}: j_find_ctor(rest, name)
    case Con{d, more}:
      kc(KDef, p88_string_eq(dk(d), "BookCache"),
        u => j_found_ctor(index_lookup(d, name), rest, name),
        u => kc(KDef, p88_string_eq(dn(d), name),
          v => j_found_ctor(d, rest, name), v => j_find_ctor_children(more, rest, name)))

# Module: src/back/common/queries.bend:117
@unsafe
def j_found_ctor(found, rest, name):
  kc(KDef, p88_string_eq(dk(found), "Absent"), u => j_find_ctor(rest, name), u => found)

# Module: src/back/common/queries.bend:127
@unsafe
def j_specialize(book, tel, args):
  match args:
    case Nil{}:
      tel
    case Con{h, rest}:
      j_specialize(book, j_app_type(wnf(book, tel), h), rest)

# Module: src/back/common/queries.bend:141
@unsafe
def j_arm_type(book, ty, name):
  j_arm_type_domain(book, ty, name, wnf(book, kid(ty, 0)))

# Checked books have unique constructor names. Like the Phase55 arity query,
# use the normalized matcher owner only when both telescope and ADT are known.
# Unknown shapes and absent owner constructors keep the global first-match path.

# Module: src/back/common/queries.bend:148
@unsafe
def j_arm_type_domain(+book: List<&2,KDef>, +ty: KTerm, +name: String, +domain: KTerm) -> KTerm:
  j_arm_tel(book, j_specialize(book,
    dt(kc(KDef, p98_tag_eq(ty, "All") && p98_tag_eq(domain, "ADT"),
      u => j_layout_ctor(book, domain, name), u => j_find_ctor(book, name))), ks(domain)), kid(ty, 1))

# Module: src/back/common/queries.bend:160
@unsafe
def j_arm_tel(book, tel, ret):
  kc(KTerm, p98_tag_eq(tel, "All"), u => all(qt(tel), nm(tel), ix(tel), kid(tel, 0), j_arm_tel(book, kid(tel, 1), ret)), u => ret)

# Module: src/back/common/queries.bend:168
@unsafe
def j_io_type(book, ty):
  kc(Bool, p88_string_eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u => j_io_spine(wnf(j_io_shadow(book), ty), 0), u => False{})

# Module: src/back/common/queries.bend:176
@unsafe
def j_io_shadow(book):
  j_io_shadow_def(book, lookup(book, "IO"))

# Module: src/back/common/queries.bend:185
@unsafe
def j_io_shadow_def(book, d):
  book_put(book, KDef{dn(d), dk(d), da(d), dx(d), dt(d), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dc(d), db(d), du(d)})

# Module: src/back/common/queries.bend:194
@unsafe
def j_io_spine(t, args):
  kc(Bool, p98_tag_eq(t, "App"), u => j_io_spine(kid(t, 0), U32.add(args, 1)), u => p98_tag_eq(t, "Ref") && p88_string_eq(nm(t), "IO") && U32.is_eq(args, 1))

# Module: src/back/common/queries.bend:203
@unsafe
def j_constructor_count(book, ty):
  j_count_constructors(dc(lookup(book, nm(ty))), rm(ty))

# Module: src/back/common/queries.bend:212
@unsafe
def j_count_constructors(ctors, removed):
  match ctors:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, has_name(removed, dn(d)), u => 0, u => 1), j_count_constructors(rest, removed))

# Module: src/back/common/queries.bend:220
@unsafe
def j_layout_ctor(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +name: String,
) -> KDef:
  +d = lookup(dc(lookup(book, nm(ty))), name)
  kc(KDef, p98_tag_eq(ty, "ADT") && p88_string_eq(dk(d), "Ctr"), u => d, u => j_find_ctor(book, name))
