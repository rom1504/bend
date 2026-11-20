# Keep preparation, ABI, tables, and all existing public or private body plans
# unchanged unless a concrete source theorem and a compatible H worker agree.
def x198pw_ty(+t: KTerm,+name: String) -> Bool:
  (String.eq(tg(t),"Ref") || String.eq(tg(t),"ADT")) && String.eq(nm(t),name) && List.is_empty(&2,KTerm,ks(t))

@unsafe
def x198pw_tel(+t: KTerm,names: List<&2,String>,+result: String) -> Bool:
  match names:
    case Nil{}: x198pw_ty(t,result)
    case Con{name,rest}: String.eq(tg(t),"All") && U32.is_gt(qt(t),0) && U32.is_eq(terms_len(ks(t)),2) &&
      x198pw_ty(kid(t,0),name) && x198pw_tel(kid(t,1),rest,result)

@unsafe
def x198pw_ctor(+d: KDef,name: String,+fields: List<&2,String>,ty: String) -> Bool:
  String.eq(dk(d),"Ctr") && String.eq(dn(d),name) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),nt_count(String,fields)) && x198pw_tel(dt(d),fields,ty)

@unsafe
def x198pw_layout(cs: List<&2,KDef>,+ty: String,+leaf: String,+node: String) -> Bool:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      (x198pw_ctor(a,leaf,["U32"],ty) && x198pw_ctor(b,node,[ty,ty],ty)) ||
      (x198pw_ctor(b,leaf,["U32"],ty) && x198pw_ctor(a,node,[ty,ty],ty))
    case _: False{}

@unsafe
def x198pw_data(+book: List<&2,KDef>,+ty: String,+leaf: String,+node: String) -> Bool:
  +d = lookup(book,ty)
  String.eq(dk(d),"ADT") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d)) &&
    x198pw_layout(dc(d),ty,leaf,node)

@unsafe
def x198pw_validate_data(+book: List<&2,KDef>,+ty: String,+d: KDef,plan: X198PWPlan) -> X198PWPlan:
  match plan:
    case X198PWNone{}: X198PWNone{}
    case X198PWPlan{+owner,+leaf,+node}:
      +a = nm(nc_unann(dv(d)))
      +b = nm(nc_unann(kid(nc_unann(dv(d)),1)))
      nt_choose(X198PWPlan,(String.eq(nc_ctor_identity(book,a),leaf) && x198pw_data(book,ty,a,b)) ||
          (String.eq(nc_ctor_identity(book,b),leaf) && x198pw_data(book,ty,b,a)),
        u => X198PWPlan{owner,leaf,node},u => X198PWNone{})

@unsafe
def x198pw_checked_plan(+book: List<&2,KDef>,+d: KDef) -> X198PWPlan:
  +ty = nm(kid(dt(d),0))
  nt_choose(X198PWPlan,U32.is_eq(da(d),3) && x198pw_tel(dt(d),[ty,ty,"Bool"],ty),
    u => x198pw_validate_data(book,ty,d,x198pw_candidate(book,d)),u => X198PWNone{})

def x198pw_add(plan: X198PWPlan,acc: List<&2,X198PWPlan>) -> List<&2,X198PWPlan>:
  match plan:
    case X198PWNone{}: acc
    case X198PWPlan{name,leaf,node}: Con{X198PWPlan{name,leaf,node},acc}

# This private map entry is consumed only within this x86 experiment. All
# dispatched function IDs and original data tables were established already.
def x198pw_key(owner: String) -> String: "$p198.pairwise/" ++ owner

@unsafe
def x198pw_owners(scope: List<&2,KDef>,+book: List<&2,KDef>,+acc: List<&2,X198PWPlan>) -> List<&2,X198PWPlan>:
  match scope:
    case Nil{}: acc
    case Con{+d,rest}:
      x198pw_owners(rest,book,nt_choose(List<&2,X198PWPlan>,String.eq(dk(d),"Def") && U32.is_eq(da(d),3) &&
          String.eq(tg(nc_unann(dv(d))),"Mat"),u => x198pw_add(x198pw_checked_plan(book,d),acc),u => acc))

@unsafe
def x198pw_mark(plans: List<&2,X198PWPlan>,ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{X198PWPlan{owner,leaf,node},rest} N111Ids{+fs,cs}:
      +key = x198pw_key("$direct." ++ owner)
      +entry : KDef = KDef{key,"X198PWCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[],False{},False{}}
      x198pw_mark(rest,N111Ids{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

def x198pw_context(+plans: List<&2,X198PWPlan>,ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{x198pw_mark(plans,ids),idx,direct,ready,view,lookups,heap,mode}

@unsafe
def x198pw_cursor(+plans: List<&2,X198PWPlan>,cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,x198pw_context(plans,c),x198pw_cursor(plans,next)}
    case P134Public{ss,c,next}: P134Public{ss,x198pw_context(plans,c),x198pw_cursor(plans,next)}
    case P134Legacy{es,c,next}: P134Legacy{es,x198pw_context(plans,c),x198pw_cursor(plans,next)}
    case p: p

@unsafe
def x198pw_ready(+plans: List<&2,X198PWPlan>,p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,X198PWPlan,plans)),
        u => x198pw_cursor(plans,cursor),u => cursor),error}

@unsafe
def x198pw_annotate(r: NR_Request,+prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      x198pw_ready(x198pw_owners(scope,book,[]),prepared)
