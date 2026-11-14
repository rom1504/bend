def p194st_v(name: String) -> N111Value: N111Local{name}
def p194st_set(name: String, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},value}}
def p194st_store(offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p194st_v("state"),offset,value}}

@unsafe
def p194st_copies(+n: U32, source: String) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(n,0),u => [],u =>
    Con{p194st_set("wide",p194st_v(source)),p194st_copies(U32.sub(n,1),"wide")})

@unsafe
def p194st_select(+destination: String, scalar: Bool) -> P113DStmt:
  nt_choose(P113DStmt,scalar,
    u => P113DScalar{N111If{p194st_v("wide"),
      [N111Set{destination,N111U64{},p194st_v("a")}],
      [N111Set{destination,N111U64{},p194st_v("b")}] }},
    u => P113DIf{p194st_v("wide"),[p194st_set(destination,p194st_v("a"))],[p194st_set(destination,p194st_v("b"))]})

@unsafe
def p194st_corridor(op: String, destination: String, +mode: U32) -> List<&2,P113DStmt>:
  +prefix = [P113DScalar{N111Bin{"condition",N111U64{},op,p194st_v("a"),p194st_v("b")}}]
  +transport = nt_choose(List<&2,P113DStmt>,U32.is_ge(mode,6),
    u => p194st_copies(nt_choose(U32,U32.is_eq(mode,6),v => 7,v => 8),"condition"),
    u => [P113DScalar{N111Set{"copy",N111U32{},p194st_v("condition")}},p194st_set("wide",p194st_v("copy"))])
  +invert = nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,1),
    u => [P113DScalar{N111Bin{"wide",N111U32{},"xor",p194st_v("wide"),N111Const{1,0}}}],u => [])
  nt_append(P113DStmt,prefix,nt_append(P113DStmt,transport,nt_append(P113DStmt,invert,
    [P113DIf{p194st_v("wide"),[],[]},p194st_select(destination,U32.is_eq(mode,1))])))

@unsafe
def p194st_rows(+mode: U32) -> List<&2,P113DStmt>:
  +first = p194st_corridor("ult","first",mode)
  +second = nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,0),
    u => p194st_corridor("ugt","second",0),u => [p194st_set("second",p194st_v("first"))])
  +observe = nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,2),
    u => [p194st_store(32,p194st_v("copy"))],u =>
      nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,3),
        v => [p194st_store(40,p194st_v("wide"))],v => []))
  nt_append(P113DStmt,first,nt_append(P113DStmt,observe,second))

@unsafe
def p194st_body(mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p194st_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p194st_v("state"),8}}],
    nt_append(P113DStmt,p194st_rows(mode),[
      p194st_store(16,p194st_v("first")),p194st_store(24,p194st_v("second")),
      P113DScalar{N111Bin{"result",N111U64{},"xor",p194st_v("first"),p194st_v("second")}},
      P113DResult{[p194st_v("result")]}]))

@unsafe
def p194st_params(mode: U32) -> List<&2,String>:
  ["state",nt_choose(String,U32.is_eq(mode,5),u => "condition",u => "seed")]

@unsafe
def p194st_setup(mode: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,4),
    u => [p194st_set("condition",N111Const{0,0})],u => [])

@unsafe
def p194st_allowed(pick: Maybe<&2,X194Select>, facts: X190BranchFacts) -> Bool:
  match pick:
    case Some{X194Select{rest,typ,op,left,right,invert,selected,names}}: x194_ps_allowed(names,facts)
    case None{}: False{}

@unsafe
def p194st_admitted(+mode: U32) -> Bool:
  p194st_allowed(x194_ps_pick(p194st_rows(mode)),
    x190_branch_facts(p194st_params(mode),p194st_setup(mode),p194st_rows(mode)))

@unsafe
def p194st_control_modes(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,8),u => [],u =>
    Con{"stress-mode-" ++ U32.show(mode) ++ "=" ++ nt_choose(String,
      Bool.not(Bool.xor(p194st_admitted(mode),U32.is_le(mode,1) || U32.is_eq(mode,6))),
      v => "1",v => "0"),p194st_control_modes(U32.inc(mode))})

def p194st_controls() -> List<&2,String>: p194st_control_modes(0)

# Machine fixtures use the actual function pipeline, including preparation,
# fact/copy/dead-write passes, allocation and the hooked final selector.
@unsafe
def p194st_emit_mode(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_eq(mode,4),
    u => x185_function_setup("p194st_" ++ U32.show(mode),p194st_params(mode),p194st_setup(mode),p194st_body(mode),N111Ids{missing(),missing()}),
    u => x181_function("p194st_" ++ U32.show(mode),p194st_params(mode),p194st_body(mode),N111Ids{missing(),missing()}))

@unsafe
def p194st_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,8),u => X181Output{[],""},u =>
    x181_program_join(p194st_emit_mode(mode),p194st_emit_modes(U32.inc(mode))))

def p194st_emit() -> X181Output: p194st_emit_modes(0)
