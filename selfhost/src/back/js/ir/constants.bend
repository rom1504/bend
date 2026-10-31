
# Module: src/back/js/ir/constants.bend:6
@unsafe
def jir_fold_primitive(+name: String, +a: JIRExpr, +b: JIRExpr) -> JIRExpr:
  jir_fold_primitive_on(name, a, b, JIRPrimitive{name, a, b})

# Module: src/back/js/ir/constants.bend:10
@unsafe
def jir_fold_primitive_on(+name: String, +a: JIRExpr, +b: JIRExpr, +original: JIRExpr) -> JIRExpr:
  match a:
    case JIRWord{x, False{}}:
      match b:
        case JIRWord{y, False{}}: jir_fold_binary(name, x, y, original)
        case JIRNull{}: jir_fold_unary(name, x, original)
        case other: original
    case other: original

# Module: src/back/js/ir/constants.bend:20
@unsafe
def jir_fold_binary(+name: String, +x: U32, +y: U32, +original: JIRExpr) -> JIRExpr:
  kc(JIRExpr, p88_string_eq(name, "U32.add"), u => JIRWord{U32.add(x, y), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.sub"), u => JIRWord{U32.sub(x, y), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.and"), u => JIRWord{U32.and(x, y), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.or"), u => JIRWord{U32.or(x, y), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.xor"), u => JIRWord{U32.xor(x, y), False{}}, u => original)))))

# Module: src/back/js/ir/constants.bend:28
@unsafe
def jir_fold_unary(+name: String, +x: U32, +original: JIRExpr) -> JIRExpr:
  kc(JIRExpr, p88_string_eq(name, "U32.inc"), u => JIRWord{U32.inc(x), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.not"), u => JIRWord{U32.not(x), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.shl"), u => JIRWord{U32.shl(x), False{}}, u =>
  kc(JIRExpr, p88_string_eq(name, "U32.shr"), u => JIRWord{U32.shr(x), False{}}, u => original))))
