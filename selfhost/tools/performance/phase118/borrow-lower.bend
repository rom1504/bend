# Translate only the existing validated NO residual vocabulary. Borrowed fields
# never enter ordinary ownership lowering; owning roots remain in the adapter.
law p118b_eval:
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +n: U32
  P113DCode

@unsafe
def p118b_args(terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P118BValues:
  match terms:
    case Nil{}: P118BValues{[],[],n,""}
    case Con{head,rest}: p118b_args_head(rest,env,n,p118b_eval(head,env,n))

@unsafe
def p118b_args_head(rest: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +first: P113DCode) -> P118BValues:
  p118b_args_tail(n,first,p118b_args(rest,env,p113d_fresh(first)))

@unsafe
def p118b_args_tail(+n: U32, +first: P113DCode, tail: P118BValues) -> P118BValues:
  match tail:
    case P118BValues{body,values,next,error}:
      P118BValues{nt_append(P113DStmt,p113d_body(first),body),
        Con{N111Local{p118b_value_name(n)},values},next,p111_first(p113d_error(first),error)}

@unsafe
def p118b_eval_call(+t: KTerm, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,values,next,error}:
      +value = nt_choose(P111ValueCode,String.eq(tg(t),"NOp"),
        u => p111_intrinsic(nm(t),values),u => p111_constructor(nm(t),values))
      p113d_join(P113DCode{body,next,error,[]},
        p113d_emitted(P113DLocal{p118b_value_name(n)},next,value))

@unsafe
def p118b_eval(t,env,n):
  nt_choose(P113DCode,String.eq(tg(t),"Var") || String.eq(tg(t),"NWord"),
    u => p113d_emitted(P113DLocal{p118b_value_name(n)},U32.inc(n),p111_value(t,env)),
    u => nt_choose(P113DCode,String.eq(tg(t),"Ctr") || String.eq(tg(t),"NCtr") || String.eq(tg(t),"NOp"),
      v => p118b_eval_call(t,n,p118b_args(ks(t),env,U32.inc(n))),
      v => p113d_fail("borrowed residual: unsupported value",n)))

law p118b_lower:
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +params: List<&2,NC_Binding>
  for +layouts: List<&2,NO_Layout>
  for +n: U32
  P113DCode

@unsafe
def p118b_terminal(+loop: Bool, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,values,next,error}:
      P113DCode{nt_append(P113DStmt,body,
        [nt_choose(P113DStmt,loop,u => P113DAgain{values},u => P113DResult{values})]),next,error,[]}

@unsafe
def p118b_let(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32) -> P113DCode:
  +first = p118b_eval(kid(t,0),env,n)
  +assigned : N111Stmt = N111Set{"v_" ++ U32.show(ix(t)),N111U64{},N111Local{p118b_value_name(n)}}
  p113d_join(first,p113d_prepend([assigned],p118b_lower(kid(t,1),Con{nc_binding(ix(t)),env},params,layouts,p113d_fresh(first))))

@unsafe
def p118b_field_loads(fields: List<&2,KTerm>, +i: U32) -> List<&2,N111Stmt>:
  match fields:
    case Nil{}: []
    case Con{field,rest}: Con{N111Load{"v_" ++ U32.show(ix(field)),N111U64{},N111Local{"scratch"},U32.mul(i,8)},p118b_field_loads(rest,U32.inc(i))}

@unsafe
def p118b_reads(+layout: NO_Layout, +fields: List<&2,KTerm>, +word: N111Value) -> List<&2,N111Stmt>:
  match layout:
    case NO_Layout{key,+ctor,+storage,+width}:
      nt_choose(List<&2,N111Stmt>,String.eq(storage,"Boxed"),
        u => Con{N111Call{"p118b_read_status",N111U64{},"p118_rt_borrow_fields",
          [p111_state(),p111_word(word),p111_scratch(),N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(width)]},p118b_field_loads(fields,0)},
        u => nt_choose(List<&2,N111Stmt>,String.eq(storage,"Nullary"),v => [],v =>
          nt_choose(List<&2,N111Stmt>,String.eq(storage,"Succ"),
            w => [N111Bin{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},"sub",word,N111Const{1,0}}],
            w => [N111Set{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},word}])) )

@unsafe
def p118b_match(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32, found: Maybe<&2,NO_Layout>) -> P113DCode:
  match found:
    case None{}: p113d_fail("borrowed residual: absent layout",n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key,+ctor,storage,width}:
          +word : N111Value = N111Local{nc_word(ix(kid(t,0)),env)}
          +fields = ks(kid(t,1))
          +yes = p118b_lower(kid(t,2),no_bind_fields(fields,env),params,layouts,n)
          +no = p118b_lower(kid(t,3),env,params,layouts,p113d_fresh(yes))
          p113d_prepend(p111_test(ctor,word),p113d_branch(N111Local{"match_condition"},
            p113d_prepend(p118b_reads(layout,fields,word),yes),no))

@unsafe
def p118b_lower(t,env,params,layouts,n):
  nt_choose(P113DCode,String.eq(tg(t),"NO_Return"),u => p118b_terminal(False{},p118b_args(ks(t),env,n)),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Loop"),u => p118b_terminal(True{},p118b_args(ks(t),env,n)),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Let"),u => p118b_let(t,env,params,layouts,n),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Match"),u => p118b_match(t,env,params,layouts,n,no_layout(nm(t),layouts)),u =>
  nt_choose(P113DCode,String.eq(tg(t),"NO_Error") && String.eq(nm(t),"ERR_FIDS"),
    u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},P113DReturn{},n)),
    u => p113d_fail("borrowed residual: unsupported node",n))))))

@unsafe
def p118b_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> P118BWorkers:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +reader = p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)
  +result = no_schema_result(schema)
  +env : List<&2,NC_Binding> = Con{NC_Binding{result,"p118b_observation",N_W64{}},params}
  +wrapper = p118b_eval(no_schema_wrapper(schema),env,0)
  +adapter : List<&2,P113DStmt> = Con{P113DCall{["p118b_observation"],p118b_read_name(owner),p111_env_words(params)},
    nt_append(P113DStmt,p113d_body(wrapper),[P113DResult{[N111Local{p118b_value_name(0)}]}])}
  P118BWorkers{[
    P113DFunction{p118b_read_name(owner),params,1,False{},p113d_body(reader)},
    P113DFunction{p113d_public(book,owner),params,1,True{},adapter}],
    p111_first(p113d_error(reader),p113d_error(wrapper))}
