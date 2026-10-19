# The original verified frontend and fixed runtime capability gate remain.
@unsafe
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p112s_emit_lowered(p112s_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})

@unsafe
def p111_live(book,t,env,n):
  nt_choose(P111Code,String.eq(tg(t),"NStatic"),u => p111_value_return(p112s_value(book,t),n),
    u => p112s_live_fallback(book,t,env,n))

@unsafe
def p111_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +n: U32) -> P111Code:
  nt_choose(P111Code,String.eq(tg(value),"NStatic"),u => p111_bind_value(book,value,body,env,id,n,p112s_value(book,value)),
    u => p112s_let_fallback(book,value,body,env,id,n))
