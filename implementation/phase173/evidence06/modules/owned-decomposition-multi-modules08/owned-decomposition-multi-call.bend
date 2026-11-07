# Call-site recognition only; actual helper semantics come from the independent
# bounded summaries. All unchanged arguments are projections or evaluated atoms.
type P173OMCall is Data:
  P173OMCall{+valid: Bool,+args: List<&2,P173OMArg>,+computed: U32,+call: KTerm,+other: List<&2,KTerm>}

law p173om_bad:
  P173OMCall

law p173om_collect:
  for +book: List<&2,KDef>
  for +root: U32
  for +args: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +found: U32
  for +computed: U32
  for +call: KTerm
  for +other: List<&2,KTerm>
  P173OMCall

law p173om_collect_call:
  for +book: List<&2,KDef>
  for +root: U32
  for +arg: KTerm
  for +rest: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +found: U32
  for +computed: U32
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +head: KTerm
  for +args: List<&2,KTerm>
  P173OMCall

law p173om_collect_work:
  for +book: List<&2,KDef>
  for +root: U32
  for +rest: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +found: U32
  for +head: KTerm
  for +args: List<&2,KTerm>
  P173OMCall

law p173om_collect_getter:
  for +book: List<&2,KDef>
  for +root: U32
  for +rest: List<&2,KTerm>
  for +index: U32
  for +acc: List<&2,P173OMArg>
  for +call: KTerm
  for +other: List<&2,KTerm>
  for +head: KTerm
  for +args: List<&2,KTerm>
  P173OMCall

law p173om_collected:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +setter: KTerm
  for +root: KTerm
  for +next: U32
  for +collected: P173OMCall
  P173OAResult

@unsafe
def p173om_bad():
  P173OMCall{False{},[],0,atom("Absent"),[]}

@unsafe
def p173om_collect(book, root, args, index, acc, found, computed, call, other):
  match args:
    case Nil{}: P173OMCall{U32.is_eq(found,1),nt_reverse(P173OMArg,acc,[]),computed,call,other}
    case Con{+arg,+rest}:
      nt_choose(P173OMCall,U32.is_lt(index,7),u =>
        nt_choose(P173OMCall,p173oa_atom(arg,root) && List.is_empty(&2,KTerm,ks(arg)),
          v => p173om_collect(book,root,rest,U32.inc(index),Con{P173OMValue{arg},acc},found,computed,call,other),
          v => p173om_collect_call(book,root,arg,rest,index,acc,found,computed,call,other,nd_head(arg),nd_args(arg,[]))),u => p173om_bad())

@unsafe
def p173om_collect_call(book, root, arg, rest, index, acc, found, computed, call, other, head, args):
  match args:
    case Con{+first,Nil{}}:
      nt_choose(P173OMCall,p173oa_var(first,root) && p173oa_user(book,head,1),
        u => p173om_collect(book,root,rest,U32.inc(index),Con{P173OMGetter{nm(head)},acc},found,computed,call,other),
        u => p173om_collect_work(book,root,rest,index,acc,found,head,args))
    case _: p173om_collect_work(book,root,rest,index,acc,found,head,args)

@unsafe
def p173om_collect_work(book, root, rest, index, acc, found, head, args):
  match args:
    case Con{+getter,+other}:
      nt_choose(P173OMCall,U32.is_eq(found,0) && p173oa_user(book,head,terms_len(args)) && p173oa_atoms(other,root),
        u => p173om_collect_getter(book,root,rest,index,acc,head,other,nd_head(getter),nd_args(getter,[])),u => p173om_bad())
    case _: p173om_bad()

@unsafe
def p173om_collect_getter(book, root, rest, index, acc, call, other, head, args):
  match args:
    case Con{+arg,Nil{}}:
      nt_choose(P173OMCall,p173oa_var(arg,root) && p173oa_user(book,head,1),
        u => p173om_collect(book,root,rest,U32.inc(index),Con{P173OMWork{nm(head)},acc},1,index,call,other),u => p173om_bad())
    case _: p173om_bad()

@unsafe
def p173om_collected(book, term, setter, root, next, collected):
  match collected:
    case P173OMCall{+valid,+args,+computed,+call,+other}:
      nt_choose(P173OAResult,valid,
        u => nt_choose(P173OAResult,p173oa_user(book,setter,U32.inc(nt_count(P173OMArg,args))),
          v => p173oa_pair_result(term,root,call,other,next,p173om_pair(book,nm(setter),args,computed)),
          v => P173OAResult{term,next,0}),
        u => P173OAResult{term,next,0})

@unsafe
def p173om_application(book, term, next, setter, args):
  match args:
    case Con{+root,+rest}:
      nt_choose(P173OAResult,p173oa_var(root,ix(root)) && U32.is_gt(terms_len(rest),1) && U32.is_le(terms_len(rest),7) &&
        p98_tag_eq(setter,"Ref") && List.is_empty(&2,KTerm,ks(setter)) && Bool.not(U32.is_eq(qt(setter),3)),
        u => p173om_collected(book,term,setter,root,next,p173om_collect(book,ix(root),rest,0,[],0,0,atom("Absent"),[])),
        u => P173OAResult{term,next,0})
    case _: P173OAResult{term,next,0}
