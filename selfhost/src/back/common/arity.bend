
# Module: src/back/common/arity.bend:8
@unsafe
def jd_arity(+book: List<&2,KDef>, +d: KDef) -> U32:
  kc(U32, p98_tag_eq(j_strip(dv(d)), "Foreign"), u => jd_domains(book, dt(d)), u =>
    U32.add(da(d), U32.min(jd_raise(book, dv(d), da(d)), U32.sub(jd_domains(book, dt(d)), da(d)))))

# Pinned fun_of/def_raise: open common lambda prefixes beyond declared formals,
# including prefixes shared by every matcher arm, capped by the type telescope.

# Module: src/back/common/arity.bend:15
@unsafe
def jd_domains(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  jd_domains_head(book, wnf(book, ty))

# Module: src/back/common/arity.bend:19
@unsafe
def jd_domains_head(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  kc(U32, p98_tag_eq(ty, "All"), u => U32.inc(jd_domains(book, kid(ty, 1))), u => 0)

# Module: src/back/common/arity.bend:23
@unsafe
def jd_raise(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  kc(U32, p98_tag_eq(t, "Ann"), u =>
    kc(U32, p98_tag_eq(j_strip(t), "Mat"), v =>
      jd_raise_typed(book, j_strip(t), left, wnf(book, kid(t, 1))),
      v => jd_raise_head(book, j_strip(t), left)),
    u => jd_raise_head(book, j_strip(t), left))

# Checked annotation supplies the matcher owner. Constructor names are unique
# in checked books; unknown/unannotated inputs retain the original global search.

# Module: src/back/common/arity.bend:33
@unsafe
def jd_raise_typed(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ty: KTerm) -> U32:
  kc(U32, p98_tag_eq(ty, "All"), u =>
    jd_raise_domain(book, t, left, wnf(book, kid(ty, 0))), u => jd_raise_head(book, t, left))

# Module: src/back/common/arity.bend:38
@unsafe
def jd_raise_domain(+book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  kc(U32, p98_tag_eq(domain, "ADT"), u =>
    jd_raise_match(book, t, left, j_layout_ctor(book, domain, nm(t))), u => jd_raise_head(book, t, left))

# Module: src/back/common/arity.bend:43
@unsafe
def jd_raise_match(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ctor: KDef) -> U32:
  U32.min(jd_raise(book, kid(t, 0), jd_raise_arm(left, da(ctor))),
    jd_raise(book, kid(t, 1), left))

# Module: src/back/common/arity.bend:48
@unsafe
def jd_raise_head(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  kc(U32, p98_tag_eq(t, "Lam"), u =>
    kc(U32, U32.is_gt(left, 0) && U32.is_lt(left, 2147483648), v => jd_raise(book, kid(t, 0), U32.sub(left, 1)),
      v => U32.inc(jd_raise(book, kid(t, 0), 0))), u =>
  kc(U32, p98_tag_eq(t, "Mat"), u =>
    jd_raise_match(book, t, left, j_find_ctor(book, nm(t))), u =>
  kc(U32, p98_tag_eq(t, "Efq"), u => 99, u => 0)))

# Module: src/back/common/arity.bend:57
@unsafe
def jd_raise_arm(+left: U32, +fields: U32) -> U32:
  # Signed residual in two's-complement U32: Mat may consume past zero before
  # later arms add fields. Clamping here would lose nested-matcher information.
  U32.add(U32.sub(left, 1), fields)

# Module: src/back/common/arity.bend:63
@unsafe
def jd_live_arity(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  kc(U32, U32.is_eq(left, 0), u => 0, u => jd_live_arity_head(book, wnf(book, ty), left))

# Module: src/back/common/arity.bend:67
@unsafe
def jd_live_arity_head(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  kc(U32, p98_tag_eq(ty, "All"), u =>
    U32.add(kc(U32, U32.is_eq(qt(ty), 0), u => 0, u => 1),
      jd_live_arity(book, kid(ty, 1), U32.sub(left, 1))), u => 0)
