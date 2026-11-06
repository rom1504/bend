# Finite compiler-data controls. These do not authorize a runtime program.
# Production proposals must enter through p171d_request's actual-source checks.

@unsafe
def p171dc_context():
  P171DContext{[],N111Ids{missing(),ns_ctor_index([N_Constructor{"P171Pair",2,True{}}],missing())},[],0}

@unsafe
def p171dc_env():
  [P171DLocal{"root",P171DWord{"root.0"}}]

@unsafe
def p171dc_body(count, offset):
  [P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state(),p111_word(N111Local{"root"}),p111_scratch(),p111_u32(count)]}},
   P113DScalar{N111Load{"field",N111U64{},N111Local{"scratch"},offset}},
   P113DScalar{N111Call{"alias",N111U64{},"p111_rt_keep",[p111_state(),p111_word(N111Local{"field"})]}},
   P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"root"})]}},
   P113DResult{[N111Local{"alias"}]}]

@unsafe
def p171dc_run(body, cases):
  p171d_walk(p171dc_context(),body,p171dc_env(),cases,P171DView{"","",0},0)

@unsafe
def p171dc_accept(code):
  match code:
    case P171DCode{body,helpers,n,accepted,declined,rooted}: U32.is_gt(accepted,0)

@unsafe
def p171dc_exact(code):
  match code:
    case P171DCode{body,helpers,n,accepted,declined,rooted}:
      p134v_list(~P113DStmt,~p134v_stmt,body,[
        P113DScalar{N111Call{"ignored",N111U64{},"p118_rt_borrow_fields",[p111_state(),p111_word(N111Local{"root"}),p111_scratch(),N111Arg{N111U32{},N111CtorId{"P171Pair"}},p111_u32(2)]}},
        P113DScalar{N111Load{"field",N111U64{},N111Local{"scratch"},0}},
        P113DScalar{N111Set{"alias",N111U64{},N111Local{"field"}}},
        P113DResult{[N111Const{1,0},N111Local{"alias"}]}]) &&
      List.is_empty(&2,P113DFunction,helpers) && U32.is_eq(accepted,1) && U32.is_eq(declined,0) && rooted

@unsafe
def p171dc_row(name, good):
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)

@unsafe
def p171d_controls():
  +known : List<&2,P171DCase> = [P171DCase{"root.0","P171Pair"}]
  [p171dc_row("whole-field-result-keep-alias-drop-erasure",p171dc_exact(p171dc_run(p171dc_body(2,0),known))),
   p171dc_row("root-return",p171dc_accept(p171dc_run([P113DResult{[N111Local{"root"}]}],[]))),
   p171dc_row("unknown-local-declines",Bool.not(p171dc_accept(p171dc_run([P113DResult{[N111Local{"unknown"}]}],[])))),
   p171dc_row("missing-dominating-constructor-declines",Bool.not(p171dc_accept(p171dc_run(p171dc_body(2,0),[])))),
   p171dc_row("wrong-constructor-width-declines",Bool.not(p171dc_accept(p171dc_run(p171dc_body(3,0),known)))),
   p171dc_row("unaligned-field-declines",Bool.not(p171dc_accept(p171dc_run(p171dc_body(2,1),known)))),
   p171dc_row("out-of-range-field-declines",Bool.not(p171dc_accept(p171dc_run(p171dc_body(2,16),known)))),
   p171dc_row("unknown-direct-callee-declines",Bool.not(p171dc_accept(p171dc_run([P113DCall{["field"],"foreign",[N111Local{"root"}]},P113DResult{[N111Local{"field"}]}],known)))),
   p171dc_row("unknown-runtime-declines",Bool.not(p171dc_accept(p171dc_run([P113DScalar{N111Call{"effect",N111U64{},"unknown_effect",[p111_state()]}},P113DResult{[N111Local{"root"}]}],known)))),
   p171dc_row("store-declines",Bool.not(p171dc_accept(p171dc_run([P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"root"}}},P113DResult{[N111Local{"root"}]}],known))))]

@unsafe
def p171dc_constant(+kind: U32, +count: U32) -> P171DCode:
  p171dc_run([P113DScalar{N111Call{"constant",N111U64{},"p111_rt_special_ctor",[p111_state(),p111_u32(kind),p111_scratch(),p111_u32(count)]}},P113DResult{[N111Local{"constant"}]}],[])

@unsafe
def p171d_constant_controls() -> List<&2,String>:
  [p171dc_row("nullary-false",p171dc_accept(p171dc_constant(1,0))),
   p171dc_row("nullary-true",p171dc_accept(p171dc_constant(2,0))),
   p171dc_row("nullary-zero",p171dc_accept(p171dc_constant(3,0))),
   p171dc_row("wrong-nullary-count-declines",Bool.not(p171dc_accept(p171dc_constant(2,1)))),
   p171dc_row("allocating-f32-declines",Bool.not(p171dc_accept(p171dc_constant(7,1))))]
