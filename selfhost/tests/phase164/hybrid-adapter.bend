# Actual adapters and source-bound obligations. No generic body is fabricated.
type P164HLowering is Data:
  P164HLowering{+lowered: P113DLowering, +raw: List<&2,P113DCandidate>, +adapters: KDef, +omitted: U32}

type P164HBook is Data:
  P164HBook{+compiled: P111Book, +adapters: KDef, +omitted: U32}

@unsafe
def p164a_put(+index: KDef, source: String, +owner: String, arity: U32) -> KDef:
  p113e_insert(index,KDef{owner,"P164Adapter",arity,0,ref(source),atom("Absent"),[],False{},False{}})

def p164a_arg(index: U32) -> String:
  "p164_arg_" ++ U32.show(index)

@unsafe
def p164a_loads(+arity: U32, +at: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(at,arity),u => [],u =>
    Con{N111Call{p164a_arg(at),N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(at)]},
      p164a_loads(arity,U32.inc(at))})

@unsafe
def p164a_args(+arity: U32, +at: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(at,arity),u => [],u =>
    Con{p111_word(N111Local{p164a_arg(at)}),p164a_args(arity,U32.inc(at))})

@unsafe
def p164a_body(owner: String, +arity: U32) -> List<&2,N111Stmt>:
  Con{N111Alloca{"p164_adapter_out",8,8},
    nt_append(N111Stmt,p164a_loads(arity,0),[
      N111Call{"p164_value",N111U64{},p113e_symbol(owner),Con{p111_state(),p164a_args(arity,0)}},
      N111Store{N111U64{},N111Local{"p164_adapter_out"},0,N111Local{"p164_value"}},
      N111Call{"p164_reply",N111U64{},"p111_rt_return",[
        p111_state(),N111Arg{N111Ptr{},N111Local{"p164_adapter_out"}},p111_u32(1)]},
      N111Return{N111Local{"p164_reply"}}])}

@unsafe
def p164a_segment(+owner: String, +arity: U32) -> N111Segment:
  N111Segment{owner,arity,1,0,0,p164a_body(owner,arity)}

# Discovery is not authorization. Candidate dependency admission supplies only
# proposed signatures. Mixed original and all actual direct bodies are checked
# against the retained actual headers before optimization or emission.
@unsafe
def p164a_ready(functions: List<&2,P113DFunction>, ready: KDef) -> KDef:
  p113e_signatures(functions,ready)

@unsafe
def p164a_allowed(+book: List<&2,KDef>, +source: String, +bangs: List<&2,String>, +ready: KDef) -> Bool:
  +definition = lookup(book,source)
  +arity = nd_arity(book,source)
  +signature = p111v_get(ready,p113d_public(book,source))
  String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,source)) &&
    U32.is_le(arity,32) && String.eq(dk(signature),"P113Direct") &&
    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),1)

# Exact fixed-shape recognizer for later emission ONLY. Admission uses the
# explicit source-bound map plus independent source/header/direct checks.
@unsafe
def p164a_shape(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{+owner,+arity,result,incoming,flags,body}:
      U32.is_le(arity,32) && U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        p134v_list(~N111Stmt,~p134v_scalar,body,p164a_body(owner,arity))

@unsafe
def p164a_generic(segments: List<&2,N111Segment>, +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segments:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+head,rest}:
      p164a_generic(rest,nt_choose(List<&2,N111Segment>,p164a_shape(head),u => acc,u => Con{head,acc}))
