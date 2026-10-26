# Request-local ownership facts. The builder retains first child visibility and
# first qualifying ADT ownership, including False. Only positive names survive.
type P144OFacts is Data:
  P144OFacts{+names: List<&2,String>, +valid: Bool}

# Independent original semantics. Keep this unchanged when wiring the entry.
@unsafe
def p144o_original(book: List<&2,KDef>, +name: String) -> Bool:
  match book:
    case Nil{}: False{}
    case Con{+d,+rest}:
      kc(Bool,p137q_is_adt(d),
        u => kc(Bool,p137q_is_ctr(lookup(dc(d),name)),u => db(d),u => p144o_original(rest,name)),
        u => p144o_original(rest,name))

@unsafe
def p144o_build(book: List<&2,KDef>) -> P144OFacts:
  p144o_rows(book,missing(),[])

@unsafe
def p144o_rows(book: List<&2,KDef>, +claimed: KDef, +positive: List<&2,String>) -> P144OFacts:
  match book:
    case Nil{}: P144OFacts{nt_reverse(String,positive,[]),True{}}
    case Con{+head,+rest}:
      nt_choose(P144OFacts,p137q_is_adt(head),
        u => p144o_children(rest,dc(head),db(head),missing(),claimed,positive),
        u => p144o_rows(rest,claimed,positive))

@unsafe
def p144o_children(+rows: List<&2,KDef>, children: List<&2,KDef>, +owned: Bool,
    +seen: KDef, +claimed: KDef, +positive: List<&2,String>) -> P144OFacts:
  match children:
    case Nil{}: p144o_rows(rows,claimed,positive)
    case Con{+head,+rest}:
      nt_choose(P144OFacts,p88_string_eq(dk(head),"BookCache") || Bool.not(book_final_name_valid(dn(head))),
        u => P144OFacts{[],False{}},
        u => p144o_child(rows,rest,owned,seen,claimed,positive,head,index_hash(dn(head),2166136261)))

@unsafe
def p144o_child(+rows: List<&2,KDef>, +rest: List<&2,KDef>, +owned: Bool,
    +seen: KDef, +claimed: KDef, +positive: List<&2,String>, +head: KDef, +hash: U32) -> P144OFacts:
  +name = dn(head)
  nt_choose(P144OFacts,p142j_member(seen,name,hash),
    u => p144o_children(rows,rest,owned,seen,claimed,positive),
    u => nt_choose(P144OFacts,p137q_is_ctr(head) && Bool.not(p142j_member(claimed,name,hash)),
      v => p144o_children(rows,rest,owned,p142j_mark(seen,name,hash),p142j_mark(claimed,name,hash),
        nt_choose(List<&2,String>,owned,w => Con{name,positive},w => positive)),
      v => p144o_children(rows,rest,owned,p142j_mark(seen,name,hash),claimed,positive)))

@unsafe
def p144o_query(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> Bool:
  match facts:
    case P144OFacts{+names,valid}:
      nt_choose(Bool,valid,u => nb_contains(names,name),u => p144o_original(book,name))

@unsafe
def p144o_identity(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> String:
  nt_choose(String,p144o_query(book,facts,name),u => name,u => nc_ctor_encode(name))

# Existing-index comparison: additional construction/destruction is charged by
# calling this after p144o_build; it is not selected by the production adapter.
@unsafe
def p144o_index(names: List<&2,String>, tree: KDef) -> KDef:
  match names:
    case Nil{}: tree
    case Con{+name,rest}: p144o_index(rest,p142j_mark(tree,name,index_hash(name,2166136261)))

@unsafe
def p144o_index_query(+book: List<&2,KDef>, valid: Bool, +tree: KDef, +name: String) -> Bool:
  nt_choose(Bool,valid,u => p142j_member(tree,name,index_hash(name,2166136261)),u => p144o_original(book,name))

# Catalogue normalization still uses the ORIGINAL source book. Only ownership
# identity queries consume the shared summary; order/arity/foreign rules stay.
@unsafe
def p144o_specs(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      Con{N_Constructor{p144o_identity(book,facts,dn(child)),nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        p144o_specs(book,rest,params,facts)}

@unsafe
def p144o_constructors(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,p144o_specs(book,dc(definition),da(definition),facts),p144o_constructors(book,rest,facts)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},p144o_constructors(book,rest,facts)},
          v => p144o_constructors(book,rest,facts)))
