# Include Phase194 predicate-controls-v3 for p194pc helpers and the unchanged
# 60 full-word selection cases; these add all integer 0/1 comparison outputs.
@unsafe
def p195pm_rows(+mode: U32) -> List<&2,P113DStmt>:
  +typ = nt_choose(N111Type,U32.is_eq(U32.mod(U32.div(mode,10),2),0),u => N111U32{},u => N111U64{})
  +st = nt_choose(N111Type,U32.is_eq(U32.mod(mode,2),0),u => N111U32{},u => N111U64{})
  +yes = nt_choose(N111Value,U32.is_lt(mode,20),u => N111Const{1,0},u => N111Const{0,0})
  +no = nt_choose(N111Value,U32.is_lt(mode,20),u => N111Const{0,0},u => N111Const{1,0})
  [P113DScalar{N111Bin{"condition",typ,p194pc_op(U32.mod(mode,10)),p194pc_v("a"),p194pc_v("b")}},
    P113DIf{p194pc_v("condition"),[],[]},p194pc_set("copy",N111U32{},p194pc_v("condition")),
    p194pc_set("wide",N111U64{},p194pc_v("copy")),
    P113DIf{p194pc_v("wide"),
      [p194pc_set("a",st,yes),p194pc_set("b",st,p194pc_v("a"))],
      [p194pc_set("a",st,no),p194pc_set("b",st,p194pc_v("a"))]}]

@unsafe
def p195pm_controls_at(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,40),u => [],u =>
    Con{p194pc_row("boolean-" ++ U32.show(mode),p194pc_admitted(p195pm_rows(mode))),p195pm_controls_at(U32.inc(mode))})

def p195pm_controls() -> List<&2,String>: p195pm_controls_at(0)

@unsafe
def p195pm_body(mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p194pc_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p194pc_v("state"),8}}],nt_append(P113DStmt,p195pm_rows(mode),[
      P113DScalar{N111Store{N111U64{},p194pc_v("state"),16,p194pc_v("a")}},
      P113DScalar{N111Store{N111U64{},p194pc_v("state"),24,p194pc_v("b")}},P113DResult{[p194pc_v("b")]}]))

@unsafe
def p195pm_emit_at(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,40),u => X181Output{[],""},u =>
    x181_program_join(x191_ordinary("p195pm_" ++ U32.show(mode),["state"],[],p195pm_body(mode),N111Ids{missing(),missing()}),
      p195pm_emit_at(U32.inc(mode))))

def p195pm_emit() -> X181Output: p195pm_emit_at(0)

# Reuse unchanged high-pressure/old-value machine fixture with this emitter.
@unsafe
def p195pm_pressure_at(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,8),u => [],u =>
    Con{p194pc_row("pressure-" ++ U32.show(mode),p194pc_admitted(p195sp_corridor(mode))),p195pm_pressure_at(U32.inc(mode))})

def p195pm_pressure_controls() -> List<&2,String>: p195pm_pressure_at(0)
def p195pm_pressure_emit() -> X181Output: p195sp_emit()
