@unsafe
def p113pl_call(+book: List<&2,KDef>, +name: String, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +info = lookup(p113pl_signatures(target),name)
  nt_choose(P113DCode,String.eq(tg(dv(info)),"NQSig") && nq_args_fit(ks(dv(info)),args),
    u => p113pl_call_result(nm(dv(info)),p113p_words(ks(dv(info)),args,env),dt(info),target,n),
    u => nt_choose(P113DCode,nq_has_bundle(args),
      v => p113pl_lower(book,nq_opaque_args("NPCall",name,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113pl_call_result(p113d_public(book,name),p111_values(args,env),atom("Absent"),target,n)))

@unsafe
def p113pl_ref(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p113d_fail("product escaping or bang reference",n),
    u => p113pl_call(book,nm(t),[],env,target,n))

@unsafe
def p113pl_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("product partial or bang call",n),
    u => p113pl_lower(book,nc_sequence("NPCall",nm(head),args,[],n),env,target,U32.add(n,terms_len(args))))

@unsafe
def p113pl_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,String.eq(tg(head),"Efq"),
    u => p113pl_live(book,head,env,target,n),u =>
  nt_choose(P113DCode,Bool.not(String.is_empty(prim)),
    u => p113pl_lower(book,nc_sequence("NOp",prim,args,[],n),env,target,U32.add(n,terms_len(args))),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Lam"),u => p113pl_lower(book,nd_beta(head,args),env,target,n),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nq_match_args(args),
      v => p113pl_lower(book,nd_match_sequence(head,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113d_fail("product higher-order matcher",n)),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Ref"),u => p113pl_ref_app(book,head,args,env,target,n),
    u => p113d_fail("product dynamic call",n))))))

@unsafe
def p113pl_match_boxed(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word: N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113pl_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p111_field_env(count,0,n)),target,U32.add(n,count))
  +no = p113pl_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,target,p113d_fresh(yes))
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt") || nw_applicable(mat),
    u => p113d_fail("product effect or specialized Word match",n),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p111_take(nm(mat),word,count,n),yes),no)))

@unsafe
def p113pl_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  nt_choose(P113DCode,String.eq(tg(arg),"NQBundle"),
    u => nt_choose(P113DCode,String.eq(nm(mat),nm(arg)) && U32.is_eq(ix(mat),U32.inc(terms_len(ks(arg)))),
      v => p113pl_lower(book,nd_reapply(kid(mat,0),nt_append(KTerm,ks(arg),nd_match_rest(t))),
        nt_append(NC_Binding,nq_remove_fields(env,ks(arg)),nq_field_bindings(ks(arg),env)),target,n),
      v => p113pl_lower(book,nc_mklet(nc_id(n),kt("NQBox",nm(arg),0,0,ks(arg)),
        kt("NMatch","",0,0,Con{mat,Con{var("",nc_id(n)),nd_match_rest(t)}})),env,target,U32.inc(n))),
    u => p113pl_match_boxed(book,t,env,target,n))

@unsafe
def p113pl_operation(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nq_has_bundle(ks(t)),
    u => p113pl_lower(book,nq_opaque_args(tg(t),nm(t),ks(t),[],n),env,target,U32.add(n,terms_len(ks(t)))),
    u => nt_choose(P113DCode,String.eq(tg(t),"NCtr"),
      v => p113pl_emitted(target,n,p113p_constructor(nm(t),p111_values(ks(t),env),p113pl_shape(target))),
      v => p113pl_emitted(target,U32.inc(n),p113p_primitive(nm(t),p111_values(ks(t),env),p113pl_shape(target),n))))

@unsafe
def p113pl_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  match literal:
    case NC_Literal{valid,word}:
      nt_choose(P113DCode,valid,u => p113pl_output(atom("Absent"),[N111Const{word,0}],target,n),
        u => p113pl_lower(book,nc_sequence("NCtr",nm(t),ks(t),[],n),env,target,U32.add(n,terms_len(ks(t)))))

@unsafe
def p113pl_nat(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32, offset: Maybe<&2,U32>) -> P113DCode:
  match offset:
    case None{}: p113d_fail("product invalid Nat offset",n)
    case Some{value}: p113pl_nat_join(p111_constructor("Succ",values),value,target,n)

@unsafe
def p113pl_nat_join(first: P111ValueCode, offset: U32, target: P113PTarget, n: U32) -> P113DCode:
  match first:
    case P111ValueCode{body,word,error}: p113d_prepend(body,p113pl_boxed(p111_intrinsic("nat_add",[word,N111Const{offset,0}]),target,n))

@unsafe
def p113pl_zeroes(+count: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(count,0),u => [],u => Con{N111Const{0,0},p113pl_zeroes(U32.sub(count,1))})

@unsafe
def p113pl_live(book,t,env,target,n):
  +tag = tg(t)
  nt_choose(P113DCode,String.eq(tag,"NWord") || String.eq(tag,"Var") || String.eq(tag,"NStatic"),u => p113pl_boxed(p113d_value(book,t,env),target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NQBundle"),u => p113pl_output(kt("NQShape",nm(t),terms_len(ks(t)),0,[]),p111_values(ks(t),env),target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NQBox"),u => p113pl_boxed(p111_constructor(nm(t),p111_values(ks(t),env)),target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Ref"),u => p113pl_ref(book,t,env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Ann") || String.eq(tag,"Loc") || String.eq(tag,"Src") || String.eq(tag,"Cut") || String.eq(tag,"Slf") || String.eq(tag,"Ins"),u => p113pl_lower(book,kid(t,0),env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"App"),u => p113pl_app(book,t,env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Let") || String.eq(tag,"NSeqLet"),u => p113pl_lets(book,ks(t),env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NNatAdd"),u => p113pl_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,target,U32.inc(n)),u =>
  nt_choose(P113DCode,String.eq(tag,"NNatSum"),u => p113pl_nat(p111_values(ks(t),env),target,n,U32.read(nm(t))),u =>
  nt_choose(P113DCode,String.eq(tag,"Ctr"),u => p113pl_ctor(book,t,env,target,n,nc_literal(t)),u =>
  nt_choose(P113DCode,String.eq(tag,"NCtr") || String.eq(tag,"NOp"),u => p113pl_operation(book,t,env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NPCall"),u => p113pl_call(book,nm(t),ks(t),env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NCall"),u => p113pl_call_result(nm(t),p111_values(ks(t),env),atom("Absent"),target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Rfl") || String.eq(tag,"Typ") || String.eq(tag,"All") || String.eq(tag,"Qua") || String.eq(tag,"ADT") || String.eq(tag,"Eql"),u => p113pl_output(atom("Absent"),[N111Const{0,0}],target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NMatch"),u => p113pl_match(book,t,env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Efq"),u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,n)),u =>
  nt_choose(P113DCode,String.eq(tag,"Rwt"),u => p113pl_lower(book,kid(t,2),env,target,n),
    u => p113d_fail("product unsupported core node " ++ tag,n))))))))))))))))))
