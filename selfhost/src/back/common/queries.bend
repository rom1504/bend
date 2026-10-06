import Base

# Shared typed backend queries: application, binders, constructors and IO facts.
# These operate on the checked book and KTerm; runtime/emission policy stays in back/js.

@unsafe
def j_env(
  +env: List<&2, KTerm>,
  +id: U32,
) -> KTerm:
  match env:
    case Nil{}:
      atom("Absent")
    case Con{h, rest}:
      kc(KTerm, U32.is_eq(ix(h), id), u => kid(h, 0), u => j_env(rest, id))

law j_type:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  KTerm

@unsafe
def j_type(book, env, t):
  j_type_on(book, env, t, tg(t))

law j_type_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +key: String
  KTerm

@unsafe
def j_type_on(book, env, t, key):
  kc(KTerm, String.eq(key, "Ann"), u => kid(t, 1), u => kc(KTerm, String.eq(key, "Var"), u => j_env(env, ix(t)), u => kc(KTerm, String.eq(key, "Ref"), u => dt(lookup(book, nm(t))), u => kc(KTerm, String.eq(key, "App"), u => j_app_type(wnf(book, j_type(book, env, kid(t, 0))), kid(t, 1)), u => atom("Absent")))))

law j_app_type:
  for +ty: KTerm
  for +arg: KTerm
  KTerm

@unsafe
def j_app_type(ty, arg):
  kc(KTerm, String.eq(tg(ty), "All"), u => subst(kid(ty, 1), ix(ty), arg), u => atom("Absent"))

law j_call_spine:
  for +t: KTerm
  for +args: List<&2, KTerm>
  KTerm

@unsafe
def j_call_spine(t, args):
  kc(KTerm, String.eq(tg(t), "Ann"), u => j_call_spine(kid(t, 0), args), u => kc(KTerm, String.eq(tg(t), "App"), u => j_call_spine(kid(t, 0), Con{kid(t, 1), args}), u => kc(KTerm, String.eq(tg(t), "Ref"), u => kt("Call", nm(t), 0, 0, args), u => atom("Absent"))))

law j_context:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

@unsafe
def j_context(book, env, xs):
  match xs:
    case Nil{}:
      env
    case Con{h, Nil{}}:
      env
    case Con{h, rest}:
      Con{kt("Env", "", ix(h), 0, Con{j_type(book, env, kid(h, 0)), Nil{}}), j_context(book, env, rest)}

law j_body:
  for +xs: List<&2, KTerm>
  KTerm

@unsafe
def j_body(xs):
  match xs:
    case Nil{}:
      atom("Absent")
    case Con{h, Nil{}}:
      h
    case Con{h, rest}:
      j_body(rest)
law j_find_ctor:
  for +book: List<&2, KDef>
  for +name: String
  KDef

@unsafe
def j_find_ctor(book, name):
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      j_found_ctor(lookup(dc(d), name), rest, name)

law j_found_ctor:
  for +found: KDef
  for +rest: List<&2, KDef>
  for +name: String
  KDef

@unsafe
def j_found_ctor(found, rest, name):
  kc(KDef, String.eq(dk(found), "Absent"), u => j_find_ctor(rest, name), u => found)

law j_specialize:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  KTerm

@unsafe
def j_specialize(book, tel, args):
  match args:
    case Nil{}:
      tel
    case Con{h, rest}:
      j_specialize(book, j_app_type(wnf(book, tel), h), rest)

law j_arm_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +name: String
  KTerm

@unsafe
def j_arm_type(book, ty, name):
  j_arm_tel(book, j_specialize(book, dt(j_find_ctor(book, name)), ks(wnf(book, kid(ty, 0)))), kid(ty, 1))

law j_arm_tel:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +ret: KTerm
  KTerm

@unsafe
def j_arm_tel(book, tel, ret):
  kc(KTerm, String.eq(tg(tel), "All"), u => all(qt(tel), nm(tel), ix(tel), kid(tel, 0), j_arm_tel(book, kid(tel, 1), ret)), u => ret)
law j_io_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

@unsafe
def j_io_type(book, ty):
  kc(Bool, String.eq(dk(lookup(book, "IO")), "Def") && db(lookup(book, "IO")), u => j_io_spine(wnf(j_io_shadow(book), ty), 0), u => False{})

law j_io_shadow:
  for +book: List<&2, KDef>
  List<&2, KDef>

@unsafe
def j_io_shadow(book):
  j_io_shadow_def(book, lookup(book, "IO"))

law j_io_shadow_def:
  for +book: List<&2, KDef>
  for +d: KDef
  List<&2, KDef>

@unsafe
def j_io_shadow_def(book, d):
  book_put(book, KDef{dn(d), dk(d), da(d), dx(d), dt(d), atom("Absent"), dc(d), db(d), du(d)})

law j_io_spine:
  for +t: KTerm
  for +args: U32
  Bool

@unsafe
def j_io_spine(t, args):
  kc(Bool, String.eq(tg(t), "App"), u => j_io_spine(kid(t, 0), U32.add(args, 1)), u => String.eq(tg(t), "Ref") && String.eq(nm(t), "IO") && U32.is_eq(args, 1))

law j_constructor_count:
  for +book: List<&2, KDef>
  for +ty: KTerm
  U32

@unsafe
def j_constructor_count(book, ty):
  j_count_constructors(dc(lookup(book, nm(ty))), rm(ty))

law j_count_constructors:
  for +ctors: List<&2, KDef>
  for +removed: List<&2, String>
  U32

@unsafe
def j_count_constructors(ctors, removed):
  match ctors:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, has_name(removed, dn(d)), u => 0, u => 1), j_count_constructors(rest, removed))

@unsafe
def j_layout_ctor(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +name: String,
) -> KDef:
  +d = lookup(dc(lookup(book, nm(ty))), name)
  kc(KDef, String.eq(tg(ty), "ADT") && String.eq(dk(d), "Ctr"), u => d, u => j_find_ctor(book, name))
