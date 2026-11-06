# Phase173 experimental bounded tail-SCC fusion. Not selected production code.
# Replace p126sc_candidates with p173sc_candidates in a private overlay only.
# No machine recursion is admitted: internal edges become existing P113DAgain.

type P173SCFrame is Data:
  P173SCFrame{+name: String, +todo: List<&2,String>}

type P173SCSearch is Data:
  P173SCSearch{+meta: KDef, +stack: List<&2,String>, +next: U32, +groups: List<&2,List<&2,String>>}

type P173SCPop is Data:
  P173SCPop{+meta: KDef, +stack: List<&2,String>, +members: List<&2,String>}

type P173SCBuilt is Data:
  P173SCBuilt{+replacements: P113ITable, +workers: List<&2,P113DCandidate>, +slot: U32}

# Explicit helper interfaces for the pinned sequential loader.
law p173sc_result:
  for +function: P113DFunction
  U32

law p173sc_shape:
  for +function: P113DFunction
  Bool

law p173sc_table:
  for +candidates: List<&2,P113DCandidate>
  for +counts: KDef
  for +index: P113ITable
  P113ITable

law p173sc_found:
  for +found: Maybe<&2,P113DFunction>
  Bool

law p173sc_present:
  for +index: P113ITable
  for +name: String
  Bool

law p173sc_names:
  for +candidates: List<&2,P113DCandidate>
  List<&2,String>

law p173sc_call_names:
  for +calls: List<&2,KTerm>
  List<&2,String>

law p173sc_pop:
  for +owner: String
  for +stack: List<&2,String>
  for +meta: KDef
  for +members: List<&2,String>
  P173SCPop

law p173sc_popped:
  for +next: U32
  for +groups: List<&2,List<&2,String>>
  for +popped: P173SCPop
  P173SCSearch

law p173sc_exit:
  for +name: String
  for +search: P173SCSearch
  P173SCSearch

law p173sc_lower:
  for +name: String
  for +low: U32
  for +search: P173SCSearch
  P173SCSearch

law p173sc_parent:
  for +frames: List<&2,P173SCFrame>
  for +child: String
  for +search: P173SCSearch
  P173SCSearch

law p173sc_enter:
  for +name: String
  for +roots: List<&2,String>
  for +frames: List<&2,P173SCFrame>
  for +index: P113ITable
  for +counts: KDef
  for +search: P173SCSearch
  P173SCSearch

law p173sc_edge:
  for +target: String
  for +owner: String
  for +roots: List<&2,String>
  for +frames: List<&2,P173SCFrame>
  for +index: P113ITable
  for +counts: KDef
  for +search: P173SCSearch
  P173SCSearch

law p173sc_search:
  for +roots: List<&2,String>
  for +frames: List<&2,P173SCFrame>
  for +index: P113ITable
  for +counts: KDef
  for +search: P173SCSearch
  P173SCSearch

law p173sc_roots:
  for +roots: List<&2,String>
  for +index: P113ITable
  for +counts: KDef
  for +search: P173SCSearch
  P173SCSearch

law p173sc_root:
  for +name: String
  for +roots: List<&2,String>
  for +index: P113ITable
  for +counts: KDef
  for +search: P173SCSearch
  P173SCSearch

law p173sc_pending:
  for +todo: List<&2,String>
  for +name: String
  for +rest: List<&2,P173SCFrame>
  for +roots: List<&2,String>
  for +index: P113ITable
  for +counts: KDef
  for +search: P173SCSearch
  P173SCSearch

law p173sc_groups:
  for +search: P173SCSearch
  List<&2,List<&2,String>>

law p173sc_functions:
  for +names: List<&2,String>
  for +index: P113ITable
  List<&2,P113DFunction>

law p173sc_functions_found:
  for +rest: List<&2,String>
  for +index: P113ITable
  for +found: Maybe<&2,P113DFunction>
  List<&2,P113DFunction>

law p173sc_members:
  for +functions: List<&2,P113DFunction>
  for +tag: U32
  for +members: KDef
  KDef

law p173sc_vector:
  for +names: List<&2,String>
  for +values: List<&2,N111Value>
  Bool

law p173sc_tail:
  for +names: List<&2,String>
  for +rest: List<&2,P113DStmt>
  for +result: U32
  Bool

law p173sc_safe:
  for +body: List<&2,P113DStmt>
  for +members: KDef
  for +arity: U32
  for +result: U32
  Bool

law p173sc_valid:
  for +functions: List<&2,P113DFunction>
  for +members: KDef
  for +result: U32
  Bool

law p173sc_width:
  for +functions: List<&2,P113DFunction>
  U32

law p173sc_size:
  for +functions: List<&2,P113DFunction>
  U32

law p173sc_stack:
  for +functions: List<&2,P113DFunction>
  U32

law p173sc_prefix:
  for +tag: U32
  String

law p173sc_rewrite:
  for +body: List<&2,P113DStmt>
  for +prefix: String
  for +members: KDef
  for +self: U32
  for +width: U32
  List<&2,P113DStmt>

law p173sc_case:
  for +function: P113DFunction
  for +tag: U32
  for +members: KDef
  for +width: U32
  List<&2,P113DStmt>

law p173sc_cases:
  for +functions: List<&2,P113DFunction>
  for +tag: U32
  for +members: KDef
  for +width: U32
  List<&2,P113DStmt>

law p173sc_scratch:
  for +functions: List<&2,P113DFunction>
  for +tag: U32
  List<&2,P113DStmt>

law p173sc_worker:
  for +functions: List<&2,P113DFunction>
  for +members: KDef
  for +name: String
  for +width: U32
  for +result: U32
  P113DCandidate

law p173sc_wrapper:
  for +function: P113DFunction
  for +worker: String
  for +tag: U32
  for +width: U32
  P113DFunction

law p173sc_wrappers:
  for +functions: List<&2,P113DFunction>
  for +worker: String
  for +tag: U32
  for +width: U32
  for +index: P113ITable
  P113ITable

law p173sc_add:
  for +functions: List<&2,P113DFunction>
  for +members: KDef
  for +counts: KDef
  for +built: P173SCBuilt
  P173SCBuilt

law p173sc_component:
  for +names: List<&2,String>
  for +index: P113ITable
  for +counts: KDef
  for +built: P173SCBuilt
  P173SCBuilt

law p173sc_component_functions:
  for +names: List<&2,String>
  for +counts: KDef
  for +built: P173SCBuilt
  for +functions: List<&2,P113DFunction>
  P173SCBuilt

law p173sc_build:
  for +groups: List<&2,List<&2,String>>
  for +index: P113ITable
  for +counts: KDef
  for +built: P173SCBuilt
  P173SCBuilt

law p173sc_replace:
  for +candidates: List<&2,P113DCandidate>
  for +index: P113ITable
  List<&2,P113DCandidate>

law p173sc_replace_one:
  for +candidate: P113DCandidate
  for +rest: List<&2,P113DCandidate>
  for +index: P113ITable
  List<&2,P113DCandidate>

law p173sc_replace_found:
  for +candidate: P113DCandidate
  for +rest: List<&2,P113DCandidate>
  for +index: P113ITable
  for +found: Maybe<&2,P113DFunction>
  List<&2,P113DCandidate>

law p173sc_finished:
  for +candidates: List<&2,P113DCandidate>
  for +built: P173SCBuilt
  List<&2,P113DCandidate>

law p173sc_indexed:
  for +candidates: List<&2,P113DCandidate>
  for +counts: KDef
  for +index: P113ITable
  List<&2,P113DCandidate>

law p173sc_counts:
  for +candidates: List<&2,P113DCandidate>
  for +counts: KDef
  for +slot: U32
  KDef

@unsafe
def p173sc_result(function):
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}: result

@unsafe
def p173sc_shape(function):
  U32.is_le(nt_count(NC_Binding,p126sc_params(function)),31) &&
    U32.is_ge(p173sc_result(function),1) && U32.is_le(p173sc_result(function),8)

@unsafe
def p173sc_table(candidates,counts,index):
  match candidates:
    case Nil{}: index
    case Con{P113DCandidate{+function,+error,+calls},+rest}:
      +name = p126sc_name(function)
      nt_choose(P113ITable,String.is_empty(error) && p173sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
        u => p173sc_table(rest,counts,p113i_put(index,function,index_hash(name,2166136261),0)),
        u => p173sc_table(rest,counts,index))

@unsafe
def p173sc_found(found):
  match found:
    case None{}: False{}
    case Some{+function}: True{}

@unsafe
def p173sc_present(index,name):
  p173sc_found(p113i_get(index,name,index_hash(name,2166136261),0))

@unsafe
def p173sc_names(candidates):
  match candidates:
    case Nil{}: []
    case Con{P113DCandidate{+function,+error,+calls},+rest}: Con{p126sc_name(function),p173sc_names(rest)}

@unsafe
def p173sc_call_names(calls):
  match calls:
    case Nil{}: []
    case Con{+head,+rest}: Con{nm(head),p173sc_call_names(rest)}

@unsafe
def p173sc_pop(owner,stack,meta,members):
  match stack:
    case Nil{}: P173SCPop{meta,[],members}
    case Con{+name,+rest}:
      +record = p111v_get(meta,name)
      +updated = p111v_put(meta,name,"P173Done",da(record),dx(record))
      nt_choose(P173SCPop,String.eq(owner,name),
        u => P173SCPop{updated,rest,Con{name,members}},
        u => p173sc_pop(owner,rest,updated,Con{name,members}))

@unsafe
def p173sc_popped(next,groups,popped):
  match popped:
    case P173SCPop{+meta,+stack,+members}: P173SCSearch{meta,stack,next,Con{members,groups}}

@unsafe
def p173sc_exit(name,search):
  match search:
    case P173SCSearch{+meta,+stack,+next,+groups}:
      +record = p111v_get(meta,name)
      nt_choose(P173SCSearch,U32.is_eq(da(record),dx(record)),
        u => p173sc_popped(next,groups,p173sc_pop(name,stack,meta,[])),u => search)

@unsafe
def p173sc_lower(name,low,search):
  match search:
    case P173SCSearch{+meta,+stack,+next,+groups}:
      +record = p111v_get(meta,name)
      P173SCSearch{p111v_put(meta,name,dk(record),da(record),U32.min(dx(record),low)),stack,next,groups}

@unsafe
def p173sc_parent(frames,child,search):
  match frames search:
    case Nil{} _: search
    case Con{P173SCFrame{+name,+todo},+rest} P173SCSearch{+meta,+stack,+next,+groups}:
      p173sc_lower(name,dx(p111v_get(meta,child)),search)


@unsafe
def p173sc_enter(name,roots,frames,index,counts,search):
  match search:
    case P173SCSearch{+meta,+stack,+next,+groups}:
      p173sc_search(roots,Con{P173SCFrame{name,p173sc_call_names(ks(dv(p111v_get(counts,name))))},frames},index,counts,
        P173SCSearch{p111v_put(meta,name,"P173Active",next,next),Con{name,stack},U32.inc(next),groups})

@unsafe
def p173sc_edge(target,owner,roots,frames,index,counts,search):
  match search:
    case P173SCSearch{+meta,+stack,+next,+groups}:
      +record = p111v_get(meta,target)
      nt_choose(P173SCSearch,String.eq(dk(record),"Absent") && p173sc_present(index,target),
        u => p173sc_enter(target,roots,frames,index,counts,search),
        u => p173sc_search(roots,frames,index,counts,
          nt_choose(P173SCSearch,String.eq(dk(record),"P173Active"),
            v => p173sc_lower(owner,da(record),search),v => search)))

# Iterative Tarjan traversal: source graph depth uses an explicit Bend work list.
# No search budget can split a component and silently admit a partial cycle.
@unsafe
def p173sc_search(roots,frames,index,counts,search):
  match frames:
    case Nil{}: p173sc_roots(roots,index,counts,search)
    case Con{P173SCFrame{+name,+todo},+rest}: p173sc_pending(todo,name,rest,roots,index,counts,search)

@unsafe
def p173sc_roots(roots,index,counts,search):
  match roots:
    case Nil{}: search
    case Con{+name,+rest}: p173sc_root(name,rest,index,counts,search)

@unsafe
def p173sc_root(name,roots,index,counts,search):
  match search:
    case P173SCSearch{+meta,+stack,+next,+groups}:
      nt_choose(P173SCSearch,String.eq(dk(p111v_get(meta,name)),"Absent") && p173sc_present(index,name),
        u => p173sc_enter(name,roots,[],index,counts,search),
        u => p173sc_search(roots,[],index,counts,search))

@unsafe
def p173sc_pending(todo,name,rest,roots,index,counts,search):
  match todo:
    case Nil{}: p173sc_search(roots,rest,index,counts,p173sc_parent(rest,name,p173sc_exit(name,search)))
    case Con{+target,+tail}: p173sc_edge(target,name,roots,Con{P173SCFrame{name,tail},rest},index,counts,search)

@unsafe
def p173sc_groups(search):
  match search:
    case P173SCSearch{+meta,+stack,+next,+groups}: nt_reverse(List<&2,String>,groups,[])

@unsafe
def p173sc_functions(names,index):
  match names:
    case Nil{}: []
    case Con{+name,+rest}: p173sc_functions_found(rest,index,p113i_get(index,name,index_hash(name,2166136261),0))

@unsafe
def p173sc_functions_found(rest,index,found):
  match found:
    case None{}: []
    case Some{+function}: Con{function,p173sc_functions(rest,index)}

@unsafe
def p173sc_members(functions,tag,members):
  match functions:
    case Nil{}: members
    case Con{+function,+rest}:
      p173sc_members(rest,U32.inc(tag),p111v_put(members,p126sc_name(function),"P173Member",
        nt_count(NC_Binding,p126sc_params(function)),tag))

@unsafe
def p173sc_vector(names,values):
  match names values:
    case Nil{} Nil{}: True{}
    case Con{+name,+rest} Con{N111Local{+word},+tail}: String.eq(name,word) && p173sc_vector(rest,tail)
    case _ _: False{}

@unsafe
def p173sc_tail(names,rest,result):
  match rest:
    case Con{P113DResult{+values},Nil{}}: U32.is_eq(nt_count(String,names),result) && p173sc_vector(names,values)
    case _: False{}

@unsafe
def p173sc_safe(body,members,arity,result):
  match body:
    case Nil{}: True{}
    case Con{P113DCall{+destinations,+target,+args},+rest}:
      +entry = p111v_get(members,target)
      nt_choose(Bool,String.eq(dk(entry),"P173Member"),
        u => U32.is_eq(nt_count(N111Value,args),da(entry)) && p173sc_tail(destinations,rest,result),
        u => p173sc_safe(rest,members,arity,result))
    case Con{P113DIf{+condition,+yes,+no},+rest}:
      p173sc_safe(yes,members,arity,result) && p173sc_safe(no,members,arity,result) && p173sc_safe(rest,members,arity,result)
    case Con{P113DAgain{+values},+rest}: U32.is_eq(nt_count(P113DStmt,rest),0) && U32.is_eq(nt_count(N111Value,values),arity)
    case Con{+stmt,+rest}: p173sc_safe(rest,members,arity,result)

@unsafe
def p173sc_valid(functions,members,result):
  match functions:
    case Nil{}: True{}
    case Con{+function,+rest}: p173sc_shape(function) && U32.is_eq(p173sc_result(function),result) &&
      p173sc_safe(p126sc_body(function),members,nt_count(NC_Binding,p126sc_params(function)),result) && p173sc_valid(rest,members,result)

@unsafe
def p173sc_width(functions):
  match functions:
    case Nil{}: 0
    case Con{+function,+rest}: U32.max(nt_count(NC_Binding,p126sc_params(function)),p173sc_width(rest))

@unsafe
def p173sc_size(functions):
  match functions:
    case Nil{}: 0
    case Con{+function,+rest}:
      +size = p113i_size(p126sc_body(function))
      nt_choose(U32,U32.is_ge(size,4096),u => 8193,
        u => U32.min(8193,U32.add(size,p173sc_size(rest))))

@unsafe
def p173sc_stack(functions):
  match functions:
    case Nil{}: 0
    case Con{+function,+rest}: p113i_stack_add(p113i_stack_add(p113i_stack(p126sc_body(function)),p113j_scratch(p126sc_body(function))),p173sc_stack(rest))

@unsafe
def p173sc_prefix(tag):
  "p113i_" ++ U32.show(U32.div(tag,16)) ++ "_local_p113i_" ++ U32.show(U32.mod(tag,16)) ++ "_"

@unsafe
def p173sc_rewrite(body,prefix,members,self,width):
  match body:
    case Nil{}: []
    case Con{P113DScalar{+stmt},+rest}:
      Con{P113DScalar{p112f_stmt(stmt,prefix)},p173sc_rewrite(rest,prefix,members,self,width)}
    case Con{P113DIf{+condition,+yes,+no},+rest}:
      Con{P113DIf{p112f_value(condition,prefix),p173sc_rewrite(yes,prefix,members,self,width),p173sc_rewrite(no,prefix,members,self,width)},p173sc_rewrite(rest,prefix,members,self,width)}
    case Con{P113DCall{+destinations,+target,+args},+rest}:
      +entry = p111v_get(members,target)
      nt_choose(List<&2,P113DStmt>,String.eq(dk(entry),"P173Member"),
        u => [P113DAgain{p126sc_lanes(dx(entry),p113j_values(args,prefix),width)}],
        u => Con{P113DCall{p113j_names(destinations,prefix),target,p113j_values(args,prefix)},p173sc_rewrite(rest,prefix,members,self,width)})
    case Con{P113DResult{+values},+rest}: Con{P113DResult{p113j_values(values,prefix)},p173sc_rewrite(rest,prefix,members,self,width)}
    case Con{P113DAgain{+values},+rest}: [P113DAgain{p126sc_lanes(self,p113j_values(values,prefix),width)}]

@unsafe
def p173sc_case(function,tag,members,width):
  +prefix = p173sc_prefix(tag)
  nt_append(P113DStmt,p126sc_bind(p126sc_params(function),prefix,0),p173sc_rewrite(p126sc_body(function),prefix,members,tag,width))

@unsafe
def p173sc_cases(functions,tag,members,width):
  match functions:
    case Nil{}: []
    case Con{+function,Nil{}}: p173sc_case(function,tag,members,width)
    case Con{+function,+rest}:
      +test = "p173sc_test_" ++ U32.show(tag)
      [P113DScalar{N111Bin{test,N111U64{},"eq",N111Local{"p126scc_tag"},N111Const{tag,0}}},
       P113DIf{N111Local{test},p173sc_case(function,tag,members,width),p173sc_cases(rest,U32.inc(tag),members,width)}]

@unsafe
def p173sc_scratch(functions,tag):
  match functions:
    case Nil{}: []
    case Con{+function,+rest}: nt_append(P113DStmt,p113j_scratch_alloc(p126sc_body(function),p173sc_prefix(tag)),p173sc_scratch(rest,U32.inc(tag)))

@unsafe
def p173sc_worker(functions,members,name,width,result):
  +body = nt_append(P113DStmt,p173sc_scratch(functions,0),p173sc_cases(functions,0,members,width))
  P113DCandidate{P113DFunction{name,Con{NC_Binding{4294967295,"p126scc_tag",N_W64{}},p126sc_lane_params(width,0)},result,False{},body},"",p113j_calls(body)}

@unsafe
def p173sc_wrapper(function,worker,tag,width):
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +destinations = p113pl_names("p173sc_result",result,0)
      P113DFunction{name,params,result,public,[
        P113DCall{destinations,worker,p126sc_lanes(tag,p126sc_param_values(params),width)},
        P113DResult{p113pl_locals(destinations)}]}

@unsafe
def p173sc_wrappers(functions,worker,tag,width,index):
  match functions:
    case Nil{}: index
    case Con{+function,+rest}:
      p173sc_wrappers(rest,worker,U32.inc(tag),width,p113i_put(index,p173sc_wrapper(function,worker,tag,width),index_hash(p126sc_name(function),2166136261),0))

@unsafe
def p173sc_add(functions,members,counts,built):
  match functions built:
    case Nil{} _: built
    case Con{+first,+rest} P173SCBuilt{+replacements,+workers,+slot}:
      +name = "$p173scc." ++ U32.show(slot)
      +result = p173sc_result(first)
      +width = p173sc_width(functions)
      nt_choose(P173SCBuilt,String.eq(dk(p111v_get(counts,name)),"Absent") && p173sc_valid(functions,members,result) &&
        U32.is_le(p173sc_size(functions),8192) && U32.is_le(p173sc_stack(functions),16384),
        u => P173SCBuilt{p173sc_wrappers(functions,name,0,width,replacements),Con{p173sc_worker(functions,members,name,width,result),workers},U32.inc(slot)},
        u => built)

@unsafe
def p173sc_component(names,index,counts,built):
  +size = nt_count(String,names)
  nt_choose(P173SCBuilt,U32.is_ge(size,2) && U32.is_le(size,64),
    u => p173sc_component_functions(names,counts,built,p173sc_functions(names,index)),u => built)

@unsafe
def p173sc_component_functions(names,counts,built,functions):
  nt_choose(P173SCBuilt,U32.is_eq(nt_count(String,names),nt_count(P113DFunction,functions)),
    u => p173sc_add(functions,p173sc_members(functions,0,missing()),counts,built),u => built)

@unsafe
def p173sc_build(groups,index,counts,built):
  match groups:
    case Nil{}: built
    case Con{+names,+rest}: p173sc_build(rest,index,counts,p173sc_component(names,index,counts,built))

@unsafe
def p173sc_replace(candidates,index):
  match candidates:
    case Nil{}: []
    case Con{+candidate,+rest}: p173sc_replace_one(candidate,rest,index)

@unsafe
def p173sc_replace_one(candidate,rest,index):
  match candidate:
    case P113DCandidate{+function,+error,+calls}:
      +name = p126sc_name(function)
      p173sc_replace_found(candidate,rest,index,p113i_get(index,name,index_hash(name,2166136261),0))

@unsafe
def p173sc_replace_found(candidate,rest,index,found):
  match found:
    case None{}: Con{candidate,p173sc_replace(rest,index)}
    case Some{+replacement}: Con{P113DCandidate{replacement,"",p113j_calls(p126sc_body(replacement))},p173sc_replace(rest,index)}

@unsafe
def p173sc_finished(candidates,built):
  match built:
    case P173SCBuilt{+replacements,+workers,+slot}: nt_append(P113DCandidate,nt_reverse(P113DCandidate,workers,[]),p173sc_replace(candidates,replacements))

@unsafe
def p173sc_indexed(candidates,counts,index):
  +groups = p173sc_groups(p173sc_search(p173sc_names(candidates),[],index,counts,P173SCSearch{missing(),[],1,[]}))
  p173sc_finished(candidates,p173sc_build(groups,index,counts,P173SCBuilt{P113IEmpty{},[],0}))

@unsafe
def p173sc_candidates(candidates):
  +counts = p173sc_counts(candidates,missing(),0)
  p173sc_indexed(candidates,counts,p173sc_table(candidates,counts,P113IEmpty{}))

# Derive edges from the actual structured bodies once. Stale auxiliary calls
# metadata is not permission to omit an edge from the component discovered.
@unsafe
def p173sc_counts(candidates,counts,slot):
  match candidates:
    case Nil{}: counts
    case Con{P113DCandidate{+function,+error,+calls},+rest}:
      +name = p126sc_name(function)
      p173sc_counts(rest,index_set(counts,KDef{name,"P126Count",U32.inc(da(p111v_get(counts,name))),slot,
        atom("Absent"),kt("Calls","",0,0,p126sc_call_terms(p113j_calls(p126sc_body(function)))),[],False{},False{}},
        index_hash(name,2166136261),32),U32.inc(slot))
