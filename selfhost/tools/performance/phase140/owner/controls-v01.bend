@unsafe
def p140oc_def(+name: String, +value: KTerm) -> KDef:
  KDef{name,"Def",0,0,kt("ADT","U32",0,0,[]),value,[],False{},False{}}

@unsafe
def p140oc_book(+leaf: U32, +unused: U32) -> List<&2,KDef>:
  book_cached([p140oc_def("main",ref("reader")),p140oc_def("reader",ref("leaf")),
    p140oc_def("leaf",kt("Lit","U32",leaf,0,[])),p140oc_def("unused",kt("Lit","U32",unused,0,[]))],40)

@unsafe
def p140oc_analysis(+old: List<&2,KDef>, +current: List<&2,KDef>) -> P140OAnalysis:
  p140o_analyze(old,current,p140o_edges(p140o_plain(old)))

@unsafe
def p140oc_ready(analysis: P140OAnalysis) -> Bool:
  match analysis:
    case P140OAnalysis{ready,dirty,edges,count}: ready

@unsafe
def p140oc_count(analysis: P140OAnalysis, expected: U32) -> Bool:
  match analysis:
    case P140OAnalysis{ready,dirty,edges,count}: ready && U32.is_eq(count,expected)

@unsafe
def p140oc_cycle(+value: U32) -> List<&2,KDef>:
  book_cached([p140oc_def("main",ref("a")),p140oc_def("a",ref("b")),
    p140oc_def("b",kt("App","",0,0,[ref("a"),kt("Lit","U32",value,0,[])])),
    p140oc_def("other",kt("Lit","U32",99,0,[]))],40)

@unsafe
def p140oc_change_edge(+to: String, +leaf: U32) -> List<&2,KDef>:
  book_cached([p140oc_def("main",ref("reader")),p140oc_def("reader",ref(to)),
    p140oc_def("leaf",kt("Lit","U32",leaf,0,[])),p140oc_def("unused",kt("Lit","U32",22,0,[]))],40)

@unsafe
def p140oc_refresh() -> Bool:
  +a = p140oc_change_edge("unused",1)
  +b = p140oc_change_edge("leaf",1)
  +c = p140oc_change_edge("leaf",2)
  p140oc_refresh_step(b,c,p140oc_analysis(a,b))

@unsafe
def p140oc_refresh_step(+b: List<&2,KDef>, +c: List<&2,KDef>, state: P140OAnalysis) -> Bool:
  match state:
    case P140OAnalysis{ready,dirty,edges,count}:
      +next = p140o_analyze(b,c,edges)
      p140oc_count(next,3) && Bool.not(p140o_clean(next,"main")) && p140o_clean(next,"unused")

@unsafe
def p140oc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":fail")

@unsafe
def p140o_controls() -> List<&2,String>:
  +old = p140oc_book(1,8)
  +same = p140oc_analysis(old,p140oc_book(1,8))
  +leaf = p140oc_analysis(old,p140oc_book(2,8))
  +other = p140oc_analysis(old,p140oc_book(1,9))
  +cycle = p140oc_analysis(p140oc_cycle(1),p140oc_cycle(2))
  +foreign_a = book_cached([p140oc_def("foreign",kt("Foreign","c",0,0,[]))],40)
  +foreign_b = book_cached([p140oc_def("foreign",kt("Foreign","other",0,0,[]))],40)
  +header_a = book_cached([p140oc_def("head",ref("leaf"))],40)
  +header_b = book_cached([KDef{"head","Def",1,0,kt("ADT","U32",0,0,[]),ref("leaf"),[],False{},False{}}],40)
  [p140oc_row("no-op-zero-dirty",p140oc_count(same,0)),
   p140oc_row("unchanged-owner-admitted",p140o_clean(same,"main")),
   p140oc_row("changed-leaf-three-dirty",p140oc_count(leaf,3)),
   p140oc_row("transitive-caller-invalidated",Bool.not(p140o_clean(leaf,"main"))),
   p140oc_row("unrelated-owner-remains-clean",p140o_clean(leaf,"unused")),
   p140oc_row("irrelevant-edit-retains-main",p140oc_count(other,1) && p140o_clean(other,"main")),
   p140oc_row("cycle-propagates-to-fixed-point",p140oc_count(cycle,3) && p140o_clean(cycle,"other")),
   p140oc_row("new-edge-retained-for-next-revision",p140oc_refresh()),
   p140oc_row("different-bound-refused",Bool.not(p140oc_ready(p140oc_analysis(old,book_cached(p140o_plain(old),41))))),
   p140oc_row("changed-header-refused",Bool.not(p140oc_ready(p140oc_analysis(header_a,header_b)))),
   p140oc_row("foreign-body-refused",Bool.not(p140oc_ready(p140oc_analysis(foreign_a,foreign_b)))),
   p140oc_row("inserted-name-refused",Bool.not(p140oc_ready(p140oc_analysis(old,book_cached(Con{p140oc_def("new",ref("main")),p140o_plain(old)},40))))),
   p140oc_row("missing-graph-refused",Bool.not(p140oc_ready(p140o_analyze(old,old,[])))),
   p140oc_row("empty-cache-falls-back",Bool.not(p140oc_ready(p140o_analyze([],old,[])))),
   p140oc_row("static-word-change-refused",Bool.not(p140or_words([P112SRaw{1}],[P112SRaw{2}]))),
   p140oc_row("static-offset-change-refused",Bool.not(p140or_words([P112SBox{"SCon",4}],[P112SBox{"SCon",6}]))),
   p140oc_row("static-kind-change-refused",Bool.not(p140or_words([P112SPacked{"One",4}],[P112SBox{"One",4}]))),
   p140oc_row("same-static-nodes-admitted",p140or_nodes([P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{2}]}],[P112SNode{0,"Pair",[P112SRaw{1},P112SRaw{2}]}]))]
