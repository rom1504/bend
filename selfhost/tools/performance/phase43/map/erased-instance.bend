# Staged bounded contextual specialization. Facts remain separate from source
# KDefs/JPure; no fact is accepted by ordinary exact_def or name-only lookup.
# da=frozen erased-prefix length; dx=original runtime arity. The eventual clone
# adapter consumes dx arguments, keeps erased null slots and starts body at da.
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

@unsafe
def j_erased_instance(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm) -> Maybe<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(Maybe<&2,KDef>, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)) && j_u32_bounded([dv(d)], 4096), u =>
    j_erased_instance_step(book, env, d, dv(d), dt(d), ks(spine), Nil{}, 0, 8192), u => None{})

@unsafe
def j_erased_instance_step(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  +head = wnf(book, ty)
  +term = j_strip(body)
  kc(Maybe<&2,KDef>, String.eq(tg(head), "All") && U32.is_eq(qt(head), 0), u =>
    kc(Maybe<&2,KDef>, U32.is_lt(prefix, 4) && U32.is_gt(fuel, 0) && String.eq(tg(term), "Lam") && U32.is_eq(qt(term), 0) && String.eq(j_l_name(term), ""), u =>
      j_erased_instance_arg(book, env, original, term, head, args, slots, prefix, fuel), u => None{}), u =>
    kc(Maybe<&2,KDef>, U32.is_gt(prefix, 0) && j_pure_signature(book, head, U32.sub(da(original), prefix)) &&
      U32.is_eq(terms_len(args), U32.sub(da(original), prefix)), u =>
      Some{KDef{dn(original), "JErasedInstance", prefix, da(original), head, body, Con{original, slots}, True{}, False{}}}, u => None{}))

@unsafe
def j_erased_instance_arg(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +fuel: U32) -> Maybe<&2,KDef>:
  match args:
    case Nil{}: None{}
    case Con{h, rest}:
      kc(Maybe<&2,KDef>, j_erased_closed_arg(book, h) &&
        exact_term(wnf(book, j_type(book, env, h)), wnf(book, kid(ty, 0))), u =>
        j_erased_instance_scanned(book, env, original, body, ty, h, rest, slots, prefix,
          j_erased_runtime_scan(book, [kid(body, 0)], ix(body), U32.sub(fuel, 1))), u => None{})

@unsafe
def j_erased_instance_scanned(+book: List<&2,KDef>, +env: List<&2,KTerm>, +original: KDef, +body: KTerm, +ty: KTerm, +arg: KTerm, +rest: List<&2,KTerm>, +slots: List<&2,KDef>, +prefix: U32, +r: Maybe<&2,U32>) -> Maybe<&2,KDef>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +slot = KDef{"", "JErasedSlot", ix(ty), ix(body), kid(ty, 0), arg, Nil{}, False{}, False{}}
      j_erased_instance_step(book, env, original, subst(kid(body, 0), ix(body), arg), j_app_type(ty, arg), rest,
        List.append(&2,KDef, slots, [slot]), U32.inc(prefix), fuel)

@unsafe
def j_erased_instance_same(+a: KDef, +b: KDef) -> Bool:
  String.eq(dk(a), "JErasedInstance") && String.eq(dk(b), "JErasedInstance") &&
    U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && exact_defs(dc(a), dc(b)) &&
    exact_term(dt(a), dt(b)) && exact_term(dv(a), dv(b))
