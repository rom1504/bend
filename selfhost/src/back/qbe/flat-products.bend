

@unsafe
def p113p_signature(book: List<&2,KDef>, name: String) -> KDef:
  nq_signature_def(book,name)


@unsafe
def p113p_known(+shape: KTerm) -> Bool:
  String.eq(tg(shape),"NQShape") && U32.is_gt(ix(shape),0) && U32.is_le(ix(shape),8)


@unsafe
def p113p_shapes_valid(shapes: List<&2,KTerm>) -> Bool:
  match shapes:
    case Nil{}: True{}
    case Con{+shape,+rest}: (String.eq(tg(shape),"Absent") || p113p_known(shape)) && p113p_shapes_valid(rest)


@unsafe
def p113p_words(shapes: List<&2,KTerm>, args: List<&2,KTerm>, +env: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match shapes args:
    case Con{+shape,+rest} Con{+arg,+more}:
      nt_append(N111Value,nt_choose(List<&2,N111Value>,p113p_known(shape),
        u => p111_values(ks(arg),env),u => [N111Local{nc_word(ix(arg),env)}]),p113p_words(rest,more,env))
    case _ _: []


@unsafe
def p113p_arguments(+shapes: List<&2,KTerm>, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>) -> P113PArguments:
  nt_choose(P113PArguments,p113p_shapes_valid(shapes) && U32.is_le(nq_shape_words(shapes),32) && nq_args_fit(shapes,args),
    u => P113PArguments{True{},p113p_words(shapes,args,env)},
    u => P113PArguments{False{},[]})

# Both maximum and minimum uses are required: no duplication or conditional
# disappearance of the virtual shell. Dropped/shared/escaping shells use the
# mature ordinary boxed fallback at their original evaluation point.


@unsafe
def p113p_bindable(+body: KTerm, +id: U32) -> Bool:
  U32.is_eq(nq_uses(body,id),1) && U32.is_eq(nq_min_uses(body,id),1)


@unsafe
def p113p_boxed(code: P111ValueCode) -> P113PValueCode:
  match code:
    case P111ValueCode{+body,+value,+error}: P113PValueCode{body,[value],error}


@unsafe
def p113p_transfer(+shape: KTerm, +wanted: KTerm, +values: List<&2,N111Value>) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_shapes_valid([shape,wanted]) && nq_same(shape,wanted) && U32.is_eq(nq_width(shape),nt_count(N111Value,values)),
    u => P113PValueCode{[],values,""},
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"product result shape mismatch"},
      v => nt_choose(P113PValueCode,p113p_known(shape) && U32.is_eq(ix(shape),nt_count(N111Value,values)),
        w => p113p_boxed(p111_constructor(nm(shape),values)),
        w => P113PValueCode{[],[],"opaque product result width mismatch"})))


@unsafe
def p113p_constructor(+name: String, +values: List<&2,N111Value>, +wanted: KTerm) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_known(wanted) && String.eq(nm(wanted),name) && U32.is_eq(ix(wanted),nt_count(N111Value,values)),
    u => P113PValueCode{[],values,""},
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"constructor product shape mismatch"},
      v => p113p_boxed(p111_constructor(name,values))))


@unsafe
def p113p_array_arity(id: U32) -> U32:
  match id:
    case 72: 2
    case 74: 3
    case 75: 1
    case 76: 1
    case _: 0


@unsafe
def p113p_array_pair(+name: String, +count: U32) -> Bool:
  +arity = p113p_array_arity(p111_op_id(name))
  U32.is_gt(arity,0) && U32.is_eq(arity,count)

# Structural signature only. The direct verifier additionally proves that both
# buffers are valid local allocas, with count*8 and16 bytes respectively, and
# prohibits a state pointer masquerading as either buffer.


@unsafe
def p113p_array_call(symbol: String, args: List<&2,N111Arg>) -> Bool:
  p113j_array_call(symbol,args)

@unsafe
def p113p_pair_code(+id: U32, +values: List<&2,N111Value>, +n: U32) -> P113PValueCode:
  +out = "p113p_out_" ++ U32.show(n)
  +first = "p113p_first_" ++ U32.show(n)
  +second = "p113p_second_" ++ U32.show(n)
  P113PValueCode{Con{p113ai_snapshot(values,n),nt_append(N111Stmt,p111_store(values,0),[
    N111Alloca{out,16,8},
    N111Call{"p113p_status_" ++ U32.show(n),N111U64{},"p113_rt_array_pair",
      [p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values)),N111Arg{N111Ptr{},N111Local{out}},p111_u32(2)]},
    N111Set{first,N111U64{},N111Local{"p113ai_array_" ++ U32.show(n)}},
    N111Load{second,N111U64{},N111Local{out},8}])},
    [N111Local{first},N111Local{second}],""}

@unsafe
def p113p_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p126dp_selected(name,values,wanted),
    u => p126dp_code(p111_head(values),p111_head(p111_tail(values)),n),
    u => p126dp_original_primitive(name,values,wanted,n))

# Exact additive direct import: original generic N111 call rules are not changed.

@unsafe
def p113p_test_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => " PASS\n",u => " FAIL\n")


@unsafe
def p113p_test_call(+id: U32, +count: U32, +input: String, +output: String, +outputs: U32) -> List<&2,N111Arg>:
  [p111_state(),p111_u32(id),N111Arg{N111Ptr{},N111Local{input}},p111_u32(count),N111Arg{N111Ptr{},N111Local{output}},p111_u32(outputs)]


@unsafe
def p113p_test_values(code: P113PValueCode, +width: U32, +error: Bool) -> Bool:
  match code:
    case P113PValueCode{body,values,+message}: U32.is_eq(nt_count(N111Value,values),width) && nt_choose(Bool,error,u => Bool.not(String.is_empty(message)),u => String.is_empty(message))


@unsafe
def p113p_control_report() -> String:
  +pair = kt("NQShape","Tuple",2,0,[])
  p113p_test_row("layout-one",p113p_known(kt("NQShape","C",1,0,[]))) ++
  p113p_test_row("layout-eight",p113p_known(kt("NQShape","C",8,0,[]))) ++
  p113p_test_row("layout-zero-refuses",Bool.not(p113p_known(kt("NQShape","C",0,0,[])))) ++
  p113p_test_row("layout-nine-refuses",Bool.not(p113p_known(kt("NQShape","C",9,0,[])))) ++
  p113p_test_row("array-get",p113p_array_pair("array_get",2)) ++
  p113p_test_row("array-swap",p113p_array_pair("array_swap",3)) ++
  p113p_test_row("array-size",p113p_array_pair("array_size",1)) ++
  p113p_test_row("array-clone",p113p_array_pair("array_clone",1)) ++
  p113p_test_row("array-set-boxed",Bool.not(p113p_array_pair("array_set",3))) ++
  p113p_test_row("wrong-arity-refuses",Bool.not(p113p_array_pair("array_get",1))) ++
  p113p_test_row("exact-import",p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"scratch","p113p_out_1",2))) ++
  p113p_test_row("state-input-refuses",Bool.not(p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"state","p113p_out_1",2)))) ++
  p113p_test_row("state-output-refuses",Bool.not(p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"scratch","state",2)))) ++
  p113p_test_row("wrong-output-count-refuses",Bool.not(p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"scratch","p113p_out_1",1)))) ++
  p113p_test_row("exact-vector",p113p_test_values(p113p_transfer(pair,pair,[N111Const{1,0},N111Const{2,0}]),2,False{})) ++
  p113p_test_row("wrong-shape-refuses",p113p_test_values(p113p_transfer(pair,kt("NQShape","Other",2,0,[]),[N111Const{1,0},N111Const{2,0}]),0,True{})) ++
  p113p_test_row("boxing-boundary",p113p_test_values(p113p_transfer(pair,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{1,0},N111Const{2,0}]),1,False{})) ++
  p113p_test_row("width-mismatch-refuses",p113p_test_values(p113p_transfer(pair,pair,[N111Const{1,0}]),0,True{})) ++
  p113p_test_row("one-field-constructor-mismatch-refuses",p113p_test_values(p113p_constructor("Other",[N111Const{1,0}],kt("NQShape","C",1,0,[])),0,True{})) ++
  p113p_test_row("one-field-primitive-mismatch-refuses",p113p_test_values(p113p_primitive("array_size",[N111Const{1,0}],kt("NQShape","C",1,0,[]),0),0,True{}))


@unsafe
def p113pl_shape(+target: P113PTarget) -> KTerm:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: shape


@unsafe
def p113pl_owner(+target: P113PTarget) -> String:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: owner


@unsafe
def p113pl_signatures(+target: P113PTarget) -> List<&2,KDef>:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: signatures


@unsafe
def p113pl_tail(+target: P113PTarget) -> Bool:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: tail


@unsafe
def p113pl_local(+target: P113PTarget, destinations: List<&2,String>, shape: KTerm) -> P113PTarget:
  match target:
    case P113PTarget{old,prior,tail,owner,signatures}: P113PTarget{destinations,shape,False{},owner,signatures}

# Only the mature semantic shape query consumes this view. No NC_Code or C
# expression is generated, read or interpreted by the structured product path.


@unsafe
def p113pl_view(+target: P113PTarget) -> NC_Target:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: NC_Destination{destinations,shape,"",owner,[],tail,signatures}


@unsafe
def p113pl_names(+base: String, +count: U32, +i: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(i,count),u => [],u => Con{base ++ "_" ++ U32.show(i),p113pl_names(base,count,U32.inc(i))})


def p113pl_locals(names: List<&2,String>) -> List<&2,N111Value>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{N111Local{name},p113pl_locals(rest)}


def p113pl_sets(names: List<&2,String>, values: List<&2,N111Value>) -> List<&2,N111Stmt>:
  match names values:
    case Con{name,rest} Con{value,more}: Con{N111Set{name,N111U64{},value},p113pl_sets(rest,more)}
    case _ _: []


@unsafe
def p113pl_done(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target),u => p118t_finish(values,n),
    u => p118t_original_done(values,target,n))

@unsafe
def p113pl_emitted(+target: P113PTarget, +n: U32, value: P113PValueCode) -> P113DCode:
  match value:
    case P113PValueCode{body,values,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113pl_done(values,target,n)),u => p113d_fail(error,n))


@unsafe
def p113pl_output(+shape: KTerm, +values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target),
    u => p118t_completed(n,p113p_transfer(shape,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},values)),
    u => p113pl_emitted(target,n,p113p_transfer(shape,p113pl_shape(target),values)))

@unsafe
def p113pl_boxed(value: P111ValueCode, +target: P113PTarget, +n: U32) -> P113DCode:
  match value:
    case P111ValueCode{body,word,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[word],target,n)),u => p113d_fail(error,n))


@unsafe
def p113pl_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target) && String.eq(name,p113pl_owner(target)),
    u => nt_choose(P113DCode,String.eq(tg(shape),"Absent"),
      v => P113DCode{[P113DAgain{p118t_tail_args(args)}],n,"",[]},
      v => p113d_fail("TRMC self call must retain boxed ABI",n)),
    u => p118t_original_call_result(name,args,shape,target,n))

law p113pl_lower:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  P113DCode


law p113pl_live:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  P113DCode


@unsafe
def p113pl_partition(+book: List<&2,KDef>, +t: KTerm, +target: P113PTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113pl_live(book,t,live,target,n))


@unsafe
def p113pl_lower(book,t,env,target,n):
  nt_choose(P113DCode,String.eq(tg(t),"Let") || String.eq(tg(t),"NSeqLet"),
    u => p113px_lower(book,p112_liveness_terms(ks(t)),env,target,n),
    u => p113px_other(book,t,env,target,n))

@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = nq_bundle_params(ix(shape),n)
  +bundle = kt("NQBundle",nm(shape),0,0,nd_entry_args(params))
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,nc_words(params),shape),U32.add(n,ix(shape)))
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,nc_uses(body)),p113d_join(first,
    p113pl_lower(book,subst(body,id,bundle),nt_append(NC_Binding,nc_live_env(env,body),params),target,p113d_fresh(first)))),u => first)

@unsafe
def p113pl_bind_boxed(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113pl_lower(book,body,nt_append(NC_Binding,nc_live_uses(env,uses),[p113_binding(book,id,value,env)]),target,p113d_fresh(first)))),u => first)

@unsafe
def p113pl_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => p126dp_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape) && p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113pl_bind_boxed(book,value,body,env,id,target,n))

@unsafe
def p113pl_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113px_live(book,p112_liveness_terms(terms),env,target,n)

@unsafe
def p113pl_call(+book: List<&2,KDef>, +name: String, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +info = lookup(p113pl_signatures(target),name)
  nt_choose(P113DCode,String.eq(tg(dv(info)),"NQSig") && nq_args_fit(ks(dv(info)),args),
    u => p113pl_call_result(nm(dv(info)),p113p_words(ks(dv(info)),args,env),dt(info),target,n),
    u => nt_choose(P113DCode,nq_has_bundle(args),
      v => p113pl_lower(book,nq_opaque_args("NPCall",name,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113pl_call_result(p113d_public(book,name),p111_values(args,env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n)))


@unsafe
def p113pl_ref(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p113d_fail("product escaping or bang reference",n),
    u => p113pl_call(book,nm(t),[],env,target,n))


@unsafe
def p113pl_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113dc_product(book,head,args,env,target,n)

@unsafe
def p113pl_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,String.eq(tg(head),"Efq"),
    u => p113pl_live(book,head,env,target,n),u =>
  nt_choose(P113DCode,String.is_empty(prim),
    u =>
  nt_choose(P113DCode,String.eq(tg(head),"Lam"),u => p113pl_lower(book,nd_beta(head,args),env,target,n),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nq_match_args(args),
      v => p113pl_lower(book,nd_match_sequence(head,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113d_fail("product higher-order matcher",n)),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Ref"),u => p113pl_ref_app(book,head,args,env,target,n),
    u => p113d_fail("product dynamic call",n)))),u => p113pl_lower(book,nc_sequence("NOp",prim,args,[],n),env,target,U32.add(n,terms_len(args)))))


@unsafe
def p113pl_match_boxed(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113pm_match(book,t,env,target,n)

@unsafe
def p113pl_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  nt_choose(P113DCode,String.eq(tg(arg),"NQBundle"),
    u => nt_choose(P113DCode,String.eq(nm(mat),nm(arg)) && U32.is_eq(ix(mat),U32.inc(terms_len(ks(arg)))),
      v => p113pl_lower(book,nd_reapply(kid(mat,0),nt_append(KTerm,ks(arg),nd_match_rest(t))),
        nt_append(NC_Binding,nq_remove_fields(env,ks(arg)),p113df_bundle_env(mat,arg,env)),target,n),
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
  nt_choose(P113DCode,p118t_eligible(t,target,n),u =>
    p113pl_lower(book,ntr_sequence(nm(t),terms_len(ntr_prefix(ks(t))),
      nt_append(KTerm,ntr_prefix(ks(t)),nd_args(ntr_last(ks(t)),[])),[],n),
      env,target,U32.add(n,U32.add(terms_len(ntr_prefix(ks(t))),ix(p113pl_shape(target))))),
    u => p118t_original_ctor(book,t,env,target,n,literal))

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
  nt_choose(P113DCode,String.eq(tg(t),"NTRCons"),u => p118t_extend(t,env,target,n),
    u => p118t_original_live(book,t,env,target,n))

@unsafe
def p113pl_candidate_code(name: String, params: List<&2,NC_Binding>, shape: KTerm, public: Bool, code: P113DCode) -> P113DCandidate:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCandidate{P113DFunction{name,params,nq_width(shape),public,body},error,calls}


@unsafe
def p113pl_boxed_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  p126s_candidate(book,name,signatures,p126s_plan(book,lookup(book,name)))

@unsafe
def p113pl_flat_entry(+book: List<&2,KDef>, +name: String, +info: KDef, +signatures: List<&2,KDef>, entry: NQ_Entry) -> P113DCandidate:
  match entry:
    case NQ_Entry{params,+args,+fresh}:
      +typed = nk_typed_bindings(params,nf_expand_kinds(ks(dv(info)),nf_worker_kinds(book,name,da(info))))
      +route = nm(dv(info))
      +shape = dt(info)
      +body = nc_compact_definition(book,lookup(book,name),fresh)
      p113pl_candidate_code(route,typed,shape,False{},
        p113pl_lower(book,nd_reapply(body,args),typed,P113PTarget{[],shape,True{},route,signatures},fresh))


@unsafe
def p113pl_flat_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +info = lookup(signatures,name)
  p113pl_flat_entry(book,name,info,signatures,nq_entry(ks(dv(info)),0,da(info)))


@unsafe
def p113pl_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +info = lookup(signatures,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),
        u => nt_append(P113DCandidate,p121f_selected(book,name,signatures,p121f_plan(book,definition)),
          nt_choose(List<&2,P113DCandidate>,String.eq(tg(dv(info)),"NQSig"),
            v => Con{p113pl_flat_candidate(book,name,signatures),p113pl_candidates(book,rest,bangs,signatures)},
            v => p113pl_candidates(book,rest,bangs,signatures))),
        u => p113pl_candidates(book,rest,bangs,signatures))

@unsafe
def p113pl_plan(+book: List<&2,KDef>, +names: List<&2,String>) -> List<&2,P113DFunction>:
  p113d_passes(p126sc_candidates(p113pl_candidates(book,names,nc_bangs_names(book,names),
    book_cached(nq_signatures(book,names),0))),missing(),[],32)

@unsafe
def p113pl_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P113DLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_finish(p112s_finish(nodes,p111_finish(source,names,p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),p113pl_plan(book,names)),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})


@unsafe
def p113pl_lower_request(request: NR_Request) -> P113DLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113pl_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})


@unsafe
def p113pl_inspect_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,P113DCandidate>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113pl_candidates(book,names,nc_bangs_names(book,names),
          book_cached(nq_signatures(book,names),0)),
        u => p113d_diagnostic_error(error))

@unsafe
def p113pl_inspect_request(request: NR_Request) -> List<&2,P113DCandidate>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113pl_inspect_prepared(names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => p113d_diagnostic_error(error))

law p171ff_product_match:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  for +mat: KTerm
  P113DCode

@unsafe
def p113pm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt") || nw_applicable(mat),
    u => p113d_fail("product effect or specialized Word match",n),
    u => p171ff_product_match(book,t,env,target,n,mat))

@unsafe
def p113pm_row(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +fresh: U32) -> P113DCode:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),
    u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p113d_prepend(prefix,p113pl_lower(book,kid(row,0),bindings,target,fresh))


law p113pm_rows:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +base: U32
  for +fresh: U32
  P113DCode


@unsafe
def p113pm_join(+row: KTerm, +base: U32, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  p113d_prepend([N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}}],p113d_branch(N111Local{condition},yes,no))

@unsafe
def p113pm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113pm_join(row,base,yes,p113pm_rows(book,rows,env,target,base,p113d_fresh(yes))),u => yes)


@unsafe
def p113pm_rows(book,rows,env,target,base,fresh):
  match rows:
    case Nil{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,fresh))
    case Con{+row,more}: p113pm_more(book,row,more,env,target,base,p113pm_row(book,row,env,target,base,fresh))


@unsafe
def p113pm_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, plan: NW_Rows) -> P113DCode:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P113DCode,valid,
        u => p113d_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p113pm_rows(book,rows,nc_remove_env(env,ix(kid(t,1))),target,n,U32.add(n,3))),
        u => p113d_fail("product: escaping Word tail retains generic recovery",n))


@unsafe
def p113pm_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, recognized: NW_Rows) -> P113DCode:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P113DCode,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p113pm_planned(book,t,env,target,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p113d_fail("product: unrecognized Word rows retain generic recovery",n))


@unsafe
def p113pm_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nw_applicable(kid(t,0)),
    u => nt_choose(P113DCode,U32.is_lt(n,4294967293) && p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p113pm_recognized(book,t,env,target,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p113d_fail("product: Word row freshness refusal",n)),
    u => p113pm_original_match(book,t,env,target,n))


@unsafe
def p113pb_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("product partial or bang call",n),
    u => p113pl_lower(book,nc_sequence("NPCall",nm(head),args,[],n),env,target,U32.add(n,terms_len(args))))


@unsafe
def p113pb_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,p98_tag_eq(selected,"Absent"),
    u => p113pb_original_ref_app(book,head,args,env,target,n),
    u => p113pl_lower(book,selected,env,target,U32.add(n,64)))


@unsafe
def p113pb_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3),
    u => p113pb_original_ref_app(book,head,args,env,target,n),
    u => nt_choose(P113DCode,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P113DCode,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p113pb_selected(book,head,args,env,target,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p113pb_original_ref_app(book,head,args,env,target,n)),
      v => p113pb_original_ref_app(book,head,args,env,target,n)))


@unsafe
def p113px_terms(plan: P112Liveness) -> List<&2,KTerm>:
  match plan:
    case P112LivenessEmpty{}: []
    case P112LivenessLeaf{term,uses}: [term]
    case P112LivenessLet{value,id,uses,rest}: Con{kt("Bind","",id,1,[value]),p113px_terms(rest)}


@unsafe
def p113px_partition(+book: List<&2,KDef>, +plan: P112Liveness, +target: P113PTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113px_live(book,plan,live,target,n))


@unsafe
def p113px_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113px_partition(book,plan,target,n,p111_partition(env,p112_liveness_uses(plan)))

@unsafe
def p113px_boxed(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),n)
  nt_choose(P113DCode,String.is_empty(p113d_error(first)),
    u => p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113px_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),target,p113d_fresh(first)))),u => first)

@unsafe
def p113px_known(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +body = kt("NSeqLet","",0,0,p113px_terms(rest))
  nt_choose(P113DCode,p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))


@unsafe
def p113px_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => p126dp_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape),
    u => p113px_known(book,value,rest,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))

@unsafe
def p113px_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match plan:
    case P112LivenessEmpty{}: p113d_fail("product empty let",n)
    case P112LivenessLeaf{term,uses}: p113pl_live(book,term,env,target,n)
    case P112LivenessLet{value,id,uses,rest}: p113px_let(book,value,rest,env,id,target,n)


@unsafe
def p113px_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match env:
    case Nil{}: p113pl_live(book,t,[],target,n)
    case Con{head,rest}: p113pl_partition(book,t,target,n,p111_partition(Con{head,rest},nc_uses(t)))

@unsafe
def p171ff_product_match(book,t,env,target,n,mat):
  +arg = kid(t,1)
  +word: N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113pl_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),target,U32.add(n,count))
  nt_choose(P113DCode,String.is_empty(p113d_error(yes)),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),p113pl_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,target,p113d_fresh(yes)))),u => yes)
