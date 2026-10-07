import Base

# ISOLATED PROPOSAL, NOT INSTALLED. One immutable memo belongs to one invocation
# of jd_host_plan_exports with one fixed prepared book. No entries enter book.
# Cached strings always come from complete jd_marshal calls (Nil/0/64), never a
# recursive fragment containing another converter's lexical $dmN reference.
type JDHostBuilt is Data:
  JDHostBuilt{+text: String, +memo: KDef, +left: U32}

@unsafe
def jd_host_plan_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}: kc(U32, present, u => 2, u => 1)
    case KLiteral{kind, number, text, begin, end}: 3

# term_key is only an index key. Confirm all non-span raw data on every hit:
# alpha-equivalent binders and normalized Sub/Var keys cannot alias by accident.
# A comparison limit is a cache miss, never a compiler refusal.
@unsafe
def jd_host_plan_same(+a: KTerm, +b: KTerm, +fuel: U32) -> Bool:
  kc(Bool, U32.is_gt(fuel, 0), u =>
    U32.is_eq(jd_host_plan_variant(a), jd_host_plan_variant(b)) &&
    String.eq(tg(a), tg(b)) && String.eq(nm(a), nm(b)) &&
    U32.is_eq(ix(a), ix(b)) && U32.is_eq(qt(a), qt(b)) &&
    U32.is_eq(kl_number(a), kl_number(b)) && String.eq(kl_text(a), kl_text(b)) &&
    jd_host_plan_names(rm(a), rm(b), U32.sub(fuel, 1)) &&
    jd_host_plan_terms(ks(a), ks(b), U32.sub(fuel, 1)), u => False{})

@unsafe
def jd_host_plan_names(+a: List<&2,String>, +b: List<&2,String>, +fuel: U32) -> Bool:
  match a:
    case Nil{}: List.is_empty(&2,String, b)
    case Con{x, xs}:
      match b:
        case Nil{}: False{}
        case Con{y, ys}: kc(Bool, U32.is_gt(fuel, 0), u => String.eq(x, y) && jd_host_plan_names(xs, ys, U32.sub(fuel, 1)), u => False{})

@unsafe
def jd_host_plan_terms(+a: List<&2,KTerm>, +b: List<&2,KTerm>, +fuel: U32) -> Bool:
  match a:
    case Nil{}: List.is_empty(&2,KTerm, b)
    case Con{x, xs}:
      match b:
        case Nil{}: False{}
        case Con{y, ys}: kc(Bool, U32.is_gt(fuel, 0), u => jd_host_plan_same(x, y, fuel) && jd_host_plan_terms(xs, ys, U32.sub(fuel, 1)), u => False{})

# sk_term evaluates Sub while producing a key. Do not introduce that work on
# types where the old classifier may return without demanding that subtree.
@unsafe
def jd_host_plan_key_safe(+t: KTerm, +fuel: U32) -> Bool:
  kc(Bool, U32.is_gt(fuel, 0), u => Bool.not(String.eq(tg(t), "Sub")) &&
    jd_host_plan_keys_safe(ks(t), U32.sub(fuel, 1)), u => False{})

@unsafe
def jd_host_plan_keys_safe(+ts: List<&2,KTerm>, +fuel: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0), u =>
      jd_host_plan_key_safe(t, fuel) && jd_host_plan_keys_safe(rest, U32.sub(fuel, 1)), u => False{})

@unsafe
def jd_host_plan_convert(+book: List<&2,KDef>, +ty: KTerm, +out: Bool,
  +marshal: Bool, +memo: KDef, +left: U32) -> JDHostBuilt:
  kc(JDHostBuilt, marshal,
    u => kc(JDHostBuilt, jd_host_plan_key_safe(ty, 64),
      u => jd_host_plan_lookup(book, ty, out, memo, left, jd_host_marshal_key(ty, out)),
      u => JDHostBuilt{jd_marshal(book, ty, out), memo, left}),
    u => JDHostBuilt{"", memo, left})

@unsafe
def jd_host_plan_lookup(+book: List<&2,KDef>, +ty: KTerm, +out: Bool,
  +memo: KDef, +left: U32, +key: String) -> JDHostBuilt:
  +found = index_find(memo, key, index_hash(key, 2166136261), 32)
  kc(JDHostBuilt, String.eq(dk(found), "JDHostMemo") && jd_host_plan_same(ty, dt(found), 64),
    u => JDHostBuilt{nm(dv(found)), memo, left},
    u => jd_host_plan_insert(ty, key, memo, left, jd_marshal(book, ty, out)))

@unsafe
def jd_host_plan_insert(+ty: KTerm, +key: String, +memo: KDef,
  +left: U32, +text: String) -> JDHostBuilt:
  kc(JDHostBuilt, U32.is_gt(left, 0),
    u => JDHostBuilt{text, index_set(memo,
      KDef{key, "JDHostMemo", 0, 0, ty, kt("JDHostText", text, 0, 0, Nil{}), Nil{}, False{}, False{}},
      index_hash(key, 2166136261), 32), U32.sub(left, 1)},
    u => JDHostBuilt{text, memo, left})

@unsafe
def jd_host_plan_prepend(+text: String, +next: JDHostBuilt) -> JDHostBuilt:
  match next:
    case JDHostBuilt{more, memo, left}: JDHostBuilt{text ++ more, memo, left}

# Unchanged telescope/error printers, with memo state passed in demand order.
# back=False is the argument vector; back=True emits input restoration.
@unsafe
def jd_host_plan_args(+book: List<&2,KDef>, +ty: KTerm, +left: U32,
  +at: U32, +out: Bool, +back: Bool, +marshal: Bool, +memo: KDef, +room: U32) -> JDHostBuilt:
  kc(JDHostBuilt, U32.is_gt(left, 0),
    u => jd_host_plan_args_on(book, wnf(book, ty), left, at, out, back, marshal, memo, room),
    u => JDHostBuilt{"", memo, room})

@unsafe
def jd_host_plan_args_on(+book: List<&2,KDef>, +t: KTerm, +left: U32,
  +at: U32, +out: Bool, +back: Bool, +marshal: Bool, +memo: KDef, +room: U32) -> JDHostBuilt:
  kc(JDHostBuilt, String.eq(tg(t), "All"),
    u => kc(JDHostBuilt, U32.is_eq(qt(t), 0),
      u => jd_host_plan_args(book, j_app_type(t, atom("Absent")), U32.sub(left, 1), at, out, back, marshal, memo, room),
      u => jd_host_plan_arg_done(book, t, left, at, out, back, marshal,
        jd_host_plan_convert(book, kid(t, 0), out, marshal, memo, room))),
    u => JDHostBuilt{kc(String, back, u => "", u => jd_host_error("host formal telescope") ++ "(),"), memo, room})

@unsafe
def jd_host_plan_arg_done(+book: List<&2,KDef>, +t: KTerm, +left: U32,
  +at: U32, +out: Bool, +back: Bool, +marshal: Bool, +built: JDHostBuilt) -> JDHostBuilt:
  match built:
    case JDHostBuilt{text, memo, room}:
      jd_host_plan_prepend(text ++ "(a" ++ U32.show(at) ++ kc(String, back, u => ");", u => "),"),
        jd_host_plan_args(book, j_app_type(t, atom("Absent")), U32.sub(left, 1), U32.inc(at), out, back, marshal, memo, room))

@unsafe
def jd_host_plan_host(+book: List<&2,KDef>, +d: KDef, +memo: KDef, +room: U32) -> JDHostBuilt:
  +arity = jd_arity(book, d)
  +live = jd_live_arity(book, dt(d), arity)
  +marshal = Bool.not(U32.is_eq(jd_host_nat_known(book, dt(d)), 0))
  jd_host_plan_result(book, d, arity, live, marshal,
    jd_host_plan_convert(book, jd_host_result(book, dt(d), arity), True{}, marshal, memo, room))

@unsafe
def jd_host_plan_result(+book: List<&2,KDef>, +d: KDef, +arity: U32,
  +live: U32, +marshal: Bool, +built: JDHostBuilt) -> JDHostBuilt:
  match built:
    case JDHostBuilt{result, memo, room}:
      jd_host_plan_inputs(book, d, arity, live, marshal, result,
        jd_host_plan_args(book, dt(d), arity, 0, False{}, False{}, marshal, memo, room))

@unsafe
def jd_host_plan_inputs(+book: List<&2,KDef>, +d: KDef, +arity: U32,
  +live: U32, +marshal: Bool, +result: String, +built: JDHostBuilt) -> JDHostBuilt:
  match built:
    case JDHostBuilt{args, memo, room}:
      jd_host_plan_finish(d, live, result, args,
        jd_host_plan_args(book, dt(d), arity, 0, True{}, True{}, marshal, memo, room))

@unsafe
def jd_host_plan_finish(+d: KDef, +live: U32, +result: String,
  +args: String, +built: JDHostBuilt) -> JDHostBuilt:
  match built:
    case JDHostBuilt{back, memo, room}:
      JDHostBuilt{"(" ++ jd_host_names(live, 0) ++ ")=>{const r=" ++ result ++
        "(run_loop(" ++ jd_name(dn(d)) ++ "(" ++ args ++ ")));" ++ back ++ "return r;}", memo, room}

@unsafe
def jd_host_plan_export(+book: List<&2,KDef>, +d: KDef, +memo: KDef, +room: U32) -> JDHostBuilt:
  kc(JDHostBuilt, j_io_type(book, dt(d)), u => JDHostBuilt{"", memo, room},
    u => jd_host_plan_export_done(book, d, jd_host_plan_host(book, d, memo, room)))

@unsafe
def jd_host_plan_export_done(+book: List<&2,KDef>, +d: KDef, +built: JDHostBuilt) -> JDHostBuilt:
  match built:
    case JDHostBuilt{text, memo, room}: JDHostBuilt{
      j_quote(dn(d)) ++ ":run_lib(" ++ text ++ "," ++
        U32.show(jd_live_arity(book, dt(d), jd_arity(book, d))) ++ "),\n", memo, room}

@unsafe
def jd_host_plan_exports(+book: List<&2,KDef>, +defs: List<&2,KDef>, +memo: KDef, +room: U32) -> String:
  match defs:
    case Nil{}: ""
    case Con{d, rest}:
      jd_host_plan_exports_next(book, rest,
        kc(JDHostBuilt, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(db(d)) &&
          Bool.not(String.eq(tg(j_strip(dv(d))), "Absent")) && Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")),
          u => jd_host_plan_export(book, d, memo, room), u => JDHostBuilt{"", memo, room}))

@unsafe
def jd_host_plan_exports_next(+book: List<&2,KDef>, +rest: List<&2,KDef>, +built: JDHostBuilt) -> String:
  match built:
    case JDHostBuilt{text, memo, room}: text ++ jd_host_plan_exports(book, rest, memo, room)
