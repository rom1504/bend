# Backend intrinsic over the unchanged verified owning call. Metadata checks
# retain the exact runtime fallback; this is not a new public memory operation.
type P114PKTake is Data:
  P114PKTake{+destination: String, +word: N111Value, +output: String}

@unsafe
def p114pk_case_buffer(+name: String, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,8),u => False{},u =>
    nt_choose(Bool,String.eq(name,"p114h_case_" ++ U32.show(index) ++ "_local_scratch"),
      v => True{},v => p114pk_case_buffer(name,U32.inc(index))))

@unsafe
def p114pk_buffer(+name: String) -> Bool:
  p114t_buffer(name) || p114pk_case_buffer(name,0)

@unsafe
def p114pk_shape(stmt: N111Stmt) -> Maybe<&2,P114PKTake>:
  match stmt:
    case N111Call{destination,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U64{},word},
      Con{N111Arg{N111Ptr{},N111Local{+output}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(Maybe<&2,P114PKTake>,String.eq(symbol,"p111_rt_take") && String.eq(state,"state") && p114pk_buffer(output),
          u => Some{P114PKTake{destination,word,output}},u => None{})
    case _: None{}

@unsafe
def p114pk_local(site: U32, role: String) -> String:
  "%p114pk_" ++ U32.show(site) ++ "_" ++ role

@unsafe
def p114pk_label(site: U32, role: String) -> String:
  "@p114pk_" ++ U32.show(site) ++ "_" ++ role

@unsafe
def p114pk_ready(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      String.is_empty(error) && Bool.not(terminal) && U32.is_lt(next,4294967280)
