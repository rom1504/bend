# Analysis only. A float parameter is a proof that every possible observation
# of its high word is absent. N_W32 alone is deliberately not such a proof.
# The original verified graph and word ABI remain unchanged.
type P126TPlan is Data:
  P126TPlan{+function: P113DFunction, +floats: List<&2,String>}

@unsafe
def p126t_find(plans: List<&2,P126TPlan>, +name: String) -> Maybe<&2,P126TPlan>:
  match plans:
    case Nil{}: None{}
    case Con{P126TPlan{P113DFunction{+target,+params,+result,+public,+body},+floats},rest}:
      nt_choose(Maybe<&2,P126TPlan>,String.eq(name,target),
        u => Some{P126TPlan{P113DFunction{target,params,result,public,body},floats}},
        u => p126t_find(rest,name))

# Graph nodes: arity=full-word observation, templates=float-only observation,
# ctors=possible copy/backedge destinations. Names are never killed: every
# overwrite and both branch arms add possibilities, so joins overapproximate.
@unsafe
def p126a_node(+graph: KDef, +name: String, +bad: U32, +used: U32, +edges: List<&2,KDef>) -> KDef:
  index_set(graph,KDef{name,"P126TNode",bad,used,atom("Absent"),atom("Absent"),edges,False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p126a_mark(value: N111Value, +graph: KDef, +bad: U32, +used: U32) -> KDef:
  match value:
    case N111Local{+name}:
      +old = p111v_get(graph,name)
      p126a_node(graph,name,U32.or(da(old),bad),U32.or(dx(old),used),dc(old))
    case _: graph

@unsafe
def p126a_edge(value: N111Value, +destination: String, +graph: KDef) -> KDef:
  match value:
    case N111Local{+source}:
      +old = p111v_get(graph,source)
      p126a_node(graph,source,da(old),dx(old),Con{KDef{destination,"P126TEdge",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},dc(old)})
    case _: graph

@unsafe
def p126a_values(values: List<&2,N111Value>, graph: KDef) -> KDef:
  match values:
    case Nil{}: graph
    case Con{head,rest}: p126a_values(rest,p126a_mark(head,graph,1,0))

@unsafe
def p126a_args(args: List<&2,N111Arg>, graph: KDef) -> KDef:
  match args:
    case Nil{}: graph
    case Con{N111Arg{typ,value},rest}: p126a_args(rest,p126a_mark(value,graph,1,0))

@unsafe
def p126a_scalar(stmt: N111Stmt, +graph: KDef) -> KDef:
  match stmt:
    case N111Set{name,N111U64{},value}: p126a_edge(value,name,graph)
    case N111Set{name,typ,value}: p126a_mark(value,graph,1,0)
    case N111Bin{name,typ,op,left,right}: p126a_mark(right,p126a_mark(left,graph,1,0),1,0)
    case N111Call{name,typ,symbol,args}: p126a_args(args,graph)
    case N111If{condition,yes,no}: p126a_scalars(no,p126a_scalars(yes,p126a_mark(condition,graph,1,0)))
    case N111Return{value}: p126a_mark(value,graph,1,0)
    case N111Load{name,typ,base,offset}: p126a_mark(base,graph,1,0)
    case N111Store{typ,base,offset,value}: p126a_mark(value,p126a_mark(base,graph,1,0),1,0)
    case N111Offset{name,base,bytes}: p126a_mark(bytes,p126a_mark(base,graph,1,0),1,0)
    case N111Alloca{name,bytes,align}: graph

@unsafe
def p126a_scalars(body: List<&2,N111Stmt>, graph: KDef) -> KDef:
  match body:
    case Nil{}: graph
    case Con{head,rest}: p126a_scalars(rest,p126a_scalar(head,graph))

@unsafe
def p126a_again(values: List<&2,N111Value>, params: List<&2,NC_Binding>, graph: KDef) -> KDef:
  match values params:
    case Nil{} _: graph
    case Con{head,rest} Con{NC_Binding{id,word,kind},tail}: p126a_again(rest,tail,p126a_edge(head,word,graph))
    case Con{head,rest} Nil{}: p126a_values(Con{head,rest},graph)

@unsafe
def p126a_call_args(values: List<&2,N111Value>, params: List<&2,NC_Binding>, +floats: List<&2,String>, +graph: KDef) -> KDef:
  match values params:
    case Nil{} _: graph
    case Con{+head,+rest} Con{NC_Binding{id,word,kind},+tail}:
      nt_choose(KDef,p114so_member(floats,word),
        u => p126a_call_args(rest,tail,floats,p126a_mark(head,graph,0,1)),
        u => p126a_call_args(rest,tail,floats,p126a_mark(head,graph,1,0)))
    case Con{head,rest} Nil{}: p126a_values(Con{head,rest},graph)

@unsafe
def p126a_call(plan: Maybe<&2,P126TPlan>, +values: List<&2,N111Value>, +graph: KDef) -> KDef:
  match plan:
    case None{}: p126a_values(values,graph)
    case Some{P126TPlan{P113DFunction{name,params,result,public,body},floats}}:
      p126a_call_args(values,params,floats,graph)

@unsafe
def p126a_head(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +plans: List<&2,P126TPlan>, +buffers: List<&2,String>, +graph: KDef) -> KDef:
  match body:
    case Nil{}: graph
    case Con{P113DScalar{stmt},rest}: p126a_body(rest,params,plans,buffers,p126a_scalar(stmt,graph))
    case Con{P113DIf{condition,yes,no},rest}:
      p126a_body(rest,params,plans,buffers,p126a_body(no,params,plans,buffers,
        p126a_body(yes,params,plans,buffers,p126a_mark(condition,graph,1,0))))
    case Con{P113DCall{names,target,args},rest}:
      p126a_body(rest,params,plans,buffers,p126a_call(p126t_find(plans,target),args,graph))
    case Con{P113DResult{values},rest}: p126a_body(rest,params,plans,buffers,p126a_values(values,graph))
    case Con{P113DAgain{values},rest}: p126a_body(rest,params,plans,buffers,p126a_again(values,params,graph))

@unsafe
def p126a_group(group: P114SOGroup, +body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +plans: List<&2,P126TPlan>, +buffers: List<&2,String>, +graph: KDef) -> KDef:
  match group:
    case P114SONo{}: p126a_head(body,params,plans,buffers,graph)
    case P114SOYes{buffer,name,id,+left,+right,+rest}:
      nt_choose(KDef,p114so_member(buffers,buffer),
        u => p126a_body(rest,params,plans,buffers,p126a_mark(right,p126a_mark(left,graph,0,1),0,1)),
        u => p126a_head(body,params,plans,buffers,graph))

@unsafe
def p126a_body(+body: List<&2,P113DStmt>, params: List<&2,NC_Binding>, plans: List<&2,P126TPlan>, buffers: List<&2,String>, graph: KDef) -> KDef:
  p126a_group(p114so_group(body),body,params,plans,buffers,graph)

@unsafe
def p126a_edge_names(edges: List<&2,KDef>, todo: List<&2,String>) -> List<&2,String>:
  match edges:
    case Nil{}: todo
    case Con{head,rest}: p126a_edge_names(rest,Con{dn(head),todo})

# At most 256 distinct alias names are explored per formal. Exhaustion refuses.
@unsafe
def p126a_visit(todo: List<&2,String>, +graph: KDef, +visited: KDef, +fuel: U32, +used: Bool) -> Bool:
  match todo:
    case Nil{}: used
    case Con{+name,+rest}:
      nt_choose(Bool,Bool.not(String.eq(dk(p111v_get(visited,name)),"Absent")),
        u => p126a_visit(rest,graph,visited,fuel,used),
        u => nt_choose(Bool,U32.is_eq(fuel,0),v => False{},v =>
          p126a_visit_node(p111v_get(graph,name),rest,graph,p111v_put(visited,name,"P126TSeen",0,0),U32.sub(fuel,1),used)))

@unsafe
def p126a_visit_node(+node: KDef, +todo: List<&2,String>, +graph: KDef, +visited: KDef, +fuel: U32, +used: Bool) -> Bool:
  nt_choose(Bool,U32.is_eq(da(node),0),
    u => p126a_visit(p126a_edge_names(dc(node),todo),graph,visited,fuel,used || U32.is_gt(dx(node),0)),
    u => False{})

@unsafe
def p126a_formals(params: List<&2,NC_Binding>, +graph: KDef, +acc: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{NC_Binding{id,+word,kind},+rest}:
      nt_choose(List<&2,String>,p126a_visit([word],graph,missing(),256,False{}),
        u => p126a_formals(rest,graph,Con{word,acc}),u => p126a_formals(rest,graph,acc))

@unsafe
def p126t_analyze(function: P113DFunction, +plans: List<&2,P126TPlan>) -> List<&2,String>:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      nt_choose(List<&2,String>,U32.is_le(nt_count(NC_Binding,params),32) && U32.is_le(p113i_size(body),4096),
        u => nt_choose(List<&2,String>,U32.is_eq(p113a_count_body(body,0),0),
          v => p126a_formals(params,p126a_body(body,params,plans,p114so_buffers(body),missing()),[]),v => []),u => [])

@unsafe
def p126a_collect(floats: List<&2,String>, +function: P113DFunction, +plans: List<&2,P126TPlan>) -> List<&2,P126TPlan>:
  match floats:
    case Nil{}: plans
    case Con{head,rest}: Con{P126TPlan{function,Con{head,rest}},plans}

# The original direct verifier requires prior callable signatures, so the input
# order is already a dependency order. Again supplies the only admitted cycle.
@unsafe
def p126a_plans_loop(functions: List<&2,P113DFunction>, +plans: List<&2,P126TPlan>) -> List<&2,P126TPlan>:
  match functions:
    case Nil{}: nt_reverse(P126TPlan,plans,[])
    case Con{+function,rest}: p126a_plans_loop(rest,p126a_collect(p126t_analyze(function,plans),function,plans))

@unsafe
def p126t_plans(functions: List<&2,P113DFunction>) -> List<&2,P126TPlan>:
  p126a_plans_loop(functions,[])
