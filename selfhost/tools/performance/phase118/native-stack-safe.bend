# Catalogue-size stack safety. Same accumulator/direct-self-tail-call pattern as
# the qualified Phase114 p114ts repairs. Node predicates and verifier contracts
# are unchanged. Structural nesting may still recurse; linear list length does
# not keep one hosted-language frame per element.

@unsafe
def p118ns_scalars(body: List<&2,N111Stmt>, +direct: Bool, +valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{N111Call{+name,N111U64{},+symbol,+args},Con{N111Return{N111Local{+reply}},Nil{}}}:
      valid && nt_choose(Bool,p118z_transition(symbol),
        u => Bool.not(direct) && String.eq(name,reply) && p118z_scalar(N111Call{name,N111U64{},symbol,args},direct),
        u => p118z_scalar(N111Call{name,N111U64{},symbol,args},direct) && p118z_scalar(N111Return{N111Local{reply}},direct))
    case Con{N111Call{name,typ,+symbol,args},rest}:
      p118ns_scalars(rest,direct,valid && Bool.not(p118z_transition(symbol)) &&
        p118z_scalar(N111Call{name,typ,symbol,args},direct))
    case Con{head,rest}: p118ns_scalars(rest,direct,valid && p118z_scalar(head,direct))

@unsafe
def p118z_scalars(body: List<&2,N111Stmt>, direct: Bool) -> Bool:
  p118ns_scalars(body,direct,True{})

@unsafe
def p118ns_segments(segments: List<&2,N111Segment>, +valid: Bool) -> Bool:
  match segments:
    case Nil{}: valid
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p118ns_segments(rest,valid && U32.is_eq(result,1) && U32.is_le(incoming,1) && p118z_scalars(body,False{}))

@unsafe
def p118z_segments(segments: List<&2,N111Segment>) -> Bool:
  p118ns_segments(segments,True{})

@unsafe
def p118ns_direct(body: List<&2,P113DStmt>, +valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{P113DScalar{stmt},rest}: p118ns_direct(rest,valid && p118z_scalar(stmt,True{}))
    case Con{P113DIf{condition,yes,no},rest}: p118ns_direct(rest,valid && p118z_direct(yes) && p118z_direct(no))
    case Con{stmt,rest}: p118ns_direct(rest,valid)

@unsafe
def p118z_direct(body: List<&2,P113DStmt>) -> Bool:
  p118ns_direct(body,True{})

@unsafe
def p118ns_functions(functions: List<&2,P113DFunction>, +valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p118ns_functions(rest,valid && p118z_direct(body))

@unsafe
def p118z_functions(functions: List<&2,P113DFunction>) -> Bool:
  p118ns_functions(functions,True{})

# Project every node in the original left-to-right order and retain the first
# diagnostic. The old projector always produces fresh=0 and calls=[]; those
# fields remain identical. Reversing each small prefix into an accumulator and
# reversing once at completion preserves every statement/function order.
@unsafe
def p118ns_project_node(stmt: P113DStmt, +ids: N111Ids) -> P113DCode:
  match stmt:
    case P113DScalar{scalar}: p118b_project_call(scalar,ids)
    case P113DIf{condition,yes,no}: p113d_branch(condition,p118b_project(yes,ids),p118b_project(no,ids))
    case _: P113DCode{[stmt],0,"",[]}

@unsafe
def p118ns_project(body: List<&2,P113DStmt>, +ids: N111Ids, reversed: List<&2,P113DStmt>, error: String) -> P113DCode:
  match body:
    case Nil{}: P113DCode{nt_reverse(P113DStmt,reversed,[]),0,error,[]}
    case Con{head,rest}:
      projected = p118ns_project_node(head,ids)
      match projected:
        case P113DCode{prefix,fresh,next_error,calls}:
          p118ns_project(rest,ids,nt_reverse(P113DStmt,prefix,reversed),p111_first(error,next_error))

@unsafe
def p118b_project(body: List<&2,P113DStmt>, ids: N111Ids) -> P113DCode:
  p118ns_project(body,ids,[],"")

@unsafe
def p118ns_project_functions(functions: List<&2,P113DFunction>, +ids: N111Ids, reversed: List<&2,P113DFunction>, error: String) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),error}
    case Con{head,rest}:
      projected = p118b_project_function(head,ids)
      match projected:
        case P118BWorkers{prefix,next_error}:
          p118ns_project_functions(rest,ids,nt_reverse(P113DFunction,prefix,reversed),p111_first(error,next_error))

@unsafe
def p118b_project_functions(functions: List<&2,P113DFunction>, ids: N111Ids) -> P118BWorkers:
  p118ns_project_functions(functions,ids,[],"")

@unsafe
def p118ns_without(functions: List<&2,P113DFunction>, +replaced: KDef, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          next = nt_choose(List<&2,P113DFunction>,String.eq(dk(p111v_get(replaced,name)),"Absent"),
            u => Con{head,reversed},u => reversed)
          p118ns_without(rest,replaced,next)

@unsafe
def p118b_without(functions: List<&2,P113DFunction>, replaced: KDef) -> List<&2,P113DFunction>:
  p118ns_without(functions,replaced,[])

# Inline the old mutually recursive continuation into a direct self tail call.
# Preserve the original first-error stop: no later observer plan is evaluated.
@unsafe
def p118ns_workers(+book: List<&2,KDef>, names: List<&2,String>, +reversed: List<&2,P113DFunction>) -> P118BWorkers:
  match names:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),""}
    case Con{+name,+rest}:
      +plan = no_observer_plan(book,name,True{})
      +workers = nt_choose(P118BWorkers,p118b_eligible(book,plan),
        u => p118b_functions(book,name,plan),u => P118BWorkers{[],""})
      match workers:
        case P118BWorkers{functions,+error}:
          ok = String.is_empty(error)
          match ok:
            case True{}: p118ns_workers(book,rest,nt_reverse(P113DFunction,functions,reversed))
            case False{}: P118BWorkers{[],error}

@unsafe
def p118e_workers(book: List<&2,KDef>, names: List<&2,String>, reversed: List<&2,P113DFunction>) -> P118BWorkers:
  p118ns_workers(book,names,reversed)

@unsafe
def p118ns_ctor_names(ctors: List<&2,N_Constructor>, +hot: List<&2,String>, +reversed: List<&2,String>) -> List<&2,String>:
  match ctors:
    case Nil{}: nt_reverse(String,reversed,[])
    case Con{N_Constructor{+name,+arity,was_hot},rest}:
      next = nt_choose(List<&2,String>,U32.is_gt(arity,0) && p118c_ordinary(name) && Bool.not(nb_contains(hot,"ctor:" ++ name)),
        u => Con{name,reversed},u => reversed)
      p118ns_ctor_names(rest,hot,next)

@unsafe
def p118c_ctor_names(ctors: List<&2,N_Constructor>, hot: List<&2,String>) -> List<&2,String>:
  p118ns_ctor_names(ctors,hot,[])

@unsafe
def p118ns_candidates(+book: List<&2,KDef>, defs: List<&2,KDef>, +hot: List<&2,String>, reversed: List<&2,String>) -> List<&2,String>:
  match defs:
    case Nil{}: nt_reverse(String,reversed,[])
    case Con{+d,rest}:
      prefix = nt_choose(List<&2,String>,String.eq(dk(d),"ADT") &&
        Bool.not(nb_contains(["Nat","U32","F32","Char","Bool","Array","Word.Nil","Word.Con","IO","IO.OP"],dn(d))),
        u => p118c_ctor_names(nc_ctor_specs(book,dc(d),da(d)),hot),u => [])
      p118ns_candidates(book,rest,hot,nt_reverse(String,prefix,reversed))

@unsafe
def p118c_candidates(book: List<&2,KDef>, defs: List<&2,KDef>, hot: List<&2,String>) -> List<&2,String>:
  p118ns_candidates(book,defs,hot,[])

@unsafe
def p118ns_ctors(ctors: List<&2,N_Constructor>, +cold: List<&2,String>, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:
  match ctors:
    case Nil{}: nt_reverse(N_Constructor,reversed,[])
    case Con{N_Constructor{+name,arity,hot},rest}:
      p118ns_ctors(rest,cold,Con{N_Constructor{name,arity,Bool.not(nb_contains(cold,name))},reversed})

@unsafe
def p118c_ctors(ctors: List<&2,N_Constructor>, cold: List<&2,String>) -> List<&2,N_Constructor>:
  p118ns_ctors(ctors,cold,[])

@unsafe
def p118ns_zero_byte(items: List<&2,P111QDatum>, +found: Bool) -> Bool:
  match items:
    case Nil{}: found
    case Con{P111QByte{value},rest}: p118ns_zero_byte(rest,found || U32.is_eq(value,0))
    case Con{item,rest}: p118ns_zero_byte(rest,found)

@unsafe
def p118c_zero_byte(items: List<&2,P111QDatum>) -> Bool:
  p118ns_zero_byte(items,False{})

# Exact mature per-definition observer predicate. In particular trusted AND
# filled foreign permission, native authentication, and Rwt refusal remain.
# Only the new integrated entry uses this loop; mature C/JS policy is untouched.
@unsafe
def p118ns_effect_definition(+d: KDef) -> Bool:
  nt_choose(Bool,nc_native_def(d),u => True{},u => nt_choose(Bool,nc_foreign(d),
    v => no_effect_foreign_allowed(db(d),String.eq(tg(nc_unann(dv(d))),"Foreign"),dn(d)),
    v => String.eq(dk(d),"Def") && no_effect_terms([dv(d)])))

@unsafe
def p118ns_effect_definitions(+valid: Bool, +book: List<&2,KDef>, names: List<&2,String>) -> Bool:
  match valid:
    case False{}: False{}
    case True{}:
      match names:
        case Nil{}: True{}
        case Con{name,rest}:
          p118ns_effect_definitions(p118ns_effect_definition(lookup(book,name)),book,rest)

@unsafe
def p118i_permission(request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p118ns_effect_definitions(True{},book,names)
