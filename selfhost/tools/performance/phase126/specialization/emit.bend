# Whole-function projection, called only after the unchanged program verifier.
# The table is re-derived from exact decision IR; no external certificate or
# precomputed host data supplies it. Unknown shapes return empty for fallback.
@unsafe
def p126s_cells_cons(bits: U32, rest: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match rest:
    case None{}: None{}
    case Some{values}: Some{Con{bits,values}}

@unsafe
def p126s_cells(+word: String, body: List<&2,P113DStmt>, +index: U32) -> Maybe<&2,List<&2,U32>>:
  match body:
    case [P113DResult{[N111Const{bits,hi}]}]:
      nt_choose(Maybe<&2,List<&2,U32>>,U32.is_eq(hi,0),u => Some{[bits]},u => None{})
    case [P113DScalar{N111Bin{+dest,N111U64{},op,N111Local{arg},N111Const{at,hi}}},
          P113DIf{N111Local{cond},[P113DResult{[N111Const{bits,upper}]}],rest}]:
      nt_choose(Maybe<&2,List<&2,U32>>,String.eq(op,"eq") && String.eq(arg,word) && String.eq(cond,dest) &&
        Bool.not(String.eq(dest,word)) && U32.is_eq(at,index) && U32.is_eq(hi,0) && U32.is_eq(upper,0) && U32.is_lt(index,63),
        u => p126s_cells_cons(bits,p126s_cells(word,rest,U32.inc(index))),u => None{})
    case _: None{}

@unsafe
def p126s_data(values: List<&2,U32>) -> List<&2,P111QDatum>:
  match values:
    case Nil{}: []
    case Con{bits,rest}: Con{P111QLong{bits,0},p126s_data(rest)}

@unsafe
def p126s_render(+name: String, +word: String, +values: List<&2,U32>) -> String:
  +table = "p126s_table_" ++ nt_fid(name)
  +last = U32.show(U32.sub(nt_count(U32,values),1))
  "function l $" ++ p113e_symbol(name) ++ "(l %state, l " ++ p111q_local(word) ++ ") {\n@entry\n" ++
  "%p126s_inside =w cultl " ++ p111q_local(word) ++ ", " ++ last ++ "\n" ++
  "jnz %p126s_inside, @p126s_input, @p126s_default\n@p126s_input\n" ++
  "%p126s_index =l copy " ++ p111q_local(word) ++ "\njmp @p126s_load\n@p126s_default\n" ++
  "%p126s_index =l copy " ++ last ++ "\njmp @p126s_load\n@p126s_load\n" ++
  "%p126s_bytes =l shl %p126s_index, 3\n%p126s_addr =l add $" ++ table ++ ", %p126s_bytes\n" ++
  "%p126s_result =l loadl %p126s_addr\nret %p126s_result\n}\n" ++
  p111q_data(P111QData{table,8,False{},p126s_data(values)})

@unsafe
def p126s_emit_cells(+name: String, +word: String, cells: Maybe<&2,List<&2,U32>>) -> String:
  match cells:
    case None{}: ""
    case Some{+values}:
      nt_choose(String,U32.is_ge(nt_count(U32,values),4),u => p126s_render(name,word,values),u => "")

@unsafe
def p126s_emit(function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(String,U32.is_eq(result,1),u => p126s_emit_cells(name,word,p126s_cells(word,body,0)),u => "")
    case _: ""

@unsafe
def p126s_has_cells(cells: Maybe<&2,List<&2,U32>>) -> Bool:
  match cells:
    case Some{values}: U32.is_ge(nt_count(U32,values),4)
    case _: False{}

@unsafe
def p126s_is_table(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      U32.is_eq(result,1) && p126s_has_cells(p126s_cells(word,body,0))
    case _: False{}
