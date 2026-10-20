law p113d_lower:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +n: U32
  P113DCode

law p113d_live:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +n: U32
  P113DCode

@unsafe
def p113d_partition(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P113DTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113d_live(book,t,live,owner,target,n))

@unsafe
def p113d_lower(book,t,env,owner,target,n):
  p113d_partition(book,t,owner,target,n,p111_partition(env,nc_uses(t)))

# Unlike p111_let_cut, a local destination owns the computed result directly.
# The original keep/live partition is retained; no frame or register transfer
# is introduced merely because the value contains an ordinary call or branch.
@unsafe
def p113d_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113d_lower(book,body,nt_append(NC_Binding,held,[nk_binding(id,value,env)]),owner,target,p113d_fresh(first))))

@unsafe
def p113d_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match terms:
    case Nil{}: p113d_fail("direct: empty let",n)
    case Con{head,Nil{}}: p113d_lower(book,head,env,owner,target,n)
    case Con{+head,rest}: p113d_let(book,kid(head,0),kt("NSeqLet","",0,0,rest),env,ix(head),owner,target,n)

@unsafe
def p113d_ref(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p113d_fail("direct: escaping or bang reference",n),
    u => p113d_call(p113d_public(book,nm(t)),[],owner,target,n))

@unsafe
def p113d_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("direct: partial or bang call",n),
    u => p113d_lower(book,nc_sequence("NCall",p113d_public(book,nm(head)),args,[],n),env,owner,target,U32.add(n,terms_len(args))))

@unsafe
def p113d_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,Bool.not(String.is_empty(prim)),
    u => p113d_lower(book,nc_sequence("NOp",prim,args,[],n),env,owner,target,U32.add(n,terms_len(args))),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Lam"),u => p113d_lower(book,nd_beta(head,args),env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nd_match_vars(args),
      v => p113d_lower(book,nd_match_sequence(head,args,[],n),env,owner,target,U32.add(n,terms_len(args))),
      v => p113d_fail("direct: higher-order matcher",n)),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Ref"),u => p113d_ref_app(book,head,args,env,owner,target,n),
    u => p113d_fail("direct: dynamic call",n)))))

@unsafe
def p113d_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113d_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p111_field_env(count,0,n)),owner,target,U32.add(n,count))
  +no = p113d_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,owner,target,p113d_fresh(yes))
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt"),
    u => p113d_fail("direct: effect match",n),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p111_take(nm(mat),word,count,n),yes),no)))

@unsafe
def p113d_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  match literal:
    case NC_Literal{valid,word}:
      nt_choose(P113DCode,valid,u => p113d_result(N111Const{word,0},target,n),
        u => p113d_lower(book,nc_sequence("NCtr",nm(t),ks(t),[],n),env,owner,target,U32.add(n,terms_len(ks(t)))))

@unsafe
def p113d_nat(+values: List<&2,N111Value>, +target: P113DTarget, +n: U32, offset: Maybe<&2,U32>) -> P113DCode:
  match offset:
    case None{}: p113d_fail("direct: invalid Nat offset",n)
    case Some{value}: p113d_nat_join(p111_constructor("Succ",values),value,target,n)

@unsafe
def p113d_nat_join(first: P111ValueCode, offset: U32, target: P113DTarget, n: U32) -> P113DCode:
  match first:
    case P111ValueCode{body,word,error}: p113d_prepend(body,p113d_emitted(target,n,p111_intrinsic("nat_add",[word,N111Const{offset,0}])))

@unsafe
def p113d_live(book,t,env,owner,target,n):
  +tag = tg(t)
  nt_choose(P113DCode,String.eq(tag,"NWord") || String.eq(tag,"Var") || String.eq(tag,"NStatic"),u => p113d_emitted(target,n,p113d_value(book,t,env)),u =>
  nt_choose(P113DCode,String.eq(tag,"Ref"),u => p113d_ref(book,t,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Ann") || String.eq(tag,"Loc") || String.eq(tag,"Src") || String.eq(tag,"Cut") || String.eq(tag,"Slf") || String.eq(tag,"Ins"),u => p113d_lower(book,kid(t,0),env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"App"),u => p113d_app(book,t,env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Let") || String.eq(tag,"NSeqLet"),u => p113d_lets(book,ks(t),env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NNatAdd"),u => p113d_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,owner,target,U32.inc(n)),u =>
  nt_choose(P113DCode,String.eq(tag,"NNatSum"),u => p113d_nat(p111_values(ks(t),env),target,n,U32.read(nm(t))),u =>
  nt_choose(P113DCode,String.eq(tag,"Ctr"),u => p113d_ctor(book,t,env,owner,target,n,nc_literal(t)),u =>
  nt_choose(P113DCode,String.eq(tag,"NCtr") || String.eq(tag,"NOp"),u => p113d_emitted(target,n,p113d_value(book,t,env)),u =>
  nt_choose(P113DCode,String.eq(tag,"NCall"),u => p113d_call(nm(t),p111_values(ks(t),env),owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Rfl") || String.eq(tag,"Typ") || String.eq(tag,"All") || String.eq(tag,"Qua") || String.eq(tag,"ADT") || String.eq(tag,"Eql"),u => p113d_result(N111Const{0,0},target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NMatch"),u => p113d_match(book,t,env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Efq"),u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},target,n)),u =>
  nt_choose(P113DCode,String.eq(tag,"Rwt"),u => p113d_lower(book,kid(t,2),env,owner,target,n),
    u => p113d_fail("direct: unsupported core node " ++ tag,n)))))))))))))))
