# Direct JS intrinsic templates ported from comp.ts OPERATIONS at fixed upstream
# 018751270e800bc222a93dad7f257083ee53a5f7. Reference source is unchanged.
# Only exact checked Def/native identities qualify; same-named source functions
# keep ordinary bodies. All args are LIVE inert locals/literals supplied by core:
# it evaluates each source actual once, left-to-right, before this expression.
# Runtime names belong to standalone runtime/js/direct.mjs, never generic G.

type JDPrimitive is Data:
  JDPrimitive{+name: String, +arity: U32, +code: String}

@unsafe
def jd_intrinsic(+book: List<&2,KDef>, +name: String, +args: List<&2,String>) -> String:
  kc(String, String.eq(name, "String.eq"), u => "",
    u => jd_primitive_candidate_emit(book, lookup(book, name), args))

@unsafe
def jd_primitive_candidate_emit(+book: List<&2,KDef>, +d: KDef,
  +args: List<&2,String>) -> String:
  kc(String, jd_primitive_candidate(d),
    u => jd_primitive_emit(book, d, args,
      jd_primitive_select(dn(d))), u => "")

@unsafe
def jd_native_known(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, jd_primitive_candidate(d),
    u => jd_primitive_admit(book, d, jd_primitive_select(dn(d))),
    u => False{})

@unsafe
def jd_primitive_candidate(+d: KDef) -> Bool:
  String.eq(dk(d), "Def") && db(d) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign"))

# The ordinary backend stops at more source functions because it supplies G
# implementations for IO and extra String helpers. Direct mode must collect
# those original bodies instead. Only actually supported native templates stop.
@unsafe
def jd_stops(+book: List<&2,KDef>) -> List<&2,String>:
  jd_primitive_stops(book, book)

@unsafe
def jd_primitive_stops(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,String>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,String>, jd_native_known(book, d),
        u => Con{dn(d), jd_primitive_stops(book, rest)},
        u => jd_primitive_stops(book, rest))

@unsafe
def jd_primitive_emit(+book: List<&2,KDef>, +d: KDef,
  +args: List<&2,String>, +p: JDPrimitive) -> String:
  match p:
    case JDPrimitive{name, arity, code}:
      kc(String, U32.is_eq(jd_primitive_arg_count(args), arity) &&
        jd_primitive_admit(book, d, p),
        u => jd_primitive_template(code, args), u => "")

@unsafe
def jd_primitive_admit(+book: List<&2,KDef>, +d: KDef, +p: JDPrimitive) -> Bool:
  match p:
    case JDPrimitive{name, arity, code}:
      kc(Bool, Bool.not(String.eq(name, "")) && String.eq(name, dn(d)) &&
        String.eq(dk(d), "Def") && db(d) && U32.is_eq(dx(d), 0) &&
        Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")),
        u => jd_primitive_telescope(book, dt(d), arity, 64), u => False{})

# Erased source telescope binders do not consume primitive arguments. Counting
# is bounded and fail-closed; this is native identity admission, not name inference.
@unsafe
def jd_primitive_telescope(+book: List<&2,KDef>, +ty: KTerm,
  +left: U32, +fuel: U32) -> Bool:
  kc(Bool, U32.is_gt(fuel, 0),
    u => jd_primitive_telescope_head(book, wnf(book, ty), left, U32.sub(fuel, 1)),
    u => False{})

@unsafe
def jd_primitive_telescope_head(+book: List<&2,KDef>, +ty: KTerm,
  +left: U32, +fuel: U32) -> Bool:
  kc(Bool, String.eq(tg(ty), "All"),
    u => kc(Bool, U32.is_eq(qt(ty), 0),
      u => jd_primitive_telescope(book, kid(ty, 1), left, fuel),
      u => kc(Bool, U32.is_gt(left, 0),
        u => jd_primitive_telescope(book, kid(ty, 1), U32.sub(left, 1), fuel),
        u => False{})), u => U32.is_eq(left, 0))

@unsafe
def jd_primitive_arg_count(+args: List<&2,String>) -> U32:
  match args:
    case Nil{}: 0
    case Con{h, rest}: U32.inc(jd_primitive_arg_count(rest))

@unsafe
def jd_primitive_find(+name: String, +rows: List<&2,JDPrimitive>) -> JDPrimitive:
  match rows:
    case Nil{}: JDPrimitive{"", 0, ""}
    case Con{h, rest}: jd_primitive_find_row(name, h, rest)

@unsafe
def jd_primitive_find_row(+name: String, +p: JDPrimitive,
  +rest: List<&2,JDPrimitive>) -> JDPrimitive:
  match p:
    case JDPrimitive{key, arity, code}:
      kc(JDPrimitive, String.eq(name, key), u => p,
        u => jd_primitive_find(name, rest))

@unsafe
def jd_primitive_arg(+args: List<&2,String>, +at: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, U32.is_eq(at, 0), u => h,
        u => jd_primitive_arg(rest, U32.sub(at, 1)))

# Substitute only the exact upstream $0..$3 markers; object "$" tags stay literal.
@unsafe
def jd_primitive_template(+text: String, +args: List<&2,String>) -> String:
  match text:
    case SNil{}: ""
    case SCon{h, rest}:
      kc(String, Char.is_eq(h, '$'),
        u => jd_primitive_placeholder(rest, args),
        u => SCon{h, jd_primitive_template(rest, args)})

@unsafe
def jd_primitive_placeholder(+text: String, +args: List<&2,String>) -> String:
  match text:
    case SNil{}: "$"
    case SCon{h, rest}:
      kc(String, Char.is_eq(h, '0'),
        u => jd_primitive_arg(args, 0) ++ jd_primitive_template(rest, args), u =>
      kc(String, Char.is_eq(h, '1'),
        u => jd_primitive_arg(args, 1) ++ jd_primitive_template(rest, args), u =>
      kc(String, Char.is_eq(h, '2'),
        u => jd_primitive_arg(args, 2) ++ jd_primitive_template(rest, args), u =>
      kc(String, Char.is_eq(h, '3'),
        u => jd_primitive_arg(args, 3) ++ jd_primitive_template(rest, args),
        u => "$" ++ jd_primitive_template(text, args)))))

@unsafe
def jd_primitive_table() -> List<&2,JDPrimitive>:
  [
    JDPrimitive{"U32.add", 2, "(($0 + $1) >>> 0)"},
    JDPrimitive{"U32.sub", 2, "(($0 - $1) >>> 0)"},
    JDPrimitive{"U32.and", 2, "(($0 & $1) >>> 0)"},
    JDPrimitive{"U32.or", 2, "(($0 | $1) >>> 0)"},
    JDPrimitive{"U32.xor", 2, "(($0 ^ $1) >>> 0)"},
    JDPrimitive{"U32.is_eq", 2, "($0 === $1)"},
    JDPrimitive{"U32.is_ne", 2, "($0 !== $1)"},
    JDPrimitive{"U32.is_lt", 2, "($0 < $1)"},
    JDPrimitive{"U32.is_le", 2, "($0 <= $1)"},
    JDPrimitive{"U32.is_gt", 2, "($0 > $1)"},
    JDPrimitive{"U32.is_ge", 2, "($0 >= $1)"},
    JDPrimitive{"U32.mul", 2, "(Math.imul($0, $1) >>> 0)"},
    JDPrimitive{"U32.div", 2, "($1 === 0 ? 0 : ($0 / $1) >>> 0)"},
    JDPrimitive{"U32.mod", 2, "($1 === 0 ? $0 : $0 % $1)"},
    JDPrimitive{"U32.inc", 1, "(($0 + 1) >>> 0)"},
    JDPrimitive{"U32.shl", 1, "(($0 << 1) >>> 0)"},
    JDPrimitive{"U32.shr", 1, "(($0 >>> 1) >>> 0)"},
    JDPrimitive{"U32.shln", 2, "($1 >= 32 ? 0 : ($0 << $1) >>> 0)"},
    JDPrimitive{"U32.shrn", 2, "($1 >= 32 ? 0 : ($0 >>> $1) >>> 0)"},
    JDPrimitive{"U32.not", 1, "(~$0 >>> 0)"},
    JDPrimitive{"U32.is_zero", 1, "($0 === 0)"},
    JDPrimitive{"U32.cmp", 2, "cmp_new($0, $1)"},
    JDPrimitive{"U32.to_f32", 1, "Math.fround($0)"},
    JDPrimitive{"U32.to_nat", 1, "$0"},
    JDPrimitive{"U32.from_nat", 1, "($0 >>> 0)"},
    JDPrimitive{"F32.add", 2, "Math.fround($0 + $1)"},
    JDPrimitive{"F32.sub", 2, "Math.fround($0 - $1)"},
    JDPrimitive{"F32.mul", 2, "Math.fround($0 * $1)"},
    JDPrimitive{"F32.div", 2, "Math.fround($0 / $1)"},
    JDPrimitive{"F32.neg", 1, "(-$0)"},
    JDPrimitive{"F32.is_eq", 2, "($0 === $1)"},
    JDPrimitive{"F32.is_ne", 2, "($0 !== $1)"},
    JDPrimitive{"F32.is_lt", 2, "($0 < $1)"},
    JDPrimitive{"F32.is_le", 2, "($0 <= $1)"},
    JDPrimitive{"F32.is_gt", 2, "($0 > $1)"},
    JDPrimitive{"F32.is_ge", 2, "($0 >= $1)"},
    JDPrimitive{"F32.sqrt", 1, "Math.fround(Math.sqrt($0))"},
    JDPrimitive{"F32.exp", 1, "Math.fround(Math.exp($0))"},
    JDPrimitive{"F32.log", 1, "Math.fround(Math.log($0))"},
    JDPrimitive{"F32.log2", 1, "Math.fround(Math.log2($0))"},
    JDPrimitive{"F32.log10", 1, "Math.fround(Math.log10($0))"},
    JDPrimitive{"F32.sin", 1, "Math.fround(Math.sin($0))"},
    JDPrimitive{"F32.cos", 1, "Math.fround(Math.cos($0))"},
    JDPrimitive{"F32.tan", 1, "Math.fround(Math.tan($0))"},
    JDPrimitive{"F32.asin", 1, "Math.fround(Math.asin($0))"},
    JDPrimitive{"F32.acos", 1, "Math.fround(Math.acos($0))"},
    JDPrimitive{"F32.atan", 1, "Math.fround(Math.atan($0))"},
    JDPrimitive{"F32.sinh", 1, "Math.fround(Math.sinh($0))"},
    JDPrimitive{"F32.cosh", 1, "Math.fround(Math.cosh($0))"},
    JDPrimitive{"F32.tanh", 1, "Math.fround(Math.tanh($0))"},
    JDPrimitive{"F32.floor", 1, "Math.fround(Math.floor($0))"},
    JDPrimitive{"F32.ceil", 1, "Math.fround(Math.ceil($0))"},
    JDPrimitive{"F32.trunc", 1, "Math.fround(Math.trunc($0))"},
    JDPrimitive{"F32.abs", 1, "Math.fround(Math.abs($0))"},
    JDPrimitive{"F32.atan2", 2, "Math.fround(Math.atan2($0, $1))"},
    JDPrimitive{"F32.pow", 2, "($0 === 1 || $0 === -1 && Math.abs($1) === Infinity ? 1 : Math.fround(Math.pow($0, $1)))"},
    JDPrimitive{"F32.mod", 2, "Math.fround($0 % $1)"},
    JDPrimitive{"F32.to_u32", 1, "($0 >= 1 && $0 < 4294967296 ? Math.floor($0) : 0)"},
    JDPrimitive{"F32.bits", 1, "f32_bits($0)"},
    JDPrimitive{"F32.show", 1, "f32_show($0)"},
    JDPrimitive{"F32.read", 1, "f32_read($0)"},
    JDPrimitive{"Nat.add", 2, "nat_chk($0 + $1)"},
    JDPrimitive{"Nat.mul", 2, "nat_chk($0 * $1)"},
    JDPrimitive{"Nat.double", 1, "nat_chk($0 + $0)"},
    JDPrimitive{"Nat.cmp", 2, "cmp_new($0, $1)"},
    JDPrimitive{"Nat.sub", 2, "($0 < $1 ? 0 : $0 - $1)"},
    JDPrimitive{"Nat.is_lt", 2, "($0 < $1)"},
    JDPrimitive{"Nat.min", 2, "($0 < $1 ? $0 : $1)"},
    JDPrimitive{"Nat.max", 2, "($0 > $1 ? $0 : $1)"},
    JDPrimitive{"Nat.divmod", 2, "nat_divmod($0, $1)"},
    JDPrimitive{"Bool.or", 2, "($0 || $1)"},
    JDPrimitive{"Bool.xor", 2, "($0 !== $1)"},
    JDPrimitive{"String.append", 2, "($0 + $1)"},
    JDPrimitive{"String.eq", 2, "($0 === $1)"},
    JDPrimitive{"String.length", 1, "[...$0].length"},
    JDPrimitive{"Array.new", 2, "array_new($0, $1)"},
    JDPrimitive{"Array.set", 3, "($0[$1 % $0.length] = $2, $0)"},
    JDPrimitive{"Array.get", 2, "{$: \"Tuple\", fst: $0, snd: $0[$1 % $0.length]}"},
    JDPrimitive{"Array.swap", 3, "array_rmw($0, $1, () => $2)"},
    JDPrimitive{"Array.size", 1, "{$: \"Tuple\", fst: $0, snd: $0.length}"},
    JDPrimitive{"Array.clone", 1, "{$: \"Tuple\", fst: $0, snd: $0.slice()}"},
    JDPrimitive{"Array.atomic.add", 3, "array_rmw($0, $1, (o) => (o + $2) >>> 0)"},
    JDPrimitive{"Array.atomic.min", 3, "array_rmw($0, $1, (o) => Math.min(o, $2))"},
    JDPrimitive{"Array.atomic.max", 3, "array_rmw($0, $1, (o) => Math.max(o, $2))"},
    JDPrimitive{"Array.atomic.and", 3, "array_rmw($0, $1, (o) => (o & $2) >>> 0)"},
    JDPrimitive{"Array.atomic.or", 3, "array_rmw($0, $1, (o) => (o | $2) >>> 0)"},
    JDPrimitive{"Array.atomic.xor", 3, "array_rmw($0, $1, (o) => (o ^ $2) >>> 0)"},
    JDPrimitive{"Array.atomic.exch", 3, "array_rmw($0, $1, (o) => $2)"},
    JDPrimitive{"Array.atomic.cas", 4, "array_rmw($0, $1, (o) => o === $2 ? $3 : o)"},
    JDPrimitive{"Array.atomic.fadd", 3, "array_rmw($0, $1, (o) => Math.fround(o + $2))"}
  ]

# Select one compiler-owned metadata row without materializing the entire table.
# The canonical table/find API remains available for exact differential probes.
# Comparisons retain table order; no cache, name-only admission or new templates.

@unsafe
def jd_primitive_select(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "U32.add"),
    u => JDPrimitive{"U32.add", 2, "(($0 + $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.sub"),
    u => JDPrimitive{"U32.sub", 2, "(($0 - $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.and"),
    u => JDPrimitive{"U32.and", 2, "(($0 & $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.or"),
    u => JDPrimitive{"U32.or", 2, "(($0 | $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.xor"),
    u => JDPrimitive{"U32.xor", 2, "(($0 ^ $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.is_eq"),
    u => JDPrimitive{"U32.is_eq", 2, "($0 === $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.is_ne"),
    u => JDPrimitive{"U32.is_ne", 2, "($0 !== $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.is_lt"),
    u => JDPrimitive{"U32.is_lt", 2, "($0 < $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.is_le"),
    u => JDPrimitive{"U32.is_le", 2, "($0 <= $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.is_gt"),
    u => JDPrimitive{"U32.is_gt", 2, "($0 > $1)"}, u =>
    jd_primitive_select_1(name)))))))))))

@unsafe
def jd_primitive_select_1(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "U32.is_ge"),
    u => JDPrimitive{"U32.is_ge", 2, "($0 >= $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.mul"),
    u => JDPrimitive{"U32.mul", 2, "(Math.imul($0, $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.div"),
    u => JDPrimitive{"U32.div", 2, "($1 === 0 ? 0 : ($0 / $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.mod"),
    u => JDPrimitive{"U32.mod", 2, "($1 === 0 ? $0 : $0 % $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.inc"),
    u => JDPrimitive{"U32.inc", 1, "(($0 + 1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.shl"),
    u => JDPrimitive{"U32.shl", 1, "(($0 << 1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.shr"),
    u => JDPrimitive{"U32.shr", 1, "(($0 >>> 1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.shln"),
    u => JDPrimitive{"U32.shln", 2, "($1 >= 32 ? 0 : ($0 << $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.shrn"),
    u => JDPrimitive{"U32.shrn", 2, "($1 >= 32 ? 0 : ($0 >>> $1) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.not"),
    u => JDPrimitive{"U32.not", 1, "(~$0 >>> 0)"}, u =>
    jd_primitive_select_2(name)))))))))))

@unsafe
def jd_primitive_select_2(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "U32.is_zero"),
    u => JDPrimitive{"U32.is_zero", 1, "($0 === 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.cmp"),
    u => JDPrimitive{"U32.cmp", 2, "cmp_new($0, $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.to_f32"),
    u => JDPrimitive{"U32.to_f32", 1, "Math.fround($0)"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.to_nat"),
    u => JDPrimitive{"U32.to_nat", 1, "$0"}, u =>
    kc(JDPrimitive, String.eq(name, "U32.from_nat"),
    u => JDPrimitive{"U32.from_nat", 1, "($0 >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.add"),
    u => JDPrimitive{"F32.add", 2, "Math.fround($0 + $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.sub"),
    u => JDPrimitive{"F32.sub", 2, "Math.fround($0 - $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.mul"),
    u => JDPrimitive{"F32.mul", 2, "Math.fround($0 * $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.div"),
    u => JDPrimitive{"F32.div", 2, "Math.fround($0 / $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.neg"),
    u => JDPrimitive{"F32.neg", 1, "(-$0)"}, u =>
    jd_primitive_select_3(name)))))))))))

@unsafe
def jd_primitive_select_3(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "F32.is_eq"),
    u => JDPrimitive{"F32.is_eq", 2, "($0 === $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.is_ne"),
    u => JDPrimitive{"F32.is_ne", 2, "($0 !== $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.is_lt"),
    u => JDPrimitive{"F32.is_lt", 2, "($0 < $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.is_le"),
    u => JDPrimitive{"F32.is_le", 2, "($0 <= $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.is_gt"),
    u => JDPrimitive{"F32.is_gt", 2, "($0 > $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.is_ge"),
    u => JDPrimitive{"F32.is_ge", 2, "($0 >= $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.sqrt"),
    u => JDPrimitive{"F32.sqrt", 1, "Math.fround(Math.sqrt($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.exp"),
    u => JDPrimitive{"F32.exp", 1, "Math.fround(Math.exp($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.log"),
    u => JDPrimitive{"F32.log", 1, "Math.fround(Math.log($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.log2"),
    u => JDPrimitive{"F32.log2", 1, "Math.fround(Math.log2($0))"}, u =>
    jd_primitive_select_4(name)))))))))))

@unsafe
def jd_primitive_select_4(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "F32.log10"),
    u => JDPrimitive{"F32.log10", 1, "Math.fround(Math.log10($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.sin"),
    u => JDPrimitive{"F32.sin", 1, "Math.fround(Math.sin($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.cos"),
    u => JDPrimitive{"F32.cos", 1, "Math.fround(Math.cos($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.tan"),
    u => JDPrimitive{"F32.tan", 1, "Math.fround(Math.tan($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.asin"),
    u => JDPrimitive{"F32.asin", 1, "Math.fround(Math.asin($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.acos"),
    u => JDPrimitive{"F32.acos", 1, "Math.fround(Math.acos($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.atan"),
    u => JDPrimitive{"F32.atan", 1, "Math.fround(Math.atan($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.sinh"),
    u => JDPrimitive{"F32.sinh", 1, "Math.fround(Math.sinh($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.cosh"),
    u => JDPrimitive{"F32.cosh", 1, "Math.fround(Math.cosh($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.tanh"),
    u => JDPrimitive{"F32.tanh", 1, "Math.fround(Math.tanh($0))"}, u =>
    jd_primitive_select_5(name)))))))))))

@unsafe
def jd_primitive_select_5(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "F32.floor"),
    u => JDPrimitive{"F32.floor", 1, "Math.fround(Math.floor($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.ceil"),
    u => JDPrimitive{"F32.ceil", 1, "Math.fround(Math.ceil($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.trunc"),
    u => JDPrimitive{"F32.trunc", 1, "Math.fround(Math.trunc($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.abs"),
    u => JDPrimitive{"F32.abs", 1, "Math.fround(Math.abs($0))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.atan2"),
    u => JDPrimitive{"F32.atan2", 2, "Math.fround(Math.atan2($0, $1))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.pow"),
    u => JDPrimitive{"F32.pow", 2, "($0 === 1 || $0 === -1 && Math.abs($1) === Infinity ? 1 : Math.fround(Math.pow($0, $1)))"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.mod"),
    u => JDPrimitive{"F32.mod", 2, "Math.fround($0 % $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.to_u32"),
    u => JDPrimitive{"F32.to_u32", 1, "($0 >= 1 && $0 < 4294967296 ? Math.floor($0) : 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.bits"),
    u => JDPrimitive{"F32.bits", 1, "f32_bits($0)"}, u =>
    kc(JDPrimitive, String.eq(name, "F32.show"),
    u => JDPrimitive{"F32.show", 1, "f32_show($0)"}, u =>
    jd_primitive_select_6(name)))))))))))

@unsafe
def jd_primitive_select_6(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "F32.read"),
    u => JDPrimitive{"F32.read", 1, "f32_read($0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.add"),
    u => JDPrimitive{"Nat.add", 2, "nat_chk($0 + $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.mul"),
    u => JDPrimitive{"Nat.mul", 2, "nat_chk($0 * $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.double"),
    u => JDPrimitive{"Nat.double", 1, "nat_chk($0 + $0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.cmp"),
    u => JDPrimitive{"Nat.cmp", 2, "cmp_new($0, $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.sub"),
    u => JDPrimitive{"Nat.sub", 2, "($0 < $1 ? 0 : $0 - $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.is_lt"),
    u => JDPrimitive{"Nat.is_lt", 2, "($0 < $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.min"),
    u => JDPrimitive{"Nat.min", 2, "($0 < $1 ? $0 : $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.max"),
    u => JDPrimitive{"Nat.max", 2, "($0 > $1 ? $0 : $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Nat.divmod"),
    u => JDPrimitive{"Nat.divmod", 2, "nat_divmod($0, $1)"}, u =>
    jd_primitive_select_7(name)))))))))))

@unsafe
def jd_primitive_select_7(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "Bool.or"),
    u => JDPrimitive{"Bool.or", 2, "($0 || $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Bool.xor"),
    u => JDPrimitive{"Bool.xor", 2, "($0 !== $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "String.append"),
    u => JDPrimitive{"String.append", 2, "($0 + $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "String.eq"),
    u => JDPrimitive{"String.eq", 2, "($0 === $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "String.length"),
    u => JDPrimitive{"String.length", 1, "[...$0].length"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.new"),
    u => JDPrimitive{"Array.new", 2, "array_new($0, $1)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.set"),
    u => JDPrimitive{"Array.set", 3, "($0[$1 % $0.length] = $2, $0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.get"),
    u => JDPrimitive{"Array.get", 2, "{$: \"Tuple\", fst: $0, snd: $0[$1 % $0.length]}"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.swap"),
    u => JDPrimitive{"Array.swap", 3, "array_rmw($0, $1, () => $2)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.size"),
    u => JDPrimitive{"Array.size", 1, "{$: \"Tuple\", fst: $0, snd: $0.length}"}, u =>
    jd_primitive_select_8(name)))))))))))

@unsafe
def jd_primitive_select_8(+name: String) -> JDPrimitive:
  kc(JDPrimitive, String.eq(name, "Array.clone"),
    u => JDPrimitive{"Array.clone", 1, "{$: \"Tuple\", fst: $0, snd: $0.slice()}"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.add"),
    u => JDPrimitive{"Array.atomic.add", 3, "array_rmw($0, $1, (o) => (o + $2) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.min"),
    u => JDPrimitive{"Array.atomic.min", 3, "array_rmw($0, $1, (o) => Math.min(o, $2))"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.max"),
    u => JDPrimitive{"Array.atomic.max", 3, "array_rmw($0, $1, (o) => Math.max(o, $2))"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.and"),
    u => JDPrimitive{"Array.atomic.and", 3, "array_rmw($0, $1, (o) => (o & $2) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.or"),
    u => JDPrimitive{"Array.atomic.or", 3, "array_rmw($0, $1, (o) => (o | $2) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.xor"),
    u => JDPrimitive{"Array.atomic.xor", 3, "array_rmw($0, $1, (o) => (o ^ $2) >>> 0)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.exch"),
    u => JDPrimitive{"Array.atomic.exch", 3, "array_rmw($0, $1, (o) => $2)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.cas"),
    u => JDPrimitive{"Array.atomic.cas", 4, "array_rmw($0, $1, (o) => o === $2 ? $3 : o)"}, u =>
    kc(JDPrimitive, String.eq(name, "Array.atomic.fadd"),
    u => JDPrimitive{"Array.atomic.fadd", 3, "array_rmw($0, $1, (o) => Math.fround(o + $2))"}, u =>
    JDPrimitive{"", 0, ""}))))))))))
