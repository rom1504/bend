# Data-only structural controls; runtime read observations are separately frozen.
@unsafe
def p112a_control_name(+name: String, good: Bool) -> String:
  nt_choose(String, good, u => "PASS " ++ name, u => "FAIL " ++ name)

def p112a_control_segment(arity: U32, incoming: U32, value: N111Value) -> N111Segment:
  N111Segment{"probe", arity, 1, incoming, 0,
    [N111Call{"out", N111U64{}, "p111_rt_reg_get", [p111_state(), N111Arg{N111U32{}, value}]},
     N111Return{N111Local{"out"}}]}

@unsafe
def p112a_control_read(arity: U32, incoming: U32, value: N111Value) -> Bool:
  String.is_empty(p111v_segment(p112a_control_segment(arity, incoming, value), N111Ids{missing(), missing()}))

@unsafe
def p112a_control_load(words: List<&2, N111Stmt>, +offset: U32) -> Bool:
  match words:
    case Con{N111Load{name, N111U64{}, N111Local{context}, actual}, Nil{}}:
      String.eq(name, "out") && String.eq(context, "state") && U32.is_eq(actual, offset)
    case _: False{}

@unsafe
def p112a_control_call(words: List<&2, N111Stmt>, +symbol: String) -> Bool:
  match words:
    case Con{N111Call{name, typ, actual, args}, Nil{}}: String.eq(actual, symbol)
    case _: False{}

def p112a_control_reg(value: N111Value) -> N111Stmt:
  N111Call{"out", N111U64{}, "p111_rt_reg_get", [p111_state(), N111Arg{N111U32{}, value}]}

# The normal public emitter must reject before any accessor rendering. It is
# deliberately not sufficient to validate the expanded load in isolation.
@unsafe
def p112a_control_refusal(emission: P111Emission) -> Bool:
  match emission:
    case P111Emission{chunks, error}: List.is_empty(&2, String, chunks) && Bool.not(String.is_empty(error))

@unsafe
def p112a_control_public_bad(index: U32) -> Bool:
  +main : N111Segment = N111Segment{"main", 0, 1, 0, 0,
    [p112a_control_reg(N111Const{index, 0}), N111Return{N111Local{"out"}}]}
  +program : P111Program = P111Program{[main], [], [0], [], [], False{}}
  p112a_control_refusal(p111_emit_lowered(P111Result{program, ""}))

@unsafe
def p112a_control_report() -> List<&2, String>:
  [p112a_control_name("register-first", p112a_control_read(1, 0, N111Const{0, 0})),
   p112a_control_name("register-last-admitted", p112a_control_read(255, 0, N111Const{254, 0})),
   p112a_control_name("continuation-first", p112a_control_read(255, 1, N111Const{0, 0})),
   p112a_control_name("register-equals-arity-refused", Bool.not(p112a_control_read(1, 0, N111Const{1, 0}))),
   p112a_control_name("continuation-capture-is-not-register", Bool.not(p112a_control_read(255, 1, N111Const{1, 0}))),
   p112a_control_name("high-index-refused", Bool.not(p112a_control_read(255, 0, N111Const{0, 1}))),
   p112a_control_name("dynamic-index-refused", Bool.not(p112a_control_read(255, 0, N111Local{"unknown"}))),
   p112a_control_name("first-offset", p112a_control_load(p112a_expand(2, p112a_control_reg(N111Const{0, 0})), 40)),
   p112a_control_name("last-offset", p112a_control_load(p112a_expand(2, p112a_control_reg(N111Const{254, 0})), 2072)),
   p112a_control_name("tag-mode-retains-register-call", p112a_control_call(p112a_expand(1, p112a_control_reg(N111Const{0, 0})), "p111_rt_reg_get")),
   p112a_control_name("high-index-retains-runtime", p112a_control_call(p112a_expand(2, p112a_control_reg(N111Const{0, 1})), "p111_rt_reg_get")),
   p112a_control_name("physical-end-retains-runtime", p112a_control_call(p112a_expand(2, p112a_control_reg(N111Const{255, 0})), "p111_rt_reg_get")),
   p112a_control_name("public-zero-arity-refusal", p112a_control_public_bad(0)),
   p112a_control_name("public-register-end-refusal", p112a_control_public_bad(255))]
