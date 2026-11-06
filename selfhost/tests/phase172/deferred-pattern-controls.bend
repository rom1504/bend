# Finite whole-record controls; no malformed program is executed natively.
# The old f_pattern_sub is unchanged and independently supplies the sequential
# reference. Match observations must be compared across baseline/candidate APIs.
type P172DPSubObservation is Data:
  P172DPSubObservation{mode: U32, +expected: KTerm, +actual: KTerm}

type P172DPMatchObservation is Data:
  P172DPMatchObservation{mode: U32, +result: FFlatten}

@unsafe
def p172dpt_var(+id: U32, quantity: U32, +begin: U32) -> KTerm:
  KTerm{"Var", "v" ++ U32.show(id), id, quantity, [], ["preserved"], begin, U32.add(begin, 2)}

@unsafe
def p172dpt_ctr(name: String, fields: List<&2,KTerm>) -> KTerm:
  KTerm{"Ctr", name, 0, 1, fields, ["constructor-origin"], 30, 36}

@unsafe
def p172dpt_body() -> KTerm:
  KTerm{"App", "body-metadata", 42, 2,
    [p172dpt_var(1,1,8), p172dpt_var(2,2,0),
      KLambda{"lambda", 7, 2, [p172dpt_var(1,0,14)], ["removed-lambda"], 13, 19, False{}},
      KLiteral{"U32", 45, "literal-spelling", 20, 25}],
    ["body-removed", ""], 3, 28}

@unsafe
def p172dpt_reference(term: KTerm, operations: List<&2,P172DPSub>) -> KTerm:
  match operations:
    case Nil{}: term
    case Con{operation, rest}:
      match operation:
        case P172DPSub{id, value}: p172dpt_reference(f_pattern_sub(term,id,value),rest)

@unsafe
def p172dpt_sub_term(mode: U32) -> KTerm:
  match mode:
    case 6: p172dpt_var(1,1,0)
    case 7: p172dpt_var(1,1,50)
    case 8: KTerm{"Var","malformed-parent",9,2,[p172dpt_var(1,1,11)], ["kept"],7,19}
    case 9: KTerm{"Var","replace-parent",2,2,[p172dpt_var(1,1,11)], ["kept"],7,19}
    case 10: KLiteral{"U32", 91, "literal", 0, 0}
    case 11: KLambda{"lambda",1,0,[p172dpt_var(1,2,9)],["lambda-removed"],7,18,True{}}
    case 17: KTerm{"Var","nested-child",9,1,[p172dpt_var(1,1,0),p172dpt_var(2,1,25)],[],0,0}
    case 18: KTerm{"Var","zero-origin",1,1,[],[],0,0}
    case 19: KTerm{"Var","nonzero-origin",1,1,[],[],75,82}
    case _: p172dpt_body()

@unsafe
def p172dpt_sub_operations(mode: U32) -> List<&2,P172DPSub>:
  match mode:
    case 0: []
    case 1: [P172DPSub{1,p172dpt_ctr("A",[])}]
    case 2: [P172DPSub{99,p172dpt_ctr("A",[])}]
    case 3: [P172DPSub{1,p172dpt_var(1,1,0)},P172DPSub{1,p172dpt_ctr("A",[])}]
    case 4: [P172DPSub{1,p172dpt_var(2,1,0)},P172DPSub{2,p172dpt_ctr("B",[])}]
    case 5: [P172DPSub{2,p172dpt_var(3,1,0)},P172DPSub{1,p172dpt_var(2,2,0)}]
    case 6: [P172DPSub{1,p172dpt_ctr("A",[p172dpt_var(2,2,19)])},P172DPSub{2,p172dpt_ctr("B",[])}]
    case 7: [P172DPSub{1,p172dpt_ctr("A",[p172dpt_var(2,2,19)])},P172DPSub{2,p172dpt_ctr("B",[])}]
    case 8: [P172DPSub{1,p172dpt_var(2,1,0)},P172DPSub{2,p172dpt_ctr("C",[])}]
    case 9: [P172DPSub{1,p172dpt_var(2,1,0)},P172DPSub{2,p172dpt_ctr("C",[])}]
    case 10: [P172DPSub{0,p172dpt_ctr("C",[])}]
    case 11: [P172DPSub{1,p172dpt_ctr("C",[p172dpt_var(1,1,3)])}]
    case 12: [P172DPSub{1,p172dpt_ctr("A",[p172dpt_var(2,1,0)])},P172DPSub{2,p172dpt_ctr("B",[p172dpt_var(3,1,0)])},P172DPSub{3,p172dpt_var(4,1,60)}]
    case 13: [P172DPSub{1,p172dpt_var(2,1,0)},P172DPSub{2,p172dpt_var(1,1,0)},P172DPSub{1,p172dpt_ctr("A",[])}]
    case 14: [P172DPSub{0,p172dpt_var(1,1,0)},P172DPSub{99,p172dpt_var(2,1,0)}]
    case 15: [P172DPSub{2,KLambda{"replacement",7,2,[p172dpt_var(3,1,0)],["replacement-removed"],0,0,False{}}},P172DPSub{3,p172dpt_ctr("B",[])}]
    case 16: [P172DPSub{1,KLiteral{"String",0,"literal-content",2,21}},P172DPSub{2,p172dpt_var(1,1,0)}]
    case 17: [P172DPSub{1,p172dpt_ctr("A",[])},P172DPSub{2,p172dpt_ctr("B",[])}]
    case 18: [P172DPSub{1,p172dpt_var(2,1,0)},P172DPSub{2,p172dpt_ctr("B",[p172dpt_var(3,1,40)])}]
    case _: [P172DPSub{1,p172dpt_var(2,1,0)},P172DPSub{2,p172dpt_ctr("B",[p172dpt_var(3,1,40)])}]

@unsafe
def p172dp_sub_case(+mode: U32) -> P172DPSubObservation:
  +term = p172dpt_sub_term(mode)
  +operations = p172dpt_sub_operations(mode)
  P172DPSubObservation{mode,p172dpt_reference(term,operations),p172dp_apply(term,operations)}

@unsafe
def p172dpt_row(patterns: List<&2,KTerm>, body: KTerm, quantity: U32) -> KTerm:
  KTerm{"Row","discarded-row-metadata",42,quantity,
    [KTerm{"Patterns","discarded-pattern-metadata",9,2,patterns,[],1,5},body],
    ["row-removed"],1,40}

@unsafe
def p172dpt_match_rows(mode: U32) -> List<&2,KTerm>:
  match mode:
    case 0: []
    case 1: [p172dpt_row([],p172dpt_body(),1)]
    case 2: [p172dpt_row([],p172dpt_var(1,1,8),1),p172dpt_row([],atom("Error"),1)]
    case 3: [p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 4: [p172dpt_row([p172dpt_ctr("A",[])],atom("Type"),1),p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 5: [p172dpt_row([p172dpt_var(11,1,9),p172dpt_var(12,2,11)],kt("App","",0,1,[p172dpt_var(11,1,0),p172dpt_var(12,1,25)]),1)]
    case 6: [p172dpt_row([p172dpt_ctr("Pair",[p172dpt_ctr("A",[]),p172dpt_var(12,1,10)])],p172dpt_var(12,1,22),1),p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 7: [p172dpt_row([p172dpt_ctr("Pair",[p172dpt_var(11,2,10),p172dpt_var(12,1,14)])],kt("App","",0,1,[p172dpt_var(11,1,20),p172dpt_var(12,1,26)]),1)]
    case 8: [p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 9: [p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 10: [p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),0)]
    case 11: [p172dpt_row([p172dpt_var(11,2,9)],p172dpt_var(11,2,20),1)]
    case 12: [p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 13: [p172dpt_row([p172dpt_ctr("A",[])],kt_span("Error","first error",0,0,[],13,15),1),p172dpt_row([p172dpt_var(11,1,9)],p172dpt_var(11,1,20),1)]
    case 14: []
    case 15: [atom("Absent")]
    case 16: [p172dpt_row([p172dpt_ctr("A",[])],atom("Type"),1),p172dpt_row([p172dpt_ctr("B",[])],atom("Empty"),1)]
    case 17: [p172dpt_row([p172dpt_var(11,1,9),p172dpt_var(12,1,10)],p172dpt_body(),1)]
    case 18: [p172dpt_row([p172dpt_var(1,1,9)],p172dpt_var(1,1,20),1),p172dpt_row([p172dpt_ctr("A",[])],atom("Type"),1)]
    case 19: [p172dpt_row([p172dpt_ctr("Pair",[p172dpt_ctr("A",[]),p172dpt_ctr("B",[])])],atom("Type"),1)]
    case 20: [KLambda{"row-lambda",3,1,[kt("Patterns","",0,1,[p172dpt_var(11,1,9)]),p172dpt_var(11,1,20)],["lambda-row"],5,9,False{}}]
    case 21: [p172dpt_row([p172dpt_var(11,2,9)],p172dpt_var(11,1,20),2)]
    case 22: [p172dpt_row([p172dpt_var(11,1,9)],kt("Match","",0,1,[kt("Heads","",0,1,[p172dpt_var(11,1,20)]),p172dpt_row([p172dpt_var(21,1,21)],p172dpt_var(21,1,30),1)]),1)]
    case _: [p172dpt_row([p172dpt_var(11,1,9)],kt("Parallel","",0,1,[kt("Vars","",0,1,[p172dpt_var(21,1,20)]),kt("Values","",0,1,[p172dpt_var(11,1,21)]),p172dpt_var(21,1,30)]),1)]

@unsafe
def p172dpt_match_heads(mode: U32) -> List<&2,KTerm>:
  match mode:
    case 0: []
    case 1: []
    case 2: []
    case 5: [p172dpt_var(1,1,8),p172dpt_var(2,1,10)]
    case 9: [p172dpt_ctr("NotVariable",[])]
    case 17: [p172dpt_var(1,1,8),p172dpt_ctr("NotVariable",[])]
    case _: [p172dpt_var(1,1,8)]

@unsafe
def p172dpt_match_vars(mode: U32) -> List<&2,KTerm>:
  match mode:
    case 0: []
    case 1: []
    case 2: []
    case 5: [p172dpt_var(1,1,8),p172dpt_var(2,1,10)]
    case 8: []
    case 12: [p172dpt_var(9,1,6),p172dpt_var(1,1,8)]
    case 17: [p172dpt_var(1,1,8),p172dpt_var(2,1,10)]
    case _: [p172dpt_var(1,1,8)]

@unsafe
def p172dp_match_case(+mode: U32) -> P172DPMatchObservation:
  +next = f_choose(U32,U32.is_eq(mode,19),u => 4294967295,u => 100)
  P172DPMatchObservation{mode,ff_match(p172dpt_match_heads(mode),p172dpt_match_rows(mode),
    p172dpt_match_vars(mode),next,kt_span("Match","",0,1,[],5,90))}
