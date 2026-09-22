import Base

law kc:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

@unsafe
def kc(A, b, yes, no):
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# First-order trusted core. Binder identifiers are globally unique.
# Quantities: 0 erased, 1 affine, 2 unrestricted. No function-valued fields.
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>}

type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}

law kt:
  for +tag: String
  for +name: String
  for +id: U32
  for +quant: U32
  for +kids: List<&2, KTerm>
  KTerm

@unsafe
def kt(tag, name, id, quant, kids):
  KTerm{tag, name, id, quant, kids, Nil{}}

law atom:
  for +tag: String
  KTerm

@unsafe
def atom(tag):
  kt(tag, "", 0, 0, Nil{})

law tg:
  for +t: KTerm
  String

@unsafe
def tg(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      tag

law nm:
  for +t: KTerm
  String

@unsafe
def nm(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      name

law ix:
  for +t: KTerm
  U32

@unsafe
def ix(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      id

law qt:
  for +t: KTerm
  U32

@unsafe
def qt(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      quant

law ks:
  for +t: KTerm
  List<&2, KTerm>

@unsafe
def ks(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      kids

law rm:
  for +t: KTerm
  List<&2, String>

@unsafe
def rm(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      removed

law terms_at:
  for +ts: List<&2, KTerm>
  for +n: U32
  KTerm

@unsafe
def terms_at(ts, n):
  match ts:
    case Nil{}:
      atom("Absent")
    case Con{h, t}:
      kc(KTerm, U32.is_eq(n, 0), u => h, u => terms_at(t, U32.sub(n, 1)))

law kid:
  for +t: KTerm
  for +n: U32
  KTerm

@unsafe
def kid(t, n):
  terms_at(ks(t), n)

law var:
  for +name: String
  for +id: U32
  KTerm

@unsafe
def var(name, id):
  kt("Var", name, id, 0, Nil{})

law ref:
  for +name: String
  KTerm

@unsafe
def ref(name):
  kt("Ref", name, 0, 0, Nil{})

law qua:
  for +q: U32
  KTerm

@unsafe
def qua(q):
  kt("Qua", "", 0, q, Nil{})

law typ:
  for +q: U32
  KTerm

@unsafe
def typ(q):
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})

law app:
  for +f: KTerm
  for +x: KTerm
  KTerm

@unsafe
def app(f, x):
  kt("App", "", 0, 0, Con{f, Con{x, Nil{}}})

law all:
  for +q: U32
  for +name: String
  for +id: U32
  for +a: KTerm
  for +b: KTerm
  KTerm

@unsafe
def all(q, name, id, a, b):
  kt("All", name, id, q, Con{a, Con{b, Nil{}}})

law dn:
  for +d: KDef
  String

@unsafe
def dn(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name

law dk:
  for +d: KDef
  String

@unsafe
def dk(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kind

law da:
  for +d: KDef
  U32

@unsafe
def da(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      arity

law dx:
  for +d: KDef
  U32

@unsafe
def dx(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      templates

law dt:
  for +d: KDef
  KTerm

@unsafe
def dt(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      typ

law dv:
  for +d: KDef
  KTerm

@unsafe
def dv(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      value

law dc:
  for +d: KDef
  List<&2, KDef>

@unsafe
def dc(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ctors

law db:
  for +d: KDef
  Bool

@unsafe
def db(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      native

law du:
  for +d: KDef
  Bool

@unsafe
def du(d):
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      unsafe

law missing:
  KDef

@unsafe
def missing():
  KDef{"", "Absent", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}

law lookup:
  for +book: List<&2, KDef>
  for +name: String
  KDef

@unsafe
def lookup(book, name):
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      kc(KDef, String.eq(dk(d), "BookCache"), u => index_lookup(d, name), u => kc(KDef, String.eq(dn(d), name), u => d, u => lookup(rest, name)))

law terms_len:
  for +ts: List<&2, KTerm>
  U32

@unsafe
def terms_len(ts):
  match ts:
    case Nil{}:
      0
    case Con{h, t}:
      U32.add(1, terms_len(t))

law has_name:
  for +ns: List<&2, String>
  for +name: String
  Bool

@unsafe
def has_name(ns, name):
  match ns:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, String.eq(h, name), u => True{}, u => has_name(t, name))

law subst_terms:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

law core_force:
  for +t: KTerm
  KTerm

law core_rebuild:
  for +t: KTerm
  KTerm

law core_apply:
  for +f: KTerm
  for +x: KTerm
  KTerm

law subst_node:
  for +t: KTerm
  for +id: U32
  for +v: KTerm
  KTerm

law subst:
  for +t: KTerm
  for +id: U32
  for +v: KTerm
  KTerm

@unsafe
def subst(t, id, v):
  kc(KTerm, String.eq(tg(t), "Var"), u => kc(KTerm, U32.is_eq(ix(t), id), u => v, u => t), u => subst_node(t, id, v))

@unsafe
def subst_node(t, id, v):
  match t:
    case KTerm{tag, name, n, q, kids, removed}:
      core_rebuild(KTerm{tag, name, n, q, subst_terms(kids, id, v), removed})

@unsafe
def subst_terms(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{subst(h, id, v), subst_terms(t, id, v)}


@unsafe
def core_force(t):
  kc(KTerm, String.eq(tg(t), "Ann"), u => core_force(kid(t, 0)),
    u => kc(KTerm, String.eq(tg(t), "Var") && U32.is_gt(terms_len(ks(t)), 0), u => core_force(kid(t, 0)), u => t))

@unsafe
def core_rebuild(t):
  kc(KTerm, String.eq(tg(t), "App"), u => core_apply(kid(t, 0), kid(t, 1)), u => t)

@unsafe
def core_apply(f, x):
  kc(KTerm, String.eq(tg(f), "Lam"), u => subst(kid(f, 0), ix(f), x), u => app(f, x))

law core_beta:
  for +t: KTerm
  KTerm

@unsafe
def core_beta(t):
  kc(KTerm, String.eq(tg(t), "App"), u => core_apply(core_beta(kid(t, 0)), kid(t, 1)), u => t)

# Scan in substitution order: Var test, children, then App rebuilding.
# A false fact returns to ordinary substitution, preserving its work and errors.
# A canonical App also survives substitution unchanged if both children do and
# its unchanged function is not Lam. Every metadata/arity check is necessary
# because core_rebuild canonicalizes App nodes even without beta reduction.
law core_subst_stable:
  for +t: KTerm
  Bool

law core_subst_stable_terms:
  for +ts: List<&2, KTerm>
  Bool

law core_subst_stable_app:
  for +kids: List<&2, KTerm>
  for +removed: List<&2, String>
  Bool

@unsafe
def core_subst_stable(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      kc(Bool, String.eq(tag, "Var"), u => False{},
        u => kc(Bool, core_subst_stable_terms(kids),
          u => kc(Bool, String.eq(tag, "App"),
            u => kc(Bool, String.eq(name, "") && U32.is_eq(id, 0) && U32.is_eq(quant, 0), u => core_subst_stable_app(kids, removed), u => False{}),
            u => True{}),
          u => False{}))

@unsafe
def core_subst_stable_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, core_subst_stable(h), u => core_subst_stable_terms(rest), u => False{})

law core_subst_stable_app_kids:
  for +kids: List<&2, KTerm>
  Bool

law core_subst_stable_app_tail:
  for +f: KTerm
  for +tail: List<&2, KTerm>
  Bool

law core_subst_stable_app_last:
  for +f: KTerm
  for +x: KTerm
  for +rest: List<&2, KTerm>
  Bool

@unsafe
def core_subst_stable_app(kids, removed):
  match removed:
    case Con{h, rest}: False{}
    case Nil{}: core_subst_stable_app_kids(kids)

@unsafe
def core_subst_stable_app_kids(kids):
  match kids:
    case Nil{}: False{}
    case Con{f, tail}: core_subst_stable_app_tail(f, tail)

@unsafe
def core_subst_stable_app_tail(f, tail):
  match tail:
    case Nil{}: False{}
    case Con{x, rest}: core_subst_stable_app_last(f, x, rest)

@unsafe
def core_subst_stable_app_last(f, x, rest):
  match rest:
    case Con{h, tail}: False{}
    case Nil{}:
      Bool.not(String.eq(tg(f), "Lam"))

