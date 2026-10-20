type P113BQDiamond is Data:
  P113BQNo{}
  P113BQYes{+name: String, +invert: Bool}

@unsafe
def p113bq_scalar(yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>) -> P113BQDiamond:
  match yes no:
    case Con{N111Set{+a,N111U64{},N111Const{1,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{0,0}},Nil{}}:
      nt_choose(P113BQDiamond,String.eq(a,b),u => P113BQYes{a,False{}},u => P113BQNo{})
    case Con{N111Set{+a,N111U64{},N111Const{0,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{1,0}},Nil{}}:
      nt_choose(P113BQDiamond,String.eq(a,b),u => P113BQYes{a,True{}},u => P113BQNo{})
    case _ _: P113BQNo{}

@unsafe
def p113bq_direct(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>) -> P113BQDiamond:
  match yes no:
    case Con{P113DScalar{a},Nil{}} Con{P113DScalar{b},Nil{}}: p113bq_scalar([a],[b])
    case _ _: P113BQNo{}

@unsafe
def p113bq_ready(diamond: P113BQDiamond, code: P111QCode) -> Bool:
  match diamond code:
    case P113BQYes{name,invert} P111QCode{chunks,n,terminal,error}: U32.is_lt(n,4294967295) && Bool.not(terminal) && String.is_empty(error)
    case _ _: False{}

@unsafe
def p113bq_emit(+condition: N111Value, diamond: P113BQDiamond, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match diamond code:
    case P113BQYes{name,+invert} P111QCode{chunks,+n,terminal,error}:
      +temporary = "%p113_bool_" ++ U32.show(n)
      P111QCode{Con{p111q_local(name) ++ " =l extuw " ++ temporary ++ "\n",
        Con{temporary ++ " =w " ++ nt_choose(String,invert,u => "ceqw",u => "cnew") ++ " " ++ p111q_value(condition,ids) ++ ", 0\n",chunks}},U32.inc(n),terminal,error}
    case P113BQNo{} _: p111q_problem("invalid private Boolean diamond",code)
