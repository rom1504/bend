
# Module: src/back/js/primitive.bend:7
@unsafe
def j_primitive_known(+name: String) -> Bool:
  String.contains("|U32.add|U32.sub|U32.mul|U32.div|U32.mod|U32.and|U32.or|U32.xor|U32.inc|U32.not|U32.shl|U32.shr|U32.shln|U32.shrn|U32.is_zero|U32.is_eq|U32.is_ne|U32.is_lt|U32.is_le|U32.is_gt|U32.is_ge|U32.to_nat|U32.from_nat|U32.to_f32|F32.add|F32.sub|F32.mul|F32.div|F32.mod|F32.neg|F32.is_eq|F32.is_ne|F32.is_lt|F32.is_le|F32.is_gt|F32.is_ge|F32.sqrt|F32.exp|F32.log|F32.log2|F32.log10|F32.sin|F32.cos|F32.tan|F32.asin|F32.acos|F32.atan|F32.sinh|F32.cosh|F32.tanh|F32.floor|F32.ceil|F32.trunc|F32.abs|", "|" ++ name ++ "|")

# Module: src/back/js/primitive.bend:11
@unsafe
def j_primitive_arity(+name: String) -> U32:
  kc(U32, String.contains("|U32.inc|U32.not|U32.shl|U32.shr|U32.is_zero|U32.to_nat|U32.from_nat|U32.to_f32|F32.neg|F32.sqrt|F32.exp|F32.log|F32.log2|F32.log10|F32.sin|F32.cos|F32.tan|F32.asin|F32.acos|F32.atan|F32.sinh|F32.cosh|F32.tanh|F32.floor|F32.ceil|F32.trunc|F32.abs|", "|" ++ name ++ "|"), u => 1, u => 2)

# Module: src/back/js/primitive.bend:15
@unsafe
def j_primitive_input(+name: String, +at: U32) -> String:
  kc(String, p88_string_eq(name, "U32.from_nat") || ((p88_string_eq(name, "U32.shln") || p88_string_eq(name, "U32.shrn")) && U32.is_eq(at, 1)), u => "Nat", u => kc(String, String.starts_with(name, "F32."), u => "F32", u => "U32"))

# Module: src/back/js/primitive.bend:19
@unsafe
def j_primitive_result(+name: String) -> String:
  kc(String, String.starts_with(name, "U32.is_") || String.starts_with(name, "F32.is_"), u => "Bool", u =>
  kc(String, p88_string_eq(name, "U32.to_nat"), u => "Nat", u =>
  kc(String, p88_string_eq(name, "U32.to_f32") || String.starts_with(name, "F32."), u => "F32", u => "U32")))

# Module: src/back/js/primitive.bend:25
@unsafe
def j_primitive_type(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), name) && U32.is_eq(terms_len(ks(ty)), 0) &&
  List.is_empty(&2, String, rm(ty)) &&
  kc(Bool, p88_string_eq(name, "Nat"), u => j_u32_native_ctor(book, "Nat", "Zero") && j_u32_native_ctor(book, "Nat", "Succ"), u =>
  kc(Bool, p88_string_eq(name, "F32"), u => j_u32_native_ctor(book, "F32", "F32") && j_u32_native_book(book), u =>
  kc(Bool, p88_string_eq(name, "Bool"), u => j_u32_native_ctor(book, "Bool", "False") && j_u32_native_ctor(book, "Bool", "True"), u => j_u32_native_book(book))))

# Module: src/back/js/primitive.bend:33
@unsafe
def j_primitive_telescope(+book: List<&2,KDef>, +ty: KTerm, +name: String, +at: U32, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, head, j_primitive_result(name)), u =>
    kc(Bool, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_primitive_type(book, wnf(book, kid(head, 0)), j_primitive_input(name, at)),
      u => j_primitive_telescope(book, kid(head, 1), name, U32.inc(at), U32.sub(left, 1)), u => False{}))

# Module: src/back/js/primitive.bend:41
@unsafe
def j_primitive_definition(+book: List<&2,KDef>, +d: KDef, +arity: U32) -> Bool:
  kc(Bool, db(d) && p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) &&
    U32.is_eq(da(d), arity) && U32.is_eq(j_primitive_arity(dn(d)), arity),
    u => j_primitive_telescope(book, dt(d), dn(d), 0, arity), u => False{})

# Module: src/back/js/primitive.bend:48
@unsafe
def j_primitive_call(+book: List<&2,KDef>, +spine: KTerm) -> Bool:
  kc(Bool, p98_tag_eq(spine, "Call") && j_primitive_known(nm(spine)),
    u => j_primitive_definition(book, lookup(book, nm(spine)), terms_len(ks(spine))), u => False{})

# A large literal shift still evaluates its left operand, without coercing it.

# Module: src/back/js/primitive.bend:54
@unsafe
def j_primitive_shift_literal(+name: String, +a: String, +count: U32) -> String:
  kc(String, U32.is_lt(count, 32),
    u => "((" ++ a ++ kc(String, p88_string_eq(name, "U32.shln"), u => "<<", u => ">>>") ++ U32.show(count) ++ ")>>>0)",
    u => "(" ++ a ++ ",0)")

# Module: src/back/js/primitive.bend:60
@unsafe
def j_primitive_symbol(+op: String) -> String:
  kc(String, p88_string_eq(op, "add"), u => "+", u =>
  kc(String, p88_string_eq(op, "sub"), u => "-", u =>
  kc(String, p88_string_eq(op, "mul"), u => "*", u =>
  kc(String, p88_string_eq(op, "div"), u => "/", u =>
  kc(String, p88_string_eq(op, "mod"), u => "%", u =>
  kc(String, p88_string_eq(op, "and"), u => "&", u =>
  kc(String, p88_string_eq(op, "or"), u => "|", u =>
  kc(String, p88_string_eq(op, "xor"), u => "^", u =>
  kc(String, p88_string_eq(op, "is_eq"), u => "===", u =>
  kc(String, p88_string_eq(op, "is_ne"), u => "!==", u =>
  kc(String, p88_string_eq(op, "is_lt"), u => "<", u =>
  kc(String, p88_string_eq(op, "is_le"), u => "<=", u =>
  kc(String, p88_string_eq(op, "is_gt"), u => ">", u => ">=")))))))))))))

# Module: src/back/js/primitive.bend:76
@unsafe
def j_primitive_code(+name: String, +a: String, +b: String) -> String:
  +op = String.drop(name, 4n)
  kc(String, String.starts_with(op, "is_") && Bool.not(p88_string_eq(op, "is_zero")),
    u => "(" ++ a ++ j_primitive_symbol(op) ++ b ++ ")", u =>
  kc(String, String.starts_with(name, "F32."), u => j_primitive_float(op, a, b), u => j_primitive_u32(op, a, b)))

# Module: src/back/js/primitive.bend:83
@unsafe
def j_primitive_float(+op: String, +a: String, +b: String) -> String:
  kc(String, p88_string_eq(op, "neg"), u => "Math.fround(-" ++ a ++ ")", u =>
  kc(String, String.contains("|add|sub|mul|div|mod|", "|" ++ op ++ "|"),
    u => "Math.fround(" ++ a ++ j_primitive_symbol(op) ++ b ++ ")",
    u => "Math.fround(Math." ++ op ++ "(" ++ a ++ "))"))

# Module: src/back/js/primitive.bend:90
@unsafe
def j_primitive_u32(+op: String, +a: String, +b: String) -> String:
  kc(String, p88_string_eq(op, "mul"), u => "(Math.imul(" ++ a ++ "," ++ b ++ ")>>>0)", u =>
  kc(String, p88_string_eq(op, "div"), u => "((a,b)=>b===0?0:(Math.floor(a/b)>>>0))(" ++ a ++ "," ++ b ++ ")", u =>
  kc(String, p88_string_eq(op, "mod"), u => "((a,b)=>b===0?a:a%b)(" ++ a ++ "," ++ b ++ ")", u =>
  kc(String, p88_string_eq(op, "shln") || p88_string_eq(op, "shrn"), u => "((a,n)=>n>=32n?0:(a" ++ kc(String, p88_string_eq(op, "shln"), u => "<<", u => ">>>") ++ "Number(n))>>>0)(" ++ a ++ "," ++ b ++ ")", u =>
  kc(String, p88_string_eq(op, "inc"), u => "((" ++ a ++ "+1)>>>0)", u =>
  kc(String, p88_string_eq(op, "not"), u => "((~" ++ a ++ ")>>>0)", u =>
  kc(String, p88_string_eq(op, "shl"), u => "((" ++ a ++ "<<1)>>>0)", u =>
  kc(String, p88_string_eq(op, "shr"), u => "(" ++ a ++ ">>>1)", u =>
  kc(String, p88_string_eq(op, "is_zero"), u => "(" ++ a ++ "===0)", u =>
  kc(String, p88_string_eq(op, "to_nat"), u => "BigInt(" ++ a ++ ")", u =>
  kc(String, p88_string_eq(op, "from_nat"), u => "Number(" ++ a ++ "&0xffffffffn)", u =>
  kc(String, p88_string_eq(op, "to_f32"), u => "Math.fround(" ++ a ++ ")", u =>
    "((" ++ a ++ j_primitive_symbol(op) ++ b ++ ")>>>0)"))))))))))))
