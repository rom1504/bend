def p195sp_v(name: String) -> N111Value: N111Local{name}
def p195sp_set(name: String, typ: N111Type, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,typ,value}}
def p195sp_store(offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p195sp_v("state"),offset,value}}

@unsafe
def p195sp_type(n: U32) -> N111Type:
  nt_choose(N111Type,U32.is_eq(U32.mod(n,2),0),u => N111U32{},u => N111U64{})

@unsafe
def p195sp_corridor(+mode: U32) -> List<&2,P113DStmt>:
  +st = p195sp_type(U32.div(mode,2))
  nt_append(P113DStmt,[P113DScalar{N111Bin{"condition",p195sp_type(mode),"ult",p195sp_v("a"),p195sp_v("b")}},
    P113DIf{p195sp_v("condition"),[],[]},p195sp_set("copy",N111U32{},p195sp_v("condition")),
    p195sp_set("wide",N111U64{},p195sp_v("copy"))],
    nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,U32.is_ge(mode,4),
      u => [P113DScalar{N111Bin{"wide",N111U32{},"xor",p195sp_v("wide"),N111Const{1,0}}}],u => []),
      [P113DIf{p195sp_v("wide"),
        [p195sp_set("a",st,p195sp_v("a")),p195sp_set("b",st,p195sp_v("a"))],
        [p195sp_set("a",st,p195sp_v("b")),p195sp_set("b",st,p195sp_v("a"))]}]))

@unsafe
def p195sp_pressure(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_ge(n,12),u => [],u =>
    Con{P113DScalar{N111Bin{"live" ++ U32.show(n),N111U64{},"add",
      p195sp_v(nt_choose(String,U32.is_eq(U32.mod(n,2),0),v => "a",v => "b")),N111Const{U32.inc(n),0}}},
      p195sp_pressure(U32.inc(n))})

@unsafe
def p195sp_reduce(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_ge(n,12),u => [],u =>
    Con{P113DScalar{N111Bin{"checksum",N111U64{},"xor",p195sp_v("checksum"),p195sp_v("live" ++ U32.show(n))}},
      p195sp_reduce(U32.inc(n))})

@unsafe
def p195sp_body(mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p195sp_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p195sp_v("state"),8}},
    p195sp_set("oldA",N111U64{},p195sp_v("a")),p195sp_set("oldB",N111U64{},p195sp_v("b"))],
    nt_append(P113DStmt,p195sp_pressure(0),nt_append(P113DStmt,p195sp_corridor(mode),
      nt_append(P113DStmt,[p195sp_set("checksum",N111U64{},N111Const{0,0})],
        nt_append(P113DStmt,p195sp_reduce(0),[
          p195sp_store(16,p195sp_v("a")),p195sp_store(24,p195sp_v("b")),
          p195sp_store(32,p195sp_v("oldA")),p195sp_store(40,p195sp_v("oldB")),
          p195sp_store(48,p195sp_v("checksum")),
          P113DScalar{N111Bin{"result",N111U64{},"xor",p195sp_v("checksum"),p195sp_v("a")}},
          P113DResult{[p195sp_v("result")]}])))))

@unsafe
def p195sp_zero_reads(reads: X181ReadCounts, +name: String) -> Bool:
  match reads:
    case X181ReadCounts{counts,names}: U32.is_eq(da(p111v_get(counts,name)),0)

@unsafe
def p195sp_projected(+rows: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x191_placement(rows,x190_branch_facts(["state"],[],rows))

@unsafe
def p195sp_projection(+mode: U32) -> Bool:
  +reads = x181_reads_stmts(p195sp_projected(p195sp_body(mode)),X181ReadCounts{missing(),[]})
  p195sp_zero_reads(reads,"condition") && p195sp_zero_reads(reads,"copy") && p195sp_zero_reads(reads,"wide")

@unsafe
def p195sp_extra_use() -> Bool:
  +rows = nt_append(P113DStmt,p195sp_corridor(0),[P113DResult{[p195sp_v("copy")]}])
  Bool.not(p195sp_zero_reads(x181_reads_stmts(p195sp_projected(rows),X181ReadCounts{missing(),[]}),"copy"))

@unsafe
def p195sp_controls_at(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,8),u => ["external-copy-refused=" ++ nt_choose(String,p195sp_extra_use(),v => "1",v => "0")],u =>
    Con{"projection-" ++ U32.show(mode) ++ "=" ++ nt_choose(String,p195sp_projection(mode),v => "1",v => "0"),
      p195sp_controls_at(U32.inc(mode))})

def p195sp_controls() -> List<&2,String>: p195sp_controls_at(0)

@unsafe
def p195sp_emit_at(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,8),u => X181Output{[],""},u =>
    x181_program_join(x191_ordinary("p195sp_" ++ U32.show(mode),["state"],[],p195sp_body(mode),N111Ids{missing(),missing()}),
      p195sp_emit_at(U32.inc(mode))))

def p195sp_emit() -> X181Output: p195sp_emit_at(0)
