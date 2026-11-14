def p194pc_v(name: String) -> N111Value: N111Local{name}
def p194pc_set(name: String, typ: N111Type, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,typ,value}}
def p194pc_op(n: U32) -> String:
  match n:
    case 0: "eq"
    case 1: "ne"
    case 2: "ult"
    case 3: "ule"
    case 4: "ugt"
    case 5: "uge"
    case 6: "slt"
    case 7: "sle"
    case 8: "sgt"
    case _: "sge"

@unsafe
def p194pc_rows(+mode: U32) -> List<&2,P113DStmt>:
  +typ = nt_choose(N111Type,U32.is_eq(U32.mod(U32.div(mode,10),2),0),u => N111U32{},u => N111U64{})
  +st = nt_choose(N111Type,U32.is_ge(mode,40),u => nt_choose(N111Type,U32.is_eq(p111v_type(typ),1),v => N111U64{},v => N111U32{}),u => typ)
  [P113DScalar{N111Bin{"condition",typ,p194pc_op(U32.mod(mode,10)),p194pc_v("a"),p194pc_v("b")}},
   nt_choose(P113DStmt,U32.is_eq(U32.mod(mode,2),0),u => P113DIf{p194pc_v("condition"),[],[]},
     u => P113DScalar{N111If{p194pc_v("condition"),[],[]}}),
   p194pc_set("copy",N111U32{},p194pc_v("condition")),
   p194pc_set("wide",N111U64{},p194pc_v("copy")),
   P113DScalar{nt_choose(N111Stmt,U32.is_ge(mode,20) && U32.is_lt(mode,40),
     u => N111Bin{"wide",N111U64{},"xor",p194pc_v("wide"),N111Const{1,0}},
     u => N111Set{"wide",N111U32{},p194pc_v("wide")})},
   P113DIf{p194pc_v("wide"),
     [p194pc_set("a",st,p194pc_v("a")),p194pc_set("b",st,p194pc_v("a"))],
     [p194pc_set("a",st,p194pc_v("b")),p194pc_set("b",st,p194pc_v("a"))]}]

@unsafe
def p194pc_present(plan: Maybe<&2,X194Select>) -> Bool:
  match plan:
    case Some{p}: True{}
    case None{}: False{}

@unsafe
def p194pc_admitted(+rows: List<&2,P113DStmt>) -> Bool:
  match x194_ps_pick(rows):
    case Some{X194Select{rest,typ,op,left,right,invert,selected,names}}:
      x194_ps_allowed(names,x190_branch_facts([],[],rows))
    case None{}: False{}

def p194pc_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

@unsafe
def p194pc_shapes(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,60),u => [],u =>
    Con{p194pc_row("predicate-mode-" ++ U32.show(mode),p194pc_admitted(p194pc_rows(mode))),p194pc_shapes(U32.inc(mode))})

@unsafe
def p194pc_gap(gap: P113DStmt) -> List<&2,P113DStmt>:
  match p194pc_rows(0):
    case Con{head,rest}: Con{head,Con{gap,rest}}
    case Nil{}: []

@unsafe
def p194pc_controls() -> List<&2,String>:
  nt_append(String,p194pc_shapes(0),[
    p194pc_row("unrelated-empty-refused",Bool.not(p194pc_present(x194_ps_pick(p194pc_gap(P113DIf{p194pc_v("a"),[],[]}))))),
    p194pc_row("operand-write-refused",Bool.not(p194pc_present(x194_ps_pick(p194pc_gap(p194pc_set("a",N111U64{},p194pc_v("b"))))))),
    p194pc_row("alias-to-operand-refused",Bool.not(p194pc_present(x194_ps_pick(p194pc_gap(p194pc_set("a",N111U32{},p194pc_v("condition"))))))),
    p194pc_row("call-refused",Bool.not(p194pc_present(x194_ps_pick(p194pc_gap(P113DScalar{N111Call{"status",N111U64{},"barrier",[]}}))))),
    p194pc_row("load-refused",Bool.not(p194pc_present(x194_ps_pick(p194pc_gap(P113DScalar{N111Load{"unused",N111U64{},p194pc_v("state"),0}}))))),
    p194pc_row("store-refused",Bool.not(p194pc_present(x194_ps_pick(p194pc_gap(P113DScalar{N111Store{N111U64{},p194pc_v("state"),0,p194pc_v("a")}}))))),
    p194pc_row("extra-use-refused",Bool.not(p194pc_admitted(nt_append(P113DStmt,p194pc_rows(0),[P113DResult{[p194pc_v("condition")]}])))),
    p194pc_row("repeated-definition",p194pc_admitted(nt_append(P113DStmt,p194pc_rows(0),p194pc_rows(1))))])

@unsafe
def p194pc_body(mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p194pc_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p194pc_v("state"),8}}],
    nt_append(P113DStmt,p194pc_rows(mode),[
      P113DScalar{N111Store{N111U64{},p194pc_v("state"),16,p194pc_v("a")}},
      P113DScalar{N111Store{N111U64{},p194pc_v("state"),24,p194pc_v("b")}},P113DResult{[p194pc_v("b")]}]))

# Original IR goes directly to the ordinary selector with its original frame
# and allocation metadata. This exercises the actual hooked consumer.
@unsafe
def p194pc_emit_mode(+mode: U32) -> X181Output:
  x191_ordinary("p194pc_" ++ U32.show(mode),["state"],[],p194pc_body(mode),N111Ids{missing(),missing()})

@unsafe
def p194pc_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,60),u => X181Output{[],""},u =>
    x181_program_join(p194pc_emit_mode(mode),p194pc_emit_modes(U32.inc(mode))))

def p194pc_emit() -> X181Output: p194pc_emit_modes(0)
