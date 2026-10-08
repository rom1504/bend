import Base

# Shared typed source-call arity and runtime-slot analysis. Historical jd_ names
# are retained to preserve existing callers and exact function bodies. This
# module emits no JavaScript or C; both backends consume the original typed book.

@unsafe
def jd_arity(+book: List<&2,KDef>, +d: KDef) -> U32:
  kc(U32, String.eq(tg(j_strip(dv(d))), "Foreign"), u => jd_domains(book, dt(d)), u =>
    U32.add(da(d), U32.min(jd_raise(book, dv(d), da(d)), U32.sub(jd_domains(book, dt(d)), da(d)))))

# Pinned fun_of/def_raise: open common lambda prefixes beyond declared formals,
# including prefixes shared by every matcher arm, capped by the type telescope.
@unsafe
def jd_domains(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  jd_domains_head(book, wnf(book, ty))

@unsafe
def jd_domains_head(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  kc(U32, String.eq(tg(ty), "All"), u => U32.inc(jd_domains(book, kid(ty, 1))), u => 0)

@unsafe
def jd_raise(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  kc(U32, String.eq(tg(t), "Ann"), u =>
    kc(U32, String.eq(tg(j_strip(t)), "Mat"), v =>
      jd_raise_typed(book, j_strip(t), left, wnf(book, kid(t, 1))),
      v => jd_raise_head(book, j_strip(t), left)),
    u => jd_raise_head(book, j_strip(t), left))

# Checked annotation supplies the matcher owner. Constructor names are unique
# in checked books; unknown/unannotated inputs retain the original global search.
@unsafe
def jd_raise_typed(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ty: KTerm) -> U32:
  kc(U32, String.eq(tg(ty), "All"), u =>
    jd_raise_domain(book, t, left, wnf(book, kid(ty, 0))), u => jd_raise_head(book, t, left))

@unsafe
def jd_raise_domain(+book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  kc(U32, String.eq(tg(domain), "ADT"), u =>
    jd_raise_match(book, t, left, j_layout_ctor(book, domain, nm(t))), u => jd_raise_head(book, t, left))

@unsafe
def jd_raise_match(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ctor: KDef) -> U32:
  U32.min(jd_raise(book, kid(t, 0), jd_raise_arm(left, da(ctor))),
    jd_raise(book, kid(t, 1), left))

@unsafe
def jd_raise_head(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  kc(U32, String.eq(tg(t), "Lam"), u =>
    kc(U32, U32.is_gt(left, 0) && U32.is_lt(left, 2147483648), v => jd_raise(book, kid(t, 0), U32.sub(left, 1)),
      v => U32.inc(jd_raise(book, kid(t, 0), 0))), u =>
  kc(U32, String.eq(tg(t), "Mat"), u =>
    jd_raise_match(book, t, left, j_find_ctor(book, nm(t))), u =>
  kc(U32, String.eq(tg(t), "Efq"), u => 99, u => 0)))

@unsafe
def jd_raise_arm(+left: U32, +fields: U32) -> U32:
  # Signed residual in two's-complement U32: Mat may consume past zero before
  # later arms add fields. Clamping here would lose nested-matcher information.
  U32.add(U32.sub(left, 1), fields)

@unsafe
def jd_live_arity(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  kc(U32, U32.is_eq(left, 0), u => 0, u => jd_live_arity_head(book, wnf(book, ty), left))

@unsafe
def jd_live_arity_head(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  kc(U32, String.eq(tg(ty), "All"), u =>
    U32.add(kc(U32, U32.is_eq(qt(ty), 0), u => 0, u => 1),
      jd_live_arity(book, kid(ty, 1), U32.sub(left, 1))), u => 0)

