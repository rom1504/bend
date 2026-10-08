# Select exactly one immutable template; unknown names have no template.
# Empty primitive names are common identity misses and cannot match this catalog.
@unsafe
def ni_template(+k: String) -> String:
  nt_choose(String, String.is_empty(k), u => "", u =>
    nt_choose(String, String.eq(k, "u32_add"), u => "U32_BIN($0, +, $1)", u =>
    nt_choose(String, String.eq(k, "u32_sub"), u => "U32_BIN($0, -, $1)", u =>
    nt_choose(String, String.eq(k, "u32_and"), u => "U32_BIN($0, &, $1)", u =>
    nt_choose(String, String.eq(k, "u32_or"), u => "U32_BIN($0, |, $1)", u =>
    nt_choose(String, String.eq(k, "u32_xor"), u => "U32_BIN($0, ^, $1)", u =>
    nt_choose(String, String.eq(k, "u32_mul"), u => "U32_BIN($0, *, $1)", u =>
    nt_choose(String, String.eq(k, "u32_is_eq"), u => "U32_BIN($0, ==, $1)", u =>
    nt_choose(String, String.eq(k, "u32_is_ne"), u => "U32_BIN($0, !=, $1)", u =>
    nt_choose(String, String.eq(k, "u32_is_lt"), u => "U32_BIN($0, <, $1)", u =>
    nt_choose(String, String.eq(k, "u32_is_le"), u => "U32_BIN($0, <=, $1)", u =>
    nt_choose(String, String.eq(k, "u32_is_gt"), u => "U32_BIN($0, >, $1)", u =>
    nt_choose(String, String.eq(k, "u32_is_ge"), u => "U32_BIN($0, >=, $1)", u =>
    nt_choose(String, String.eq(k, "u32_inc"), u => "U32_BIN($0, +, 1)", u =>
    nt_choose(String, String.eq(k, "u32_shl"), u => "U32_BIN($0, <<, 1)", u =>
    nt_choose(String, String.eq(k, "u32_shr"), u => "U32_BIN($0, >>, 1)", u =>
    nt_choose(String, String.eq(k, "u32_shln"), u => "($1 >= 32 ? 0 : U32_BIN($0, <<, $1))", u =>
    nt_choose(String, String.eq(k, "u32_shrn"), u => "($1 >= 32 ? 0 : U32_BIN($0, >>, $1))", u =>
    nt_choose(String, String.eq(k, "u32_div"), u => "((u32)($1) == 0 ? 0 : (u64)U32_QUO((u32)($0), (u32)($1)))", u =>
    nt_choose(String, String.eq(k, "u32_mod"), u => "((u32)($1) == 0 ? $0 : U32_BIN($0, -, U32_QUO((u32)($0), (u32)($1)) * $1))", u =>
    nt_choose(String, String.eq(k, "u32_not"), u => "((u64)~(u32)($0))", u =>
    nt_choose(String, String.eq(k, "u32_is_zero"), u => "U32_BIN($0, ==, 0)", u =>
    nt_choose(String, String.eq(k, "u32_cmp"), u => "(U32_BIN($0, >, $1) + U32_BIN($0, >=, $1))", u =>
    nt_choose(String, String.eq(k, "u32_to_f32"), u => "f32_rewrap((f32)(u32)($0))", u =>
    nt_choose(String, String.eq(k, "u32_to_nat"), u => "((u64)$0)", u =>
    nt_choose(String, String.eq(k, "u32_from_nat"), u => "((u64)(u32)($0))", u =>
    nt_choose(String, String.eq(k, "f32_add"), u => "f32_rewrap(f32_unbox($0) + f32_unbox($1))", u =>
    nt_choose(String, String.eq(k, "f32_sub"), u => "f32_rewrap(f32_unbox($0) - f32_unbox($1))", u =>
    nt_choose(String, String.eq(k, "f32_mul"), u => "f32_rewrap(f32_unbox($0) * f32_unbox($1))", u =>
    nt_choose(String, String.eq(k, "f32_div"), u => "f32_rewrap(f32_unbox($0) / f32_unbox($1))", u =>
    nt_choose(String, String.eq(k, "f32_is_eq"), u => "((u64)(f32_unbox($0) == f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_is_ne"), u => "((u64)(f32_unbox($0) != f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_is_lt"), u => "((u64)(f32_unbox($0) < f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_is_le"), u => "((u64)(f32_unbox($0) <= f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_is_gt"), u => "((u64)(f32_unbox($0) > f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_is_ge"), u => "((u64)(f32_unbox($0) >= f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_sqrt"), u => "f32_rewrap((f32)sqrt(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_exp"), u => "f32_rewrap((f32)exp(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_log"), u => "f32_rewrap((f32)log(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_log2"), u => "f32_rewrap((f32)log2(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_log10"), u => "f32_rewrap((f32)log10(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_sin"), u => "f32_rewrap((f32)sin(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_cos"), u => "f32_rewrap((f32)cos(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_tan"), u => "f32_rewrap((f32)tan(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_asin"), u => "f32_rewrap((f32)asin(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_acos"), u => "f32_rewrap((f32)acos(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_atan"), u => "f32_rewrap((f32)atan(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_sinh"), u => "f32_rewrap((f32)sinh(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_cosh"), u => "f32_rewrap((f32)cosh(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_tanh"), u => "f32_rewrap((f32)tanh(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_floor"), u => "f32_rewrap((f32)floor(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_ceil"), u => "f32_rewrap((f32)ceil(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_trunc"), u => "f32_rewrap((f32)trunc(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_abs"), u => "f32_rewrap((f32)fabs(f32_unbox($0)))", u =>
    nt_choose(String, String.eq(k, "f32_pow"), u => "f32_rewrap((f32)pow(f32_unbox($0), f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_atan2"), u => "f32_rewrap((f32)atan2(f32_unbox($0), f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_mod"), u => "f32_rewrap((f32)fmod(f32_unbox($0), f32_unbox($1)))", u =>
    nt_choose(String, String.eq(k, "f32_neg"), u => "f32_rewrap(-f32_unbox($0))", u =>
    nt_choose(String, String.eq(k, "f32_to_u32"), u => "f32_to_u32($0)", u =>
    nt_choose(String, String.eq(k, "f32_bits"), u => "$0", u =>
    nt_choose(String, String.eq(k, "f32_show"), u => "f32_show(e, $0)", u =>
    nt_choose(String, String.eq(k, "f32_read"), u => "f32_read(e, $0)", u =>
    nt_choose(String, String.eq(k, "nat_add"), u => "nat_chk(e, $0 + $1)", u =>
    nt_choose(String, String.eq(k, "nat_sub"), u => "($0 < $1 ? 0 : $0 - $1)", u =>
    nt_choose(String, String.eq(k, "nat_mul"), u => "nat_mul(e, $0, $1)", u =>
    nt_choose(String, String.eq(k, "nat_double"), u => "nat_chk(e, $0 + $0)", u =>
    nt_choose(String, String.eq(k, "nat_cmp"), u => "(($0 > $1) + ($0 >= $1))", u =>
    nt_choose(String, String.eq(k, "nat_is_lt"), u => "($0 < $1)", u =>
    nt_choose(String, String.eq(k, "bool_or"), u => "(native_bool($0) | native_bool($1))", u =>
    nt_choose(String, String.eq(k, "bool_xor"), u => "(native_bool($0) ^ native_bool($1))", u =>
      ""))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

@unsafe
def ni_replace_all(+s: String, +key: String, +value: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, +t}:
      nt_choose(String, String.starts_with(s, key), u => value ++ ni_replace_all(String.drop(s, String.length(key)), key, value), u => SCon{h, ni_replace_all(t, key, value)})

@unsafe
def ni_fill(+s: String, xs: List<&2, String>, +i: U32) -> String:
  match xs:
    case Nil{}: s
    case Con{h, t}: ni_fill(ni_replace_all(s, "$" ++ U32.show(i), h), t, U32.inc(i))

@unsafe
def ni_emit(k: String, xs: List<&2, String>) -> String:
  ni_fill(ni_template(k), xs, 0)
