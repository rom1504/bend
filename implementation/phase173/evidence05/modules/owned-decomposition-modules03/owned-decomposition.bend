# Experimental ordinary owned-field decomposition before QBE ownership lowering.
# Pair summaries are authenticated by owned-decomposition-summary.bend.
type P173OAResult is Data:
  P173OAResult{+term: KTerm, +next: U32, +hits: U32}

type P173OAList is Data:
  P173OAList{+terms: List<&2,KTerm>, +next: U32, +hits: U32}

type P173OABook is Data:
  P173OABook{+index: KDef, +next: U32, +hits: U32}

# Hoisted contracts keep the pinned sequential loader deterministic.
law p173oa_var:
  for +term: KTerm
  for +id: U32
  Bool

law p173oa_atom:
  for +term: KTerm
  for +root: U32
  Bool

law p173oa_atoms:
  for terms: List<&2,KTerm>
  for +root: U32
  Bool

law p173oa_user:
  for +book: List<&2,KDef>
  for +head: KTerm
  for +arity: U32
  Bool

law p173oa_definition:
  for +book: List<&2,KDef>
  for +definition: KDef
  for +arity: U32
  Bool

law p173oa_rename:
  for +term: KTerm
  for ids: List<&2,U32>
  for +next: U32
  KTerm

law p173oa_lambdas:
  for +count: U32
  for +next: U32
  for +body: KTerm
  KTerm

law p173oa_result_fields:
  for +summary: P173ODSummary
  for +row: P173ODRow
  for +next: U32
  for +result: U32
  KTerm

law p173oa_row_body:
  for +summary: P173ODSummary
  for +row: P173ODRow
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  KTerm

law p173oa_row_changed:
  for +summary: P173ODSummary
  for +row: P173ODRow
  Bool

law p173oa_row_width:
  for row: P173ODRow
  U32

law p173oa_row_join:
  for +row: P173ODRow
  for +summary: P173ODSummary
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +start: U32
  for tail: P173OAResult
  P173OAResult

law p173oa_pair_result:
  for +term: KTerm
  for +root: KTerm
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  for pair: Maybe<&2,P173ODSummary>
  P173OAResult

law p173oa_summary_result:
  for +term: KTerm
  for +root: KTerm
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  for +summary: P173ODSummary
  P173OAResult

law p173oa_ids_fresh:
  for ids: List<&2,U32>
  for +next: U32
  Bool

law p173oa_rows_fresh:
  for rows: List<&2,P173ODRow>
  for +next: U32
  Bool

law p173oa_apply_rows:
  for +original: KTerm
  for +root: KTerm
  for +start: U32
  for built: P173OAResult
  P173OAResult

law p173oa_getter:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +call: KTerm
  for +getter: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  P173OAResult

law p173oa_call:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +value: KTerm
  for +next: U32
  P173OAResult

law p173oa_getter_args:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +call: KTerm
  for +head: KTerm
  for +other: List<&2,KTerm>
  for +next: U32
  for args: List<&2,KTerm>
  P173OAResult

law p173oa_call_args:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +head: KTerm
  for +next: U32
  for +args: List<&2,KTerm>
  P173OAResult

law p173oa_try:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  P173OAResult

law p173oa_application:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  for +setter: KTerm
  for args: List<&2,KTerm>
  P173OAResult

law p173oa_tried:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +fuel: U32
  for tried: P173OAResult
  P173OAResult

law p173oa_rebuild:
  for +term: KTerm
  for children: P173OAList
  P173OAResult

law p173oa_first:
  for +book: List<&2,KDef>
  for +rest: List<&2,KTerm>
  for +fuel: U32
  for first: P173OAResult
  P173OAList

law p173oa_cons:
  for term: KTerm
  for hits: U32
  for rest: P173OAList
  P173OAList

law p173oa_definition_done:
  for +book: List<&2,KDef>
  for +prepared: List<&2,KDef>
  for +rest: List<&2,String>
  for +index: KDef
  for +hits: U32
  for +fact: KDef
  for result: P173OAResult
  P173OABook

law p173oa_context:
  for context: KDef
  for index: KDef
  KDef

law p173oa_publish:
  for prepared: List<&2,KDef>
  for changed: P173OABook
  List<&2,KDef>

law p173oa_pure_names:
  for +book: List<&2,KDef>
  for names: List<&2,String>
  Bool

law p173oa_walk:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +next: U32
  for +fuel: U32
  P173OAResult

law p173oa_terms:
  for +book: List<&2,KDef>
  for terms: List<&2,KTerm>
  for +next: U32
  for +fuel: U32
  P173OAList

law p173oa_rows:
  for rows: List<&2,P173ODRow>
  for +summary: P173ODSummary
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +fallback: KTerm
  for +next: U32
  P173OAResult

law p173oa_definitions:
  for +book: List<&2,KDef>
  for +prepared: List<&2,KDef>
  for names: List<&2,String>
  for +index: KDef
  for +next: U32
  for +hits: U32
  P173OABook

@unsafe
def p173oa_var(term, id):
  p98_tag_eq(term,"Var") && U32.is_eq(ix(term),id) && List.is_empty(&2,KTerm,ks(term))

# The initial composition accepts only already evaluated external arguments.
# Root identity may not occur in another argument or in a call head.
@unsafe
def p173oa_atom(term, root):
  nt_choose(Bool,p98_tag_eq(term,"Var"),u => List.is_empty(&2,KTerm,ks(term)) && Bool.not(U32.is_eq(ix(term),root)),
    u => p98_tag_eq(term,"NWord") || p98_tag_eq(term,"NStatic"))

@unsafe
def p173oa_atoms(terms, root):
  match terms:
    case Nil{}: True{}
    case Con{head,rest}: p173oa_atom(head,root) && p173oa_atoms(rest,root)

@unsafe
def p173oa_user(book, head, arity):
  nt_choose(Bool,p98_tag_eq(head,"Ref") && List.is_empty(&2,KTerm,ks(head)) && Bool.not(U32.is_eq(qt(head),3)),
    u => p173oa_definition(book,lookup(book,nm(head)),arity),u => False{})

@unsafe
def p173oa_definition(book, definition, arity):
  String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)) &&
    U32.is_eq(nd_arity(book,dn(definition)),arity)

# Replace only field-variable identities. Fresh replacements are disjoint from
# every source binder; no beta reduction or normalization is performed.
@unsafe
def p173oa_rename(term, ids, next):
  match ids:
    case Nil{}: term
    case Con{id,rest}: p173oa_rename(nq_layout_subst(term,id,var("",next)),rest,U32.inc(next))

@unsafe
def p173oa_lambdas(count, next, body):
  nt_choose(KTerm,U32.is_eq(count,0),u => body,
    u => k_lam("",next,2,[p173oa_lambdas(U32.sub(count,1),U32.inc(next),body)],0,0,False{}))

@unsafe
def p173oa_result_fields(summary, row, next, result):
  match summary row:
    case P173ODSummary{getterRoot,setterRoot,replacement,rows}
      P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue}:
      nq_layout_subst(p173oa_rename(setterValue,setterFields,next),replacement,var("",result))

@unsafe
def p173oa_row_body(summary, row, call, other, next):
  match row:
    case P173ODRow{ctor,+count,mask,getterFields,getterValue,setterFields,setterValue}:
      +result = U32.add(next,count)
      nc_mklet(result,nd_reapply(call,Con{p173oa_rename(getterValue,getterFields,next),other}),
        p173oa_result_fields(summary,row,next,result))

@unsafe
def p173oa_row_changed(summary, row):
  match summary row:
    case P173ODSummary{getterRoot,setterRoot,replacement,rows}
      P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue}:
      Bool.not(p173oa_var(setterValue,setterRoot)) && nu_has(nc_uses(setterValue),replacement)

@unsafe
def p173oa_rows(rows, summary, call, other, fallback, next):
  match rows:
    case Nil{}: P173OAResult{fallback,next,0}
    case Con{+row,+rest}:
      nt_choose(P173OAResult,p173oa_row_changed(summary,row),
        u => p173oa_row_join(row,summary,call,other,next,
          p173oa_rows(rest,summary,call,other,fallback,U32.add(next,U32.inc(p173oa_row_width(row))))),
        u => p173oa_rows(rest,summary,call,other,fallback,next))

@unsafe
def p173oa_row_width(row):
  match row:
    case P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue}: count

@unsafe
def p173oa_row_join(row, summary, call, other, start, tail):
  match row tail:
    case P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue}
      P173OAResult{rest,next,hits}:
      P173OAResult{kt("Mat",ctor,U32.inc(count),mask,
        [p173oa_lambdas(count,start,p173oa_row_body(summary,row,call,other,start)),rest]),next,U32.inc(hits)}

@unsafe
def p173oa_pair_result(term, root, call, other, next, pair):
  match pair:
    case None{}: P173OAResult{term,next,0}
    case Some{+summary}:
      p173oa_summary_result(term,root,call,other,next,summary)

@unsafe
def p173oa_summary_result(term, root, call, other, next, summary):
  match summary:
    case P173ODSummary{getterRoot,setterRoot,replacement,rows}:
      nt_choose(P173OAResult,U32.is_lt(norm_max_term(term),next) && U32.is_lt(getterRoot,next) && U32.is_lt(setterRoot,next) &&
        U32.is_lt(replacement,next) && p173oa_rows_fresh(rows,next),
        u => p173oa_apply_rows(term,root,next,p173oa_rows(rows,summary,call,other,
          k_lam("",next,2,[nq_layout_subst(term,ix(root),var("",next))],0,0,False{}),U32.inc(next))),
        u => P173OAResult{term,next,0})

@unsafe
def p173oa_ids_fresh(ids, next):
  match ids:
    case Nil{}: True{}
    case Con{id,rest}: U32.is_lt(id,next) && p173oa_ids_fresh(rest,next)

@unsafe
def p173oa_rows_fresh(rows, next):
  match rows:
    case Nil{}: True{}
    case Con{P173ODRow{ctor,count,mask,getterFields,getterValue,setterFields,setterValue},rest}:
      p173oa_ids_fresh(getterFields,next) && p173oa_ids_fresh(setterFields,next) &&
        U32.is_lt(norm_max_term(getterValue),next) && U32.is_lt(norm_max_term(setterValue),next) &&
        p173oa_rows_fresh(rest,next)

@unsafe
def p173oa_apply_rows(original, root, start, built):
  match built:
    case P173OAResult{matcher,next,+hits}:
      nt_choose(P173OAResult,U32.is_gt(hits,0),
        u => P173OAResult{app(matcher,root),next,hits},u => P173OAResult{original,start,0})

@unsafe
def p173oa_getter(book, term, setter, root, call, getter, other, next):
  p173oa_getter_args(book,term,setter,root,call,nd_head(getter),other,next,nd_args(getter,[]))

@unsafe
def p173oa_getter_args(book, term, setter, root, call, head, other, next, args):
  match args:
    case Con{arg,Nil{}}:
      nt_choose(P173OAResult,p173oa_var(arg,ix(root)) && p173oa_user(book,head,1),
        u => p173oa_pair_result(term,root,call,other,next,p173od_pair(book,nm(head),nm(setter))),
        u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}

@unsafe
def p173oa_call(book, term, setter, root, value, next):
  p173oa_call_args(book,term,setter,root,nd_head(value),next,nd_args(value,[]))

@unsafe
def p173oa_call_args(book, term, setter, root, head, next, args):
  match args:
    case Con{getter,+other}:
      nt_choose(P173OAResult,p173oa_user(book,head,terms_len(args)) && p173oa_atoms(other,ix(root)),
        u => p173oa_getter(book,term,setter,root,head,getter,other,next),
        u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}

@unsafe
def p173oa_try(book, term, next):
  nt_choose(P173OAResult,p98_tag_eq(term,"App") && U32.is_lt(next,3999999000),
    u => p173oa_application(book,term,next,nd_head(term),nd_args(term,[])),
    u => P173OAResult{term,next,0})

@unsafe
def p173oa_application(book, term, next, setter, args):
  match args:
    case Con{+root,Con{value,Nil{}}}:
      nt_choose(P173OAResult,p173oa_var(root,ix(root)) && p173oa_user(book,setter,2),
        u => p173oa_call(book,term,setter,root,value,next),u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}

@unsafe
def p173oa_walk(book, term, next, fuel):
  nt_choose(P173OAResult,U32.is_eq(fuel,0),u => P173OAResult{term,next,0},
    u => p173oa_tried(book,term,fuel,p173oa_try(book,term,next)))

@unsafe
def p173oa_tried(book, term, fuel, tried):
  match tried:
    case P173OAResult{result,next,+hits}:
      nt_choose(P173OAResult,U32.is_gt(hits,0),u => tried,
        u => p173oa_rebuild(term,p173oa_terms(book,ks(term),next,U32.sub(fuel,1))))

@unsafe
def p173oa_rebuild(term, children):
  match children:
    case P173OAList{terms,next,+hits}:
      P173OAResult{nt_choose(KTerm,U32.is_gt(hits,0),u => k_with_children(term,terms),u => term),next,hits}

@unsafe
def p173oa_terms(book, terms, next, fuel):
  match terms:
    case Nil{}: P173OAList{[],next,0}
    case Con{head,rest}: p173oa_first(book,rest,fuel,p173oa_walk(book,head,next,fuel))

@unsafe
def p173oa_first(book, rest, fuel, first):
  match first:
    case P173OAResult{term,next,hits}: p173oa_cons(term,hits,p173oa_terms(book,rest,next,fuel))

@unsafe
def p173oa_cons(term, hits, rest):
  match rest:
    case P173OAList{terms,next,more}: P173OAList{Con{term,terms},next,U32.add(hits,more)}

# The input book is the original checked/erased request; summaries cannot be
# influenced by an earlier rewrite in this traversal. Static data is unchanged.
@unsafe
def p173oa_definitions(book, prepared, names, index, next, hits):
  match names:
    case Nil{}: P173OABook{index,next,hits}
    case Con{+name,rest}:
      +fact = ns_body(prepared,name)
      nt_choose(P173OABook,String.eq(dk(fact),"NativeStaticBody"),
        u => p173oa_definition_done(book,prepared,rest,index,hits,fact,p173oa_walk(book,dv(fact),next,4096)),
        u => p173oa_definitions(book,prepared,rest,index,next,hits))

@unsafe
def p173oa_definition_done(book, prepared, rest, index, hits, fact, result):
  match result:
    case P173OAResult{term,next,+more}:
      p173oa_definitions(book,prepared,rest,
        nt_choose(KDef,U32.is_gt(more,0),u => index_set(index,
          KDef{dn(fact),dk(fact),da(fact),dx(fact),dt(fact),term,dc(fact),db(fact),du(fact)},
          index_hash(dn(fact),2166136261),32),u => index),next,U32.add(hits,more))

@unsafe
def p173oa_context(context, index):
  match context:
    case KDef{name,kind,arity,templates,typ,value,Con{old,rest},native,unsafe}:
      KDef{name,kind,arity,templates,typ,value,Con{index,rest},native,unsafe}
    case _: context

@unsafe
def p173oa_publish(prepared, changed):
  match changed prepared:
    case P173OABook{index,next,+hits}
      Con{KDef{name,kind,arity,templates,typ,value,Con{source,Con{context,tail}},native,unsafe},rest}:
      nt_choose(List<&2,KDef>,U32.is_gt(hits,0),
        u => Con{KDef{name,kind,U32.max(arity,next),templates,typ,value,
          Con{source,Con{p173oa_context(context,index),tail}},native,unsafe},rest},u => prepared)
    case _ _: prepared

# Initial experimental request scope. This is stricter than observer/effect
# permission: every reachable foreign or unknown definition refuses the pass.
@unsafe
def p173oa_pure_names(book, names):
  match names:
    case Nil{}: True{}
    case Con{name,rest}:
      +definition = lookup(book,name)
      String.eq(dk(definition),"Def") && Bool.not(nc_foreign(definition)) && p173oa_pure_names(book,rest)

@unsafe
def p173oa_prepared(book, names, prepared):
  match prepared:
    case P112SPrepared{+ready,nodes,+error}:
      nt_choose(P112SPrepared,String.is_empty(error) &&
        String.eq(dk(ns_context(ready)),"NativeStaticContext") &&
        U32.is_lt(norm_book_bound(book),3999998000) && p173oa_pure_names(book,names),
        u => P112SPrepared{p173oa_publish(ready,p173oa_definitions(book,ready,names,
          index_first(dc(ns_context(ready))),U32.inc(norm_book_bound(book)),0)),nodes,error},
        u => prepared)

law p173oa_inspect_names:
  for +book: List<&2,KDef>
  for names: List<&2,String>
  for +next: U32
  List<&2,String>

law p173oa_inspect_one:
  for +book: List<&2,KDef>
  for +name: String
  for +rest: List<&2,String>
  for result: P173OAResult
  List<&2,String>

@unsafe
def p173oa_inspect_one(book, name, rest, result):
  match result:
    case P173OAResult{term,next,+hits}:
      nt_choose(List<&2,String>,U32.is_gt(hits,0),
        u => Con{name ++ ":rows=" ++ U32.show(hits),p173oa_inspect_names(book,rest,next)},
        u => p173oa_inspect_names(book,rest,next))

@unsafe
def p173oa_inspect_names(book, names, next):
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      +definition = lookup(book,name)
      nt_choose(List<&2,String>,String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)),
        u => p173oa_inspect_one(book,name,rest,p173oa_walk(book,nc_definition(book,definition,0),next,4096)),
        u => p173oa_inspect_names(book,rest,next))

@unsafe
def p173oa_inspect_request(request: NR_Request) -> List<&2,String>:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      nt_choose(List<&2,String>,p173oa_pure_names(book,names),
        u => Con{"scope:pure",p173oa_inspect_names(book,names,U32.inc(norm_book_bound(book)))},
        u => ["scope:foreign-or-unknown-refused"])
