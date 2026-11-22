#!/usr/bin/env python3
"""Wave 5B Track W5B-C2: Frontend / IR / Lowering & Closure Killer.

Composable, 100% bit-exact compile-time optimizations on top of wave5a_unified/compiler.bend.
Strictly scoped to frontend, core term/lookup, text/intrinsic, scalar-array, and IR lowering
(p86..p134, p205, nc_*, nd_*, ns_*, nt_*, ni_*, j_*, terms_at, lookup).
Zero overlap with W5B-C1 (x181..x202 / w4_* / w5_*) or W5B-C3 (apply_parcg / apply_strhash).

Rules enforced:
- Strictly 1-scrutinee parameter matches (never multi-scrutinee on large ADTs).
- Zero `nt_choose` / `kc` closure allocations on all patched hot paths.
- 100% bit-exact .o output.
"""

import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave5a_unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave5b_c2/compiler.bend")


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    if n != 1:
        raise RuntimeError(f"Patch {label!r}: expected 1 match, found {n}")
    return text.replace(old, new, 1)


def apply_patches(src: str) -> str:
    if "# AGY-W5B-C2-IR" in src:
        return src

    # =========================================================================
    # 1. Core Term & Book Lookup Closure Killer: terms_at, lookup
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/core/term.bend:124
@unsafe
def terms_at(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> KTerm:
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      kc(KTerm, U32.is_eq(n, 0), u => h, u => terms_at(t, U32.sub(n, 1)))""",
        """# AGY-W5B-C2-IR
# Module: src/core/term.bend:124
law terms_at:
  for +ts: List<&2, KTerm>
  for +n: U32
  KTerm

@unsafe
def w5c2_terms_at_if(z: Bool, +h: KTerm, +t: List<&2, KTerm>, +n: U32) -> KTerm:
  match z:
    case True{}: h
    case False{}: terms_at(t, U32.sub(n, 1))

@unsafe
def terms_at(ts, n):
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      w5c2_terms_at_if(U32.is_eq(n, 0), h, t, n)""",
        "fast_terms_at",
    )

    src = replace_exact(
        src,
        """@unsafe
def lookup(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d,+rest}:
      kc(KDef, p137q_is_cache(d),
        u => index_lookup(d, name),
        u => kc(KDef, p137q_name_eq(name, d),
          v => d, v => lookup(rest, name)))""",
        """law lookup:
  for +book: List<&2,KDef>
  for +name: String
  KDef

@unsafe
def w5c2_lookup_eq(hit: Bool, +d: KDef, +rest: List<&2,KDef>, +name: String) -> KDef:
  match hit:
    case True{}: d
    case False{}: lookup(rest, name)

@unsafe
def w5c2_lookup_cache(is_c: Bool, +d: KDef, +dname: String, +rest: List<&2,KDef>, +name: String) -> KDef:
  match is_c:
    case True{}: index_lookup(d, name)
    case False{}: w5c2_lookup_eq(String.eq(dname, name), d, rest, name)

@unsafe
def w5c2_lookup_head(+d: KDef, +rest: List<&2,KDef>, +name: String) -> KDef:
  match d:
    case KDef{dname, kind, _, _, _, _, _, _, _}:
      w5c2_lookup_cache(String.eq(kind, "BookCache"), d, dname, rest, name)
    case KIndexLeaf{_, _}:
      w5c2_lookup_eq(String.eq("", name), d, rest, name)
    case KIndexNode{_, _, _, _}:
      w5c2_lookup_eq(String.eq("", name), d, rest, name)

@unsafe
def lookup(book, name):
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}: w5c2_lookup_head(d, rest, name)""",
        "fast_lookup",
    )

    # =========================================================================
    # 2. Common Term Queries Closure Killer: j_strip, j_env, j_app_type, j_call_spine
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/back/common/literals.bend:11
@unsafe
def j_strip(t):
  kc(KTerm, p98_tag_eq(t, "Ann"), u => j_strip(kid(t, 0)), u => t)""",
        """# Module: src/back/common/literals.bend:11
@unsafe
def w5c2_j_strip_if(is_ann: Bool, +t: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match is_ann:
    case False{}: t
    case True{}:
      match kids:
        case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
        case Con{h, _}: j_strip(h)

@unsafe
def j_strip(t):
  match t:
    case KTerm{tag, _, _, _, kids, _, _, _}:
      w5c2_j_strip_if(String.eq(tag, "Ann"), t, kids)
    case _: t""",
        "fast_j_strip",
    )

    src = replace_exact(
        src,
        """# Module: src/back/common/queries.bend:7
@unsafe
def j_env(
  +env: List<&2, KTerm>,
  +id: U32,
) -> KTerm:
  match env:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      kc(KTerm, U32.is_eq(ix(h), id), u => kid(h, 0), u => j_env(rest, id))""",
        """# Module: src/back/common/queries.bend:7
law j_env:
  for +env: List<&2, KTerm>
  for +id: U32
  KTerm

@unsafe
def w5c2_j_env_if(hit: Bool, +h: KTerm, +rest: List<&2, KTerm>, +id: U32) -> KTerm:
  match hit:
    case True{}: kid(h, 0)
    case False{}: j_env(rest, id)

@unsafe
def j_env(env, id):
  match env:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, rest}:
      w5c2_j_env_if(U32.is_eq(ix(h), id), h, rest, id)""",
        "fast_j_env",
    )

    src = replace_exact(
        src,
        """# Module: src/back/common/queries.bend:44
@unsafe
def j_app_type(ty, arg):
  kc(KTerm, p98_tag_eq(ty, "All"), u => subst(kid(ty, 1), ix(ty), arg), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/common/queries.bend:53
@unsafe
def j_call_spine(t, args):
  kc(KTerm, p98_tag_eq(t, "Ann"), u => j_call_spine(kid(t, 0), args), u => kc(KTerm, p98_tag_eq(t, "App"), u => j_call_spine(kid(t, 0), Con{kid(t, 1), args}), u => kc(KTerm, p98_tag_eq(t, "Ref"), u => kt("Call", nm(t), 0, 0, args), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})))""",
        """# Module: src/back/common/queries.bend:44
@unsafe
def w5c2_j_app_type_if(ok: Bool, +ty: KTerm, +arg: KTerm) -> KTerm:
  match ok:
    case True{}: subst(kid(ty, 1), ix(ty), arg)
    case False{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def j_app_type(ty, arg):
  w5c2_j_app_type_if(p98_tag_eq(ty, "All"), ty, arg)

# Module: src/back/common/queries.bend:53
@unsafe
def w5c2_j_spine_ref(is_ref: Bool, +name: String, +args: List<&2, KTerm>) -> KTerm:
  match is_ref:
    case True{}: kt("Call", name, 0, 0, args)
    case False{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w5c2_j_spine_app(is_app: Bool, +tag: String, +name: String, +kids: List<&2, KTerm>, +args: List<&2, KTerm>) -> KTerm:
  match is_app:
    case False{}: w5c2_j_spine_ref(String.eq(tag, "Ref"), name, args)
    case True{}:
      match kids:
        case Con{f, Con{x, _}}: j_call_spine(f, Con{x, args})
        case Con{f, Nil{}}: j_call_spine(f, Con{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, args})
        case Nil{}: j_call_spine({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, args})

@unsafe
def w5c2_j_spine_ann(is_ann: Bool, +tag: String, +name: String, +kids: List<&2, KTerm>, +args: List<&2, KTerm>) -> KTerm:
  match is_ann:
    case False{}: w5c2_j_spine_app(String.eq(tag, "App"), tag, name, kids, args)
    case True{}:
      match kids:
        case Con{h, _}: j_call_spine(h, args)
        case Nil{}: j_call_spine({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, args)

@unsafe
def j_call_spine(t, args):
  match t:
    case KTerm{tag, name, _, _, kids, _, _, _}:
      w5c2_j_spine_ann(String.eq(tag, "Ann"), tag, name, kids, args)
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}""",
        "fast_j_call_spine",
    )

    # =========================================================================
    # 3. Text Helpers Killer: nt_clean (fast-path + zero-closure), nt_replace
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/back/native/text.bend:50
@unsafe
def nt_clean(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}:
      nt_choose(String, Char.is_alpha(h) || Char.is_digit(h) || Char.is_eq(h, '_'), u => SCon{h, ""}, u => "_") ++ nt_clean(t)""",
        """# Module: src/back/native/text.bend:50
@unsafe
def w5c2_clean_char_ok(+c: U32) -> Bool:
  (U32.is_ge(c, 97) && U32.is_le(c, 122)) ||
  (U32.is_ge(c, 65) && U32.is_le(c, 90)) ||
  (U32.is_ge(c, 48) && U32.is_le(c, 57)) ||
  U32.is_eq(c, 95)

@unsafe
def w5c2_is_clean(s: String) -> Bool:
  match s:
    case SNil{}: True{}
    case SCon{h, t}: w5c2_clean_char_ok(Char.to_u32(h)) && w5c2_is_clean(t)

@unsafe
def w5c2_clean_pick(ok: Bool, +h: Char) -> Char:
  match ok:
    case True{}: h
    case False{}: '_'

@unsafe
def w5c2_clean_slow(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}: SCon{w5c2_clean_pick(w5c2_clean_char_ok(Char.to_u32(h)), h), w5c2_clean_slow(t)}

@unsafe
def w5c2_clean_if(ok: Bool, +s: String) -> String:
  match ok:
    case True{}: s
    case False{}: w5c2_clean_slow(s)

@unsafe
def nt_clean(+s: String) -> String:
  w5c2_clean_if(w5c2_is_clean(s), s)""",
        "fast_nt_clean",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/text.bend:82
@unsafe
def nt_replace_step(
  +s: String,
  +key: String,
  +value: String,
  +acc: String,
) -> String:
  match s:
    case SNil{}: acc
    case SCon{h, t}: nt_replace_go(t, key, value, acc ++ SCon{h, ""})

# Module: src/back/native/text.bend:93
@unsafe
def nt_replace_go(s, key, value, acc):
  nt_choose(String, String.starts_with(s, key), u => acc ++ value ++ String.drop(s, String.length(key)), u => nt_replace_step(s, key, value, acc))

# Module: src/back/native/text.bend:97
@unsafe
def nt_replace(s: String, key: String, value: String) -> String:
  nt_replace_go(s, key, value, "")""",
        """# Module: src/back/native/text.bend:82
law w5c2_rep_scan:
  for +s: String
  for +key: String
  for +k0: U32
  for +klen: Nat
  for +value: String
  String

@unsafe
def w5c2_rep_hit(hit: Bool, +s: String, +h: Char, +t: String, +key: String, +k0: U32, +klen: Nat, +value: String) -> String:
  match hit:
    case True{}: value ++ String.drop(s, klen)
    case False{}: SCon{h, w5c2_rep_scan(t, key, k0, klen, value)}

@unsafe
def w5c2_rep_scan(s, key, k0, klen, value):
  match s:
    case SNil{}: ""
    case SCon{+h, +t}:
      w5c2_rep_hit(U32.is_eq(Char.to_u32(h), k0) && String.starts_with(s, key), s, h, t, key, k0, klen, value)

@unsafe
def nt_replace_step(+s: String, +key: String, +value: String, +acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{h, t}: acc ++ SCon{h, nt_replace(t, key, value)}

@unsafe
def nt_replace_go(s, key, value, acc):
  acc ++ nt_replace(s, key, value)

# Module: src/back/native/text.bend:97
@unsafe
def nt_replace(+s: String, +key: String, +value: String) -> String:
  match key:
    case SNil{}: value ++ s
    case SCon{kh, _}: w5c2_rep_scan(s, key, Char.to_u32(kh), String.length(key), value)""",
        "fast_nt_replace",
    )

    # =========================================================================
    # 4. Native Intrinsic & Primitive Dispatch Killer:
    #    ni_template_prior, ni_template, nc_primitive_name, nc_native_def,
    #    nc_native_marked, nc_native_primitive, nc_primitive_arity,
    #    nc_atomic, nc_array_known, nc_unann, nc_occurs, nc_uses_term, nc_live_uses
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/back/native/intrinsic.bend:4
@unsafe
def ni_template_prior(+k: String) -> String:
  nt_choose(String, String.is_empty(k), u => "", u =>
    nt_choose(String, p88_string_eq(k, "u32_add"), u => "U32_BIN($0, +, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_sub"), u => "U32_BIN($0, -, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_and"), u => "U32_BIN($0, &, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_or"), u => "U32_BIN($0, |, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_xor"), u => "U32_BIN($0, ^, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_mul"), u => "U32_BIN($0, *, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_eq"), u => "U32_BIN($0, ==, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_ne"), u => "U32_BIN($0, !=, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_lt"), u => "U32_BIN($0, <, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_le"), u => "U32_BIN($0, <=, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_gt"), u => "U32_BIN($0, >, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_ge"), u => "U32_BIN($0, >=, $1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_inc"), u => "U32_BIN($0, +, 1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_shl"), u => "U32_BIN($0, <<, 1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_shr"), u => "U32_BIN($0, >>, 1)", u =>
    nt_choose(String, p88_string_eq(k, "u32_shln"), u => "($1 >= 32 ? 0 : U32_BIN($0, <<, $1))", u =>
    nt_choose(String, p88_string_eq(k, "u32_shrn"), u => "($1 >= 32 ? 0 : U32_BIN($0, >>, $1))", u =>
    nt_choose(String, p88_string_eq(k, "u32_div"), u => "((u32)($1) == 0 ? 0 : (u64)U32_QUO((u32)($0), (u32)($1)))", u =>
    nt_choose(String, p88_string_eq(k, "u32_mod"), u => "((u32)($1) == 0 ? $0 : U32_BIN($0, -, U32_QUO((u32)($0), (u32)($1)) * $1))", u =>
    nt_choose(String, p88_string_eq(k, "u32_not"), u => "((u64)~(u32)($0))", u =>
    nt_choose(String, p88_string_eq(k, "u32_is_zero"), u => "U32_BIN($0, ==, 0)", u =>
    nt_choose(String, p88_string_eq(k, "u32_cmp"), u => "(U32_BIN($0, >, $1) + U32_BIN($0, >=, $1))", u =>
    nt_choose(String, p88_string_eq(k, "u32_to_f32"), u => "f32_rewrap((f32)(u32)($0))", u =>
    nt_choose(String, p88_string_eq(k, "u32_to_nat"), u => "((u64)$0)", u =>
    nt_choose(String, p88_string_eq(k, "u32_from_nat"), u => "((u64)(u32)($0))", u =>
    nt_choose(String, p88_string_eq(k, "f32_add"), u => "f32_rewrap(f32_unbox($0) + f32_unbox($1))", u =>
    nt_choose(String, p88_string_eq(k, "f32_sub"), u => "f32_rewrap(f32_unbox($0) - f32_unbox($1))", u =>
    nt_choose(String, p88_string_eq(k, "f32_mul"), u => "f32_rewrap(f32_unbox($0) * f32_unbox($1))", u =>
    nt_choose(String, p88_string_eq(k, "f32_div"), u => "f32_rewrap(f32_unbox($0) / f32_unbox($1))", u =>
    nt_choose(String, p88_string_eq(k, "f32_is_eq"), u => "((u64)(f32_unbox($0) == f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_is_ne"), u => "((u64)(f32_unbox($0) != f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_is_lt"), u => "((u64)(f32_unbox($0) < f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_is_le"), u => "((u64)(f32_unbox($0) <= f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_is_gt"), u => "((u64)(f32_unbox($0) > f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_is_ge"), u => "((u64)(f32_unbox($0) >= f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_sqrt"), u => "f32_rewrap((f32)sqrt(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_exp"), u => "f32_rewrap((f32)exp(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_log"), u => "f32_rewrap((f32)log(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_log2"), u => "f32_rewrap((f32)log2(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_log10"), u => "f32_rewrap((f32)log10(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_sin"), u => "f32_rewrap((f32)sin(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_cos"), u => "f32_rewrap((f32)cos(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_tan"), u => "f32_rewrap((f32)tan(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_asin"), u => "f32_rewrap((f32)asin(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_acos"), u => "f32_rewrap((f32)acos(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_atan"), u => "f32_rewrap((f32)atan(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_sinh"), u => "f32_rewrap((f32)sinh(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_cosh"), u => "f32_rewrap((f32)cosh(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_tanh"), u => "f32_rewrap((f32)tanh(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_floor"), u => "f32_rewrap((f32)floor(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_ceil"), u => "f32_rewrap((f32)ceil(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_trunc"), u => "f32_rewrap((f32)trunc(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_abs"), u => "f32_rewrap((f32)fabs(f32_unbox($0)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_pow"), u => "f32_rewrap((f32)pow(f32_unbox($0), f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_atan2"), u => "f32_rewrap((f32)atan2(f32_unbox($0), f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_mod"), u => "f32_rewrap((f32)fmod(f32_unbox($0), f32_unbox($1)))", u =>
    nt_choose(String, p88_string_eq(k, "f32_neg"), u => "f32_rewrap(-f32_unbox($0))", u =>
    nt_choose(String, p88_string_eq(k, "f32_to_u32"), u => "f32_to_u32($0)", u =>
    nt_choose(String, p88_string_eq(k, "f32_bits"), u => "$0", u =>
    nt_choose(String, p88_string_eq(k, "f32_show"), u => "f32_show(e, $0)", u =>
    nt_choose(String, p88_string_eq(k, "f32_read"), u => "f32_read(e, $0)", u =>
    nt_choose(String, p88_string_eq(k, "nat_add"), u => "nat_chk(e, $0 + $1)", u =>
    nt_choose(String, p88_string_eq(k, "nat_sub"), u => "($0 < $1 ? 0 : $0 - $1)", u =>
    nt_choose(String, p88_string_eq(k, "nat_mul"), u => "nat_mul(e, $0, $1)", u =>
    nt_choose(String, p88_string_eq(k, "nat_double"), u => "nat_chk(e, $0 + $0)", u =>
    nt_choose(String, p88_string_eq(k, "nat_cmp"), u => "(($0 > $1) + ($0 >= $1))", u =>
    nt_choose(String, p88_string_eq(k, "nat_is_lt"), u => "($0 < $1)", u =>
    nt_choose(String, p88_string_eq(k, "bool_or"), u => "(native_bool($0) | native_bool($1))", u =>
    nt_choose(String, p88_string_eq(k, "bool_xor"), u => "(native_bool($0) ^ native_bool($1))", u =>
      ""))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

# F32.from_nat consumes the complete 48-bit Nat; narrowing through U32 loses
# its high word. Keep this primitive distinct from U32.to_f32.
@unsafe
def ni_template(+k: String) -> String:
  nt_choose(String, p88_string_eq(k, "f32_from_nat"),
    u => "f32_rewrap((f32)($0))", u => ni_template_prior(k))""",
        """# Module: src/back/native/intrinsic.bend:4
@unsafe
def w5c2_str_pick(ok: Bool, +yes: String, +no: String) -> String:
  match ok:
    case True{}: yes
    case False{}: no

@unsafe
def w5c2_ni_u32_3(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "u32_not"), "((u64)~(u32)($0))",
  w5c2_str_pick(String.eq(k, "u32_is_zero"), "U32_BIN($0, ==, 0)",
  w5c2_str_pick(String.eq(k, "u32_cmp"), "(U32_BIN($0, >, $1) + U32_BIN($0, >=, $1))",
  w5c2_str_pick(String.eq(k, "u32_to_f32"), "f32_rewrap((f32)(u32)($0))",
  w5c2_str_pick(String.eq(k, "u32_to_nat"), "((u64)$0)",
  w5c2_str_pick(String.eq(k, "u32_from_nat"), "((u64)(u32)($0))", ""))))))

@unsafe
def w5c2_ni_u32_2(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "u32_inc"), "U32_BIN($0, +, 1)",
  w5c2_str_pick(String.eq(k, "u32_shl"), "U32_BIN($0, <<, 1)",
  w5c2_str_pick(String.eq(k, "u32_shr"), "U32_BIN($0, >>, 1)",
  w5c2_str_pick(String.eq(k, "u32_shln"), "($1 >= 32 ? 0 : U32_BIN($0, <<, $1))",
  w5c2_str_pick(String.eq(k, "u32_shrn"), "($1 >= 32 ? 0 : U32_BIN($0, >>, $1))",
  w5c2_str_pick(String.eq(k, "u32_div"), "((u32)($1) == 0 ? 0 : (u64)U32_QUO((u32)($0), (u32)($1)))",
  w5c2_str_pick(String.eq(k, "u32_mod"), "((u32)($1) == 0 ? $0 : U32_BIN($0, -, U32_QUO((u32)($0), (u32)($1)) * $1))",
    w5c2_ni_u32_3(k))))))))

@unsafe
def w5c2_ni_u32(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "u32_add"), "U32_BIN($0, +, $1)",
  w5c2_str_pick(String.eq(k, "u32_sub"), "U32_BIN($0, -, $1)",
  w5c2_str_pick(String.eq(k, "u32_and"), "U32_BIN($0, &, $1)",
  w5c2_str_pick(String.eq(k, "u32_or"), "U32_BIN($0, |, $1)",
  w5c2_str_pick(String.eq(k, "u32_xor"), "U32_BIN($0, ^, $1)",
  w5c2_str_pick(String.eq(k, "u32_mul"), "U32_BIN($0, *, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_eq"), "U32_BIN($0, ==, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_ne"), "U32_BIN($0, !=, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_lt"), "U32_BIN($0, <, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_le"), "U32_BIN($0, <=, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_gt"), "U32_BIN($0, >, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_ge"), "U32_BIN($0, >=, $1)",
    w5c2_ni_u32_2(k)))))))))))))

@unsafe
def w5c2_ni_f32_3(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "f32_floor"), "f32_rewrap((f32)floor(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_ceil"), "f32_rewrap((f32)ceil(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_trunc"), "f32_rewrap((f32)trunc(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_abs"), "f32_rewrap((f32)fabs(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_pow"), "f32_rewrap((f32)pow(f32_unbox($0), f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_atan2"), "f32_rewrap((f32)atan2(f32_unbox($0), f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_mod"), "f32_rewrap((f32)fmod(f32_unbox($0), f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_neg"), "f32_rewrap(-f32_unbox($0))",
  w5c2_str_pick(String.eq(k, "f32_to_u32"), "f32_to_u32($0)",
  w5c2_str_pick(String.eq(k, "f32_bits"), "$0",
  w5c2_str_pick(String.eq(k, "f32_show"), "f32_show(e, $0)",
  w5c2_str_pick(String.eq(k, "f32_read"), "f32_read(e, $0)", ""))))))))))))

@unsafe
def w5c2_ni_f32_2(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "f32_sqrt"), "f32_rewrap((f32)sqrt(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_exp"), "f32_rewrap((f32)exp(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_log"), "f32_rewrap((f32)log(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_log2"), "f32_rewrap((f32)log2(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_log10"), "f32_rewrap((f32)log10(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_sin"), "f32_rewrap((f32)sin(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_cos"), "f32_rewrap((f32)cos(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_tan"), "f32_rewrap((f32)tan(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_asin"), "f32_rewrap((f32)asin(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_acos"), "f32_rewrap((f32)acos(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_atan"), "f32_rewrap((f32)atan(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_sinh"), "f32_rewrap((f32)sinh(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_cosh"), "f32_rewrap((f32)cosh(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_tanh"), "f32_rewrap((f32)tanh(f32_unbox($0)))",
    w5c2_ni_f32_3(k)))))))))))))))

@unsafe
def w5c2_ni_f32(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "f32_add"), "f32_rewrap(f32_unbox($0) + f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_sub"), "f32_rewrap(f32_unbox($0) - f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_mul"), "f32_rewrap(f32_unbox($0) * f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_div"), "f32_rewrap(f32_unbox($0) / f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_is_eq"), "((u64)(f32_unbox($0) == f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_ne"), "((u64)(f32_unbox($0) != f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_lt"), "((u64)(f32_unbox($0) < f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_le"), "((u64)(f32_unbox($0) <= f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_gt"), "((u64)(f32_unbox($0) > f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_ge"), "((u64)(f32_unbox($0) >= f32_unbox($1)))",
    w5c2_ni_f32_2(k)))))))))))

@unsafe
def w5c2_ni_nat(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "nat_add"), "nat_chk(e, $0 + $1)",
  w5c2_str_pick(String.eq(k, "nat_sub"), "($0 < $1 ? 0 : $0 - $1)",
  w5c2_str_pick(String.eq(k, "nat_mul"), "nat_mul(e, $0, $1)",
  w5c2_str_pick(String.eq(k, "nat_double"), "nat_chk(e, $0 + $0)",
  w5c2_str_pick(String.eq(k, "nat_cmp"), "(($0 > $1) + ($0 >= $1))",
  w5c2_str_pick(String.eq(k, "nat_is_lt"), "($0 < $1)", ""))))))

@unsafe
def w5c2_ni_bool(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "bool_or"), "(native_bool($0) | native_bool($1))",
  w5c2_str_pick(String.eq(k, "bool_xor"), "(native_bool($0) ^ native_bool($1))", ""))

@unsafe
def w5c2_ni_b(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_bool(k)
    case False{}: ""

@unsafe
def w5c2_ni_n(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_nat(k)
    case False{}: w5c2_ni_b(U32.is_eq(c, 98), k)

@unsafe
def w5c2_ni_f(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_f32(k)
    case False{}: w5c2_ni_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_ni_u(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_u32(k)
    case False{}: w5c2_ni_f(U32.is_eq(c, 102), c, k)

@unsafe
def ni_template_prior(+k: String) -> String:
  match k:
    case SNil{}: ""
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_ni_u(U32.is_eq(c, 117), c, k)

# F32.from_nat consumes the complete 48-bit Nat; narrowing through U32 loses
# its high word. Keep this primitive distinct from U32.to_f32.
@unsafe
def w5c2_ni_from_nat(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: "f32_rewrap((f32)($0))"
    case False{}: ni_template_prior(k)

@unsafe
def ni_template(+k: String) -> String:
  w5c2_ni_from_nat(String.eq(k, "f32_from_nat"), k)""",
        "fast_ni_template",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/bridge.bend:120
@unsafe
def nc_occurs(t, id):
  nt_choose(Bool, p98_tag_eq(t, "Var"), u => U32.is_eq(ix(t), id), u => nc_occurs_list(ks(t), id))

# Var remains a leaf even in malformed raw terms with Var children.

# Module: src/back/native/bridge.bend:125
@unsafe
def nc_uses_term(+t: KTerm, +uses: NU_Set) -> NU_Set:
  nt_choose(NU_Set, p98_tag_eq(t, "Var"),
    u => nu_add(uses, ix(t)), u => nc_uses_list(ks(t), uses))""",
        """# Module: src/back/native/bridge.bend:120
@unsafe
def w5c2_nc_occurs_if(is_var: Bool, +t: KTerm, +id: U32) -> Bool:
  match is_var:
    case True{}: U32.is_eq(ix(t), id)
    case False{}: nc_occurs_list(ks(t), id)

@unsafe
def nc_occurs(t, id):
  w5c2_nc_occurs_if(p98_tag_eq(t, "Var"), t, id)

# Var remains a leaf even in malformed raw terms with Var children.

# Module: src/back/native/bridge.bend:125
@unsafe
def w5c2_nc_uses_if(is_var: Bool, +t: KTerm, +uses: NU_Set) -> NU_Set:
  match is_var:
    case True{}: nu_add(uses, ix(t))
    case False{}: nc_uses_list(ks(t), uses)

@unsafe
def nc_uses_term(+t: KTerm, +uses: NU_Set) -> NU_Set:
  w5c2_nc_uses_if(p98_tag_eq(t, "Var"), t, uses)""",
        "fast_nc_uses_occurs",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/bridge.bend:144
@unsafe
def nc_live_uses(env: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, NC_Binding>, nc_uses_has(uses, id), u => Con{NC_Binding{id, word, kind}, nc_live_uses(rest, uses)}, u => nc_live_uses(rest, uses))""",
        """# Module: src/back/native/bridge.bend:144
law nc_live_uses:
  for env: List<&2, NC_Binding>
  for +uses: NU_Set
  List<&2, NC_Binding>

@unsafe
def w5c2_nc_live_if(has: Bool, +id: U32, +word: String, +kind: N_WordKind, rest: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, NC_Binding>:
  match has:
    case True{}: Con{NC_Binding{id, word, kind}, nc_live_uses(rest, uses)}
    case False{}: nc_live_uses(rest, uses)

@unsafe
def nc_live_uses(env, uses):
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, rest}:
      w5c2_nc_live_if(nu_has(uses, id), id, word, kind, rest, uses)""",
        "fast_nc_live_uses",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/bridge.bend:502
@unsafe
def nc_primitive_name(+k: String) -> String:
  nt_choose(String, p88_string_eq(k, "Array.get_unchecked"),
    u => "array_get", u => String.to_lower(nt_clean(k)))

# Module: src/back/native/bridge.bend:510
@unsafe
def nc_native_def(+d: KDef) -> Bool:
  nt_choose(Bool, db(d), u => nc_native_marked(d), u => False{})

# Ordinary definitions never require intrinsic-name construction or templates.
# Explicit control flow matters: Boolean arguments are otherwise evaluated.

# Module: src/back/native/bridge.bend:516
@unsafe
def nc_native_marked(+d: KDef) -> Bool:
  nt_choose(Bool, p98_tag_eq(nc_unann(dv(d)), "Foreign"), u => False{},
    u => nc_native_primitive(nc_primitive_name(dn(d))))

# Module: src/back/native/bridge.bend:521
@unsafe
def nc_native_primitive(+prim: String) -> Bool:
  Bool.not(p88_string_eq(ni_template(prim), "")) || nc_array_known(prim) || p88_string_eq(prim, "nat_divmod")

# Module: src/back/native/bridge.bend:525
@unsafe
def nc_ref_name(+book: List<&2, KDef>, +name: String) -> String:
  nt_choose(String, nc_native_def(lookup(book, name)), u => "$native." ++ name, u => name)

# Module: src/back/native/bridge.bend:529
@unsafe
def nc_primitive_arity(+k: String) -> U32:
  +fmt = ni_template(k)
  nt_choose(U32, p88_string_eq(k, "array_atomic_cas"), u => 4, u =>
  nt_choose(U32, U32.is_ne(nc_atomic(k), 0) || p88_string_eq(k, "array_set") || p88_string_eq(k, "array_swap"), u => 3, u =>
  nt_choose(U32, p88_string_eq(k, "array_new") || p88_string_eq(k, "array_get") || p88_string_eq(k, "nat_divmod"), u => 2, u =>
  nt_choose(U32, p88_string_eq(fmt, nt_replace(fmt, "$1", "?")), u => 1, u => 2))))""",
        """# Module: src/back/native/bridge.bend:502
@unsafe
def w5c2_cl_ch_up(is_up: Bool, +c: U32, +h: Char) -> Char:
  match is_up:
    case True{}: Char.from_u32(U32.add(c, 32))
    case False{}: w5c2_clean_pick((U32.is_ge(c, 97) && U32.is_le(c, 122)) || (U32.is_ge(c, 48) && U32.is_le(c, 57)) || U32.is_eq(c, 95), h)

@unsafe
def w5c2_clean_lower(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}:
      +c = Char.to_u32(h)
      SCon{w5c2_cl_ch_up(U32.is_ge(c, 65) && U32.is_le(c, 90), c, h), w5c2_clean_lower(t)}

@unsafe
def w5c2_pn_u2(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "U32.inc"), "u32_inc",
  w5c2_str_pick(String.eq(k, "U32.shl"), "u32_shl",
  w5c2_str_pick(String.eq(k, "U32.shr"), "u32_shr",
  w5c2_str_pick(String.eq(k, "U32.shln"), "u32_shln",
  w5c2_str_pick(String.eq(k, "U32.shrn"), "u32_shrn",
  w5c2_str_pick(String.eq(k, "U32.div"), "u32_div",
  w5c2_str_pick(String.eq(k, "U32.mod"), "u32_mod",
  w5c2_str_pick(String.eq(k, "U32.not"), "u32_not",
  w5c2_str_pick(String.eq(k, "U32.is_zero"), "u32_is_zero",
  w5c2_str_pick(String.eq(k, "U32.to_nat"), "u32_to_nat",
  w5c2_str_pick(String.eq(k, "U32.from_nat"), "u32_from_nat",
  w5c2_str_pick(String.eq(k, "U32.to_f32"), "u32_to_f32",
  w5c2_str_pick(String.eq(k, "U32.cmp"), "u32_cmp", "")))))))))))))

@unsafe
def w5c2_pn_u1(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "U32.add"), "u32_add",
  w5c2_str_pick(String.eq(k, "U32.sub"), "u32_sub",
  w5c2_str_pick(String.eq(k, "U32.mul"), "u32_mul",
  w5c2_str_pick(String.eq(k, "U32.and"), "u32_and",
  w5c2_str_pick(String.eq(k, "U32.or"), "u32_or",
  w5c2_str_pick(String.eq(k, "U32.xor"), "u32_xor",
  w5c2_str_pick(String.eq(k, "U32.is_eq"), "u32_is_eq",
  w5c2_str_pick(String.eq(k, "U32.is_ne"), "u32_is_ne",
  w5c2_str_pick(String.eq(k, "U32.is_lt"), "u32_is_lt",
  w5c2_str_pick(String.eq(k, "U32.is_le"), "u32_is_le",
  w5c2_str_pick(String.eq(k, "U32.is_gt"), "u32_is_gt",
  w5c2_str_pick(String.eq(k, "U32.is_ge"), "u32_is_ge", ""))))))))))))

@unsafe
def w5c2_pn_f(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "F32.add"), "f32_add",
  w5c2_str_pick(String.eq(k, "F32.sub"), "f32_sub",
  w5c2_str_pick(String.eq(k, "F32.mul"), "f32_mul",
  w5c2_str_pick(String.eq(k, "F32.div"), "f32_div",
  w5c2_str_pick(String.eq(k, "F32.is_lt"), "f32_is_lt",
  w5c2_str_pick(String.eq(k, "F32.is_le"), "f32_is_le",
  w5c2_str_pick(String.eq(k, "F32.is_gt"), "f32_is_gt",
  w5c2_str_pick(String.eq(k, "F32.is_ge"), "f32_is_ge",
  w5c2_str_pick(String.eq(k, "F32.is_eq"), "f32_is_eq",
  w5c2_str_pick(String.eq(k, "F32.sqrt"), "f32_sqrt",
  w5c2_str_pick(String.eq(k, "F32.neg"), "f32_neg",
  w5c2_str_pick(String.eq(k, "F32.from_nat"), "f32_from_nat", ""))))))))))))

@unsafe
def w5c2_pn_a(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "Array.get"), "array_get",
  w5c2_str_pick(String.eq(k, "Array.get_unchecked"), "array_get",
  w5c2_str_pick(String.eq(k, "Array.set"), "array_set",
  w5c2_str_pick(String.eq(k, "Array.new"), "array_new",
  w5c2_str_pick(String.eq(k, "Array.size"), "array_size",
  w5c2_str_pick(String.eq(k, "Array.swap"), "array_swap",
  w5c2_str_pick(String.eq(k, "Array.clone"), "array_clone", "")))))))

@unsafe
def w5c2_pn_nb(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "Nat.add"), "nat_add",
  w5c2_str_pick(String.eq(k, "Nat.sub"), "nat_sub",
  w5c2_str_pick(String.eq(k, "Nat.mul"), "nat_mul",
  w5c2_str_pick(String.eq(k, "Nat.is_lt"), "nat_is_lt",
  w5c2_str_pick(String.eq(k, "Nat.divmod"), "nat_divmod",
  w5c2_str_pick(String.eq(k, "Bool.or"), "bool_or",
  w5c2_str_pick(String.eq(k, "Bool.xor"), "bool_xor", "")))))))

@unsafe
def w5c2_pn_fallback(hit: String, +k: String) -> String:
  match hit:
    case SNil{}: w5c2_clean_lower(k)
    case SCon{a, b}: SCon{a, b}

@unsafe
def w5c2_pn_u_res(hit: String, +k: String) -> String:
  match hit:
    case SNil{}: w5c2_pn_fallback(w5c2_pn_u2(k), k)
    case SCon{a, b}: SCon{a, b}

@unsafe
def w5c2_pn_disp_nb(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_fallback(w5c2_pn_nb(k), k)
    case False{}: w5c2_clean_lower(k)

@unsafe
def w5c2_pn_disp_a(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_fallback(w5c2_pn_a(k), k)
    case False{}: w5c2_pn_disp_nb(U32.is_eq(c, 78) || U32.is_eq(c, 66), k)

@unsafe
def w5c2_pn_disp_f(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_fallback(w5c2_pn_f(k), k)
    case False{}: w5c2_pn_disp_a(U32.is_eq(c, 65), c, k)

@unsafe
def w5c2_pn_disp_u(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_u_res(w5c2_pn_u1(k), k)
    case False{}: w5c2_pn_disp_f(U32.is_eq(c, 70), c, k)

@unsafe
def nc_primitive_name(+k: String) -> String:
  match k:
    case SNil{}: ""
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_pn_disp_u(U32.is_eq(c, 85), c, k)

# Module: src/back/native/bridge.bend:510
@unsafe
def w5c2_nc_native_def_if(is_base: Bool, +d: KDef) -> Bool:
  match is_base:
    case True{}: nc_native_marked(d)
    case False{}: False{}

@unsafe
def nc_native_def(+d: KDef) -> Bool:
  w5c2_nc_native_def_if(db(d), d)

# Module: src/back/native/bridge.bend:516
@unsafe
def w5c2_may_be_prim_first(+name: String) -> Bool:
  match name:
    case SNil{}: False{}
    case SCon{h, _}:
      +c = Char.to_u32(h)
      U32.is_eq(c, 85) || U32.is_eq(c, 70) || U32.is_eq(c, 78) || U32.is_eq(c, 66) || U32.is_eq(c, 65) ||
      U32.is_eq(c, 117) || U32.is_eq(c, 102) || U32.is_eq(c, 110) || U32.is_eq(c, 98) || U32.is_eq(c, 97)

@unsafe
def w5c2_nc_marked_if(ok: Bool, +name: String) -> Bool:
  match ok:
    case True{}: nc_native_primitive(nc_primitive_name(name))
    case False{}: False{}

@unsafe
def nc_native_marked(+d: KDef) -> Bool:
  +name = dn(d)
  w5c2_nc_marked_if(w5c2_may_be_prim_first(name) && Bool.not(p98_tag_eq(nc_unann(dv(d)), "Foreign")), name)

# Module: src/back/native/bridge.bend:521
@unsafe
def w5c2_prim_is_u32(+k: String) -> Bool:
  String.eq(k, "u32_add") || String.eq(k, "u32_sub") || String.eq(k, "u32_and") ||
  String.eq(k, "u32_or") || String.eq(k, "u32_xor") || String.eq(k, "u32_mul") ||
  String.eq(k, "u32_is_eq") || String.eq(k, "u32_is_ne") || String.eq(k, "u32_is_lt") ||
  String.eq(k, "u32_is_le") || String.eq(k, "u32_is_gt") || String.eq(k, "u32_is_ge") ||
  String.eq(k, "u32_inc") || String.eq(k, "u32_shl") || String.eq(k, "u32_shr") ||
  String.eq(k, "u32_shln") || String.eq(k, "u32_shrn") || String.eq(k, "u32_div") ||
  String.eq(k, "u32_mod") || String.eq(k, "u32_not") || String.eq(k, "u32_is_zero") ||
  String.eq(k, "u32_cmp") || String.eq(k, "u32_to_f32") || String.eq(k, "u32_to_nat") ||
  String.eq(k, "u32_from_nat")

@unsafe
def w5c2_prim_is_f32(+k: String) -> Bool:
  String.eq(k, "f32_add") || String.eq(k, "f32_sub") || String.eq(k, "f32_mul") ||
  String.eq(k, "f32_div") || String.eq(k, "f32_is_eq") || String.eq(k, "f32_is_ne") ||
  String.eq(k, "f32_is_lt") || String.eq(k, "f32_is_le") || String.eq(k, "f32_is_gt") ||
  String.eq(k, "f32_is_ge") || String.eq(k, "f32_sqrt") || String.eq(k, "f32_exp") ||
  String.eq(k, "f32_log") || String.eq(k, "f32_log2") || String.eq(k, "f32_log10") ||
  String.eq(k, "f32_sin") || String.eq(k, "f32_cos") || String.eq(k, "f32_tan") ||
  String.eq(k, "f32_asin") || String.eq(k, "f32_acos") || String.eq(k, "f32_atan") ||
  String.eq(k, "f32_sinh") || String.eq(k, "f32_cosh") || String.eq(k, "f32_tanh") ||
  String.eq(k, "f32_floor") || String.eq(k, "f32_ceil") || String.eq(k, "f32_trunc") ||
  String.eq(k, "f32_abs") || String.eq(k, "f32_pow") || String.eq(k, "f32_atan2") ||
  String.eq(k, "f32_mod") || String.eq(k, "f32_neg") || String.eq(k, "f32_to_u32") ||
  String.eq(k, "f32_bits") || String.eq(k, "f32_show") || String.eq(k, "f32_read") ||
  String.eq(k, "f32_from_nat")

@unsafe
def w5c2_prim_is_nat(+k: String) -> Bool:
  String.eq(k, "nat_add") || String.eq(k, "nat_sub") || String.eq(k, "nat_mul") ||
  String.eq(k, "nat_double") || String.eq(k, "nat_cmp") || String.eq(k, "nat_is_lt") ||
  String.eq(k, "nat_divmod")

@unsafe
def w5c2_prim_is_bool(+k: String) -> Bool:
  String.eq(k, "bool_or") || String.eq(k, "bool_xor")

@unsafe
def w5c2_prim_a(ok: Bool, +k: String) -> Bool:
  match ok:
    case True{}: nc_array_known(k)
    case False{}: False{}

@unsafe
def w5c2_prim_b(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_bool(k)
    case False{}: w5c2_prim_a(U32.is_eq(c, 97), k)

@unsafe
def w5c2_prim_n(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_nat(k)
    case False{}: w5c2_prim_b(U32.is_eq(c, 98), c, k)

@unsafe
def w5c2_prim_f(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_f32(k)
    case False{}: w5c2_prim_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_prim_u(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_u32(k)
    case False{}: w5c2_prim_f(U32.is_eq(c, 102), c, k)

@unsafe
def nc_native_primitive(+prim: String) -> Bool:
  match prim:
    case SNil{}: False{}
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_prim_u(U32.is_eq(c, 117), c, prim)

# Module: src/back/native/bridge.bend:525
@unsafe
def w5c2_nc_ref_if(is_nat: Bool, +name: String) -> String:
  match is_nat:
    case True{}: "$native." ++ name
    case False{}: name

@unsafe
def nc_ref_name(+book: List<&2, KDef>, +name: String) -> String:
  w5c2_nc_ref_if(nc_native_def(lookup(book, name)), name)

# Module: src/back/native/bridge.bend:529
@unsafe
def w5c2_arity_2_if(is2: Bool) -> U32:
  match is2:
    case True{}: 2
    case False{}: 1

@unsafe
def w5c2_arity_u32(+k: String) -> U32:
  w5c2_arity_2_if(
    String.eq(k, "u32_add") || String.eq(k, "u32_sub") || String.eq(k, "u32_and") ||
    String.eq(k, "u32_or") || String.eq(k, "u32_xor") || String.eq(k, "u32_mul") ||
    String.eq(k, "u32_is_eq") || String.eq(k, "u32_is_ne") || String.eq(k, "u32_is_lt") ||
    String.eq(k, "u32_is_le") || String.eq(k, "u32_is_gt") || String.eq(k, "u32_is_ge") ||
    String.eq(k, "u32_shln") || String.eq(k, "u32_shrn") || String.eq(k, "u32_div") ||
    String.eq(k, "u32_mod") || String.eq(k, "u32_cmp"))

@unsafe
def w5c2_arity_f32(+k: String) -> U32:
  w5c2_arity_2_if(
    String.eq(k, "f32_add") || String.eq(k, "f32_sub") || String.eq(k, "f32_mul") ||
    String.eq(k, "f32_div") || String.eq(k, "f32_is_eq") || String.eq(k, "f32_is_ne") ||
    String.eq(k, "f32_is_lt") || String.eq(k, "f32_is_le") || String.eq(k, "f32_is_gt") ||
    String.eq(k, "f32_is_ge") || String.eq(k, "f32_pow") || String.eq(k, "f32_atan2") ||
    String.eq(k, "f32_mod"))

@unsafe
def w5c2_arity_nat(+k: String) -> U32:
  w5c2_arity_2_if(
    String.eq(k, "nat_add") || String.eq(k, "nat_sub") || String.eq(k, "nat_mul") ||
    String.eq(k, "nat_cmp") || String.eq(k, "nat_is_lt") || String.eq(k, "nat_divmod"))

@unsafe
def w5c2_arity_arr3(is3: Bool, +k: String) -> U32:
  match is3:
    case True{}: 3
    case False{}: w5c2_arity_2_if(String.eq(k, "array_new") || String.eq(k, "array_get"))

@unsafe
def w5c2_arity_arr4(is4: Bool, +k: String) -> U32:
  match is4:
    case True{}: 4
    case False{}: w5c2_arity_arr3(U32.is_ne(nc_atomic(k), 0) || String.eq(k, "array_set") || String.eq(k, "array_swap"), k)

@unsafe
def w5c2_arity_a(ok: Bool, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_arr4(String.eq(k, "array_atomic_cas"), k)
    case False{}: 1

@unsafe
def w5c2_arity_b(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_2_if(String.eq(k, "bool_or") || String.eq(k, "bool_xor"))
    case False{}: w5c2_arity_a(U32.is_eq(c, 97), k)

@unsafe
def w5c2_arity_n(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_nat(k)
    case False{}: w5c2_arity_b(U32.is_eq(c, 98), c, k)

@unsafe
def w5c2_arity_f(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_f32(k)
    case False{}: w5c2_arity_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_arity_u(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_u32(k)
    case False{}: w5c2_arity_f(U32.is_eq(c, 102), c, k)

@unsafe
def nc_primitive_arity(+k: String) -> U32:
  match k:
    case SNil{}: 1
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_arity_u(U32.is_eq(c, 117), c, k)""",
        "fast_nc_primitive_dispatch",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/array.bend:14
@unsafe
def nc_atomic(k):
  nt_choose(U32, p88_string_eq(k, "array_atomic_add"), u => 1, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_min"), u => 2, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_max"), u => 3, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_and"), u => 4, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_or"), u => 5, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_xor"), u => 6, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_exch"), u => 7, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_cas"), u => 8, u =>
  nt_choose(U32, p88_string_eq(k, "array_atomic_fadd"), u => 9, u => 0)))))))))

# Module: src/back/native/array.bend:26
@unsafe
def nc_array_known(k):
  U32.is_ne(nc_atomic(k), 0) || p88_string_eq(k, "array_new") || p88_string_eq(k, "array_get") || p88_string_eq(k, "array_set") || p88_string_eq(k, "array_swap") || p88_string_eq(k, "array_size") || p88_string_eq(k, "array_clone")""",
        """# Module: src/back/native/array.bend:14
@unsafe
def w5c2_u32_pick(ok: Bool, +yes: U32, +no: U32) -> U32:
  match ok:
    case True{}: yes
    case False{}: no

@unsafe
def w5c2_nc_atomic_go(is_a: Bool, +k: String) -> U32:
  match is_a:
    case False{}: 0
    case True{}:
      w5c2_u32_pick(String.eq(k, "array_atomic_add"), 1,
      w5c2_u32_pick(String.eq(k, "array_atomic_min"), 2,
      w5c2_u32_pick(String.eq(k, "array_atomic_max"), 3,
      w5c2_u32_pick(String.eq(k, "array_atomic_and"), 4,
      w5c2_u32_pick(String.eq(k, "array_atomic_or"), 5,
      w5c2_u32_pick(String.eq(k, "array_atomic_xor"), 6,
      w5c2_u32_pick(String.eq(k, "array_atomic_exch"), 7,
      w5c2_u32_pick(String.eq(k, "array_atomic_cas"), 8,
      w5c2_u32_pick(String.eq(k, "array_atomic_fadd"), 9, 0)))))))))

@unsafe
def nc_atomic(k):
  match k:
    case SNil{}: 0
    case SCon{h, _}: w5c2_nc_atomic_go(U32.is_eq(Char.to_u32(h), 97), k)

# Module: src/back/native/array.bend:26
@unsafe
def w5c2_nc_arr_known_go(is_a: Bool, +k: String) -> Bool:
  match is_a:
    case False{}: False{}
    case True{}:
      String.eq(k, "array_get") || String.eq(k, "array_set") || String.eq(k, "array_new") ||
      String.eq(k, "array_swap") || String.eq(k, "array_size") || String.eq(k, "array_clone") ||
      U32.is_ne(nc_atomic(k), 0)

@unsafe
def nc_array_known(k):
  match k:
    case SNil{}: False{}
    case SCon{h, _}: w5c2_nc_arr_known_go(U32.is_eq(Char.to_u32(h), 97), k)""",
        "fast_nc_atomic_array_known",
    )

    src = replace_exact(
        src,
        """# Module: src/back/native/book.bend:62
@unsafe
def nc_unann(t):
  nt_choose(KTerm, p98_tag_eq(t, "Ann"), u => nc_unann(kid(t, 0)), u => t)""",
        """# Module: src/back/native/book.bend:62
@unsafe
def w5c2_nc_unann_if(is_ann: Bool, +t: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match is_ann:
    case False{}: t
    case True{}:
      match kids:
        case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
        case Con{h, _}: nc_unann(h)

@unsafe
def nc_unann(t):
  match t:
    case KTerm{tag, _, _, _, kids, _, _, _}:
      w5c2_nc_unann_if(String.eq(tag, "Ann"), t, kids)
    case _: t""",
        "fast_nc_unann",
    )

    # =========================================================================
    # 5. Scalar-Array Analysis Closure Killer: ns_generic_array, ns_terms, ns_annotated, ns_term
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/back/native/scalar-array.bend:15
@unsafe
def ns_generic_array(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Ref"),
    u => nt_choose(Bool, nc_native_def(lookup(book, nm(t))),
      v => nb_contains(["array_new", "array_get", "array_set", "array_swap", "array_size", "array_clone"], nc_primitive_name(nm(t))), v => False{}), u => False{})

# Module: src/back/native/scalar-array.bend:21
@unsafe
def ns_array_pattern(+t: KTerm) -> Bool:
  (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Mat")) && (p88_string_eq(nm(t), "ALeaf") || p88_string_eq(nm(t), "ANode"))

# Module: src/back/native/scalar-array.bend:25
@unsafe
def ns_terms(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_term(book, h), u => ns_terms(book, rest), u => False{})

# Module: src/back/native/scalar-array.bend:31
@unsafe
def ns_annotated(+book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  nt_choose(Bool, ns_array_pattern(value),
    u => ns_array_type(book, nt_choose(KTerm, p98_tag_eq(value, "Mat"), v => kid(nq_layout_type(book, ty), 0), v => ty)) && ns_terms(book, ks(value)),
    u => ns_term(book, value))

# Module: src/back/native/scalar-array.bend:37
@unsafe
def ns_term(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Ann"), u => ns_annotated(book, kid(t, 0), kid(t, 1)), u =>
  nt_choose(Bool, p98_tag_eq(t, "Rwt") || ns_array_pattern(t), u => False{}, u =>
  nt_choose(Bool, nt_choose(Bool, p98_tag_eq(t, "App"), v => ns_generic_array(book, nc_unann(kid(t, 0))), v => False{}), u => ns_scalar(book, kid(t, 1)), u =>
  nt_choose(Bool, ns_generic_array(book, t), u => False{}, u => ns_terms(book, ks(t))))))""",
        """# Module: src/back/native/scalar-array.bend:15
@unsafe
def w5c2_ns_gen_arr_prim(ok: Bool, +name: String) -> Bool:
  match ok:
    case False{}: False{}
    case True{}:
      +p = nc_primitive_name(name)
      String.eq(p, "array_get") || String.eq(p, "array_set") || String.eq(p, "array_new") ||
      String.eq(p, "array_swap") || String.eq(p, "array_size") || String.eq(p, "array_clone")

@unsafe
def w5c2_ns_gen_arr_ref(is_ref: Bool, +book: List<&2, KDef>, +name: String) -> Bool:
  match is_ref:
    case False{}: False{}
    case True{}: w5c2_ns_gen_arr_prim(nc_native_def(lookup(book, name)), name)

@unsafe
def ns_generic_array(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, _, _, _, _, _, _}:
      w5c2_ns_gen_arr_ref(String.eq(tag, "Ref"), book, name)
    case _: False{}

# Module: src/back/native/scalar-array.bend:21
@unsafe
def ns_array_pattern(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, _, _, _, _, _, _}:
      (String.eq(tag, "Ctr") || String.eq(tag, "Mat")) && (String.eq(name, "ALeaf") || String.eq(name, "ANode"))
    case _: False{}

# Module: src/back/native/scalar-array.bend:25
law ns_term:
  for +book: List<&2, KDef>
  for +t: KTerm
  Bool

@unsafe
def ns_terms(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: ns_term(book, h) && ns_terms(book, rest)

# Module: src/back/native/scalar-array.bend:31
@unsafe
def w5c2_ns_ann_ty(is_mat: Bool, +book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  match is_mat:
    case True{}: kid(nq_layout_type(book, ty), 0)
    case False{}: ty

@unsafe
def w5c2_ns_ann_if(is_pat: Bool, +book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  match is_pat:
    case True{}: ns_array_type(book, w5c2_ns_ann_ty(p98_tag_eq(value, "Mat"), book, ty)) && ns_terms(book, ks(value))
    case False{}: ns_term(book, value)

@unsafe
def ns_annotated(+book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  w5c2_ns_ann_if(ns_array_pattern(value), book, value, ty)

# Module: src/back/native/scalar-array.bend:37
@unsafe
def w5c2_ns_term_gen(is_gen: Bool, +book: List<&2, KDef>, +kids: List<&2, KTerm>) -> Bool:
  match is_gen:
    case True{}: False{}
    case False{}: ns_terms(book, kids)

@unsafe
def w5c2_ns_term_app2(is_ga: Bool, +book: List<&2, KDef>, +t: KTerm, +k1: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match is_ga:
    case True{}: ns_scalar(book, k1)
    case False{}: w5c2_ns_term_gen(ns_generic_array(book, t), book, kids)

@unsafe
def w5c2_ns_term_app(is_app: Bool, +book: List<&2, KDef>, +t: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match is_app:
    case True{}: w5c2_ns_term_app2(ns_generic_array(book, nc_unann(terms_at(kids, 0))), book, t, terms_at(kids, 1), kids)
    case False{}: w5c2_ns_term_gen(ns_generic_array(book, t), book, kids)

@unsafe
def w5c2_ns_term_rwt(bad: Bool, +tag: String, +book: List<&2, KDef>, +t: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match bad:
    case True{}: False{}
    case False{}: w5c2_ns_term_app(String.eq(tag, "App"), book, t, kids)

@unsafe
def w5c2_ns_term_ann(is_ann: Bool, +tag: String, +name: String, +book: List<&2, KDef>, +t: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match is_ann:
    case True{}: ns_annotated(book, terms_at(kids, 0), terms_at(kids, 1))
    case False{}:
      w5c2_ns_term_rwt(
        String.eq(tag, "Rwt") || ((String.eq(tag, "Ctr") || String.eq(tag, "Mat")) && (String.eq(name, "ALeaf") || String.eq(name, "ANode"))),
        tag, book, t, kids)

@unsafe
def ns_term(book, t):
  match t:
    case KTerm{tag, name, _, _, kids, _, _, _}:
      w5c2_ns_term_ann(String.eq(tag, "Ann"), tag, name, book, t, kids)
    case KLambda{_, _, _, kids, _, _, _, _}:
      ns_terms(book, kids)
    case KLiteral{_, _, _, _, _}: True{}""",
        "fast_ns_term",
    )

    # =========================================================================
    # 6. p205v_range / p205v_range_cmp / p205v_dist_* Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p205v_range(book, t, fuel):
  kc(W2Range,U32.is_eq(fuel,0),u => W2Range{0,0,False{}},u =>
    p205v_range_lit(book,j_strip(t),U32.sub(fuel,1),j_u32(j_strip(t))))

@unsafe
def p205v_range_cmp(+op: String, +ra: W2Range, +rb: W2Range) -> KTerm:
  match ra rb:
    case W2Range{la,ha,oka} W2Range{lb,hb,okb}:
      kc(KTerm,oka && okb,u =>
        kc(KTerm,agy_str_eq(op,"u32_is_le"),a =>
          kc(KTerm,U32.is_le(ha,lb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_gt(la,hb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,agy_str_eq(op,"u32_is_lt"),a =>
          kc(KTerm,U32.is_lt(ha,lb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_ge(la,hb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,agy_str_eq(op,"u32_is_ge"),a =>
          kc(KTerm,U32.is_ge(la,hb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_lt(ha,lb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,agy_str_eq(op,"u32_is_gt"),a =>
          kc(KTerm,U32.is_gt(la,hb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_le(ha,lb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,agy_str_eq(op,"u32_is_eq"),a =>
          kc(KTerm,U32.is_lt(ha,lb) || U32.is_gt(la,hb),b => p205v_bool(False{}),b => atom("Absent")),a =>
        kc(KTerm,agy_str_eq(op,"u32_is_ne"),a =>
          kc(KTerm,U32.is_lt(ha,lb) || U32.is_gt(la,hb),b => p205v_bool(True{}),b => atom("Absent")),a => atom("Absent"))))))),
        u => atom("Absent"))""",
        """@unsafe
def w5c2_p205v_range_if(z: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> W2Range:
  match z:
    case True{}: W2Range{0,0,False{}}
    case False{}:
      +s = j_strip(t)
      p205v_range_lit(book, s, U32.sub(fuel, 1), j_u32_node(s))

@unsafe
def p205v_range(book, t, fuel):
  w5c2_p205v_range_if(U32.is_eq(fuel, 0), book, t, fuel)

@unsafe
def w5c2_rcmp_tf(yes: Bool, no: Bool) -> KTerm:
  match yes:
    case True{}: p205v_bool(True{})
    case False{}:
      match no:
        case True{}: p205v_bool(False{})
        case False{}: atom("Absent")

@unsafe
def w5c2_rcmp_b(ok: Bool, +val: Bool) -> KTerm:
  match ok:
    case True{}: p205v_bool(val)
    case False{}: atom("Absent")

@unsafe
def w5c2_rcmp_ne(m: Bool, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_b(U32.is_lt(ha,lb) || U32.is_gt(la,hb), True{})
    case False{}: atom("Absent")

@unsafe
def w5c2_rcmp_eq(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_b(U32.is_lt(ha,lb) || U32.is_gt(la,hb), False{})
    case False{}: w5c2_rcmp_ne(String.eq(op,"u32_is_ne"), la, ha, lb, hb)

@unsafe
def w5c2_rcmp_gt(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_gt(la,hb), U32.is_le(ha,lb))
    case False{}: w5c2_rcmp_eq(String.eq(op,"u32_is_eq"), op, la, ha, lb, hb)

@unsafe
def w5c2_rcmp_ge(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_ge(la,hb), U32.is_lt(ha,lb))
    case False{}: w5c2_rcmp_gt(String.eq(op,"u32_is_gt"), op, la, ha, lb, hb)

@unsafe
def w5c2_rcmp_lt(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_lt(ha,lb), U32.is_ge(la,hb))
    case False{}: w5c2_rcmp_ge(String.eq(op,"u32_is_ge"), op, la, ha, lb, hb)

@unsafe
def w5c2_rcmp_le(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_le(ha,lb), U32.is_gt(la,hb))
    case False{}: w5c2_rcmp_lt(String.eq(op,"u32_is_lt"), op, la, ha, lb, hb)

@unsafe
def w5c2_rcmp_ok(ok: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match ok:
    case False{}: atom("Absent")
    case True{}: w5c2_rcmp_le(String.eq(op,"u32_is_le"), op, la, ha, lb, hb)

@unsafe
def p205v_range_cmp(+op: String, +ra: W2Range, +rb: W2Range) -> KTerm:
  match ra rb:
    case W2Range{la,ha,oka} W2Range{lb,hb,okb}:
      w5c2_rcmp_ok(oka && okb, op, la, ha, lb, hb)""",
        "fast_p205v_range",
    )

    # =========================================================================
    # 7. p113px_let & p113df_* Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p113px_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,agy_str_eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => p126dp_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape),
    u => p113px_known(book,value,rest,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))""",
        """@unsafe
def w5c2_px_let_shape(is_call: Bool, +book: List<&2,KDef>, +value: KTerm, +target: P113PTarget) -> KTerm:
  match is_call:
    case True{}: nq_call_shape(book,nm(value),ks(value),p113pl_view(target))
    case False{}: p126dp_value_shape(book,value,p113pl_view(target))

@unsafe
def w5c2_px_let_known(kn: Bool, +book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  match kn:
    case True{}: p113px_known(book,value,rest,env,id,target,n,shape)
    case False{}: p113px_boxed(book,value,rest,env,id,target,n)

@unsafe
def p113px_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = w5c2_px_let_shape(p98_tag_eq(value,"NPCall"), book, value, target)
  w5c2_px_let_known(p113p_known(shape), book, value, rest, env, id, target, n, shape)""",
        "fast_p113px_let",
    )

    # =========================================================================
    # 8. p113k_* Massive Closure Killer (3.4s inclusive!)
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p113k_bits(+value: U32, +bits: U32) -> U32:
  nt_choose(U32,U32.is_eq(value,0),u => bits,u => p113k_bits(U32.shr(value),U32.inc(bits)))


@unsafe
def p113k_exact(+lo: U32, +hi: U32) -> P113KFact:
  P113KFact{nt_choose(U32,U32.is_eq(hi,0),u => p113k_bits(lo,0),u => U32.add(32,p113k_bits(hi,0))),True{},lo,hi}


@unsafe
def p113k_bound(+bits: U32) -> P113KFact:
  nt_choose(P113KFact,U32.is_eq(bits,0),u => p113k_exact(0,0),u => P113KFact{U32.min(bits,64),False{},0,0})


@unsafe
def p113k_get(+facts: KDef, +name: String) -> P113KFact:
  +record = p111v_get(facts,name)
  nt_choose(P113KFact,agy_str_eq(dk(record),"P113KFact"),
    u => P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
    u => p113k_bound(64))""",
        """@unsafe
def w5c2_bits1(ge2: Bool, +b: U32) -> U32:
  match ge2:
    case True{}: U32.add(b, 2)
    case False{}: U32.inc(b)

@unsafe
def w5c2_bits2(ge4: Bool, +v: U32, +b: U32) -> U32:
  match ge4:
    case True{}: w5c2_bits1(U32.is_ge(U32.shrn(v, 2n), 2), U32.add(b, 2))
    case False{}: w5c2_bits1(U32.is_ge(v, 2), b)

@unsafe
def w5c2_bits4(ge16: Bool, +v: U32, +b: U32) -> U32:
  match ge16:
    case True{}:
      +v1 = U32.shrn(v, 4n)
      w5c2_bits2(U32.is_ge(v1, 4), v1, U32.add(b, 4))
    case False{}: w5c2_bits2(U32.is_ge(v, 4), v, b)

@unsafe
def w5c2_bits8(ge256: Bool, +v: U32, +b: U32) -> U32:
  match ge256:
    case True{}:
      +v1 = U32.shrn(v, 8n)
      w5c2_bits4(U32.is_ge(v1, 16), v1, U32.add(b, 8))
    case False{}: w5c2_bits4(U32.is_ge(v, 16), v, b)

@unsafe
def w5c2_bits16(ge65536: Bool, +v: U32, +b: U32) -> U32:
  match ge65536:
    case True{}:
      +v1 = U32.shrn(v, 16n)
      w5c2_bits8(U32.is_ge(v1, 256), v1, U32.add(b, 16))
    case False{}: w5c2_bits8(U32.is_ge(v, 256), v, b)

@unsafe
def w5c2_bits_nz(z: Bool, +v: U32, +b: U32) -> U32:
  match z:
    case True{}: b
    case False{}: w5c2_bits16(U32.is_ge(v, 65536), v, b)

@unsafe
def p113k_bits(+value: U32, +bits: U32) -> U32:
  w5c2_bits_nz(U32.is_eq(value, 0), value, bits)

@unsafe
def w5c2_p113k_exact_bits(hi_z: Bool, +lo: U32, +hi: U32) -> U32:
  match hi_z:
    case True{}: p113k_bits(lo, 0)
    case False{}: p113k_bits(hi, 32)

@unsafe
def p113k_exact(+lo: U32, +hi: U32) -> P113KFact:
  P113KFact{w5c2_p113k_exact_bits(U32.is_eq(hi, 0), lo, hi), True{}, lo, hi}

@unsafe
def w5c2_p113k_bound_if(z: Bool, +bits: U32) -> P113KFact:
  match z:
    case True{}: P113KFact{0, True{}, 0, 0}
    case False{}: P113KFact{U32.min(bits, 64), False{}, 0, 0}

@unsafe
def p113k_bound(+bits: U32) -> P113KFact:
  w5c2_p113k_bound_if(U32.is_eq(bits, 0), bits)

@unsafe
def w5c2_p113k_get_if(ok: Bool, +arity: U32, +templates: U32, +val: KTerm) -> P113KFact:
  match ok:
    case True{}: P113KFact{arity, U32.is_eq(templates, 1), ix(val), qt(val)}
    case False{}: P113KFact{64, False{}, 0, 0}

@unsafe
def w5c2_p113k_get_rec(record: KDef) -> P113KFact:
  match record:
    case KDef{_, kind, arity, templates, _, val, _, _, _}:
      w5c2_p113k_get_if(String.eq(kind, "P113KFact"), arity, templates, val)
    case _: P113KFact{64, False{}, 0, 0}

@unsafe
def p113k_get(+facts: KDef, +name: String) -> P113KFact:
  w5c2_p113k_get_rec(p111v_get(facts, name))""",
        "fast_p113k_bits_exact_bound_get",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_atom(+value: N111Value, fact: P113KFact) -> N111Value:
  match fact:
    case P113KFact{bits,+exact,lo,hi}: nt_choose(N111Value,exact,u => N111Const{lo,hi},u => value)""",
        """@unsafe
def w5c2_p113k_atom_if(exact: Bool, +lo: U32, +hi: U32, +value: N111Value) -> N111Value:
  match exact:
    case True{}: N111Const{lo,hi}
    case False{}: value

@unsafe
def p113k_atom(+value: N111Value, fact: P113KFact) -> N111Value:
  match fact:
    case P113KFact{bits,exact,lo,hi}: w5c2_p113k_atom_if(exact, lo, hi, value)""",
        "fast_p113k_atom",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_join_fact(left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re && U32.is_eq(ll,rl) && U32.is_eq(lh,rh),
        u => p113k_exact(ll,lh),u => P113KFact{U32.max(lb,rb),False{},U32.and(ll,rl),U32.and(lh,rh)})

# AGY-W5-STRUCT: Patricia-trie structural intersection for p113k_join (0 re-hashing, O(1) disjoint pruning)
@unsafe
def p113k_join_insert(+out: KDef, +name: String, +hash: U32, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      p131i_insert(out,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",1,0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},hash)

@unsafe
def p113k_join_record_h(+record: KDef, +hash: U32, +right: KDef, +out: KDef) -> KDef:
  nt_choose(KDef,agy_str_eq(dk(record),"P113KFact"),
    u =>
      +name = dn(record)
      +found = index_find(right,name,hash,32)
      nt_choose(KDef,agy_str_eq(dk(found),"P113KFact"),
        v => p113k_join_insert(out,name,hash,p113k_join_fact(
          P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
          P113KFact{da(found),U32.is_eq(dx(found),1),ix(dv(found)),qt(dv(found))})),
        v => out),
    u => out)

@unsafe
def p113k_join_bucket_h(bucket: List<&2,KDef>, +hash: U32, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket_h(rest,hash,right,p113k_join_record_h(head,hash,right,out))

@unsafe
def p113k_join_record_b(+record: KDef, +hash: U32, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  nt_choose(KDef,agy_str_eq(dk(record),"P113KFact"),
    u =>
      +name = dn(record)
      +found = index_bucket(rbucket,name)
      nt_choose(KDef,agy_str_eq(dk(found),"P113KFact"),
        v => p113k_join_insert(out,name,hash,p113k_join_fact(
          P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
          P113KFact{da(found),U32.is_eq(dx(found),1),ix(dv(found)),qt(dv(found))})),
        v => out),
    u => out)

@unsafe
def p113k_join_buckets(lbucket: List<&2,KDef>, +hash: U32, +rbucket: List<&2,KDef>, out: KDef) -> KDef:
  match lbucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_buckets(rest,hash,rbucket,p113k_join_record_b(head,hash,rbucket,out))

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record_h(head,index_hash(dn(head),2166136261),right,out))

@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  p113k_join_record_h(record,index_hash(dn(record),2166136261),right,out)

law p113k_join_go:
  for +left: KDef
  for +right: KDef
  for +out: KDef
  KDef

@unsafe
def p113k_join_leaf(+lh: U32, +lbucket: List<&2,KDef>, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh,rbucket}:
      nt_choose(KDef,U32.is_eq(lh,rh),u => p113k_join_buckets(lbucket,lh,rbucket,out),u => out)
    case KIndexNode{rh,rm,ra,rb}:
      nt_choose(KDef,U32.is_eq(rm,0),
        u => p113k_join_bucket_h(lbucket,lh,right,out),
        u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(rm,1)),0),
          v => nt_choose(KDef,U32.is_eq(U32.and(lh,rm),0),
            w => p113k_join_leaf(lh,lbucket,ra,out),
            w => p113k_join_leaf(lh,lbucket,rb,out)),
          v => out))
    case KDef{_,kind,_,_,_,_,_,_,_}:
      nt_choose(KDef,agy_str_eq(kind,"Absent"),u => out,u => p113k_join_bucket_h(lbucket,lh,right,out))

@unsafe
def p113k_join_nn_diff(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  nt_choose(KDef,U32.is_lt(lm,rm),
    u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(lm,1)),0),
      v => nt_choose(KDef,U32.is_eq(U32.and(rh,lm),0),
        w => p113k_join_go(la,right,out),
        w => p113k_join_go(lb,right,out)),
      v => out),
    u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(rm,1)),0),
      v => nt_choose(KDef,U32.is_eq(U32.and(lh,rm),0),
        w => p113k_join_go(left,ra,out),
        w => p113k_join_go(left,rb,out)),
      v => out))

@unsafe
def p113k_join_nn(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  nt_choose(KDef,U32.is_eq(lm,0) || U32.is_eq(rm,0),
    u => p113k_join_go(lb,right,p113k_join_go(la,right,out)),
    u => nt_choose(KDef,U32.is_eq(lm,rm),
      v => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(lm,1)),0),
        w => p113k_join_go(lb,rb,p113k_join_go(la,ra,out)),
        w => out),
      v => p113k_join_nn_diff(lh,lm,la,lb,left,rh,rm,ra,rb,right,out)))

@unsafe
def p113k_join_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh,rbucket}:
      nt_choose(KDef,U32.is_eq(lm,0),
        u => p113k_join_go(lb,right,p113k_join_go(la,right,out)),
        u => nt_choose(KDef,U32.is_eq(U32.and(U32.xor(lh,rh),U32.sub(lm,1)),0),
          v => nt_choose(KDef,U32.is_eq(U32.and(rh,lm),0),
            w => p113k_join_go(la,right,out),
            w => p113k_join_go(lb,right,out)),
          v => out))
    case KIndexNode{rh,rm,ra,rb}:
      p113k_join_nn(lh,lm,la,lb,left,rh,rm,ra,rb,right,out)
    case KDef{_,kind,_,_,_,_,_,_,_}:
      nt_choose(KDef,agy_str_eq(kind,"Absent"),u => out,u => p113k_join_go(lb,right,p113k_join_go(la,right,out)))""",
        """@unsafe
def w5c2_join_fact_if(same: Bool, +lb: U32, +ll: U32, +lh: U32, +rb: U32, +rl: U32, +rh: U32) -> P113KFact:
  match same:
    case True{}: p113k_exact(ll, lh)
    case False{}: P113KFact{U32.max(lb, rb), False{}, U32.and(ll, rl), U32.and(lh, rh)}

@unsafe
def p113k_join_fact(left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      w5c2_join_fact_if(le && re && U32.is_eq(ll,rl) && U32.is_eq(lh,rh), lb, ll, lh, rb, rl, rh)

# AGY-W5-STRUCT + W5B-C2: zero-closure Patricia-trie structural intersection for p113k_join
@unsafe
def p113k_join_insert(+out: KDef, +name: String, +hash: U32, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      p131i_insert(out,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",1,0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},hash)

@unsafe
def w5c2_join_pair_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +ra: U32, +rx: U32, +rv: KTerm, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}:
      p113k_join_insert(out, name, hash, p113k_join_fact(
        P113KFact{la, U32.is_eq(lx, 1), ix(lv), qt(lv)},
        P113KFact{ra, U32.is_eq(rx, 1), ix(rv), qt(rv)}))

@unsafe
def w5c2_join_found(+found: KDef, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +out: KDef) -> KDef:
  match found:
    case KDef{_, rkind, ra, rx, _, rv, _, _, _}:
      w5c2_join_pair_ok(String.eq(rkind, "P113KFact"), name, hash, la, lx, lv, ra, rx, rv, out)
    case _: out

@unsafe
def w5c2_join_rec_h_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +right: KDef, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}: w5c2_join_found(index_find(right, name, hash, 32), name, hash, la, lx, lv, out)

@unsafe
def p113k_join_record_h(+record: KDef, +hash: U32, +right: KDef, +out: KDef) -> KDef:
  match record:
    case KDef{name, lkind, la, lx, _, lv, _, _, _}:
      w5c2_join_rec_h_ok(String.eq(lkind, "P113KFact"), name, hash, la, lx, lv, right, out)
    case _: out

@unsafe
def p113k_join_bucket_h(bucket: List<&2,KDef>, +hash: U32, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket_h(rest,hash,right,p113k_join_record_h(head,hash,right,out))

@unsafe
def w5c2_join_rec_b_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}: w5c2_join_found(index_bucket(rbucket, name), name, hash, la, lx, lv, out)

@unsafe
def p113k_join_record_b(+record: KDef, +hash: U32, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  match record:
    case KDef{name, lkind, la, lx, _, lv, _, _, _}:
      w5c2_join_rec_b_ok(String.eq(lkind, "P113KFact"), name, hash, la, lx, lv, rbucket, out)
    case _: out

@unsafe
def p113k_join_buckets(lbucket: List<&2,KDef>, +hash: U32, +rbucket: List<&2,KDef>, out: KDef) -> KDef:
  match lbucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_buckets(rest,hash,rbucket,p113k_join_record_b(head,hash,rbucket,out))

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record_h(head,index_hash(dn(head),2166136261),right,out))

@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  p113k_join_record_h(record,index_hash(dn(record),2166136261),right,out)

law p113k_join_go:
  for +left: KDef
  for +right: KDef
  for +out: KDef
  KDef

law p113k_join_leaf:
  for +lh: U32
  for +lbucket: List<&2,KDef>
  for +right: KDef
  for +out: KDef
  KDef

@unsafe
def w5c2_jl_eq(eq: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  match eq:
    case True{}: p113k_join_buckets(lbucket, lh, rbucket, out)
    case False{}: out

@unsafe
def w5c2_jl_lr(go_l: Bool, +lh: U32, +lbucket: List<&2,KDef>, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_leaf(lh, lbucket, ra, out)
    case False{}: p113k_join_leaf(lh, lbucket, rb, out)

@unsafe
def w5c2_jl_sub(in_sub: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rm: U32, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match in_sub:
    case True{}: w5c2_jl_lr(U32.is_eq(U32.and(lh, rm), 0), lh, lbucket, ra, rb, out)
    case False{}: out

@unsafe
def w5c2_jl_rm0(rm0: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match rm0:
    case True{}: p113k_join_bucket_h(lbucket, lh, right, out)
    case False{}: w5c2_jl_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, lbucket, rm, ra, rb, out)

@unsafe
def w5c2_jl_abs(is_abs: Bool, +lh: U32, +lbucket: List<&2,KDef>, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: out
    case False{}: p113k_join_bucket_h(lbucket, lh, right, out)

@unsafe
def p113k_join_leaf(lh, lbucket, right, out):
  match right:
    case KIndexLeaf{rh, rbucket}:
      w5c2_jl_eq(U32.is_eq(lh, rh), lh, lbucket, rbucket, out)
    case KIndexNode{rh, rm, ra, rb}:
      w5c2_jl_rm0(U32.is_eq(rm, 0), lh, lbucket, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jl_abs(String.eq(kind, "Absent"), lh, lbucket, right, out)

@unsafe
def w5c2_jg_lr(go_l: Bool, +a: KDef, +b: KDef, +other: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_go(a, other, out)
    case False{}: p113k_join_go(b, other, out)

@unsafe
def w5c2_jg_lr_r(go_l: Bool, +other: KDef, +a: KDef, +b: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_go(other, a, out)
    case False{}: p113k_join_go(other, b, out)

@unsafe
def w5c2_jnn_lt_sub(ok: Bool, +rh: U32, +lm: U32, +la: KDef, +lb: KDef, +right: KDef, +out: KDef) -> KDef:
  match ok:
    case True{}: w5c2_jg_lr(U32.is_eq(U32.and(rh, lm), 0), la, lb, right, out)
    case False{}: out

@unsafe
def w5c2_jnn_gt_sub(ok: Bool, +lh: U32, +rm: U32, +left: KDef, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match ok:
    case True{}: w5c2_jg_lr_r(U32.is_eq(U32.and(lh, rm), 0), left, ra, rb, out)
    case False{}: out

@unsafe
def w5c2_jnn_lt(lt: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match lt:
    case True{}: w5c2_jnn_lt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right, out)
    case False{}: w5c2_jnn_gt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, rm, left, ra, rb, out)

@unsafe
def p113k_join_nn_diff(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c2_jnn_lt(U32.is_lt(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jnn_same_sub(ok: Bool, +la: KDef, +lb: KDef, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match ok:
    case True{}: p113k_join_go(lb, rb, p113k_join_go(la, ra, out))
    case False{}: out

@unsafe
def w5c2_jnn_eq(eq: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match eq:
    case True{}: w5c2_jnn_same_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), la, lb, ra, rb, out)
    case False{}: w5c2_jnn_lt(U32.is_lt(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jnn_z(z: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match z:
    case True{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))
    case False{}: w5c2_jnn_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def p113k_join_nn(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c2_jnn_z(U32.is_eq(lm, 0) || U32.is_eq(rm, 0), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jn_lm0(lm0: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +rh: U32, +right: KDef, +out: KDef) -> KDef:
  match lm0:
    case True{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))
    case False{}: w5c2_jnn_lt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right, out)

@unsafe
def w5c2_jn_abs(is_abs: Bool, +la: KDef, +lb: KDef, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: out
    case False{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))

@unsafe
def p113k_join_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh, _}:
      w5c2_jn_lm0(U32.is_eq(lm, 0), lh, lm, la, lb, rh, right, out)
    case KIndexNode{rh, rm, ra, rb}:
      p113k_join_nn(lh, lm, la, lb, left, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jn_abs(String.eq(kind, "Absent"), la, lb, right, out)""",
        "fast_p113k_join",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_limit(fact: P113KFact, +width: U32) -> P113KFact:
  match fact:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,exact,u => p113k_exact(lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)),
        u => P113KFact{U32.min(bits,width),False{},lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)})""",
        """@unsafe
def w5c2_p113k_limit_if(exact: Bool, +bits: U32, +lo: U32, +nhi: U32, +width: U32) -> P113KFact:
  match exact:
    case True{}: p113k_exact(lo, nhi)
    case False{}: P113KFact{U32.min(bits, width), False{}, lo, nhi}

@unsafe
def p113k_limit(fact: P113KFact, +width: U32) -> P113KFact:
  match fact:
    case P113KFact{+bits,exact,+lo,+hi}:
      +nhi = w5c2_u32_pick(U32.is_eq(width, 32), 0, hi)
      w5c2_p113k_limit_if(exact, bits, lo, nhi, width)""",
        "fast_p113k_limit",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_ones(+bits: U32) -> U32:
  nt_choose(U32,U32.is_eq(bits,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(bits)),1))


@unsafe
def p113k_mask_covers(+bits: U32, mask: P113KFact) -> Bool:
  match mask:
    case P113KFact{mb,+exact,+lo,+hi}:
      exact && nt_choose(Bool,U32.is_le(bits,32),
        u => U32.is_eq(U32.and(lo,p113k_ones(bits)),p113k_ones(bits)),
        u => U32.is_eq(lo,4294967295) && U32.is_eq(U32.and(hi,p113k_ones(U32.sub(bits,32))),p113k_ones(U32.sub(bits,32))))


@unsafe
def p113k_bits_of(fact: P113KFact) -> U32:
  match fact:
    case P113KFact{bits,exact,lo,hi}: bits


@unsafe
def p113k_zero(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_eq(bits,0)


@unsafe
def p113k_result_type(+typ: N111Type, +op: String) -> N111Type:
  nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => typ)""",
        """@unsafe
def w5c2_ones_if(is32: Bool, +bits: U32) -> U32:
  match is32:
    case True{}: 4294967295
    case False{}: U32.sub(U32.shln(1, U32.to_nat(bits)), 1)

@unsafe
def p113k_ones(+bits: U32) -> U32:
  w5c2_ones_if(U32.is_eq(bits, 32), bits)

@unsafe
def w5c2_mask_cov_if(le32: Bool, +bits: U32, +lo: U32, +hi: U32) -> Bool:
  match le32:
    case True{}:
      +m = p113k_ones(bits)
      U32.is_eq(U32.and(lo, m), m)
    case False{}:
      +m = p113k_ones(U32.sub(bits, 32))
      U32.is_eq(lo, 4294967295) && U32.is_eq(U32.and(hi, m), m)

@unsafe
def p113k_mask_covers(+bits: U32, mask: P113KFact) -> Bool:
  match mask:
    case P113KFact{_, exact, +lo, +hi}:
      exact && w5c2_mask_cov_if(U32.is_le(bits, 32), bits, lo, hi)

@unsafe
def p113k_bits_of(fact: P113KFact) -> U32:
  match fact:
    case P113KFact{bits,exact,lo,hi}: bits

@unsafe
def p113k_zero(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_eq(bits,0)

@unsafe
def w5c2_res_ty_if(is_cmp: Bool, +typ: N111Type) -> N111Type:
  match is_cmp:
    case True{}: N111U32{}
    case False{}: typ

@unsafe
def p113k_result_type(+typ: N111Type, +op: String) -> N111Type:
  w5c2_res_ty_if(p111v_comparison(op), typ)""",
        "fast_p113k_ones_mask_resty",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{+bits,+exact,+lo,hi}:
      nt_choose(P113KScalar,exact,
        u => nt_choose(P113KScalar,U32.is_eq(lo,0),v => p113k_scalars(no,facts),v => p113k_scalars(yes,facts)),
        u => w4g_scalar_join_opt(condition,facts,bits,p113k_scalars(yes,p113l_assume(facts,condition,True{})),p113k_scalars(no,p113l_assume(facts,condition,False{}))))""",
        """@unsafe
def w5c2_sc_if_lo(lo0: Bool, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef) -> P113KScalar:
  match lo0:
    case True{}: p113k_scalars(no, facts)
    case False{}: p113k_scalars(yes, facts)

@unsafe
def w5c2_sc_if_ex(exact: Bool, +bits: U32, +lo: U32, +condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef) -> P113KScalar:
  match exact:
    case True{}: w5c2_sc_if_lo(U32.is_eq(lo, 0), yes, no, facts)
    case False{}: w4g_scalar_join_opt(condition, facts, bits, p113k_scalars(yes, p113l_assume(facts, condition, True{})), p113k_scalars(no, p113l_assume(facts, condition, False{})))

@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{+bits,exact,+lo,_}:
      w5c2_sc_if_ex(exact, bits, lo, condition, yes, no, facts)""",
        "fast_p113k_scalar_if",
    )

    # =========================================================================
    # 9. p131i_original_set Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  kc(KDef, p88_string_eq(dk(tree), "Absent"), u => index_leaf(d, hash, Nil{}),
    u => index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash))))))""",
        """@unsafe
def w5c2_orig_set_if(is_abs: Bool, +tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match is_abs:
    case True{}: index_leaf(d, hash, Nil{})
    case False{}: index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash)))))

@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  w5c2_orig_set_if(String.eq(dk(tree), "Absent"), tree, d, hash)""",
        "fast_p131i_original_set",
    )

    # =========================================================================
    # 10. norm_max -> native U32.max (zero closures)
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/core/normalize.bend:224
@unsafe
def norm_max(
  +a: U32,
  +b: U32,
) -> U32:
  kc(U32, U32.is_le(a, b), u => b, u => a)""",
        """# Module: src/core/normalize.bend:224
@unsafe
def norm_max(
  +a: U32,
  +b: U32,
) -> U32:
  U32.max(a, b)""",
        "fast_norm_max",
    )

    # =========================================================================
    # 11. p113l_* Relation / Bin-Relation / Assume Closure & Redundant-Lookup Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p113l_enrich(+answer: P113KFact, op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match answer left right:
    case P113KFact{+bits,+exact,lo,hi} P113KFact{lb,le,ll,lh} P113KFact{rb,re,rl,rh}:
      nt_choose(P113KFact,Bool.not(exact) && agy_str_eq(op,"or"),
        u => P113KFact{bits,False{},U32.or(ll,rl),U32.or(lh,rh)},u => answer)


@unsafe
def p113l_version(+facts: KDef, +name: String) -> U32:
  ix(dt(p111v_get(facts,name)))


@unsafe
def p113l_relation(+facts: KDef, +name: String) -> KDef:
  +found = p111v_get(facts,"@condition:" ++ name)
  nt_choose(KDef,agy_str_eq(dk(found),"P113LRelation") &&
    U32.is_eq(ix(dt(found)),p113l_version(facts,nm(dv(found)))) &&
    U32.is_eq(qt(dt(found)),p113l_version(facts,name)),u => found,u => missing())


@unsafe
def p113l_relate(+facts: KDef, +name: String, subject: String, version: U32, truth: U32) -> KDef:
  +key = "@condition:" ++ name
  index_set(facts,KDef{key,"P113LRelation",truth,0,kt("Epoch","",version,p113l_version(facts,name),[]),kt("Subject",subject,0,0,[]),[],False{},False{}},index_hash(key,2166136261),32)


@unsafe
def p113l_copy_relation(+before: KDef, +after: KDef, +name: String, value: N111Value, +invert: Bool) -> KDef:
  match value:
    case N111Local{source}:
      +record = p113l_relation(before,source)
      nt_choose(KDef,agy_str_eq(dk(record),"P113LRelation"),u =>
        p113l_relate(after,name,nm(dv(record)),ix(dt(record)),U32.xor(da(record),Bool.to_u32(invert))),u => after)
    case _: after


@unsafe
def p113l_comparison(+before: KDef, +after: KDef, +name: String, +op: String, left: N111Value, right: N111Value) -> KDef:
  match left right:
    case N111Local{+subject} N111Const{+lo,+hi}:
      nt_choose(KDef,(agy_str_eq(op,"eq") || agy_str_eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1) && U32.is_le(p113k_bits_of(p113k_get(before,subject)),1),
        u => p113l_relate(after,name,subject,p113l_version(before,subject),U32.xor(lo,Bool.to_u32(agy_str_eq(op,"ne")))),u => after)
    case _ _: after


@unsafe
def p113l_bin_relation(+before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  nt_choose(KDef,(agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add")) && p113k_zero(p113k_value(right,before)),
    u => p113l_copy_relation(before,after,name,left,False{}),u =>
  nt_choose(KDef,(agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add")) && p113k_zero(p113k_value(left,before)),
    u => p113l_copy_relation(before,after,name,right,False{}),u =>
  nt_choose(KDef,agy_str_eq(op,"xor") && p113l_exact_one(p113k_value(right,before)),
    u => p113l_copy_relation(before,after,name,left,True{}),u =>
    p113l_comparison(before,after,name,op,p113k_replace(left,before),p113k_replace(right,before)))))""",
        """@unsafe
def w5c2_p113l_enr_if(ok: Bool, +bits: U32, +ll: U32, +rl: U32, +lh: U32, +rh: U32, +answer: P113KFact) -> P113KFact:
  match ok:
    case True{}: P113KFact{bits, False{}, U32.or(ll, rl), U32.or(lh, rh)}
    case False{}: answer

@unsafe
def p113l_enrich(+answer: P113KFact, op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match answer left right:
    case P113KFact{+bits,+exact,lo,hi} P113KFact{lb,le,ll,lh} P113KFact{rb,re,rl,rh}:
      w5c2_p113l_enr_if(Bool.not(exact) && String.eq(op, "or"), bits, ll, rl, lh, rh, answer)

@unsafe
def p113l_version(+facts: KDef, +name: String) -> U32:
  ix(dt(p111v_get(facts, name)))

@unsafe
def w5c2_p113l_rel_ok(ok: Bool, +found: KDef) -> KDef:
  match ok:
    case True{}: found
    case False{}: missing()

@unsafe
def w5c2_p113l_rel_check(found: KDef, +facts: KDef, +name: String) -> KDef:
  match found:
    case KDef{_, kind, _, _, ftyp, fval, _, _, _}:
      w5c2_p113l_rel_ok(
        String.eq(kind, "P113LRelation") &&
        U32.is_eq(ix(ftyp), p113l_version(facts, nm(fval))) &&
        U32.is_eq(qt(ftyp), p113l_version(facts, name)), found)
    case _: missing()

@unsafe
def p113l_relation(+facts: KDef, +name: String) -> KDef:
  w5c2_p113l_rel_check(p111v_get(facts, "@condition:" ++ name), facts, name)

@unsafe
def p113l_relate(+facts: KDef, +name: String, subject: String, version: U32, truth: U32) -> KDef:
  +key = "@condition:" ++ name
  index_set(facts, KDef{key, "P113LRelation", truth, 0, kt("Epoch", "", version, p113l_version(facts, name), []), kt("Subject", subject, 0, 0, []), [], False{}, False{}}, index_hash(key, 2166136261), 32)

@unsafe
def w5c2_p113l_copy_ok(ok: Bool, +after: KDef, +name: String, +fval: KTerm, +ftyp: KTerm, +arity: U32, +invert: Bool) -> KDef:
  match ok:
    case True{}: p113l_relate(after, name, nm(fval), ix(ftyp), U32.xor(arity, Bool.to_u32(invert)))
    case False{}: after

@unsafe
def w5c2_p113l_copy_rec(record: KDef, +after: KDef, +name: String, +invert: Bool) -> KDef:
  match record:
    case KDef{_, kind, arity, _, ftyp, fval, _, _, _}:
      w5c2_p113l_copy_ok(String.eq(kind, "P113LRelation"), after, name, fval, ftyp, arity, invert)
    case _: after

@unsafe
def p113l_copy_relation(+before: KDef, +after: KDef, +name: String, value: N111Value, +invert: Bool) -> KDef:
  match value:
    case N111Local{source}: w5c2_p113l_copy_rec(p113l_relation(before, source), after, name, invert)
    case _: after

@unsafe
def w5c2_p113l_cmp_if(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +subject: String, +lo: U32) -> KDef:
  match ok:
    case True{}: p113l_relate(after, name, subject, p113l_version(before, subject), U32.xor(lo, Bool.to_u32(String.eq(op, "ne"))))
    case False{}: after

@unsafe
def p113l_comparison(+before: KDef, +after: KDef, +name: String, +op: String, left: N111Value, right: N111Value) -> KDef:
  match left right:
    case N111Local{+subject} N111Const{+lo,+hi}:
      w5c2_p113l_cmp_if((String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1) && U32.is_le(p113k_bits_of(p113k_get(before,subject)),1), before, after, name, op, subject, lo)
    case _ _: after

@unsafe
def w5c2_p113l_br_eqne(is_eqne: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  match is_eqne:
    case True{}: p113l_comparison(before, after, name, op, p113k_replace(left, before), p113k_replace(right, before))
    case False{}: after

@unsafe
def w5c2_p113l_br_xor1(ok: Bool, +before: KDef, +after: KDef, +name: String, +left: N111Value) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, left, True{})
    case False{}: after

@unsafe
def w5c2_p113l_br_lz(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value, +rf: P113KFact) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, right, False{})
    case False{}: w5c2_p113l_br_xor1(String.eq(op, "xor") && p113l_exact_one(rf), before, after, name, left)

@unsafe
def w5c2_p113l_br_rz(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value, +rf: P113KFact) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, left, False{})
    case False{}: w5c2_p113l_br_lz(p113k_zero(p113k_value(left, before)), before, after, name, op, left, right, rf)

@unsafe
def w5c2_p113l_br_oxa(is_oxa: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  match is_oxa:
    case True{}:
      +rf = p113k_value(right, before)
      w5c2_p113l_br_rz(p113k_zero(rf), before, after, name, op, left, right, rf)
    case False{}: w5c2_p113l_br_eqne(String.eq(op, "eq") || String.eq(op, "ne"), before, after, name, op, left, right)

@unsafe
def p113l_bin_relation(+before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  w5c2_p113l_br_oxa(String.eq(op, "or") || String.eq(op, "xor") || String.eq(op, "add"), before, after, name, op, left, right)""",
        "fast_p113l_relations",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113l_assume(+facts: KDef, condition: N111Value, +truth: Bool) -> KDef:
  match condition:
    case N111Local{name}:
      +record = p113l_relation(facts,name)
      nt_choose(KDef,agy_str_eq(dk(record),"P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts,nm(dv(record)))),1),
        u => p113k_put(facts,nm(dv(record)),p113k_exact(U32.xor(da(record),Bool.to_u32(Bool.not(truth))),0)),u => facts)
    case _: facts""",
        """@unsafe
def w5c2_p113l_assume_ok(ok: Bool, +facts: KDef, +subj: String, +arity: U32, +truth: Bool) -> KDef:
  match ok:
    case True{}: p113k_put(facts, subj, p113k_exact(U32.xor(arity, Bool.to_u32(Bool.not(truth))), 0))
    case False{}: facts

@unsafe
def w5c2_p113l_assume_rec(record: KDef, +facts: KDef, +truth: Bool) -> KDef:
  match record:
    case KDef{_, kind, arity, _, _, fval, _, _, _}:
      +subj = nm(fval)
      w5c2_p113l_assume_ok(String.eq(kind, "P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts, subj)), 1), facts, subj, arity, truth)
    case _: facts

@unsafe
def p113l_assume(+facts: KDef, condition: N111Value, +truth: Bool) -> KDef:
  match condition:
    case N111Local{name}: w5c2_p113l_assume_rec(p113l_relation(facts, name), facts, truth)
    case _: facts""",
        "fast_p113l_assume",
    )

    # =========================================================================
    # 12. NU_Set (nu_tip, nu_join, nu_insert, nu_add, nu_has) + nc_word Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/back/native/uses.bend:9
@unsafe
def nu_tip(s: NU_Set, +key: U32) -> U32:
  match s:
    case NU_Empty{}: key
    case NU_Leaf{stored}: stored
    case NU_Node{+mask, +left, +right}:
      nt_choose(U32, U32.is_eq(U32.and(key, mask), 0), u => nu_tip(left, key), u => nu_tip(right, key))

# Module: src/back/native/uses.bend:17
@unsafe
def nu_join(+s: NU_Set, +key: U32, +mask: U32) -> NU_Set:
  nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0),
    u => NU_Node{mask, NU_Leaf{key}, s}, u => NU_Node{mask, s, NU_Leaf{key}})

# Module: src/back/native/uses.bend:22
@unsafe
def nu_insert(+s: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case NU_Leaf{stored}: nu_join(s, key, split)
    case NU_Node{+mask, +left, +right}:
      nt_choose(NU_Set, U32.is_lt(split, mask), u => nu_join(s, key, split),
        u => nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0),
          v => NU_Node{mask, nu_insert(left, key, split), right},
          v => NU_Node{mask, left, nu_insert(right, key, split)}))

# Module: src/back/native/uses.bend:33
@unsafe
def nu_add(+s: NU_Set, +key: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case _:
      +split = index_split_bit(U32.xor(key, nu_tip(s, key)))
      nt_choose(NU_Set, U32.is_eq(split, 0), u => s, u => nu_insert(s, key, split))

# Module: src/back/native/uses.bend:41
@unsafe
def nu_has(s: NU_Set, +key: U32) -> Bool:
  match s:
    case NU_Empty{}: False{}
    case NU_Leaf{stored}: U32.is_eq(stored, key)
    case NU_Node{+mask, +left, +right}:
      nt_choose(Bool, U32.is_eq(U32.and(key, mask), 0), u => nu_has(left, key), u => nu_has(right, key))

# Module: src/back/native/bridge.bend:19
@unsafe
def nc_word(+id: U32, +env: List<&2, NC_Binding>) -> String:
  match env:
    case Nil{}: "NATIVE_UNBOUND_VARIABLE"
    case Con{NC_Binding{+at, +word, +kind}, +rest}:
      nt_choose(String, U32.is_eq(id, at), u => word, u => nc_word(id, rest))""",
        """# Module: src/back/native/uses.bend:9
law nu_tip:
  for s: NU_Set
  for +key: U32
  U32

@unsafe
def w5c2_nu_tip_lr(go_l: Bool, left: NU_Set, right: NU_Set, +key: U32) -> U32:
  match go_l:
    case True{}: nu_tip(left, key)
    case False{}: nu_tip(right, key)

@unsafe
def nu_tip(s, key):
  match s:
    case NU_Empty{}: key
    case NU_Leaf{stored}: stored
    case NU_Node{+mask, left, right}:
      w5c2_nu_tip_lr(U32.is_eq(U32.and(key, mask), 0), left, right, key)

# Module: src/back/native/uses.bend:17
@unsafe
def w5c2_nu_join_lr(go_l: Bool, +s: NU_Set, +key: U32, +mask: U32) -> NU_Set:
  match go_l:
    case True{}: NU_Node{mask, NU_Leaf{key}, s}
    case False{}: NU_Node{mask, s, NU_Leaf{key}}

@unsafe
def nu_join(+s: NU_Set, +key: U32, +mask: U32) -> NU_Set:
  w5c2_nu_join_lr(U32.is_eq(U32.and(key, mask), 0), s, key, mask)

# Module: src/back/native/uses.bend:22
law nu_insert:
  for +s: NU_Set
  for +key: U32
  for +split: U32
  NU_Set

@unsafe
def w5c2_nu_ins_lr(go_l: Bool, +mask: U32, +left: NU_Set, +right: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match go_l:
    case True{}: NU_Node{mask, nu_insert(left, key, split), right}
    case False{}: NU_Node{mask, left, nu_insert(right, key, split)}

@unsafe
def w5c2_nu_ins_lt(lt: Bool, +s: NU_Set, +mask: U32, +left: NU_Set, +right: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match lt:
    case True{}: nu_join(s, key, split)
    case False{}: w5c2_nu_ins_lr(U32.is_eq(U32.and(key, mask), 0), mask, left, right, key, split)

@unsafe
def nu_insert(s, key, split):
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case NU_Leaf{stored}: nu_join(s, key, split)
    case NU_Node{+mask, +left, +right}:
      w5c2_nu_ins_lt(U32.is_lt(split, mask), s, mask, left, right, key, split)

# Module: src/back/native/uses.bend:33
@unsafe
def w5c2_nu_add_if(z: Bool, +s: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match z:
    case True{}: s
    case False{}: nu_insert(s, key, split)

@unsafe
def nu_add(+s: NU_Set, +key: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case _:
      +split = index_split_bit(U32.xor(key, nu_tip(s, key)))
      w5c2_nu_add_if(U32.is_eq(split, 0), s, key, split)

# Module: src/back/native/uses.bend:41
law nu_has:
  for s: NU_Set
  for +key: U32
  Bool

@unsafe
def w5c2_nu_has_lr(go_l: Bool, left: NU_Set, right: NU_Set, +key: U32) -> Bool:
  match go_l:
    case True{}: nu_has(left, key)
    case False{}: nu_has(right, key)

@unsafe
def nu_has(s, key):
  match s:
    case NU_Empty{}: False{}
    case NU_Leaf{stored}: U32.is_eq(stored, key)
    case NU_Node{+mask, left, right}:
      w5c2_nu_has_lr(U32.is_eq(U32.and(key, mask), 0), left, right, key)

# Module: src/back/native/bridge.bend:19
law nc_word:
  for +id: U32
  for +env: List<&2, NC_Binding>
  String

@unsafe
def w5c2_nc_word_if(eq: Bool, +word: String, +id: U32, +rest: List<&2, NC_Binding>) -> String:
  match eq:
    case True{}: word
    case False{}: nc_word(id, rest)

@unsafe
def nc_word(id, env):
  match env:
    case Nil{}: "NATIVE_UNBOUND_VARIABLE"
    case Con{NC_Binding{+at, +word, _}, +rest}:
      w5c2_nc_word_if(U32.is_eq(id, at), word, id, rest)""",
        "fast_nu_set_and_nc_word",
    )

    # =========================================================================
    # 13. nq_layout_subst & nq_layout_remaining Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """# Module: src/back/native/product-layout.bend:105
@unsafe
def nq_layout_remaining(ts: List<&2, KTerm>, +left: U32) -> U32:
  match ts:
    case Nil{}: left
    case Con{+h, +rest}:
      nt_choose(U32, U32.is_eq(left, 0), u => 0, u => nq_layout_remaining(List.append(&2, KTerm, ks(h), rest), U32.sub(left, 1)))

# Ordinary subst invokes core_rebuild, which can beta-reduce applications.
# This substitution only rebuilds syntax and never evaluates a substituted term.

# Module: src/back/native/product-layout.bend:114
@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(t, "Var"),
    u => nt_choose(KTerm, U32.is_eq(ix(t), id), v => value, v => t),
    u => k_rebuild(t, nm(t), ix(t), qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t)))""",
        """# Module: src/back/native/product-layout.bend:105
law nq_layout_remaining:
  for ts: List<&2, KTerm>
  for +left: U32
  U32

@unsafe
def w5c2_nq_rem_if(z: Bool, +h: KTerm, +rest: List<&2, KTerm>, +left: U32) -> U32:
  match z:
    case True{}: 0
    case False{}: nq_layout_remaining(List.append(&2, KTerm, ks(h), rest), U32.sub(left, 1))

@unsafe
def nq_layout_remaining(ts, left):
  match ts:
    case Nil{}: left
    case Con{+h, +rest}:
      w5c2_nq_rem_if(U32.is_eq(left, 0), h, rest, left)

# Module: src/back/native/product-layout.bend:114
@unsafe
def w5c2_nq_sub_var(eq: Bool, +t: KTerm, +value: KTerm) -> KTerm:
  match eq:
    case True{}: value
    case False{}: t

@unsafe
def w5c2_nq_sub_if(is_var: Bool, +t: KTerm, +n: U32, +id: U32, +value: KTerm) -> KTerm:
  match is_var:
    case True{}: w5c2_nq_sub_var(U32.is_eq(n, id), t, value)
    case False{}: k_rebuild(t, nm(t), n, qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t))

@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KTerm{tag, _, n, _, _, _, _, _}:
      w5c2_nq_sub_if(String.eq(tag, "Var"), t, n, id, value)
    case KLambda{name, n, quant, kids, removed, begin, end, present}:
      KLambda{name, n, quant, nq_layout_subst_list(kids, id, value), removed, begin, end, present}
    case KLiteral{_, _, _, _, _}: t""",
        "fast_nq_layout_subst",
    )

    # =========================================================================
    # 14. p111_op_id_prior / p111_op_id (86 nested nt_choose -> first-char dispatch!)
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p111_op_id_prior(+name: String) -> U32:
  nt_choose(U32, agy_str_eq(name, "u32_add"), u => 1, u =>
  nt_choose(U32, agy_str_eq(name, "u32_sub"), u => 2, u =>
  nt_choose(U32, agy_str_eq(name, "u32_and"), u => 3, u =>
  nt_choose(U32, agy_str_eq(name, "u32_or"), u => 4, u =>
  nt_choose(U32, agy_str_eq(name, "u32_xor"), u => 5, u =>
  nt_choose(U32, agy_str_eq(name, "u32_mul"), u => 6, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_eq"), u => 7, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_ne"), u => 8, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_lt"), u => 9, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_le"), u => 10, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_gt"), u => 11, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_ge"), u => 12, u =>
  nt_choose(U32, agy_str_eq(name, "u32_inc"), u => 13, u =>
  nt_choose(U32, agy_str_eq(name, "u32_shl"), u => 14, u =>
  nt_choose(U32, agy_str_eq(name, "u32_shr"), u => 15, u =>
  nt_choose(U32, agy_str_eq(name, "u32_shln"), u => 16, u =>
  nt_choose(U32, agy_str_eq(name, "u32_shrn"), u => 17, u =>
  nt_choose(U32, agy_str_eq(name, "u32_div"), u => 18, u =>
  nt_choose(U32, agy_str_eq(name, "u32_mod"), u => 19, u =>
  nt_choose(U32, agy_str_eq(name, "u32_not"), u => 20, u =>
  nt_choose(U32, agy_str_eq(name, "u32_is_zero"), u => 21, u =>
  nt_choose(U32, agy_str_eq(name, "u32_cmp"), u => 22, u =>
  nt_choose(U32, agy_str_eq(name, "u32_to_f32"), u => 23, u =>
  nt_choose(U32, agy_str_eq(name, "u32_to_nat"), u => 24, u =>
  nt_choose(U32, agy_str_eq(name, "u32_from_nat"), u => 25, u =>
  nt_choose(U32, agy_str_eq(name, "f32_add"), u => 26, u =>
  nt_choose(U32, agy_str_eq(name, "f32_sub"), u => 27, u =>
  nt_choose(U32, agy_str_eq(name, "f32_mul"), u => 28, u =>
  nt_choose(U32, agy_str_eq(name, "f32_div"), u => 29, u =>
  nt_choose(U32, agy_str_eq(name, "f32_is_eq"), u => 30, u =>
  nt_choose(U32, agy_str_eq(name, "f32_is_ne"), u => 31, u =>
  nt_choose(U32, agy_str_eq(name, "f32_is_lt"), u => 32, u =>
  nt_choose(U32, agy_str_eq(name, "f32_is_le"), u => 33, u =>
  nt_choose(U32, agy_str_eq(name, "f32_is_gt"), u => 34, u =>
  nt_choose(U32, agy_str_eq(name, "f32_is_ge"), u => 35, u =>
  nt_choose(U32, agy_str_eq(name, "f32_sqrt"), u => 36, u =>
  nt_choose(U32, agy_str_eq(name, "f32_exp"), u => 37, u =>
  nt_choose(U32, agy_str_eq(name, "f32_log"), u => 38, u =>
  nt_choose(U32, agy_str_eq(name, "f32_log2"), u => 39, u =>
  nt_choose(U32, agy_str_eq(name, "f32_log10"), u => 40, u =>
  nt_choose(U32, agy_str_eq(name, "f32_sin"), u => 41, u =>
  nt_choose(U32, agy_str_eq(name, "f32_cos"), u => 42, u =>
  nt_choose(U32, agy_str_eq(name, "f32_tan"), u => 43, u =>
  nt_choose(U32, agy_str_eq(name, "f32_asin"), u => 44, u =>
  nt_choose(U32, agy_str_eq(name, "f32_acos"), u => 45, u =>
  nt_choose(U32, agy_str_eq(name, "f32_atan"), u => 46, u =>
  nt_choose(U32, agy_str_eq(name, "f32_sinh"), u => 47, u =>
  nt_choose(U32, agy_str_eq(name, "f32_cosh"), u => 48, u =>
  nt_choose(U32, agy_str_eq(name, "f32_tanh"), u => 49, u =>
  nt_choose(U32, agy_str_eq(name, "f32_floor"), u => 50, u =>
  nt_choose(U32, agy_str_eq(name, "f32_ceil"), u => 51, u =>
  nt_choose(U32, agy_str_eq(name, "f32_trunc"), u => 52, u =>
  nt_choose(U32, agy_str_eq(name, "f32_abs"), u => 53, u =>
  nt_choose(U32, agy_str_eq(name, "f32_pow"), u => 54, u =>
  nt_choose(U32, agy_str_eq(name, "f32_atan2"), u => 55, u =>
  nt_choose(U32, agy_str_eq(name, "f32_mod"), u => 56, u =>
  nt_choose(U32, agy_str_eq(name, "f32_neg"), u => 57, u =>
  nt_choose(U32, agy_str_eq(name, "f32_to_u32"), u => 58, u =>
  nt_choose(U32, agy_str_eq(name, "f32_bits"), u => 59, u =>
  nt_choose(U32, agy_str_eq(name, "f32_show"), u => 60, u =>
  nt_choose(U32, agy_str_eq(name, "f32_read"), u => 61, u =>
  nt_choose(U32, agy_str_eq(name, "nat_add"), u => 62, u =>
  nt_choose(U32, agy_str_eq(name, "nat_sub"), u => 63, u =>
  nt_choose(U32, agy_str_eq(name, "nat_mul"), u => 64, u =>
  nt_choose(U32, agy_str_eq(name, "nat_double"), u => 65, u =>
  nt_choose(U32, agy_str_eq(name, "nat_cmp"), u => 66, u =>
  nt_choose(U32, agy_str_eq(name, "nat_is_lt"), u => 67, u =>
  nt_choose(U32, agy_str_eq(name, "bool_or"), u => 68, u =>
  nt_choose(U32, agy_str_eq(name, "bool_xor"), u => 69, u =>
  nt_choose(U32, agy_str_eq(name, "nat_divmod"), u => 70, u =>
  nt_choose(U32, agy_str_eq(name, "array_new"), u => 71, u =>
  nt_choose(U32, agy_str_eq(name, "array_get"), u => 72, u =>
  nt_choose(U32, agy_str_eq(name, "array_set"), u => 73, u =>
  nt_choose(U32, agy_str_eq(name, "array_swap"), u => 74, u =>
  nt_choose(U32, agy_str_eq(name, "array_size"), u => 75, u =>
  nt_choose(U32, agy_str_eq(name, "array_clone"), u => 76, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_add"), u => 77, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_min"), u => 78, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_max"), u => 79, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_and"), u => 80, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_or"), u => 81, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_xor"), u => 82, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_exch"), u => 83, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_cas"), u => 84, u =>
  nt_choose(U32, agy_str_eq(name, "array_atomic_fadd"), u => 85, u =>
    0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

# New primitive IDs append to the frozen 1..85 catalogue.
@unsafe
def p111_op_id(+name: String) -> U32:
  nt_choose(U32, agy_str_eq(name, "f32_from_nat"), u => 86, u => p111_op_id_prior(name))""",
        """@unsafe
def w5c2_opid_u2(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "u32_inc"), 13,
  w5c2_u32_pick(String.eq(k, "u32_shl"), 14,
  w5c2_u32_pick(String.eq(k, "u32_shr"), 15,
  w5c2_u32_pick(String.eq(k, "u32_shln"), 16,
  w5c2_u32_pick(String.eq(k, "u32_shrn"), 17,
  w5c2_u32_pick(String.eq(k, "u32_div"), 18,
  w5c2_u32_pick(String.eq(k, "u32_mod"), 19,
  w5c2_u32_pick(String.eq(k, "u32_not"), 20,
  w5c2_u32_pick(String.eq(k, "u32_is_zero"), 21,
  w5c2_u32_pick(String.eq(k, "u32_cmp"), 22,
  w5c2_u32_pick(String.eq(k, "u32_to_f32"), 23,
  w5c2_u32_pick(String.eq(k, "u32_to_nat"), 24,
  w5c2_u32_pick(String.eq(k, "u32_from_nat"), 25, 0)))))))))))))

@unsafe
def w5c2_opid_u(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "u32_add"), 1,
  w5c2_u32_pick(String.eq(k, "u32_sub"), 2,
  w5c2_u32_pick(String.eq(k, "u32_and"), 3,
  w5c2_u32_pick(String.eq(k, "u32_or"), 4,
  w5c2_u32_pick(String.eq(k, "u32_xor"), 5,
  w5c2_u32_pick(String.eq(k, "u32_mul"), 6,
  w5c2_u32_pick(String.eq(k, "u32_is_eq"), 7,
  w5c2_u32_pick(String.eq(k, "u32_is_ne"), 8,
  w5c2_u32_pick(String.eq(k, "u32_is_lt"), 9,
  w5c2_u32_pick(String.eq(k, "u32_is_le"), 10,
  w5c2_u32_pick(String.eq(k, "u32_is_gt"), 11,
  w5c2_u32_pick(String.eq(k, "u32_is_ge"), 12, w5c2_opid_u2(k)))))))))))))

@unsafe
def w5c2_opid_f3(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "f32_floor"), 50,
  w5c2_u32_pick(String.eq(k, "f32_ceil"), 51,
  w5c2_u32_pick(String.eq(k, "f32_trunc"), 52,
  w5c2_u32_pick(String.eq(k, "f32_abs"), 53,
  w5c2_u32_pick(String.eq(k, "f32_pow"), 54,
  w5c2_u32_pick(String.eq(k, "f32_atan2"), 55,
  w5c2_u32_pick(String.eq(k, "f32_mod"), 56,
  w5c2_u32_pick(String.eq(k, "f32_neg"), 57,
  w5c2_u32_pick(String.eq(k, "f32_to_u32"), 58,
  w5c2_u32_pick(String.eq(k, "f32_bits"), 59,
  w5c2_u32_pick(String.eq(k, "f32_show"), 60,
  w5c2_u32_pick(String.eq(k, "f32_read"), 61, 0))))))))))))

@unsafe
def w5c2_opid_f2(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "f32_sqrt"), 36,
  w5c2_u32_pick(String.eq(k, "f32_exp"), 37,
  w5c2_u32_pick(String.eq(k, "f32_log"), 38,
  w5c2_u32_pick(String.eq(k, "f32_log2"), 39,
  w5c2_u32_pick(String.eq(k, "f32_log10"), 40,
  w5c2_u32_pick(String.eq(k, "f32_sin"), 41,
  w5c2_u32_pick(String.eq(k, "f32_cos"), 42,
  w5c2_u32_pick(String.eq(k, "f32_tan"), 43,
  w5c2_u32_pick(String.eq(k, "f32_asin"), 44,
  w5c2_u32_pick(String.eq(k, "f32_acos"), 45,
  w5c2_u32_pick(String.eq(k, "f32_atan"), 46,
  w5c2_u32_pick(String.eq(k, "f32_sinh"), 47,
  w5c2_u32_pick(String.eq(k, "f32_cosh"), 48,
  w5c2_u32_pick(String.eq(k, "f32_tanh"), 49, w5c2_opid_f3(k)))))))))))))))

@unsafe
def w5c2_opid_f(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "f32_add"), 26,
  w5c2_u32_pick(String.eq(k, "f32_sub"), 27,
  w5c2_u32_pick(String.eq(k, "f32_mul"), 28,
  w5c2_u32_pick(String.eq(k, "f32_div"), 29,
  w5c2_u32_pick(String.eq(k, "f32_is_eq"), 30,
  w5c2_u32_pick(String.eq(k, "f32_is_ne"), 31,
  w5c2_u32_pick(String.eq(k, "f32_is_lt"), 32,
  w5c2_u32_pick(String.eq(k, "f32_is_le"), 33,
  w5c2_u32_pick(String.eq(k, "f32_is_gt"), 34,
  w5c2_u32_pick(String.eq(k, "f32_is_ge"), 35, w5c2_opid_f2(k)))))))))))

@unsafe
def w5c2_opid_n(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "nat_add"), 62,
  w5c2_u32_pick(String.eq(k, "nat_sub"), 63,
  w5c2_u32_pick(String.eq(k, "nat_mul"), 64,
  w5c2_u32_pick(String.eq(k, "nat_double"), 65,
  w5c2_u32_pick(String.eq(k, "nat_cmp"), 66,
  w5c2_u32_pick(String.eq(k, "nat_is_lt"), 67,
  w5c2_u32_pick(String.eq(k, "nat_divmod"), 70, 0)))))))

@unsafe
def w5c2_opid_a(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "array_new"), 71,
  w5c2_u32_pick(String.eq(k, "array_get"), 72,
  w5c2_u32_pick(String.eq(k, "array_set"), 73,
  w5c2_u32_pick(String.eq(k, "array_swap"), 74,
  w5c2_u32_pick(String.eq(k, "array_size"), 75,
  w5c2_u32_pick(String.eq(k, "array_clone"), 76,
  w5c2_u32_pick(String.eq(k, "array_atomic_add"), 77,
  w5c2_u32_pick(String.eq(k, "array_atomic_min"), 78,
  w5c2_u32_pick(String.eq(k, "array_atomic_max"), 79,
  w5c2_u32_pick(String.eq(k, "array_atomic_and"), 80,
  w5c2_u32_pick(String.eq(k, "array_atomic_or"), 81,
  w5c2_u32_pick(String.eq(k, "array_atomic_xor"), 82,
  w5c2_u32_pick(String.eq(k, "array_atomic_exch"), 83,
  w5c2_u32_pick(String.eq(k, "array_atomic_cas"), 84,
  w5c2_u32_pick(String.eq(k, "array_atomic_fadd"), 85, 0)))))))))))))))

@unsafe
def w5c2_opid_b(ok: Bool, +k: String) -> U32:
  match ok:
    case True{}: w5c2_u32_pick(String.eq(k, "bool_or"), 68, w5c2_u32_pick(String.eq(k, "bool_xor"), 69, 0))
    case False{}: 0

@unsafe
def w5c2_opid_da(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_a(k)
    case False{}: w5c2_opid_b(U32.is_eq(c, 98), k)

@unsafe
def w5c2_opid_dn(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_n(k)
    case False{}: w5c2_opid_da(U32.is_eq(c, 97), c, k)

@unsafe
def w5c2_opid_df(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_f(k)
    case False{}: w5c2_opid_dn(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_opid_du(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_u(k)
    case False{}: w5c2_opid_df(U32.is_eq(c, 102), c, k)

@unsafe
def p111_op_id_prior(+name: String) -> U32:
  match name:
    case SNil{}: 0
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_opid_du(U32.is_eq(c, 117), c, name)

# New primitive IDs append to the frozen 1..85 catalogue.
@unsafe
def w5c2_opid_fn(ok: Bool, +name: String) -> U32:
  match ok:
    case True{}: 86
    case False{}: p111_op_id_prior(name)

@unsafe
def p111_op_id(+name: String) -> U32:
  w5c2_opid_fn(String.eq(name, "f32_from_nat"), name)""",
        "fast_p111_op_id",
    )

    # =========================================================================
    # 15. p111_partition_step & p111_keep Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p111_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P111Partition) -> P111Partition:
  match parts:
    case P111Partition{+live, +drop}:
      nt_choose(P111Partition, used, u => P111Partition{Con{NC_Binding{id, word, kind}, live}, drop}, u => nt_choose(P111Partition, p112to_nonowning(kind), v => P111Partition{live, drop}, v => P111Partition{live, Con{N111Call{"ignored", N111U64{}, "p111_rt_sink", [p111_state(), p111_word(N111Local{word})]}, drop}}))

@unsafe
def p111_partition(env: List<&2, NC_Binding>, +uses: NU_Set) -> P111Partition:
  match env:
    case Nil{}: P111Partition{Nil{}, Nil{}}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: p111_partition_step(id, word, kind, nc_uses_has(uses, id), p111_partition(rest, uses))

@unsafe
def p111_keep(env: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, N111Stmt>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, nc_uses_has(uses, id) && Bool.not(p112to_nonowning(kind)), u => Con{N111Call{word, N111U64{}, "p111_rt_keep", [p111_state(), p111_word(N111Local{word})]}, p111_keep(rest, uses)}, u => p111_keep(rest, uses))""",
        """@unsafe
def w5c2_part_nonown(no: Bool, +word: String, +live: List<&2, NC_Binding>, +drop: List<&2, N111Stmt>) -> P111Partition:
  match no:
    case True{}: P111Partition{live, drop}
    case False{}: P111Partition{live, Con{N111Call{"ignored", N111U64{}, "p111_rt_sink", [p111_state(), p111_word(N111Local{word})]}, drop}}

@unsafe
def w5c2_part_used(used: Bool, +id: U32, +word: String, +kind: N_WordKind, +live: List<&2, NC_Binding>, +drop: List<&2, N111Stmt>) -> P111Partition:
  match used:
    case True{}: P111Partition{Con{NC_Binding{id, word, kind}, live}, drop}
    case False{}: w5c2_part_nonown(p112to_nonowning(kind), word, live, drop)

@unsafe
def p111_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P111Partition) -> P111Partition:
  match parts:
    case P111Partition{+live, +drop}:
      w5c2_part_used(used, id, word, kind, live, drop)

@unsafe
def p111_partition(env: List<&2, NC_Binding>, +uses: NU_Set) -> P111Partition:
  match env:
    case Nil{}: P111Partition{Nil{}, Nil{}}
    case Con{NC_Binding{+id, +word, +kind}, rest}: p111_partition_step(id, word, kind, nu_has(uses, id), p111_partition(rest, uses))

law p111_keep:
  for env: List<&2, NC_Binding>
  for +uses: NU_Set
  List<&2, N111Stmt>

@unsafe
def w5c2_p111_keep_if(keep: Bool, +word: String, rest: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, N111Stmt>:
  match keep:
    case True{}: Con{N111Call{word, N111U64{}, "p111_rt_keep", [p111_state(), p111_word(N111Local{word})]}, p111_keep(rest, uses)}
    case False{}: p111_keep(rest, uses)

@unsafe
def p111_keep(env, uses):
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, rest}:
      w5c2_p111_keep_if(nu_has(uses, id) && Bool.not(p112to_nonowning(kind)), word, rest, uses)""",
        "fast_p111_partition_keep",
    )

    # =========================================================================
    # 16. p112f_name Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  nt_choose(String,agy_str_eq(name,"state"),u => name,u =>
    nt_choose(String,String.starts_with(prefix,"p113i_") && String.starts_with(name,"p113i_"),
      v => prefix ++ String.drop(name,6n),
      v => prefix ++ "local_" ++ name))""",
        """@unsafe
def w5c2_p112f_p113i(both: Bool, +prefix: String, +name: String) -> String:
  match both:
    case True{}: prefix ++ String.drop(name, 6n)
    case False{}: prefix ++ "local_" ++ name

@unsafe
def w5c2_p112f_state(is_st: Bool, +prefix: String, +name: String) -> String:
  match is_st:
    case True{}: name
    case False{}: w5c2_p112f_p113i(String.starts_with(prefix, "p113i_") && String.starts_with(name, "p113i_"), prefix, name)

@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  w5c2_p112f_state(String.eq(name, "state"), prefix, name)""",
        "fast_p112f_name",
    )

    # =========================================================================
    # 17. p113k_bin_stmt, p113k_body_next, p113k_body_if Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"mul") || agy_str_eq(op,"and")) && (p113k_zero(lf) || p113k_zero(rf)),
        u => N111Set{name,typ,N111Const{0,0}},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"shl") || agy_str_eq(op,"shr")) && p113k_zero(lf),
        u => N111Set{name,typ,N111Const{0,0}},u =>
      nt_choose(N111Stmt,U32.is_eq(p111v_type(typ),1) && ((agy_str_eq(op,"eq") && p113l_exact_one(rf)) || (agy_str_eq(op,"ne") && p113k_zero(rf))) && U32.is_le(p113k_bits_of(lf),1),
        u => N111Set{name,N111U32{},left},u =>
      nt_choose(N111Stmt,U32.is_eq(p111v_type(typ),1) && ((agy_str_eq(op,"eq") && p113l_exact_one(lf)) || (agy_str_eq(op,"ne") && p113k_zero(lf))) && U32.is_le(p113k_bits_of(rf),1),
        u => N111Set{name,N111U32{},right},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"shl") || agy_str_eq(op,"shr")) && p113k_zero(rf)) ||
          (agy_str_eq(op,"mul") && p113l_exact_one(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(agy_str_eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"add")) && p113k_zero(lf)) ||
          (agy_str_eq(op,"mul") && p113l_exact_one(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right})))))))""",
        """@unsafe
def w5c2_bs_7(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, typ, right}
    case False{}: N111Bin{name, typ, op, left, right}

@unsafe
def w5c2_bs_6(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, typ, left}
    case False{}:
      w5c2_bs_7(
        (String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
        ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(lf)) ||
        (String.eq(op,"mul") && p113l_exact_one(lf)),
        name, typ, op, left, right)

@unsafe
def w5c2_bs_5(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, N111U32{}, right}
    case False{}:
      w5c2_bs_6(
        (String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
        ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"shl") || String.eq(op,"shr")) && p113k_zero(rf)) ||
        (String.eq(op,"mul") && p113l_exact_one(rf)),
        name, typ, op, left, right, lf, rf)

@unsafe
def w5c2_bs_4(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, N111U32{}, left}
    case False{}:
      w5c2_bs_5(
        U32.is_eq(p111v_type(typ),1) && ((String.eq(op,"eq") && p113l_exact_one(lf)) || (String.eq(op,"ne") && p113k_zero(lf))) && U32.is_le(p113k_bits_of(rf),1),
        name, typ, op, left, right, lf, rf)

@unsafe
def w5c2_bs_2(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, typ, N111Const{0, 0}}
    case False{}:
      w5c2_bs_4(
        U32.is_eq(p111v_type(typ),1) && ((String.eq(op,"eq") && p113l_exact_one(rf)) || (String.eq(op,"ne") && p113k_zero(rf))) && U32.is_le(p113k_bits_of(lf),1),
        name, typ, op, left, right, lf, rf)

@unsafe
def w5c2_bs_1(exact: Bool, +lo: U32, +hi: U32, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match exact:
    case True{}: N111Set{name, p113k_result_type(typ, op), N111Const{lo, hi}}
    case False{}:
      w5c2_bs_2(
        ((String.eq(op,"mul") || String.eq(op,"and")) && (p113k_zero(lf) || p113k_zero(rf))) ||
        ((String.eq(op,"shl") || String.eq(op,"shr")) && p113k_zero(lf)),
        name, typ, op, left, right, lf, rf)

@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{_, exact, +lo, +hi}:
      w5c2_bs_1(exact, lo, hi, name, typ, op, left, right, lf, rf)""",
        "fast_p113k_bin_stmt",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_body_next(+result: P113KBody, +rest: List<&2,P113DStmt>) -> P113KBody:
  match result:
    case P113KBody{+body,+facts,+terminal}:
      nt_choose(P113KBody,terminal,u => result,u => p113k_body_append(body,p113k_body(rest,facts)))""",
        """@unsafe
def w5c2_body_next_if(term: Bool, +result: P113KBody, +body: List<&2,P113DStmt>, +facts: KDef, +rest: List<&2,P113DStmt>) -> P113KBody:
  match term:
    case True{}: result
    case False{}: p113k_body_append(body, p113k_body(rest, facts))

@unsafe
def p113k_body_next(+result: P113KBody, +rest: List<&2,P113DStmt>) -> P113KBody:
  match result:
    case P113KBody{+body, +facts, terminal}:
      w5c2_body_next_if(terminal, result, body, facts, rest)""",
        "fast_p113k_body_next",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{+bits,+exact,+lo,hi}:
      nt_choose(P113KBody,exact,
        u => nt_choose(P113KBody,U32.is_eq(lo,0),v => p113k_body(no,facts),v => p113k_body(yes,facts)),
        u => w4k_body_join_opt(condition,facts,bits,p113k_body(yes,p113l_assume(facts,condition,True{})),p113k_body(no,p113l_assume(facts,condition,False{}))))""",
        """@unsafe
def w5c2_body_if_lo(lo0: Bool, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef) -> P113KBody:
  match lo0:
    case True{}: p113k_body(no, facts)
    case False{}: p113k_body(yes, facts)

@unsafe
def w5c2_body_if_ex(exact: Bool, +bits: U32, +lo: U32, +condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef) -> P113KBody:
  match exact:
    case True{}: w5c2_body_if_lo(U32.is_eq(lo, 0), yes, no, facts)
    case False{}: w4k_body_join_opt(condition, facts, bits, p113k_body(yes, p113l_assume(facts, condition, True{})), p113k_body(no, p113l_assume(facts, condition, False{})))

@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{+bits, exact, +lo, _}:
      w5c2_body_if_ex(exact, bits, lo, condition, yes, no, facts)""",
        "fast_p113k_body_if",
    )

    # =========================================================================
    # 18. p113pl_lower & p113pl_live Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p113pl_lower(book,t,env,target,n):
  nt_choose(P113DCode,agy_str_eq(tg(t),"Let") || agy_str_eq(tg(t),"NSeqLet"),
    u => p113px_lower(book,p112_liveness_terms(ks(t)),env,target,n),
    u => p113px_other(book,t,env,target,n))""",
        """@unsafe
def w5c2_pl_lower_if(is_let: Bool, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match is_let:
    case True{}: p113px_lower(book, p112_liveness_terms(ks(t)), env, target, n)
    case False{}: p113px_other(book, t, env, target, n)

@unsafe
def p113pl_lower(book,t,env,target,n):
  +tag = tg(t)
  w5c2_pl_lower_if(String.eq(tag, "Let") || String.eq(tag, "NSeqLet"), book, t, env, target, n)""",
        "fast_p113pl_lower",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113pl_live(book,t,env,target,n):
  nt_choose(P113DCode,agy_str_eq(tg(t),"NTRCons"),u => p118t_extend(t,env,target,n),
    u => p118t_original_live(book,t,env,target,n))""",
        """@unsafe
def w5c2_pl_live_if(is_ntr: Bool, +book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match is_ntr:
    case True{}: p118t_extend(t, env, target, n)
    case False{}: p118t_original_live(book, t, env, target, n)

@unsafe
def p113pl_live(book,t,env,target,n):
  w5c2_pl_live_if(p98_tag_eq(t, "NTRCons"), book, t, env, target, n)""",
        "fast_p113pl_live",
    )

    # =========================================================================
    # 19. p123p_test / p123p_pick / p123p_bin Closure & Non-Eq/Ne Fast-Guard Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p123p_test(+op: String, value: N111Value, constant: N111Value, +facts: KDef) -> KDef:
  match value constant:
    case N111Local{source} N111Const{+lo,+hi}:
      nt_choose(KDef,(agy_str_eq(op,"eq") || agy_str_eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1),
        u => p123p_test_origin(op,lo,p123p_get(facts,source)),u => missing())
    case _ _: missing()


@unsafe
def p123p_pick(+op: String, +left: N111Value, +right: N111Value, +facts: KDef) -> KDef:
  +forward = p123p_test(op,left,right,facts)
  nt_choose(KDef,agy_str_eq(dk(forward),"P123Test"),u => forward,u => p123p_test(op,right,left,facts))


@unsafe
def p123p_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  nt_choose(P113KScalar,agy_str_eq(dk(record),"P123Test"),
    u => P113KScalar{[nt_choose(N111Stmt,U32.is_eq(da(record),0),
      v => N111Set{name,N111U32{},N111Local{nm(dv(record))}},
      v => N111Bin{name,N111U32{},"xor",N111Local{nm(dv(record))},N111Const{1,0}})],
      p113k_put(facts,name,p113k_bin_fact(typ,op,lf,rf))},
    u => p123p_old_bin(name,typ,op,left,right,facts,lf,rf))""",
        """@unsafe
def w5c2_p123p_test_if(ok: Bool, +op: String, +lo: U32, +facts: KDef, +source: String) -> KDef:
  match ok:
    case True{}: p123p_test_origin(op, lo, p123p_get(facts, source))
    case False{}: missing()

@unsafe
def p123p_test(+op: String, value: N111Value, constant: N111Value, +facts: KDef) -> KDef:
  match value constant:
    case N111Local{source} N111Const{+lo,+hi}:
      w5c2_p123p_test_if((String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1), op, lo, facts, source)
    case _ _: missing()

@unsafe
def w5c2_p123p_pick_fwd(hit: Bool, +forward: KDef, +op: String, +right: N111Value, +left: N111Value, +facts: KDef) -> KDef:
  match hit:
    case True{}: forward
    case False{}: p123p_test(op, right, left, facts)

@unsafe
def w5c2_p123p_pick_eq(is_eqne: Bool, +op: String, +left: N111Value, +right: N111Value, +facts: KDef) -> KDef:
  match is_eqne:
    case False{}: missing()
    case True{}:
      +forward = p123p_test(op, left, right, facts)
      w5c2_p123p_pick_fwd(String.eq(dk(forward), "P123Test"), forward, op, right, left, facts)

@unsafe
def p123p_pick(+op: String, +left: N111Value, +right: N111Value, +facts: KDef) -> KDef:
  w5c2_p123p_pick_eq(String.eq(op, "eq") || String.eq(op, "ne"), op, left, right, facts)

@unsafe
def w5c2_p123p_bin_stmt(is0: Bool, +name: String, +vname: String) -> N111Stmt:
  match is0:
    case True{}: N111Set{name, N111U32{}, N111Local{vname}}
    case False{}: N111Bin{name, N111U32{}, "xor", N111Local{vname}, N111Const{1, 0}}

@unsafe
def w5c2_p123p_bin_if(hit: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  match hit:
    case True{}:
      P113KScalar{[w5c2_p123p_bin_stmt(U32.is_eq(da(record), 0), name, nm(dv(record)))],
        p113k_put(facts, name, p113k_bin_fact(typ, op, lf, rf))}
    case False{}: p123p_old_bin(name, typ, op, left, right, facts, lf, rf)

@unsafe
def p123p_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  w5c2_p123p_bin_if(String.eq(dk(record), "P123Test"), name, typ, op, left, right, facts, lf, rf, record)""",
        "fast_p123p",
    )

    # =========================================================================
    # 20. p126dp_value_shape Closure Killer
    # =========================================================================
    src = replace_exact(
        src,
        """@unsafe
def p126dp_value_shape(+book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(value),"NOp") && U32.is_eq(p111_op_id(nm(value)),70) && U32.is_eq(terms_len(ks(value)),2),
    u => kt("NQShape","Tuple",2,0,[]),
    u => nt_choose(KTerm,agy_str_eq(tg(value),"App"),
      v => nt_choose(KTerm,U32.is_eq(p111_op_id(nd_native_call(book,value)),70),
        w => kt("NQShape","Tuple",2,0,[]),w => nq_value_shape(book,value,target)),
      v => nq_value_shape(book,value,target)))""",
        """@unsafe
def w5c2_p126dp_tup(ok: Bool, +book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  match ok:
    case True{}: kt("NQShape", "Tuple", 2, 0, [])
    case False{}: nq_value_shape(book, value, target)

@unsafe
def w5c2_p126dp_app(is_app: Bool, +book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  match is_app:
    case True{}: w5c2_p126dp_tup(String.eq(nd_native_call(book, value), "nat_divmod"), book, value, target)
    case False{}: nq_value_shape(book, value, target)

@unsafe
def w5c2_p126dp_nop(is_divmod: Bool, +tag: String, +book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  match is_divmod:
    case True{}: kt("NQShape", "Tuple", 2, 0, [])
    case False{}: w5c2_p126dp_app(String.eq(tag, "App"), book, value, target)

@unsafe
def p126dp_value_shape(+book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  +tag = tg(value)
  w5c2_p126dp_nop(String.eq(tag, "NOp") && String.eq(nm(value), "nat_divmod") && U32.is_eq(terms_len(ks(value)), 2), tag, book, value, target)""",
        "fast_p126dp_value_shape",
    )

    return src


def main():
    ap = argparse.ArgumentParser(description="Wave 5B W5B-C2 Frontend/IR/Lowering & Closure Killer")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src = args.src.read_text()
    out = apply_patches(src)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(f"W5B-C2 patched: {args.dst} ({len(out)} bytes, delta={len(out)-len(src):+d} bytes)")


if __name__ == "__main__":
    main()
