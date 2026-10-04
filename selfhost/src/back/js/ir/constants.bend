# Fold only admitted primitive operations whose operands are integer tokens.
# These nine operations emit JavaScript operators without host function calls;
# U32 arithmetic here has the same modulo-2^32 result. No operand can coerce an
# object, throw or invoke a hook. Float words and nonliteral operands stay intact.
@unsafe
def jir_fold_primitive(+name: String, +a: JIRExpr, +b: JIRExpr) -> JIRExpr:
  jir_fold_primitive_on(name, a, b, JIRPrimitive{name, a, b})

@unsafe
def jir_fold_primitive_on(+name: String, +a: JIRExpr, +b: JIRExpr, +original: JIRExpr) -> JIRExpr:
  match a:
    case JIRWord{x, False{}}:
      match b:
        case JIRWord{y, False{}}: jir_fold_binary(name, x, y, original)
        case JIRNull{}: jir_fold_unary(name, x, original)
        case other: original
    case other: original

@unsafe
def jir_fold_binary(+name: String, +x: U32, +y: U32, +original: JIRExpr) -> JIRExpr:
  kc(JIRExpr, String.eq(name, "U32.add"), u => JIRWord{U32.add(x, y), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.sub"), u => JIRWord{U32.sub(x, y), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.and"), u => JIRWord{U32.and(x, y), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.or"), u => JIRWord{U32.or(x, y), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.xor"), u => JIRWord{U32.xor(x, y), False{}}, u => original)))))

@unsafe
def jir_fold_unary(+name: String, +x: U32, +original: JIRExpr) -> JIRExpr:
  kc(JIRExpr, String.eq(name, "U32.inc"), u => JIRWord{U32.inc(x), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.not"), u => JIRWord{U32.not(x), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.shl"), u => JIRWord{U32.shl(x), False{}}, u =>
  kc(JIRExpr, String.eq(name, "U32.shr"), u => JIRWord{U32.shr(x), False{}}, u => original))))
