# Nat representation is a whole private-graph choice. These semantic IR facts
# come from the existing closed-type/literal/native proof, never emitted text.
# A refused boundary keeps every original BigInt instruction and public ABI.
type JWEmission is Data:
  JWEmission{+code: String, +numberNat: Bool}

@unsafe
def jw_nat_functions_valid(+functions: List<&2,JWFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      valid && jw_nat_code_valid(code) && jw_nat_functions_valid(rest)

@unsafe
def jw_nat_values_valid(+values: List<&2,JWValue>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value, rest}: jw_nat_value_valid(value) && jw_nat_values_valid(rest)

@unsafe
def jw_nat_native(+name: String) -> Bool:
  String.contains("|Nat.add|Nat.sub|Nat.is_lt|Nat.divmod|", "|" ++ name ++ "|")

@unsafe
def jw_nat_value_valid(+value: JWValue) -> Bool:
  match value:
    case JWSlot{slot}: True{}
    case JWLiteral{code}: True{}
    case JWNat{number}: True{}
    case JWGlobal{name, layout}: String.eq(layout, "string")
    case JWProject{layout, input, index}: jw_nat_value_valid(input)
    case JWPrimitive{name, args}: j_primitive_known(name) && jw_nat_values_valid(args)
    case JWConstruct{layout, name, fields}: jw_nat_values_valid(fields)
    case JWNative{name, args}:
      (jw_nat_native(name) || String.contains("|U32.cmp|Bool.xor|Bool.and|F32.to_u32|String.append|", "|" ++ name ++ "|")) && jw_nat_values_valid(args)
    case JWNumberOp{op, args}: False{}

@unsafe
def jw_nat_code_valid(+code: List<&2,JWInstruction>) -> Bool:
  match code:
    case Nil{}: True{}
    case Con{instruction, rest}: jw_nat_instruction_valid(instruction) && jw_nat_code_valid(rest)

@unsafe
def jw_nat_instruction_valid(+instruction: JWInstruction) -> Bool:
  match instruction:
    case JWAssign{slot, value}: jw_nat_value_valid(value)
    case JWDirectCall{slot, target, args}: jw_nat_values_valid(args)
    case JWCase{layout, name, input, yes, no}:
      jw_nat_value_valid(input) && jw_nat_code_valid(yes) && jw_nat_code_valid(no)
    case JWReturn{value}: jw_nat_value_valid(value)
    case JWImpossible{}: True{}

@unsafe
def jw_nat_functions(+functions: List<&2,JWFunction>) -> List<&2,JWFunction>:
  match functions:
    case Nil{}: Nil{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      Con{JWFunction{name, arity, jw_nat_code(code), valid}, jw_nat_functions(rest)}

@unsafe
def jw_nat_values(+values: List<&2,JWValue>) -> List<&2,JWValue>:
  match values:
    case Nil{}: Nil{}
    case Con{value, rest}: Con{jw_nat_value(value), jw_nat_values(rest)}

@unsafe
def jw_nat_layout(+layout: String) -> String:
  kc(String, String.eq(layout, "nat"), u => "nat-number", u => layout)

@unsafe
def jw_nat_value(+value: JWValue) -> JWValue:
  match value:
    case JWNat{number}: JWLiteral{U32.show(number)}
    case JWProject{layout, input, index}: JWProject{jw_nat_layout(layout), jw_nat_value(input), index}
    case JWPrimitive{name, args}:
      kc(JWValue, String.contains("|U32.to_nat|U32.from_nat|U32.shln|U32.shrn|", "|" ++ name ++ "|"),
        u => JWNumberOp{name, jw_nat_values(args)}, u => JWPrimitive{name, jw_nat_values(args)})
    case JWConstruct{layout, name, fields}:
      kc(JWValue, String.eq(layout, "nat"), u => JWNumberOp{name, jw_nat_values(fields)},
        u => JWConstruct{layout, name, jw_nat_values(fields)})
    case JWNative{name, args}:
      kc(JWValue, jw_nat_native(name), u => JWNumberOp{name, jw_nat_values(args)}, u => JWNative{name, jw_nat_values(args)})
    case other: value

@unsafe
def jw_nat_code(+code: List<&2,JWInstruction>) -> List<&2,JWInstruction>:
  match code:
    case Nil{}: Nil{}
    case Con{instruction, rest}: Con{jw_nat_instruction(instruction), jw_nat_code(rest)}

@unsafe
def jw_nat_instruction(+instruction: JWInstruction) -> JWInstruction:
  match instruction:
    case JWAssign{slot, value}: JWAssign{slot, jw_nat_value(value)}
    case JWDirectCall{slot, target, args}: JWDirectCall{slot, target, jw_nat_values(args)}
    case JWCase{layout, name, input, yes, no}:
      JWCase{jw_nat_layout(layout), name, jw_nat_value(input), jw_nat_code(yes), jw_nat_code(no)}
    case JWReturn{value}: JWReturn{jw_nat_value(value)}
    case JWImpossible{}: JWImpossible{}

# Every repeated operand is evaluated exactly once by a small private helper.
# Intermediates are exact below 2^49. Unknown operations cannot pass admission.
@unsafe
def jw_number_code(+op: String, +a: String, +b: String) -> String:
  kc(String, String.eq(op, "Zero"), u => "0", u =>
  kc(String, String.eq(op, "Succ"), u => "$natChecked(" ++ a ++ "+1)", u =>
  kc(String, String.eq(op, "Nat.add"), u => "$natChecked(" ++ a ++ "+" ++ b ++ ")", u =>
  kc(String, String.eq(op, "Nat.sub"), u => "$natSub(" ++ a ++ "," ++ b ++ ")", u =>
  kc(String, String.eq(op, "Nat.is_lt"), u => "(" ++ a ++ "<" ++ b ++ ")", u =>
  kc(String, String.eq(op, "Nat.divmod"), u => "$natDivmod(" ++ a ++ "," ++ b ++ ")", u =>
  kc(String, String.eq(op, "U32.to_nat"), u => a, u =>
  kc(String, String.eq(op, "U32.from_nat"), u => "(" ++ a ++ ">>>0)", u =>
  kc(String, String.eq(op, "U32.shln"), u => "$natShl(" ++ a ++ "," ++ b ++ ")", u =>
  kc(String, String.eq(op, "U32.shrn"), u => "$natShr(" ++ a ++ "," ++ b ++ ")", u => "bad('private Nat operation invariant')"))))))))))

@unsafe
def jw_nat_declarations() -> String:
  "/* private Number Nat */function $natChecked(n){if(n<0||n>281474976710655)return bad('a Nat past the largest immediate 2^48-1');return n;}" ++
  "function $natSub(a,b){return a>=b?a-b:0;}" ++
  "function $natDivmod(a,b){if(b===0)return[0,a];const r=a%b;return[(a-r)/b,r];}" ++
  "function $natShl(a,n){return n>=32?0:(a<<n)>>>0;}function $natShr(a,n){return n>=32?0:a>>>n;}"

# The scalar public guard has already checked the original BigInt Nat domain.
@unsafe
def jw_nat_inputs(+book: List<&2,KDef>, +ty: KTerm, +at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u =>
    kc(String, j_primitive_type(book, wnf(book, kid(wnf(book, ty), 0)), "Nat"),
      u => "$s" ++ U32.show(at) ++ "=regionCounterNumber($s" ++ U32.show(at) ++ ");", u => "") ++
    jw_nat_inputs(book, kid(wnf(book, ty), 1), U32.inc(at), total))

@unsafe
def jw_nat_result(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, wnf(book, ty), "Nat"),
    u => jw_nat_result(book, kid(wnf(book, ty), 1), U32.sub(left, 1)))
