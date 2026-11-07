# Finite structural controls and complete real-checker results. No claim of
# source checking, execution, or correctness is made by this prepared file.
type P175PDState is Data:
  P175PDState{+book: List<&2,KDef>, +dirty: Bool}
type P175PDObservation is Data:
  P175PDObservation{+baseline: List<&2,KDef>, +candidate: List<&2,KDef>,
    +baselineFamilies: List<&2,String>, +candidateFamilies: List<&2,String>,
    +baselineConstructors: List<&2,Bool>, +candidateConstructors: List<&2,Bool>}
type P175PDParsed is Data:
  P175PDParsed{+parseError: String, +checked: DChecking}

law p175pd_steps:
  for +old: P175PDState
  for +candidate: P175PDState
  for updates: List<&2,KDef>
  for +names: List<&2,String>
  List<&2,P175PDObservation>
law p175pd_fill:
  for n: U32
  List<&2,KDef>

# Frozen original publication decision, with only its continuation replaced by
# a state record for complete per-update observations.
@unsafe
def p175pd_original(state: P175PDState, +definition: KDef) -> P175PDState:
  match state:
    case P175PDState{+book,+dirty}:
      match book:
        case Nil{}: P175PDState{book_put(book,definition),False{}}
        case Con{+cache,+tail}:
          nt_choose(P175PDState,p88_string_eq(dk(cache),"BookCache") &&
            p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
            u => P175PDState{p143cp_logged(cache,tail,definition),True{}},
            u => P175PDState{book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{}})

# Same isolated transition as the overlay. The actual full-checker observations
# below call p156cp_start, so they exercise the override rather than this copy.
@unsafe
def p175pd_candidate(state: P175PDState, +definition: KDef) -> P175PDState:
  match state:
    case P175PDState{+book,+dirty}:
      match book:
        case Nil{}: P175PDState{book_put(book,definition),False{}}
        case Con{+cache,+tail}:
          nt_choose(P175PDState,p88_string_eq(dk(cache),"BookCache") &&
            p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
            u => P175PDState{p143cp_logged(cache,tail,definition),True{}},
            u => nt_choose(P175PDState,dirty && p88_string_eq(dk(cache),"BookCache") && Bool.not(p88_string_eq(dk(definition),"BookCache")),
              u => P175PDState{book_put(book,definition),True{}},
              u => P175PDState{book_put(nt_choose(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{}}))

@unsafe
def p175pd_families(+book: List<&2,KDef>, names: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: Nil{}
    case Con{head,rest}: Con{dg_family(book,head),p175pd_families(book,rest)}

@unsafe
def p175pd_constructors(+book: List<&2,KDef>, names: List<&2,String>) -> List<&2,Bool>:
  match names:
    case Nil{}: Nil{}
    case Con{head,rest}: Con{constructor_exists(book,head),p175pd_constructors(book,rest)}

@unsafe
def p175pd_observe(old: P175PDState, candidate: P175PDState, +names: List<&2,String>) -> P175PDObservation:
  match old candidate:
    case P175PDState{+a,da} P175PDState{+b,db}:
      P175PDObservation{p143cp_canon(a),p143cp_canon(b),
        p175pd_families(a,names),p175pd_families(b,names),
        p175pd_constructors(a,names),p175pd_constructors(b,names)}

@unsafe
def p175pd_steps(old,candidate,updates,names):
  match updates:
    case Nil{}: [p175pd_observe(old,candidate,names)]
    case Con{+head,rest}:
      Con{p175pd_observe(old,candidate,names),
        p175pd_steps(p175pd_original(old,head),p175pd_candidate(candidate,head),rest,names)}

@unsafe
def p175pd_def(name: String, value: KTerm) -> KDef:
  KDef{name,"Def",0,0,typ(1),value,[],False{},False{}}

@unsafe
def p175pd_type(+name: String, ctor: String) -> KDef:
  KDef{name,"ADT",0,0,typ(1),atom("Absent"),
    [KDef{ctor,"Ctr",0,0,ref(name),atom("Absent"),[],False{},False{}}],False{},False{}}

@unsafe
def p175pd_fill(n):
  match n:
    case 0: []
    case +k: Con{p175pd_def("name" ++ U32.show(k),typ(0)),p175pd_fill(U32.sub(k,1))}

@unsafe
def p175pd_controls() -> List<&2,List<&2,P175PDObservation>>:
  +a = p175pd_type("A","Old")
  +b = p175pd_type("B","Both")
  +f = p175pd_def("f",atom("Absent"))
  +seed = book_cached([f,a,b],99)
  +names : List<&2,String> = ["Old","New","Both","missing",""]
  +events : List<&2,KDef> = [p175pd_def("f",typ(0)),p175pd_def("f",typ(1)),
    p175pd_type("A","New"),p175pd_def("f",typ(0)),p175pd_type("B","Old"),
    p175pd_def("A",typ(0)),p175pd_type("A","Both"),p175pd_type("B","New")]
  +large = book_cached(Con{f,Con{a,p175pd_fill(257)}},101)
  [p175pd_steps(P175PDState{seed,False{}},P175PDState{seed,False{}},events,names),
   p175pd_steps(P175PDState{large,False{}},P175PDState{large,False{}},events,names),
   p175pd_steps(P175PDState{[f,a,b],False{}},P175PDState{[f,a,b],False{}},events,names),
   p175pd_steps(P175PDState{[],False{}},P175PDState{[],False{}},events,names),
   p175pd_steps(P175PDState{book_cached([p175pd_def("",typ(0)),a],0),False{}},
     P175PDState{book_cached([p175pd_def("",typ(0)),a],0),False{}},
     [p175pd_def("",typ(1)),p175pd_type("A","New"),p175pd_def("",typ(0))],names),
   p175pd_steps(P175PDState{book_cached([p175pd_def("costarring",typ(0)),p175pd_def("liquid",typ(0)),a],7),False{}},
     P175PDState{book_cached([p175pd_def("costarring",typ(0)),p175pd_def("liquid",typ(0)),a],7),False{}},
     [p175pd_def("costarring",typ(1)),p175pd_type("A","New"),p175pd_def("liquid",typ(1)),p175pd_type("A","Old")],names)]

# Actual checker path: its existing p143cp_result is required for both normal
# and failure worlds. Compare complete DChecking across separately checked APIs.
@unsafe
def p175pd_check(+events: List<&2,KDef>, +bound: U32) -> DChecking:
  +seed = book_cached([],bound)
  p143cp_result(p156cp_start(p143cs_plan(events),
    kw_seed(check_declarations(events,seed),bound),seed,True{}),True{})

@unsafe
def p175pd_check_observe() -> List<&2,DChecking>:
  +signature = p175pd_def("f",atom("Absent"))
  +fill = p175pd_def("f",typ(0))
  +a = p175pd_type("A","Old")
  +b = p175pd_type("B","New")
  [p175pd_check([signature,fill,a,p175pd_def("g",typ(0)),b],127),
   p175pd_check([signature,fill,a,p175pd_def("g",typ(0)),p175pd_type("B","Old")],127),
   p175pd_check([signature,fill,a,fill],127),
   p175pd_check([signature,fill,a,p175pd_def("bad",ref("unknown"))],127),
   p175pd_check([signature,fill,a,p175pd_def("bad",kt("Ctr","New",0,1,[])),b],127),
   p175pd_check([signature,fill,a],4294967295),
   p175pd_check([],0)]

# Every stream has >256 distinct ordinary definitions before its interesting
# success/error boundary, exercising the large final canonicalizer. These call
# the private compact checker explicitly rather than relying on size admission.
@unsafe
def p175pd_large_check_observe() -> List<&2,DChecking>:
  +prefix = p175pd_fill(257)
  +signature = p175pd_def("f",atom("Absent"))
  +fill = p175pd_def("f",typ(0))
  +a = p175pd_type("A","Old")
  +b = p175pd_type("B","New")
  [p175pd_check(List.append(&2,KDef,prefix,[signature,fill,a,p175pd_def("g",typ(0)),b]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,a,fill,p175pd_def("g",typ(0)),b]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,a,p175pd_def("f",typ(1))]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,fill,a,p175pd_def("g",typ(0)),p175pd_type("B","Old")]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,fill,a,fill]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,fill,a,p175pd_def("bad",ref("unknown"))]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,fill,a,p175pd_def("bad",kt("Ctr","New",0,1,[])),b]),127),
   p175pd_check(List.append(&2,KDef,prefix,[signature,fill,a]),4294967295)]

# A literal negative control for the previously rejected blanket ADT log:
# each side must return constructors [False,True] and families ["","A"].
# This is not just
# agreement between two copies of an algorithm that might share the same bug.
@unsafe
def p175pd_stale_adt() -> P175PDObservation:
  +seed = book_cached([p175pd_def("f",atom("Absent")),p175pd_type("A","Old")],0)
  +old = p175pd_original(p175pd_original(P175PDState{seed,False{}},p175pd_def("f",typ(0))),p175pd_type("A","New"))
  +candidate = p175pd_candidate(p175pd_candidate(P175PDState{seed,False{}},p175pd_def("f",typ(0))),p175pd_type("A","New"))
  p175pd_observe(old,candidate,["Old","New"])

# Accept source fixtures without discarding parse errors; host controls compare
# the entire parsed error plus DChecking, including the ordered book and index.
@unsafe
def p175pd_text(text: String) -> P175PDParsed:
  match f_load_graph("Unit",[FSource{"Unit","/phase175-publication.bend",text}]):
    case FResult{+book,error,imports}:
      P175PDParsed{error,p175pd_check(book,norm_max_book(book))}
