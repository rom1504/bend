# Staged bounded contextual specialization. Facts remain separate from source
# KDefs/JPure; no fact is accepted by ordinary exact_def or name-only lookup.
# da=frozen erased-prefix length; dx=original runtime arity. The eventual clone
# adapter analyzes dx-da live slots; the unchanged public ABI keeps null prefix slots.
@unsafe
def j_erased_closed_arg(+book: List<&2,KDef>, +arg: KTerm) -> Bool:
  +head = wnf(book, arg)
  kc(Bool, String.eq(tg(head), "Qua"), u =>
    (U32.is_eq(qt(head), 1) || U32.is_eq(qt(head), 2)) && List.is_empty(&2,KTerm, ks(head)) && List.is_empty(&2,String, rm(head)), u =>
    j_pure_type(book, head) && j_pure_shape_bound([head], 256))

@unsafe
def j_erased_runtime_scan(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  match todo:
    case Nil{}: Some{fuel}
    case Con{t, rest}:
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && Bool.not(String.eq(tg(t), "Var") && U32.is_eq(ix(t), binder)), u =>
        kc(Maybe<&2,U32>, String.eq(tg(t), "Ann"), u =>
          j_erased_runtime_scan(book, Con{kid(t, 0), rest}, binder, U32.sub(fuel, 1)), u =>
        kc(Maybe<&2,U32>, String.eq(tg(t), "App"), u =>
          j_erased_runtime_call(book, j_call_spine(t, Nil{}), rest, binder, U32.sub(fuel, 1)), u =>
          j_erased_runtime_scan(book, List.append(&2,KTerm, ks(t), rest), binder, U32.sub(fuel, 1)))), u => None{})

@unsafe
def j_erased_runtime_call(+book: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,U32>, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)) && U32.is_le(da(d), 32), u =>
    j_erased_runtime_args(book, ks(spine), dt(d), rest, binder, fuel), u => None{})

@unsafe
def j_erased_runtime_args(+book: List<&2,KDef>, +args: List<&2,KTerm>, +ty: KTerm, +todo: List<&2,KTerm>, +binder: U32, +fuel: U32) -> Maybe<&2,U32>:
  match args:
    case Nil{}: j_erased_runtime_scan(book, todo, binder, fuel)
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && String.eq(tg(head), "All"), u =>
        j_erased_runtime_args(book, rest, j_app_type(head, h),
          kc(List<&2,KTerm>, U32.is_eq(qt(head), 0), u => todo, u => Con{h, todo}), binder, U32.sub(fuel, 1)), u => None{})

# Match j_def's unconditional source-emission path. Native intrinsics may retain
# a runtime override; they are not source-body instances or source aliases.
@unsafe
def j_instance_source_definition(+d: KDef) -> Bool:
  String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(dv(d)), "Absent")) && Bool.not(String.eq(tg(dv(d)), "Foreign")) &&
    (Bool.not(db(d)) || Bool.not(j_intrinsic(dn(d))))

@unsafe
def j_erased_instance(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm) -> Maybe<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,KDef>, String.eq(tg(spine), "Call") && j_instance_source_definition(d) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)) && j_u32_bounded([dv(d)], 4096), u =>
    j_erased_instance_step(book, env, d, dv(d), dt(d), ks(spine), Nil{}, 0, 8192), u => None{})

@unsafe
def j_erased_instance_step(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  # The typed All determines erasure; the library pipeline normalizes Lam qty.
  # Runtime absence below proves that substituting this binder is type-only.
  +head = wnf(book, ty)
  +term = j_strip(body)
  kc(Maybe<&2,KDef>, String.eq(tg(head), "All") && U32.is_eq(qt(head), 0), u =>
    kc(Maybe<&2,KDef>, U32.is_lt(prefix, 4) && U32.is_gt(fuel, 0) && String.eq(tg(term), "Lam") && String.eq(j_l_name(term), ""), u =>
      j_erased_instance_arg(book, env, original, term, head, args, slots, prefix, fuel), u => None{}), u =>
    kc(Maybe<&2,KDef>, U32.is_gt(prefix, 0) && j_pure_signature(book, head, U32.sub(da(original), prefix)) &&
      U32.is_eq(terms_len(args), U32.sub(da(original), prefix)), u =>
      Some{KDef{dn(original), "JErasedInstance", prefix, da(original), head, body, Con{original, slots}, True{}, False{}}}, u => None{}))

# check_fits uses compare(actual, expected, True); norm_cmp_kind allows Data
# (Qua2) to fit Type (Qua1). Only closed, normalized literal kind quantities are
# admitted here, with reverse1->2 refused. Ground argument/value proofs stay exact.
@unsafe
def j_erased_kind_fits(+book: List<&2,KDef>, +actual: KTerm, +expected: KTerm) -> Bool:
  exact_term(actual, expected) ||
    (j_erased_closed_kind(book, actual, 2) && j_erased_closed_kind(book, expected, 1)) ||
    (j_erased_closed_kind(book, actual, 1) && j_erased_closed_kind(book, expected, 1)) ||
    (j_erased_closed_kind(book, actual, 2) && j_erased_closed_kind(book, expected, 2))

@unsafe
def j_erased_closed_kind(+book: List<&2,KDef>, +ty: KTerm, +q: U32) -> Bool:
  kc(Bool, String.eq(tg(ty), "Typ") && U32.is_eq(terms_len(ks(ty)), 1) && List.is_empty(&2,String, rm(ty)),
    u => j_erased_kind_quantity(wnf(book, kid(ty, 0)), q), u => False{})

@unsafe
def j_erased_kind_quantity(+q: KTerm, +expected: U32) -> Bool:
  String.eq(tg(q), "Qua") && U32.is_eq(qt(q), expected) &&
    List.is_empty(&2,KTerm, ks(q)) && List.is_empty(&2,String, rm(q))

@unsafe
def j_erased_instance_arg(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  match args:
    case Nil{}: None{}
    case Con{h, rest}:
      kc(Maybe<&2,KDef>, j_erased_closed_arg(book, h) &&
        j_erased_kind_fits(book, wnf(book, j_erased_arg_type(book, wnf(book, h))), wnf(book, kid(ty, 0))), u =>
        j_erased_instance_scanned(book, env, original, body, ty, wnf(book, h), rest, slots, prefix,
          j_erased_runtime_scan(book, [kid(body, 0)], ix(body), U32.sub(fuel, 1))), u => None{})

@unsafe
def j_erased_instance_scanned(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +arg: KTerm, +rest: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +r: Maybe<&2,U32>) -> Maybe<&2,KDef>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +slot: KDef = KDef{"", "JErasedSlot", ix(ty), ix(body), kid(ty, 0), arg, Nil{}, False{}, False{}}
      j_erased_instance_step(book, env, original, subst(kid(body, 0), ix(body), arg), j_app_type(ty, arg), rest,
        List.append(&2,KDef, slots, [slot]), U32.inc(prefix), fuel)

@unsafe
def j_erased_instance_same(+a: KDef, +b: KDef) -> Bool:
  String.eq(dk(a), "JErasedInstance") && String.eq(dk(b), "JErasedInstance") &&
    U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && exact_defs(dc(a), dc(b)) &&
    exact_term(dt(a), dt(b)) && exact_term(dv(a), dv(b))


@unsafe
def j_erased_arg_type(+book: List<&2,KDef>, +arg: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(arg), "Qua"), u => atom("Qnt"), u =>
    kc(KTerm, String.eq(tg(arg), "ADT"), u => tele_fill(book, dt(lookup(book, nm(arg))), ks(arg)), u => atom("Absent")))
