# Finite source-level controls for the existing freshener. These do not establish
# a theorem or authenticate a forged cache. The replay helper is a test model.
type P142FTReplay is Data:
  P142FTReplay{+result: FFreshDefs, +hit: Bool}

@unsafe
def p142ft_same(a: FFreshDefs, b: FFreshDefs) -> Bool:
  match a b:
    case FFreshDefs{ad,an} FFreshDefs{bd,bn}:
      U32.is_eq(an,bn) && p140p_defs(ad,bd)

def p142ft_next(result: FFreshDefs) -> U32:
  match result:
    case FFreshDefs{defs,next}: next

@unsafe
def p142ft_append(prefix: List<&2,KDef>, tail: FFreshDefs) -> FFreshDefs:
  match tail:
    case FFreshDefs{defs,next}: FFreshDefs{norm_defs_join(prefix,defs),next}

@unsafe
def p142ft_suffix(prefix: FFreshDefs, tail: List<&2,KDef>) -> FFreshDefs:
  match prefix:
    case FFreshDefs{defs,next}: p142ft_append(defs,f_fresh_defs(tail,next))

@unsafe
def p142ft_compose(+prefix: List<&2,KDef>, +tail: List<&2,KDef>, +start: U32) -> Bool:
  p142ft_same(f_fresh_defs(norm_defs_join(prefix,tail),start),
    p142ft_suffix(f_fresh_defs(prefix,start),tail))

# Test guard uses the completed representation, not the raw parser accumulator.
@unsafe
def p142ft_replay(+old: List<&2,KDef>, +current: List<&2,KDef>, +tail: List<&2,KDef>, +old_start: U32, +start: U32) -> P142FTReplay:
  nt_choose(P142FTReplay,U32.is_eq(old_start,start) && p140p_defs(old,current),
    u => P142FTReplay{p142ft_suffix(f_fresh_defs(old,old_start),tail),True{}},
    u => P142FTReplay{f_fresh_defs(norm_defs_join(current,tail),start),False{}})

@unsafe
def p142ft_replayed(result: P142FTReplay, expected: FFreshDefs, hit: Bool) -> Bool:
  match result:
    case P142FTReplay{actual,used}: Bool.not(Bool.xor(used,hit)) && p142ft_same(actual,expected)

@unsafe
def p142ft_replay_case(+old: List<&2,KDef>, +current: List<&2,KDef>, +tail: List<&2,KDef>, old_start: U32, +start: U32, hit: Bool) -> Bool:
  p142ft_replayed(p142ft_replay(old,current,tail,old_start,start),
    f_fresh_defs(norm_defs_join(current,tail),start),hit)

def p142ft_ref() -> KTerm:
  KTerm{"Ref","U32",0,1,[],[],10,13}

def p142ft_definition(name: String, type_id: U32, +value_id: U32, children: List<&2,KDef>, native: Bool, unsafe: Bool) -> KDef:
  KDef{name,"Def",1,0,
    KTerm{"All","x",type_id,1,[p142ft_ref(),p142ft_ref()],[],10,19},
    KLambda{"x",value_id,2,[KTerm{"Var","x",value_id,1,[],[],23,24}],[],20,25,True{}},
    children,native,unsafe}

def p142ft_nested() -> KDef:
  p142ft_definition("Outer",7,8,
    [p142ft_definition("Child",9,10,
      [p142ft_definition("Grandchild",11,12,[],True{},True{})],False{},True{})],True{},False{})

def p142ft_let() -> KDef:
  KDef{"let_case","Def",0,0,p142ft_ref(),
    KTerm{"Let","",0,1,
      [KTerm{"Bind","a",42,2,[KLiteral{"U32",8,"",30,31}],[],29,31},
       KLambda{"z",44,0,[KTerm{"Var","a",42,1,[],[],34,35}],[],32,35,False{}}],[],28,36},
    [],False{},False{}}

def p142ft_metadata(+present: Bool, quant: U32, begin: U32, native: Bool, unsafe: Bool) -> KDef:
  KDef{"metadata","Def",2,1,KLiteral{"U32",17,"literal-text",100,104},
    KLambda{"x",8,quant,[KTerm{"Var","x",8,1,[],[],112,113}],["removed"],begin,114,present},
    [],native,unsafe}

def p142ft_foreign(path: String) -> KDef:
  KDef{"foreign_step","Def",0,0,p142ft_ref(),
    KTerm{"Foreign","foreign_step",0,1,[KTerm{"Path",path,0,1,[],[],40,49}],[],38,49},
    [],False{},False{}}

@unsafe
def p142ft_controls() -> List<&2,String>:
  +one = p142ft_definition("one",7,8,[],False{},False{})
  +two = p142ft_definition("two",90,91,[],True{},True{})
  +nested = p142ft_nested()
  +metadata = p142ft_metadata(True{},2,110,True{},False{})
  +relative = p142ft_foreign("./foreign.js")
  +absolute = p142ft_foreign("/shared/foreign.js")
  +path_a = f_path_defs([relative],"/a/",False{})
  +path_b = f_path_defs([relative],"/b/",False{})
  +absolute_a = f_path_defs([absolute],"/a/",False{})
  +absolute_b = f_path_defs([absolute],"/b/",False{})
  +index : KDef = KIndexLeaf{7,[]}
  +projection : KDef = KDef{"","IndexLeaf",7,0,
    KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],True{},False{}}
  [p114st_row("freshening-empty-prefix",p142ft_compose([],[one],10)),
   p114st_row("freshening-empty-tail",p142ft_compose([one],[],10)),
   p114st_row("freshening-type-value-local-env",p142ft_compose([one],[two],10)),
   p114st_row("freshening-manual-counter-and-id-oracle",
     p142ft_same(f_fresh_defs([one],10),FFreshDefs{[p142ft_definition("one",10,11,[],False{},False{})],12})),
   p114st_row("freshening-nested-children-complete-cut",p142ft_compose([nested],[one],10) && U32.is_eq(p142ft_next(f_fresh_defs([nested,one],10)),18)),
   p114st_row("freshening-let-lambda-composition",p142ft_compose([p142ft_let()],[one],10)),
   p114st_row("freshening-let-lambda-counter",U32.is_eq(p142ft_next(f_fresh_defs([p142ft_let()],10)),12)),
   p114st_row("freshening-quantity-presence-flags-spans",p142ft_compose([metadata],[two],1)),
   p114st_row("freshening-hit-unchanged-completed-prefix",p142ft_replay_case([one],[one],[two],10,10,True{})),
   p114st_row("freshening-hit-suffix-binder-count-change",p142ft_replay_case([one],[one],[nested],10,10,True{}) && U32.is_eq(p142ft_next(f_fresh_defs([one,nested],10)),18)),
   p114st_row("freshening-miss-start-counter",p142ft_replay_case([one],[one],[two],10,11,False{})),
   p114st_row("freshening-miss-prefix-body",p142ft_replay_case([one],[p142ft_definition("one",7,99,[],False{},False{})],[two],10,10,False{})),
   p114st_row("freshening-miss-prefix-child",p142ft_replay_case([one],[p142ft_definition("one",7,8,[two],False{},False{})],[],10,10,False{})),
   p114st_row("freshening-miss-quantity",p142ft_replay_case([metadata],[p142ft_metadata(True{},1,110,True{},False{})],[],10,10,False{})),
   p114st_row("freshening-miss-quantity-presence",p142ft_replay_case([metadata],[p142ft_metadata(False{},2,110,True{},False{})],[],10,10,False{})),
   p114st_row("freshening-miss-span",p142ft_replay_case([metadata],[p142ft_metadata(True{},2,111,True{},False{})],[],10,10,False{})),
   p114st_row("freshening-miss-native-flag",p142ft_replay_case([metadata],[p142ft_metadata(True{},2,110,False{},False{})],[],10,10,False{})),
   p114st_row("freshening-miss-unsafe-flag",p142ft_replay_case([metadata],[p142ft_metadata(True{},2,110,True{},True{})],[],10,10,False{})),
   p114st_row("freshening-relative-foreign-path-falsifier",Bool.not(p140p_defs(path_a,path_b)) && p142ft_replay_case(path_a,path_b,[one],10,10,False{})),
   p114st_row("freshening-relative-foreign-same-path",p142ft_replay_case(path_a,path_a,[one],10,10,True{})),
   p114st_row("freshening-absolute-foreign-path-control",p140p_defs(absolute_a,absolute_b) && p142ft_replay_case(absolute_a,absolute_b,[one],10,10,True{})),
   p114st_row("freshening-projecting-comparator-limit",f_fresh_prefix_exact_defs([index],[projection]) && Bool.not(p140p_defs([index],[projection]))),
   p114st_row("freshening-full-result-counter-sensitive",Bool.not(p142ft_same(FFreshDefs{[one],11},FFreshDefs{[one],12}))),
   p114st_row("freshening-full-result-order-sensitive",Bool.not(p142ft_same(FFreshDefs{[one,two],11},FFreshDefs{[two,one],11})))]
