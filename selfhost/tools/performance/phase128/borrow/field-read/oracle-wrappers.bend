# ABI-isolation fixture only: external C supplies a valid allocated scratch
# pointer. These wrappers are never production IR or a verifier exemption.
@unsafe
def p128bf_oracle_function(+name: String, +arity: U32, +count: U32) -> String:
  +ids = N111Ids{missing(),p111q_constructor_ids([N_Constructor{"oracle",arity,False{}}],0,missing())}
  +call = N111Call{"status",N111U64{},"p118_rt_borrow_fields",
    [p111_state(),p111_word(N111Local{"word"}),p111_scratch(),
      N111Arg{N111U32{},N111CtorId{"oracle"}},p111_u32(count)]}
  "export function l $" ++ name ++ "(l %state, l %v_word, l %v_scratch) {\n@entry\n" ++
    p111q_body_text(p111q_stmts([call,N111Return{N111Local{"status"}}],ids,P111QCode{[],0,False{},""})) ++ "}\n"

@unsafe
def p128bf_oracle_widths(+width: U32) -> String:
  nt_choose(String,U32.is_gt(width,8),u => "",u =>
    p128bf_oracle_function("p128bf_width_" ++ U32.show(width),width,width) ++ p128bf_oracle_widths(U32.inc(width)))

@unsafe
def p128bf_oracle_module() -> String:
  p128bf_oracle_widths(0) ++ p128bf_oracle_function("p128bf_mismatched_count",2,3)
