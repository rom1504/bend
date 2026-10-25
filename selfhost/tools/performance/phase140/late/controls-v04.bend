def p140lc_function(name: String, value: U32) -> P113DFunction:
  P113DFunction{name,[],1,True{},[P113DResult{[N111Const{value,0}]}]}

@unsafe
def p140lc_item(+name: String, mode: U32, fallback: List<&2,P113DFunction>) -> P140LItem:
  P140LItem{name,no_plan_refuse(name,"finite control"),mode,P118BWorkers{[],""},fallback}

@unsafe
def p140lc_dirty(name: String) -> KDef:
  p140lc_dirty_result(p140o_mark(name,P140ODirty{missing(),0}))

def p140lc_dirty_result(dirty: P140ODirty) -> KDef:
  match dirty:
    case P140ODirty{names,count}: names

@unsafe
def p140lc_counts(result: P140LResult, hits: U32, misses: U32) -> Bool:
  match result:
    case P140LResult{scan,cache,stats}: p134v_list(U32,U32.is_eq,p140lc_pair(stats),[hits,misses])

def p140lc_pair(stats: List<&2,U32>) -> List<&2,U32>:
  match stats:
    case Con{h,Con{m,rest}}: [h,m]
    case _: []

@unsafe
def p140lc_cache(result: P140LResult) -> P140LCache:
  match result:
    case P140LResult{scan,cache,stats}: cache

@unsafe
def p140lc_book(value: U32) -> List<&2,KDef>:
  book_cached([
    KDef{"main","Control",0,0,atom("Data"),ref("leaf"),[],False{},False{}},
    KDef{"leaf","Control",0,0,atom("Data"),KLiteral{"U32",value,"",0,0},[],False{},False{}},
    KDef{"other","Control",0,0,atom("Data"),atom("Absent"),[],False{},False{}}],40)

# An unrelated nullary constructor result unfolds an editable alias. The
# catalogue changes although the selected main owner's dependency closure does
# not mention Alias/Hidden; source headers remain byte-identical.
@unsafe
def p140lc_global_book(+target: String) -> List<&2,KDef>:
  book_cached([
    KDef{"main","Control",0,0,atom("Data"),atom("Absent"),[],False{},False{}},
    KDef{"Alias","Def",0,0,atom("Data"),kt("ADT",target,0,0,[]),[],False{},False{}},
    KDef{"Hidden","ADT",0,0,atom("Data"),atom("Absent"),
      [KDef{"Hidden0","Ctr",0,0,ref("Alias"),atom("Absent"),[],False{},False{}}],False{},False{}},
    KDef{"Other","ADT",0,0,atom("Data"),atom("Absent"),[],False{},False{}}],40)

@unsafe
def p140lc_hidden_book(value: U32, target: String) -> List<&2,KDef>:
  ns_attach_book(book_cached([
    KDef{"main","Control",0,0,atom("Data"),atom("Absent"),[],False{},False{}},
    KDef{"H","Control",0,0,atom("Data"),KLiteral{"U32",value,"",0,0},[],False{},False{}},
    KDef{"G","Control",0,0,atom("Data"),KLiteral{"U32",9,"",0,0},[],False{},False{}}],40),
    [KDef{"main","NativeErasedBody",0,0,atom("Absent"),ref(target),[],False{},False{}}],0,[])

@unsafe
def p140lc_controls() -> List<&2,String>:
  +hidden_a = p140lc_hidden_book(1,"H")
  +hidden_b = p140lc_hidden_book(1,"G")
  +hidden_cache = p140lc_cache(p140l_scan(hidden_a,["main"],[],p140l_empty()))
  +hidden_next = p140lc_cache(p140l_scan(hidden_b,["main"],[],hidden_cache))
  +global_a = p140lc_global_book("Hidden")
  +global_b = p140lc_global_book("Other")
  +global_cache = p140lc_cache(p140l_scan(global_a,["main"],[],p140l_empty()))
  +spec : NO_Spec = NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A","B"]}
  +empty = missing()
  +name = p113d_public([],"f")
  +a = p140lc_function(name,1)
  +b = p140lc_function(name,2)
  +other = p140lc_function("unrelated",9)
  +none = p140lc_item("f",0,[])
  +scalar = p140lc_item("f",2,[a])
  +absent = p140lc_item("f",2,[])
  +book = p140lc_book(1)
  +names : List<&2,String> = ["main","leaf","other"]
  +cold = p140l_scan(book,names,[],p140l_empty())
  +prior = p140lc_cache(cold)
  [p114st_row("late-hidden-fact-reference-invalidates",p140lc_counts(p140l_scan(p140lc_hidden_book(2,"H"),["main"],[],hidden_cache),0,1)),
   p114st_row("late-hidden-fact-edit-invalidates",p140lc_counts(p140l_scan(hidden_b,["main"],[],hidden_cache),0,1)),
   p114st_row("late-hidden-fact-edge-removal-retained",p140lc_counts(p140l_scan(p140lc_hidden_book(2,"G"),["main"],[],hidden_next),1,0)),
   p114st_row("late-global-alias-changes-catalogue",Bool.not(p134v_list(NO_Spec,p140l_spec,nol_scalar_specs(global_a,global_a),nol_scalar_specs(global_b,global_b)))),
   p114st_row("late-global-alias-invalidates-unrelated-owner",p140lc_counts(p140l_scan(global_b,["main"],[],global_cache),0,1)),
   p114st_row("late-spec-identical",p140l_spec(spec,spec)),
   p114st_row("late-spec-key",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"other","ctor","Boxed",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-ctor",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","other","Boxed",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-storage",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Nullary",2},"Owner",["A","B"]}))),
   p114st_row("late-spec-width",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",1},"Owner",["A","B"]}))),
   p114st_row("late-spec-owner",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Other",["A","B"]}))),
   p114st_row("late-spec-type-order",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["B","A"]}))),
   p114st_row("late-spec-type-length",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A"]}))),
   p114st_row("late-spec-type-name",Bool.not(p140l_spec(spec,NO_Spec{NO_Layout{"key","ctor","Boxed",2},"Owner",["A","C"]}))),
   p114st_row("late-refusal-reuses",p140l_hit([],"f",[],True{},empty,none)),
   p114st_row("late-unready-refuses",Bool.not(p140l_hit([],"f",[],False{},empty,none))),
   p114st_row("late-owner-name-refuses",Bool.not(p140l_hit([],"g",[],True{},empty,none))),
   p114st_row("late-dirty-refuses",Bool.not(p140l_hit([],"f",[],True{},p140lc_dirty("f"),none))),
   p114st_row("late-unrelated-dirty-reuses",p140l_hit([],"f",[],True{},p140lc_dirty("g"),none)),
   p114st_row("late-scalar-exact-fallback",p140l_hit([],"f",[a],True{},empty,scalar)),
   p114st_row("late-scalar-body-change",Bool.not(p140l_hit([],"f",[b],True{},empty,scalar))),
   p114st_row("late-scalar-missing-fallback",Bool.not(p140l_hit([],"f",[],True{},empty,scalar))),
   p114st_row("late-scalar-new-fallback",Bool.not(p140l_hit([],"f",[a],True{},empty,absent))),
   p114st_row("late-scalar-unchanged-absence",p140l_hit([],"f",[other],True{},empty,absent)),
   p114st_row("late-scalar-unrelated-body",p140l_hit([],"f",[other,a],True{},empty,scalar)),
   p114st_row("late-scalar-first-duplicate",p140l_hit([],"f",[a,b],True{},empty,scalar)),
   p114st_row("late-scalar-changed-first-duplicate",Bool.not(p140l_hit([],"f",[b,a],True{},empty,scalar))),
   p114st_row("late-cold-misses",p140lc_counts(cold,0,3)),
   p114st_row("late-same-book-hits",p140lc_counts(p140l_scan(book,names,[],prior),3,0)),
   p114st_row("late-transitive-body-edit",p140lc_counts(p140l_scan(p140lc_book(2),names,[],prior),1,2)),
   p114st_row("late-owner-order-refuses",p140lc_counts(p140l_scan(book,["leaf","main","other"],[],prior),0,3)),
   p114st_row("late-bound-change-refuses",p140lc_counts(p140l_scan(book_cached(p140o_plain(book),41),names,[],prior),0,3))]
