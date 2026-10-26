# Whole-work ownership kernels: prepare, all actual catalogue-name queries,
# result reduction, and reclamation belong to one invocation. No retained cache.
@unsafe
def p144ow_children(children: List<&2,KDef>, acc: List<&2,String>) -> List<&2,String>:
  match children:
    case Nil{}: acc
    case Con{head,rest}: p144ow_children(rest,Con{dn(head),acc})

@unsafe
def p144ow_names(book: List<&2,KDef>, acc: List<&2,String>) -> List<&2,String>:
  match book:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,p137q_is_adt(head),
        u => p144ow_names(rest,p144ow_children(dc(head),acc)),
        u => p144ow_names(rest,acc))

@unsafe
def p144ow_original_once(+book: List<&2,KDef>, names: List<&2,String>, count: U32) -> U32:
  match names:
    case Nil{}: count
    case Con{name,rest}: p144ow_original_once(book,rest,U32.add(count,Bool.to_u32(p144o_original(book,name))))

@unsafe
def p144ow_list_once(+book: List<&2,KDef>, +facts: P144OFacts, names: List<&2,String>, count: U32) -> U32:
  match names:
    case Nil{}: count
    case Con{name,rest}: p144ow_list_once(book,facts,rest,U32.add(count,Bool.to_u32(p144o_query(book,facts,name))))

@unsafe
def p144ow_index_once(+book: List<&2,KDef>, +valid: Bool, +tree: KDef, names: List<&2,String>, count: U32) -> U32:
  match names:
    case Nil{}: count
    case Con{name,rest}: p144ow_index_once(book,valid,tree,rest,U32.add(count,Bool.to_u32(p144o_index_query(book,valid,tree,name))))

@unsafe
def p144ow_original_rounds(+book: List<&2,KDef>, +names: List<&2,String>, rounds: U32, count: U32) -> U32:
  match rounds:
    case 0: count
    case n: p144ow_original_rounds(book,names,U32.sub(n,1),p144ow_original_once(book,names,count))

@unsafe
def p144ow_list_rounds(+book: List<&2,KDef>, +facts: P144OFacts, +names: List<&2,String>, rounds: U32, count: U32) -> U32:
  match rounds:
    case 0: count
    case n: p144ow_list_rounds(book,facts,names,U32.sub(n,1),p144ow_list_once(book,facts,names,count))

@unsafe
def p144ow_index_rounds(+book: List<&2,KDef>, +valid: Bool, +tree: KDef, +names: List<&2,String>, rounds: U32, count: U32) -> U32:
  match rounds:
    case 0: count
    case n: p144ow_index_rounds(book,valid,tree,names,U32.sub(n,1),p144ow_index_once(book,valid,tree,names,count))

@unsafe
def p144ow_original(+book: List<&2,KDef>, rounds: U32) -> U32:
  p144ow_original_rounds(book,p144ow_names(book,[]),rounds,17)

@unsafe
def p144ow_list(+book: List<&2,KDef>, rounds: U32) -> U32:
  p144ow_list_rounds(book,p144o_build(book),p144ow_names(book,[]),rounds,17)

@unsafe
def p144ow_index_ready(+book: List<&2,KDef>, rounds: U32, facts: P144OFacts) -> U32:
  match facts:
    case P144OFacts{names,valid}:
      p144ow_index_rounds(book,valid,p144o_index(names,missing()),p144ow_names(book,[]),rounds,17)

@unsafe
def p144ow_index(+book: List<&2,KDef>, rounds: U32) -> U32:
  p144ow_index_ready(book,rounds,p144o_build(book))
