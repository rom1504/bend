# Two-member tail SCCs use the existing full-Term Again loop and direct ABI.
@unsafe
def p126sc_name(function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,params,result,public,body}: name

@unsafe
def p126sc_params(function: P113DFunction) -> List<&2,NC_Binding>:
  match function:
    case P113DFunction{name,params,result,public,body}: params

@unsafe
def p126sc_body(function: P113DFunction) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,body}: body

@unsafe
def p126sc_shape(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8)

@unsafe
def p126sc_has(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,String.eq(head,name),u => True{},u => p126sc_has(rest,name))

@unsafe
def p126sc_internal(+name: String, +left: String, +right: String) -> Bool:
  String.eq(name,left) || String.eq(name,right)

# The whole residual block must be exactly Result([the call destination]).
@unsafe
def p126sc_tail(destinations: List<&2,String>, rest: List<&2,P113DStmt>) -> Bool:
  match destinations rest:
    case Con{name,Nil{}} Con{P113DResult{Con{N111Local{word},Nil{}}},Nil{}}: String.eq(name,word)
    case _ _: False{}

@unsafe
def p126sc_safe(body: List<&2,P113DStmt>, +left: String, +right: String, +la: U32, +ra: U32, +self_arity: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DCall{+destinations,+target,+args},+rest}:
      nt_choose(Bool,p126sc_internal(target,left,right),
        u => p126sc_tail(destinations,rest) && U32.is_eq(nt_count(N111Value,args),nt_choose(U32,String.eq(target,left),v => la,v => ra)),
        u => p126sc_safe(rest,left,right,la,ra,self_arity))
    case Con{P113DIf{condition,yes,no},rest}:
      p126sc_safe(yes,left,right,la,ra,self_arity) && p126sc_safe(no,left,right,la,ra,self_arity) && p126sc_safe(rest,left,right,la,ra,self_arity)
    case Con{P113DAgain{values},rest}: U32.is_eq(nt_count(P113DStmt,rest),0) && U32.is_eq(nt_count(N111Value,values),self_arity)
    case Con{stmt,rest}: p126sc_safe(rest,left,right,la,ra,self_arity)

@unsafe
def p126sc_pair_safe(+left: P113DFunction, +right: P113DFunction) -> Bool:
  +ln = p126sc_name(left)
  +rn = p126sc_name(right)
  +la = nt_count(NC_Binding,p126sc_params(left))
  +ra = nt_count(NC_Binding,p126sc_params(right))
  nt_choose(Bool,Bool.not(String.eq(ln,rn)) && p126sc_shape(left) && p126sc_shape(right),
    u => nt_choose(Bool,p126sc_has(p113j_calls(p126sc_body(left)),rn) && p126sc_has(p113j_calls(p126sc_body(right)),ln),
      v => p126sc_safe(p126sc_body(left),ln,rn,la,ra,la) && p126sc_safe(p126sc_body(right),ln,rn,la,ra,ra),
      v => False{}),u => False{})

@unsafe
def p126sc_zeros(count: U32) -> List<&2,N111Value>:
  match count:
    case 0: []
    case _: Con{N111Const{0,0},p126sc_zeros(U32.sub(count,1))}

@unsafe
def p126sc_lanes(+tag: U32, +args: List<&2,N111Value>, +width: U32) -> List<&2,N111Value>:
  Con{N111Const{tag,0},nt_append(N111Value,args,p126sc_zeros(U32.sub(width,nt_count(N111Value,args))))}

@unsafe
def p126sc_lane_params(+count: U32, +index: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(count,index),u => [],u =>
    Con{NC_Binding{index,"p126scc_arg_" ++ U32.show(index),N_W64{}},p126sc_lane_params(count,U32.inc(index))})

@unsafe
def p126sc_param_values(params: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}: Con{N111Local{word},p126sc_param_values(rest)}

@unsafe
def p126sc_bind(params: List<&2,NC_Binding>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{P113DScalar{N111Set{p112f_name(prefix,word),N111U64{},N111Local{"p126scc_arg_" ++ U32.show(index)}}},p126sc_bind(rest,prefix,U32.inc(index))}

@unsafe
def p126sc_rewrite(body: List<&2,P113DStmt>, +prefix: String, +left: String, +right: String, +self_tag: U32, +width: U32) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}:
      Con{P113DScalar{p112f_stmt(stmt,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),p126sc_rewrite(yes,prefix,left,right,self_tag,width),p126sc_rewrite(no,prefix,left,right,self_tag,width)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DCall{destinations,+target,+args},+rest}:
      nt_choose(List<&2,P113DStmt>,p126sc_internal(target,left,right),
        u => [P113DAgain{p126sc_lanes(nt_choose(U32,String.eq(target,left),v => 0,v => 1),p113j_values(args,prefix),width)}],
        u => Con{P113DCall{p113j_names(destinations,prefix),target,p113j_values(args,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)})
    case Con{P113DResult{values},rest}: Con{P113DResult{p113j_values(values,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DAgain{values},rest}: [P113DAgain{p126sc_lanes(self_tag,p113j_values(values,prefix),width)}]

@unsafe
def p126sc_external(calls: List<&2,String>, +left: String, +right: String) -> List<&2,String>:
  match calls:
    case Nil{}: []
    case Con{+name,+rest}: nt_choose(List<&2,String>,p126sc_internal(name,left,right),u => p126sc_external(rest,left,right),u => Con{name,p126sc_external(rest,left,right)})

@unsafe
def p126sc_worker(+left: P113DFunction, +right: P113DFunction, +name: String) -> P113DCandidate:
  +ln = p126sc_name(left)
  +rn = p126sc_name(right)
  +lb = p126sc_body(left)
  +rb = p126sc_body(right)
  +width = U32.max(nt_count(NC_Binding,p126sc_params(left)),nt_count(NC_Binding,p126sc_params(right)))
  +params : List<&2,NC_Binding> = Con{NC_Binding{4294967295,"p126scc_tag",N_W64{}},p126sc_lane_params(width,0)}
  +yes = nt_append(P113DStmt,p126sc_bind(p126sc_params(left),"p113i_14_",0),p126sc_rewrite(lb,"p113i_14_",ln,rn,0,width))
  +no = nt_append(P113DStmt,p126sc_bind(p126sc_params(right),"p113i_15_",0),p126sc_rewrite(rb,"p113i_15_",ln,rn,1,width))
  +body : List<&2,P113DStmt> = nt_append(P113DStmt,p113j_scratch_alloc(lb,"p113i_14_"),nt_append(P113DStmt,p113j_scratch_alloc(rb,"p113i_15_"),[
    P113DScalar{N111Bin{"p126scc_side",N111U64{},"eq",N111Local{"p126scc_tag"},N111Const{0,0}}},P113DIf{N111Local{"p126scc_side"},yes,no}]))
  P113DCandidate{P113DFunction{name,params,1,False{},body},"",p126sc_external(nt_append(String,p113j_calls(lb),p113j_calls(rb)),ln,rn)}

@unsafe
def p126sc_wrapper(function: P113DFunction, +worker: String, +tag: U32, +width: U32) -> P113DCandidate:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      P113DCandidate{P113DFunction{name,params,result,public,[
        P113DCall{["p126scc_result"],worker,p126sc_lanes(tag,p126sc_param_values(params),width)},
        P113DResult{[N111Local{"p126scc_result"}]}]},"",[worker]}
