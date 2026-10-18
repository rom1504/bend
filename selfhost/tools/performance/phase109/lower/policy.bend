# Optional checked policies. The original ownership graph is retained and must
# pass nxo_verify before any trusted ABI call or fused emission is constructed.
# No source function name participates in these transformations.
@unsafe
def nxo_p_name(+name: String) -> String:
  "rt_fast_" ++ name

@unsafe
def nxo_p_fields(+fields: List<&2,String>, +i: U32) -> List<&2,NxStmt>:
  match fields:
    case Nil{}: []
    case Con{h,t}: Con{NxSet{h,NxCall{nxo_p_name("field"),[NxVar{"ctx"},NxConst{NxU32{},i}]}},nxo_p_fields(t,U32.inc(i))}

@unsafe
def nxo_p_op(+op: NxoOp, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  match op:
    case NxoKeep{word}: [NxSet{word,NxCall{nxo_p_name("keep"),[NxVar{"ctx"},NxVar{word}]}}]
    case NxoSink{word}: [NxSet{"status",NxCall{nxo_p_name("sink"),[NxVar{"ctx"},NxVar{word}]}}]
    case NxoBuild{dest,cid,fields}: [NxSet{dest,NxCall{nxo_p_name(nx_choose(String,U32.is_eq(nxo_size(String,fields),0),u => "zero",u => "build2")),Con{NxVar{"ctx"},Con{NxConst{NxU32{},cid},nxo_exprs(fields)}}}}]
    case NxoTake{word,fields}: nx_choose(List<&2,NxStmt>,U32.is_eq(nxo_size(String,fields),0),u => [],u => Con{NxSet{"status",NxCall{nxo_p_name("take2"),[NxVar{"ctx"},NxVar{word}]}},nxo_p_fields(fields,0)})
    case NxoBranch{word,cid,yes,no}:
      nxo_join(NxStmt,nx_choose(List<&2,NxStmt>,String.eq(word,tag_word),u => [],u => [NxSet{"tag",NxCall{nxo_p_name("id"),[NxVar{"ctx"},NxVar{word}]}}]),
        [NxIf{NxBin{"eq",NxVar{"tag"},NxConst{NxU32{},cid}},nxo_p_ops(yes,policy,word),nxo_p_ops(no,policy,word)}])
    case NxoReturn{word}: [NxReturn{NxVar{word}}]
    case NxoTail{words}: nxo_join(NxStmt,nxo_nx_moves(words,0,True{}),nxo_nx_moves(words,0,False{}))
    case NxoFail{code}: [NxSet{"failed",NxCall{"rt_fail",[NxVar{"ctx"},NxConst{NxU32{},code}]}},NxReturn{NxVar{"failed"}}]

@unsafe
def nxo_p_tail_pair(+words: List<&2,String>, +remaining: String, +dest: String) -> Bool:
  match words:
    case Con{a,Con{b,Nil{}}}: (String.eq(a,remaining) && String.eq(b,dest)) || (String.eq(a,dest) && String.eq(b,remaining))
    case _: False{}

@unsafe
def nxo_p_fusion_shape(+parent: String, +a: String, +b: String, +dest: String, +cid: U32, +keep: String, +other: String, +tail: List<&2,String>) -> Bool:
  (U32.is_eq(cid,1) || U32.is_eq(cid,3)) &&
  Bool.not(String.eq(a,b) || String.eq(parent,a) || String.eq(parent,b)) &&
  (String.eq(keep,a) || String.eq(keep,b)) &&
  Bool.not(String.eq(other,parent) || String.eq(other,a) || String.eq(other,b)) &&
  Bool.not(String.eq(dest,parent) || String.eq(dest,a) || String.eq(dest,b) || String.eq(dest,other)) &&
  nxo_p_tail_pair(tail,nx_choose(String,String.eq(keep,a),u => b,u => a),dest)

@unsafe
def nxo_p_fused(+parent: String, +a: String, +b: String, +dest: String, +cid: U32, +keep: String, +other: String, +tail: List<&2,String>) -> List<&2,NxStmt>:
  +remaining = nx_choose(String,String.eq(keep,a),u => b,u => a)
  +index = nx_choose(U32,String.eq(keep,a),u => 0,u => 1)
  nxo_join(NxStmt,
    [NxSet{dest,NxCall{"rt_rebuild2",[NxVar{"ctx"},NxVar{parent},NxConst{NxU32{},cid},NxConst{NxU32{},index},NxVar{other}]}},
     NxSet{remaining,NxCall{nxo_p_name("field"),[NxVar{"ctx"},NxConst{NxU32{},0}]}}],
    nxo_join(NxStmt,nxo_nx_moves(tail,0,True{}),nxo_nx_moves(tail,0,False{})))

@unsafe
def nxo_p_try_fusion(+ops: List<&2,NxoOp>) -> Maybe<&2,List<&2,NxStmt>>:
  match ops:
    case Con{NxoTake{parent,Con{a,Con{b,Nil{}}}},Con{NxoBuild{dest,cid,Con{keep,Con{other,Nil{}}}},Con{NxoTail{tail},Nil{}}}}:
      nx_choose(Maybe<&2,List<&2,NxStmt>>,nxo_p_fusion_shape(parent,a,b,dest,cid,keep,other,tail),u => Some{nxo_p_fused(parent,a,b,dest,cid,keep,other,tail)},u => None{})
    case _: None{}

@unsafe
def nxo_p_fallback(+ops: List<&2,NxoOp>, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  match ops:
    case Nil{}: []
    case Con{h,t}:
      # Any intervening operation invalidates the cached tag. A branch is
      # terminal in verified ownership IR, so only its direct fallback reuses it.
      nxo_join(NxStmt,nxo_p_op(h,policy,tag_word),nxo_p_ops(t,policy,""))

@unsafe
def nxo_p_select(+fusion: Maybe<&2,List<&2,NxStmt>>, +ops: List<&2,NxoOp>, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  match fusion:
    case Some{body}: body
    case None{}: nxo_p_fallback(ops,policy,tag_word)

@unsafe
def nxo_p_ops(+ops: List<&2,NxoOp>, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  nx_choose(List<&2,NxStmt>,String.eq(policy,"fused"),u => nxo_p_select(nxo_p_try_fusion(ops),ops,policy,tag_word),u => nxo_p_fallback(ops,policy,tag_word))

@unsafe
def nxo_policy_function(+name: String, +arity: U32, +next: U32, +body: List<&2,NxoOp>, +policy: String) -> NxFunction:
  NxFunction{name,Con{NxParam{"ctx",NxPtr{}},nxo_params("p",0,arity)},NxU64{},
    nxo_join(NxParam,nxo_params("v",0,next),nxo_join(NxParam,nxo_params("next",0,arity),[NxParam{"status",NxU32{}},NxParam{"tag",NxU32{}},NxParam{"failed",NxU64{}}])),
    [NxWhile{NxConst{NxU32{},1},nx_choose(List<&2,NxStmt>,String.eq(policy,"raw"),u => nxo_nx_ops(body),u => nxo_p_ops(body,policy,""))},NxReturn{NxConst{NxU64{},0}}]}

def nxo_refused(+name: String, +body: List<&2,NxoOp>, +error: String) -> NxoResult:
  NxoResult{NxFunction{name,[],NxU64{},[],[]},body,error}

@unsafe
def nxo_policy_checked(+name: String, +body: List<&2,NxoOp>, +function: NxFunction, +policy: String) -> NxoResult:
  NxoResult{function,body,nx_choose(String,nxlib_verify(NxLibrary{nxlib_runtime_imports_policy(policy),[function],[name]}),u => "",u => "opaque runtime IR verifier refused")}

@unsafe
def nxo_finish_policy(+name: String, +arity: U32, +code: NxoCode, +policy: String) -> NxoResult:
  match code:
    case NxoCode{body,next,error}:
      nx_choose(NxoResult,Bool.not(String.eq(error,"")),u => nxo_refused(name,body,error),u =>
      nx_choose(NxoResult,Bool.not(nxlib_runtime_policy_valid(policy)),u => nxo_refused(name,body,"unknown owned lowering policy"),u =>
      nx_choose(NxoResult,nxo_verify(body,arity),u => nxo_policy_checked(name,body,nxo_policy_function(name,arity,next,body,policy),policy),u => nxo_refused(name,body,"owned-Term verifier refused"))))

@unsafe
def nxo_lower_policy(+fact: KDef, +ctors: List<&2,NxoCtor>, +symbol: String, +policy: String) -> NxoResult:
  nx_choose(NxoResult,nxo_admit(fact,ctors),u =>
    nxo_finish_policy(symbol,da(fact),nxo_apply(dv(fact),nxo_param_words(0,da(fact)),[],nxo_param_words(0,da(fact)),ctors,dn(fact),da(fact),0),policy),u =>
      nxo_refused(symbol,[],"requires well-shaped checked NativeErasedBody, one to eight live parameters and the fixed runtime catalogue"))
