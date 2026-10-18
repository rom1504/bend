# Owning source words may use only the exact p*/v* slots allocated by the
# source lowering. Private runtime, tail-move, tag and status temporaries are
# never legal ownership words, even if their machine type happens to be U64.
# This module follows the additive NxoCall declaration extension.
@unsafe
def nx110rtn_names(+prefix: String, +index: U32, +count: U32) -> List<&2,String>:
  nx_choose(List<&2,String>,U32.is_eq(index,count),u => [],u =>
    Con{prefix ++ U32.show(index),nx110rtn_names(prefix,U32.inc(index),count)})

@unsafe
def nx110rtn_words(+words: List<&2,String>, +allowed: List<&2,String>) -> Bool:
  match words:
    case Nil{}: True{}
    case Con{word,rest}: nxlib_has_name(word,allowed) && nx110rtn_words(rest,allowed)

@unsafe
def nx110rtn_op(+op: NxoOp, +allowed: List<&2,String>) -> Bool:
  match op:
    case NxoKeep{word}: nxlib_has_name(word,allowed)
    case NxoSink{word}: nxlib_has_name(word,allowed)
    case NxoBuild{dest,cid,fields}: nxlib_has_name(dest,allowed) && nx110rtn_words(fields,allowed)
    case NxoTake{word,fields}: nxlib_has_name(word,allowed) && nx110rtn_words(fields,allowed)
    case NxoBranch{word,cid,yes,no}: nxlib_has_name(word,allowed) && nx110rtn_ops(yes,allowed) && nx110rtn_ops(no,allowed)
    case NxoReturn{word}: nxlib_has_name(word,allowed)
    case NxoTail{words}: nx110rtn_words(words,allowed)
    case NxoCall{dest,symbol,words}: nxlib_has_name(dest,allowed) && nx110rtn_words(words,allowed)
    case NxoFail{code}: True{}

@unsafe
def nx110rtn_ops(+ops: List<&2,NxoOp>, +allowed: List<&2,String>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{head,rest}: nx110rtn_op(head,allowed) && nx110rtn_ops(rest,allowed)

@unsafe
def nx110rtn_check(+ops: List<&2,NxoOp>, +arity: U32, +next: U32) -> Bool:
  nx110rtn_ops(ops,nxo_join(String,nx110rtn_names("p",0,arity),nx110rtn_names("v",0,next)))
