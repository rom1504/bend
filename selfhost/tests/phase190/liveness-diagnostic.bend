# Read-only diagnostic replay of the maintained private x86 preparation path.
# The caller supplies an exact source function name. No IR is changed or run.
def p190ld_b(value: Bool) -> String: nt_choose(String,value,u => "1",u => "0")

def p190ld_value(value: N111Value) -> String:
  match value:
    case N111Local{name}: name
    case N111Const{lo,hi}: "const(" ++ U32.show(lo) ++ "," ++ U32.show(hi) ++ ")"
    case N111Symbol{name}: "symbol(" ++ name ++ ")"
    case N111FuncId{name}: "function(" ++ name ++ ")"
    case N111CtorId{name}: "ctor(" ++ name ++ ")"

@unsafe
def p190ld_values(values: List<&2,N111Value>) -> String:
  match values:
    case Nil{}: ""
    case Con{head,rest}: p190ld_value(head) ++ ";" ++ p190ld_values(rest)

@unsafe
def p190ld_args(args: List<&2,N111Arg>) -> String:
  match args:
    case Nil{}: ""
    case Con{N111Arg{typ,value},rest}: p190ld_value(value) ++ ";" ++ p190ld_args(rest)

@unsafe
def p190ld_scalar(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{name,typ,value}: name ++ "=set/" ++ U32.show(p111v_type(typ)) ++ " " ++ p190ld_value(value)
    case N111Bin{name,typ,op,left,right}: name ++ "=" ++ op ++ "/" ++ U32.show(p111v_type(typ)) ++ " " ++ p190ld_value(left) ++ " " ++ p190ld_value(right)
    case N111Load{name,typ,base,offset}: name ++ "=load " ++ p190ld_value(base) ++ "+" ++ U32.show(offset)
    case N111Store{typ,base,offset,value}: "store " ++ p190ld_value(base) ++ "+" ++ U32.show(offset) ++ " " ++ p190ld_value(value)
    case N111Offset{name,base,bytes}: name ++ "=offset " ++ p190ld_value(base) ++ " " ++ p190ld_value(bytes)
    case N111Alloca{name,bytes,align}: name ++ "=alloca " ++ U32.show(bytes)
    case N111Call{name,typ,symbol,args}: name ++ "=call " ++ symbol ++ " " ++ p190ld_args(args)
    case N111Return{value}: "return " ++ p190ld_value(value)
    case N111If{condition,yes,no}: "scalar-if " ++ p190ld_value(condition)

law p190ld_body:
  for +body: List<&2,P113DStmt>
  for +prefix: String
  for +facts: X190BranchFacts
  List<&2,String>

@unsafe
def p190ld_adjacent(body: List<&2,P113DStmt>, +prefix: String, +facts: X190BranchFacts) -> List<&2,String>:
  match body:
    case Con{P113DScalar{N111Bin{+name,+typ,+op,left,right}},Con{P113DIf{+condition,yes,no},rest}}:
      [prefix ++ "adjacent " ++ name ++ " condition=" ++ p190ld_value(condition) ++ " allowed=" ++
        p190ld_b(x190_branch_allowed(name,typ,op,condition,facts))]
    case _: []

@unsafe
def p190ld_stmt(stmt: P113DStmt, +prefix: String, +facts: X190BranchFacts) -> List<&2,String>:
  match stmt:
    case P113DScalar{N111If{condition,yes,no}}:
      Con{prefix ++ "if " ++ p190ld_value(condition),nt_append(String,
        p190ld_body(x181_scalar_rows(yes),prefix ++ "Y/",facts),p190ld_body(x181_scalar_rows(no),prefix ++ "N/",facts))}
    case P113DScalar{scalar}: [prefix ++ p190ld_scalar(scalar)]
    case P113DIf{condition,yes,no}:
      Con{prefix ++ "if " ++ p190ld_value(condition),nt_append(String,
        p190ld_body(yes,prefix ++ "Y/",facts),p190ld_body(no,prefix ++ "N/",facts))}
    case P113DCall{names,target,args}: [prefix ++ "direct-call " ++ target ++ " " ++ p190ld_values(args)]
    case P113DResult{values}: [prefix ++ "result " ++ p190ld_values(values)]
    case P113DAgain{values}: [prefix ++ "again " ++ p190ld_values(values)]

@unsafe
def p190ld_body(body,prefix,facts):
  match body:
    case Nil{}: []
    case Con{head,rest}: nt_append(String,p190ld_adjacent(body,prefix,facts),
      nt_append(String,p190ld_stmt(head,prefix,facts),p190ld_body(rest,prefix,facts)))

@unsafe
def p190ld_home(+name: String, +reads: KDef, +writes: KDef, +pairs: KDef, frame: X181Frame) -> String:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      "home " ++ name ++ " reads=" ++ U32.show(da(p111v_get(reads,name))) ++ " writes=" ++ U32.show(da(p111v_get(writes,name))) ++
        " pairs=" ++ U32.show(da(p111v_get(pairs,name))) ++ " kind=" ++ dk(slot) ++ " index=" ++ U32.show(da(slot))

@unsafe
def p190ld_homes(names: List<&2,String>, +reads: KDef, +writes: KDef, +pairs: KDef, +frame: X181Frame) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{p190ld_home(name,reads,writes,pairs,frame),p190ld_homes(rest,reads,writes,pairs,frame)}

@unsafe
def p190ld_report(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +frame: X181Frame,
    counts: X181ReadCounts, +facts: X190BranchFacts) -> List<&2,String>:
  match counts facts:
    case X181ReadCounts{reads,names} X190BranchFacts{allReads,writes,pairs,protected}:
      nt_append(String,["body-statements=" ++ U32.show(p113i_size(body)),"setup-statements=" ++ U32.show(p113i_size(setup)),
        "float-path=" ++ p190ld_b(x186_f_has_body(body)),"liveness-safe=" ++ p190ld_b(x190_l_safe_body(setup) && x190_l_safe_body(body))],
        nt_append(String,p190ld_homes(nt_reverse(String,names,[]),allReads,writes,pairs,frame),
          nt_append(String,p190ld_body(setup,"setup/",facts),p190ld_body(body,"body/",facts))))

@unsafe
def p190ld_final(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,String>:
  +all = nt_append(P113DStmt,setup,body)
  +frame = x190_liveness_frame(x181_register_frame(x181_frame("diagnostic",params,all),
    nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => body,u => all)),params,setup,body)
  p190ld_report(params,setup,body,frame,x181_reads_stmts(body,x181_reads_stmts(setup,X181ReadCounts{missing(),[]})),x190_branch_facts(params,setup,body))

@unsafe
def p190ld_memory(+params: List<&2,String>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> List<&2,String>:
  p190ld_final(params,setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,x186_private_body(params,setup,body)))))

@unsafe
def p190ld_place(+params: List<&2,String>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> List<&2,String>:
  p190ld_memory(params,setup,x185_prepare_body(params,setup,x185_scratch_body(params,setup,body)))

@unsafe
def p190ld_late_body(params: List<&2,String>, setup: List<&2,P113DStmt>, body: P113ABody) -> List<&2,String>:
  match body:
    case P113ABody{ready,next}: p190ld_place(params,setup,ready)

@unsafe
def p190ld_late_setup(params: List<&2,String>, body: List<&2,P113DStmt>, ids: N111Ids, setup: P113ABody) -> List<&2,String>:
  match setup:
    case P113ABody{ready,next}: p190ld_late_body(params,ready,x185_late_stmts(body,ids,next))

@unsafe
def p190ld_setup(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> List<&2,String>:
  nt_choose(List<&2,String>,x185_late_enabled() && p114t_names(params) && p114t_body_names(setup) && p114t_body_names(body),
    u => p190ld_late_setup(params,body,ids,x185_late_stmts(setup,ids,0)),u => p190ld_place(params,setup,body))

@unsafe
def p190ld_array_emit(function: P113DFunction, prelude: List<&2,N111Stmt>, ids: N111Ids) -> List<&2,String>:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      p190ld_setup(Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
        u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})},
        x181_scalar_rows(Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude}),body,ids)

@unsafe
def p190ld_array_scanned(+function: P113DFunction, +ids: N111Ids, +heap: U32, scan: P117HScan) -> List<&2,String>:
  match function scan:
    case P113DFunction{+name,+params,+result,+public,+body} P117HScan{facts,slots,+mask,+used,+again,left,+next,+sites}:
      +used = U32.and(mask,used)
      nt_choose(List<&2,String>,again && U32.is_gt(used,0) && U32.is_gt(next,0) &&
          U32.is_le(p113i_size(body),1024) && p117v_all(sites,next,used,0),
        u => Con{"array-path=versioned",p190ld_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,used,sites)),
          nt_append(N111Stmt,p117h_prelude(params,1,used,heap),x185_array_dispatch(name,params,result,used)),ids)},
        u => nt_choose(List<&2,String>,again && U32.is_gt(used,0),
          v => Con{"array-path=hoisted",p190ld_array_emit(p113a_function_done(name,params,result,public,p117h_rewrite(body,0,heap,used,sites)),
            p117h_prelude(params,1,used,heap),ids)},
          v => Con{"array-path=plain",p190ld_array_emit(p113a_function(function,heap),[],ids)}))

@unsafe
def p190ld_array_selected(+function: P113DFunction, +ids: N111Ids, +heap: U32) -> List<&2,String>:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(List<&2,String>,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),
        u => p190ld_array_emit(p113a_function(function,heap),[],ids),
        u => p190ld_array_scanned(function,ids,heap,p117h_walk(body,count,
          P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()})))

@unsafe
def p190ld_function(+function: P113DFunction, context: P134Context) -> List<&2,String>:
  match function context:
    case P113DFunction{name,+params,+result,public,+body} P134Context{+ids,index,direct,ready,view,lookups,+heap,+mode}:
      nt_choose(List<&2,String>,U32.is_eq(mode,2) && U32.is_gt(p113a_count_body(body,0),0) && p113a_params(params) && p113a_body_names(body),
        u => p190ld_array_selected(function,ids,heap),
        u => p190ld_setup(Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
          v => x181_param_names(params),v => Con{"__x181_result_out",x181_param_names(params)})},[],body,ids))

@unsafe
def p190ld_cursor(cursor: P134Cursor, +target: String) -> List<&2,String>:
  match cursor:
    case P134Private{Nil{},context,next}: p190ld_cursor(next,target)
    case P134Private{Con{+head,rest},+context,next}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,String>,String.eq(name,target),u => Con{"function=" ++ name,p190ld_function(head,context)},
            u => p190ld_cursor(P134Private{rest,context,next},target))
    case P134Legacy{entries,context,next}: p190ld_cursor(next,target)
    case P134Public{segments,context,next}: p190ld_cursor(next,target)
    case _: ["target-not-found=" ++ target]

@unsafe
def p190ld_probe(prepared: P169Prepared, target: String) -> List<&2,String>:
  match prepared:
    case P169Prepared{forwarders,cursor,+error}:
      nt_choose(List<&2,String>,String.is_empty(error),u => p190ld_cursor(cursor,target),u => ["error=" ++ error])
