# Phase154 private direct producer. The reference boundary is p113d_candidate,
# not the wider product/direct compiler. No old whole-function IR is built.
# Internal NC_Binding words are empty only for canonical v_<id> locals; empty
# means P154Binder{id}. Other entry spellings remain explicit. Existing liveness,
# ownership-kind, erasure and bounded core-selection algorithms are reused.
# Only fixed primitive/static/test snippets cross the old scalar IR boundary.
# The final decoder, verification and destruction remain charged by the caller.

type P154DTarget is Data:
  P154DReturn{}
  P154DLocal{+name: P154Name}

type P154DCode is Data:
  P154DCode{+body: List<&2,P154DStmt>, +fresh: U32, +error: String, +calls: List<&2,String>}

type P154ValueCode is Data:
  P154ValueCode{+body: List<&2,P154Stmt>, +word: P154Value, +error: String}

type P154Partition is Data:
  P154Partition{+live: List<&2,NC_Binding>, +drop: List<&2,P154Stmt>}

# Preserve entry spelling unless it is precisely the id's canonical local.
# Generated bindings are private and always use the empty numeric marker.
@unsafe
def p154d_env(params: List<&2,NC_Binding>) -> List<&2,NC_Binding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{+id,+word,kind},rest}:
      Con{NC_Binding{id,nt_choose(String,String.eq(word,"v_" ++ U32.show(id)),u => "",u => word),kind},p154d_env(rest)}

@unsafe
def p154d_name(+id: U32, +word: String) -> P154Name:
  nt_choose(P154Name,String.is_empty(word),u => P154Binder{id},u => p154c_name(word))

@unsafe
def p154d_local(+id: U32, env: List<&2,NC_Binding>) -> P154Value:
  match env:
    case Nil{}: P154Local{P154Named{"NATIVE_UNBOUND_VARIABLE"}}
    case Con{NC_Binding{at,word,kind},rest}:
      nt_choose(P154Value,U32.is_eq(id,at),u => P154Local{p154d_name(at,word)},u => p154d_local(id,rest))

@unsafe
def p154d_values(args: List<&2,KTerm>, +env: List<&2,NC_Binding>) -> List<&2,P154Value>:
  match args:
    case Nil{}: []
    case Con{head,rest}: Con{p154d_local(ix(head),env),p154d_values(rest,env)}

def p154d_state() -> P154Arg:
  P154Arg{N111Ptr{},P154Local{P154Named{"state"}}}

def p154d_scratch() -> P154Arg:
  P154Arg{N111Ptr{},P154Local{P154Named{"scratch"}}}

def p154d_u32(value: U32) -> P154Arg:
  P154Arg{N111U32{},P154Const{value,0}}

def p154d_word(value: P154Value) -> P154Arg:
  P154Arg{N111U64{},value}

@unsafe
def p154d_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P154Partition) -> P154Partition:
  match parts:
    case P154Partition{+live,+drop}:
      nt_choose(P154Partition,used,u => P154Partition{Con{NC_Binding{id,word,kind},live},drop},
        u => nt_choose(P154Partition,p112to_nonowning(kind),v => P154Partition{live,drop},
          v => P154Partition{live,Con{P154Call{P154Named{"ignored"},N111U64{},"p111_rt_sink",[p154d_state(),p154d_word(P154Local{p154d_name(id,word)})]},drop}}))

@unsafe
def p154d_partition_env(env: List<&2,NC_Binding>, +uses: NU_Set) -> P154Partition:
  match env:
    case Nil{}: P154Partition{[],[]}
    case Con{NC_Binding{+id,word,kind},rest}:
      p154d_partition_step(id,word,kind,nc_uses_has(uses,id),p154d_partition_env(rest,uses))

@unsafe
def p154d_keep(env: List<&2,NC_Binding>, +uses: NU_Set) -> List<&2,P154Stmt>:
  match env:
    case Nil{}: []
    case Con{NC_Binding{+id,+word,kind},+rest}:
      nt_choose(List<&2,P154Stmt>,nc_uses_has(uses,id) && Bool.not(p112to_nonowning(kind)),
        u => Con{P154Call{p154d_name(id,word),N111U64{},"p111_rt_keep",[p154d_state(),p154d_word(P154Local{p154d_name(id,word)})]},p154d_keep(rest,uses)},
        u => p154d_keep(rest,uses))

@unsafe
def p154d_binding(+book: List<&2,KDef>, id: U32, +value: KTerm, +env: List<&2,NC_Binding>) -> NC_Binding:
  NC_Binding{id,"",p113_value_kind(book,value,env)}

@unsafe
def p154d_field_kind(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +i: U32) -> N_WordKind:
  nt_choose(N_WordKind,p113n_is_imm(p113n_field_kind(book,mat,count,i)),
    u => N_Imm64{},u => p113df_kind(p113df_mask(mat,count),i,N_W64{}))

@unsafe
def p154d_field_env(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +i: U32, +n: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(i,count),u => [],
    u => Con{NC_Binding{nc_id(U32.add(n,i)),"",p154d_field_kind(book,mat,count,i)},p154d_field_env(book,mat,count,U32.inc(i),n)})

@unsafe
def p154d_leaf(value: P111ValueCode) -> P154ValueCode:
  match value:
    case P111ValueCode{body,word,error}: P154ValueCode{p154c_scalars(body),p154c_value(word),error}

@unsafe
def p154d_intrinsic(name: String, values: List<&2,P154Value>) -> P154ValueCode:
  p154d_leaf(p111_intrinsic(name,p154c_decode_values(values)))

@unsafe
def p154d_test(name: String, word: P154Value) -> List<&2,P154Stmt>:
  p154c_scalars(p111_test(name,p154c_decode_value(word)))

@unsafe
def p154d_store(values: List<&2,P154Value>, +index: U32) -> List<&2,P154Stmt>:
  match values:
    case Nil{}: []
    case Con{head,rest}:
      Con{P154Store{N111U64{},P154Local{P154Named{"scratch"}},U32.mul(index,8),head},p154d_store(rest,U32.inc(index))}

@unsafe
def p154d_constructor_general(+name: String, +values: List<&2,P154Value>) -> P154ValueCode:
  +kind = p111_special(name)
  +call = nt_choose(P154Stmt,U32.is_eq(kind,0),
    u => P154Call{P154Named{"value"},N111U64{},"p111_rt_ctor",[p154d_state(),P154Arg{N111U32{},P154CtorId{name}},p154d_scratch(),p154d_u32(nt_count(P154Value,values))]},
    u => P154Call{P154Named{"value"},N111U64{},"p111_rt_special_ctor",[p154d_state(),p154d_u32(kind),p154d_scratch(),p154d_u32(nt_count(P154Value,values))]})
  P154ValueCode{nt_append(P154Stmt,p154d_store(values,0),[call]),P154Local{P154Named{"value"}},""}

@unsafe
def p154d_constructor_single(+name: String, field: P154Value) -> P154ValueCode:
  P154ValueCode{[
    P154Set{P154Named{"p114p_payload"},N111U64{},field},
    P154Store{N111U64{},P154Local{P154Named{"scratch"}},0,P154Local{P154Named{"p114p_payload"}}},
    P154Bin{P154Named{"p114p_fits"},N111U64{},"ule",P154Local{P154Named{"p114p_payload"}},P154Const{4294967295,255}},
    P154If{P154Local{P154Named{"p114p_fits"}},[
      P154Bin{P154Named{"p114p_metadata"},N111U64{},"shl",P154CtorId{name},P154Const{40,0}},
      P154Bin{P154Named{"p114p_metadata"},N111U64{},"or",P154Local{P154Named{"p114p_metadata"}},P154Const{0,16777216}},
      P154Bin{P154Named{"value"},N111U64{},"or",P154Local{P154Named{"p114p_metadata"}},P154Local{P154Named{"p114p_payload"}}}],[
      P154Call{P154Named{"value"},N111U64{},"p111_rt_ctor",[p154d_state(),P154Arg{N111U32{},P154CtorId{name}},p154d_scratch(),p154d_u32(1)]}]}],
    P154Local{P154Named{"value"}},""}

@unsafe
def p154d_constructor(+name: String, +values: List<&2,P154Value>) -> P154ValueCode:
  match values:
    case Con{field,Nil{}}:
      nt_choose(P154ValueCode,p114p_ordinary(name),u => p154d_constructor_single(name,field),u => p154d_constructor_general(name,values))
    case _: p154d_constructor_general(name,values)

@unsafe
def p154d_load_fields(+count: U32, +i: U32, +n: U32) -> List<&2,P154Stmt>:
  nt_choose(List<&2,P154Stmt>,U32.is_eq(count,i),u => [],
    u => Con{P154Load{P154Binder{nc_id(U32.add(n,i))},N111U64{},P154Local{P154Named{"scratch"}},U32.mul(i,8)},p154d_load_fields(count,U32.inc(i),n)})

@unsafe
def p154d_take_general(+name: String, +word: P154Value, +count: U32, +n: U32) -> List<&2,P154Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2,P154Stmt>,U32.is_eq(count,0),u => [],
    u => Con{nt_choose(P154Stmt,U32.is_eq(kind,0),
      v => P154Call{P154Named{"ignored"},N111U64{},"p111_rt_take",[p154d_state(),p154d_word(word),p154d_scratch(),p154d_u32(count)]},
      v => P154Call{P154Named{"ignored"},N111U64{},"p111_rt_special_take",[p154d_state(),p154d_u32(kind),p154d_word(word),p154d_scratch(),p154d_u32(count)]}),p154d_load_fields(count,0,n)})

@unsafe
def p154d_take(+book: List<&2,KDef>, +mat: KTerm, +word: P154Value, +count: U32, +n: U32) -> List<&2,P154Stmt>:
  nt_choose(List<&2,P154Stmt>,p113nm_eligible(book,mat,count),
    u => [P154Bin{P154Binder{nc_id(n)},N111U64{},"sub",word,P154Const{1,0}}],
    u => p154d_take_general(nm(mat),word,count,n))

@unsafe
def p154d_uint(parsed: Maybe<&2,U32>) -> P154ValueCode:
  match parsed:
    case None{}: P154ValueCode{[],P154Const{0,0},"invalid native U32 literal"}
    case Some{value}: P154ValueCode{[],P154Const{value,0},""}

@unsafe
def p154d_body(+code: P154DCode) -> List<&2,P154DStmt>:
  match code:
    case P154DCode{body,fresh,error,calls}: body

@unsafe
def p154d_fresh(+code: P154DCode) -> U32:
  match code:
    case P154DCode{body,fresh,error,calls}: fresh

@unsafe
def p154d_error(+code: P154DCode) -> String:
  match code:
    case P154DCode{body,fresh,error,calls}: error

@unsafe
def p154d_calls(+code: P154DCode) -> List<&2,String>:
  match code:
    case P154DCode{body,fresh,error,calls}: calls

@unsafe
def p154d_prepend(prefix: List<&2,P154Stmt>, code: P154DCode) -> P154DCode:
  match code:
    case P154DCode{body,fresh,error,calls}: P154DCode{nt_append(P154DStmt,p154d_scalars(prefix),body),fresh,error,calls}

def p154d_fail(error: String, n: U32) -> P154DCode:
  P154DCode{[],n,error,[]}

@unsafe
def p154d_join(+first: P154DCode, +second: P154DCode) -> P154DCode:
  P154DCode{nt_append(P154DStmt,p154d_body(first),p154d_body(second)),p154d_fresh(second),
    p111_first(p154d_error(first),p154d_error(second)),nt_append(String,p154d_calls(first),p154d_calls(second))}

@unsafe
def p154d_result(word: P154Value, target: P154DTarget, n: U32) -> P154DCode:
  match target:
    case P154DReturn{}: P154DCode{[P154DResult{[word]}],n,"",[]}
    case P154DLocal{name}: P154DCode{[P154DScalar{P154Set{name,N111U64{},word}}],n,"",[]}

@unsafe
def p154d_emitted(+target: P154DTarget, +n: U32, value: P154ValueCode) -> P154DCode:
  match value:
    case P154ValueCode{body,word,+error}:
      nt_choose(P154DCode,String.is_empty(error),u => p154d_prepend(body,p154d_result(word,target,n)),u => p154d_fail(error,n))

@unsafe
def p154d_branch(condition: P154Value, +yes: P154DCode, +no: P154DCode) -> P154DCode:
  P154DCode{[P154DIf{condition,p154d_body(yes),p154d_body(no)}],p154d_fresh(no),
    p111_first(p154d_error(yes),p154d_error(no)),nt_append(String,p154d_calls(yes),p154d_calls(no))}

@unsafe
def p154d_tail(target: P154DTarget) -> Bool:
  match target:
    case P154DReturn{}: True{}
    case _: False{}

@unsafe
def p154d_call(+name: String, +args: List<&2,P154Value>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  nt_choose(P154DCode,String.eq(name,owner),
    u => nt_choose(P154DCode,p154d_tail(target),u => P154DCode{[P154DAgain{args}],n,"",[]},u => p154d_fail("direct: non-tail self call",n)),
    u => p154d_call_target(name,args,target,n))

@unsafe
def p154d_call_target(+name: String, args: List<&2,P154Value>, target: P154DTarget, n: U32) -> P154DCode:
  match target:
    case P154DReturn{}: P154DCode{[P154DCall{[P154Named{"p113_result"}],name,args},P154DResult{[P154Local{P154Named{"p113_result"}}]}],n,"",[name]}
    case P154DLocal{dest}: P154DCode{[P154DCall{[dest],name,args}],n,"",[name]}

@unsafe
def p154d_value(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>) -> P154ValueCode:
  nt_choose(P154ValueCode,String.eq(tg(t),"NStatic"),u => p154d_leaf(p112s_value(book,t)),u =>
  nt_choose(P154ValueCode,String.eq(tg(t),"Var"),u => P154ValueCode{[],p154d_local(ix(t),env),""},u =>
  nt_choose(P154ValueCode,String.eq(tg(t),"NWord"),u => p154d_uint(U32.read(nm(t))),u =>
  nt_choose(P154ValueCode,String.eq(tg(t),"NCtr"),u => p154d_constructor(nm(t),p154d_values(ks(t),env)),u =>
  nt_choose(P154ValueCode,String.eq(tg(t),"NOp"),u => p154d_intrinsic(nm(t),p154d_values(ks(t),env)),
    u => P154ValueCode{[],P154Const{0,0},"not a native evaluated value"})))))

@unsafe
def p154d_partition(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P154DTarget, +n: U32, parts: P154Partition) -> P154DCode:
  match parts:
    case P154Partition{live,drop}: p154d_prepend(drop,p154d_live(book,t,live,owner,target,n))

@unsafe
def p154d_lower(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  nt_choose(P154DCode,String.eq(tg(t),"Let") || String.eq(tg(t),"NSeqLet"),
    u => p154dl_lower(book,p112_liveness_terms(ks(t)),env,owner,target,n),
    u => p154dl_other(book,t,env,owner,target,n))

@unsafe
def p154d_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  p154dl_live(book,p112_liveness_terms(terms),env,owner,target,n)

@unsafe
def p154d_ref(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  nt_choose(P154DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p154d_fail("direct: escaping or bang reference",n),
    u => p154d_call(p113d_public(book,nm(t)),[],owner,target,n))

@unsafe
def p154d_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  p154dc_direct(book,head,args,env,owner,target,n)

@unsafe
def p154d_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  +head = nd_head(t)
  nt_choose(P154DCode,String.eq(tg(head),"Efq"),
    u => p154d_live(book,head,env,owner,target,n),
    u => p154da_original_app(book,t,env,owner,target,n))

@unsafe
def p154d_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  p154dm_match(book,t,env,owner,target,n)

@unsafe
def p154d_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32, literal: NC_Literal) -> P154DCode:
  match literal:
    case NC_Literal{valid,word}:
      nt_choose(P154DCode,valid,u => p154d_result(P154Const{word,0},target,n),
        u => p154d_lower(book,nc_sequence("NCtr",nm(t),ks(t),[],n),env,owner,target,U32.add(n,terms_len(ks(t)))))

@unsafe
def p154d_nat(+values: List<&2,P154Value>, +target: P154DTarget, +n: U32, offset: Maybe<&2,U32>) -> P154DCode:
  match offset:
    case None{}: p154d_fail("direct: invalid Nat offset",n)
    case Some{value}: p154d_nat_join(p154d_constructor("Succ",values),value,target,n)

@unsafe
def p154d_nat_join(first: P154ValueCode, offset: U32, target: P154DTarget, n: U32) -> P154DCode:
  match first:
    case P154ValueCode{body,word,error}: p154d_prepend(body,p154d_emitted(target,n,p154d_intrinsic("nat_add",[word,P154Const{offset,0}])))

@unsafe
def p154d_live(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  +tag = tg(t)
  nt_choose(P154DCode,String.eq(tag,"NWord") || String.eq(tag,"Var") || String.eq(tag,"NStatic"),u => p154d_emitted(target,n,p154d_value(book,t,env)),u =>
  nt_choose(P154DCode,String.eq(tag,"Ref"),u => p154d_ref(book,t,owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"Ann") || String.eq(tag,"Loc") || String.eq(tag,"Src") || String.eq(tag,"Cut") || String.eq(tag,"Slf") || String.eq(tag,"Ins"),u => p154d_lower(book,kid(t,0),env,owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"App"),u => p154d_app(book,t,env,owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"Let") || String.eq(tag,"NSeqLet"),u => p154d_lets(book,ks(t),env,owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"NNatAdd"),u => p154d_lower(book,nc_sequence("NNatSum",nm(t),ks(t),[],n),env,owner,target,U32.inc(n)),u =>
  nt_choose(P154DCode,String.eq(tag,"NNatSum"),u => p154d_nat(p154d_values(ks(t),env),target,n,U32.read(nm(t))),u =>
  nt_choose(P154DCode,String.eq(tag,"Ctr"),u => p154d_ctor(book,t,env,owner,target,n,nc_literal(t)),u =>
  nt_choose(P154DCode,String.eq(tag,"NCtr") || String.eq(tag,"NOp"),u => p154d_emitted(target,n,p154d_value(book,t,env)),u =>
  nt_choose(P154DCode,String.eq(tag,"NCall"),u => p154d_call(nm(t),p154d_values(ks(t),env),owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"Rfl") || String.eq(tag,"Typ") || String.eq(tag,"All") || String.eq(tag,"Qua") || String.eq(tag,"ADT") || String.eq(tag,"Eql"),u => p154d_result(P154Const{0,0},target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"NMatch"),u => p154d_match(book,t,env,owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tag,"Efq"),u => p154d_prepend([P154Call{P154Named{"ignored"},N111U64{},"p111_rt_fail",[p154d_state(),p154d_u32(4)]}],p154d_result(P154Const{0,0},target,n)),u =>
  nt_choose(P154DCode,String.eq(tag,"Rwt"),u => p154d_lower(book,kid(t,2),env,owner,target,n),
    u => p154d_fail("direct: unsupported core node " ++ tag,n)))))))))))))))

@unsafe
def p154d_candidate(+book: List<&2,KDef>, +name: String) -> P154DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p154d_candidate_code(owner,params,p154d_lower(book,nd_reapply(body,nd_entry_args(params)),p154d_env(params),owner,P154DReturn{},arity))

@unsafe
def p154d_candidate_code(name: String, params: List<&2,NC_Binding>, code: P154DCode) -> P154DCandidate:
  match code:
    case P154DCode{body,fresh,error,calls}: P154DCandidate{P154DFunction{name,params,1,True{},body},error,calls}

@unsafe
def p154dm_original_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  +mat = kid(t,0)
  +arg = kid(t,1)
  +word : P154Value = p154d_local(ix(arg),env)
  +count = nt_choose(U32,U32.is_eq(ix(mat),0),u => nc_field_count(book,nm(mat)),u => U32.sub(ix(mat),1))
  +yes = p154d_lower(book,nd_reapply(nc_field_apps(kid(mat,0),count,0,n),nd_match_rest(t)),
    nt_append(NC_Binding,nc_remove_env(env,ix(arg)),p154d_field_env(book,mat,count,0,n)),owner,target,U32.add(n,count))
  +no = p154d_lower(book,nd_reapply(app(kid(mat,1),arg),nd_match_rest(t)),env,owner,target,p154d_fresh(yes))
  nt_choose(P154DCode,String.eq(nm(mat),"Emit") || String.eq(nm(mat),"Halt"),
    u => p154d_fail("direct: effect match",n),
    u => p154d_prepend(p154d_test(nm(mat),word),p154d_branch(P154Local{P154Named{"match_condition"}},
      p154d_prepend(p154d_take(book,mat,word,count,n),yes),no)))

@unsafe
def p154da_original_app(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  +head = nd_head(t)
  +args = nd_args(t,[])
  +prim = nd_native_call(book,t)
  nt_choose(P154DCode,String.is_empty(prim),
    u =>
  nt_choose(P154DCode,String.eq(tg(head),"Lam"),u => p154d_lower(book,nd_beta(head,args),env,owner,target,n),u =>
  nt_choose(P154DCode,String.eq(tg(head),"Mat"),
    u => nt_choose(P154DCode,U32.is_eq(terms_len(args),1) || nd_match_vars(args),
      v => p154d_lower(book,nd_match_sequence(head,args,[],n),env,owner,target,U32.add(n,terms_len(args))),
      v => p154d_fail("direct: higher-order matcher",n)),u =>
  nt_choose(P154DCode,String.eq(tg(head),"Ref"),u => p154d_ref_app(book,head,args,env,owner,target,n),
    u => p154d_fail("direct: dynamic call head=" ++ tg(head) ++ ":" ++ nm(head),n)))),u => p154d_lower(book,nc_sequence("NOp",prim,args,[],n),env,owner,target,U32.add(n,terms_len(args))))

@unsafe
def p154dl_partition(+book: List<&2,KDef>, +plan: P112Liveness, +owner: String, +target: P154DTarget, +n: U32, parts: P154Partition) -> P154DCode:
  match parts:
    case P154Partition{live,drop}: p154d_prepend(drop,p154dl_live(book,plan,live,owner,target,n))

@unsafe
def p154dl_lower(+book: List<&2,KDef>, +plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  p154dl_partition(book,plan,owner,target,n,p154d_partition_env(env,p112_liveness_uses(plan)))

@unsafe
def p154dl_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  +uses = p112_liveness_uses(rest)
  +value_env = nc_live_env(env,value)
  +held = nc_live_uses(env,uses)
  +first = p154d_lower(book,value,value_env,owner,P154DLocal{P154Binder{id}},n)
  p154d_prepend(p154d_keep(value_env,uses),p154d_join(first,
    p154dl_lower(book,rest,nt_append(NC_Binding,held,[p154d_binding(book,id,value,env)]),owner,target,p154d_fresh(first))))

@unsafe
def p154dl_live(+book: List<&2,KDef>, plan: P112Liveness, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  match plan:
    case P112LivenessEmpty{}: p154d_fail("direct: empty let",n)
    case P112LivenessLeaf{term,uses}: p154d_live(book,term,env,owner,target,n)
    case P112LivenessLet{value,id,uses,rest}: p154dl_let(book,value,rest,env,id,owner,target,n)

@unsafe
def p154dl_other(+book: List<&2,KDef>, +t: KTerm, env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  match env:
    case Nil{}: p154d_live(book,t,[],owner,target,n)
    case Con{head,rest}: p154d_partition(book,t,owner,target,n,p154d_partition_env(Con{head,rest},nc_uses(t)))

@unsafe
def p154dm_row(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +base: U32, +fresh: U32) -> P154DCode:
  +word: P154Name = P154Binder{nc_id(base)}
  +bit: P154Name = P154Binder{nc_id(U32.inc(base))}
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),"",N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),
    u => Con{NC_Binding{nc_id(U32.inc(base)),"",N_W32{}},env},u => env)}
  +prefix : List<&2,P154Stmt> = nt_choose(List<&2,P154Stmt>,U32.is_eq(qt(row),1),
    u => [P154Bin{bit,N111U64{},"shr",P154Local{word},P154Const{ix(row),0}},P154Bin{bit,N111U64{},"and",P154Local{bit},P154Const{1,0}}],u => [])
  p154d_prepend(prefix,p154d_lower(book,kid(row,0),bindings,owner,target,fresh))

@unsafe
def p154dm_join(+row: KTerm, +base: U32, +yes: P154DCode, +no: P154DCode) -> P154DCode:
  +masked: P154Name = P154Named{"p112m_mask_" ++ U32.show(base)}
  +condition: P154Name = P154Named{"p112m_hit_" ++ U32.show(base)}
  p154d_prepend([P154Bin{masked,N111U64{},"and",P154Local{P154Binder{nc_id(base)}},P154Const{p112m_mask(ix(row)),0}},
    P154Bin{condition,N111U64{},"eq",P154Local{masked},P154Const{nw_value(row),0}}],p154d_branch(P154Local{condition},yes,no))

@unsafe
def p154dm_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +base: U32, +yes: P154DCode) -> P154DCode:
  p154dm_join(row,base,yes,p154dm_rows(book,rows,env,owner,target,base,p154d_fresh(yes)))

@unsafe
def p154dm_rows(+book: List<&2,KDef>, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +base: U32, +fresh: U32) -> P154DCode:
  match rows:
    case Nil{}: p154d_prepend([P154Call{P154Named{"ignored"},N111U64{},"p111_rt_fail",[p154d_state(),p154d_u32(4)]}],p154d_result(P154Const{0,0},target,fresh))
    case Con{+row,more}: p154dm_more(book,row,more,env,owner,target,base,p154dm_row(book,row,env,owner,target,base,fresh))

@unsafe
def p154dm_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32, plan: NW_Rows) -> P154DCode:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P154DCode,valid,
        u => p154d_prepend([P154Bin{P154Binder{nc_id(n)},N111U64{},"and",p154d_local(ix(kid(t,1)),env),P154Const{4294967295,0}}],
          p154dm_rows(book,rows,nc_remove_env(env,ix(kid(t,1))),owner,target,n,U32.add(n,3))),
        u => p154d_fail("direct: escaping Word tail retains generic recovery",n))

@unsafe
def p154dm_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32, recognized: NW_Rows) -> P154DCode:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P154DCode,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p154dm_planned(book,t,env,owner,target,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p154d_fail("direct: unrecognized Word rows retain generic recovery",n))

@unsafe
def p154dm_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  nt_choose(P154DCode,nw_applicable(kid(t,0)),
    u => nt_choose(P154DCode,U32.is_lt(n,4294967293) && p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p154dm_recognized(book,t,env,owner,target,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p154d_fail("direct: Word row freshness refusal",n)),
    u => p154dm_original_match(book,t,env,owner,target,n))

@unsafe
def p154db_original_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  nt_choose(P154DCode,U32.is_eq(qt(head),3) || Bool.not(U32.is_eq(terms_len(args),nd_arity(book,nm(head)))),
    u => p154d_fail("direct: partial or bang call",n),
    u => p154d_lower(book,nc_sequence("NCall",p113d_public(book,nm(head)),args,[],n),env,owner,target,U32.add(n,terms_len(args))))

@unsafe
def p154db_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32, +selected: KTerm) -> P154DCode:
  nt_choose(P154DCode,p98_tag_eq(selected,"Absent"),
    u => p154db_original_ref_app(book,head,args,env,owner,target,n),
    u => p154d_lower(book,selected,env,owner,target,U32.add(n,64)))

@unsafe
def p154db_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  nt_choose(P154DCode,U32.is_eq(qt(head),3),
    u => p154db_original_ref_app(book,head,args,env,owner,target,n),
    u => nt_choose(P154DCode,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P154DCode,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p154db_selected(book,head,args,env,owner,target,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p154db_original_ref_app(book,head,args,env,owner,target,n)),
      v => p154db_original_ref_app(book,head,args,env,owner,target,n)))

@unsafe
def p154dc_direct_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32, +selected: KTerm) -> P154DCode:
  nt_choose(P154DCode,String.eq(tg(selected),"Absent"),
    u => p154db_ref_app(book,head,args,env,owner,target,n),
    u => p154d_lower(book,selected,env,owner,target,p113dc_next(book,head,n)))

@unsafe
def p154dc_direct(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P154DTarget, +n: U32) -> P154DCode:
  p154dc_direct_selected(book,head,args,env,owner,target,n,p113dc_plan(book,head,args,env,n))
