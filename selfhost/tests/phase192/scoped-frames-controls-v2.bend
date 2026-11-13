# V2 controls include all original rows plus duplicate-definition boundaries.
# Compiler-data checks for scope materialization and canonical expansion
# refusals. Runtime stack/ownership controls use the H sentinel observer.
@unsafe
def p192hf_buffer() -> String: p112f_name(p114h_prefix(0),"scratch")

@unsafe
def p192hf_ids() -> N111Ids:
  N111Ids{p111v_put(missing(),"resume","N111Id",7,0),missing()}

def p192hf_call(state: String, symbol: String, buffer: String, count: U32, high: U32) -> N111Stmt:
  N111Call{"answer",N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},N111FuncId{"resume"}},N111Arg{N111Ptr{},N111Local{buffer}},
    N111Arg{N111U32{},N111Const{count,high}}]}

@unsafe
def p192hf_good() -> N111Stmt:
  p192hf_call("state","p111_rt_frame",p192hf_buffer(),1,0)

@unsafe
def p192hf_setup() -> List<&2,P113DStmt>:
  [P113DScalar{N111Alloca{p192hf_buffer(),2048,8}}]

@unsafe
def p192hf_scope_count(scope: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>, params: List<&2,String>) -> U32:
  nt_count(String,x192hf_scope(scope,params,setup,body))

law p192hf_calls:
  for rows: List<&2,N111Stmt>
  U32

@unsafe
def p192hf_calls(rows):
  match rows:
    case Nil{}: 0
    case Con{N111Call{name,typ,symbol,args},rest}: U32.inc(p192hf_calls(rest))
    case Con{N111If{condition,yes,no},rest}: U32.add(p192hf_calls(yes),U32.add(p192hf_calls(no),p192hf_calls(rest)))
    case Con{head,rest}: p192hf_calls(rest)

@unsafe
def p192hf_refused(stmt: N111Stmt, ids: N111Ids, scope: List<&2,String>, site: U32) -> Bool:
  U32.is_eq(p192hf_calls(x192hf_scalar(stmt,ids,site,scope)),1)

@unsafe
def p192hf_row(name: String, okay: Bool) -> String:
  name ++ nt_choose(String,okay,u => "=1",u => "=0")

@unsafe
def p192hf_expansion_shape(rows: List<&2,N111Stmt>, site: U32) -> Bool:
  match rows:
    case Con{N111Load{name,N111Ptr{},N111Local{state},16},rest}:
      String.eq(name,p114t_name(site,"sp")) && String.eq(state,"state") && U32.is_eq(p192hf_calls(rest),0)
    case _: False{}

@unsafe
def p192hf_counter(result: P113ABody) -> Bool:
  match result:
    case P113ABody{Con{P113DIf{condition,yes,no},Con{P113DScalar{N111Load{name,N111Ptr{},base,16}},rest}},next}:
      U32.is_eq(next,3) && String.eq(name,p114t_name(2,"sp"))
    case _: False{}

@unsafe
def p192hf_controls() -> List<&2,String>:
  +scope: List<&2,String> = [p192hf_buffer()]
  [p192hf_row("allocated-factory-scope",U32.is_eq(p192hf_scope_count(scope,p192hf_setup(),[],["state"]),1)),
   p192hf_row("empty-scope-fast-refusal",p192hf_refused(p192hf_good(),p192hf_ids(),[],0)),
   p192hf_row("scoped-frame-expanded",p192hf_expansion_shape(x192hf_scalar(p192hf_good(),p192hf_ids(),0,scope),0)),
   p192hf_row("unknown-name-not-authority",U32.is_eq(p192hf_scope_count(["ordinary"],
     [P113DScalar{N111Alloca{"ordinary",2048,8}}],[],[]),0)),
   p192hf_row("case-eight-outside-factory-bound",U32.is_eq(p192hf_scope_count([p112f_name(p114h_prefix(8),"scratch")],
     [P113DScalar{N111Alloca{p112f_name(p114h_prefix(8),"scratch"),2048,8}}],[],[]),0)),
   p192hf_row("missing-allocation-refused",U32.is_eq(p192hf_scope_count(scope,[],[],[]),0)),
   p192hf_row("body-only-allocation-refused",U32.is_eq(p192hf_scope_count(scope,[],p192hf_setup(),[]),0)),
   p192hf_row("short-allocation-refused",U32.is_eq(p192hf_scope_count(scope,
     [P113DScalar{N111Alloca{p192hf_buffer(),16,8}}],[],[]),0)),
   p192hf_row("wrong-alignment-refused",U32.is_eq(p192hf_scope_count(scope,
     [P113DScalar{N111Alloca{p192hf_buffer(),2048,4}}],[],[]),0)),
   p192hf_row("duplicate-allocation-refused",U32.is_eq(p192hf_scope_count(scope,
     nt_append(P113DStmt,p192hf_setup(),p192hf_setup()),[],[]),0)),
   p192hf_row("wrong-alignment-second-setup-allocation-refused",U32.is_eq(p192hf_scope_count(scope,
     nt_append(P113DStmt,p192hf_setup(),[P113DScalar{N111Alloca{p192hf_buffer(),2048,4}}]),[],[]),0)),
   p192hf_row("body-second-allocation-refused",U32.is_eq(p192hf_scope_count(scope,p192hf_setup(),p192hf_setup(),[]),0)),
   p192hf_row("nested-setup-second-allocation-refused",U32.is_eq(p192hf_scope_count(scope,
     nt_append(P113DStmt,p192hf_setup(),[P113DIf{N111Const{1,0},p192hf_setup(),[]}]),[],[]),0)),
   p192hf_row("nested-body-second-allocation-refused",U32.is_eq(p192hf_scope_count(scope,p192hf_setup(),
     [P113DIf{N111Const{1,0},[],p192hf_setup()}],[]),0)),
   p192hf_row("nested-scalar-body-allocation-refused",U32.is_eq(p192hf_scope_count(scope,p192hf_setup(),
     [P113DScalar{N111If{N111Const{1,0},[N111Alloca{p192hf_buffer(),2048,8}],[]}}],[]),0)),
   p192hf_row("duplicate-scope-refused",U32.is_eq(p192hf_scope_count([p192hf_buffer(),p192hf_buffer()],p192hf_setup(),[],[]),0)),
   p192hf_row("incoming-buffer-refused",U32.is_eq(p192hf_scope_count(scope,p192hf_setup(),[],scope),0)),
   p192hf_row("redefined-buffer-refused",U32.is_eq(p192hf_scope_count(scope,p192hf_setup(),[
     P113DScalar{N111Set{p192hf_buffer(),N111Ptr{},N111Local{"other"}}}],[]),0)),
   p192hf_row("partial-scope-keeps-other-frame",p192hf_refused(
     p192hf_call("state","p111_rt_frame",p112f_name(p114h_prefix(1),"scratch"),1,0),p192hf_ids(),scope,0)),
   p192hf_row("unknown-function-id-refused",p192hf_refused(p192hf_good(),N111Ids{missing(),missing()},scope,0)),
   p192hf_row("wrong-state-refused",p192hf_refused(p192hf_call("other","p111_rt_frame",p192hf_buffer(),1,0),p192hf_ids(),scope,0)),
   p192hf_row("wrong-symbol-refused",p192hf_refused(p192hf_call("state","unknown",p192hf_buffer(),1,0),p192hf_ids(),scope,0)),
   p192hf_row("large-capture-count-refused",p192hf_refused(p192hf_call("state","p111_rt_frame",p192hf_buffer(),9,0),p192hf_ids(),scope,0)),
   p192hf_row("high-capture-count-refused",p192hf_refused(p192hf_call("state","p111_rt_frame",p192hf_buffer(),1,1),p192hf_ids(),scope,0)),
   p192hf_row("site-saturation-refused",p192hf_refused(p192hf_good(),p192hf_ids(),scope,4294967200)),
   p192hf_row("nonzero-site-shared-factory",p192hf_expansion_shape(x192hf_scalar(p192hf_good(),p192hf_ids(),17,scope),17)),
   p192hf_row("nested-branches-share-counter",p192hf_counter(x192hf_late_stmts([
     P113DIf{N111Local{"condition"},[P113DScalar{p192hf_good()}],[P113DScalar{p192hf_good()}]},
     P113DScalar{p192hf_good()}],p192hf_ids(),0,scope)))]
