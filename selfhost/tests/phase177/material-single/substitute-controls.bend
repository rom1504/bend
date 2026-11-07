# Literal full-value expectations for frontend f_sub, not core subst.
type P177FSCase is Data:
  P177FSCase{+input: KTerm, +id: U32, +value: KTerm, +expected: KTerm}

def p177fsc_value(begin: U32, end: U32) -> KTerm:
  KLiteral{"U32",99,"replacement",begin,end}

def p177fsc_cases() -> List<&2,P177FSCase>:
  +v = p177fsc_value(0,0)
  [P177FSCase{KTerm{"Var","hit",7,2,[KTerm{"Ref","ignored",1,2,[],[],1,2}],["var-note"],10,11},7,v,p177fsc_value(10,11)},
   P177FSCase{KTerm{"Var","miss",8,1,[KTerm{"Var","child",7,0,[],[],20,21}],["var-note"],10,11},7,v,
      KTerm{"Var","miss",8,1,[p177fsc_value(20,21)],["var-note"],10,11}},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],10,11},7,p177fsc_value(1,0),p177fsc_value(1,0)},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],10,11},7,p177fsc_value(0,1),p177fsc_value(0,1)},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],10,11},7,
      KTerm{"FUnboundVar","name",9,2,[v],["keep"],0,0},
      KTerm{"FUnboundVar","name",9,2,[v],["keep"],0,0}},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],10,11},7,
      KLiteral{"FUnboundVar",7,"literal-kind",0,0},KLiteral{"FUnboundVar",7,"literal-kind",10,11}},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],10,11},7,
      KLambda{"replacement",7,1,[KTerm{"Var","opaque-child",7,2,[],[],0,0}],["lambda-note"],0,0,False{}},
      KLambda{"replacement",7,1,[KTerm{"Var","opaque-child",7,2,[],[],0,0}],["lambda-note"],10,11,False{}}},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],10,11},7,
      KTerm{"Ctr","replacement",7,1,[KTerm{"Var","opaque-child",7,2,[],[],0,0}],["ctor-note"],0,0},
      KTerm{"Ctr","replacement",7,1,[KTerm{"Var","opaque-child",7,2,[],[],0,0}],["ctor-note"],10,11}},
   P177FSCase{KTerm{"App","keep-app",44,2,[KLambda{"x",7,1,[KTerm{"Var","x",7,1,[],[],19,20}],["lambda"],17,21,True{}},v],["app-note"],16,22},7,v,
      KTerm{"App","keep-app",44,2,[KLambda{"x",7,1,[p177fsc_value(19,20)],["lambda"],17,21,True{}},v],["app-note"],16,22}},
   P177FSCase{KTerm{"App","empty-app",44,2,[],["keep"],23,24},7,v,
      KTerm{"App","empty-app",44,2,[],["keep"],23,24}},
   P177FSCase{KLiteral{"Var",7,"not-a-variable",23,24},7,v,KLiteral{"Var",7,"not-a-variable",23,24}},
   P177FSCase{KTerm{"Lam","legacy",7,1,[KTerm{"Var","x",7,2,[],[],25,26}],["keep"],24,27},7,v,
      KTerm{"Lam","legacy",7,1,[p177fsc_value(25,26)],["keep"],24,27}},
   P177FSCase{KTerm{"Error","still-traverse",0,2,[KTerm{"Var","x",7,2,[],[],31,32}],["keep"],30,33},7,v,
      KTerm{"Error","still-traverse",0,2,[p177fsc_value(31,32)],["keep"],30,33}},
   P177FSCase{KTerm{"FName","both-children",0,2,[KTerm{"Var","syntax",7,2,[],[],35,36},KTerm{"Var","value",7,2,[],[],37,38}],["keep"],34,39},7,v,
      KTerm{"FName","both-children",0,2,[p177fsc_value(35,36),p177fsc_value(37,38)],["keep"],34,39}},
   P177FSCase{KTerm{"Var","hit",7,2,[],[],41,42},7,KTerm{"Var","self-id",7,1,[],["keep"],0,0},
      KTerm{"Var","self-id",7,1,[],["keep"],41,42}},
   P177FSCase{KTerm{"Var","zero",0,2,[],[],0,0},0,v,v},
   P177FSCase{KTerm{"Var","max",4294967295,2,[],[],4294967295,0},4294967295,v,p177fsc_value(4294967295,0)},
   P177FSCase{KLambda{"empty",7,0,[],["keep"],51,52,False{}},7,v,
      KLambda{"empty",7,0,[],["keep"],51,52,False{}}},
   P177FSCase{KTerm{"Var","root-hit",7,2,[KTerm{"Error","ignored-child",0,2,[],[],1,2}],[],0,29},7,v,
      p177fsc_value(0,29)},
   P177FSCase{KTerm{"App","three-children",44,1,[KTerm{"Var","a",7,0,[],[],61,62},KTerm{"Var","b",7,0,[],[],63,64},KTerm{"Var","c",7,0,[],[],65,66}],["keep"],60,67},7,v,
      KTerm{"App","three-children",44,1,[p177fsc_value(61,62),p177fsc_value(63,64),p177fsc_value(65,66)],["keep"],60,67}}]

@unsafe
def p177fsc_actual_cases(cases: List<&2,P177FSCase>) -> List<&2,KTerm>:
  match cases:
    case Nil{}: Nil{}
    case Con{P177FSCase{input,id,value,expected},rest}:
      Con{f_sub(input,id,value),p177fsc_actual_cases(rest)}

@unsafe
def p177fsc_expected_cases(cases: List<&2,P177FSCase>) -> List<&2,KTerm>:
  match cases:
    case Nil{}: Nil{}
    case Con{P177FSCase{input,id,value,expected},rest}:
      Con{expected,p177fsc_expected_cases(rest)}

@unsafe
def p177fsc_actual() -> List<&2,KTerm>:
  p177fsc_actual_cases(p177fsc_cases())

@unsafe
def p177fsc_expected() -> List<&2,KTerm>:
  p177fsc_expected_cases(p177fsc_cases())
