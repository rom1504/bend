# Independently compare memo hits/misses against original fresh transformations.
@unsafe
def p134ut_table(scalar: P113DFunction) -> P113ITable:
  p113i_table_function(p114st_pair(),p113i_table_function(scalar,P113IEmpty{}))

def p134ut_scalar() -> P113DFunction:
  P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{7,0}]}]}

def p134ut_high() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{0,1}]}]}

@unsafe
def p134ut_case(original: P113DFunction, oldtable: P113ITable, current: P113DFunction, table: P113ITable, expected: Bool) -> Bool:
  p134ut_previous(current,table,expected,p134u_fresh(original,oldtable))

@unsafe
def p134ut_previous(+current: P113DFunction, +table: P113ITable, expected: Bool, previous: P134UOne) -> Bool:
  match previous:
    case P134UOne{unit,slot,hit}:
      p134ut_answer(current,table,expected,p134u_one(current,table,slot))

@unsafe
def p134ut_answer(current: P113DFunction, table: P113ITable, expected: Bool, answer: P134UOne) -> Bool:
  match answer:
    case P134UOne{P134RKUnit{function,memo},slot,hit}:
      p134v_bool(hit,expected) && p134v_function(function,p113i_function(current,table))

@unsafe
def p134ut_pipeline(original: P113DProgram, +current: P113DProgram) -> Bool:
  p134ut_pipeline_previous(current,p134u_optimize(p114s_open(original),P134UCache{[],[]}))

@unsafe
def p134ut_pipeline_previous(+current: P113DProgram, previous: P134UOptimized) -> Bool:
  match previous:
    case P134UOptimized{boundary,cache,stats}:
      p134ut_pipeline_answer(current,p134u_optimize(p114s_open(current),cache))

@unsafe
def p134ut_pipeline_answer(current: P113DProgram, answer: P134UOptimized) -> Bool:
  match answer:
    case P134UOptimized{boundary,cache,stats}:
      p134rkt_same_boundary(boundary,p134rkt_reference_ranges(p134rkt_reference_inline(p114s_open(current))))

@unsafe
def p134ut_range(input: P113DFunction, current: P113DFunction, expected: Bool) -> Bool:
  p134ut_range_previous(current,expected,p134rk_ranged(input))

@unsafe
def p134ut_range_previous(+current: P113DFunction, expected: Bool, unit: P134RKUnit) -> Bool:
  match unit:
    case P134RKUnit{function,memo}:
      p134ut_range_answer(current,expected,p134u_range_one(current,P134RKEmpty{},memo))

@unsafe
def p134ut_range_answer(current: P113DFunction, expected: Bool, answer: P134URangeOne) -> Bool:
  match answer:
    case P134URangeOne{function,memo,prior,inner}:
      p134v_bool(prior,expected) && Bool.not(inner) && p134v_function(function,p113k_function(current))

@unsafe
def p134u_controls() -> List<&2,String>:
  +table = p134ut_table(p114st_scalar())
  +changed = p134ut_table(p134ut_scalar())
  +caller = p114st_caller()
  +identity = p114st_identity()
  +edited : P113DProgram = P113DProgram{p114st_original(),[p134ut_scalar(),p114st_pair(),caller]}
  +invalid : P113DProgram = P113DProgram{p114st_original(),[P113DFunction{"bad",[],1,False{},[P113DResult{[N111Local{"undefined"}]}]}]}
  [p114st_row("units-inline-identical",p134ut_case(caller,table,caller,table,True{})),
   p114st_row("units-callee-body-invalidates",p134ut_case(caller,table,caller,changed,False{})),
   p114st_row("units-absent-now-present",p134ut_case(caller,P113IEmpty{},caller,table,False{})),
   p114st_row("units-present-now-absent",p134ut_case(caller,table,caller,P113IEmpty{},False{})),
   p114st_row("units-absent-remains-absent",p134ut_case(caller,P113IEmpty{},caller,P113IEmpty{},True{})),
   p114st_row("units-irrelevant-table-change",p134ut_case(identity,table,identity,changed,True{})),
   p114st_row("units-original-body-invalidates",p134ut_case(identity,table,p134ut_high(),table,False{})),
   p114st_row("units-nested-call-invalidates",p134ut_case(p114st_branch(),table,p114st_branch(),changed,False{})),
   p114st_row("units-loop-no-dependencies",p134ut_case(p114st_loop(),table,p114st_loop(),changed,True{})),
   p114st_row("units-range-exact-input",p134ut_range(p134rkt_fold(),p134rkt_fold(),True{})),
   p114st_row("units-range-changed-input",p134ut_range(identity,p134ut_high(),False{})),
   p114st_row("units-empty-revision",p134ut_pipeline(p114st_program(0),p114st_program(0))),
   p114st_row("units-publish-on-hit",p134ut_pipeline(p114st_program(2),p114st_program(2))),
   p114st_row("units-edit-callee-propagates",p134ut_pipeline(p114st_program(2),edited)),
   p114st_row("units-edit-reverted",p134ut_pipeline(edited,p114st_program(2))),
   p114st_row("units-functions-added",p134ut_pipeline(p114st_program(0),p114st_program(2))),
   p114st_row("units-functions-deleted",p134ut_pipeline(p114st_program(2),p114st_program(0))),
   p114st_row("units-reordered-slots",p134ut_pipeline(p114st_program(2),P113DProgram{p114st_original(),[p114st_pair(),p114st_scalar(),caller]})),
   p114st_row("units-invalid-new-boundary",p134ut_pipeline(p114st_program(2),invalid)),
   p114st_row("units-invalid-prior-boundary",p134ut_pipeline(invalid,p114st_program(2)))]
