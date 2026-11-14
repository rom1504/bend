def p195tc_v(name: String) -> N111Value: N111Local{name}
def p195tc_c(lo: U32) -> N111Value: N111Const{lo,0}
def p195tc_values() -> List<&2,U32>: [0,2147483648,2139095040,4286578688,2143363909,2139095041,4294967295,3735928559]
def p195tc_tables() -> List<&2,P126ITable>: [P126ITable{"p195tc_table",7}]
def p195tc_bind(name: String, id: U32) -> NC_Binding: NC_Binding{id,name,N_W64{}}
def p195tc_table() -> P113DFunction:
  P113DFunction{"p195tc_table",[p195tc_bind("index",0)],1,True{},p126s_decision("index",p195tc_values(),0)}
def p195tc_call(name: String, value: N111Value) -> P113DStmt:
  P113DCall{[name],"p195tc_table",[value]}
def p195tc_function(name: String, body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,[p195tc_bind("index",0),p195tc_bind("condition",1)],1,True{},body}

@unsafe
def p195tc_rows(+mode: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,0),u => [p195tc_call("value",p195tc_v("index")),P113DResult{[p195tc_v("value")]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,1),u => [
    P113DScalar{N111Store{N111U64{},p195tc_v("state"),0,p195tc_v("index")}},
    p195tc_call("index",p195tc_v("index")),
    P113DScalar{N111Store{N111U64{},p195tc_v("state"),8,p195tc_v("index")}},P113DResult{[p195tc_v("index")]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,2),u => [
    P113DIf{p195tc_v("condition"),[p195tc_call("value",p195tc_v("index"))],[p195tc_call("value",p195tc_c(0))]},
    P113DResult{[p195tc_v("value")]}],u => [
    p195tc_call("first",p195tc_v("index")),
    P113DScalar{N111Call{"ignored",N111U64{},"p195tc_barrier",[
      N111Arg{N111Ptr{},p195tc_v("state")},N111Arg{N111U64{},p195tc_v("first")}]}},
    P113DScalar{N111Bin{"next",N111U64{},"add",p195tc_v("index"),p195tc_c(1)}},
    p195tc_call("second",p195tc_v("next")),
    P113DScalar{N111Bin{"value",N111U64{},"add",p195tc_v("first"),p195tc_v("second")}},
    P113DResult{[p195tc_v("value")]}])))

@unsafe
def p195tc_emit_function(symbol: String, function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x181_function(symbol,["state","index","condition"],body,N111Ids{missing(),missing()})

@unsafe
def p195tc_emit_mode(+mode: U32) -> X181Output:
  +function = p195tc_function("p195tc_fixture",p195tc_rows(mode))
  x181_program_join(p195tc_emit_function("p195tc_old_" ++ U32.show(mode),function),
    p195tc_emit_function("p195tc_new_" ++ U32.show(mode),x195t_when(True{},function,p195tc_tables())))

@unsafe
def p195tc_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_eq(mode,4),u => X181Output{[],""},u =>
    x181_program_join(p195tc_emit_mode(mode),p195tc_emit_modes(U32.inc(mode))))

def p195tc_emit() -> X181Output:
  x181_program_join(x181_direct(p195tc_table(),N111Ids{missing(),missing()}),
    x181_program_join(x195t_data(p195tc_table(),p195tc_tables(),missing()),p195tc_emit_modes(0)))

@unsafe
def p195tc_calls(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p126i_calls(body,p195tc_tables())

def p195tc_ok(output: X181Output) -> Bool:
  match output:
    case X181Output{chunks,error}: String.is_empty(error)

def p195tc_row(name: String, ok: Bool) -> String:
  "table-" ++ name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

@unsafe
def p195tc_long(+n: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(n,0),u => [],u => Con{n,p195tc_long(U32.sub(n,1))})

@unsafe
def p195tc_controls() -> List<&2,String>:
  +basic = p195tc_function("fixture",p195tc_rows(0))
  [p195tc_row("catalogue",U32.is_eq(nt_count(P126ITable,p126i_catalogue([p195tc_table()],[])),1)),
   p195tc_row("basic",Bool.not(p195tc_calls(x195t_when(True{},basic,p195tc_tables())))),
   p195tc_row("same-destination",Bool.not(p195tc_calls(x195t_when(True{},p195tc_function("fixture",p195tc_rows(1)),p195tc_tables())))),
   p195tc_row("branches",Bool.not(p195tc_calls(x195t_when(True{},p195tc_function("fixture",p195tc_rows(2)),p195tc_tables())))),
   p195tc_row("effects",Bool.not(p195tc_calls(x195t_when(True{},p195tc_function("fixture",p195tc_rows(3)),p195tc_tables())))),
   p195tc_row("off",p195tc_calls(x195t_when(False{},basic,p195tc_tables()))),
   p195tc_row("unknown",p195tc_calls(x195t_when(True{},basic,[]))),
   p195tc_row("local-collision",p195tc_calls(x195t_when(True{},p195tc_function("fixture",
     Con{P113DScalar{N111Set{"p195t_collision",N111U64{},p195tc_c(0)}},p195tc_rows(0)}),p195tc_tables()))),
   p195tc_row("read-collision",Bool.not(x195t_clean_body([P113DResult{[p195tc_v("p195t_read")]}]))),
   p195tc_row("parameter-collision",p195tc_calls(x195t_when(True{},P113DFunction{"fixture",[p195tc_bind("p195t_index",0)],1,True{},p195tc_rows(0)},p195tc_tables()))),
   p195tc_row("short-refusal",p195tc_calls(x195t_when(True{},basic,[P126ITable{"p195tc_table",2}]))),
   p195tc_row("long-refusal",p195tc_calls(x195t_when(True{},basic,[P126ITable{"p195tc_table",64}]))),
   p195tc_row("data",p195tc_ok(x195t_data(p195tc_table(),p195tc_tables(),missing()))),
   p195tc_row("length-refusal",Bool.not(p195tc_ok(x195t_data(p195tc_table(),[P126ITable{"p195tc_table",6}],missing())))),
   p195tc_row("upper-word-refusal",Bool.not(p195tc_ok(x195t_data(P113DFunction{"p195tc_table",[p195tc_bind("index",0)],1,True{},
     [P113DResult{[N111Const{1,1}]}]},p195tc_tables(),missing())))),
   p195tc_row("limit-64",p126s_has_cells(p126s_cells("index",p126s_decision("index",p195tc_long(64),0),0))),
   p195tc_row("limit-65",Bool.not(p126s_has_cells(p126s_cells("index",p126s_decision("index",p195tc_long(65),0),0))))]
