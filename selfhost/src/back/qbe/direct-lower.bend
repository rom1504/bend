

@unsafe
def p113d_body(+code: P113DCode) -> List<&2,P113DStmt>:
  match code:
    case P113DCode{body,fresh,error,calls}: body


@unsafe
def p113d_fresh(+code: P113DCode) -> U32:
  match code:
    case P113DCode{body,fresh,error,calls}: fresh


@unsafe
def p113d_error(+code: P113DCode) -> String:
  match code:
    case P113DCode{body,fresh,error,calls}: error


@unsafe
def p113d_calls(+code: P113DCode) -> List<&2,String>:
  match code:
    case P113DCode{body,fresh,error,calls}: calls


def p113d_scalars(body: List<&2,N111Stmt>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P113DScalar{stmt},p113d_scalars(rest)}


@unsafe
def p113d_prepend(prefix: List<&2,N111Stmt>, code: P113DCode) -> P113DCode:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCode{nt_append(P113DStmt,p113d_scalars(prefix),body),fresh,error,calls}


def p113d_fail(error: String, n: U32) -> P113DCode:
  P113DCode{[],n,error,[]}


@unsafe
def p113d_join(+first: P113DCode, +second: P113DCode) -> P113DCode:
  P113DCode{nt_append(P113DStmt,p113d_body(first),p113d_body(second)),p113d_fresh(second),
    p111_first(p113d_error(first),p113d_error(second)),nt_append(String,p113d_calls(first),p113d_calls(second))}


@unsafe
def p113d_result(word: N111Value, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DResult{[word]}],n,"",[]}
    case P113DLocal{name}: P113DCode{[P113DScalar{N111Set{name,N111U64{},word}}],n,"",[]}


@unsafe
def p113d_emitted(+target: P113DTarget, +n: U32, value: P111ValueCode) -> P113DCode:
  match value:
    case P111ValueCode{body,word,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113d_result(word,target,n)),u => p113d_fail(error,n))


@unsafe
def p113d_branch(condition: N111Value, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  P113DCode{[P113DIf{condition,p113d_body(yes),p113d_body(no)}],p113d_fresh(no),
    p111_first(p113d_error(yes),p113d_error(no)),nt_append(String,p113d_calls(yes),p113d_calls(no))}


@unsafe
def p113d_tail(target: P113DTarget) -> Bool:
  match target:
    case P113DReturn{}: True{}
    case _: False{}


@unsafe
def p113d_public(+book: List<&2,KDef>, +name: String) -> String:
  nt_choose(String,U32.is_eq(nd_arity(book,name),0),u => nc_ref_name(book,name),u => nd_name(nc_ref_name(book,name)))


@unsafe
def p113d_call(+name: String, +args: List<&2,N111Value>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,String.eq(name,owner),
    u => nt_choose(P113DCode,p113d_tail(target),u => P113DCode{[P113DAgain{args}],n,"",[]},u => p113d_fail("direct: non-tail self call",n)),
    u => p113d_call_target(name,args,target,n))


@unsafe
def p113d_call_target(+name: String, args: List<&2,N111Value>, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DCall{["p113_result"],name,args},P113DResult{[N111Local{"p113_result"}]}],n,"",[name]}
    case P113DLocal{dest}: P113DCode{[P113DCall{[dest],name,args}],n,"",[name]}

# Scalar snippets are reused whole, including their own checked shifts and
# branches. The direct path never interprets generated backend text.


@unsafe
def p113d_value(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode,String.eq(tg(t),"NStatic"),
    u => p112s_value(book,t),u => p111_value(t,env))


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
  nt_choose(P113DCode,String.eq(tg(t),"Let") || String.eq(tg(t),"NSeqLet"),
    u => p113dl_lower(book,p112_liveness_terms(ks(t)),env,owner,target,n),
    u => p113dl_other(book,t,env,owner,target,n))

@unsafe
def p113d_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113d_lower(book,body,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),owner,target,p113d_fresh(first))))

@unsafe
def p113d_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dl_live(book,p112_liveness_terms(terms),env,owner,target,n)

@unsafe
def p113d_ref(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p113d_fail("direct: escaping or bang reference",n),
    u => p113d_call(p113d_public(book,nm(t)),[],owner,target,n))


@unsafe
def p113d_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dc_direct(book,head,args,env,owner,target,n)

@unsafe
def p113d_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  nt_choose(P113DCode,String.eq(tg(head),"Efq"),
    u => p113d_live(book,head,env,owner,target,n),
    u => p113da_original_app(book,t,env,owner,target,n))

@unsafe
def p113d_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dm_match(book,t,env,owner,target,n)

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


@unsafe
def p113d_candidate(+book: List<&2,KDef>, +name: String) -> P113DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p113d_candidate_code(owner,params,p113d_lower(book,nd_reapply(body,nd_entry_args(params)),params,owner,P113DReturn{},arity))


@unsafe
def p113d_candidate_code(name: String, params: List<&2,NC_Binding>, code: P113DCode) -> P113DCandidate:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCandidate{P113DFunction{name,params,1,True{},body},error,calls}


@unsafe
def p113d_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),
        u => Con{p113d_candidate(book,name),p113d_candidates(book,rest,bangs)},
        u => p113d_candidates(book,rest,bangs))


@unsafe
def p113d_ready(+index: KDef, +name: String) -> Bool:
  String.eq(dk(p111v_get(index,name)),"P113Direct")


@unsafe
def p113d_deps(calls: List<&2,String>, +index: KDef) -> Bool:
  match calls:
    case Nil{}: True{}
    case Con{head,rest}: p113d_ready(index,head) && p113d_deps(rest,index)


@unsafe
def p113d_pass(candidates: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match candidates:
    case Nil{}: P113DPass{index,functions,nt_reverse(P113DCandidate,waiting,[]),count}
    case Con{+candidate,rest}: p113d_pass_one(candidate,rest,index,functions,waiting,count)


@unsafe
def p113d_pass_one(+candidate: P113DCandidate, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match candidate:
    case P113DCandidate{+function,+error,+calls}: p113d_pass_function(candidate,function,error,calls,rest,index,functions,waiting,count)


@unsafe
def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      nt_choose(P113DPass,Bool.not(String.is_empty(error)) || p113d_ready(index,name),
        u => p113d_pass(rest,index,functions,waiting,count),u =>
        nt_choose(P113DPass,p113d_deps(calls,index),
          v => p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count)),
          v => p113d_pass(rest,index,functions,Con{candidate,waiting},count)))


law p113d_passes:
  for +candidates: List<&2,P113DCandidate>
  for +index: KDef
  for +functions: List<&2,P113DFunction>
  for +fuel: U32
  List<&2,P113DFunction>


@unsafe
def p113d_pass_next(+fuel: U32, pass: P113DPass) -> List<&2,P113DFunction>:
  match pass:
    case P113DPass{index,+functions,waiting,count}:
      nt_choose(List<&2,P113DFunction>,U32.is_eq(count,0),u => nt_reverse(P113DFunction,functions,[]),
        u => p113d_passes(waiting,index,functions,U32.sub(fuel,1)))


@unsafe
def p113d_passes(candidates,index,functions,fuel):
  nt_choose(List<&2,P113DFunction>,U32.is_eq(fuel,0),u => nt_reverse(P113DFunction,functions,[]),
    u => p113d_pass_next(fuel,p113d_pass(candidates,index,functions,[],0)))


@unsafe
def p113d_plan(+book: List<&2,KDef>, +names: List<&2,String>) -> List<&2,P113DFunction>:
  p113d_passes(p113d_candidates(book,names,nc_bangs_names(book,names)),missing(),[],32)


@unsafe
def p113d_finish(original: P112SResult, functions: List<&2,P113DFunction>) -> P113DLowering:
  match original:
    case P112SResult{bundle,error}: P113DLowered{P113DProgram{bundle,functions},error}


@unsafe
def p113d_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P113DLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_finish(p112s_finish(nodes,p111_finish(source,names,p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),p113d_plan(book,names)),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})


@unsafe
def p113d_lower_request(request: NR_Request) -> P113DLowering:
  p114s_lower_request(request)

def p113d_diagnostic_error(error: String) -> List<&2,P113DCandidate>:
  [P113DCandidate{P113DFunction{"$p113.diagnostic",[],1,False{},[]},error,[]}]


@unsafe
def p113d_inspect_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,P113DCandidate>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113d_candidates(book,names,nc_bangs_names(book,names)),
        u => p113d_diagnostic_error(error))


@unsafe
def p113d_inspect_request(request: NR_Request) -> List<&2,P113DCandidate>:
  p113pl_inspect_request(request)

@unsafe
def p113dm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p113d_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p113df_field_env(book,mat,count,0,n)),owner,target,U32.add(n,count))
  +no = p113d_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,owner,target,p113d_fresh(yes))
  nt_choose(P113DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt"),
    u => p113d_fail("direct: effect match",n),
    u => p113d_prepend(p111_test(nm(mat),word),p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p113nm_take(book,mat,word,count,n),yes),no)))

@unsafe
def p113da_original_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P113DCode,String.is_empty(prim),
    u =>
  nt_choose(P113DCode,String.eq(tg(head),"Lam"),u => p113d_lower(book,nd_beta(head,args),env,owner,target,n),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Mat"),
    u => nt_choose(P113DCode,U32.is_eq(terms_len(args),1) || nd_match_vars(args),
      v => p113d_lower(book,nd_match_sequence(head,args,[],n),env,owner,target,U32.add(n,terms_len(args))),
      v => p113d_fail("direct: higher-order matcher",n)),u =>
  nt_choose(P113DCode,String.eq(tg(head),"Ref"),u => p113d_ref_app(book,head,args,env,owner,target,n),
    u => p113d_fail("direct: dynamic call head=" ++ tg(head) ++ ":" ++ nm(head),n)))),u => p113d_lower(book,nc_sequence("NOp",prim,args,[],n),env,owner,target,U32.add(n,terms_len(args))))


@unsafe
def p113dl_partition(+book: List<&2,KDef>, +plan: P112Liveness, +owner: String, +target: P113DTarget, +n: U32, parts: P111Partition) -> P113DCode:
  match parts:
    case P111Partition{live,drop}: p113d_prepend(drop,p113dl_live(book,plan,live,owner,target,n))


@unsafe
def p113dl_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dl_partition(book,plan,owner,target,n,p111_partition(env,p112_liveness_uses(plan)))


@unsafe
def p113dl_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p113d_lower(book,value,value_env,owner,P113DLocal{"v_" ++ U32.show(id)},n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113dl_lower(book,rest,nt_append(NC_Binding,held,[p113_binding(book,id,value,env)]),owner,target,p113d_fresh(first))))

@unsafe
def p113dl_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match plan:
    case P112LivenessEmpty{}: p113d_fail("direct: empty let",n)
    case P112LivenessLeaf{term,uses}: p113d_live(book,term,env,owner,target,n)
    case P112LivenessLet{value,id,uses,rest}: p113dl_let(book,value,rest,env,id,owner,target,n)


@unsafe
def p113dl_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  match env:
    case Nil{}: p113d_live(book,t,[],owner,target,n)
    case Con{head,rest}: p113d_partition(book,t,owner,target,n,p111_partition(Con{head,rest},nc_uses(t)))


@unsafe
def p113dm_row(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +base: U32, +fresh: U32) -> P113DCode:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),
    u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p113d_prepend(prefix,p113d_lower(book,kid(row,0),bindings,owner,target,fresh))


law p113dm_rows:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +base: U32
  for +fresh: U32
  P113DCode


@unsafe
def p113dm_join(+row: KTerm, +base: U32, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  p113d_prepend([N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}}],p113d_branch(N111Local{condition},yes,no))


@unsafe
def p113dm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +base: U32, +yes: P113DCode) -> P113DCode:
  p113dm_join(row,base,yes,p113dm_rows(book,rows,env,owner,target,base,p113d_fresh(yes)))


@unsafe
def p113dm_rows(book,rows,env,owner,target,base,fresh):
  match rows:
    case Nil{}: p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},target,fresh))
    case Con{+row,more}: p113dm_more(book,row,more,env,owner,target,base,p113dm_row(book,row,env,owner,target,base,fresh))


@unsafe
def p113dm_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, plan: NW_Rows) -> P113DCode:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P113DCode,valid,
        u => p113d_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p113dm_rows(book,rows,nc_remove_env(env,ix(kid(t,1))),owner,target,n,U32.add(n,3))),
        u => p113d_fail("direct: escaping Word tail retains generic recovery",n))


@unsafe
def p113dm_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, recognized: NW_Rows) -> P113DCode:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P113DCode,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p113dm_planned(book,t,env,owner,target,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p113d_fail("direct: unrecognized Word rows retain generic recovery",n))


@unsafe
def p113dm_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nw_applicable(kid(t,0)),
    u => nt_choose(P113DCode,U32.is_lt(n,4294967293) && p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p113dm_recognized(book,t,env,owner,target,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p113d_fail("direct: Word row freshness refusal",n)),
    u => p113dm_original_match(book,t,env,owner,target,n))


@unsafe
def p113db_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p113d_fail("direct: partial or bang call",n),
    u => p113d_lower(book,nc_sequence("NCall",p113d_public(book,nm(head)),args,[],n),env,owner,target,U32.add(n,terms_len(args))))


@unsafe
def p113db_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,p98_tag_eq(selected,"Absent"),
    u => p113db_original_ref_app(book,head,args,env,owner,target,n),
    u => p113d_lower(book,selected,env,owner,target,U32.add(n,64)))


@unsafe
def p113db_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3),
    u => p113db_original_ref_app(book,head,args,env,owner,target,n),
    u => nt_choose(P113DCode,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P113DCode,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p113db_selected(book,head,args,env,owner,target,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p113db_original_ref_app(book,head,args,env,owner,target,n)),
      v => p113db_original_ref_app(book,head,args,env,owner,target,n)))


@unsafe
def p113d_verify(program: P113DProgram) -> String:
  p113e_verify(program)


@unsafe
def p113d_chunks(+program: P113DProgram) -> List<&2,String>:
  p113e_checked_chunks(program,p113d_verify(program))


@unsafe
def p113d_text(program: P113DProgram) -> String:
  nt_text_finish(nt_reverse(String,p113d_chunks(program),[]),"")


@unsafe
def p113d_emit_verified(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Direct{program}},
    u => P111Emission{[],"direct structured IR: " ++ error})

@unsafe
def p113d_emit_lowered(result: P113DLowering) -> P111Emission:
  match result:
    case P113DLowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p113d_emit_verified(program,p113d_verify(program)),
        u => P111Emission{[],"direct native lowering: " ++ error})


@unsafe
def p113df_mask(+mat: KTerm, +count: U32) -> U32:
  nt_choose(U32,String.eq(tg(mat),"Mat") && U32.is_eq(ix(mat),U32.inc(count)) && U32.is_le(count,8),
    u => nt_choose(U32,U32.is_lt(qt(mat),U32.shln(1,U32.to_nat(count))),v => qt(mat),v => 0),
    u => 0)

# Keep the existing local names, IDs and full-Term words. Only ownership kind
# changes. The book argument is reserved for an independently admitted Nat
# extension; the scalar certificate already contains its original type proof.


@unsafe
def p113df_field_env(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +i: U32, +n: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(i,count),u => [],
    u => Con{p113n_field_binding(book,mat,count,i,n),p113df_field_env(book,mat,count,U32.inc(i),n)})

@unsafe
def p113df_kind(+mask: U32, +i: U32, +prior: N_WordKind) -> N_WordKind:
  nt_choose(N_WordKind,U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(i))),0),
    u => N_W32{},u => prior)


@unsafe
def p113df_refine(bindings: List<&2,NC_Binding>, +mask: U32, +i: U32) -> List<&2,NC_Binding>:
  match bindings:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{NC_Binding{id,word,p113df_kind(mask,i,kind)},p113df_refine(rest,mask,U32.inc(i))}


@unsafe
def p113df_vars(fields: List<&2,KTerm>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+field,rest}: String.eq(tg(field),"Var") && p113df_vars(rest)

# A virtual product match transfers the same independent fields as a boxed
# take. Refine only the exact matched constructor's variable fields, retaining
# every preexisting kind on an unset bit. No boxing or physical ABI changes.


@unsafe
def p113df_bundle_env(+mat: KTerm, +bundle: KTerm, +env: List<&2,NC_Binding>) -> List<&2,NC_Binding>:
  +fields = ks(bundle)
  +bindings = nq_field_bindings(fields,env)
  nt_choose(List<&2,NC_Binding>,String.eq(tg(bundle),"NQBundle") && String.eq(nm(mat),nm(bundle)) && p113df_vars(fields),
    u => p113df_refine(bindings,p113df_mask(mat,terms_len(fields)),0),
    u => bindings)


@unsafe
def p113dc_definition(+book: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  nt_choose(KTerm,String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => nt_choose(KTerm,U32.is_eq(nd_leading(dv(d),0),arity) && U32.is_le(n,U32.sub(4294967295,arity)),
      v => nd_comb_try(nc_erase(book,dv(d)),args,env,n,arity),
      v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113dc_arity(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  +count = terms_len(args)
  nt_choose(KTerm,U32.is_gt(arity,0) && U32.is_le(arity,8) && U32.is_gt(count,0) && U32.is_le(count,arity) && nd_comb_literal(args),
    u => p113dc_definition(book,lookup(book,nm(head)),args,env,n,arity),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113dc_plan(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> KTerm:
  nt_choose(KTerm,String.eq(tg(head),"Ref") && Bool.not(U32.is_eq(qt(head),3)),
    u => p113dc_arity(book,head,args,env,n,nd_arity(book,nm(head))),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113dc_next(+book: List<&2,KDef>, +head: KTerm, +n: U32) -> U32:
  U32.add(n,nd_arity(book,nm(head)))


@unsafe
def p113dc_generic_selected(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +selected: KTerm) -> P111Code:
  nt_choose(P111Code,String.eq(tg(selected),"Absent"),
    u => p112b_ref_app(book,t,head,args,env,n),
    u => p111_lower(book,selected,env,p113dc_next(book,head,n)))


@unsafe
def p113dc_generic(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p113dc_generic_selected(book,t,head,args,env,n,p113dc_plan(book,head,args,env,n))


@unsafe
def p113dc_direct_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,String.eq(tg(selected),"Absent"),
    u => p113db_ref_app(book,head,args,env,owner,target,n),
    u => p113d_lower(book,selected,env,owner,target,p113dc_next(book,head,n)))


@unsafe
def p113dc_direct(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dc_direct_selected(book,head,args,env,owner,target,n,p113dc_plan(book,head,args,env,n))


@unsafe
def p113dc_product_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,String.eq(tg(selected),"Absent"),
    u => p113pb_ref_app(book,head,args,env,target,n),
    u => p113pl_lower(book,selected,env,target,p113dc_next(book,head,n)))


@unsafe
def p113dc_product(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113dc_product_selected(book,head,args,env,target,n,p113dc_plan(book,head,args,env,n))
