# Emit straight-line basic blocks. Only branches and suspended private calls
# change the PC; arithmetic and construction do not dispatch through an evaluator.
@unsafe
def jw_emit_value(+v: JWValue, +direct: Bool) -> String:
  match v:
    case JWSlot{slot}: jw_emit_slot(slot, direct)
    case JWLiteral{code}: code
    case JWGlobal{name}: "get(G," ++ j_quote(name) ++ ")"
    case JWProject{layout, input, index}: jw_emit_project(layout, jw_emit_value(input, direct), index)
    case JWPrimitive{name, args}:
      j_primitive_code(name, "(" ++ jw_emit_at(args, 0, direct) ++ ")", "(" ++ jw_emit_at(args, 1, direct) ++ ")")
    case JWConstruct{name, fields}: "ctor(" ++ j_quote(name) ++ ",[" ++ jw_emit_values(fields, direct) ++ "])"
    case JWNative{name, args}: "callOwned(get(G," ++ j_quote(name) ++ "),[" ++ jw_emit_values(args, direct) ++ "])"

@unsafe
def jw_emit_slot(+slot: U32, +direct: Bool) -> String:
  kc(String, direct, u => "$v" ++ U32.show(slot), u => "$r[" ++ U32.show(slot) ++ "]")

@unsafe
def jw_emit_values(+values: List<&2,JWValue>, +direct: Bool) -> String:
  match values:
    case Nil{}: ""
    case Con{value, rest}: jw_emit_value(value, direct) ++ "," ++ jw_emit_values(rest, direct)

@unsafe
def jw_emit_at(+values: List<&2,JWValue>, +at: U32, +direct: Bool) -> String:
  match values:
    case Nil{}: ""
    case Con{value, rest}: kc(String, U32.is_eq(at, 0), u => jw_emit_value(value, direct), u => jw_emit_at(rest, U32.sub(at, 1), direct))

@unsafe
def jw_emit_project(+layout: String, +input: String, +index: U32) -> String:
  kc(String, String.eq(layout, "nat"), u => "(" ++ input ++ "-1n)", u =>
  kc(String, String.eq(layout, "tuple"), u => "(" ++ input ++ ")[" ++ U32.show(index) ++ "]", u =>
  kc(String, String.eq(layout, "char"), u => "(typeof " ++ input ++ "==='string'?" ++ input ++ ".codePointAt(0):" ++ input ++ ")", u =>
  kc(String, String.eq(layout, "string"), u => kc(String, U32.is_eq(index, 0),
    u => input ++ ".codePointAt(0)", u => input ++ ".slice(" ++ input ++ ".codePointAt(0)>65535?2:1)"),
    u => "(" ++ input ++ ").a[" ++ U32.show(index) ++ "]"))))

@unsafe
def jw_emit_condition(+layout: String, +name: String, +input: JWValue, +direct: Bool) -> String:
  +value = jw_emit_value(input, direct)
  kc(String, String.eq(layout, "bool"), u => value ++ "===" ++ kc(String, String.eq(name, "True"), u => "true", u => "false"), u =>
  kc(String, String.eq(layout, "nat"), u => value ++ kc(String, String.eq(name, "Zero"), u => "===0n", u => "!==0n"), u =>
  kc(String, String.eq(layout, "string"), u => value ++ kc(String, String.eq(name, "SNil"), u => "===''", u => "!==''"), u =>
  kc(String, String.eq(layout, "char") || String.eq(layout, "tuple"), u => "true",
    u => "(" ++ value ++ ").$===" ++ j_quote(name)))))

@unsafe
def jw_tail_result(+code: List<&2,JWInstruction>, +slot: U32) -> Bool:
  match code:
    case Con{JWReturn{JWSlot{at}}, Nil{}}: U32.is_eq(slot, at)
    case other: False{}

@unsafe
def jw_emit_tail_transfer(+args: List<&2,JWValue>, +target: U32) -> String:
  "$r=[" ++ jw_emit_values(args, False{}) ++ "];$pc=" ++ U32.show(target) ++ ";continue;}"

@unsafe
def jw_entry_name(+functions: List<&2,JWFunction>, +at: U32) -> String:
  match functions:
    case Nil{}: "$invalidWorker"
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(String, U32.is_eq(at, 0), u => j_region_name(name) ++ "$tree", u => jw_entry_name(rest, U32.sub(at, 1)))

@unsafe
def jw_context_name(+ctx: JWEmitContext, +target: U32) -> String:
  match ctx:
    case JWEmitContext{functions, components, group}: jw_entry_name(functions, target)

@unsafe
def jw_context_same(+ctx: JWEmitContext, +target: U32) -> Bool:
  match ctx:
    case JWEmitContext{functions, components, group}: U32.is_eq(jw_component_at(components, target), group)

@unsafe
def jw_emit_block(+ctx: JWEmitContext, +code: List<&2,JWInstruction>, +label: U32, +next: U32, +prefix: String) -> JWPrinted:
  match code:
    case Nil{}: JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ "return bad('private worker missing return');}", next}
    case Con{instruction, rest}:
      match instruction:
        case JWAssign{slot, value}:
          jw_emit_block(ctx, rest, label, next, prefix ++ "$r[" ++ U32.show(slot) ++ "]=" ++ jw_emit_value(value, False{}) ++ ";")
        case JWDirectCall{slot, target, args}:
          kc(JWPrinted, jw_context_same(ctx, target), u =>
            kc(JWPrinted, jw_tail_result(rest, slot), u =>
              JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ jw_emit_tail_transfer(args, target), next}, u =>
              jw_emit_call_block(ctx, rest, label, next, prefix, slot, target, args)), u =>
            jw_emit_block(ctx, rest, label, next, prefix ++ "$r[" ++ U32.show(slot) ++ "]=" ++
              jw_context_name(ctx, target) ++ "(" ++ jw_emit_values(args, False{}) ++ ");"))
        case JWCase{layout, name, input, yes, no}:
          jw_emit_case_block(ctx, label, next, prefix, jw_emit_condition(layout, name, input, False{}), yes, no)
        case JWReturn{value}:
          JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ "$value=" ++ jw_emit_value(value, False{}) ++
            ";if(!$top)return $value;--$top;$pc=$returns[$top];$r=$registers[$top];$registers[$top]=null;continue;}", next}
        case JWImpossible{}:
          JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ "return bad('private worker impossible branch');}", next}

@unsafe
def jw_emit_call_block(+ctx: JWEmitContext, +rest: List<&2,JWInstruction>, +label: U32, +next: U32, +prefix: String,
  +slot: U32, +target: U32, +args: List<&2,JWValue>) -> JWPrinted:
  +after = jw_emit_block(ctx, rest, next, U32.inc(next), "$r[" ++ U32.show(slot) ++ "]=$value;")
  JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ "$returns[$top]=" ++ U32.show(next) ++
    ";$registers[$top++]=$r;$r=[" ++ jw_emit_values(args, False{}) ++ "];$pc=" ++ U32.show(target) ++ ";continue;}" ++
    jw_printed_code(after), jw_printed_next(after)}

@unsafe
def jw_emit_case_block(+ctx: JWEmitContext, +label: U32, +next: U32, +prefix: String, +condition: String,
  +yes: List<&2,JWInstruction>, +no: List<&2,JWInstruction>) -> JWPrinted:
  +left = jw_emit_block(ctx, yes, next, U32.add(next, 2), "")
  +right = jw_emit_block(ctx, no, U32.inc(next), jw_printed_next(left), "")
  JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ "$pc=(" ++ condition ++ ")?" ++ U32.show(next) ++ ":" ++
    U32.show(U32.inc(next)) ++ ";continue;}" ++ jw_printed_code(left) ++ jw_printed_code(right), jw_printed_next(right)}

@unsafe
def jw_emit_functions(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +at: U32, +next: U32) -> JWPrinted:
  match functions:
    case Nil{}: JWPrinted{"", next}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      +body = kc(JWPrinted, jw_context_same(ctx, at), u => jw_emit_block(ctx, code, at, next, ""), u => JWPrinted{"", next})
      +more = jw_emit_functions(ctx, rest, U32.inc(at), jw_printed_next(body))
      JWPrinted{jw_printed_code(body) ++ jw_printed_code(more), jw_printed_next(more)}

@unsafe
def jw_all_valid(+functions: List<&2,JWFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{JWFunction{name, arity, code, valid}, rest}: valid && jw_all_valid(rest)

@unsafe
def jw_wrappers(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +at: U32, +group: U32) -> String:
  match functions:
    case Nil{}: ""
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(String, jw_context_same(ctx, at), u =>
        "function " ++ j_region_name(name) ++ "$tree(" ++ j_region_parameters(0, arity) ++ "){return $worker" ++ U32.show(group) ++ "(" ++
          U32.show(at) ++ ",[" ++ j_region_vector_names("$p", 0, arity) ++ "]);}", u => "") ++ jw_wrappers(ctx, rest, U32.inc(at), group)

# Direct edges between different SCCs cannot grow with recursive input: their
# condensation graph is a DAG. Acyclic singleton functions need neither register
# vectors nor a dispatcher; the shared value printer emits scalar JS locals.
@unsafe
def jw_calls_target(+code: List<&2,JWInstruction>, +target: U32) -> Bool:
  match code:
    case Nil{}: False{}
    case Con{instruction, rest}:
      kc(Bool, jw_instruction_target(instruction, target), u => True{}, u => jw_calls_target(rest, target))

@unsafe
def jw_instruction_target(+instruction: JWInstruction, +target: U32) -> Bool:
  match instruction:
    case JWDirectCall{slot, called, args}: U32.is_eq(called, target)
    case JWCase{layout, name, input, yes, no}: jw_calls_target(yes, target) || jw_calls_target(no, target)
    case other: False{}

@unsafe
def jw_component_members(+components: List<&2,U32>, +group: U32) -> U32:
  match components:
    case Nil{}: 0
    case Con{member, rest}: U32.add(kc(U32, U32.is_eq(member, group), u => 1, u => 0), jw_component_members(rest, group))

@unsafe
def jw_register_bound(+code: List<&2,JWInstruction>, +bound: U32) -> U32:
  match code:
    case Nil{}: bound
    case Con{instruction, rest}: jw_register_bound(rest, jw_instruction_bound(instruction, bound))

@unsafe
def jw_instruction_bound(+instruction: JWInstruction, +bound: U32) -> U32:
  match instruction:
    case JWAssign{slot, value}: U32.max(bound, U32.inc(slot))
    case JWDirectCall{slot, target, args}: U32.max(bound, U32.inc(slot))
    case JWCase{layout, name, input, yes, no}: U32.max(jw_register_bound(yes, bound), jw_register_bound(no, bound))
    case other: bound

@unsafe
def jw_direct_locals(+at: U32, +arity: U32, +bound: U32) -> String:
  kc(String, U32.is_eq(at, bound), u => "", u =>
    "let $v" ++ U32.show(at) ++ kc(String, U32.is_lt(at, arity), u => "=$p" ++ U32.show(at), u => "") ++ ";" ++
      jw_direct_locals(U32.inc(at), arity, bound))

@unsafe
def jw_emit_direct(+ctx: JWEmitContext, +code: List<&2,JWInstruction>) -> String:
  match code:
    case Nil{}: "return bad('private worker missing return');"
    case Con{instruction, rest}:
      match instruction:
        case JWAssign{slot, value}: jw_emit_slot(slot, True{}) ++ "=" ++ jw_emit_value(value, True{}) ++ ";" ++ jw_emit_direct(ctx, rest)
        case JWDirectCall{slot, target, args}: jw_emit_slot(slot, True{}) ++ "=" ++ jw_context_name(ctx, target) ++
          "(" ++ jw_emit_values(args, True{}) ++ ");" ++ jw_emit_direct(ctx, rest)
        case JWCase{layout, name, input, yes, no}:
          "if(" ++ jw_emit_condition(layout, name, input, True{}) ++ "){" ++ jw_emit_direct(ctx, yes) ++ "}else{" ++ jw_emit_direct(ctx, no) ++ "}"
        case JWReturn{value}: "return " ++ jw_emit_value(value, True{}) ++ ";"
        case JWImpossible{}: "return bad('private worker impossible branch');"

@unsafe
def jw_emit_components(+functions: List<&2,JWFunction>, +components: List<&2,U32>, +todo: List<&2,JWFunction>, +at: U32, +total: U32) -> String:
  match todo:
    case Nil{}: ""
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(String, U32.is_eq(jw_component_at(components, at), at), u =>
        jw_emit_component(JWEmitContext{functions, components, at}, functions, name, arity, code, at, total,
          U32.is_gt(jw_component_members(components, at), 1) || jw_calls_target(code, at)), u => "") ++
        jw_emit_components(functions, components, rest, U32.inc(at), total)

@unsafe
def jw_emit_component(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +name: String, +arity: U32,
  +code: List<&2,JWInstruction>, +group: U32, +total: U32, +recursive: Bool) -> String:
  kc(String, recursive, u =>
    "function $worker" ++ U32.show(group) ++ "($pc,$r){/* private first-order continuation component */let $value,$top=0;const $returns=[],$registers=[];for(;;){switch($pc){" ++
      jw_printed_code(jw_emit_functions(ctx, functions, 0, total)) ++ "default:return bad('private worker pc invariant');}}}" ++
      jw_wrappers(ctx, functions, 0, group), u =>
    "function " ++ j_region_name(name) ++ "$tree(" ++ j_region_parameters(0, arity) ++ "){/* private first-order acyclic function */" ++
      jw_direct_locals(0, arity, jw_register_bound(code, arity)) ++ jw_emit_direct(ctx, code) ++ "}")

@unsafe
def j_worker_declarations(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  j_worker_declarations_done(defs, jw_simplify_functions(jw_functions(book, defs, defs)))

@unsafe
def j_worker_declarations_done(+defs: List<&2,KDef>, +functions: List<&2,JWFunction>) -> String:
  kc(String, Bool.not(List.is_empty(&2,KDef, defs)) && jw_all_valid(functions), u =>
    jw_declarations_components(functions, j_region_def_count(defs), jw_components(functions)), u => "")

@unsafe
def jw_declarations_components(+functions: List<&2,JWFunction>, +total: U32, +plan: Maybe<&2,List<&2,U32>>) -> String:
  match plan:
    case None{}: ""
    case Some{components}: jw_emit_components(functions, components, functions, 0, total)
