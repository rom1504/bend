# Diagnostic-only copies of actual selected queries. No production override.
# Counts are logical list visits, not CPU samples, allocations or RC operations.
# BookCache delegates retain exact index_lookup semantics; delegated tree work
# is explicitly counted as unknown rather than pretending to cost zero.
type P136QFind is Data:
  P136QFind{+definition: KDef, +rows: U32, +names: U32, +delegations: U32}

type P136QOwned is Data:
  P136QOwned{+owned: Bool, +book_rows: U32, +child_rows: U32, +names: U32, +delegations: U32}

type P136QSummary is Data:
  P136QSummary{+queries: U32, +find_rows: U32, +lookup_rows: U32, +owner_rows: U32, +child_rows: U32, +name_tests: U32, +delegations: U32, +exact: Bool}

@unsafe
def p136q_find(+name: String, book: List<&2,KDef>) -> P136QFind:
  p136q_find_go(name,book,0)

@unsafe
def p136q_find_go(+name: String, book: List<&2,KDef>, +rows: U32) -> P136QFind:
  match book:
    case Nil{}: P136QFind{f_find(name,[]),rows,rows,0}
    case Con{+d,+rest}:
      p136q_find_next(name,d,rest,U32.add(rows,1),f_eq(name,dn(d)))

@unsafe
def p136q_find_next(+name: String, d: KDef, rest: List<&2,KDef>, +rows: U32, same: Bool) -> P136QFind:
  match same:
    case True{}: P136QFind{d,rows,rows,0}
    case False{}: p136q_find_go(name,rest,rows)

@unsafe
def p136q_lookup(book: List<&2,KDef>, name: String) -> P136QFind:
  p136q_lookup_go(book,name,0,0)

@unsafe
def p136q_lookup_go(book: List<&2,KDef>, +name: String, rows: U32, names: U32) -> P136QFind:
  match book:
    case Nil{}: P136QFind{missing(),rows,names,0}
    case Con{+d,+rest}:
      p136q_lookup_cache(d,rest,name,U32.add(rows,1),names,p88_string_eq(dk(d),"BookCache"))

@unsafe
def p136q_lookup_cache(+d: KDef, rest: List<&2,KDef>, +name: String, rows: U32, names: U32, cached: Bool) -> P136QFind:
  match cached:
    case True{}: P136QFind{index_lookup(d,name),rows,names,1}
    case False{}: p136q_lookup_name(d,rest,name,rows,U32.add(names,1),p88_string_eq(dn(d),name))

@unsafe
def p136q_lookup_name(d: KDef, rest: List<&2,KDef>, name: String, rows: U32, names: U32, same: Bool) -> P136QFind:
  match same:
    case True{}: P136QFind{d,rows,names,0}
    case False{}: p136q_lookup_go(rest,name,rows,names)

@unsafe
def p136q_owned(book: List<&2,KDef>, name: String) -> P136QOwned:
  p136q_owned_go(book,name,0,0,0,0)

@unsafe
def p136q_owned_go(book: List<&2,KDef>, +name: String, rows: U32, children: U32, names: U32, delegations: U32) -> P136QOwned:
  match book:
    case Nil{}: P136QOwned{False{},rows,children,names,delegations}
    case Con{+d,rest}:
      p136q_owned_kind(d,rest,name,U32.add(rows,1),children,names,delegations,p88_string_eq(dk(d),"ADT"))

@unsafe
def p136q_owned_kind(+d: KDef, rest: List<&2,KDef>, +name: String, rows: U32, children: U32, names: U32, delegations: U32, adt: Bool) -> P136QOwned:
  match adt:
    case False{}: p136q_owned_go(rest,name,rows,children,names,delegations)
    case True{}: p136q_owned_child(db(d),rest,name,rows,children,names,delegations,p136q_lookup(dc(d),name))

@unsafe
def p136q_owned_child(owned: Bool, rest: List<&2,KDef>, name: String, rows: U32, children: U32, names: U32, delegations: U32, found: P136QFind) -> P136QOwned:
  match found:
    case P136QFind{definition,child_rows,child_names,child_delegations}:
      p136q_owned_match(owned,rest,name,rows,U32.add(children,child_rows),U32.add(names,child_names),U32.add(delegations,child_delegations),p88_string_eq(dk(definition),"Ctr"))

@unsafe
def p136q_owned_match(owned: Bool, rest: List<&2,KDef>, name: String, rows: U32, children: U32, names: U32, delegations: U32, found: Bool) -> P136QOwned:
  match found:
    case True{}: P136QOwned{owned,rows,children,names,delegations}
    case False{}: p136q_owned_go(rest,name,rows,children,names,delegations)

@unsafe
def p136q_identity(+name: String, result: P136QOwned) -> String:
  match result:
    case P136QOwned{owned,rows,children,names,delegations}:
      kc(String,owned,u => name,u => nc_ctor_encode(name))

@unsafe
def p136q_one(+book: List<&2,KDef>, +name: String) -> P136QSummary:
  p136q_one_values(book,name,p136q_find(name,book),p136q_lookup(book,name),p136q_owned(book,name))

@unsafe
def p136q_one_values(+book: List<&2,KDef>, +name: String, find: P136QFind, found: P136QFind, +owned: P136QOwned) -> P136QSummary:
  match find found owned:
    case P136QFind{fd,fr,fn,fi} P136QFind{ld,lr,ln,li} P136QOwned{+answer,br,cr,cn,ci}:
      P136QSummary{1,fr,lr,br,cr,U32.add(fn,U32.add(ln,cn)),U32.add(fi,U32.add(li,ci)),
        prefix_state_exact_def(fd,f_find(name,book)) && prefix_state_exact_def(ld,lookup(book,name)) &&
        prefix_state_exact_bool(answer,nc_ctor_owned(book,name)) &&
        String.eq(p136q_identity(name,owned),nc_ctor_identity(book,name))}

def p136q_zero() -> P136QSummary:
  P136QSummary{0,0,0,0,0,0,0,True{}}

@unsafe
def p136q_add(a: P136QSummary, b: P136QSummary) -> P136QSummary:
  match a b:
    case P136QSummary{aq,af,al,ao,ac,an,ai,ae} P136QSummary{bq,bf,bl,bo,bc,bn,bi,be}:
      P136QSummary{U32.add(aq,bq),U32.add(af,bf),U32.add(al,bl),U32.add(ao,bo),U32.add(ac,bc),U32.add(an,bn),U32.add(ai,bi),ae && be}

@unsafe
def p136q_queries(+book: List<&2,KDef>, names: List<&2,String>, acc: P136QSummary) -> P136QSummary:
  match names:
    case Nil{}: acc
    case Con{name,rest}: p136q_queries(book,rest,p136q_add(acc,p136q_one(book,name)))

@unsafe
def p136q_take(book: List<&2,KDef>, +count: U32) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{head,rest}: p136q_take_next(head,rest,count,U32.is_eq(count,0))

@unsafe
def p136q_take_next(head: KDef, rest: List<&2,KDef>, count: U32, stop: Bool) -> List<&2,KDef>:
  match stop:
    case True{}: []
    case False{}: Con{head,p136q_take(rest,U32.sub(count,1))}

@unsafe
def p136q_names(book: List<&2,KDef>) -> List<&2,String>:
  match book:
    case Nil{}: []
    case Con{head,rest}: Con{dn(head),p136q_names(rest)}

# Scale actual immutable rows, not invented AST encodings. Pass a raw book for
# name-scan scaling, or an actual prepared book to observe its existing cache.
@unsafe
def p136q_prefix(+book: List<&2,KDef>, count: U32) -> P136QSummary:
  p136q_prefix_ready(p136q_take(book,count))

@unsafe
def p136q_prefix_ready(+book: List<&2,KDef>) -> P136QSummary:
  p136q_queries(book,p136q_names(book),p136q_zero())

@unsafe
def p136q_exact(result: P136QSummary) -> Bool:
  match result:
    case P136QSummary{q,f,l,o,c,n,i,exact}: exact

@unsafe
def p136q_find_rows(result: P136QFind, rows: U32) -> Bool:
  match result:
    case P136QFind{definition,actual,names,delegations}: U32.is_eq(actual,rows)

@unsafe
def p136q_owned_rows(result: P136QOwned, rows: U32, children: U32, delegates: U32, value: Bool) -> Bool:
  match result:
    case P136QOwned{owned,actual,child_rows,names,delegations}:
      U32.is_eq(actual,rows) && U32.is_eq(child_rows,children) && U32.is_eq(delegations,delegates) && prefix_state_exact_bool(owned,value)

def p136q_def(name: String, kind: String, owned: Bool, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},children,owned,False{}}

@unsafe
def p136q_controls() -> List<&2,String>:
  +first = p136q_def("a","Def",False{},[])
  +last = p136q_def("b","Def",False{},[])
  +ctor = p136q_def("C","Ctr",False{},[])
  +plain = p136q_def("Plain","ADT",False{},[ctor])
  +owned = p136q_def("Owned","ADT",True{},[ctor])
  +shadow = p136q_def("Shadow","ADT",True{},[p136q_def("C","Def",False{},[]),ctor])
  +cached = p136q_def("Cached","ADT",True{},book_cached([ctor],0))
  [p114st_row("query-empty",p136q_exact(p136q_one([],"missing"))),
   p114st_row("query-first",p136q_find_rows(p136q_find("a",[first,last]),1)),
   p114st_row("query-last",p136q_find_rows(p136q_find("b",[first,last]),2)),
   p114st_row("query-missing",p136q_find_rows(p136q_find("none",[first,last]),2)),
   p114st_row("query-duplicates",p136q_exact(p136q_one([first,p136q_def("a","ADT",True{},[])],"a"))),
   p114st_row("query-bookcache",p136q_exact(p136q_one(book_cached([first,last],0),"b"))),
   p114st_row("query-owner-false-first",p136q_owned_rows(p136q_owned([plain,owned],"C"),1,1,0,False{})),
   p114st_row("query-owner-child-shadow",p136q_owned_rows(p136q_owned([shadow,owned],"C"),2,2,0,True{})),
   p114st_row("query-owner-cached-child",p136q_owned_rows(p136q_owned([cached],"C"),1,1,1,True{})),
   p114st_row("query-owner-cached-exact",p136q_exact(p136q_one([cached],"C"))),
   p114st_row("query-owner-missing",p136q_owned_rows(p136q_owned([plain,owned],"X"),2,2,0,False{})),
   p114st_row("query-unicode",p136q_exact(p136q_one([p136q_def("商","ADT",True{},[p136q_def("字","Ctr",False{},[])])],"字"))),
   p114st_row("query-prefix",p136q_exact(p136q_prefix([first,last],2))),
   p114st_row("query-prefix-empty",p136q_exact(p136q_prefix([first,last],0)))]

# Only the ordinary request.source construction supplies this mirror contract.
# Diagnostic caller keeps both raw and cached observations; no optimizer uses it.
@unsafe
def p136q_raw(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+head,rest}:
      kc(List<&2,KDef>,p88_string_eq(dk(head),"BookCache"),u => rest,u => book)

@unsafe
def p136q_child_names(children: List<&2,KDef>, +acc: List<&2,String>) -> List<&2,String>:
  match children:
    case Nil{}: acc
    case Con{+head,+rest}:
      kc(List<&2,String>,p88_string_eq(dk(head),"Ctr"),
        u => p136q_child_names(rest,Con{dn(head),acc}),u => p136q_child_names(rest,acc))

@unsafe
def p136q_ctor_names(book: List<&2,KDef>, +acc: List<&2,String>) -> List<&2,String>:
  match book:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+head,+rest}:
      kc(List<&2,String>,p88_string_eq(dk(head),"ADT"),
        u => p136q_ctor_names(rest,p136q_child_names(dc(head),acc)),u => p136q_ctor_names(rest,acc))

@unsafe
def p136q_take_names(values: List<&2,String>, +count: U32) -> List<&2,String>:
  match values:
    case Nil{}: []
    case Con{head,rest}: p136q_take_names_next(head,rest,count,U32.is_eq(count,0))

@unsafe
def p136q_take_names_next(head: String, rest: List<&2,String>, count: U32, stop: Bool) -> List<&2,String>:
  match stop:
    case True{}: []
    case False{}: Con{head,p136q_take_names(rest,U32.sub(count,1))}
