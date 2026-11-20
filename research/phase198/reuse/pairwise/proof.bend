# A closed positive-path proof for a pairwise tree zipper. Roles are bound to
# program declarations at proof time. Variable roles bind to checked binder
# identities; cached substitution hints on Var are not traversed.
type X198PWPattern is Data:
  X198PWCase{+role: String,+body: X198PWPattern}
  X198PWLam{+slot: String,+body: X198PWPattern}
  X198PWVar{+slot: String}
  X198PWCall{+role: String,+args: List<&2,X198PWPattern>}
  X198PWCtr{+role: String,+fields: List<&2,X198PWPattern>}
  X198PWLet2{+a: X198PWPattern,+b: X198PWPattern,+body: X198PWPattern}

type X198PWState is Data:
  X198PWBad{}
  X198PWState{+roles: KDef,+vars: KDef}

type X198PWPlan is Data:
  X198PWNone{}
  X198PWPlan{+owner: String,+leaf: String,+node: String}

def x198pw_name(+map: KDef,+role: String) -> String:
  nm(dt(p111v_get(map,role)))

def x198pw_put(+map: KDef,+role: String,name: String) -> KDef:
  index_set(map,KDef{role,"X198PWName",0,0,kt("Name",name,0,0,[]),atom("Absent"),[],False{},False{}},
    index_hash(role,2166136261),32)

def x198pw_role(+role: String,+value: String,+state: X198PWState) -> X198PWState:
  match state:
    case X198PWState{+roles,vars}:
      +old = x198pw_name(roles,role)
      nt_choose(X198PWState,String.is_empty(value),u => X198PWBad{},u =>
        nt_choose(X198PWState,String.is_empty(old),v => X198PWState{x198pw_put(roles,role,value),vars},
          v => nt_choose(X198PWState,String.eq(old,value),w => state,w => X198PWBad{})))
    case X198PWBad{}: X198PWBad{}

def x198pw_bind(+slot: String,+id: U32,+s: X198PWState) -> X198PWState:
  match s:
    case X198PWState{roles,+vars}:
      +reverse = "#" ++ U32.show(id)
      nt_choose(X198PWState,String.eq(dk(p111v_get(vars,slot)),"Absent") && String.eq(dk(p111v_get(vars,reverse)),"Absent"),
        u => X198PWState{roles,p111v_put(p111v_put(vars,slot,"X198PWVar",id,0),reverse,"X198PWId",0,0)},u => X198PWBad{})
    case _: X198PWBad{}

@unsafe
def x198pw_arm(+t: KTerm,+name: String,+left: U32) -> KTerm:
  +u = nc_unann(t)
  nt_choose(KTerm,U32.is_gt(left,0) && String.eq(tg(u),"Mat") && U32.is_eq(terms_len(ks(u)),2),
    x => nt_choose(KTerm,String.eq(nm(u),name),y => kid(u,0),y => x198pw_arm(kid(u,1),name,U32.sub(left,1))),
    x => atom("Absent"))

@unsafe
def x198pw_spine(+t: KTerm,+acc: List<&2,KTerm>,+left: U32) -> KPChain:
  +u = nc_unann(t)
  nt_choose(KPChain,String.eq(tg(u),"App") && U32.is_gt(left,0) && U32.is_eq(terms_len(ks(u)),2),
    v => x198pw_spine(kid(u,0),Con{kid(u,1),acc},U32.sub(left,1)),v => KPChain{acc,u})

law x198pw_match:
  for +p: X198PWPattern
  for +term: KTerm
  for +state: X198PWState
  X198PWState

@unsafe
def x198pw_seq(patterns: List<&2,X198PWPattern>, terms: List<&2,KTerm>, +state: X198PWState) -> X198PWState:
  match patterns terms state:
    case Nil{} Nil{} _: state
    case Con{p,ps} Con{t,ts} X198PWState{roles,vars}: x198pw_seq(ps,ts,x198pw_match(p,t,state))
    case _ _ _: X198PWBad{}

@unsafe
def x198pw_call_match(role: String,ps: List<&2,X198PWPattern>,chain: KPChain,s: X198PWState) -> X198PWState:
  match chain:
    case KPChain{args,+head}:
      nt_choose(X198PWState,String.eq(tg(head),"Ref") && List.is_empty(&2,KTerm,ks(head)),
        u => x198pw_seq(ps,args,x198pw_role(role,nm(head),s)),u => X198PWBad{})

@unsafe
def x198pw_two_bind(+a: KTerm,+b: KTerm,body: KTerm,pa: X198PWPattern,pb: X198PWPattern,pbody: X198PWPattern,s: X198PWState) -> X198PWState:
  nt_choose(X198PWState,String.eq(tg(a),"Bind") && String.eq(tg(b),"Bind") &&
      U32.is_eq(terms_len(ks(a)),1) && U32.is_eq(terms_len(ks(b)),1),
    u => x198pw_match(pbody,body,x198pw_bind("res1",ix(b),
      x198pw_match(pb,kid(b,0),x198pw_bind("res0",ix(a),x198pw_match(pa,kid(a,0),s))))),
    u => X198PWBad{})

@unsafe
def x198pw_match_term(p: X198PWPattern,+t: KTerm,+state: X198PWState) -> X198PWState:
  match p state:
    case X198PWCase{role,body} X198PWState{roles,vars}:
      x198pw_match(body,x198pw_arm(t,x198pw_name(roles,role),8),state)
    case X198PWLam{slot,body} X198PWState{roles,vars}:
      nt_choose(X198PWState,String.eq(tg(t),"Lam") && U32.is_eq(terms_len(ks(t)),1) && U32.is_gt(qt(t),0),
        u => x198pw_match(body,kid(t,0),x198pw_bind(slot,ix(t),state)),u => X198PWBad{})
    case X198PWVar{slot} X198PWState{roles,vars}:
      +v = p111v_get(vars,slot)
      nt_choose(X198PWState,String.eq(tg(t),"Var") && String.eq(dk(v),"X198PWVar") && U32.is_eq(ix(t),da(v)),
        u => state,u => X198PWBad{})
    case X198PWCall{role,args} X198PWState{roles,vars}: x198pw_call_match(role,args,x198pw_spine(t,[],4),state)
    case X198PWCtr{+role,fields} X198PWState{roles,vars}:
      nt_choose(X198PWState,String.eq(tg(t),"Ctr") && String.eq(nm(t),x198pw_name(roles,role)),
        u => x198pw_seq(fields,ks(t),state),u => X198PWBad{})
    case X198PWLet2{pa,pb,pr} X198PWState{roles,vars}:
      nt_choose(X198PWState,String.eq(tg(t),"Let") && U32.is_eq(terms_len(ks(t)),3),
        u => x198pw_two_bind(kid(t,0),kid(t,1),kid(t,2),pa,pb,pr,state),u => X198PWBad{})
    case _ _: X198PWBad{}

@unsafe
def x198pw_match(p,term,state):
  x198pw_match_term(p,nc_unann(term),state)

def x198pw_v(name: String) -> X198PWPattern: X198PWVar{name}
def x198pw_leaf(v: String) -> X198PWPattern: X198PWCtr{"leaf",[x198pw_v(v)]}
def x198pw_node(l: X198PWPattern,r: X198PWPattern) -> X198PWPattern: X198PWCtr{"node",[l,r]}
def x198pw_two(role: String,x: String,y: String,body: X198PWPattern) -> X198PWPattern:
  X198PWCase{role,X198PWLam{x,X198PWLam{y,body}}}
def x198pw_three(x: String,y: String,z: String,body: X198PWPattern) -> X198PWPattern:
  X198PWLam{x,X198PWLam{y,X198PWLam{z,body}}}
def x198pw_recur(x: String,y: String) -> X198PWPattern:
  X198PWCall{"self",[x198pw_v(x),x198pw_v(y),x198pw_v("d")]}

def x198pw_root_leaf() -> X198PWPattern:
  X198PWCase{"leaf",X198PWLam{"a",X198PWCase{"leaf",X198PWLam{"b",X198PWLam{"d",
    X198PWCall{"leafFunction",[x198pw_v("a"),x198pw_v("b"),x198pw_v("d")]}}}}}}

def x198pw_root_node() -> X198PWPattern:
  x198pw_two("node","a","b",x198pw_two("node","c","d1",X198PWLam{"d",
    X198PWLet2{x198pw_recur("a","c"),x198pw_recur("b","d1"),X198PWCall{"join",[x198pw_v("res0"),x198pw_v("res1")]}}}))

def x198pw_join() -> X198PWPattern:
  x198pw_two("node","a","b",x198pw_two("node","c","d",x198pw_node(
    x198pw_node(x198pw_v("a"),x198pw_v("c")),x198pw_node(x198pw_v("b"),x198pw_v("d")))))

def x198pw_leaf_function() -> X198PWPattern:
  x198pw_three("a","b","d",X198PWCall{"order",[x198pw_v("a"),x198pw_v("b"),
    X198PWCall{"xor",[x198pw_v("d"),X198PWCall{"gt",[x198pw_v("a"),x198pw_v("b")]}]}]})

def x198pw_order(case_: String,a: String,b: String) -> X198PWPattern:
  X198PWLam{"a",X198PWLam{"b",X198PWCase{case_,x198pw_node(x198pw_leaf(a),x198pw_leaf(b))}}}

@unsafe
def x198pw_def(+book: List<&2,KDef>, role: String, +arity: U32, pattern: X198PWPattern, state: X198PWState) -> X198PWState:
  match state:
    case X198PWState{+roles,vars}:
      +d = lookup(book,x198pw_name(roles,role))
      nt_choose(X198PWState,String.eq(dk(d),"Def") && U32.is_eq(da(d),arity) && Bool.not(nc_native_def(d) || nc_foreign(d) || du(d)),
        u => x198pw_match(pattern,dv(d),X198PWState{roles,missing()}),u => X198PWBad{})
    case _: X198PWBad{}

@unsafe
def x198pw_intrinsic(+book: List<&2,KDef>,+roles: KDef, role: String, code: String) -> Bool:
  +d = lookup(book,x198pw_name(roles,role))
  nc_native_def(d) && U32.is_eq(da(d),2) && String.eq(nc_primitive_name(dn(d)),code)

@unsafe
def x198pw_finish(+book: List<&2,KDef>,+owner: String,s: X198PWState) -> X198PWPlan:
  match s:
    case X198PWState{+roles,vars}:
      nt_choose(X198PWPlan,x198pw_intrinsic(book,roles,"xor","bool_xor") && x198pw_intrinsic(book,roles,"gt","u32_is_gt"),
        u => X198PWPlan{owner,nc_ctor_identity(book,x198pw_name(roles,"leaf")),nc_ctor_identity(book,x198pw_name(roles,"node"))},
        u => X198PWNone{})
    case _: X198PWNone{}

@unsafe
def x198pw_family(+book: List<&2,KDef>,+owner: String,+leaf: String,+node: String) -> X198PWPlan:
  +roles = x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(missing(),"self",owner),"leaf",leaf),"node",node),"false","False"),"true","True")
  +leafPath = x198pw_def(book,"self",3,x198pw_root_leaf(),X198PWState{roles,missing()})
  +nodePath = x198pw_def(book,"self",3,x198pw_root_node(),leafPath)
  +zipPath = x198pw_def(book,"join",2,x198pw_join(),nodePath)
  +leafFunc = x198pw_def(book,"leafFunction",3,x198pw_leaf_function(),zipPath)
  +noSwap = x198pw_def(book,"order",3,x198pw_order("false","a","b"),leafFunc)
  x198pw_finish(book,owner,x198pw_def(book,"order",3,x198pw_order("true","b","a"),noSwap))

@unsafe
def x198pw_alternative(book: List<&2,KDef>,owner: String,one: String,two: String,plan: X198PWPlan) -> X198PWPlan:
  match plan:
    case X198PWNone{}: x198pw_family(book,owner,two,one)
    case X198PWPlan{name,leaf,node}: X198PWPlan{name,leaf,node}

@unsafe
def x198pw_second(+book: List<&2,KDef>,+d: KDef,+one: String,+t: KTerm) -> X198PWPlan:
  nt_choose(X198PWPlan,String.eq(tg(t),"Mat") && Bool.not(String.eq(one,nm(t))) && U32.is_eq(terms_len(ks(t)),2),
    u => x198pw_alternative(book,dn(d),one,nm(t),x198pw_family(book,dn(d),one,nm(t))),u => X198PWNone{})

@unsafe
def x198pw_first(+book: List<&2,KDef>,+d: KDef,+t: KTerm) -> X198PWPlan:
  nt_choose(X198PWPlan,String.eq(tg(t),"Mat") && U32.is_eq(terms_len(ks(t)),2),
    u => x198pw_second(book,d,nm(t),nc_unann(kid(t,1))),u => X198PWNone{})

@unsafe
def x198pw_candidate(+book: List<&2,KDef>,+d: KDef) -> X198PWPlan:
  nt_choose(X198PWPlan,String.eq(dk(d),"Def") && U32.is_eq(da(d),3) && Bool.not(db(d) || du(d)),
    u => x198pw_first(book,d,nc_unann(dv(d))),u => X198PWNone{})
