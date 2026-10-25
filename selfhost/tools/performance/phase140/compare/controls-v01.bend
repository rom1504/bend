# Compare both implementations with independent expected answers. Synthetic
# index values exercise exact structure, not index search validity.
@unsafe
def p140eqc_row(name: String, +a: KDef, +b: KDef, +expected: Bool) -> String:
  p114st_row(name,p134v_bool(p140r_def(a,b),expected) && p134v_bool(p140eq_def(a,b),expected))

def p140eqc_def(name: String, value: U32) -> KDef:
  KDef{name,"Def",0,0,atom("Data"),KLiteral{"U32",value,"",0,0},[],False{},False{}}

def p140eqc_wrap(term: KTerm) -> KDef:
  KDef{"value","Def",0,0,atom("Data"),term,[],False{},False{}}

@unsafe
def p140eqc_book(+left: U32) -> List<&2,KDef>:
  nt_choose(List<&2,KDef>,U32.is_eq(left,0),u => [],
    u => Con{p140eqc_def("entry" ++ U32.show(left),left),p140eqc_book(U32.sub(left,1))})

@unsafe
def p140eqc_controls() -> List<&2,String>:
  +a = p140eqc_def("a",1)
  +b = p140eqc_def("b",2)
  +leaf : KDef = KIndexLeaf{7,[a,b]}
  +right : KDef = KIndexLeaf{9,[p140eqc_def("c",3)]}
  +tree : KDef = KIndexNode{0,8,leaf,right}
  +fake : KDef = KDef{"","IndexLeaf",7,0,atom("Absent"),atom("Absent"),[a,b],True{},False{}}
  +parent : KDef = KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[a,b],False{},False{}}
  +term : KTerm = KTerm{"Var","x",3,2,[],["gone"],10,20}
  +lambda : KTerm = KLambda{"x",3,2,[term],[],10,20,True{}}
  +literal : KTerm = KLiteral{"U32",7,"seven",10,20}
  +built = index_build(p140eqc_book(32))
  [p140eqc_row("eq-empty",missing(),missing(),True{}),
   p140eqc_row("eq-ordinary",a,p140eqc_def("a",1),True{}),
   p140eqc_row("eq-name",a,p140eqc_def("b",1),False{}),
   p140eqc_row("eq-value",a,p140eqc_def("a",2),False{}),
   p140eqc_row("eq-kind",a,KDef{"a","Ctr",0,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-arity",a,KDef{"a","Def",1,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-templates",a,KDef{"a","Def",0,1,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-native",a,KDef{"a","Def",0,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],True{},False{}},False{}),
   p140eqc_row("eq-unsafe",a,KDef{"a","Def",0,0,atom("Data"),KLiteral{"U32",1,"",0,0},[],False{},True{}},False{}),
   p140eqc_row("eq-type",a,KDef{"a","Def",0,0,atom("Set"),KLiteral{"U32",1,"",0,0},[],False{},False{}},False{}),
   p140eqc_row("eq-leaf",leaf,KIndexLeaf{7,[a,b]},True{}),
   p140eqc_row("eq-leaf-hash",leaf,KIndexLeaf{8,[a,b]},False{}),
   p140eqc_row("eq-collision-order",leaf,KIndexLeaf{7,[b,a]},False{}),
   p140eqc_row("eq-collision-length",leaf,KIndexLeaf{7,[a]},False{}),
   p140eqc_row("eq-collision-body",leaf,KIndexLeaf{7,[a,p140eqc_def("b",3)]},False{}),
   p140eqc_row("eq-index-variant",fake,leaf,False{}),
   p140eqc_row("eq-node",tree,KIndexNode{0,8,leaf,right},True{}),
   p140eqc_row("eq-node-hash",tree,KIndexNode{1,8,leaf,right},False{}),
   p140eqc_row("eq-node-mask",tree,KIndexNode{0,16,leaf,right},False{}),
   p140eqc_row("eq-node-left",tree,KIndexNode{0,8,KIndexLeaf{7,[a]},right},False{}),
   p140eqc_row("eq-node-right",tree,KIndexNode{0,8,leaf,KIndexLeaf{9,[]}},False{}),
   p140eqc_row("eq-node-order",tree,KIndexNode{0,8,right,leaf},False{}),
   p140eqc_row("eq-child-order",parent,KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[b,a],False{},False{}},False{}),
   p140eqc_row("eq-child-length",parent,KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[a],False{},False{}},False{}),
   p140eqc_row("eq-nested-variant",KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[fake],False{},False{}},KDef{"Owner","ADT",0,0,atom("Data"),atom("Absent"),[leaf],False{},False{}},False{}),
   p140eqc_row("eq-term",p140eqc_wrap(term),p140eqc_wrap(term),True{}),
   p140eqc_row("eq-term-begin",p140eqc_wrap(term),p140eqc_wrap(KTerm{"Var","x",3,2,[],["gone"],11,20}),False{}),
   p140eqc_row("eq-term-end",p140eqc_wrap(term),p140eqc_wrap(KTerm{"Var","x",3,2,[],["gone"],10,21}),False{}),
   p140eqc_row("eq-term-removed",p140eqc_wrap(term),p140eqc_wrap(KTerm{"Var","x",3,2,[],[],10,20}),False{}),
   p140eqc_row("eq-lambda",p140eqc_wrap(lambda),p140eqc_wrap(lambda),True{}),
   p140eqc_row("eq-lambda-present",p140eqc_wrap(lambda),p140eqc_wrap(KLambda{"x",3,2,[term],[],10,20,False{}}),False{}),
   p140eqc_row("eq-lambda-variant",p140eqc_wrap(lambda),p140eqc_wrap(KTerm{"Lam","x",3,2,[term],[],10,20}),False{}),
   p140eqc_row("eq-literal",p140eqc_wrap(literal),p140eqc_wrap(literal),True{}),
   p140eqc_row("eq-literal-number",p140eqc_wrap(literal),p140eqc_wrap(KLiteral{"U32",8,"seven",10,20}),False{}),
   p140eqc_row("eq-literal-text",p140eqc_wrap(literal),p140eqc_wrap(KLiteral{"U32",7,"SEVEN",10,20}),False{}),
   p140eqc_row("eq-literal-variant",p140eqc_wrap(literal),p140eqc_wrap(KTerm{"U32","seven",7,0,[],[],10,20}),False{}),
   p140eqc_row("eq-built-index",built,index_build(p140eqc_book(32)),True{}),
   p140eqc_row("eq-built-edited",built,index_set(built,p140eqc_def("entry16",99),index_hash("entry16",2166136261),32),False{}),
   p114st_row("eq-list-identical",p140eq_list([a,b],[a,b])),
   p114st_row("eq-list-order",Bool.not(p140eq_list([a,b],[b,a])))]
