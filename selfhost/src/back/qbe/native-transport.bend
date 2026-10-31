


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
      nt_choose(P113DCode,valid,u => p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{word,0}],target,n),
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
  nt_choose(P113DCode,String.eq(tag,"NCall"),u => p113pl_call_result(nm(t),p111_values(ks(t),env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Rfl") || String.eq(tag,"Typ") || String.eq(tag,"All") || String.eq(tag,"Qua") || String.eq(tag,"ADT") || String.eq(tag,"Eql"),u => p113pl_output({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[N111Const{0,0}],target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"NMatch"),u => p113pl_match(book,t,env,target,n),u =>
  nt_choose(P113DCode,String.eq(tag,"Efq"),u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,n)),u =>
  nt_choose(P113DCode,String.eq(tag,"Rwt"),u => p113pl_lower(book,kid(t,2),env,target,n),
    u => p113d_fail("product unsupported core node " ++ tag,n))))))))))))))))))

@unsafe
def p118t_target(+target: P113PTarget) -> Bool:
  p113pl_tail(target) && String.eq(tg(p113pl_shape(target)),"P118TRMC")


def p118t_state() -> List<&2,N111Value>:
  [N111Local{"p118_root"},N111Local{"p118_parent"}]


@unsafe
def p118t_tail_args(args: List<&2,N111Value>) -> List<&2,N111Value>:
  nt_append(N111Value,args,p118t_state())


@unsafe
def p118t_eligible(+term: KTerm, +target: P113PTarget, +n: U32) -> Bool:
  +shape = p113pl_shape(target)
  p118t_target(target) && ntr_eligible(term,
    NC_Destination{[],{KTerm{"NTRMC", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},"",nm(shape),nd_entry_params(ix(shape),0),True{},[]},n)


@unsafe
def p118t_prefix(values: List<&2,N111Value>, +count: U32) -> List<&2,N111Value>:
  match values count:
    case _ 0: []
    case Con{head,rest} _: Con{head,p118t_prefix(rest,U32.sub(count,1))}
    case _ _: []


@unsafe
def p118t_rest(+values: List<&2,N111Value>, +count: U32) -> List<&2,N111Value>:
  match values count:
    case _ 0: values
    case Con{head,rest} _: p118t_rest(rest,U32.sub(count,1))
    case _ _: []


@unsafe
def p118t_finish(values: List<&2,N111Value>, +n: U32) -> P113DCode:
  match values:
    case Con{word,Nil{}}:
      +result = "p118_finished_" ++ U32.show(n)
      P113DCode{[
        P113DScalar{N111Call{result,N111U64{},"p118_rt_finish",
          [p111_state(),p111_word(N111Local{"p118_root"}),p111_word(N111Local{"p118_parent"}),p111_word(word)]}},
        P113DResult{[N111Local{result}]}],U32.inc(n),"",[]}
    case _: p113d_fail("TRMC terminal result must be boxed",n)


@unsafe
def p118t_completed(+n: U32, value: P113PValueCode) -> P113DCode:
  match value:
    case P113PValueCode{body,values,+error}:
      nt_choose(P113DCode,String.is_empty(error),
        u => p113d_prepend(body,p118t_finish(values,n)),u => p113d_fail(error,n))


@unsafe
def p118t_extend(+t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +values = p111_values(ks(t),env)
  +count = ix(t)
  +node = "p118_node_" ++ U32.show(n)
  +root = "p118_next_root_" ++ U32.show(n)
  +empty = "p118_root_empty_" ++ U32.show(n)
  +valid = p118t_target(target) && nd_match_vars(ks(t)) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    U32.is_eq(terms_len(ks(t)),U32.add(count,ix(p113pl_shape(target)))) && U32.is_eq(p111_special(nm(t)),0)
  nt_choose(P113DCode,valid,u =>
    p113d_prepend(nt_append(N111Stmt,p111_store(p118t_prefix(values,count),0),[
      N111Call{node,N111U64{},"p118_rt_extend",[p111_state(),p111_word(N111Local{"p118_parent"}),
        N111Arg{N111U32{},N111CtorId{nm(t)}},p111_scratch(),p111_u32(count)]},
      N111Bin{empty,N111U64{},"eq",N111Local{"p118_root"},N111Const{0,0}},
      N111If{N111Local{empty},[N111Set{root,N111U64{},N111Local{node}}],[N111Set{root,N111U64{},N111Local{"p118_root"}}]}]),
      P113DCode{[P113DAgain{nt_append(N111Value,p118t_rest(values,count),[N111Local{root},N111Local{node}])}],U32.inc(n),"",[]}),
    u => p113d_fail("TRMC invalid private construction",n))


@unsafe
def p118t_has_extend(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{name,typ,symbol,args}},rest}:
      String.eq(symbol,"p118_rt_extend") || p118t_has_extend(rest)
    case Con{P113DIf{condition,yes,no},rest}: p118t_has_extend(yes) || p118t_has_extend(no) || p118t_has_extend(rest)
    case Con{stmt,rest}: p118t_has_extend(rest)


@unsafe
def p118t_ready(+name: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, code: P113DCode) -> List<&2,P113DCandidate>:
  match code:
    case P113DCode{+body,fresh,+error,+calls}:
      +private = "$p118.trmc." ++ name
      +arity = nt_count(NC_Binding,params)
      +hidden : List<&2,NC_Binding> = [NC_Binding{nc_id(arity),"p118_root",N_W64{}},NC_Binding{nc_id(U32.inc(arity)),"p118_parent",N_W64{}}]
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p118t_has_extend(body),u => [
        P113DCandidate{P113DFunction{private,nt_append(NC_Binding,params,hidden),1,False{},body},"",calls},
        P113DCandidate{P113DFunction{name,params,1,True{},[
          P113DCall{["p118_public_result"],private,nt_append(N111Value,p113pl_locals(nc_words(params)),[N111Const{0,0},N111Const{0,0}])},
          P113DResult{[N111Local{"p118_public_result"}]}]},"",[private]}],u => [old])


@unsafe
def p118t_retry(+book: List<&2,KDef>, +name: String, +old: P113DCandidate) -> List<&2,P113DCandidate>:
  match old:
    case P113DCandidate{P113DFunction{+owner,+params,result,public,body},+error,calls}:
      +arity = nt_count(NC_Binding,params)
      nt_choose(List<&2,P113DCandidate>,String.eq(error,"product non-tail self call") &&
        Bool.not(String.starts_with(name,"$")) && U32.is_ge(arity,1) && U32.is_le(arity,8),u =>
        p118t_retry_body(book,name,owner,params,old,nc_compact_definition(book,lookup(book,name),0)),u => [old])


@unsafe
def p118t_retry_body(+book: List<&2,KDef>, +name: String, +owner: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, +body: KTerm) -> List<&2,P113DCandidate>:
  +arity = nt_count(NC_Binding,params)
  nt_choose(List<&2,P113DCandidate>,U32.is_gt(nq_layout_remaining([body],513),0),u =>
    p118t_ready(owner,params,old,p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,
      P113PTarget{[],kt("P118TRMC",name,arity,0,[]),True{},owner,[]},arity)),u => [old])


@unsafe
def p118t_import(+symbol: String) -> Bool:
  String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_finish")


@unsafe
def p118t_import_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p118_rt_extend"),u =>
    p118t_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
    String.eq(symbol,"p118_rt_finish") && p111v_args(args,[3,2,2,2],live,ids))


@unsafe
def p118t_extend_contract(+args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +constructor: KDef) -> Bool:
  +count = p111v_literal(p111v_arg(args,4))
  p111v_args(args,[3,2,1,3,1],live,ids) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    Bool.not(String.eq(dk(constructor),"Absent")) && U32.is_eq(da(constructor),U32.inc(count)) &&
    p111v_buffer(args,3,count,live)


@unsafe
def p118t_import_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) && p118t_import_contract(symbol,args,live,ids),
    name,schema,live,"TRMC import signature/constructor/capacity mismatch")


@unsafe
def p118q_sized(+stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,4))
      nt_choose(N111Stmt,String.eq(symbol,"p118_rt_extend") &&
        U32.is_eq(nt_count(N111Arg,args),5) && U32.is_ge(count,1) && U32.is_le(count,7),
        u => N111Call{name,N111U64{},"p118_rt_extend" ++ U32.show(count),p118xs_prefix(args)},
        u => p118xs_original(stmt))
    case _: p118xs_original(stmt)

@unsafe
def p118e_workers(book: List<&2,KDef>, names: List<&2,String>, reversed: List<&2,P113DFunction>) -> P118BWorkers:
  p118ns_workers(True{},book,names,reversed,"")


@unsafe
def p118e_worker_result(book: List<&2,KDef>, names: List<&2,String>, reversed: List<&2,P113DFunction>, workers: P118BWorkers) -> P118BWorkers:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P118BWorkers,String.is_empty(error),
        u => p118e_workers(book,names,nt_reverse(P113DFunction,functions,reversed)),
        u => P118BWorkers{[],error})

# Empty additions need no second signature index. Nonempty additions retain the
# independent borrowed-function structural checker in p118b_compose, including
# exact constructor/arity checking of every readonly runtime import.

@unsafe
def p118e_emit_functions(+original: P113AProgram, +functions: List<&2,P113DFunction>) -> P111Emission:
  match functions:
    case Nil{}: P134Planned{P134Admitted{original}}
    case Con{head,rest}: p118b_compose(original,P118BWorkers{functions,""})

@unsafe
def p118e_emit_workers(original: P113AProgram, workers: P118BWorkers) -> P111Emission:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p118e_emit_functions(original,functions),
        u => P111Emission{[],"borrowed profile: " ++ error})

# This is an internal continuation of successful request-bound verification.
# Unknown sharing retains the entire original metadata, rather than asserting
# that an empty cold list is an independently established certificate.

@unsafe
def p118e_cold(+original: P113AProgram, book: List<&2,KDef>, source: List<&2,KDef>, +hot: List<&2,String>) -> P113AProgram:
  nt_choose(P113AProgram,nb_contains(hot,"*"),u => original,
    u => p118c_apply_verified(original,p118c_candidates(book,source,hot)))


@unsafe
def p118e_permitted(request: NR_Request, original: P113AProgram) -> P111Emission:
  p128br_prepare(request,original,True{})

@unsafe
def p118e_prepare(+request: NR_Request, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p118e_permitted(request,original),
        u => p118i_prepare(request,original))

@unsafe
def p118e_verified(request: NR_Request, original: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p118e_prepare(request,original),
    u => P111Emission{[],"array structured IR: " ++ error})


@unsafe
def p118e_lowered(request: NR_Request, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p118e_verified(request,program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})

@unsafe
def p118u_divmod(+dest: String, +buffer: String, +op: U32, +site: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +raw = p111q_local(p114t_name(site,"u_raw"))
      +left = p111q_local(p114t_name(site,"u_left"))
      +right = p111q_local(p114t_name(site,"u_right"))
      +right_word = p111q_local(p114t_name(site,"u_right_word"))
      +ptr = p111q_local(p114t_name(site,"u_ptr"))
      +ok = p111q_local(p114t_name(site,"u_nonzero"))
      +answer = p111q_local(p114t_name(site,"u_answer"))
      +target = p111q_local(dest)
      +yes = p111q_label(site)
      +no = p111q_label(U32.inc(site))
      +done = p111q_label(U32.add(site,2))
      text = raw ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++
        left ++ " =w copy " ++ raw ++ "\n" ++
        ptr ++ " =l add " ++ p111q_local(buffer) ++ ", 8\n" ++
        right_word ++ " =l loadl " ++ ptr ++ "\n" ++
        right ++ " =w copy " ++ right_word ++ "\n" ++
        ok ++ " =w cnew " ++ right ++ ", 0\n" ++
        "jnz " ++ ok ++ ", " ++ yes ++ ", " ++ no ++ "\n" ++ yes ++ "\n" ++
        answer ++ " =w " ++ nt_choose(String,U32.is_eq(op,18),u => "udiv",u => "urem") ++
          " " ++ left ++ ", " ++ right ++ "\n" ++
        target ++ " =l extuw " ++ answer ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ no ++ "\n" ++
        target ++ " =l copy " ++ nt_choose(String,U32.is_eq(op,18),u => "0",u => raw) ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ done ++ "\n"
      P111QCode{Con{text,chunks},U32.add(site,3),terminal,error}

@unsafe
def p118f_original_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+op,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}
      P111QCode{chunks,+next,terminal,error}:
        nt_choose(P111QCode,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          (U32.is_eq(op,18) || U32.is_eq(op,19)) && p114t_buffer(buffer),
          u => p118u_divmod(dest,buffer,op,next,code),
          u => p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code))
    case _ P111QCode{chunks,next,terminal,error}:
      p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code)

@unsafe
def p118f_to_u32(+dest: String, buffer: String, +site: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +raw = p111q_local(p114t_name(site,"f_raw"))
      +bits = p111q_local(p114t_name(site,"f_bits"))
      +value = p111q_local(p114t_name(site,"f_value"))
      +nonnegative = p111q_local(p114t_name(site,"f_nonnegative"))
      +below_limit = p111q_local(p114t_name(site,"f_below_limit"))
      +valid = p111q_local(p114t_name(site,"f_valid"))
      +answer = p111q_local(p114t_name(site,"f_answer"))
      +target = p111q_local(dest)
      +yes = p111q_label(site)
      +no = p111q_label(U32.inc(site))
      +done = p111q_label(U32.add(site,2))
      text = raw ++ " =l loadl " ++ p111q_local(buffer) ++ "\n" ++
        bits ++ " =w copy " ++ raw ++ "\n" ++
        value ++ " =s cast " ++ bits ++ "\n" ++
        nonnegative ++ " =w cges " ++ value ++ ", s_0\n" ++
        below_limit ++ " =w clts " ++ value ++ ", s_4294967296\n" ++
        valid ++ " =w and " ++ nonnegative ++ ", " ++ below_limit ++ "\n" ++
        "jnz " ++ valid ++ ", " ++ yes ++ ", " ++ no ++ "\n" ++ yes ++ "\n" ++
        answer ++ " =w stoui " ++ value ++ "\n" ++
        target ++ " =l extuw " ++ answer ++ "\n" ++
        "jmp " ++ done ++ "\n" ++ no ++ "\n" ++
        target ++ " =l copy 0\n" ++
        "jmp " ++ done ++ "\n" ++ done ++ "\n"
      P111QCode{Con{text,chunks},U32.add(site,3),terminal,error}

@unsafe
def p118np_foreign(+d: KDef) -> Bool:
  Bool.not(db(d)) && (p98_tag_eq(nc_unann(dv(d)),"Foreign") ||
    (p88_string_eq(dk(d),"Def") && nc_foreign(d)))


@unsafe
def p118np_walk(todo: List<&2,List<&2,KDef>>, +found: Bool) -> Bool:
  match todo:
    case Nil{}: found
    case Con{Nil{},rest}: p118np_walk(rest,found)
    case Con{Con{+d,following},rest}:
      p118np_walk(Con{dc(d),Con{following,rest}},found || p118np_foreign(d))


@unsafe
def p118np_reference(ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{+d,rest}:
      (Bool.not(db(d)) && (p98_tag_eq(nc_unann(dv(d)),"Foreign") ||
        (p88_string_eq(dk(d),"Def") && nc_foreign(d)))) ||
        p118np_reference(dc(d)) || p118np_reference(rest)


def p118np_definition(name: String, kind: String, value: KTerm, children: List<&2,KDef>, trusted: Bool) -> KDef:
  KDef{name,kind,0,0,{KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},value,children,trusted,False{}}


@unsafe
def p118np_case(+name: String, +defs: List<&2,KDef>, +expected: Bool) -> String:
  p113ft_row(name,U32.is_eq(Bool.to_u32(nc_pack_foreign(defs)),Bool.to_u32(expected)) &&
    U32.is_eq(Bool.to_u32(p118np_reference(defs)),Bool.to_u32(expected)))


@unsafe
def p118np_controls() -> List<&2,String>:
  +plain = p118np_definition("plain","Def",kt("NWord","7",0,0,[]),[],False{})
  +foreign = p118np_definition("foreign","Def",{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{})
  +trusted = p118np_definition("trusted","Def",{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],True{})
  +absent = p118np_definition("absent","Def",{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{})
  +nondef = p118np_definition("nondef","ADT",{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{})
  +nested = p118np_definition("cache","BookCache",{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[plain,foreign],True{})
  +annotated = p118np_definition("annotation","Def",kt("Ann","",0,0,[{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]),[],False{})
  [p118np_case("pack-stack-empty",[],False{}),
   p118np_case("pack-stack-ordinary",[plain,nondef],False{}),
   p118np_case("pack-stack-untrusted-foreign",[foreign],True{}),
   p118np_case("pack-stack-trusted-foreign",[trusted],False{}),
   p118np_case("pack-stack-unfilled-definition",[absent],True{}),
   p118np_case("pack-stack-annotated-foreign",[annotated],True{}),
   p118np_case("pack-stack-cache-children",[nested],True{}),
   p118np_case("pack-stack-following-sibling",[plain,trusted,foreign],True{})]


@unsafe
def p118np_flat(+n: U32, +plain: KDef, tail: List<&2,KDef>) -> List<&2,KDef>:
  match n:
    case 0: tail
    case _: p118np_flat(U32.sub(n,1),plain,Con{plain,tail})


@unsafe
def p118np_nested(+n: U32, children: List<&2,KDef>) -> List<&2,KDef>:
  match n:
    case 0: children
    case _: p118np_nested(U32.sub(n,1),[p118np_definition("nested","BookCache",{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},children,True{})])


@unsafe
def p118np_scale(requested: U32) -> List<&2,String>:
  +n = U32.min(requested,65536)
  +plain = p118np_definition("plain","Def",kt("NWord","7",0,0,[]),[],False{})
  +foreign = p118np_definition("foreign","Def",{KTerm{"Foreign", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{})
  [p113ft_row("pack-stack-large-flat-clear",Bool.not(nc_pack_foreign(p118np_flat(n,plain,[])))),
   p113ft_row("pack-stack-large-last-foreign",nc_pack_foreign(p118np_flat(n,plain,[foreign]))),
   p113ft_row("pack-stack-large-nested-clear",Bool.not(nc_pack_foreign(p118np_nested(n,[])))),
   p113ft_row("pack-stack-large-nested-foreign",nc_pack_foreign(p118np_nested(n,[foreign])))]
