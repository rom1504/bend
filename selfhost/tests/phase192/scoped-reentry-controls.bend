# The first continuation PUSHES a second frame from its renamed case buffer,
# then reenters the owner. Both machine roles consume the same verified H plan.
def p192hcf_v(name: String) -> N111Value: N111Local{name}
def p192hcf_bind(name: String, id: U32) -> NC_Binding: NC_Binding{id,name,N_W64{}}

@unsafe
def p192hcf_return(value: N111Value) -> List<&2,N111Stmt>: p111_body(p111_return(value,0))

@unsafe
def p192hcf_owner() -> N111Segment:
  p111_segment("reentry",[p192hcf_bind("n",0),p192hcf_bind("seed",1)],0,0,[
    N111Bin{"done",N111U64{},"eq",p192hcf_v("n"),N111Const{0,0}},
    N111If{p192hcf_v("done"),p192hcf_return(p192hcf_v("seed")),
      nt_append(N111Stmt,p111_frame([p192hcf_bind("seed",0)],"first"),nt_append(N111Stmt,[
        N111Bin{"next_n",N111U64{},"sub",p192hcf_v("n"),N111Const{1,0}},
        N111Bin{"next_seed",N111U64{},"add",p192hcf_v("seed"),N111Const{3,0}}],
        p111_body(p111_jump("reentry",[p192hcf_v("next_n"),p192hcf_v("next_seed")],0))))}])

@unsafe
def p192hcf_first() -> N111Segment:
  p111_segment("first",[p192hcf_bind("captured",0),p192hcf_bind("result",1)],1,1,
    Con{N111Bin{"marker",N111U64{},"xor",p192hcf_v("captured"),N111Const{2779096485,1515870810}},
      nt_append(N111Stmt,p111_frame([p192hcf_bind("result",0)],"second"),
        p111_body(p111_jump("reentry",[N111Const{0,0},p192hcf_v("marker")],0)))})

@unsafe
def p192hcf_second() -> N111Segment:
  p111_segment("second",[p192hcf_bind("carried",0),p192hcf_bind("resumed",1)],1,1,
    Con{N111Bin{"scaled",N111U64{},"mul",p192hcf_v("carried"),N111Const{33,0}},
    Con{N111Bin{"answer",N111U64{},"xor",p192hcf_v("scaled"),p192hcf_v("resumed")},
      p192hcf_return(p192hcf_v("answer"))}})

@unsafe
def p192hcf_segments() -> List<&2,N111Segment>:
  [p192hcf_owner(),p192hcf_first(),p192hcf_second()]

@unsafe
def p192hcf_ids() -> N111Ids:
  N111Ids{p111q_function_ids(p192hcf_segments(),0,missing()),missing()}

@unsafe
def p192hcf_plan() -> P114HPlan:
  p114h_plan(p192hcf_owner(),p112f_index(p192hcf_segments()),missing())

@unsafe
def p192hcf_verified(scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      nt_choose(String,String.is_empty(error),u => p111v_segments(p192hcf_segments(),N111Ids{index,missing()}),u => error)

@unsafe
def p192hcf_validate() -> String:
  p192hcf_verified(p111v_functions(p192hcf_segments(),P111VScan{missing(),"",0}))

@unsafe
def p192hcf_worker(+scoped: Bool, plan: P114HPlan) -> X181Output:
  match plan:
    case P114HPlan{valid,+params,+body,+cases}:
      nt_choose(X181Output,valid,u => x192hf_function_setup(
        nt_choose(String,scoped,v => "p192hcf_scoped",v => "p192hcf_plain"),x192h_formals(params),
        Con{P113DScalar{N111Alloca{"scratch",2048,8}},x192h_buffers(cases,0)},
        x192h_worker_body(params,body,cases),p192hcf_ids(),
        nt_choose(List<&2,String>,scoped,v => x192hf_case_buffers(cases,0),v => [])),
        u => X181Output{[],"reentry H plan refused"})

@unsafe
def p192hcf_has_frame(output: X181Output) -> Bool:
  match output:
    case X181Output{chunks,error}:
      String.is_empty(error) && String.contains(x188_render(x188_many(chunks)),"call p111_rt_frame")

@unsafe
def p192hcf_no_frame(output: X181Output) -> Bool:
  match output:
    case X181Output{chunks,error}:
      String.is_empty(error) && Bool.not(String.contains(x188_render(x188_many(chunks)),"call p111_rt_frame"))

@unsafe
def p192hcf_fids(ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{+functions,constructors}:
      U32.is_eq(da(p111v_get(functions,"first")),1) && U32.is_eq(da(p111v_get(functions,"second")),2)

@unsafe
def p192hcf_two_cases(plan: P114HPlan) -> Bool:
  match plan:
    case P114HPlan{valid,params,body,cases}: valid && U32.is_eq(nt_count(P114HCase,cases),2)

@unsafe
def p192hcf_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p192hcf_controls() -> List<&2,String>:
  [p192hcf_row("original-reentry-ir-verified",String.is_empty(p192hcf_validate())),
   p192hcf_row("reentry-H-two-cases",p192hcf_two_cases(p192hcf_plan())),
   p192hcf_row("fixed-oracle-function-ids",p192hcf_fids(p192hcf_ids())),
   p192hcf_row("plain-case-frame-call-retained",p192hcf_has_frame(p192hcf_worker(False{},p192hcf_plan()))),
   p192hcf_row("scoped-case-frame-call-removed",p192hcf_no_frame(p192hcf_worker(True{},p192hcf_plan())))]

@unsafe
def p192hcf_emit() -> X181Output:
  x181_program_join(p192hcf_worker(False{},p192hcf_plan()),p192hcf_worker(True{},p192hcf_plan()))
