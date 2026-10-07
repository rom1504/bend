# Private direct-backend specialization. Same result/fallback as j_specialize;
# the beta-stable environment proof and realization are shared with the checker.
@unsafe
def jd_specialize(+book: List<&2,KDef>, +tel: KTerm, +args: List<&2,KTerm>) -> KTerm:
  kc(KTerm, env_tele_many(args),
    u => kc(KTerm, env_tele_safe(tel),
      v => jd_specialize_cursor(book, tel, args, Nil{}, 0),
      v => j_specialize(book, tel, args)),
    u => j_specialize(book, tel, args))

law jd_specialize_cursor:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KTerm

@unsafe
def jd_specialize_cursor(book, tel, args, bindings, count):
  match args:
    case Nil{}: env_subst_apply(tel, bindings)
    case Con{h, rest}:
      kc(KTerm, String.eq(tg(tel), "All") && U32.is_lt(count, 64),
        u => kc(KTerm, env_tele_safe(h),
          v => jd_specialize_cursor(book, kid(tel, 1), rest,
            Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.inc(count)),
          v => jd_specialize_fallback(book, tel, args, bindings)),
        u => jd_specialize_fallback(book, tel, args, bindings))

@unsafe
def jd_specialize_fallback(+book: List<&2,KDef>, +tel: KTerm,
  +args: List<&2,KTerm>, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  j_specialize(book, env_subst_apply(tel, bindings), args)
