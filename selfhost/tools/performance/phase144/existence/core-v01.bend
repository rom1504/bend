# One immutable batch, not a cross-request cache or a new BookCache authority.
# Ownership facts are deliberately not used: an unowned/non-ADT parent and a
# non-Ctr child can satisfy the existing constructor_exists predicate.
type P144CEFacts is Data:
  P144CEFacts{+members: KDef, +valid: Bool}

@unsafe
def p144ce_build(book: List<&2,KDef>) -> P144CEFacts:
  p144ce_rows(book,missing())

@unsafe
def p144ce_rows(book: List<&2,KDef>, +members: KDef) -> P144CEFacts:
  match book:
    case Nil{}: P144CEFacts{members,True{}}
    case Con{+parent,+rest}:
      nt_choose(P144CEFacts,book_final_name_valid(dk(parent)),
        u => nt_choose(P144CEFacts,p88_string_eq(dk(parent),"BookCache"),
          v => p144ce_rows(rest,members),
          v => p144ce_children(rest,dc(parent),missing(),members)),
        u => P144CEFacts{missing(),False{}})

@unsafe
def p144ce_children(+rows: List<&2,KDef>, children: List<&2,KDef>,
    +seen: KDef, +members: KDef) -> P144CEFacts:
  match children:
    case Nil{}: p144ce_rows(rows,members)
    case Con{+head,+rest}:
      nt_choose(P144CEFacts,book_final_name_valid(dn(head)) && book_final_name_valid(dk(head)),
        u => nt_choose(P144CEFacts,p88_string_eq(dk(head),"BookCache"),
          v => P144CEFacts{missing(),False{}},
          v => p144ce_child(rows,rest,seen,members,head,index_hash(dn(head),2166136261))),
        u => P144CEFacts{missing(),False{}})

@unsafe
def p144ce_child(+rows: List<&2,KDef>, +rest: List<&2,KDef>, +seen: KDef,
    +members: KDef, +head: KDef, +hash: U32) -> P144CEFacts:
  +name = dn(head)
  nt_choose(P144CEFacts,p142j_member(seen,name,hash),
    u => p144ce_children(rows,rest,seen,members),
    u => p144ce_children(rows,rest,p142j_mark(seen,name,hash),
      nt_choose(KDef,p88_string_eq(dk(head),"Absent"),
        v => members,v => p142j_mark(members,name,hash))))

@unsafe
def p144ce_query(+book: List<&2,KDef>, facts: P144CEFacts, +name: String) -> Bool:
  match facts:
    case P144CEFacts{members,valid}:
      nt_choose(Bool,valid && book_final_name_valid(name),
        u => p142j_member(members,name,index_hash(name,2166136261)),
        u => constructor_exists(book,name))

# Full consumer interfaces build and release their own facts. Original functions
# remain unchanged independent oracles and all invalid fact cases use them.
@unsafe
def p144ce_names(+done: List<&2,KDef>, +ctors: List<&2,KDef>, +names: List<&2,String>) -> String:
  match ctors:
    case Nil{}: ""
    case Con{head,Nil{}}: constructor_names(done,ctors,names)
    case _: p144ce_names_go(done,ctors,names,p144ce_build(done))

@unsafe
def p144ce_names_go(+done: List<&2,KDef>, ctors: List<&2,KDef>, +names: List<&2,String>, +facts: P144CEFacts) -> String:
  match ctors:
    case Nil{}: ""
    case Con{+head,rest}:
      nt_choose(String,has_name(names,dn(head)) || p144ce_query(done,facts,dn(head)),
        u => "duplicate constructor name",
        u => p144ce_names_go(done,rest,Con{dn(head),names},facts))

@unsafe
def p144ce_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case _: p144ce_disjoint_go(defs,context,p144ce_build(context))

@unsafe
def p144ce_disjoint_go(defs: List<&2,KDef>, +context: List<&2,KDef>, +facts: P144CEFacts) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{+definition,rest}:
      nt_choose(Bool,Bool.not(p144ce_query(context,facts,dn(definition))) &&
        p144ce_disjoint_go(dc(definition),context,facts),
        u => p144ce_disjoint_go(rest,context,facts),u => False{})
