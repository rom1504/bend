# Reuse the mature checked syntax/layout analysis, with no C-string renderer.
# nq_signature_def already enforces one fixed nondependent shell, <=8 fields,
# <=32 flat argument words, exact constructor identity, and bounded aliases.
@unsafe
def p113p_signature(book: List<&2,KDef>, name: String) -> KDef:
  nq_signature_def(book,name)

@unsafe
def p113p_known(+shape: KTerm) -> Bool:
  String.eq(tg(shape),"NQShape") && U32.is_gt(ix(shape),0) && U32.is_le(ix(shape),8)

@unsafe
def p113p_shapes_valid(shapes: List<&2,KTerm>) -> Bool:
  match shapes:
    case Nil{}: True{}
    case Con{+shape,+rest}: (String.eq(tg(shape),"Absent") || p113p_known(shape)) && p113p_shapes_valid(rest)

@unsafe
def p113p_words(shapes: List<&2,KTerm>, args: List<&2,KTerm>, +env: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match shapes args:
    case Con{+shape,+rest} Con{+arg,+more}:
      nt_append(N111Value,nt_choose(List<&2,N111Value>,p113p_known(shape),
        u => p111_values(ks(arg),env),u => [N111Local{nc_word(ix(arg),env)}]),p113p_words(rest,more,env))
    case _ _: []

@unsafe
def p113p_arguments(+shapes: List<&2,KTerm>, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>) -> P113PArguments:
  nt_choose(P113PArguments,p113p_shapes_valid(shapes) && U32.is_le(nq_shape_words(shapes),32) && nq_args_fit(shapes,args),
    u => P113PArguments{True{},p113p_words(shapes,args,env)},
    u => P113PArguments{False{},[]})

# Both maximum and minimum uses are required: no duplication or conditional
# disappearance of the virtual shell. Dropped/shared/escaping shells use the
# mature ordinary boxed fallback at their original evaluation point.
@unsafe
def p113p_bindable(+body: KTerm, +id: U32) -> Bool:
  U32.is_eq(nq_uses(body,id),1) && U32.is_eq(nq_min_uses(body,id),1)

@unsafe
def p113p_boxed(code: P111ValueCode) -> P113PValueCode:
  match code:
    case P111ValueCode{+body,+value,+error}: P113PValueCode{body,[value],error}

@unsafe
def p113p_transfer(+shape: KTerm, +wanted: KTerm, +values: List<&2,N111Value>) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_shapes_valid([shape,wanted]) && nq_same(shape,wanted) && U32.is_eq(nq_width(shape),nt_count(N111Value,values)),
    u => P113PValueCode{[],values,""},
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"product result shape mismatch"},
      v => nt_choose(P113PValueCode,p113p_known(shape) && U32.is_eq(ix(shape),nt_count(N111Value,values)),
        w => p113p_boxed(p111_constructor(nm(shape),values)),
        w => P113PValueCode{[],[],"opaque product result width mismatch"})))

@unsafe
def p113p_constructor(+name: String, +values: List<&2,N111Value>, +wanted: KTerm) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_known(wanted) && String.eq(nm(wanted),name) && U32.is_eq(ix(wanted),nt_count(N111Value,values)),
    u => P113PValueCode{[],values,""},
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"constructor product shape mismatch"},
      v => p113p_boxed(p111_constructor(name,values))))
