# Complete term expectations are literal data, independent of the algorithm.
# The host compares all fields rather than norm_exact (which omits spans).
type P177SCase is Data:
  P177SCase{+input: KTerm, +id: U32, +value: KTerm, +expected: KTerm}

def p177sv_value() -> KTerm:
  KLiteral{"U32",99,"replacement",901,902}

def p177sv_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

def p177sv_cases() -> List<&2,P177SCase>:
  +v = p177sv_value()
  +a = p177sv_absent()
  [
    P177SCase{KTerm{"Var","x",7,2,[KTerm{"Var","child",7,0,[],[],2,3}],["note"],10,11},7,v,v},
    P177SCase{KTerm{"Var","other",8,1,[KTerm{"Var","child",7,0,[],[],2,3}],["stored"],10,11},7,v,
      KTerm{"Var","other",8,1,[KTerm{"Var","child",7,0,[],[],2,3}],["stored"],10,11}},
    P177SCase{KTerm{"Ref","leaf",7,2,[],["keep"],15,17},7,v,
      KTerm{"Ref","leaf",7,2,[],["keep"],15,17}},
    P177SCase{KLiteral{"String",7,"payload",16,18},7,v,KLiteral{"String",7,"payload",16,18}},
    P177SCase{KLambda{"binder",7,1,[KTerm{"Var","x",7,0,[],[],20,21}],["keep"],19,22,False{}},7,v,
      KLambda{"binder",7,1,[v],["keep"],19,22,False{}}},
    P177SCase{KLambda{"binder",7,2,[KTerm{"Var","x",7,0,[],[],20,21}],["keep"],19,22,True{}},7,v,
      KLambda{"binder",7,2,[v],["keep"],19,22,True{}}},
    P177SCase{KTerm{"Lam","legacy",7,1,[KTerm{"Var","x",7,0,[],[],20,21}],["keep"],19,22},7,v,
      KTerm{"Lam","legacy",7,1,[v],["keep"],19,22}},
    P177SCase{KTerm{"App","discard",45,2,[],["discard"],30,31},7,v,
      KTerm{"App","",0,0,[a,a],[],30,31}},
    P177SCase{KTerm{"App","discard",45,2,[KTerm{"Ref","f",3,1,[],["function"],1,2}],["discard"],30,31},7,v,
      KTerm{"App","",0,0,[KTerm{"Ref","f",3,1,[],["function"],1,2},a],[],30,31}},
    P177SCase{KTerm{"App","discard",45,2,[KTerm{"Ref","f",3,1,[],["function"],1,2},KTerm{"Var","x",7,0,[],[],3,4},KTerm{"Var","extra",7,0,[],[],5,6}],["discard"],30,31},7,v,
      KTerm{"App","",0,0,[KTerm{"Ref","f",3,1,[],["function"],1,2},v],[],30,31}},
    P177SCase{KTerm{"App","discard",45,2,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],40,41}],[],39,42,False{}},KTerm{"Var","x",7,0,[],[],43,44}],["discard"],38,45},7,v,v},
    P177SCase{KTerm{"App","",0,0,[KTerm{"Lam","z",8,1,[KTerm{"Var","z",8,0,[],[],40,41}],[],39,42},KTerm{"Ref","arg",0,0,[],[],43,44}],[],38,45},7,v,
      KTerm{"Ref","arg",0,0,[],[],43,44}},
    P177SCase{KTerm{"App","",0,0,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],40,41}],[],39,42,True{}}],[],38,45},7,v,a},
    P177SCase{KTerm{"Ctr","Pair",4,2,[KTerm{"App","",0,0,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],40,41}],[],39,42,True{}},KTerm{"Ref","arg",0,0,[],[],43,44}],[],38,45},KTerm{"Var","x",7,0,[],[],46,47}],["outer"],37,48},7,v,
      KTerm{"Ctr","Pair",4,2,[KTerm{"Ref","arg",0,0,[],[],43,44},v],["outer"],37,48}},
    P177SCase{KTerm{"App","",0,0,[KTerm{"Var","function",7,0,[],[],50,51},KLiteral{"U8",23,"arg",52,53}],[],49,54},7,
      KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],1,2}],[],0,3,False{}},
      KLiteral{"U8",23,"arg",52,53}},
    P177SCase{KTerm{"App","",0,0,[KLiteral{"U32",8,"function",50,51},KTerm{"Var","x",7,0,[],[],52,53}],[],49,54},7,v,
      KTerm{"App","",0,0,[KLiteral{"U32",8,"function",50,51},v],[],49,54}},
    P177SCase{KTerm{"Var","same",7,0,[],[],60,61},7,KTerm{"Var","same",7,0,[],[],70,71},
      KTerm{"Var","same",7,0,[],[],70,71}},
    P177SCase{KTerm{"Var","opaque-replacement",7,0,[],[],60,61},7,
      KTerm{"App","not-rebuilt",55,2,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],1,2}],[],0,3,False{}},v],["keep"],70,71},
      KTerm{"App","not-rebuilt",55,2,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],1,2}],[],0,3,False{}},v],["keep"],70,71}},
    P177SCase{KLambda{"empty",4294967295,2,[],["empty"],4294967295,0,False{}},4294967295,v,
      KLambda{"empty",4294967295,2,[],["empty"],4294967295,0,False{}}},
    P177SCase{KTerm{"App","",0,0,[KTerm{"Ann","ann",12,2,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],1,2}],[],0,3,True{}},KTerm{"Var","x",7,0,[],[],3,4}],["ann"],1,5},v],[],0,9},7,v,
      KTerm{"App","",0,0,[KTerm{"Ann","ann",12,2,[KLambda{"z",8,1,[KTerm{"Var","z",8,0,[],[],1,2}],[],0,3,True{}},v],["ann"],1,5},v],[],0,9}}
  ]

@unsafe
def p177sv_actual_cases(cases: List<&2,P177SCase>) -> List<&2,KTerm>:
  match cases:
    case Nil{}: Nil{}
    case Con{P177SCase{input,id,value,expected},rest}:
      Con{subst(input,id,value),p177sv_actual_cases(rest)}

@unsafe
def p177sv_expected_cases(cases: List<&2,P177SCase>) -> List<&2,KTerm>:
  match cases:
    case Nil{}: Nil{}
    case Con{P177SCase{input,id,value,expected},rest}:
      Con{expected,p177sv_expected_cases(rest)}

@unsafe
def p177sv_actual() -> List<&2,KTerm>:
  p177sv_actual_cases(p177sv_cases())

@unsafe
def p177sv_expected() -> List<&2,KTerm>:
  p177sv_expected_cases(p177sv_cases())

@unsafe
def p177sv_node_actual() -> List<&2,KTerm>:
  [subst_node(KTerm{"Var","root",7,1,[KTerm{"Var","child",7,0,[],[],2,3}],["keep"],1,4},7,p177sv_value()),
   subst_node(KTerm{"Var","empty",7,2,[],["keep"],5,6},7,p177sv_value())]

def p177sv_node_expected() -> List<&2,KTerm>:
  [KTerm{"Var","root",7,1,[p177sv_value()],["keep"],1,4},
   KTerm{"Var","empty",7,2,[],["keep"],5,6}]
