# Exact selected Phase117 lowering bodies, renamed only for conservative delegation.

@unsafe
def p118t_original_done(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  match target:
    case P113PTarget{+destinations,+shape,+tail,owner,signatures}:
      +width = nt_count(N111Value,values)
      +temps = p113pl_names("p113p_move_" ++ U32.show(n),width,0)
      nt_choose(P113DCode,U32.is_eq(width,nq_width(shape)),
        u => nt_choose(P113DCode,tail,u => P113DCode{[P113DResult{values}],n,"",[]},u =>
          nt_choose(P113DCode,U32.is_eq(width,nt_count(String,destinations)),
            v => P113DCode{p113d_scalars(nt_append(N111Stmt,p113pl_sets(temps,values),p113pl_sets(destinations,p113pl_locals(temps)))),U32.inc(n),"",[]},
            v => p113d_fail("product destination width mismatch",n))),
        u => p113d_fail("product value width mismatch",n))

@unsafe
def p118t_original_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:
  +names = p113pl_names("p113p_call_" ++ U32.show(n),nq_width(shape),0)
  nt_choose(P113DCode,String.eq(name,p113pl_owner(target)),
    u => nt_choose(P113DCode,p113pl_tail(target) && nq_same(shape,p113pl_shape(target)),
      v => P113DCode{[P113DAgain{args}],n,"",[]},v => p113d_fail("product non-tail self call",n)),
    u => p113d_join(P113DCode{[P113DCall{names,name,args}],U32.inc(n),"",[name]},
      p113pl_output(shape,p113pl_locals(names),target,U32.inc(n))))

@unsafe
def p118t_original_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  match literal:
    case NC_Literal{valid,word}:
      nt_choose(P113DCode,valid,u => p113pl_output(atom("Absent"),[N111Const{word,0}],target,n),
        u => p113pl_lower(book,nc_sequence("NCtr",nm(t),ks(t),[],n),env,target,U32.add(n,terms_len(ks(t)))))

@unsafe
def p118t_original_live(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
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
