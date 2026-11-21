# Equation patterns operate on checked, first-order, non-erased functions.
# A role denotes the *same* resolved declaration throughout the equation graph.
# Binder references are lexical positions. Source spellings are immaterial.
type P205Pattern is Data:
  L205{+inner: P205Pattern}
  B205{+value: P205Pattern, +inner: P205Pattern}
  V205{+depth: U32}
  R205{+role: String}
  N205{+tag: String, +name: String, +kids: List<&2,P205Pattern>}

type P205Equation is Data:
  P205Equation{+signature: List<&2,String>, +pattern: P205Pattern}

@unsafe
def p205_var_at(+id: U32, ids: List<&2,U32>, +depth: U32) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{x,xs}: kc(Bool,U32.is_eq(depth,0),u => U32.is_eq(id,x),u => p205_var_at(id,xs,U32.sub(depth,1)))

@unsafe
def p205_role(+roles: KDef, +key: String, +name: String) -> Maybe<&2,KDef>:
  +old = dk(p111v_get(roles,key))
  kc(Maybe<&2,KDef>,String.eq(old,"Absent"),u => Some{p111v_put(roles,key,name,0,0)},
    u => kc(Maybe<&2,KDef>,String.eq(old,name),v => Some{roles},v => None{}))

@unsafe
def p205_fields(ps: List<&2,P205Pattern>, ts: List<&2,KTerm>, +env: List<&2,U32>, state: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match state:
    case None{}: None{}
    case Some{roles}: p205_fields_found(ps,ts,env,roles)

@unsafe
def p205_fields_found(ps: List<&2,P205Pattern>, ts: List<&2,KTerm>, +env: List<&2,U32>, +roles: KDef) -> Maybe<&2,KDef>:
  match ps ts:
    case Nil{} Nil{}: Some{roles}
    case Con{p,pr} Con{t,tr}: p205_fields(pr,tr,env,p205_match(p,j_strip(t),env,roles))
    case _ _: None{}

@unsafe
def p205_bind_body(p: P205Pattern, t: KTerm, env: List<&2,U32>, state: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match state:
    case None{}: None{}
    case Some{roles}: p205_match(p,j_strip(t),env,roles)

@unsafe
def p205_match(p: P205Pattern, +t: KTerm, +env: List<&2,U32>, +roles: KDef) -> Maybe<&2,KDef>:
  match p:
    case L205{inner}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Lam") && U32.is_ne(qt(t),0) && U32.is_eq(terms_len(ks(t)),1),
        u => p205_match(inner,j_strip(kid(t,0)),Con{ix(t),env},roles),u => None{})
    case B205{value,inner}:
      +b = kid(t,0)
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Let") && p98_tag_eq(b,"Bind") && U32.is_ne(qt(b),0) &&
          U32.is_eq(terms_len(ks(t)),2) && U32.is_eq(terms_len(ks(b)),1),
        u => p205_bind_body(inner,kid(t,1),Con{ix(b),env},p205_match(value,j_strip(kid(b,0)),env,roles)),u => None{})
    case V205{depth}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Var") && p205_var_at(ix(t),env,depth),u => Some{roles},u => None{})
    case R205{role}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,"Ref") && List.is_empty(&2,KTerm,ks(t)),u => p205_role(roles,role,nm(t)),u => None{})
    case N205{tag,name,children}:
      kc(Maybe<&2,KDef>,p98_tag_eq(t,tag) && String.eq(nm(t),name) && List.is_empty(&2,String,rm(t)),
        u => p205_fields(children,ks(t),env,Some{roles}),u => None{})

@unsafe
def p205_ty(+t: KTerm, +kind: String) -> Bool:
  kc(Bool,String.eq(kind,"Strings"),u => p98_tag_eq(t,"ADT") && String.eq(nm(t),"List") &&
      U32.is_eq(terms_len(ks(t)),2) && p98_tag_eq(kid(t,0),"Qua") && U32.is_eq(qt(kid(t,0)),2) &&
      p198e_owner(kid(t,1),"String"),u => p198e_owner(t,kind))

@unsafe
def p205_signature(+t: KTerm, args: List<&2,String>) -> Bool:
  match args:
    case Con{arg,Nil{}}: p205_ty(t,arg)
    case Con{arg,rest}: p98_tag_eq(t,"All") && U32.is_ne(qt(t),0) && p205_ty(kid(t,0),arg) && p205_signature(kid(t,1),rest)
    case _: False{}

@unsafe
def p205_verify(+book: List<&2,KDef>, state: Maybe<&2,KDef>, +role: String, eqn: P205Equation) -> Maybe<&2,KDef>:
  match state eqn:
    case Some{+roles} P205Equation{args,pattern}:
      +d = lookup(book,dk(p111v_get(roles,role)))
      kc(Maybe<&2,KDef>,String.eq(dk(d),"Def") && U32.is_eq(dx(d),0) && (Bool.not(db(d)) || String.eq(dn(d),"String.append")) && p205_signature(dt(d),args),
        u => p205_match(pattern,j_strip(dv(d)),[],roles),u => None{})
    case _ _: None{}

@unsafe
def p205_ok(state: Maybe<&2,KDef>) -> Bool:
  match state:
    case Some{x}: True{}
    case None{}: False{}

@unsafe
def p205_law(+book: List<&2,KDef>, +rep: String, +join: String, +split: String) -> Bool:
  +r0 = p111v_put(p111v_put(p111v_put(missing(),"repeat",rep,0,0),"join",join,0,0),"split",split,0,0)
  +r1 = p205_verify(book,Some{r0},"repeat",p205_repeat_equation())
  +r2 = p205_verify(book,r1,"join",p205_join_equation())
  +r3 = p205_verify(book,r2,"split",p205_split_equation())
  +r4 = p205_verify(book,r3,"join_rest",p205_join_rest_equation())
  +r5 = p205_verify(book,r4,"pick",p205_pick_equation())
  +r6 = p205_verify(book,r5,"push",p205_push_equation())
  p205_ok(p205_verify(book,r6,"append",p205_append_equation())) && j_primitive_definition(book,lookup(book,"U32.is_eq"),2)

# The only reordered arguments are already-evaluated variables and literals.
# If a temporary is eliminated, neither delimiter may depend on that binding.
@unsafe
def p205_atom(+t: KTerm, +bound: KTerm) -> Bool:
  core_literal(t) || (p98_tag_eq(t,"Var") && Bool.not(p98_tag_eq(bound,"Bind") && U32.is_eq(ix(t),ix(bound))))

@unsafe
def p205_pair(+name: String, a: KTerm, b: KTerm) -> KTerm:
  app(app(ref(name),a),b)

@unsafe
def p205_attempt(+book: List<&2,KDef>, +out: KTerm, +bound: KTerm) -> KTerm:
  +join = j_call_spine(out,[])
  kc(KTerm,U32.is_eq(terms_len(ks(join)),2),u => p205_inner(book,join,j_call_spine(kid(join,1),[]),bound),u => atom("Absent"))

@unsafe
def p205_inner(+book: List<&2,KDef>, +join: KTerm, +split: KTerm, +bound: KTerm) -> KTerm:
  +input = j_strip(kid(split,1))
  +target = kc(KTerm,p98_tag_eq(bound,"Bind"),u => kid(bound,0),u => input)
  +rep = j_call_spine(target,[])
  kc(KTerm,U32.is_eq(terms_len(ks(split)),2) && U32.is_eq(terms_len(ks(rep)),2) &&
    (Bool.not(p98_tag_eq(bound,"Bind")) || (p98_tag_eq(input,"Var") && U32.is_eq(ix(input),ix(bound)))) &&
    p205_atom(j_strip(kid(join,0)),bound) && p205_atom(j_strip(kid(split,0)),bound),
    u => kc(KTerm,p205_law(book,nm(rep),nm(join),nm(split)),
      v => p205_pair(nm(rep),kid(rep,0),p205_pair(nm(join),kid(join,0),p205_pair(nm(split),kid(split,0),kid(rep,1)))),
      v => atom("Absent")),
    u => atom("Absent"))

@unsafe
def p205_rewrap(+original: KTerm, +child: KTerm, +prefix: List<&2,KTerm>) -> KTerm:
  kc(KTerm,p98_tag_eq(child,"Absent"),u => child,u => k_with_children(original,List.append(&2,KTerm,prefix,[child])))

@unsafe
def p205_tail(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(t,"Lam"),u => p205_rewrap(t,p205_tail(book,kid(t,0)),[]),u =>
  kc(KTerm,p98_tag_eq(t,"Let"),v => p205_lets(book,t,ks(t),[]),v => p205_attempt(book,t,atom("Absent"))))

@unsafe
def p205_lets(+book: List<&2,KDef>, +parent: KTerm, xs: List<&2,KTerm>, +prev: List<&2,KTerm>) -> KTerm:
  match xs:
    case Con{+b,Con{+body,Nil{}}}:
      +fused = kc(KTerm,p98_tag_eq(b,"Bind"),u => p205_attempt(book,body,b),u => atom("Absent"))
      kc(KTerm,p98_tag_eq(fused,"Absent"),u => p205_rewrap(parent,p205_tail(book,body),nt_reverse(KTerm,Con{b,prev},[])),
        u => kc(KTerm,List.is_empty(&2,KTerm,prev),v => fused,v => p205_rewrap(parent,fused,nt_reverse(KTerm,prev,[]))))
    case Con{b,rest}: p205_lets(book,parent,rest,Con{b,prev})
    case _: atom("Absent")

# Keep only successful edits. Most requests reuse the original list and skip a
# second layout check. The kernel checks the changed body in its source context.
@unsafe
def p205_checked_body(+context: List<&2,KDef>, +raw: KDef, +body: KTerm) -> KDef:
  kc(KDef,p98_tag_eq(body,"Absent"),u => missing(),u => p205_recheck(context,dg_event_output(raw,body)))

@unsafe
def p205_recheck(+context: List<&2,KDef>, +changed: KDef) -> KDef:
  +result = check_definition_body(kw_initial(context),changed,0)
  kc(KDef,good(result),u => ka_def(context,dg_event_output(changed,ct(result))),u => missing())

@unsafe
def p205_returns_string(+t: KTerm) -> Bool:
  kc(Bool,p98_tag_eq(t,"All"),u => p205_returns_string(kid(t,1)),u => p198e_owner(t,"String"))

@unsafe
def p205_update(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  p205_checked_body(context,raw,p205_tail(context,dv(raw)))

@unsafe
def p205_decls(+context: List<&2,KDef>, defs: List<&2,KDef>, +edits: KDef) -> KDef:
  match defs:
    case Nil{}: edits
    case Con{+d,rest}:
      +change = kc(KDef,String.eq(dk(d),"Def") && Bool.not(db(d)) && U32.is_eq(dx(d),0) &&
        p205_returns_string(dt(d)),u => p205_update(context,lookup(context,dn(d))),u => missing())
      p205_decls(context,rest,kc(KDef,String.eq(dk(change),"Absent"),u => edits,u =>
        index_set(edits,change,index_hash(dn(change),2166136261),32)))

@unsafe
def p205_overlay(defs: List<&2,KDef>, +edits: KDef) -> List<&2,KDef>:
  match defs:
    case Nil{}: []
    case Con{+d,rest}:
      Con{nc_context_pick(d,p111v_get(edits,dn(d))),p205_overlay(rest,edits)}

@unsafe
def p205_candidate(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +candidate: List<&2,KDef>) -> P86Plan:
  kc(P86Plan,String.is_empty(jl_checked_error(context,candidate,["main"],stops)),
    u => P86PlanReady{nr_prepare_annotated(context,candidate),verdict},u => P86PlanReady{nr_prepare_annotated(context,original),verdict})

@unsafe
def p205_ready(+context: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +original: List<&2,KDef>, +edits: KDef) -> P86Plan:
  kc(P86Plan,String.eq(dk(edits),"Absent"),u => P86PlanReady{nr_prepare_annotated(context,original),verdict},
    u => p205_candidate(context,stops,verdict,original,p205_overlay(original,edits)))
