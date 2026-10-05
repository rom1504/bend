# Private tuple transport. All use scans inspect complete branch-local code;
# unknown/effectful values are retained. No source names or public ABI changes.
type JWVShape is Data:
  JWVShape{+valid: Bool, +seen: Bool}

type JWVCode is Data:
  JWVCode{+code: List<&2,JWInstruction>, +next: U32}

@unsafe
def jwv_count(+xs: List<&2,JWValue>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x, rest}: U32.inc(jwv_count(rest))

@unsafe
def jwv_slot_count(+xs: List<&2,U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x, rest}: U32.inc(jwv_slot_count(rest))

@unsafe
def jwv_at(+xs: List<&2,JWValue>, +at: U32) -> JWValue:
  match xs:
    case Nil{}: JWLiteral{"null"}
    case Con{x, rest}: kc(JWValue, U32.is_eq(at, 0), u => x, u => jwv_at(rest, U32.sub(at, 1)))

@unsafe
def jwv_slot_at(+xs: List<&2,U32>, +at: U32) -> U32:
  match xs:
    case Nil{}: 4294967295
    case Con{x, rest}: kc(U32, U32.is_eq(at, 0), u => x, u => jwv_slot_at(rest, U32.sub(at, 1)))

@unsafe
def jwv_has(+xs: List<&2,U32>, +slot: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x, rest}: U32.is_eq(x, slot) || jwv_has(rest, slot)

@unsafe
def jwv_forget(+xs: List<&2,U32>, +slot: U32) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{x, rest}: kc(List<&2,U32>, U32.is_eq(x, slot), u => jwv_forget(rest, slot), u => Con{x, jwv_forget(rest, slot)})

# With projected=true, exact tuple field reads are the only permitted use.
@unsafe
def jwv_use(+v: JWValue, +slot: U32, +projected: Bool) -> Bool:
  match v:
    case JWSlot{at}: U32.is_eq(at, slot)
    case JWProject{layout, JWSlot{at}, index}:
      U32.is_eq(at, slot) && Bool.not(projected && String.eq(layout, "tuple") && U32.is_lt(index, 2))
    case JWProject{layout, input, index}: jwv_use(input, slot, projected)
    case JWPrimitive{name, args}: jwv_uses(args, slot, projected)
    case JWConstruct{layout, name, fields}: jwv_uses(fields, slot, projected)
    case JWNative{name, args}: jwv_uses(args, slot, projected)
    case JWNumberOp{op, args}: jwv_uses(args, slot, projected)
    case other: False{}

@unsafe
def jwv_uses(+vs: List<&2,JWValue>, +slot: U32, +projected: Bool) -> Bool:
  match vs:
    case Nil{}: False{}
    case Con{v, rest}: jwv_use(v, slot, projected) || jwv_uses(rest, slot, projected)

@unsafe
def jwv_code_use(+code: List<&2,JWInstruction>, +slot: U32, +projected: Bool) -> Bool:
  match code:
    case Nil{}: False{}
    case Con{i, rest}: jwv_instruction_use(i, slot, projected) || jwv_code_use(rest, slot, projected)

@unsafe
def jwv_instruction_use(+i: JWInstruction, +slot: U32, +projected: Bool) -> Bool:
  match i:
    case JWAssign{at, value}: U32.is_eq(at, slot) || jwv_use(value, slot, projected)
    case JWDirectCall{at, target, args}: U32.is_eq(at, slot) || jwv_uses(args, slot, projected)
    case JWCallValues{slots, target, args}: jwv_has(slots, slot) || jwv_uses(args, slot, projected)
    case JWCase{layout, name, input, yes, no}:
      jwv_use(input, slot, projected) || jwv_code_use(yes, slot, projected) || jwv_code_use(no, slot, projected)
    case JWReturn{value}: jwv_use(value, slot, projected)
    case JWReturnValues{values}: jwv_uses(values, slot, projected)
    case JWImpossible{}: False{}

# Shared renaming/projection substitution. The newly supplied field slots are
# already in the destination numbering and must not themselves be shifted.
@unsafe
def jwv_shift(+slot: U32, +start: U32, +amount: U32) -> U32:
  kc(U32, U32.is_lt(slot, start), u => slot, u => U32.add(slot, amount))

@unsafe
def jwv_map(+v: JWValue, +slot: U32, +left: U32, +right: U32, +start: U32, +amount: U32) -> JWValue:
  match v:
    case JWSlot{at}: JWSlot{jwv_shift(at, start, amount)}
    case JWProject{layout, JWSlot{at}, index}:
      kc(JWValue, U32.is_eq(at, slot) && String.eq(layout, "tuple") && U32.is_lt(index, 2),
        u => JWSlot{kc(U32, U32.is_eq(index, 0), u => left, u => right)},
        u => JWProject{layout, JWSlot{jwv_shift(at, start, amount)}, index})
    case JWProject{layout, input, index}: JWProject{layout, jwv_map(input, slot, left, right, start, amount), index}
    case JWPrimitive{name, args}: JWPrimitive{name, jwv_maps(args, slot, left, right, start, amount)}
    case JWConstruct{layout, name, fields}: JWConstruct{layout, name, jwv_maps(fields, slot, left, right, start, amount)}
    case JWNative{name, args}: JWNative{name, jwv_maps(args, slot, left, right, start, amount)}
    case JWNumberOp{op, args}: JWNumberOp{op, jwv_maps(args, slot, left, right, start, amount)}
    case other: v

@unsafe
def jwv_maps(+vs: List<&2,JWValue>, +slot: U32, +left: U32, +right: U32, +start: U32, +amount: U32) -> List<&2,JWValue>:
  match vs:
    case Nil{}: Nil{}
    case Con{v, rest}: Con{jwv_map(v, slot, left, right, start, amount), jwv_maps(rest, slot, left, right, start, amount)}

@unsafe
def jwv_shift_slots(+xs: List<&2,U32>, +start: U32, +amount: U32) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{x, rest}: Con{jwv_shift(x, start, amount), jwv_shift_slots(rest, start, amount)}

@unsafe
def jwv_map_code(+code: List<&2,JWInstruction>, +slot: U32, +left: U32, +right: U32, +start: U32, +amount: U32) -> List<&2,JWInstruction>:
  match code:
    case Nil{}: Nil{}
    case Con{i, rest}: Con{jwv_map_instruction(i, slot, left, right, start, amount), jwv_map_code(rest, slot, left, right, start, amount)}

@unsafe
def jwv_map_instruction(+i: JWInstruction, +slot: U32, +left: U32, +right: U32, +start: U32, +amount: U32) -> JWInstruction:
  match i:
    case JWAssign{at, value}: JWAssign{jwv_shift(at, start, amount), jwv_map(value, slot, left, right, start, amount)}
    case JWDirectCall{at, target, args}: JWDirectCall{jwv_shift(at, start, amount), target, jwv_maps(args, slot, left, right, start, amount)}
    case JWCallValues{slots, target, args}: JWCallValues{jwv_shift_slots(slots, start, amount), target, jwv_maps(args, slot, left, right, start, amount)}
    case JWCase{layout, name, input, yes, no}:
      JWCase{layout, name, jwv_map(input, slot, left, right, start, amount),
        jwv_map_code(yes, slot, left, right, start, amount), jwv_map_code(no, slot, left, right, start, amount)}
    case JWReturn{value}: JWReturn{jwv_map(value, slot, left, right, start, amount)}
    case JWReturnValues{values}: JWReturnValues{jwv_maps(values, slot, left, right, start, amount)}
    case JWImpossible{}: JWImpossible{}

@unsafe
def jwv_split_values(+vs: List<&2,JWValue>, +at: U32) -> List<&2,JWValue>:
  List.append(&2,JWValue, jwv_first_values(vs, at), Con{JWProject{"tuple", jwv_at(vs, at), 1}, Nil{}})

@unsafe
def jwv_first_values(+vs: List<&2,JWValue>, +at: U32) -> List<&2,JWValue>:
  match vs:
    case Nil{}: Nil{}
    case Con{v, rest}: kc(List<&2,JWValue>, U32.is_eq(at, 0),
      u => Con{JWProject{"tuple", v, 0}, rest}, u => Con{v, jwv_first_values(rest, U32.sub(at, 1))})

@unsafe
def jwv_is_slot(+v: JWValue) -> Bool:
  match v:
    case JWSlot{slot}: True{}
    case JWProject{layout, input, index}: String.eq(layout, "tuple") && U32.is_lt(index, 2) && jwv_is_slot(input)
    case other: False{}

@unsafe
def jwv_parameter_calls(+fs: List<&2,JWFunction>, +target: U32, +at: U32, +arity: U32) -> Bool:
  match fs:
    case Nil{}: True{}
    case Con{JWFunction{name, count, code, valid}, rest}:
      jwv_parameter_code(code, target, at, arity) && jwv_parameter_calls(rest, target, at, arity)

@unsafe
def jwv_parameter_code(+code: List<&2,JWInstruction>, +target: U32, +at: U32, +arity: U32) -> Bool:
  match code:
    case Nil{}: True{}
    case Con{JWDirectCall{slot, called, args}, rest}:
      (Bool.not(U32.is_eq(called, target)) || (U32.is_eq(jwv_count(args), arity) && jwv_is_slot(jwv_at(args, at)))) && jwv_parameter_code(rest, target, at, arity)
    case Con{JWCallValues{slots, called, args}, rest}:
      (Bool.not(U32.is_eq(called, target)) || (U32.is_eq(jwv_count(args), arity) && jwv_is_slot(jwv_at(args, at)))) && jwv_parameter_code(rest, target, at, arity)
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      jwv_parameter_code(yes, target, at, arity) && jwv_parameter_code(no, target, at, arity) && jwv_parameter_code(rest, target, at, arity)
    case Con{other, rest}: jwv_parameter_code(rest, target, at, arity)

@unsafe
def jwv_parameter_rewrite(+fs: List<&2,JWFunction>, +target: U32, +at: U32, +arity: U32, +index: U32) -> List<&2,JWFunction>:
  match fs:
    case Nil{}: Nil{}
    case Con{JWFunction{name, count, code, valid}, rest}:
      Con{JWFunction{name, kc(U32, U32.is_eq(index, target), u => U32.inc(count), u => count),
        jwv_parameter_edges(kc(List<&2,JWInstruction>, U32.is_eq(index, target),
          u => jwv_map_code(code, at, at, arity, arity, 1), u => code), target, at), valid},
        jwv_parameter_rewrite(rest, target, at, arity, U32.inc(index))}

@unsafe
def jwv_parameter_edges(+code: List<&2,JWInstruction>, +target: U32, +at: U32) -> List<&2,JWInstruction>:
  match code:
    case Nil{}: Nil{}
    case Con{i, rest}: Con{jwv_parameter_edge(i, target, at), jwv_parameter_edges(rest, target, at)}

@unsafe
def jwv_parameter_edge(+i: JWInstruction, +target: U32, +at: U32) -> JWInstruction:
  match i:
    case JWDirectCall{slot, called, args}: JWDirectCall{slot, called,
      kc(List<&2,JWValue>, U32.is_eq(called, target), u => jwv_split_values(args, at), u => args)}
    case JWCallValues{slots, called, args}: JWCallValues{slots, called,
      kc(List<&2,JWValue>, U32.is_eq(called, target), u => jwv_split_values(args, at), u => args)}
    case JWCase{layout, name, input, yes, no}: JWCase{layout, name, input, jwv_parameter_edges(yes, target, at), jwv_parameter_edges(no, target, at)}
    case other: i

@unsafe
def jwv_function(+fs: List<&2,JWFunction>, +at: U32) -> Maybe<&2,JWFunction>:
  match fs:
    case Nil{}: None{}
    case Con{f, rest}: kc(Maybe<&2,JWFunction>, U32.is_eq(at, 0), u => Some{f}, u => jwv_function(rest, U32.sub(at, 1)))

@unsafe
def jwv_parameters(+fs: List<&2,JWFunction>, +entry: U32, +target: U32, +at: U32, +local: U32, +fuel: U32) -> List<&2,JWFunction>:
  kc(List<&2,JWFunction>, U32.is_eq(fuel, 0), u => fs, u =>
    jwv_parameters_next(fs, entry, target, at, local, fuel, jwv_function(fs, target)))

@unsafe
def jwv_parameters_next(+fs: List<&2,JWFunction>, +entry: U32, +target: U32, +at: U32, +local: U32, +fuel: U32, +found: Maybe<&2,JWFunction>) -> List<&2,JWFunction>:
  match found:
    case None{}: fs
    case Some{JWFunction{name, arity, code, valid}}:
      kc(List<&2,JWFunction>, U32.is_eq(target, entry) || U32.is_eq(local, 0) || Bool.not(U32.is_lt(at, arity)) || U32.is_gt(arity, 11),
        u => jwv_parameters(fs, entry, U32.inc(target), 0, 4, fuel), u =>
        kc(List<&2,JWFunction>, valid && Bool.not(jwv_code_use(code, at, True{})) && jwv_code_use(code, at, False{}) && jwv_parameter_calls(fs, target, at, arity),
          u => jwv_parameters(jwv_clean_functions(jwv_parameter_rewrite(fs, target, at, arity, 0)), entry, target, at, U32.sub(local, 1), U32.sub(fuel, 1)),
          u => jwv_parameters(fs, entry, target, U32.inc(at), local, fuel)))

# Only dominated canonical tuple construction/aliases provide return shape.
# The fact set stores shape, never substitutes an unevaluated field expression.
@unsafe
def jwv_tuple(+v: JWValue, +facts: List<&2,U32>) -> Bool:
  match v:
    case JWSlot{slot}: jwv_has(facts, slot)
    case JWConstruct{layout, name, Con{a, Con{b, Nil{}}}}: String.eq(layout, "tuple") && String.eq(name, "Tuple")
    case other: False{}

# Returning an inline constructor would duplicate its field evaluations when
# split. Require the lowered, already materialized slot form instead.
@unsafe
def jwv_return_tuple(+v: JWValue, +facts: List<&2,U32>) -> Bool:
  match v:
    case JWSlot{slot}: jwv_has(facts, slot)
    case other: False{}

@unsafe
def jwv_facts(+facts: List<&2,U32>, +slot: U32, +value: JWValue) -> List<&2,U32>:
  kc(List<&2,U32>, jwv_tuple(value, facts), u => kc(List<&2,U32>, U32.is_lt(jwv_slot_count(facts), 64),
    u => Con{slot, jwv_forget(facts, slot)}, u => jwv_forget(facts, slot)), u => jwv_forget(facts, slot))

@unsafe
def jwv_drop_slots(+facts: List<&2,U32>, +slots: List<&2,U32>) -> List<&2,U32>:
  match slots:
    case Nil{}: facts
    case Con{slot, rest}: jwv_drop_slots(jwv_forget(facts, slot), rest)

@unsafe
def jwv_shape_join(+a: JWVShape, +b: JWVShape) -> JWVShape:
  match a:
    case JWVShape{av, ah}:
      match b:
        case JWVShape{bv, bh}: JWVShape{av && bv, ah || bh}

@unsafe
def jwv_shape_ok(+shape: JWVShape) -> Bool:
  match shape:
    case JWVShape{valid, seen}: valid && seen

@unsafe
def jwv_return_shape(+code: List<&2,JWInstruction>, +facts: List<&2,U32>, +at: U32) -> JWVShape:
  match code:
    case Nil{}: JWVShape{False{}, False{}}
    case Con{JWAssign{slot, value}, rest}: jwv_return_shape(rest, jwv_facts(facts, slot, value), at)
    case Con{JWDirectCall{slot, target, args}, rest}: jwv_return_shape(rest, jwv_forget(facts, slot), at)
    case Con{JWCallValues{slots, target, args}, rest}: jwv_return_shape(rest, jwv_drop_slots(facts, slots), at)
    case Con{JWCase{layout, name, input, yes, no}, Nil{}}:
      jwv_shape_join(jwv_return_shape(yes, facts, at), jwv_return_shape(no, facts, at))
    case Con{JWReturn{value}, Nil{}}: JWVShape{U32.is_eq(at, 0) && jwv_return_tuple(value, facts), True{}}
    case Con{JWReturnValues{values}, Nil{}}:
      JWVShape{U32.is_lt(at, jwv_count(values)) && U32.is_lt(jwv_count(values), 4) && jwv_return_tuple(jwv_at(values, at), facts), True{}}
    case Con{JWImpossible{}, Nil{}}: JWVShape{True{}, False{}}
    case other: JWVShape{False{}, False{}}

@unsafe
def jwv_result_calls(+fs: List<&2,JWFunction>, +target: U32, +at: U32) -> Bool:
  match fs:
    case Nil{}: True{}
    case Con{JWFunction{name, arity, code, valid}, rest}: jwv_result_code(code, target, at) && jwv_result_calls(rest, target, at)

@unsafe
def jwv_result_code(+code: List<&2,JWInstruction>, +target: U32, +at: U32) -> Bool:
  match code:
    case Nil{}: True{}
    case Con{JWDirectCall{slot, called, args}, rest}:
      (Bool.not(U32.is_eq(called, target)) || (U32.is_eq(at, 0) && Bool.not(jwv_code_use(rest, slot, True{})))) && jwv_result_code(rest, target, at)
    case Con{JWCallValues{slots, called, args}, rest}:
      (Bool.not(U32.is_eq(called, target)) ||
        (U32.is_lt(at, jwv_slot_count(slots)) && Bool.not(jwv_code_use(rest, jwv_slot_at(slots, at), True{})))) && jwv_result_code(rest, target, at)
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      jwv_result_code(yes, target, at) && jwv_result_code(no, target, at) && jwv_result_code(rest, target, at)
    case Con{other, rest}: jwv_result_code(rest, target, at)

@unsafe
def jwv_return_rewrite(+code: List<&2,JWInstruction>, +at: U32) -> List<&2,JWInstruction>:
  match code:
    case Nil{}: Nil{}
    case Con{JWReturn{value}, rest}: Con{JWReturnValues{jwv_split_values(Con{value, Nil{}}, at)}, rest}
    case Con{JWReturnValues{values}, rest}: Con{JWReturnValues{jwv_split_values(values, at)}, rest}
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      Con{JWCase{layout, name, input, jwv_return_rewrite(yes, at), jwv_return_rewrite(no, at)}, rest}
    case Con{other, rest}: Con{other, jwv_return_rewrite(rest, at)}

@unsafe
def jwv_code_of(+r: JWVCode) -> List<&2,JWInstruction>:
  match r:
    case JWVCode{code, next}: code

@unsafe
def jwv_next_of(+r: JWVCode) -> U32:
  match r:
    case JWVCode{code, next}: next

@unsafe
def jwv_prepend(+i: JWInstruction, +r: JWVCode) -> JWVCode:
  match r:
    case JWVCode{code, next}: JWVCode{Con{i, code}, next}

@unsafe
def jwv_result_edges(+code: List<&2,JWInstruction>, +target: U32, +at: U32, +next: U32) -> JWVCode:
  match code:
    case Nil{}: JWVCode{Nil{}, next}
    case Con{JWDirectCall{slot, called, args}, rest}:
      kc(JWVCode, U32.is_eq(called, target), u =>
        jwv_result_edge(Con{slot, Nil{}}, called, args, rest, target, at, next), u =>
        jwv_prepend(JWDirectCall{slot, called, args}, jwv_result_edges(rest, target, at, next)))
    case Con{JWCallValues{slots, called, args}, rest}:
      kc(JWVCode, U32.is_eq(called, target), u =>
        jwv_result_edge(slots, called, args, rest, target, at, next), u =>
        jwv_prepend(JWCallValues{slots, called, args}, jwv_result_edges(rest, target, at, next)))
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      jwv_result_branch(layout, name, input, jwv_result_edges(yes, target, at, next), no, rest, target, at)
    case Con{other, rest}: jwv_prepend(other, jwv_result_edges(rest, target, at, next))

@unsafe
def jwv_result_edge(+slots: List<&2,U32>, +called: U32, +args: List<&2,JWValue>, +rest: List<&2,JWInstruction>, +target: U32, +at: U32, +next: U32) -> JWVCode:
  jwv_prepend(JWCallValues{List.append(&2,U32, slots, Con{next, Nil{}}), called, args},
    jwv_result_edges(jwv_map_code(rest, jwv_slot_at(slots, at), jwv_slot_at(slots, at), next, 0, 0), target, at, U32.inc(next)))

@unsafe
def jwv_result_branch(+layout: String, +name: String, +input: JWValue, +yes: JWVCode, +no: List<&2,JWInstruction>, +rest: List<&2,JWInstruction>, +target: U32, +at: U32) -> JWVCode:
  jwv_result_branch_done(layout, name, input, yes, jwv_result_edges(no, target, at, jwv_next_of(yes)), rest, target, at)

@unsafe
def jwv_result_branch_done(+layout: String, +name: String, +input: JWValue, +yes: JWVCode, +no: JWVCode, +rest: List<&2,JWInstruction>, +target: U32, +at: U32) -> JWVCode:
  jwv_prepend(JWCase{layout, name, input, jwv_code_of(yes), jwv_code_of(no)}, jwv_result_edges(rest, target, at, jwv_next_of(no)))

@unsafe
def jwv_result_rewrite(+fs: List<&2,JWFunction>, +target: U32, +at: U32, +index: U32) -> List<&2,JWFunction>:
  match fs:
    case Nil{}: Nil{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      Con{JWFunction{name, arity, jwv_code_of(jwv_result_edges(
        kc(List<&2,JWInstruction>, U32.is_eq(index, target), u => jwv_return_rewrite(code, at), u => code),
        target, at, jw_register_bound(code, arity))), valid}, jwv_result_rewrite(rest, target, at, U32.inc(index))}

# A removed shell's fields still evaluate once, in order, at the old allocation.
@unsafe
def jwv_clean(+code: List<&2,JWInstruction>, +next: U32) -> JWVCode:
  match code:
    case Nil{}: JWVCode{Nil{}, next}
    case Con{JWAssign{slot, JWConstruct{layout, name, Con{a, Con{b, Nil{}}}}}, rest}:
      kc(JWVCode, String.eq(layout, "tuple") && String.eq(name, "Tuple") && Bool.not(jwv_code_use(rest, slot, True{})),
        u => jwv_prepend(JWAssign{next, a}, jwv_prepend(JWAssign{U32.inc(next), b},
          jwv_clean(jwv_map_code(rest, slot, next, U32.inc(next), 0, 0), U32.add(next, 2)))),
        u => jwv_prepend(JWAssign{slot, JWConstruct{layout, name, Con{a, Con{b, Nil{}}}}}, jwv_clean(rest, next)))
    case Con{JWAssign{slot, JWSlot{from}}, rest}:
      kc(JWVCode, Bool.not(U32.is_eq(slot, from)) && Bool.not(jwv_code_use(rest, slot, True{})) && jwv_code_use(rest, slot, False{}),
        u => jwv_prepend(JWAssign{next, JWProject{"tuple", JWSlot{from}, 0}},
          jwv_prepend(JWAssign{U32.inc(next), JWProject{"tuple", JWSlot{from}, 1}},
            jwv_clean(jwv_map_code(rest, slot, next, U32.inc(next), 0, 0), U32.add(next, 2)))),
        u => jwv_prepend(JWAssign{slot, JWSlot{from}}, jwv_clean(rest, next)))
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      jwv_clean_branch(layout, name, input, jwv_clean(yes, next), no, rest)
    case Con{other, rest}: jwv_prepend(other, jwv_clean(rest, next))

@unsafe
def jwv_clean_branch(+layout: String, +name: String, +input: JWValue, +yes: JWVCode, +no: List<&2,JWInstruction>, +rest: List<&2,JWInstruction>) -> JWVCode:
  jwv_clean_branch_done(layout, name, input, yes, jwv_clean(no, jwv_next_of(yes)), rest)

@unsafe
def jwv_clean_branch_done(+layout: String, +name: String, +input: JWValue, +yes: JWVCode, +no: JWVCode, +rest: List<&2,JWInstruction>) -> JWVCode:
  jwv_prepend(JWCase{layout, name, input, jwv_code_of(yes), jwv_code_of(no)}, jwv_clean(rest, jwv_next_of(no)))

@unsafe
def jwv_clean_rounds(+code: List<&2,JWInstruction>, +arity: U32, +fuel: U32) -> List<&2,JWInstruction>:
  kc(List<&2,JWInstruction>, U32.is_eq(fuel, 0), u => code, u =>
    jwv_clean_rounds(jwv_code_of(jwv_clean(code, jw_register_bound(code, arity))), arity, U32.sub(fuel, 1)))

@unsafe
def jwv_clean_functions(+fs: List<&2,JWFunction>) -> List<&2,JWFunction>:
  match fs:
    case Nil{}: Nil{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      Con{JWFunction{name, arity, jwv_clean_rounds(code, arity, 3), valid}, jwv_clean_functions(rest)}

# Return rewriting exposes shells in the producer only. Avoid cleaning every
# unrelated function again for each decomposed result field.
@unsafe
def jwv_clean_target(+fs: List<&2,JWFunction>, +target: U32, +at: U32) -> List<&2,JWFunction>:
  match fs:
    case Nil{}: Nil{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      Con{JWFunction{name, arity, kc(List<&2,JWInstruction>, U32.is_eq(at, target),
        u => jwv_clean_rounds(code, arity, 3), u => code), valid}, jwv_clean_target(rest, target, U32.inc(at))}

@unsafe
def jwv_results(+fs: List<&2,JWFunction>, +entry: U32, +target: U32, +at: U32, +fuel: U32) -> List<&2,JWFunction>:
  kc(List<&2,JWFunction>, U32.is_eq(fuel, 0), u => fs, u =>
    jwv_results_next(fs, entry, target, at, fuel, jwv_function(fs, target)))

@unsafe
def jwv_results_next(+fs: List<&2,JWFunction>, +entry: U32, +target: U32, +at: U32, +fuel: U32, +found: Maybe<&2,JWFunction>) -> List<&2,JWFunction>:
  match found:
    case None{}: fs
    case Some{JWFunction{name, arity, code, valid}}:
      kc(List<&2,JWFunction>, U32.is_eq(entry, target) || U32.is_eq(at, 4),
        u => jwv_results(fs, entry, U32.inc(target), 0, fuel), u =>
        kc(List<&2,JWFunction>, valid && jwv_shape_ok(jwv_return_shape(code, Nil{}, at)) && jwv_result_calls(fs, target, at),
          u => jwv_results(jwv_clean_target(jwv_result_rewrite(fs, target, at, 0), target, 0), entry, target, at, U32.sub(fuel, 1)),
          u => jwv_results(fs, entry, target, U32.inc(at), fuel)))

# Branches from typed lowering terminate their block. Reject a synthetic join
# rather than treating its branch-local remainder as the complete use scope.
@unsafe
def jwv_terminal_functions(+fs: List<&2,JWFunction>) -> Bool:
  match fs:
    case Nil{}: True{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      jwv_terminal_code(code) && jwv_terminal_functions(rest)

@unsafe
def jwv_terminal_code(+code: List<&2,JWInstruction>) -> Bool:
  match code:
    case Nil{}: True{}
    case Con{JWCase{layout, name, input, yes, no}, Nil{}}: jwv_terminal_code(yes) && jwv_terminal_code(no)
    case Con{JWCase{layout, name, input, yes, no}, rest}: False{}
    case Con{other, rest}: jwv_terminal_code(rest)

@unsafe
def jw_values_functions(+fs: List<&2,JWFunction>, +entry: U32) -> List<&2,JWFunction>:
  kc(List<&2,JWFunction>, jw_all_valid(fs) && jwv_terminal_functions(fs) && U32.is_lt(entry, jw_graph_count(fs, 0)) && U32.is_lt(jw_graph_count(fs, 0), 97),
    u => jwv_clean_functions(jwv_results(jwv_clean_functions(jwv_parameters(fs, entry, 0, 0, 4, 32)), entry, 0, 0, 32)), u => fs)
