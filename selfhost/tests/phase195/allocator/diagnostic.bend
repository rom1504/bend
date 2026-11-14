# Diagnostic-only replacement at the actual post-scalar/pre-selection boundary.
# Each function emits one typed PError containing JSON, with outer error empty.
# Extract PError.error as data. NEVER render/assemble/link this diagnostic route.
# Arrays preserve constructor identity, field order, widths and constant words.
@unsafe
def p192d_join(parts: List<&2,String>, +separator: String) -> String:
  match parts:
    case Nil{}: ""
    case Con{head,Nil{}}: head
    case Con{head,rest}: head ++ separator ++ p192d_join(rest,separator)

@unsafe
def p192d_names(names: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{head,rest}: Con{sk_quote(head),p192d_names(rest)}

def p192d_type(typ: N111Type) -> String:
  match typ:
    case N111U32{}: "\"N111U32\""
    case N111U64{}: "\"N111U64\""
    case N111Ptr{}: "\"N111Ptr\""

@unsafe
def p192d_value(value: N111Value) -> String:
  match value:
    case N111Local{name}: "[\"N111Local\"," ++ sk_quote(name) ++ "]"
    case N111Const{lo,hi}: "[\"N111Const\"," ++ U32.show(lo) ++ "," ++ U32.show(hi) ++ "]"
    case N111Symbol{name}: "[\"N111Symbol\"," ++ sk_quote(name) ++ "]"
    case N111FuncId{name}: "[\"N111FuncId\"," ++ sk_quote(name) ++ "]"
    case N111CtorId{name}: "[\"N111CtorId\"," ++ sk_quote(name) ++ "]"

@unsafe
def p192d_values(values: List<&2,N111Value>) -> List<&2,String>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p192d_value(head),p192d_values(rest)}

@unsafe
def p192d_args(args: List<&2,N111Arg>) -> List<&2,String>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}:
      Con{"[\"N111Arg\"," ++ p192d_type(typ) ++ "," ++ p192d_value(value) ++ "]",p192d_args(rest)}

law p192d_scalars:
  for body: List<&2,N111Stmt>
  List<&2,String>

@unsafe
def p192d_scalar(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{name,typ,value}:
      "[\"N111Set\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ p192d_value(value) ++ "]"
    case N111Bin{name,typ,op,left,right}:
      "[\"N111Bin\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ sk_quote(op) ++ "," ++ p192d_value(left) ++ "," ++ p192d_value(right) ++ "]"
    case N111Call{name,typ,symbol,args}:
      "[\"N111Call\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ sk_quote(symbol) ++ ",[" ++ p192d_join(p192d_args(args),",") ++ "]]"
    case N111If{condition,yes,no}:
      "[\"N111If\"," ++ p192d_value(condition) ++ ",[" ++ p192d_join(p192d_scalars(yes),",") ++ "],[" ++ p192d_join(p192d_scalars(no),",") ++ "]]"
    case N111Return{value}: "[\"N111Return\"," ++ p192d_value(value) ++ "]"
    case N111Load{name,typ,base,offset}:
      "[\"N111Load\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ p192d_value(base) ++ "," ++ U32.show(offset) ++ "]"
    case N111Store{typ,base,offset,value}:
      "[\"N111Store\"," ++ p192d_type(typ) ++ "," ++ p192d_value(base) ++ "," ++ U32.show(offset) ++ "," ++ p192d_value(value) ++ "]"
    case N111Offset{name,base,bytes}:
      "[\"N111Offset\"," ++ sk_quote(name) ++ "," ++ p192d_value(base) ++ "," ++ p192d_value(bytes) ++ "]"
    case N111Alloca{name,bytes,align}:
      "[\"N111Alloca\"," ++ sk_quote(name) ++ "," ++ U32.show(bytes) ++ "," ++ U32.show(align) ++ "]"

@unsafe
def p192d_scalars(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p192d_scalar(head),p192d_scalars(rest)}

law p192d_body:
  for body: List<&2,P113DStmt>
  List<&2,String>

@unsafe
def p192d_stmt(stmt: P113DStmt) -> String:
  match stmt:
    case P113DScalar{scalar}: "[\"P113DScalar\"," ++ p192d_scalar(scalar) ++ "]"
    case P113DIf{condition,yes,no}:
      "[\"P113DIf\"," ++ p192d_value(condition) ++ ",[" ++ p192d_join(p192d_body(yes),",") ++ "],[" ++ p192d_join(p192d_body(no),",") ++ "]]"
    case P113DCall{destinations,target,args}:
      "[\"P113DCall\",[" ++ p192d_join(p192d_names(destinations),",") ++ "]," ++ sk_quote(target) ++ ",[" ++ p192d_join(p192d_values(args),",") ++ "]]"
    case P113DResult{values}: "[\"P113DResult\",[" ++ p192d_join(p192d_values(values),",") ++ "]]"
    case P113DAgain{values}: "[\"P113DAgain\",[" ++ p192d_join(p192d_values(values),",") ++ "]]"

@unsafe
def p192d_body(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p192d_stmt(head),p192d_body(rest)}

# Diagnostic-only route marker, inserted only AFTER allocation returns. These
# frames are serialized below, never saved, rendered, assembled or executed.
@unsafe
def p195ac_mark(frame: X181Frame, route: String, chosen: U32) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(slots,"__p195_allocator_route",route,chosen,0),bytes,calls,params,symbol}

@unsafe
def x190_allocate_legacy(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>) -> X181Frame:
  p195ac_mark(x190_liveness_frame(x181_register_frame(frame,registerBody),params,setup,body),"legacy",0)

@unsafe
def x190_j_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +rows: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x190_j_valid(names,rows,params,1,groups),
    u => p195ac_mark(x190_j_install(names,groups,1,frame),"joint",nt_count(String,names)),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def p195ac_eligible(names: List<&2,String>, +slots: KDef, +counts: KDef) -> U32:
  match names:
    case Nil{}: 0
    case Con{+name,rest}:
      U32.add(nt_choose(U32,String.eq(dk(p111v_get(slots,name)),"X181Stack") &&
        U32.is_gt(da(p111v_get(counts,name)),0),u => 1,u => 0),p195ac_eligible(rest,slots,counts))

@unsafe
def p195ac_homes(names: List<&2,String>, +slots: KDef, +counts: KDef) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      +entry = p111v_get(slots,name)
      Con{"[" ++ sk_quote(name) ++ "," ++ sk_quote(dk(entry)) ++ "," ++ U32.show(da(entry)) ++
        "," ++ U32.show(da(p111v_get(counts,name))) ++ "]",p195ac_homes(rest,slots,counts)}

@unsafe
def p195ac_candidates(candidates: X190LCandidates) -> String:
  match candidates:
    case X190LCandidates{names,ids}: "[" ++ p192d_join(p192d_names(names),",") ++ "]"

@unsafe
def p195ac_output(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, path: String, originalRows: U32, initial: X181Frame,
    allocated: X181Frame, reads: X181ReadCounts) -> X181Output:
  match initial allocated reads:
    case X181Frame{+initialSlots,initialBytes,initialCalls,initialParams,initialSymbol}
         X181Frame{+slots,bytes,calls,words,frameSymbol} X181ReadCounts{+counts,+names}:
      +route = p111v_get(slots,"__p195_allocator_route")
      X181Output{[X188One{PError{"{\"kind\":\"phase195-allocator-ir\",\"version\":1,\"symbol\":" ++ sk_quote(symbol) ++
        ",\"params\":[" ++ p192d_join(p192d_names(params),",") ++ "],\"setup\":[" ++ p192d_join(p192d_body(setup),",") ++
        "],\"body\":[" ++ p192d_join(p192d_body(body),",") ++ "],\"allocation\":{\"path\":" ++ sk_quote(path) ++
        ",\"route\":" ++ sk_quote(dk(route)) ++ ",\"chosen\":" ++ U32.show(da(route)) ++
        ",\"originalRows\":" ++ U32.show(originalRows) ++
        ",\"placementRows\":" ++ U32.show(p113i_add(p113i_size(setup),p113i_size(body))) ++
        ",\"safe\":" ++ nt_choose(String,x190_l_safe_body(setup) && x190_l_safe_body(body),u => "true",u => "false") ++
        ",\"eligibleNames\":" ++ U32.show(p195ac_eligible(names,initialSlots,counts)) ++
        ",\"candidates32\":" ++ p195ac_candidates(x190_l_candidates(nt_reverse(String,names,[]),counts,initialSlots,1,32,missing(),[])) ++
        ",\"frameBytes\":" ++ U32.show(bytes) ++ ",\"outgoingBytes\":" ++ U32.show(calls) ++
        ",\"homes\":[" ++ p192d_join(p195ac_homes(names,slots,counts),",") ++ "]}}"}}],""}

@unsafe
def p195ac_allocate(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +placement: List<&2,P113DStmt>, path: String, originalRows: U32, +frame: X181Frame) -> X181Output:
  p195ac_output(symbol,params,setup,placement,path,originalRows,frame,
    x190_allocate_frame(frame,params,setup,placement,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,
        u => nt_append(P113DStmt,setup,placement))),
    x191_joint_reads(setup,placement,x181_tail_args(frame)))

@unsafe
def x191_ordinary_facts(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids, facts: X190BranchFacts) -> X181Output:
  p195ac_allocate(symbol,params,setup,x191_placement(body,facts),"ordinary",
    p113i_add(p113i_size(setup),p113i_size(body)),x181_frame(symbol,params,nt_append(P113DStmt,setup,body)))

@unsafe
def p195ac_float(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    nodes: List<&2,X186FloatNode>, originalRows: U32) -> X181Output:
  +placement = x186_f_placement_rows(nodes)
  p195ac_allocate(symbol,params,setup,placement,"float",originalRows,
    x181_frame(symbol,params,nt_append(P113DStmt,setup,placement)))

@unsafe
def x194fv_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:
  p195ac_float(symbol,params,setup,x194fv_nodes(params,setup,nodes),
    p113i_add(p113i_size(setup),p113i_size(x186_f_placement_rows(nodes))))

