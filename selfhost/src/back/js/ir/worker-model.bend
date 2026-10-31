
# Module: src/back/js/ir/worker-model.bend:3
type JWValue is Data:
  JWSlot{+slot: U32}
  JWLiteral{+code: String}
  JWNat{+number: U32}
  JWGlobal{+name: String, +layout: String}
  JWProject{+layout: String, +input: JWValue, +index: U32}
  JWPrimitive{+name: String, +args: List<&2,JWValue>}
  JWConstruct{+layout: String, +name: String, +fields: List<&2,JWValue>}
  JWNative{+name: String, +args: List<&2,JWValue>}
  JWNumberOp{+op: String, +args: List<&2,JWValue>}

# Values contain no private calls. Each such call is explicit. Cyclic edges
# retain a PC-loop fallback; direct recursive entries consume one shared budget,
# and cross-component edges follow the proved acyclic condensation graph.

# Module: src/back/js/ir/worker-model.bend:17
type JWInstruction is Data:
  JWAssign{+slot: U32, +value: JWValue}
  JWDirectCall{+slot: U32, +target: U32, +args: List<&2,JWValue>}
  JWCase{+layout: String, +name: String, +input: JWValue,
    +yes: List<&2,JWInstruction>, +no: List<&2,JWInstruction>}
  JWReturn{+value: JWValue}
  JWImpossible{}

# Module: src/back/js/ir/worker-model.bend:25
type JWBinding is Data:
  JWBinding{+id: U32, +value: JWValue, +typ: KTerm}

# Module: src/back/js/ir/worker-model.bend:28
type JWLower is Data:
  JWLower{+code: List<&2,JWInstruction>, +value: JWValue, +next: U32, +valid: Bool}

# Module: src/back/js/ir/worker-model.bend:31
type JWArgs is Data:
  JWArgs{+code: List<&2,JWInstruction>, +values: List<&2,JWValue>, +next: U32, +valid: Bool}

# Module: src/back/js/ir/worker-model.bend:34
type JWFunction is Data:
  JWFunction{+name: String, +arity: U32, +code: List<&2,JWInstruction>, +valid: Bool}

# Module: src/back/js/ir/worker-model.bend:37
type JWPrinted is Data:
  JWPrinted{+code: String, +next: U32}

# Module: src/back/js/ir/worker-model.bend:40
type JWEmitContext is Data:
  JWEmitContext{+functions: List<&2,JWFunction>, +components: List<&2,U32>, +group: U32}

# Module: src/back/js/ir/worker-model.bend:44
@unsafe
def jw_fail() -> JWLower:
  JWLower{Nil{}, JWLiteral{"null"}, 0, False{}}

# Module: src/back/js/ir/worker-model.bend:48
@unsafe
def jw_code(+r: JWLower) -> List<&2,JWInstruction>:
  match r:
    case JWLower{code, value, next, valid}: code

# Module: src/back/js/ir/worker-model.bend:53
@unsafe
def jw_value(+r: JWLower) -> JWValue:
  match r:
    case JWLower{code, value, next, valid}: value

# Module: src/back/js/ir/worker-model.bend:58
@unsafe
def jw_next(+r: JWLower) -> U32:
  match r:
    case JWLower{code, value, next, valid}: next

# Module: src/back/js/ir/worker-model.bend:63
@unsafe
def jw_valid(+r: JWLower) -> Bool:
  match r:
    case JWLower{code, value, next, valid}: valid

# Module: src/back/js/ir/worker-model.bend:68
@unsafe
def jw_printed_code(+r: JWPrinted) -> String:
  match r:
    case JWPrinted{code, next}: code

# Module: src/back/js/ir/worker-model.bend:73
@unsafe
def jw_printed_next(+r: JWPrinted) -> U32:
  match r:
    case JWPrinted{code, next}: next
