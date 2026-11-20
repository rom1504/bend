# Experimental runtime fixed-state certificate. Facts: 0 unknown, 1 independent
# of fuel/counter, 2 counter plus an independent U32 delta, 3 full fuel minus one.
type X198ABinding is Data:
  X198ABinding{+name: String, +fact: U32}
type X198AState is Data:
  X198AState{+valid: Bool, +env: List<&2,X198ABinding>}

@unsafe
def x198o_get(+name: String, env: List<&2,X198ABinding>) -> U32:
  match env:
    case Nil{}: 0
    case Con{X198ABinding{key,fact},rest}: nt_choose(U32,String.eq(name,key),u => fact,u => x198o_get(name,rest))

@unsafe
def x198o_value(value: N111Value, env: List<&2,X198ABinding>) -> U32:
  match value:
    case N111Const{lo,hi}: 1
    case N111Local{name}: x198o_get(name,env)
    case _: 0

@unsafe
def x198o_bin(+typ: N111Type, +op: String, +left: U32, +right: U32) -> U32:
  nt_choose(U32,U32.is_eq(left,1) && U32.is_eq(right,1),u => 1,u =>
    nt_choose(U32,U32.is_eq(p113k_width(typ),32) &&
      ((String.eq(op,"add") && ((U32.is_eq(left,2) && U32.is_eq(right,1)) || (U32.is_eq(left,1) && U32.is_eq(right,2)))) ||
       (String.eq(op,"sub") && U32.is_eq(left,2) && U32.is_eq(right,1))),v => 2,v => 0))

@unsafe
def x198o_initial(params: List<&2,NC_Binding>, +fuel: String, +counter: String) -> List<&2,X198ABinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198ABinding{name,nt_choose(U32,String.eq(name,fuel),u => 0,u => nt_choose(U32,String.eq(name,counter),v => 2,v => 1))},x198o_initial(rest,fuel,counter)}

@unsafe
def x198o_join_rows(rows: List<&2,X198ABinding>, +left: List<&2,X198ABinding>, +right: List<&2,X198ABinding>, +seen: List<&2,String>) -> List<&2,X198ABinding>:
  match rows:
    case Nil{}: []
    case Con{X198ABinding{+name,fact},+rest}:
      +a = x198o_get(name,left)
      b = x198o_get(name,right)
      nt_choose(List<&2,X198ABinding>,nb_contains(seen,name),u => x198o_join_rows(rest,left,right,seen),u =>
        Con{X198ABinding{name,nt_choose(U32,U32.is_eq(a,b),v => a,v => 0)},x198o_join_rows(rest,left,right,Con{name,seen})})

@unsafe
def x198o_join(left: X198AState, right: X198AState) -> X198AState:
  match left right:
    case X198AState{a,+xs} X198AState{b,+ys}: X198AState{a && b,x198o_join_rows(nt_append(X198ABinding,xs,ys),xs,ys,[])}

law x198o_eval:
  for body: List<&2,P113DStmt>
  for +env: List<&2,X198ABinding>
  for +fuel: String
  X198AState

@unsafe
def x198o_continue(body: List<&2,P113DStmt>, fuel: String, +state: X198AState) -> X198AState:
  match state:
    case X198AState{+valid,+env}: nt_choose(X198AState,valid,u => x198o_eval(body,env,fuel),u => state)

@unsafe
def x198o_branch(+condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, +env: List<&2,X198ABinding>, +fuel: String) -> X198AState:
  nt_choose(X198AState,U32.is_eq(x198o_value(condition,env),1),u => x198o_join(x198o_eval(yes,env,fuel),x198o_eval(no,env,fuel)),u => X198AState{False{},[]})

@unsafe
def x198o_eval(body,env,fuel):
  match body:
    case Nil{}: X198AState{True{},env}
    case Con{P113DScalar{N111Set{+name,+typ,+value}},rest}:
      nt_choose(X198AState,x190_branch_width(typ),u => x198o_eval(rest,Con{X198ABinding{name,nt_choose(U32,U32.is_eq(x198o_value(value,env),3) && U32.is_eq(p113k_width(typ),32),v => 0,v => x198o_value(value,env))},env},fuel),u => X198AState{False{},[]})
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+left,+right}},rest}:
      nt_choose(X198AState,x190_branch_width(typ) && x198n_op(op),u =>
        x198o_eval(rest,Con{X198ABinding{name,nt_choose(U32,String.eq(op,"sub") && x185_sf_source(left,fuel) && x192_p_constant(right,1) && U32.is_eq(p113k_width(typ),64),v => 3,v => x198o_bin(typ,op,x198o_value(left,env),x198o_value(right,env)))},env},fuel),u => X198AState{False{},[]})
    case Con{P113DIf{condition,yes,no},rest}: x198o_continue(rest,fuel,x198o_branch(condition,yes,no,env,fuel))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}: x198o_continue(rest,fuel,x198o_branch(condition,x181_scalar_rows(yes),x181_scalar_rows(no),env,fuel))
    case _: X198AState{False{},[]}

@unsafe
def x198o_back(params: List<&2,String>, values: List<&2,N111Value>, +env: List<&2,X198ABinding>, +fuel: String, +counter: String) -> Bool:
  match params values:
    case Nil{} Nil{}: True{}
    case Con{+name,ps} Con{value,vs}:
      U32.is_eq(x198o_value(value,env),nt_choose(U32,String.eq(name,fuel),u => 3,u => nt_choose(U32,String.eq(name,counter),v => 2,v => 1))) && x198o_back(ps,vs,env,fuel,counter)
    case _ _: False{}

@unsafe
def x198o_finished(state: X198AState, params: List<&2,String>, values: List<&2,N111Value>, fuel: String, counter: String) -> Bool:
  match state:
    case X198AState{valid,env}: valid && x198o_back(params,values,env,fuel,counter)

@unsafe
def x198o_argument(params: List<&2,String>, values: List<&2,N111Value>, +wanted: String) -> N111Value:
  match params values:
    case Con{name,ps} Con{+value,vs}: nt_choose(N111Value,String.eq(name,wanted),u => value,u => x198o_argument(ps,vs,wanted))
    case _ _: N111Const{0,0}

@unsafe
def x198o_guards(params: List<&2,String>, values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  match params values:
    case Con{+name,ps} Con{+value,vs}:
      +rest = x198o_guards(ps,vs,fuel,counter)
      nt_choose(List<&2,P113DStmt>,String.eq(name,fuel) || String.eq(name,counter) || x185_sf_source(value,name),u => rest,u =>
        Con{P113DScalar{N111Bin{"p198a_eq",N111U64{},"eq",N111Local{name},value}},Con{P113DScalar{N111Bin{"p198a_same",N111U32{},"and",N111Local{"p198a_same"},N111Local{"p198a_eq"}}},rest}})
    case _ _: []

@unsafe
def x198o_fast(+params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"p198a_delta",N111U32{},"sub",x198o_argument(params,values,counter),N111Local{counter}}},
   P113DScalar{N111Set{"p198a_count",N111U32{},x198o_argument(params,values,fuel)}},
   P113DScalar{N111Bin{"p198a_total",N111U32{},"mul",N111Local{"p198a_count"},N111Local{"p198a_delta"}}},
   P113DScalar{N111Bin{"p198a_result",N111U32{},"add",x198o_argument(params,values,counter),N111Local{"p198a_total"}}},
   P113DResult{[N111Local{"p198a_result"}]}]

@unsafe
def x198o_emit(prefix: List<&2,P113DStmt>, +params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,prefix,Con{P113DScalar{N111Set{"p198a_same",N111U32{},N111Const{1,0}}},
    nt_append(P113DStmt,x198o_guards(params,values,fuel,counter),[P113DIf{N111Local{"p198a_same"},x198o_fast(params,values,fuel,counter),[P113DAgain{values}]}])})

@unsafe
def x198o_loop(split: Maybe<&2,X198NLoop>, +original: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  match split:
    case Some{X198NLoop{+prefix,+values}}:
      +names = x181_param_names(params)
      nt_choose(List<&2,P113DStmt>,x198n_clean(prefix,names) && x198o_finished(x198o_eval(prefix,x198o_initial(params,fuel,counter),fuel),names,values,fuel,counter),u => x198o_emit(prefix,names,values,fuel,counter),u => original)
    case None{}: original

@unsafe
def x198o_unwrap(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String) -> List<&2,P113DStmt>:
  match body:
    case [P113DScalar{N111Bin{+name,N111U64{},+op,+left,+right}},P113DIf{+condition,+yes,no}]:
      nt_choose(List<&2,P113DStmt>,String.eq(op,"ne") && x198n_name(name,x181_param_names(params)) && x185_sf_source(left,fuel) && x192_p_constant(right,0) && x185_sf_source(condition,name),u => yes,u => body)
    case _: body

@unsafe
def x198o_positive(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String, returned: List<&2,N111Value>) -> List<&2,P113DStmt>:
  match returned:
    case [N111Local{+counter}]:
      +core = x198o_unwrap(body,params,fuel)
      nt_choose(List<&2,P113DStmt>,Bool.not(String.eq(counter,fuel)) && nb_contains(x181_param_names(params),counter),u => x198o_loop(x198n_split(core),body,params,fuel,counter),u => body)
    case _: body

@unsafe
def x198o_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(String.starts_with(name,"p198a_")) && x198o_names(rest)
