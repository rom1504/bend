# Optional structured pure gap; total nodes across all branches remain <=32.
@unsafe
def p112g_split(+body: List<&2,N111Stmt>, +count: U32, +acc: List<&2,N111Stmt>) -> Maybe<&2,P112PureGap>:
  nt_choose(Maybe<&2,P112PureGap>,U32.is_le(count,32),u => p112h_split(body,count,acc),u => None{})
