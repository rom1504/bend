# The runtime ABI is the only lowering of semantic ownership operations here.
# No arithmetic, pointer loads or unrestricted optimization is allowed on Terms.
@unsafe
def nxo_exprs(+words: List<&2,String>) -> List<&2,NxExpr>:
  match words:
    case Nil{}: []
    case Con{h,t}: Con{NxVar{h},nxo_exprs(t)}

@unsafe
def nxo_nx_build(+dest: String, +cid: U32, +fields: List<&2,String>) -> NxStmt:
  NxSet{dest,NxCall{nx_choose(String,U32.is_eq(nxo_size(String,fields),0),u => "rt_zero",u => "rt_build2"),Con{NxVar{"ctx"},Con{NxConst{NxU32{},cid},nxo_exprs(fields)}}}}

@unsafe
def nxo_nx_fields(+fields: List<&2,String>, +i: U32) -> List<&2,NxStmt>:
  match fields:
    case Nil{}: []
    case Con{h,t}: Con{NxSet{h,NxCall{"rt_field",[NxVar{"ctx"},NxConst{NxU32{},i}]}},nxo_nx_fields(t,U32.inc(i))}

@unsafe
def nxo_nx_moves(+words: List<&2,String>, +i: U32, +save: Bool) -> List<&2,NxStmt>:
  match words:
    case Nil{}: []
    case Con{h,t}:
      Con{nx_choose(NxStmt,save,u => NxSet{"next" ++ U32.show(i),NxVar{h}},u => NxSet{"p" ++ U32.show(i),NxVar{"next" ++ U32.show(i)}}),nxo_nx_moves(t,U32.inc(i),save)}

@unsafe
def nxo_nx_ops(+ops: List<&2,NxoOp>) -> List<&2,NxStmt>:
  match ops:
    case Nil{}: []
    case Con{h,t}: nxo_join(NxStmt,nxo_nx_op(h),nxo_nx_ops(t))

@unsafe
def nxo_nx_op(+op: NxoOp) -> List<&2,NxStmt>:
  match op:
    case NxoKeep{word}: [NxSet{word,NxCall{"rt_keep",[NxVar{"ctx"},NxVar{word}]}}]
    case NxoSink{word}: [NxSet{"status",NxCall{"rt_sink",[NxVar{"ctx"},NxVar{word}]}}]
    case NxoBuild{dest,cid,fields}: [nxo_nx_build(dest,cid,fields)]
    case NxoTake{word,fields}: nx_choose(List<&2,NxStmt>,U32.is_eq(nxo_size(String,fields),0),u => [],u => Con{NxSet{"status",NxCall{"rt_take2",[NxVar{"ctx"},NxVar{word}]}},nxo_nx_fields(fields,0)})
    case NxoBranch{word,cid,yes,no}: [NxSet{"tag",NxCall{"rt_id",[NxVar{"ctx"},NxVar{word}]}},NxIf{NxBin{"eq",NxVar{"tag"},NxConst{NxU32{},cid}},nxo_nx_ops(yes),nxo_nx_ops(no)}]
    case NxoReturn{word}: [NxReturn{NxVar{word}}]
    case NxoTail{words}: nxo_join(NxStmt,nxo_nx_moves(words,0,True{}),nxo_nx_moves(words,0,False{}))
    case NxoFail{code}: [NxSet{"failed",NxCall{"rt_fail",[NxVar{"ctx"},NxConst{NxU32{},code}]}},NxReturn{NxVar{"failed"}}]

@unsafe
def nxo_params(+prefix: String, +i: U32, +count: U32) -> List<&2,NxParam>:
  nx_choose(List<&2,NxParam>,U32.is_eq(i,count),u => [],u => Con{NxParam{prefix ++ U32.show(i),NxU64{}},nxo_params(prefix,U32.inc(i),count)})

@unsafe
def nxo_symbol_chars(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{h,t}: "_" ++ U32.show(Char.to_u32(h)) ++ nxo_symbol_chars(t)

def nxo_symbol(+name: String) -> String:
  "owned" ++ nxo_symbol_chars(name)

@unsafe
def nxo_finish(+name: String, +arity: U32, +code: NxoCode) -> NxoResult:
  nxo_finish_policy(name,arity,code,"raw")

# Raw remains the default. Alternate policies preserve the original verified
# semantic graph and are selected explicitly by the experimental harness.
@unsafe
def nxo_lower(+fact: KDef, +ctors: List<&2,NxoCtor>, +symbol: String) -> NxoResult:
  nxo_lower_policy(fact,ctors,symbol,"raw")
