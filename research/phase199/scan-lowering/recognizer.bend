# Semantic tokens describe only the certified modular recurrence. Zero means
# unknown/refusal. Names are arbitrary; metadata names come from the guarded
# p117 factory, never from matching a user function's spelling.
@unsafe
def x199s_put(env: KDef, name: String, token: U32) -> KDef:
  p111v_put(env,name,"X199Scan",token,0)

@unsafe
def x199s_token(value: N111Value, env: KDef) -> U32:
  match value:
    case N111Local{name}: da(p111v_get(env,name))
    case N111Const{+lo,hi}:
      nt_choose(U32,U32.is_eq(hi,0),u =>
        nt_choose(U32,U32.is_eq(lo,0),v => 7,v =>
          nt_choose(U32,U32.is_eq(lo,1),w => 8,w =>
            nt_choose(U32,U32.is_eq(lo,4),z => 9,z => 0))),u => 0)
    case _: 0

def x199s_pair(+a: U32, +b: U32, +x: U32, +y: U32) -> Bool:
  (U32.is_eq(a,x) && U32.is_eq(b,y)) || (U32.is_eq(a,y) && U32.is_eq(b,x))

def x199s_narrow(+token: U32) -> U32:
  nt_choose(U32,U32.is_eq(token,2),u => 11,u =>
    nt_choose(U32,U32.is_eq(token,4),v => 17,v =>
      nt_choose(U32,U32.is_eq(token,7) || U32.is_eq(token,8) || U32.is_eq(token,9) ||
        U32.is_eq(token,11) || U32.is_eq(token,12) || U32.is_eq(token,13) ||
        U32.is_eq(token,16) || U32.is_eq(token,17) || U32.is_eq(token,18) || U32.is_eq(token,19),w => token,w => 0)))

def x199s_bin(typ: N111Type, +op: String, +a: U32, +b: U32) -> U32:
  match typ:
    case N111U32{}:
      nt_choose(U32,String.eq(op,"add") && x199s_pair(x199s_narrow(a),x199s_narrow(b),11,8),u => 12,u =>
        nt_choose(U32,String.eq(op,"add") && x199s_pair(x199s_narrow(a),x199s_narrow(b),17,16),v => 18,v =>
          nt_choose(U32,String.eq(op,"xor") && x199s_pair(x199s_narrow(a),x199s_narrow(b),18,11),w => 19,w => 0)))
    case N111U64{}:
      nt_choose(U32,String.eq(op,"sub") && U32.is_eq(a,1) && U32.is_eq(b,8),u => 10,u =>
        nt_choose(U32,String.eq(op,"and") && (x199s_pair(a,b,2,6) || x199s_pair(a,b,11,6)),v => 13,v =>
          nt_choose(U32,String.eq(op,"mul") && x199s_pair(a,b,13,9),w => 14,w =>
            nt_choose(U32,String.eq(op,"xor") && x199s_pair(a,b,18,11),z => 19,z => 0))))
    case _: 0

@unsafe
def x199s_free(+name: String, params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || nb_contains(params,name) ||
    String.eq(name,p117h_name(3,"base")) || String.eq(name,p117h_name(3,"mask")))

@unsafe
def x199s_seed(fuel: String, index: String, array: String, carry: String) -> KDef:
  x199s_put(x199s_put(x199s_put(x199s_put(x199s_put(x199s_put(missing(),
    fuel,1),index,2),array,3),carry,4),p117h_name(3,"base"),5),p117h_name(3,"mask"),6)

type X199ScanState is Data:
  X199ScanState{+env: KDef, +loads: U32, +stores: U32}

@unsafe
def x199s_bound(+name: String, +token: U32, params: List<&2,String>, state: X199ScanState) -> Maybe<&2,X199ScanState>:
  match state:
    case X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_gt(token,0) && x199s_free(name,params),
        u => Some{X199ScanState{x199s_put(env,name,token),loads,stores}},u => None{})

@unsafe
def x199s_scalar(stmt: N111Stmt, params: List<&2,String>, +state: X199ScanState) -> Maybe<&2,X199ScanState>:
  match stmt state:
    case N111Set{name,N111U64{},value} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_token(value,env),params,state)
    case N111Set{name,N111U32{},value} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_narrow(x199s_token(value,env)),params,state)
    case N111Bin{name,typ,op,left,right} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_bin(typ,op,x199s_token(left,env),x199s_token(right,env)),params,state)
    case N111Offset{name,base,bytes} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),5) && U32.is_eq(x199s_token(bytes,env),14),
        u => x199s_bound(name,15,params,state),u => None{})
    case N111Load{name,N111U32{},base,offset} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),15) && U32.is_eq(offset,0) &&
          U32.is_eq(loads,0) && U32.is_eq(stores,0),
        u => x199s_bound(name,16,params,X199ScanState{env,1,0}),u => None{})
    case N111Store{N111U32{},base,offset,value} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),15) && U32.is_eq(offset,0) &&
          U32.is_eq(x199s_token(value,env),19) && U32.is_eq(loads,1) && U32.is_eq(stores,0),
        u => Some{X199ScanState{env,1,1}},u => None{})
    case _ _: None{}

@unsafe
def x199s_again(values: List<&2,N111Value>, state: X199ScanState) -> Bool:
  match values state:
    case Con{a,Con{b,Con{c,Con{d,Nil{}}}}} X199ScanState{+env,+loads,+stores}:
      U32.is_eq(loads,1) && U32.is_eq(stores,1) && U32.is_eq(x199s_token(a,env),10) &&
        U32.is_eq(x199s_token(b,env),12) && U32.is_eq(x199s_token(c,env),3) && U32.is_eq(x199s_token(d,env),18)
    case _ _: False{}

@unsafe
def x199s_walk(body: List<&2,P113DStmt>, +params: List<&2,String>, state: Maybe<&2,X199ScanState>, +budget: U32) -> Bool:
  match body state:
    case Con{P113DAgain{values},Nil{}} Some{current}: x199s_again(values,current)
    case Con{P113DScalar{stmt},rest} Some{current}:
      U32.is_gt(budget,0) && x199s_walk(rest,params,x199s_scalar(stmt,params,current),U32.sub(budget,1))
    case _ _: False{}

@unsafe
def x199s_result(body: List<&2,P113DStmt>, array: String, carry: String) -> Bool:
  match body:
    case Con{P113DResult{Con{a,Con{c,Nil{}}}},Nil{}}: x185_sf_source(a,array) && x185_sf_source(c,carry)
    case _: False{}

@unsafe
def x199s_call(fuel: String, index: String, array: String, +carry: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{carry,N111U64{},"p199_rt_u32_scan4",[
    N111Arg{N111Ptr{},p117h_ref(3,"base")},N111Arg{N111U64{},p117h_ref(3,"mask")},
    N111Arg{N111U64{},N111Local{fuel}},N111Arg{N111U64{},N111Local{index}},N111Arg{N111U64{},N111Local{carry}}]}},
    P113DResult{[N111Local{array},N111Local{carry}]}]

@unsafe
def x199s_positive(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String,
    +index: String, +array: String, +carry: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+condition,+yes,+no},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,String.eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(condition,test) && x199s_free(test,params) &&
          x199s_walk(yes,params,Some{X199ScanState{x199s_seed(fuel,index,array,carry),0,0}},64),
        u => [P113DScalar{N111Bin{test,N111U64{},op,left,right}},
          P113DIf{condition,x199s_call(fuel,index,array,carry),no}],u => body)
    case _: body

@unsafe
def x199s_select(+params: List<&2,String>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match params body:
    case Con{state,Con{out,Con{+fuel,Con{+index,Con{+array,Con{+carry,Nil{}}}}}}}
        Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+condition,+yes,no},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,String.eq(state,"state") && String.eq(out,"__x181_result_out") &&
          p113e_distinct(params) && String.eq(op,"eq") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(condition,test) && x199s_free(test,params) && x199s_result(yes,array,carry),
        u => [P113DScalar{N111Bin{test,N111U64{},op,left,right}},
          P113DIf{condition,yes,x199s_positive(no,params,fuel,index,array,carry)}],u => body)
    case _ _: body
