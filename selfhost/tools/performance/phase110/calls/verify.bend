# Ownership and signature checks are independent. NxoCall's credit rule lives
# in the exact replacement of nxo_v_ops; this pass checks closed callee binding.
@unsafe
def nxc_call_ok(+found: Maybe<&2,NxcCallee>, +words: List<&2,String>) -> Bool:
  match found:
    case None{}: False{}
    case Some{NxcCallee{source,symbol,arity}}: U32.is_eq(arity,nxo_size(String,words))

@unsafe
def nxc_ops_ok(+ops: List<&2,NxoOp>, +callees: List<&2,NxcCallee>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{head,rest}:
      nxc_op_ok(head,callees) && nxc_ops_ok(rest,callees)

@unsafe
def nxc_op_ok(+op: NxoOp, +callees: List<&2,NxcCallee>) -> Bool:
  match op:
    case NxoCall{dest,symbol,words}: nxc_call_ok(nxc_find(symbol,callees,True{}),words)
    case NxoBranch{word,cid,yes,no}: nxc_ops_ok(yes,callees) && nxc_ops_ok(no,callees)
    case _: True{}

@unsafe
def nxc_sources_ok(+sources: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>) -> Bool:
  match sources:
    case Nil{}: True{}
    case Con{NxcSource{fact,symbol},rest}:
      +callees = nxc_catalogue(rest)
      nxo_admit(fact,ctors) && Bool.not(String.eq(dn(fact),"")) && nx_ident(symbol) &&
      nxc_missing(nxc_find(dn(fact),callees,False{})) && nxc_missing(nxc_find(symbol,callees,True{})) && nxc_sources_ok(rest,ctors)

@unsafe
def nxc_verify(+ops: List<&2,NxoOp>, +arity: U32, +callees: List<&2,NxcCallee>) -> Bool:
  nxo_verify(ops,arity) && nxc_ops_ok(ops,callees)
