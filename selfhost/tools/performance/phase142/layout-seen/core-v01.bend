# Same layout traversal and errors; only visited-name membership is indexed.
# No request cache or skipped term/type validation is introduced.
@unsafe
def p142j_checked_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> String:
  kc(String,p142j_visit(book_context(book),book_cached(defs,0),roots,missing(),stops),
    u => "an open Array element type",u => "")

@unsafe
def p142j_visit(+book: List<&2,KDef>, +defs: List<&2,KDef>, todo: List<&2,String>, +seen: KDef, +stops: List<&2,String>) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{+name,+rest}:
      kc(Bool,p88_string_eq(name,"$layout.open-array"),u => True{},
        u => p142j_name(book,defs,name,rest,seen,stops,index_hash(name,2166136261)))

@unsafe
def p142j_name(+book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: List<&2,String>, +hash: U32) -> Bool:
  kc(Bool,p142j_member(seen,name,hash) || has_name(stops,name),
    u => p142j_visit(book,defs,rest,seen,stops),
    u => p142j_def(book,defs,lookup(defs,name),rest,p142j_mark(seen,name,hash),stops))

@unsafe
def p142j_def(+book: List<&2,KDef>, +defs: List<&2,KDef>, +d: KDef, +todo: List<&2,String>, +seen: KDef, +stops: List<&2,String>) -> Bool:
  p142j_visit(book,defs,kc(List<&2,String>,p88_string_eq(dk(d),"Def") && U32.is_eq(dx(d),0),
    u => jl_term(book,dv(d),todo),u => todo),seen,stops)

@unsafe
def p142j_member(seen: KDef, name: String, hash: U32) -> Bool:
  p88_string_eq(dk(index_find(seen,name,hash,32)),"P142JSeen")

@unsafe
def p142j_mark(seen: KDef, name: String, hash: U32) -> KDef:
  index_set(seen,KDef{name,"P142JSeen",0,0,
    {KTerm{"Absent","",0,0,[],[],0,0}:KTerm},
    {KTerm{"Absent","",0,0,[],[],0,0}:KTerm},[],False{},False{}},hash,32)

# Test/bridge helper: the production checked entry starts from missing().
@unsafe
def p142j_members(names: List<&2,String>, seen: KDef) -> KDef:
  match names:
    case Nil{}: seen
    case Con{+name,rest}: p142j_members(rest,p142j_mark(seen,name,index_hash(name,2166136261)))
