# Additive checked policies over Phase109's unchanged semantic ownership IR.
# TermABI v2 admits only this fixed borrowed identity extraction. Ownership
# remains in NxoOp until checked admission and nxo_verify both succeed.
def nxlib_runtime110_policy_valid(+policy: String) -> Bool:
  String.eq(policy,"tagged") || String.eq(policy,"specialized")

def nxo110_rebuild_name(+cid: U32, +index: U32) -> String:
  "rt_rebuild2_c" ++ U32.show(cid) ++ "_k" ++ U32.show(index)

def nxlib_runtime110_rebuild(+cid: U32, +index: U32) -> NxImport:
  NxImport{nxo110_rebuild_name(cid,index),[NxParam{"ctx",NxPtr{}},NxParam{"parent",NxU64{}},NxParam{"other",NxU64{}}],NxU64{}}

def nxlib_runtime110_imports_policy(+policy: String) -> List<&2,NxImport>:
  nx_choose(List<&2,NxImport>,String.eq(policy,"tagged"),u => nxlib_runtime_imports_policy("fused"),u =>
  nx_choose(List<&2,NxImport>,String.eq(policy,"specialized"),u =>
    nxo_join(NxImport,[nxlib_runtime110_rebuild(1,0),nxlib_runtime110_rebuild(1,1),nxlib_runtime110_rebuild(3,0),nxlib_runtime110_rebuild(3,1)],nxlib_runtime_named("rt_fast_")),u => []))

# materialize.py authenticates the exact production term_aux accessor and
# records these two constants. This is a pure borrowed observation; it cannot
# expose the context or produce a memory address from a Term.
def nxo110_tag(+word: String) -> NxExpr:
  NxBin{"and",NxBin{"lshr",NxVar{word},NxConst{NxU64{},40}},NxConst{NxU64{},65535}}

@unsafe
def nxo110_op(+op: NxoOp, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  match op:
    case NxoBranch{word,cid,yes,no}:
      nxo_join(NxStmt,nx_choose(List<&2,NxStmt>,String.eq(word,tag_word),u => [],u => [NxSet{"tag110",nxo110_tag(word)}]),
        [NxIf{NxBin{"eq",NxVar{"tag110"},NxConst{NxU64{},cid}},nxo110_ops(yes,policy,word),nxo110_ops(no,policy,word)}])
    case _: nxo_p_op(op,"trusted",tag_word)

@unsafe
def nxo110_fused(+parent: String, +a: String, +b: String, +dest: String, +cid: U32, +keep: String, +other: String, +tail: List<&2,String>, +policy: String) -> List<&2,NxStmt>:
  nxo110_fused_selected(parent,dest,cid,other,tail,policy,nxo_law_select(String,String.eq(keep,a),a,b))

@unsafe
def nxo110_fused_selected(+parent: String, +dest: String, +cid: U32, +other: String, +tail: List<&2,String>, +policy: String, +selection: NxoLawSelection<String>) -> List<&2,NxStmt>:
  match selection:
    case NxoLawSelection{index,retained,remaining}:
      nxo_join(NxStmt,
        [NxSet{dest,nx_choose(NxExpr,String.eq(policy,"specialized"),u => NxCall{nxo110_rebuild_name(cid,index),[NxVar{"ctx"},NxVar{parent},NxVar{other}]},u => NxCall{"rt_rebuild2",[NxVar{"ctx"},NxVar{parent},NxConst{NxU32{},cid},NxConst{NxU32{},index},NxVar{other}]})},
         NxSet{remaining,NxCall{"rt_fast_field",[NxVar{"ctx"},NxConst{NxU32{},0}]}}],
        nxo_join(NxStmt,nxo_nx_moves(tail,0,True{}),nxo_nx_moves(tail,0,False{})))

@unsafe
def nxo110_try_fusion(+ops: List<&2,NxoOp>, +policy: String) -> Maybe<&2,List<&2,NxStmt>>:
  match ops:
    case Con{NxoTake{parent,Con{a,Con{b,Nil{}}}},Con{NxoBuild{dest,cid,Con{keep,Con{other,Nil{}}}},Con{NxoTail{tail},Nil{}}}}:
      nx_choose(Maybe<&2,List<&2,NxStmt>>,nxo_p_fusion_shape(parent,a,b,dest,cid,keep,other,tail),u => Some{nxo110_fused(parent,a,b,dest,cid,keep,other,tail,policy)},u => None{})
    case _: None{}

@unsafe
def nxo110_fallback(+ops: List<&2,NxoOp>, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  match ops:
    case Nil{}: []
    case Con{h,t}: nxo_join(NxStmt,nxo110_op(h,policy,tag_word),nxo110_ops(t,policy,""))

@unsafe
def nxo110_select(+fusion: Maybe<&2,List<&2,NxStmt>>, +ops: List<&2,NxoOp>, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  match fusion:
    case Some{body}: body
    case None{}: nxo110_fallback(ops,policy,tag_word)

@unsafe
def nxo110_ops(+ops: List<&2,NxoOp>, +policy: String, +tag_word: String) -> List<&2,NxStmt>:
  nxo110_select(nxo110_try_fusion(ops,policy),ops,policy,tag_word)

@unsafe
def nxo110_function(+name: String, +arity: U32, +next: U32, +body: List<&2,NxoOp>, +policy: String) -> NxFunction:
  NxFunction{name,Con{NxParam{"ctx",NxPtr{}},nxo_params("p",0,arity)},NxU64{},
    nxo_join(NxParam,nxo_params("v",0,next),nxo_join(NxParam,nxo_params("next",0,arity),[NxParam{"status",NxU32{}},NxParam{"tag110",NxU64{}},NxParam{"failed",NxU64{}}])),
    [NxWhile{NxConst{NxU32{},1},nxo110_ops(body,policy,"")},NxReturn{NxConst{NxU64{},0}}]}

@unsafe
def nxo110_checked(+name: String, +body: List<&2,NxoOp>, +function: NxFunction, +policy: String) -> NxoResult:
  NxoResult{function,body,nx_choose(String,nxlib_verify(NxLibrary{nxlib_runtime110_imports_policy(policy),[function],[name]}),u => "",u => "opaque runtime v2 IR verifier refused")}

@unsafe
def nxo110_finish(+name: String, +arity: U32, +code: NxoCode, +policy: String) -> NxoResult:
  match code:
    case NxoCode{body,next,error}:
      nx_choose(NxoResult,Bool.not(String.eq(error,"")),u => nxo_refused(name,body,error),u =>
      nx_choose(NxoResult,Bool.not(nxlib_runtime110_policy_valid(policy)),u => nxo_refused(name,body,"unknown v2 owned lowering policy"),u =>
      nx_choose(NxoResult,nxo_verify(body,arity),u => nxo110_checked(name,body,nxo110_function(name,arity,next,body,policy),policy),u => nxo_refused(name,body,"owned-Term verifier refused"))))

@unsafe
def nxo_lower110_policy(+fact: KDef, +ctors: List<&2,NxoCtor>, +symbol: String, +policy: String) -> NxoResult:
  nx_choose(NxoResult,nxo_admit(fact,ctors),u =>
    nxo110_finish(symbol,da(fact),nxo_apply(dv(fact),nxo_param_words(0,da(fact)),[],nxo_param_words(0,da(fact)),ctors,dn(fact),da(fact),0),policy),u =>
      nxo_refused(symbol,[],"requires well-shaped checked NativeErasedBody, one to eight live parameters and the fixed runtime catalogue"))
