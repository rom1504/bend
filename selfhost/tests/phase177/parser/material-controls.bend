def p177cc_value() -> KTerm:
  KLiteral{"U32",123,"literal-metadata",3,4}

def p177cc_error(+label: String, +begin: U32) -> KTerm:
  KTerm{"Error",label,5,2,[p177cc_value()],["error-note"],begin,U32.add(begin,1)}

def p177cc_lambda(+body: KTerm) -> KTerm:
  KLambda{"x",17,2,[body],["lambda-note"],7,8,False{}}

def p177cc_cases() -> List<&2,KTerm>:
  +first = p177cc_error("first-deferred",11)
  +second = p177cc_error("second-eager",13)
  +bound : KTerm = KTerm{"Var","x",17,2,[],["variable-note"],15,16}
  +safe : KTerm = KTerm{"Ctr","Pair",3,2,[p177cc_value(),bound],["pair-note"],17,18}
  [p177cc_value(),safe,bound,first,
   p177cc_lambda(first),
   KTerm{"App","eager-wins",0,1,[p177cc_lambda(first),second],["app-note"],19,20},
   KTerm{"App","discard-deferred",0,1,[p177cc_lambda(p177cc_value()),p177cc_lambda(first)],[],21,22},
   KTerm{"App","identity",0,1,[p177cc_lambda(bound),safe],[],23,24},
   KTerm{"Unknown","eager-before-deferred",0,1,[p177cc_lambda(first),second],[],25,26},
   KTerm{"All","domain-first",17,2,[first,second],[],27,28},
   KTerm{"All","nested-domain",17,2,[p177cc_lambda(first),second],[],29,30},
   KTerm{"Let","value-first",0,1,[first,second],[],31,32},
   KTerm{"Let","nested-value",0,1,[p177cc_lambda(first),second],[],33,34},
   KTerm{"FName","located",0,1,[first,safe],["name-note"],35,36},
   KTerm{"FName","missing",0,1,[],[],37,38},
   KTerm{"Ref",".add",0,1,[],[],39,40},
   KTerm{"Lam","legacy-empty",17,1,[],["empty-note"],41,42},
   KLambda{"empty",17,0,[],["empty-note"],43,44,False{}},
   KTerm{"All","extra",17,1,[safe,first,second],[],45,46},
   KTerm{"Let","empty",0,2,[],["empty-note"],47,48},
   KTerm{"App","empty",0,2,[],["empty-note"],49,50},
   KTerm{"App","missing-arg",0,2,[p177cc_lambda(bound)],["app-note"],51,52},
   KTerm{"App","extra-arg",0,2,[p177cc_lambda(bound),safe,second],["app-note"],53,54},
   KLiteral{"FName",99,"arbitrary-literal-kind",55,56},
   KLiteral{"Lam",100,"arbitrary-literal-kind",57,58},
   KTerm{"Unknown","empty",0,2,[],["empty-note"],59,60}]

@unsafe
def p177cc_priority_actual() -> KTerm:
  f_context_materialize(KTerm{"App","",0,1,
    [p177cc_lambda(p177cc_error("first-deferred",11)),p177cc_error("second-eager",13)],[],19,20})

def p177cc_priority_expected() -> KTerm:
  KTerm{"Error","second-eager",5,2,[KLiteral{"U32",123,"literal-metadata",3,4}],["error-note"],13,14}
