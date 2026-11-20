# Experimental nonzero-mode certificate. This module is not in the live manifest.
# Canonical aliases are admitted only from N_W32 parameter metadata; no arbitrary
# ABI word is silently identified with its low half.
type X198NFact is Data:
  X198NUnknown{}
  X198NConst{+lo: U32, +hi: U32}
  X198NAlias{+name: String, +narrow: Bool}
  X198NNonzero{+narrow: Bool}
  X198NPredecessor{}

type X198NBinding is Data:
  X198NBinding{+name: String, +fact: X198NFact}

type X198NState is Data:
  X198NState{+valid: Bool, +env: List<&2,X198NBinding>}

@unsafe
def x198n_equal(left: X198NFact, right: X198NFact) -> Bool:
  match left right:
    case X198NUnknown{} X198NUnknown{}: True{}
    case X198NConst{a,b} X198NConst{c,d}: U32.is_eq(a,c) && U32.is_eq(b,d)
    case X198NAlias{a,b} X198NAlias{c,d}: String.eq(a,c) && Bool.not(Bool.xor(b,d))
    case X198NNonzero{a} X198NNonzero{b}: Bool.not(Bool.xor(a,b))
    case X198NPredecessor{} X198NPredecessor{}: True{}
    case _ _: False{}

@unsafe
def x198n_get(+name: String, env: List<&2,X198NBinding>) -> X198NFact:
  match env:
    case Nil{}: X198NUnknown{}
    case Con{X198NBinding{key,+fact},rest}: nt_choose(X198NFact,String.eq(name,key),u => fact,u => x198n_get(name,rest))

@unsafe
def x198n_value(value: N111Value, env: List<&2,X198NBinding>) -> X198NFact:
  match value:
    case N111Const{lo,hi}: X198NConst{lo,hi}
    case N111Local{name}: x198n_get(name,env)
    case _: X198NUnknown{}

@unsafe
def x198n_zero(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: U32.is_eq(lo,0) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def x198n_one(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: U32.is_eq(lo,1) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def x198n_nonzero(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: Bool.not(U32.is_eq(lo,0) && U32.is_eq(hi,0))
    case X198NNonzero{narrow}: True{}
    case _: False{}

@unsafe
def x198n_low_nonzero(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: Bool.not(U32.is_eq(lo,0))
    case X198NNonzero{narrow}: narrow
    case _: False{}

@unsafe
def x198n_width(+value: X198NFact, typ: N111Type) -> X198NFact:
  match value typ:
    case X198NConst{lo,hi} N111U32{}: X198NConst{lo,0}
    case X198NAlias{name,narrow} N111U32{}: nt_choose(X198NFact,narrow,u => value,u => X198NUnknown{})
    case X198NNonzero{narrow} N111U32{}: nt_choose(X198NFact,narrow,u => value,u => X198NUnknown{})
    case X198NPredecessor{} N111U32{}: X198NUnknown{}
    case _ _: value

@unsafe
def x198n_constant(answer: P113KFact) -> X198NFact:
  match answer:
    case P113KFact{bits,exact,lo,hi}: nt_choose(X198NFact,exact,u => X198NConst{lo,hi},u => X198NUnknown{})

@unsafe
def x198n_exact_bin(typ: N111Type, op: String, left: X198NFact, right: X198NFact) -> X198NFact:
  match left right:
    case X198NConst{a,b} X198NConst{c,d}: x198n_constant(p113k_bin_fact(typ,op,p113k_exact(a,b),p113k_exact(c,d)))
    case _ _: X198NUnknown{}

# Only trap-free integer operations may be discarded by this certificate.
def x198n_op(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") || String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"shl") || String.eq(op,"shr") || String.eq(op,"sar") || String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"ult") || String.eq(op,"ule") || String.eq(op,"ugt") || String.eq(op,"uge")

@unsafe
def x198n_bin(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact) -> X198NFact:
  nt_choose(X198NFact,String.eq(op,"or") && (x198n_nonzero(left) || x198n_nonzero(right)),u =>
    nt_choose(X198NFact,x198n_equal(left,right),v => x198n_width(left,typ),v => X198NNonzero{x198n_low_nonzero(left) || x198n_low_nonzero(right)}),u =>
  nt_choose(X198NFact,(String.eq(op,"eq") || String.eq(op,"ne")) &&
    ((x198n_zero(left) && x198n_nonzero(right)) || (x198n_zero(right) && x198n_nonzero(left))),u =>
      X198NConst{nt_choose(U32,String.eq(op,"ne"),v => 1,v => 0),0},u =>
  nt_choose(X198NFact,x198n_zero(right) && (String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"shl") || String.eq(op,"shr") || String.eq(op,"sar")),u => x198n_width(left,typ),u =>
  nt_choose(X198NFact,x198n_zero(left) && (String.eq(op,"add") || String.eq(op,"or") || String.eq(op,"xor")),u => x198n_width(right,typ),u =>
  nt_choose(X198NFact,String.eq(op,"mul") && (x198n_zero(left) || x198n_zero(right)),u => X198NConst{0,0},u =>
  nt_choose(X198NFact,String.eq(op,"mul") && x198n_one(right),u => x198n_width(left,typ),u =>
  nt_choose(X198NFact,String.eq(op,"mul") && x198n_one(left),u => x198n_width(right,typ),u =>
    x198n_exact_bin(typ,op,left,right))))))))

@unsafe
def x198n_join_rows(rows: List<&2,X198NBinding>, +left: List<&2,X198NBinding>, +right: List<&2,X198NBinding>, +seen: List<&2,String>) -> List<&2,X198NBinding>:
  match rows:
    case Nil{}: []
    case Con{X198NBinding{+name,fact},+rest}:
      +a = x198n_get(name,left)
      +b = x198n_get(name,right)
      nt_choose(List<&2,X198NBinding>,nb_contains(seen,name),u => x198n_join_rows(rest,left,right,seen),u =>
        Con{X198NBinding{name,nt_choose(X198NFact,x198n_equal(a,b),v => a,v => X198NUnknown{})},x198n_join_rows(rest,left,right,Con{name,seen})})

@unsafe
def x198n_join(left: X198NState, right: X198NState) -> X198NState:
  match left right:
    case X198NState{a,+xs} X198NState{b,+ys}:
      X198NState{a && b,x198n_join_rows(nt_append(X198NBinding,xs,ys),xs,ys,[])}

law x198n_eval:
  for body: List<&2,P113DStmt>
  for +env: List<&2,X198NBinding>
  for +fuel: String
  X198NState

@unsafe
def x198n_continue(body: List<&2,P113DStmt>, fuel: String, +state: X198NState) -> X198NState:
  match state:
    case X198NState{+valid,+env}: nt_choose(X198NState,valid,u => x198n_eval(body,env,fuel),u => state)

@unsafe
def x198n_choose(+condition: X198NFact, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +env: List<&2,X198NBinding>, +fuel: String) -> X198NState:
  nt_choose(X198NState,x198n_zero(condition),u => x198n_eval(no,env,fuel),u =>
    nt_choose(X198NState,x198n_nonzero(condition),v => x198n_eval(yes,env,fuel),v =>
      x198n_join(x198n_eval(yes,env,fuel),x198n_eval(no,env,fuel))))

@unsafe
def x198n_eval(body,env,fuel):
  match body:
    case Nil{}: X198NState{True{},env}
    case Con{P113DScalar{N111Set{+name,+typ,+value}},rest}:
      nt_choose(X198NState,x190_branch_width(typ),u =>
        x198n_eval(rest,Con{X198NBinding{name,x198n_width(x198n_value(value,env),typ)},env},fuel),u => X198NState{False{},[]})
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+left,+right}},rest}:
      nt_choose(X198NState,x190_branch_width(typ) && x198n_op(op),u =>
        x198n_eval(rest,Con{X198NBinding{name,nt_choose(X198NFact,String.eq(op,"sub") && x185_sf_source(left,fuel) && x192_p_constant(right,1) && U32.is_eq(p113k_width(typ),64),v => X198NPredecessor{},v => x198n_bin(typ,op,x198n_width(x198n_value(left,env),typ),x198n_width(x198n_value(right,env),typ)))},env},fuel),u => X198NState{False{},[]})
    case Con{P113DIf{condition,yes,no},rest}:
      x198n_continue(rest,fuel,x198n_choose(x198n_value(condition,env),yes,no,env,fuel))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x198n_continue(rest,fuel,x198n_choose(x198n_value(condition,env),x181_scalar_rows(yes),x181_scalar_rows(no),env,fuel))
    case _: X198NState{False{},[]}

type X198NLoop is Data:
  X198NLoop{+prefix: List<&2,P113DStmt>, +values: List<&2,N111Value>}

def x198n_enabled() -> Bool: True{}

def x198n_name(+name: String, +params: List<&2,String>) -> Bool:
  Bool.not(nb_contains(params,name) || String.starts_with(name,"p198n_") || String.starts_with(name,"p198a_"))

law x198n_clean:
  for body: List<&2,P113DStmt>
  for +params: List<&2,String>
  Bool

@unsafe
def x198n_clean(body,params):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Set{name,typ,value}},rest}: x198n_name(name,params) && x190_branch_width(typ) && x198n_clean(rest,params)
    case Con{P113DScalar{N111Bin{name,typ,op,left,right}},rest}: x198n_name(name,params) && x190_branch_width(typ) && x198n_op(op) && x198n_clean(rest,params)
    case Con{P113DIf{condition,yes,no},rest}: x198n_clean(yes,params) && x198n_clean(no,params) && x198n_clean(rest,params)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}: x198n_clean(x181_scalar_rows(yes),params) && x198n_clean(x181_scalar_rows(no),params) && x198n_clean(rest,params)
    case _: False{}

@unsafe
def x198n_split_add(stmt: P113DStmt, suffix: Maybe<&2,X198NLoop>) -> Maybe<&2,X198NLoop>:
  match suffix:
    case Some{X198NLoop{prefix,values}}: Some{X198NLoop{Con{stmt,prefix},values}}
    case None{}: None{}

@unsafe
def x198n_split(body: List<&2,P113DStmt>) -> Maybe<&2,X198NLoop>:
  match body:
    case [P113DAgain{values}]: Some{X198NLoop{[],values}}
    case Con{head,rest}: x198n_split_add(head,x198n_split(rest))
    case Nil{}: None{}

# These kinds come from the verified direct worker, before conversion to names.
def x198n_fuel_kind(kind: N_WordKind) -> Bool:
  match kind:
    case N_Imm64{}: True{}
    case N_W64{}: True{}
    case _: False{}

def x198n_word_kind(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}

@unsafe
def x198n_types(params: List<&2,NC_Binding>, +fuel: String) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,+name,+kind},rest}:
      nt_choose(Bool,String.eq(name,fuel),u => x198n_fuel_kind(kind),u => x198n_word_kind(kind)) && x198n_types(rest,fuel)

@unsafe
def x198n_initial(params: List<&2,NC_Binding>, +fuel: String, +mode: String) -> List<&2,X198NBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198NBinding{name,nt_choose(X198NFact,String.eq(name,fuel),u => X198NNonzero{False{}},u =>
        nt_choose(X198NFact,String.eq(name,mode),v => X198NNonzero{True{}},v => X198NAlias{name,True{}}))},x198n_initial(rest,fuel,mode)}

@unsafe
def x198n_return(values: List<&2,N111Value>, +params: List<&2,String>, +fuel: String, +mode: String) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{N111Const{lo,hi},rest}: x198n_return(rest,params,fuel,mode)
    case Con{N111Local{+name},rest}: nb_contains(params,name) && Bool.not(String.eq(name,fuel) || String.eq(name,mode)) && x198n_return(rest,params,fuel,mode)
    case _: False{}

@unsafe
def x198n_identity(fact: X198NFact, name: String) -> Bool:
  match fact:
    case X198NAlias{other,narrow}: narrow && String.eq(other,name)
    case _: False{}

@unsafe
def x198n_pred(fact: X198NFact) -> Bool:
  match fact:
    case X198NPredecessor{}: True{}
    case _: False{}

@unsafe
def x198n_back(params: List<&2,String>, values: List<&2,N111Value>, +env: List<&2,X198NBinding>, +fuel: String, +mode: String) -> Bool:
  match params values:
    case Nil{} Nil{}: True{}
    case Con{+name,ps} Con{value,vs}:
      +fact = x198n_value(value,env)
      nt_choose(Bool,String.eq(name,fuel),u => x198n_pred(fact),u =>
        nt_choose(Bool,String.eq(name,mode),v => x198n_low_nonzero(fact),v => x198n_identity(fact,name))) && x198n_back(ps,vs,env,fuel,mode)
    case _ _: False{}

@unsafe
def x198n_finished(state: X198NState, params: List<&2,String>, values: List<&2,N111Value>, fuel: String, mode: String) -> Bool:
  match state:
    case X198NState{valid,env}: valid && x198n_back(params,values,env,fuel,mode)

@unsafe
def x198n_modes(choices: List<&2,String>, +params: List<&2,NC_Binding>, +fuel: String, +returned: List<&2,N111Value>, +prefix: List<&2,P113DStmt>, +values: List<&2,N111Value>) -> Maybe<&2,String>:
  match choices:
    case Nil{}: None{}
    case Con{+mode,rest}:
      +names = x181_param_names(params)
      nt_choose(Maybe<&2,String>,Bool.not(String.eq(mode,fuel)) && x198n_return(returned,names,fuel,mode) &&
        x198n_finished(x198n_eval(prefix,x198n_initial(params,fuel,mode),fuel),names,values,fuel,mode),u => Some{mode},u => x198n_modes(rest,params,fuel,returned,prefix,values))

@unsafe
def x198n_loop(split: Maybe<&2,X198NLoop>, +params: List<&2,NC_Binding>, +fuel: String, returned: List<&2,N111Value>) -> Maybe<&2,String>:
  match split:
    case Some{X198NLoop{+prefix,values}}:
      nt_choose(Maybe<&2,String>,x198n_clean(prefix,x181_param_names(params)),u =>
        x198n_modes(x181_param_names(params),params,fuel,returned,prefix,values),u => None{})
    case None{}: None{}

# The original positive-fuel branch may contain a redundant verified Nat guard.
# Its failure arm is unreachable under the outer U64 positive-fuel condition.
@unsafe
def x198n_positive(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String, returned: List<&2,N111Value>) -> Maybe<&2,String>:
  match body:
    case [P113DScalar{N111Bin{+name,N111U64{},+op,+left,+right}},P113DIf{+condition,yes,no}]:
      nt_choose(Maybe<&2,String>,String.eq(op,"ne") && x198n_name(name,x181_param_names(params)) && x185_sf_source(left,fuel) && x192_p_constant(right,0) && x185_sf_source(condition,name),u =>
        x198n_loop(x198n_split(yes),params,fuel,returned),u => None{})
    case _: x198n_loop(x198n_split(body),params,fuel,returned)

@unsafe
def x198n_selected(choice: Maybe<&2,String>, +original: List<&2,P113DStmt>, +test: P113DStmt, condition: N111Value, +returned: List<&2,N111Value>, positive: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match choice:
    case Some{mode}: [test,P113DIf{condition,[P113DResult{returned}],[P113DScalar{N111Bin{"p198n_nonzero_exit",N111U32{},"ne",N111Local{mode},N111Const{0,0}}},P113DIf{N111Local{"p198n_nonzero_exit"},[P113DResult{returned}],positive}]}]
    case None{}: original

@unsafe
def x198n_body(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>) -> List<&2,P113DStmt>:
  match body:
    case [P113DScalar{N111Bin{+name,N111U64{},+op,N111Local{+fuel},+zero}},P113DIf{+condition,[P113DResult{+returned}],+positive}]:
      +names = x181_param_names(params)
      nt_choose(List<&2,P113DStmt>,x198n_enabled() && x198n_name(name,names) && String.eq(op,"eq") && x185_sf_source(condition,name) && x192_p_constant(zero,0) && nb_contains(names,fuel) && p113e_distinct(names) && U32.is_le(nt_count(String,names),8) && U32.is_le(p113i_size(body),256) && x198n_types(params,fuel) && Bool.not(nb_contains(names,"p198n_nonzero_exit")) && x198o_names(names),u =>
        x198n_composed(x198n_positive(positive,params,fuel,returned),P113DScalar{N111Bin{name,N111U64{},op,N111Local{fuel},zero}},condition,returned,x198o_positive(positive,params,fuel,returned)),u => body)
    case _: body

@unsafe
def x198n_composed(choice: Maybe<&2,String>, +test: P113DStmt, +condition: N111Value, +returned: List<&2,N111Value>, +positive: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x198n_selected(choice,[test,P113DIf{condition,[P113DResult{returned}],positive}],test,condition,returned,positive)
