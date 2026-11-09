# ABI11102 Char is a full-word identity, not a Unicode-range conversion.
# The unchanged native verifier establishes the import signature and accessible
# buffer. Exact kind/count operands retain all other special constructors and
# malformed calls on the original route. No ownership operation is removed.
#
# A take writes its input before assigning the status destination; a constructor
# loads before assigning its destination. Consequently destination/input/buffer
# aliases preserve the original call's read-before-return ordering without a
# fresh temporary. The buffer's eight bytes retain every input bit.

@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111U64{},+word},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_take") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")),
          u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_ctor") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p186ch_emitted(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(P111QCode,changed,u => p114t_words(body,ids,code),u => p186rt_stmt(stmt,ids,code))

@unsafe
def p186ch_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p186ch_emitted(stmt,ids,code,p186ch_expand(stmt)),u => p186rt_stmt(stmt,ids,code))
