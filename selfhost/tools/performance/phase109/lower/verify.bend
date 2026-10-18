# Path-local ownership credits, separate from Nx structural/type checking.
# A Keep adds one credit to its returned handle; every consumer spends one.
# Constructor tags are refined only by a tested branch or a verified Build.
# This is finite IR validation, not a proof of runtime implementation safety.
type NxoOwned is Data:
  NxoOwned{+word: String, +count: U32, +tag: U32}

@unsafe
def nxo_v_get(+word: String, +state: List<&2,NxoOwned>) -> NxoOwned:
  match state:
    case Nil{}: NxoOwned{word,0,4}
    case Con{NxoOwned{name,count,tag},rest}:
      nx_choose(NxoOwned,String.eq(word,name),u => NxoOwned{name,count,tag},u => nxo_v_get(word,rest))

@unsafe
def nxo_v_put(+word: String, +count: U32, +tag: U32, +state: List<&2,NxoOwned>) -> List<&2,NxoOwned>:
  match state:
    case Nil{}: [NxoOwned{word,count,tag}]
    case Con{NxoOwned{name,old,known},rest}:
      nx_choose(List<&2,NxoOwned>,String.eq(word,name),u => Con{NxoOwned{word,count,tag},rest},u => Con{NxoOwned{name,old,known},nxo_v_put(word,count,tag,rest)})

def nxo_v_count(item: NxoOwned) -> U32:
  match item:
    case NxoOwned{word,count,tag}: count

def nxo_v_tag(item: NxoOwned) -> U32:
  match item:
    case NxoOwned{word,count,tag}: tag

@unsafe
def nxo_v_empty(+state: List<&2,NxoOwned>) -> Bool:
  match state:
    case Nil{}: True{}
    case Con{NxoOwned{word,count,tag},rest}: U32.is_eq(count,0) && nxo_v_empty(rest)

@unsafe
def nxo_v_spend(+word: String, +state: List<&2,NxoOwned>) -> Maybe<&2,List<&2,NxoOwned>>:
  +count = nxo_v_count(nxo_v_get(word,state))
  nx_choose(Maybe<&2,List<&2,NxoOwned>>,U32.is_gt(count,0),u => Some{nxo_v_put(word,U32.sub(count,1),nxo_v_tag(nxo_v_get(word,state)),state)},u => None{})

@unsafe
def nxo_v_spend_words(+words: List<&2,String>, +state: List<&2,NxoOwned>) -> Maybe<&2,List<&2,NxoOwned>>:
  match words:
    case Nil{}: Some{state}
    case Con{word,rest}: nxo_v_spend_rest(rest,nxo_v_spend(word,state))

@unsafe
def nxo_v_spend_rest(+words: List<&2,String>, +state: Maybe<&2,List<&2,NxoOwned>>) -> Maybe<&2,List<&2,NxoOwned>>:
  match state:
    case None{}: None{}
    case Some{owned}: nxo_v_spend_words(words,owned)

@unsafe
def nxo_v_fresh(+word: String, +tag: U32, +state: List<&2,NxoOwned>) -> Maybe<&2,List<&2,NxoOwned>>:
  nx_choose(Maybe<&2,List<&2,NxoOwned>>,nx_ident(word) && U32.is_eq(nxo_v_count(nxo_v_get(word,state)),0),u => Some{nxo_v_put(word,1,tag,state)},u => None{})

@unsafe
def nxo_v_fresh_after(+word: String, +tag: U32, +state: Maybe<&2,List<&2,NxoOwned>>) -> Maybe<&2,List<&2,NxoOwned>>:
  match state:
    case None{}: None{}
    case Some{owned}: nxo_v_fresh(word,tag,owned)

@unsafe
def nxo_v_fields(+fields: List<&2,String>, +state: Maybe<&2,List<&2,NxoOwned>>) -> Maybe<&2,List<&2,NxoOwned>>:
  match fields:
    case Nil{}: state
    case Con{word,rest}: nxo_v_fields(rest,nxo_v_fresh_after(word,4,state))

def nxo_v_shape(+tag: U32, +fields: U32) -> Bool:
  ((U32.is_eq(tag,0) || U32.is_eq(tag,2)) && U32.is_eq(fields,0)) ||
  ((U32.is_eq(tag,1) || U32.is_eq(tag,3)) && U32.is_eq(fields,2))

@unsafe
def nxo_v_take(+word: String, +fields: List<&2,String>, +state: List<&2,NxoOwned>) -> Maybe<&2,List<&2,NxoOwned>>:
  nx_choose(Maybe<&2,List<&2,NxoOwned>>,nxo_v_shape(nxo_v_tag(nxo_v_get(word,state)),nxo_size(String,fields)),
    u => nxo_v_fields(fields,nxo_v_spend(word,state)),u => None{})

@unsafe
def nxo_v_build(+word: String, +cid: U32, +fields: List<&2,String>, +state: List<&2,NxoOwned>) -> Maybe<&2,List<&2,NxoOwned>>:
  nx_choose(Maybe<&2,List<&2,NxoOwned>>,nxo_v_shape(cid,nxo_size(String,fields)),
    u => nxo_v_fresh_after(word,cid,nxo_v_spend_words(fields,state)),u => None{})

@unsafe
def nxo_v_continue(+ops: List<&2,NxoOp>, +state: Maybe<&2,List<&2,NxoOwned>>, +arity: U32) -> Bool:
  match state:
    case None{}: False{}
    case Some{owned}: nxo_v_ops(ops,owned,arity)

def nxo_v_terminal(ops: List<&2,NxoOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case _: False{}

@unsafe
def nxo_v_done(+state: Maybe<&2,List<&2,NxoOwned>>) -> Bool:
  match state:
    case None{}: False{}
    case Some{owned}: nxo_v_empty(owned)

@unsafe
def nxo_v_keep(+word: String, +ops: List<&2,NxoOp>, +state: List<&2,NxoOwned>, +arity: U32) -> Bool:
  +count = nxo_v_count(nxo_v_get(word,state))
  U32.is_gt(count,0) && U32.is_lt(count,4294967295) &&
    nxo_v_ops(ops,nxo_v_put(word,U32.inc(count),nxo_v_tag(nxo_v_get(word,state)),state),arity)

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
        case NxoFail{code}: nxo_v_terminal(rest)

@unsafe
def nxo_v_params(+i: U32, +arity: U32) -> List<&2,NxoOwned>:
  nx_choose(List<&2,NxoOwned>,U32.is_eq(i,arity),u => [],u => Con{NxoOwned{"p" ++ U32.show(i),1,4},nxo_v_params(U32.inc(i),arity)})

@unsafe
def nxo_verify(+ops: List<&2,NxoOp>, +arity: U32) -> Bool:
  U32.is_gt(arity,0) && U32.is_lt(arity,9) && nxo_v_ops(ops,nxo_v_params(0,arity),arity)
