# Emit straight-line basic blocks. Only branches and suspended private calls
# change the PC; arithmetic and construction do not dispatch through an evaluator.
type JWEmission is Data:
  JWEmission{+code: String, +numberNat: Bool, +recursive: Bool}

@unsafe
def jw_emit_value(+v: JWValue, +direct: Bool) -> String:
  match v:
    case JWSlot{slot}: jw_emit_slot(slot, direct)
    case JWLiteral{code}: code
    case JWNat{number}: U32.show(number) ++ "n"
    case JWGlobal{name, layout}: "get(G," ++ j_quote(name) ++ ")"
    case JWProject{layout, input, index}: jw_emit_project(layout, jw_emit_value(input, direct), index)
    case JWPrimitive{name, args}:
      j_primitive_code(name, "(" ++ jw_emit_at(args, 0, direct) ++ ")", "(" ++ jw_emit_at(args, 1, direct) ++ ")")
    case JWConstruct{layout, name, fields}: jw_emit_construct(layout, name, fields, direct)
    case JWNative{name, args}: "callOwned(get(G," ++ j_quote(name) ++ "),[" ++ jw_emit_values(args, direct) ++ "])"
    case JWNumberOp{op, args}: jw_number_code(op, "(" ++ jw_emit_at(args, 0, direct) ++ ")", "(" ++ jw_emit_at(args, 1, direct) ++ ")")

# Exact native layouts remove constructor dispatch and its temporary vector.
# The typed IR already evaluated nontrivial fields; inline literals keep order.
@unsafe
def jw_emit_construct(+layout: String, +name: String, +fields: List<&2,JWValue>, +direct: Bool) -> String:
  kc(String, String.eq(layout, "tagged"), u =>
    "({$:" ++ j_quote(name) ++ "," ++ jw_emit_fields(fields, direct, 0) ++ "})", u =>
    jw_emit_construct_done(name, fields, direct, jw_emit_construct_native(layout, name, fields, direct)))

@unsafe
def jw_emit_construct_done(+name: String, +fields: List<&2,JWValue>, +direct: Bool, +native: String) -> String:
  kc(String, String.eq(native, ""), u =>
    "ctor(" ++ j_quote(name) ++ ",[" ++ jw_emit_values(fields, direct) ++ "])", u => native)

# Layout proves the canonical native owner. Names and arities are still exact;
# unsupported combinations retain ctor. SCon repeats only a typed Char leaf/slot.
@unsafe
def jw_emit_construct_native(+layout: String, +name: String, +fields: List<&2,JWValue>, +direct: Bool) -> String:
  match fields:
    case Nil{}:
      kc(String, String.eq(layout, "bool") && String.eq(name, "True"), u => "true", u =>
      kc(String, String.eq(layout, "bool") && String.eq(name, "False"), u => "false", u =>
      kc(String, String.eq(layout, "string") && String.eq(name, "SNil"), u => "''", u => "")))
    case Con{one, Nil{}}:
      kc(String, String.eq(layout, "char") && String.eq(name, "Chr"),
        u => "checkedChar(" ++ jw_emit_value(one, direct) ++ ")", u => "")
    case Con{left, Con{right, Nil{}}}:
      kc(String, String.eq(layout, "tuple") && String.eq(name, "Tuple"),
        u => "[" ++ jw_emit_value(left, direct) ++ "," ++ jw_emit_value(right, direct) ++ "]", u =>
      kc(String, String.eq(layout, "string") && String.eq(name, "SCon"), u =>
        "((typeof " ++ jw_emit_value(left, direct) ++ "==='string'?" ++ jw_emit_value(left, direct) ++
        ":String.fromCodePoint(" ++ jw_emit_value(left, direct) ++ "))+" ++ jw_emit_value(right, direct) ++ ")", u => ""))
    case other: ""

@unsafe
def jw_emit_fields(+fields: List<&2,JWValue>, +direct: Bool, +at: U32) -> String:
  match fields:
    case Nil{}: ""
    case Con{value, rest}: "_" ++ U32.show(at) ++ ":" ++ jw_emit_value(value, direct) ++ "," ++ jw_emit_fields(rest, direct, U32.inc(at))

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
  kc(String, String.eq(layout, "nat") || String.eq(layout, "nat-number"),
    u => "(" ++ input ++ kc(String, String.eq(layout, "nat"), u => "-1n)", u => "-1)"), u =>
  kc(String, String.eq(layout, "tuple"), u => "(" ++ input ++ ")[" ++ U32.show(index) ++ "]", u =>
  kc(String, String.eq(layout, "char"), u => "(typeof " ++ input ++ "==='string'?" ++ input ++ ".codePointAt(0):" ++ input ++ ")", u =>
  kc(String, String.eq(layout, "string"), u => kc(String, U32.is_eq(index, 0),
    u => input ++ ".codePointAt(0)", u => input ++ ".slice(" ++ input ++ ".codePointAt(0)>65535?2:1)"),
     u => kc(String, String.eq(layout, "tagged"), u => "(" ++ input ++ ")._" ++ U32.show(index),
       u => "(" ++ input ++ ").a[" ++ U32.show(index) ++ "]")))))

@unsafe
def jw_emit_condition(+layout: String, +name: String, +input: JWValue, +direct: Bool) -> String:
  +value = jw_emit_value(input, direct)
  kc(String, String.eq(layout, "bool"), u => value ++ "===" ++ kc(String, String.eq(name, "True"), u => "true", u => "false"), u =>
  kc(String, String.eq(layout, "nat") || String.eq(layout, "nat-number"),
    u => value ++ kc(String, String.eq(name, "Zero"), u => "===0", u => "!==0") ++
      kc(String, String.eq(layout, "nat"), u => "n", u => ""), u =>
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
        case JWCallValues{slots, target, args}:
          kc(JWPrinted, jw_context_same(ctx, target), u =>
            kc(JWPrinted, jw_values_tail(rest, slots), u =>
              JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ jw_emit_tail_transfer(args, target), next}, u =>
              jw_emit_values_call_block(ctx, rest, label, next, prefix, slots, target, args)), u =>
            jw_emit_block(ctx, rest, label, next, prefix ++ jw_values_capture(slots,
              jw_context_name(ctx, target) ++ "(" ++ jw_emit_values(args, False{}) ++ ")", False{})))
        case JWReturnValues{values}:
          JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ jw_values_return(values, False{}), next}
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
def jw_wrappers(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +at: U32, +group: U32, +tailOnly: Bool) -> String:
  match functions:
    case Nil{}: ""
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(String, jw_context_same(ctx, at), u =>
        "function " ++ j_region_name(name) ++ "$tree(" ++ j_region_parameters(0, arity) ++ "){" ++
          kc(String, tailOnly, u => "/* private tail-only component */", u =>
            "if($workerBudget===0)return $worker" ++ U32.show(group) ++ "(" ++ U32.show(at) ++ ",[" ++
              j_region_vector_names("$p", 0, arity) ++ "]);--$workerBudget;try{") ++
          "return $native" ++ U32.show(group) ++ "(" ++ U32.show(at) ++ "," ++ j_region_vector_names("$p", 0, arity) ++ ");" ++
          kc(String, tailOnly, u => "", u => "}finally{++$workerBudget;}") ++ "}", u => "") ++
        jw_wrappers(ctx, rest, U32.inc(at), group, tailOnly)

# Native recursion uses the same scalar frame for exact tail transfers. Every
# argument is captured before any slot is overwritten, including permutations.
@unsafe
def jw_native_capture(+args: List<&2,JWValue>, +at: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{value, rest}: "const $next" ++ U32.show(at) ++ "=" ++ jw_emit_value(value, True{}) ++ ";" ++ jw_native_capture(rest, U32.inc(at))

@unsafe
def jw_native_store(+args: List<&2,JWValue>, +at: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{value, rest}: "$v" ++ U32.show(at) ++ "=$next" ++ U32.show(at) ++ ";" ++ jw_native_store(rest, U32.inc(at))

@unsafe
def jw_native_tail(+args: List<&2,JWValue>, +target: U32) -> String:
  jw_native_capture(args, 0) ++ jw_native_store(args, 0) ++ "$pc=" ++ U32.show(target) ++ ";continue;"

# The native function shares only scalar storage between entries of one SCC.
# Each invocation owns a new frame; non-tail calls still use budgeted wrappers.
@unsafe
def jw_component_bound(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +at: U32, +registers: Bool) -> U32:
  match functions:
    case Nil{}: 0
    case Con{JWFunction{name, arity, code, valid}, rest}:
      U32.max(kc(U32, jw_context_same(ctx, at), u => kc(U32, registers, u => jw_register_bound(code, arity), u => arity), u => 0),
        jw_component_bound(ctx, rest, U32.inc(at), registers))

@unsafe
def jw_native_entries(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +at: U32) -> String:
  match functions:
    case Nil{}: ""
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(String, jw_context_same(ctx, at), u => "case " ++ U32.show(at) ++ ":{" ++ jw_emit_direct(ctx, code) ++ "}", u => "") ++
        jw_native_entries(ctx, rest, U32.inc(at))

@unsafe
def jw_native_component(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +group: U32, +arity: U32, +bound: U32) -> String:
  "function $native" ++ U32.show(group) ++ "($pc," ++ j_region_vector_names("$v", 0, arity) ++ "){/* private first-order native component */" ++
    jw_direct_locals(arity, 0, bound) ++ "for(;;){switch($pc){" ++ jw_native_entries(ctx, functions, 0) ++
    "default:return bad('private native pc invariant');}}}"

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
    case JWCallValues{slots, called, args}: U32.is_eq(called, target)
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
    case JWCallValues{slots, target, args}: jw_values_slot_bound(slots, bound)
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
        case JWDirectCall{slot, target, args}:
          kc(String, jw_context_same(ctx, target) && jw_tail_result(rest, slot), u => jw_native_tail(args, target), u =>
            jw_emit_slot(slot, True{}) ++ "=" ++ jw_context_name(ctx, target) ++
              "(" ++ jw_emit_values(args, True{}) ++ ");" ++ jw_emit_direct(ctx, rest))
        case JWCallValues{slots, target, args}:
          kc(String, jw_context_same(ctx, target) && jw_values_tail(rest, slots), u => jw_native_tail(args, target), u =>
            jw_values_capture(slots, jw_context_name(ctx, target) ++ "(" ++ jw_emit_values(args, True{}) ++ ")", True{}) ++ jw_emit_direct(ctx, rest))
        case JWReturnValues{values}: jw_values_return(values, True{})
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

# Every recursive edge uses exactly the same tail predicate as the native
# printer. Cross-component calls follow the proved DAG and cannot recurse here.
@unsafe
def jw_tail_component(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +at: U32) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      (Bool.not(jw_context_same(ctx, at)) || (valid && jw_tail_code(ctx, code))) &&
        jw_tail_component(ctx, rest, U32.inc(at))

@unsafe
def jw_tail_code(+ctx: JWEmitContext, +code: List<&2,JWInstruction>) -> Bool:
  match code:
    case Nil{}: True{}
    case Con{JWDirectCall{slot, target, args}, rest}:
      (Bool.not(jw_context_same(ctx, target)) || jw_tail_result(rest, slot)) && jw_tail_code(ctx, rest)
    case Con{JWCallValues{slots, target, args}, rest}:
      (Bool.not(jw_context_same(ctx, target)) || jw_values_tail(rest, slots)) && jw_tail_code(ctx, rest)
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      jw_tail_code(ctx, yes) && jw_tail_code(ctx, no) && jw_tail_code(ctx, rest)
    case Con{other, rest}: jw_tail_code(ctx, rest)

@unsafe
def jw_emit_recursive(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +group: U32, +total: U32, +tailOnly: Bool) -> String:
  kc(String, tailOnly, u => "", u =>
    "function $worker" ++ U32.show(group) ++ "($pc,$r){/* private first-order continuation component */let $value,$top=0;const $returns=[],$registers=[];for(;;){switch($pc){" ++
      jw_printed_code(jw_emit_functions(ctx, functions, 0, total)) ++ "default:return bad('private worker pc invariant');}}}") ++
    jw_native_component(ctx, functions, group, jw_component_bound(ctx, functions, 0, False{}), jw_component_bound(ctx, functions, 0, True{})) ++
    jw_wrappers(ctx, functions, 0, group, tailOnly)

@unsafe
def jw_emit_component(+ctx: JWEmitContext, +functions: List<&2,JWFunction>, +name: String, +arity: U32,
  +code: List<&2,JWInstruction>, +group: U32, +total: U32, +recursive: Bool) -> String:
  kc(String, recursive, u =>
    jw_emit_recursive(ctx, functions, group, total, jw_tail_component(ctx, functions, 0)), u =>
    "function " ++ j_region_name(name) ++ "$tree(" ++ j_region_parameters(0, arity) ++ "){/* private first-order acyclic function */" ++
      jw_direct_locals(0, arity, jw_register_bound(code, arity)) ++ jw_emit_direct(ctx, code) ++ "}")

@unsafe
def j_worker_emission(+book: List<&2,KDef>, +defs: List<&2,KDef>, +entry: U32) -> JWEmission:
  j_worker_emission_done(defs, jw_values_functions(jw_simplify_functions(jw_functions(book, defs, defs)), entry))

@unsafe
def j_worker_emission_done(+defs: List<&2,KDef>, +functions: List<&2,JWFunction>) -> JWEmission:
  kc(JWEmission, Bool.not(List.is_empty(&2,KDef, defs)) && jw_all_valid(functions), u =>
    jw_emission_mode(functions, j_region_def_count(defs), jw_nat_functions_valid(functions)), u => JWEmission{"", False{}, False{}})

@unsafe
def jw_emission_mode(+functions: List<&2,JWFunction>, +total: U32, +numberNat: Bool) -> JWEmission:
  jw_declarations_components(kc(List<&2,JWFunction>, numberNat, u => jw_nat_functions(functions), u => functions),
    total, jw_components(functions), numberNat)

# The successful SCC labels already prove all private edges. A non-canonical
# member proves a mutual cycle; singleton recursion is an explicit self-call.
# This bounded fact ranks public entries, never excludes private acyclic helpers.
@unsafe
def jw_graph_recursive(+functions: List<&2,JWFunction>, +components: List<&2,U32>, +at: U32) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      match components:
        case Nil{}: False{}
        case Con{group, remaining}:
          Bool.not(U32.is_eq(group, at)) || jw_calls_target(code, at) ||
            jw_graph_recursive(rest, remaining, U32.inc(at))

@unsafe
def jw_declarations_components(+functions: List<&2,JWFunction>, +total: U32, +plan: Maybe<&2,List<&2,U32>>, +numberNat: Bool) -> JWEmission:
  match plan:
    case None{}: JWEmission{"", False{}, False{}}
    case Some{components}:
      JWEmission{kc(String, numberNat, u => jw_nat_declarations(), u => "") ++
        jw_values_declarations(functions) ++ "let $workerBudget=32;" ++ jw_emit_components(functions, components, functions, 0, total),
        numberNat, jw_graph_recursive(functions, components, 0)}

# Private multiple results retain scalar formals but return one flat vector.
# The typed transformation is identical to the scalar-register experiment.
@unsafe
def jw_values_slot_bound(+slots: List<&2,U32>, +bound: U32) -> U32:
  match slots:
    case Nil{}: bound
    case Con{slot, rest}: jw_values_slot_bound(rest, U32.max(bound, U32.inc(slot)))

@unsafe
def jw_values_tail(+code: List<&2,JWInstruction>, +slots: List<&2,U32>) -> Bool:
  match code:
    case Con{JWReturnValues{values}, Nil{}}: jw_values_same_slots(values, slots)
    case other: False{}

@unsafe
def jw_values_same_slots(+values: List<&2,JWValue>, +slots: List<&2,U32>) -> Bool:
  match values:
    case Nil{}: List.is_empty(&2,U32, slots)
    case Con{JWSlot{at}, rest}:
      match slots:
        case Con{slot, more}: U32.is_eq(at, slot) && jw_values_same_slots(rest, more)
        case Nil{}: False{}
    case other: False{}

# A fresh private vector evaluates every result once before either native
# return or machine-frame restoration. It never enters the public ABI.
@unsafe
def jw_values_return(+values: List<&2,JWValue>, +direct: Bool) -> String:
  kc(String, direct, u => "return [" ++ jw_emit_values(values, True{}) ++ "];", u =>
    "$value=[" ++ jw_emit_values(values, False{}) ++ "];if(!$top)return $value;--$top;$pc=$returns[$top];$r=$registers[$top];$registers[$top]=null;continue;}")

# The captured vector is fresh, private and has all indexed own fields. Reads
# cannot observe a prototype getter or alias a destination frame slot.
@unsafe
def jw_values_store(+slots: List<&2,U32>, +direct: Bool, +at: U32) -> String:
  match slots:
    case Nil{}: ""
    case Con{slot, rest}: jw_emit_slot(slot, direct) ++ "=$results[" ++ U32.show(at) ++ "];" ++ jw_values_store(rest, direct, U32.inc(at))

@unsafe
def jw_values_capture(+slots: List<&2,U32>, +first: String, +direct: Bool) -> String:
  "{const $results=" ++ first ++ ";" ++ jw_values_store(slots, direct, 0) ++ "}"

@unsafe
def jw_emit_values_call_block(+ctx: JWEmitContext, +rest: List<&2,JWInstruction>, +label: U32, +next: U32, +prefix: String,
  +slots: List<&2,U32>, +target: U32, +args: List<&2,JWValue>) -> JWPrinted:
  +after = jw_emit_block(ctx, rest, next, U32.inc(next), jw_values_capture(slots, "$value", False{}))
  JWPrinted{"case " ++ U32.show(label) ++ ":{" ++ prefix ++ "$returns[$top]=" ++ U32.show(next) ++
    ";$registers[$top++]=$r;$r=[" ++ jw_emit_values(args, False{}) ++ "];$pc=" ++ U32.show(target) ++ ";continue;}" ++
    jw_printed_code(after), jw_printed_next(after)}

@unsafe
def jw_values_used(+code: List<&2,JWInstruction>) -> Bool:
  match code:
    case Nil{}: False{}
    case Con{JWCallValues{slots, target, args}, rest}: True{}
    case Con{JWReturnValues{values}, rest}: True{}
    case Con{JWCase{layout, name, input, yes, no}, rest}: jw_values_used(yes) || jw_values_used(no) || jw_values_used(rest)
    case Con{other, rest}: jw_values_used(rest)

@unsafe
def jw_values_declarations(+fs: List<&2,JWFunction>) -> String:
  match fs:
    case Nil{}: ""
    case Con{JWFunction{name, arity, code, valid}, rest}:
      kc(String, jw_values_used(code), u => "/* private flat tuple transport */",
        u => jw_values_declarations(rest))
