type P205TProduct is Data:
  P205TProduct{+book: List<&2,KDef>,+constructors: List<&2,N_Constructor>}

def p205t_owner(+role: String,+roles: List<&2,KTerm>) -> String:
  nm(p205t_find(role,roles))

def p205t_def(+book: List<&2,KDef>,+key: String,+shape: P205TExpr,+st: P205TMatch) -> P205TMatch:
  match st:
    case P205TNo{}: P205TNo{}
    case P205TYes{+r,+v}:
      +name = p205t_owner(key,r)
      +d = lookup(book,name)
      +f = ns_body(book,name)
      nt_choose(P205TMatch,String.eq(dk(d),"Def") && Bool.not(du(d) || db(d) || nc_foreign(d)) &&
          String.eq(dk(f),"NativeErasedBody"),
        u => p205t_match(shape,dv(f),P205TYes{r,[]}),u => P205TNo{})

def p205t_group(+book: List<&2,KDef>,+entry: KTerm) -> P205TMatch:
  +s0 = p205t_match(p205t_entry(),entry,P205TYes{[],[]})
  +s1 = p205t_def(book,"1",p205t_finish(),s0)
  +s2 = p205t_def(book,"2",p205t_down(),s1)
  +s3 = p205t_def(book,"3",p205t_step(),s2)
  +s4 = p205t_def(book,"4",p205t_push(),s3)
  p205t_def(book,"5",p205t_pop(),s4)

def p205t_inside(+name: String,+r: List<&2,KTerm>) -> Bool:
  String.eq(name,p205t_owner("1",r)) || String.eq(name,p205t_owner("2",r)) ||
    String.eq(name,p205t_owner("3",r)) || String.eq(name,p205t_owner("4",r)) ||
    String.eq(name,p205t_owner("5",r))

@unsafe
def p205t_mentions(+todo: List<&2,KTerm>,+r: List<&2,KTerm>) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{+h,+rest}:
      nt_choose(Bool,String.eq(tg(h),"Ref"),u => p205t_inside(nm(h),r) || p205t_mentions(rest,r),
        u => p205t_mentions(nt_choose(List<&2,KTerm>,String.eq(tg(h),"Var"),v => rest,
          v => nt_append(KTerm,ks(h),rest)),r))

def p205t_yes(+x: P205TMatch) -> Bool:
  match x:
    case P205TYes{+r,+v}: True{}
    case _: False{}

@unsafe
def p205t_closed(+book: List<&2,KDef>,+ns: List<&2,String>,+r: List<&2,KTerm>) -> Bool:
  match ns:
    case Nil{}: True{}
    case Con{+n,+t}:
      +f = ns_body(book,n)
      +d = lookup(book,n)
      nt_choose(Bool,p205t_inside(n,r),u => p205t_closed(book,t,r),
        u => nt_choose(Bool,String.eq(dk(f),"NativeErasedBody"),
          v => (Bool.not(p205t_mentions([dv(f)],r)) || p205t_yes(p205t_match(p205t_entry(),dv(f),P205TYes{r,[]}))) &&
            p205t_closed(book,t,r),
          v => (nc_native_def(d) || nc_foreign(d)) && p205t_closed(book,t,r)))

@unsafe
def p205t_small(+ns: List<&2,String>,+left: U32) -> Bool:
  match ns:
    case Nil{}: True{}
    case Con{+h,+t}: nt_choose(Bool,U32.is_eq(left,0),u => False{},u => p205t_small(t,U32.sub(left,1)))

@unsafe
def p205t_scan(+book: List<&2,KDef>,+ns: List<&2,String>) -> P205TMatch:
  match ns:
    case Nil{}: P205TNo{}
    case Con{+n,+t}:
      +f = ns_body(book,n)
      +b = dv(f)
      +can = String.eq(dk(f),"NativeErasedBody") && U32.is_eq(da(f),3) &&
        String.eq(tg(b),"Lam") && String.eq(tg(kid(b,0)),"Lam") && String.eq(tg(kid(kid(b,0),0)),"Lam")
      +r = nt_choose(P205TMatch,can,u => p205t_group(book,b),u => P205TNo{})
      nt_choose(P205TMatch,p205t_yes(r),u => r,u => p205t_scan(book,t))

law p205t_build:
  for +pattern: P205TExpr
  for +r: List<&2,KTerm>
  for +base: U32
  KTerm

@unsafe
def p205t_builds(+ps: List<&2,P205TExpr>,+r: List<&2,KTerm>,+base: U32) -> List<&2,KTerm>:
  match ps:
    case Nil{}: []
    case Con{+p,+t}: Con{p205t_build(p,r,base),p205t_builds(t,r,base)}

@unsafe
def p205t_build(pattern,r,base):
  match pattern:
    case P205TExpr{+tag,+op,+n,+i,+q,+ps}:
      +binder = U32.is_eq(op,1) || U32.is_eq(op,2)
      +id = nt_choose(U32,binder,u => U32.add(base,i),u => i)
      +name = nt_choose(String,binder,u => "$p205v" ++ U32.show(id),
        u => nt_choose(String,U32.is_eq(op,3),v => p205t_owner(n,r),v => n))
      kt(tag,name,id,q,p205t_builds(ps,r,base))

def p205t_value(+d: KDef,+v: KTerm) -> KDef:
  KDef{dn(d),dk(d),da(d),dx(d),dt(d),v,dc(d),db(d),du(d)}

def p205t_children(+d: KDef,+cs: List<&2,KDef>) -> KDef:
  KDef{dn(d),dk(d),da(d),dx(d),dt(d),dv(d),cs,db(d),du(d)}

def p205t_install_idx(+idx: KDef,+d: KDef,+v: KTerm) -> KDef:
  index_set(idx,p205t_value(d,v),index_hash(dn(d),2166136261),32)

def p205t_left_tag() -> String: "$private.p205.spine.left"
def p205t_right_tag() -> String: "$private.p205.spine.right"

@unsafe
def p205t_write_idx(+book: List<&2,KDef>,+cs: List<&2,N_Constructor>,+r: List<&2,KTerm>,+bound: U32,
    +cache: KDef,+tail: List<&2,KDef>,+source: KDef,+stat: KDef,+more: List<&2,KDef>,+info: List<&2,KDef>) -> P205TProduct:
  match info:
    case Con{+idx,+other}:
      +left = p205t_left_tag()
      +right = p205t_right_tag()
      +roles : List<&2,KTerm> = Con{kt("9",left,0,0,[]),Con{kt("10",right,0,0,[]),r}}
      +push = ns_body(book,p205t_owner("4",r))
      +pop = ns_body(book,p205t_owner("5",r))
      +a = p205t_install_idx(idx,push,p205t_build(p205t_new_push(),roles,U32.inc(bound)))
      +b = p205t_install_idx(a,pop,p205t_build(p205t_new_pop(),roles,U32.add(bound,16)))
      P205TProduct{Con{p205t_children(cache,Con{source,Con{p205t_children(stat,Con{b,other}),more}}),tail},
        nt_append(N_Constructor,cs,[N_Constructor{left,3,True{}},N_Constructor{right,3,True{}}])}
    case _: P205TProduct{book,cs}

@unsafe
def p205t_write_ctx(+book: List<&2,KDef>,+cs: List<&2,N_Constructor>,+r: List<&2,KTerm>,+bound: U32,
    +cache: KDef,+tail: List<&2,KDef>,+fields: List<&2,KDef>) -> P205TProduct:
  match fields:
    case Con{+source,Con{+stat,+more}}:
      nt_choose(P205TProduct,String.eq(dk(cache),"BookCache") && String.eq(dk(stat),"NativeStaticContext") &&
        String.eq(dn(stat),"$native.static"),
        u => p205t_write_idx(book,cs,r,bound,cache,tail,source,stat,more,dc(stat)),
        u => P205TProduct{book,cs})
    case _: P205TProduct{book,cs}

@unsafe
def p205t_write(+book: List<&2,KDef>,+cs: List<&2,N_Constructor>,+r: List<&2,KTerm>,+bound: U32) -> P205TProduct:
  match book:
    case Con{+cache,+tail}: p205t_write_ctx(book,cs,r,bound,cache,tail,dc(cache))
    case _: P205TProduct{book,cs}

@unsafe
def p205t_room(+cs: List<&2,N_Constructor>,+left: U32) -> Bool:
  match cs:
    case Nil{}: True{}
    case Con{+h,+t}: nt_choose(Bool,U32.is_eq(left,0),u => False{},u => p205t_room(t,U32.sub(left,1)))

@unsafe
def p205t_admit(+book: List<&2,KDef>,+names: List<&2,String>,+cs: List<&2,N_Constructor>,+bound: U32,+state: P205TMatch) -> P205TProduct:
  match state:
    case P205TNo{}: P205TProduct{book,cs}
    case P205TYes{+r,+v}:
      nt_choose(P205TProduct,U32.is_lt(bound,3999999900) && p205t_room(cs,65000) &&
          Bool.not(nc_has_ctor(cs,p205t_left_tag()) || nc_has_ctor(cs,p205t_right_tag())) &&
          String.starts_with(p205t_owner("6",r),"$ctor.") && String.starts_with(p205t_owner("7",r),"$ctor.") &&
          String.starts_with(p205t_owner("8",r),"$ctor.") && p205t_closed(book,names,r),
        u => p205t_write(book,cs,r,bound),u => P205TProduct{book,cs})

@unsafe
def p205t_apply(+book: List<&2,KDef>,+names: List<&2,String>,+cs: List<&2,N_Constructor>,+bound: U32) -> P205TProduct:
  nt_choose(P205TProduct,p205t_small(names,512),u => p205t_admit(book,names,cs,bound,p205t_scan(book,names)),
    u => P205TProduct{book,cs})

@unsafe
def p205t_lower(+mode: U32,+source: List<&2,KDef>,+names: List<&2,String>,+p: P205TProduct) -> P167Lowered:
  match p:
    case P205TProduct{+book,+cs}: p168_catalogued(mode,source,book,names,cs)

@unsafe
def p205t_catalogued(+known: Maybe<&2,U32>,+mode: U32,+source: List<&2,KDef>,+book: List<&2,KDef>,
    +names: List<&2,String>,+cs: List<&2,N_Constructor>) -> P167Lowered:
  match known:
    case Some{+bound}: p205t_lower(mode,source,names,p205t_apply(book,names,cs,bound))
    case None{}: p168_catalogued(mode,source,book,names,cs)
