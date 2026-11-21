# A conservative straight-line certificate that some state field cannot be fixed.
# Unknown control flow returns no proof. A proven refusal adds no runtime checks.
type X198OProgress is Data:
  X198OProgress{+fact: X198NFact, +different: String}
type X198OProgressBinding is Data:
  X198OProgressBinding{+name: String, +value: X198OProgress}
type X198OProgressState is Data:
  X198OProgressState{+valid: Bool, +env: List<&2,X198OProgressBinding>}

@unsafe
def x198o_progress_get(+name: String, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match env:
    case Nil{}: X198OProgress{X198NUnknown{},""}
    case Con{X198OProgressBinding{key,+value},rest}: nt_choose(X198OProgress,String.eq(name,key),u => value,u => x198o_progress_get(name,rest))

@unsafe
def x198o_progress_value(value: N111Value, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match value:
    case N111Const{lo,hi}: X198OProgress{X198NConst{lo,hi},""}
    case N111Local{name}: x198o_progress_get(name,env)
    case _: X198OProgress{X198NUnknown{},""}

@unsafe
def x198o_progress_initial(params: List<&2,NC_Binding>, +fuel: String) -> List<&2,X198OProgressBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198OProgressBinding{name,X198OProgress{nt_choose(X198NFact,String.eq(name,fuel),u => X198NUnknown{},u => X198NAlias{name,True{}}),""}},x198o_progress_initial(rest,fuel)}

@unsafe
def x198o_progress_alias(value: X198NFact) -> String:
  match value:
    case X198NAlias{+name,narrow}: nt_choose(String,narrow,u => name,u => "")
    case _: ""

@unsafe
def x198o_progress_copy(value: X198OProgress, +typ: N111Type) -> X198OProgress:
  match value:
    case X198OProgress{fact,different}: X198OProgress{x198n_width(fact,typ),different}

@unsafe
def x198o_progress_diff(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact) -> String:
  nt_choose(String,U32.is_eq(p113k_width(typ),32),u =>
    nt_choose(String,(String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"xor")) && x198n_low_nonzero(right),v => x198o_progress_alias(left),v =>
      nt_choose(String,(String.eq(op,"add") || String.eq(op,"xor")) && x198n_low_nonzero(left),w => x198o_progress_alias(right),w => "")),u => "")

@unsafe
def x198o_progress_bin(+typ: N111Type, +op: String, left: X198OProgress, right: X198OProgress) -> X198OProgress:
  match left right:
    case X198OProgress{+a,ad} X198OProgress{+b,bd}:
      +x = x198n_width(a,typ)
      +y = x198n_width(b,typ)
      X198OProgress{x198n_bin(typ,op,x,y),x198o_progress_diff(typ,op,x,y)}

@unsafe
def x198o_progress_eval(body: List<&2,P113DStmt>, +env: List<&2,X198OProgressBinding>) -> X198OProgressState:
  match body:
    case Nil{}: X198OProgressState{True{},env}
    case Con{P113DScalar{N111Set{+name,+typ,+value}},rest}:
      nt_choose(X198OProgressState,x190_branch_width(typ),u => x198o_progress_eval(rest,Con{X198OProgressBinding{name,x198o_progress_copy(x198o_progress_value(value,env),typ)},env}),u => X198OProgressState{False{},[]})
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+left,+right}},rest}:
      nt_choose(X198OProgressState,x190_branch_width(typ) && x198n_op(op),u => x198o_progress_eval(rest,Con{X198OProgressBinding{name,x198o_progress_bin(typ,op,x198o_progress_value(left,env),x198o_progress_value(right,env))},env}),u => X198OProgressState{False{},[]})
    case _: X198OProgressState{False{},[]}

@unsafe
def x198o_progress_is(value: X198OProgress, name: String) -> Bool:
  match value:
    case X198OProgress{fact,+different}: Bool.not(String.is_empty(different)) && String.eq(different,name)

@unsafe
def x198o_progress_back(params: List<&2,String>, values: List<&2,N111Value>, +env: List<&2,X198OProgressBinding>, +fuel: String, +counter: String) -> Bool:
  match params values:
    case Con{+name,ps} Con{value,vs}:
      (Bool.not(String.eq(name,fuel) || String.eq(name,counter)) && x198o_progress_is(x198o_progress_value(value,env),name)) || x198o_progress_back(ps,vs,env,fuel,counter)
    case _ _: False{}

@unsafe
def x198o_progress_finished(state: X198OProgressState, params: List<&2,String>, values: List<&2,N111Value>, fuel: String, counter: String) -> Bool:
  match state:
    case X198OProgressState{valid,env}: valid && x198o_progress_back(params,values,env,fuel,counter)

@unsafe
def x198o_no_fixed(+prefix: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, values: List<&2,N111Value>, +fuel: String, counter: String) -> Bool:
  x198o_progress_finished(x198o_progress_eval(prefix,x198o_progress_initial(params,fuel)),x181_param_names(params),values,fuel,counter)
