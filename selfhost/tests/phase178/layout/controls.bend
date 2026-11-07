# Complete observations; expected values below are literal compiler data.
type ErasureObservation is Data:
  ErasureObservation{+body: KTerm, +references: List<&2,String>}

type ErasureControl is Data:
  ErasureControl{+input: KTerm, +expected: KTerm, +references: List<&2,String>}

law erasure_control_observe:
  for +book: List<&2,KDef>
  for +input: KTerm
  for +reverseSeed: List<&2,String>
  for +tail: List<&2,String>
  ErasureObservation

law erasure_control_uncollected:
  for +book: List<&2,KDef>
  for +input: KTerm
  for +reverseSeed: List<&2,String>
  ErasureObservation

law erasure_control_definition:
  for +book: List<&2,KDef>
  for +definition: KDef
  for +n: U32
  ErasureObservation

@unsafe
def erasure_control_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

@unsafe
def erasure_control_tel() -> KTerm:
  all(0,"T",7,typ(1),all(1,"x",8,var("T",7),kt("ADT","Owned",0,0,[])))

@unsafe
def erasure_control_book() -> List<&2,KDef>:
  [KDef{"Owned","ADT",0,0,typ(1),erasure_control_absent(),
      [KDef{"O","Ctr",2,0,erasure_control_tel(),erasure_control_absent(),[],False{},False{}}],True{},False{}},
   KDef{"User","ADT",0,0,typ(1),erasure_control_absent(),
      [KDef{"U","Ctr",2,0,erasure_control_tel(),erasure_control_absent(),[],False{},False{}}],False{},False{}}]

@unsafe
def erasure_control_books() -> List<&2,List<&2,KDef>>:
  +book = erasure_control_book()
  [[],book,book_cached(book,0),p144o_view(book_cached(book,0),p144o_build(book))]

@unsafe
def erasure_control_cases() -> List<&2,ErasureControl>:
  [ErasureControl{KTerm{"Var","x",9,2,[ref("discard")],["old"],11,20},
      KTerm{"Var","x",9,0,[],[],0,0},[]},
   ErasureControl{KTerm{"Ref","a",9,2,[ref("b"),ref("a")],["old"],11,20},
      KTerm{"Ref","a",9,2,[KTerm{"Ref","b",0,0,[],[],0,0},KTerm{"Ref","a",0,0,[],[],0,0}],[],0,0},["a","b","a"]},
   ErasureControl{KLiteral{"String",42,"λ\n",11,20},KLiteral{"String",42,"λ\n",11,20},[]},
   ErasureControl{KLambda{"x",9,0,[ref("body"),ref("discard")],["old"],11,20,True{}},
      KTerm{"Ref","body",0,0,[],[],0,0},["body"]},
   ErasureControl{KLambda{"x",9,2,[ref("body"),ref("extra")],["old"],11,20,False{}},
      KLambda{"x",9,2,[KTerm{"Ref","body",0,0,[],[],0,0},KTerm{"Ref","extra",0,0,[],[],0,0}],[],0,0,False{}},["body","extra"]},
   ErasureControl{KTerm{"Lam","legacy",9,1,[ref("body")],["old"],11,20},
      KTerm{"Lam","legacy",9,1,[KTerm{"Ref","body",0,0,[],[],0,0}],[],0,0},["body"]},
   ErasureControl{KTerm{"App","raw",9,2,[ka_wrap(ref("function"),all(0,"T",7,typ(1),typ(1))),ref("discard"),ref("extra")],["old"],11,20},
      KTerm{"Ref","function",0,0,[],[],0,0},["function"]},
   ErasureControl{ka_wrap(KTerm{"Ref","proof",0,0,[ref("discard")],[],0,0},kt("Eql","",0,0,[ref("type-only"),ref("type-only")])),
      KTerm{"Rfl","",0,0,[],[],0,0},[]},
   ErasureControl{ka_wrap(ref("body"),typ(1)),KTerm{"Ref","body",0,0,[],[],0,0},["body"]},
   ErasureControl{KTerm{"App","empty",9,2,[],["old"],11,20},KTerm{"App","empty",9,2,[],[],0,0},[]},
   ErasureControl{KTerm{"App","raw",9,2,[ref("f"),ref("x"),ref("f")],["old"],11,20},
      KTerm{"App","raw",9,2,[KTerm{"Ref","f",0,0,[],[],0,0},KTerm{"Ref","x",0,0,[],[],0,0},KTerm{"Ref","f",0,0,[],[],0,0}],[],0,0},["f","x","f"]},
   ErasureControl{ka_wrap(KTerm{"Ctr","O",9,2,[ref("dead"),ref("live")],["old"],11,20},kt("ADT","Owned",0,0,[])),
      KTerm{"Ctr","O",9,2,[KTerm{"Ref","live",0,0,[],[],0,0}],[],0,0},["live"]},
   ErasureControl{ka_wrap(KTerm{"Ctr","U",9,2,[ref("dead"),ref("live")],["old"],11,20},kt("ADT","User",0,0,[])),
      KTerm{"Ctr","$ctor.85_",9,2,[KTerm{"Ref","live",0,0,[],[],0,0}],[],0,0},["live"]},
   ErasureControl{KTerm{"Ann","empty",9,2,[],["old"],11,20},KTerm{"Absent","",0,0,[],[],0,0},[]},
   ErasureControl{KLambda{"empty",4294967295,0,[],["old"],11,20,False{}},KTerm{"Absent","",0,0,[],[],0,0},[]},
   ErasureControl{KTerm{"Rwt","rewrite",9,2,[ref("proof"),ref("motive"),ref("result")],["old"],11,20},
      KTerm{"Rwt","rewrite",9,2,[KTerm{"Ref","proof",0,0,[],[],0,0},KTerm{"Ref","motive",0,0,[],[],0,0},KTerm{"Ref","result",0,0,[],[],0,0}],[],0,0},["proof","motive","result"]},
   ErasureControl{ka_wrap(KTerm{"Mat","O",9,2,[ref("arm"),ref("rest")],["old"],11,20},
      all(1,"scrutinee",10,kt("ADT","Owned",0,0,[]),typ(1))),
      KTerm{"Mat","O",2,0,[KTerm{"Ref","arm",0,0,[],[],0,0},KTerm{"Ref","rest",0,0,[],[],0,0}],[],0,0},["arm","rest"]},
   ErasureControl{ka_wrap(KTerm{"Ctr","O",9,2,[ref("dead"),ref("live"),ref("extra-dead")],["old"],11,20},kt("ADT","Owned",0,0,[])),
      KTerm{"Ctr","O",9,2,[KTerm{"Ref","live",0,0,[],[],0,0}],[],0,0},["live"]},
   ErasureControl{KTerm{"Lit","legacy",9,2,[ref("visible")],["old"],11,20},
      KTerm{"Lit","legacy",9,2,[KTerm{"Ref","visible",0,0,[],[],0,0}],[],0,0},["visible"]},
   ErasureControl{app(ka_wrap(ref("Array.new"),all(0,"T",7,typ(1),typ(1))),ref("discarded-element")),
      KTerm{"Ref","Array.new",0,0,[],[],0,0},["Array.new"]}]

@unsafe
def erasure_control_actual_rows(+book: List<&2,KDef>, cases: List<&2,ErasureControl>) -> List<&2,ErasureObservation>:
  match cases:
    case Nil{}: []
    case Con{ErasureControl{input,expected,references},rest}:
      Con{erasure_control_observe(book,input,[],[]),erasure_control_actual_rows(book,rest)}

@unsafe
def erasure_control_expected_rows(cases: List<&2,ErasureControl>) -> List<&2,ErasureObservation>:
  match cases:
    case Nil{}: []
    case Con{ErasureControl{input,expected,references},rest}:
      Con{ErasureObservation{expected,references},erasure_control_expected_rows(rest)}

@unsafe
def erasure_control_actual() -> List<&2,ErasureObservation>:
  erasure_control_actual_rows(erasure_control_book(),erasure_control_cases())

@unsafe
def erasure_control_expected() -> List<&2,ErasureObservation>:
  erasure_control_expected_rows(erasure_control_cases())

@unsafe
def erasure_control_telescopes() -> List<&2,KTerm>:
  [erasure_control_tel(),all(1,"x",7,typ(1),all(0,"y",8,typ(1),typ(1))),
   all(0,"T",7,typ(1),var("T",7)),erasure_control_absent()]

@unsafe
def erasure_control_arguments() -> List<&2,List<&2,KTerm>>:
  [[],[ref("x")],[ref("x"),ref("y"),ref("x")],
   [all(1,"next",99,typ(1),typ(1)),ref("dependent-live")],
   [all(0,"next",99,typ(1),typ(1)),ref("dependent-dead")]]

@unsafe
def erasure_control_definitions() -> List<&2,KDef>:
  [KDef{"normal","Def",0,0,typ(1),ref("next"),[],False{},False{}},
   KDef{"foreign","Def",0,0,erasure_control_tel(),kt("Foreign","foreign",0,0,[]),[],False{},False{}},
   KDef{"absent","Def",0,0,typ(1),erasure_control_absent(),[],False{},False{}},
   KDef{"U32.add","Def",2,0,typ(1),erasure_control_absent(),[],True{},False{}}]

@unsafe
def erasure_control_closure_book() -> List<&2,KDef>:
  [KDef{"main","Def",0,0,typ(1),kt("Seq","",0,0,
      [ref("a"),ref("b"),ref("a"),ref("foreign"),ref("U32.add"),ref("missing"),
       app(ka_wrap(ref("b"),all(0,"T",7,typ(1),typ(1))),ref("unreachable"))]),[],False{},False{}},
   KDef{"a","Def",0,0,typ(1),ref("main"),[],False{},False{}},
   KDef{"a","Def",0,0,typ(1),ref("shadowed"),[],False{},False{}},
   KDef{"b","Def",0,0,typ(1),KLiteral{"U32",5,"five",11,20},[],False{},False{}},
   KDef{"foreign","Def",0,0,erasure_control_tel(),kt("Foreign","foreign",0,0,[]),[],False{},False{}},
   KDef{"U32.add","Def",2,0,typ(1),erasure_control_absent(),[],True{},False{}}]

@unsafe
def erasure_control_string_lists() -> List<&2,List<&2,String>>:
  [[],["a"],["main","foreign"],["pending","a","pending"]]

@unsafe
def erasure_control_adt() -> KTerm:
  kt("ADT","Owned",0,0,[])

@unsafe
def erasure_control_visit(+book: List<&2,KDef>, todo: List<&2,String>,
  done: List<&2,String>, facts: List<&2,KDef>) -> NR_Closure:
  nr_visit(book,"main",todo,done,facts,lookup(book,"main"))

@unsafe
def erasure_control_incremental_after(+book: List<&2,KDef>, mode: U32,
  +first: P140OEResult) -> List<&2,P140OEResult>:
  match first:
    case P140OEResult{closure,entries,hits,misses}:
      [first,p140oe_apply(book,P140OAnalysis{U32.is_eq(mode,1),missing(),[],0},entries)]

@unsafe
def erasure_control_incremental(+book: List<&2,KDef>, mode: U32) -> List<&2,P140OEResult>:
  erasure_control_incremental_after(book,mode,p140oe_apply(book,P140OAnalysis{False{},missing(),[],0},[]))
