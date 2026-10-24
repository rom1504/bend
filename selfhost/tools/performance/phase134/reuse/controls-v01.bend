@unsafe
def p134urc_def(+name: String, value: KTerm) -> KDef:
  KDef{name,"Def",0,0,atom("Typ"),value,[],False{},True{}}

@unsafe
def p134urc_word(value: U32) -> KTerm:
  kt("NWord","",value,0,[])

@unsafe
def p134urc_book(+first: U32, +second: U32) -> List<&2,KDef>:
  [p134urc_def("keep",p134urc_word(first)),p134urc_def("edit",p134urc_word(second))]

# Observation includes exact fresh/error and all QBE program metadata, not
# merely an instruction count. Production admission is not bypassed: these
# are data-level tests of an isolated lowering boundary.
@unsafe
def p134urc_observe(book: P111Book) -> String:
  match book:
    case P111Book{segments,fresh,error}:
      U32.show(fresh) ++ ":" ++ error ++ ":" ++
        p111q_text(P111Program{segments,nc_default_ctors(),[],[],[],False{}})

@unsafe
def p134urc_same(+book: List<&2,KDef>, +names: List<&2,String>, +bangs: List<&2,String>, +n: U32, cached: P134URResult) -> Bool:
  String.eq(p134urc_observe(p134ur_book(cached)),p134urc_observe(p111_compile_defs(book,names,bangs,n,[])))

@unsafe
def p134urc_stats(result: P134URResult, +hits: U32, +lowered: U32, +refused: U32, +freshMiss: U32, +keyMiss: U32) -> Bool:
  match result:
    case P134URResult{book,slots,P134URStats{h,l,r,f,k}}:
      U32.is_eq(h,hits) && U32.is_eq(l,lowered) && U32.is_eq(r,refused) && U32.is_eq(f,freshMiss) && U32.is_eq(k,keyMiss)

@unsafe
def p134urc_mutate_slots(+book: List<&2,KDef>, slots: List<&2,P134URSlot>) -> List<&2,P134URSlot>:
  match slots:
    case Con{first,Con{P134URCached{key,code},Nil{}}}:
      [first,P134URCached{p134ur_key(book,"edit",p134urc_word(12),1024,False{}),code}]
    case _: []

@unsafe
def p134urc_row(+name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => ":pass",u => ":FAIL")

@unsafe
def p134ur_controls() -> List<&2,String>:
  +a = p134urc_book(7,11)
  +b = p134urc_book(7,12)
  +names : List<&2,String> = ["keep","edit"]
  +cold = p134ur_run(a,names,[],0,[])
  +cache = p134ur_slots(cold)
  +noop = p134ur_run(a,names,[],0,cache)
  +edit = p134ur_run(b,names,[],0,cache)
  +fresh = p134ur_run(a,names,[],1,cache)
  +reordered = p134ur_run(a,["edit","keep"],[],0,cache)
  +bang = p134ur_run(a,names,["keep"],0,cache)
  +dependent : List<&2,KDef> = [p134urc_def("keep",kt("Ref","edit",0,0,[])),p134urc_def("edit",p134urc_word(11))]
  +refused = p134ur_run(dependent,names,[],0,cache)
  +mutated = p134ur_run(b,names,[],0,p134urc_mutate_slots(b,cache))
  [p134urc_row("cold-exact",p134urc_same(a,names,[],0,cold)),
   p134urc_row("cold-lowers-two",p134urc_stats(cold,0,2,0,0,0)),
   p134urc_row("noop-exact",p134urc_same(a,names,[],0,noop)),
   p134urc_row("noop-skips-two-lowerings",p134urc_stats(noop,2,0,0,0,0)),
   p134urc_row("real-body-edit-exact",p134urc_same(b,names,[],0,edit)),
   p134urc_row("real-body-edit-unrelated-owner-hit",p134urc_stats(edit,1,1,0,0,1)),
   p134urc_row("fresh-counter-change-exact",p134urc_same(a,names,[],1,fresh)),
   p134urc_row("fresh-counter-change-misses",p134urc_stats(fresh,0,2,0,2,0)),
   p134urc_row("order-change-exact",p134urc_same(a,["edit","keep"],[],0,reordered)),
   p134urc_row("order-change-misses",p134urc_stats(reordered,0,2,0,0,2)),
   p134urc_row("bang-change-exact",p134urc_same(a,names,["keep"],0,bang)),
   p134urc_row("bang-change-misses-owner",p134urc_stats(bang,1,1,0,0,1)),
   p134urc_row("unknown-context-fallback-exact",p134urc_same(dependent,names,[],0,refused)),
   p134urc_row("unknown-context-refused",p134urc_stats(refused,1,1,1,0,0)),
   p134urc_row("missing-owner-error-exact",p134urc_same(a,["missing"],[],0,p134ur_run(a,["missing"],[],0,cache))),
   p134urc_row("empty-owner-list-exact",p134urc_same(a,[],[],0,p134ur_run(a,[],[],0,cache))),
   p134urc_row("static-word-refused",Bool.not(p134ur_closed([kt("NStatic","",0,0,[])]))),
   p134urc_row("constructor-refused",Bool.not(p134ur_closed([kt("NCtr","Tuple",0,0,[])]))),
   p134urc_row("matcher-refused",Bool.not(p134ur_closed([kt("Mat","Tuple",0,0,[])]))),
   p134urc_row("nested-global-ref-refused",Bool.not(p134ur_closed([kt("Let","",0,0,[kt("Ref","edit",0,0,[])])]))),
   p134urc_row("body-mutation-oracle-detects-stale-result",Bool.not(p134urc_same(b,names,[],0,mutated)))]
