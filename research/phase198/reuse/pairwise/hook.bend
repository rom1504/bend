def x198pw_cid(c: String,ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{functions,ctors}: p111v_get(ctors,c)

def x198pw_has_cid(+id: KDef,+arity: U32) -> Bool:
  String.eq(dk(id),"N111Id") && U32.is_lt(da(id),65536) && U32.is_eq(dx(id),arity)

def x198pw_h_args(ps: List<&2,String>) -> Bool:
  match ps:
    case Con{state,Con{a,Con{b,Con{d,Con{mode,Con{depth,Con{value,Nil{}}}}}}}}:
      String.eq(state,"state") && String.eq(mode,"p114h_mode") && String.eq(depth,"p114r_depth") && String.eq(value,"p114r_value")
    case _: False{}

@unsafe
def x198pw_get_mark(name: String,ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,x198pw_key(name))

@unsafe
def x198pw_emit_wrapper(+symbol: String,+slow: String,leaf: U32,+node: U32,no: U32,yes: U32) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    x198pw_machine(".Lp198pair_" ++ symbol,slow,node,U32.add(131072,node),U32.add(16777216,U32.mul(leaf,256)),
      U32.add(16777216,U32.mul(no,256)),U32.add(16777216,U32.mul(yes,256))),X188One{PSize{symbol}}])],""}

@unsafe
def x198pw_worker_cids(+symbol: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+leaf: String,+node: String) -> X181Output:
  +leafId = x198pw_cid(leaf,ids)
  +nodeId = x198pw_cid(node,ids)
  +no = x198pw_cid("False",ids)
  +yes = x198pw_cid("True",ids)
  +slow = "p198w_original_" ++ symbol
  nt_choose(X181Output,p185cc_known(node,2,ids) && x198pw_has_cid(leafId,1) && x198pw_has_cid(no,0) && x198pw_has_cid(yes,0) &&
      U32.is_ne(da(leafId),da(nodeId)) && U32.is_ne(da(no),da(yes)),
    u => x181_program_join(x198pw_emit_wrapper(symbol,slow,da(leafId),da(nodeId),da(no),da(yes)),
      x185_function_setup(slow,params,setup,body,ids)),
    u => x185_function_setup(symbol,params,setup,body,ids))

@unsafe
def x198pw_worker(+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,+body: List<&2,P113DStmt>,
    +ids: N111Ids,+entry: KDef) -> X181Output:
  +symbol = p114r_symbol(name)
  nt_choose(X181Output,String.eq(dk(entry),"X198PWCertified") && x198pw_h_args(params),
    u => x198pw_worker_cids(symbol,params,setup,body,ids,nm(dt(entry)),nm(dv(entry))),
    u => x185_function_setup(symbol,params,setup,body,ids))

@unsafe
def x192h_emit_checked(+segment: N111Segment,+name: String,+params: List<&2,String>,+setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>,+adapter: List<&2,P113DStmt>,+ids: N111Ids,+available: KDef) -> X181Output:
  +error = p111_first(x181_program_stmts(setup,available),p111_first(x181_program_stmts(body,available),
    p111_first(x181_program_stmts(adapter,available),p111_first(x181_hygiene_names(params),
      p111_first(x181_hygiene_stmts(setup),p111_first(x181_hygiene_stmts(body),x181_hygiene_stmts(adapter)))))))
  nt_choose(X181Output,String.is_empty(error),u => x192h_output_or_original(segment,ids,
    x181_program_join(x198pw_worker(name,params,setup,body,ids,x198pw_get_mark(name,ids)),
      x185_function_setup(p111q_symbol(name),["state"],[],adapter,ids))),u => x181_segment(segment,ids))

# Diagnostic helpers expose the same unmodified classifier and constructor
# telescope for independent finite controls, including rejected source variants.
@unsafe
def x198pw_probe(request: NR_Request,+owner: String) -> X198PWPlan:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}: x198pw_checked_plan(book,lookup(book,owner))

@unsafe
def x198pw_symbolic(request: NR_Request,+owner: String) -> X198PWPlan:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}: x198pw_candidate(book,lookup(book,owner))

@unsafe
def x198pw_descriptor(request: NR_Request,name: String) -> KDef:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: lookup(book,name)
