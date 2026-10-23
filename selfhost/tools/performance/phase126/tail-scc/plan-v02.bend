# Discovery uses the existing hashed function index. Duplicate identities are
# never combined; the original candidate closure keeps its original behavior.
@unsafe
def p126sc_call_terms(calls: List<&2,String>) -> List<&2,KTerm>:
  match calls:
    case Nil{}: []
    case Con{name,rest}: Con{kt("Ref",name,0,0,[]),p126sc_call_terms(rest)}

@unsafe
def p126sc_call_has(calls: List<&2,KTerm>, +name: String) -> Bool:
  match calls:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,String.eq(nm(head),name),u => True{},u => p126sc_call_has(rest,name))

@unsafe
def p126sc_counts(candidates: List<&2,P113DCandidate>, +counts: KDef, +slot: U32) -> KDef:
  match candidates:
    case Nil{}: counts
    case Con{P113DCandidate{function,error,calls},rest}:
      +name = p126sc_name(function)
      p126sc_counts(rest,index_set(counts,KDef{name,"P126Count",U32.inc(da(p111v_get(counts,name))),slot,atom("Absent"),kt("Calls","",0,0,p126sc_call_terms(calls)),[],False{},False{}},index_hash(name,2166136261),32),U32.inc(slot))

@unsafe
def p126sc_index(candidates: List<&2,P113DCandidate>, +counts: KDef, +index: P113ITable) -> P113ITable:
  match candidates:
    case Nil{}: index
    case Con{P113DCandidate{+function,+error,calls},+rest}:
      +name = p126sc_name(function)
      nt_choose(P113ITable,String.is_empty(error) && p126sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
        u => p126sc_index(rest,counts,p113i_put(index,function,index_hash(name,2166136261),0)),
        u => p126sc_index(rest,counts,index))

@unsafe
def p126sc_partner_try(+left: P113DFunction, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: None{}
    case Some{+right}:
      nt_choose(Maybe<&2,P113DFunction>,String.eq(dk(p111v_get(done,p126sc_name(right))),"Absent") && U32.is_gt(dx(p111v_get(counts,p126sc_name(right))),slot) && p126sc_call_has(ks(dv(p111v_get(counts,p126sc_name(right)))),p126sc_name(left)),
        u => nt_choose(Maybe<&2,P113DFunction>,p126sc_pair_safe(left,right),v => Some{right},v => None{}),u => None{})

law p126sc_partner:
  for +calls: List<&2,String>
  for +left: P113DFunction
  for +index: P113ITable
  for +counts: KDef
  for +slot: U32
  for +done: KDef
  Maybe<&2,P113DFunction>

@unsafe
def p126sc_partner_next(+calls: List<&2,String>, +left: P113DFunction, +index: P113ITable, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: p126sc_partner(calls,left,index,counts,slot,done)
    case Some{right}: Some{right}

@unsafe
def p126sc_partner(calls,left,index,counts,slot,done):
  match calls:
    case Nil{}: None{}
    case Con{+name,rest}: p126sc_partner_next(rest,left,index,counts,slot,done,p126sc_partner_try(left,counts,slot,done,p113i_get(index,name,index_hash(name,2166136261),0)))

law p126sc_walk:
  for +candidates: List<&2,P113DCandidate>
  for +index: P113ITable
  for +counts: KDef
  for +done: KDef
  for +slot: U32
  for +acc: List<&2,P113DCandidate>
  List<&2,P113DCandidate>

@unsafe
def p126sc_found(+candidate: P113DCandidate, +left: P113DFunction, +rest: List<&2,P113DCandidate>, +index: P113ITable, +counts: KDef, +done: KDef, +slot: U32, +acc: List<&2,P113DCandidate>, found: Maybe<&2,P113DFunction>) -> List<&2,P113DCandidate>:
  match found:
    case None{}: p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc})
    case Some{+right}:
      +worker = "$p126scc." ++ U32.show(slot)
      +width = U32.max(nt_count(NC_Binding,p126sc_params(left)),nt_count(NC_Binding,p126sc_params(right)))
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(p111v_get(counts,worker)),"Absent"),
        u => p126sc_walk(rest,index,counts,p111v_put(p111v_put(done,p126sc_name(left),"P126Used",0,0),p126sc_name(right),"P126Used",0,0),U32.inc(slot),
          Con{p126sc_wrapper(right,worker,1,width),Con{p126sc_wrapper(left,worker,0,width),Con{p126sc_worker(left,right,worker),acc}}}),
        u => p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc}))

@unsafe
def p126sc_one(+candidate: P113DCandidate, +rest: List<&2,P113DCandidate>, +index: P113ITable, +counts: KDef, +done: KDef, +slot: U32, +acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match candidate:
    case P113DCandidate{+function,+error,+calls}:
      +name = p126sc_name(function)
      nt_choose(List<&2,P113DCandidate>,Bool.not(String.eq(dk(p111v_get(done,name)),"Absent")),
        u => p126sc_walk(rest,index,counts,done,U32.inc(slot),acc),
        u => nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p126sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
          v => p126sc_found(candidate,function,rest,index,counts,done,slot,acc,p126sc_partner(calls,function,index,counts,slot,done)),
          v => p126sc_walk(rest,index,counts,done,U32.inc(slot),Con{candidate,acc})))

@unsafe
def p126sc_walk(candidates,index,counts,done,slot,acc):
  match candidates:
    case Nil{}: nt_reverse(P113DCandidate,acc,[])
    case Con{candidate,rest}: p126sc_one(candidate,rest,index,counts,done,slot,acc)

@unsafe
def p126sc_candidates_counted(+candidates: List<&2,P113DCandidate>, +counts: KDef) -> List<&2,P113DCandidate>:
  p126sc_walk(candidates,p126sc_index(candidates,counts,P113IEmpty{}),counts,missing(),0,[])

@unsafe
def p126sc_candidates(+candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  p126sc_candidates_counted(candidates,p126sc_counts(candidates,missing(),0))
