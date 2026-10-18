# Exact additive declaration replacements; historical sources are untouched.

type NxoOp is Data:
  NxoKeep{+word: String}
  NxoSink{+word: String}
  NxoBuild{+dest: String, +cid: U32, +fields: List<&2, String>}
  NxoTake{+word: String, +fields: List<&2, String>}
  NxoBranch{+word: String, +cid: U32, +yes: List<&2, NxoOp>, +no: List<&2, NxoOp>}
  NxoReturn{+word: String}
  NxoTail{+words: List<&2, String>}
  NxoCall{+dest: String, +symbol: String, +words: List<&2,String>}
  NxoFail{+code: U32}

@unsafe
def nxo_v_ops(+ops: List<&2,NxoOp>, +state: List<&2,NxoOwned>, +arity: U32) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{op,rest}:
      match op:
        case NxoKeep{word}: nxo_v_keep(word,rest,state,arity)
        case NxoSink{word}: nxo_v_continue(rest,nxo_v_spend(word,state),arity)
        case NxoBuild{dest,cid,fields}: nxo_v_continue(rest,nxo_v_build(dest,cid,fields,state),arity)
        case NxoTake{word,fields}: nxo_v_continue(rest,nxo_v_take(word,fields,state),arity)
        case NxoBranch{word,cid,yes,no}:
          nxo_v_terminal(rest) && U32.is_gt(nxo_v_count(nxo_v_get(word,state)),0) && U32.is_lt(cid,4) &&
          nxo_v_ops(yes,nxo_v_put(word,nxo_v_count(nxo_v_get(word,state)),cid,state),arity) && nxo_v_ops(no,state,arity)
        case NxoReturn{word}: nxo_v_terminal(rest) && nxo_v_done(nxo_v_spend(word,state))
        case NxoTail{words}: nxo_v_terminal(rest) && U32.is_eq(nxo_size(String,words),arity) && nxo_v_done(nxo_v_spend_words(words,state))
        case NxoCall{dest,symbol,words}: nxo_v_continue(rest,nxo_v_fresh_after(dest,4,nxo_v_spend_words(words,state)),arity)
        case NxoFail{code}: nxo_v_terminal(rest)

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
    case NxoCall{dest,symbol,words}: [NxSet{dest,NxCall{symbol,Con{NxVar{"ctx"},nxo_exprs(words)}}}]
    case NxoFail{code}: [NxSet{"failed",NxCall{"rt_fail",[NxVar{"ctx"},NxConst{NxU32{},code}]}},NxReturn{NxVar{"failed"}}]

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
    case NxoCall{dest,symbol,words}: [NxSet{dest,NxCall{symbol,Con{NxVar{"ctx"},nxo_exprs(words)}}}]
    case NxoFail{code}: [NxSet{"failed",NxCall{"rt_fail",[NxVar{"ctx"},NxConst{NxU32{},code}]}},NxReturn{NxVar{"failed"}}]
