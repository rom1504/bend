# Stage1: compose verified scalar-only borrowed readers. Ordinary NO entry has
# no summaries and follows its previous behavior. No public owning adapter may
# receive a borrowed word. A summary call always names its checked private reader.

@unsafe
def p128br_lookup(+name: String, helpers: List<&2,P128BRHelper>) -> Maybe<&2,P128BRHelper>:
  match helpers:
    case Nil{}: None{}
    case Con{+head,rest}:
      match head:
        case P128BRHelper{owner,params,roots,result,reader}:
          nt_choose(Maybe<&2,P128BRHelper>,String.eq(name,owner),u => Some{head},u => p128br_lookup(name,rest))

@unsafe
def p128br_present(value: Maybe<&2,P128BRHelper>) -> Bool:
  match value:
    case None{}: False{}
    case Some{helper}: True{}

@unsafe
def p128br_held(+origin: KTerm, params: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{head,rest}:
      (no_root_index(roots,i) && noa_below(origin,kt("OArg","",i,0,[]))) ||
        p128br_held(origin,rest,roots,U32.inc(i))

@unsafe
def p128br_arguments(+ctx: NO_Context, params: List<&2,KTerm>, +roots: List<&2,U32>, args: List<&2,KTerm>, +i: U32) -> Bool:
  match params args:
    case Nil{} Nil{}: True{}
    case Con{+param,rest} Con{+arg,more}:
      String.eq(noa_value_type(ctx,arg),nm(param)) &&
        nt_choose(Bool,no_root_index(roots,i),
          u => String.eq(tg(arg),"OA") && p128br_held(noa_origin(arg),
            no_schema_params(noa_schema(ctx)),no_schema_roots(noa_schema(ctx)),0),
          u => Bool.not(String.eq(tg(noa_scalar(ctx,arg)),"Absent"))) &&
        p128br_arguments(ctx,rest,roots,more,U32.inc(i))
    case _ _: False{}

@unsafe
def p128br_words(+ctx: NO_Context, args: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> List<&2,KTerm>:
  match args:
    case Nil{}: []
    case Con{+arg,rest}:
      Con{nt_choose(KTerm,no_root_index(roots,i),u => kid(arg,1),u => noa_scalar(ctx,arg)),
        p128br_words(ctx,rest,roots,U32.inc(i))}

@unsafe
def p128br_call(+ctx: NO_Context, helper: P128BRHelper, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  match helper:
    case P128BRHelper{owner,+params,+roots,+result,reader}:
      +id = nc_id(n)
      nt_choose(NO_Analysis,p128br_arguments(ctx,params,roots,args,0) &&
        nol_scalar(noa_book(ctx),kt("ADT",result,0,0,[])),
        u => noa_prepend(kt("NO_Let","",id,0,[kt("NO_ReadCall",reader,0,0,p128br_words(ctx,args,roots,0))]),
          noa_continue(ctx,k,NO_Input{noa_atom(result,kt("OUnique","",id,0,[]),var("",id)),facts,U32.inc(n),fuel})),
        u => noa_fail("observer: borrowed helper type or held-origin",n,fuel))

@unsafe
def p128br_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont, helper: Maybe<&2,P128BRHelper>) -> NO_Analysis:
  match helper:
    case Some{ready}: p128br_call(ctx,ready,args,facts,n,fuel,k)
    case None{}:
      +d = lookup(noa_book(ctx),name)
      nt_choose(NO_Analysis,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d) || nb_contains(stack,name)) && U32.is_lt(nt_count(String,stack),8),
        u => noa_eval(ctx,nc_source_body(noa_book(ctx),d,n),[],facts,Con{name,stack},n,fuel,NO_KApplyArgs{args,k}),
        u => noa_fail("observer: helper effect, cycle or depth",n,fuel))

@unsafe
def noa_reference(+ctx: NO_Context, +name: String, +args: List<&2,KTerm>, +facts: List<&2,KTerm>, +stack: List<&2,String>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +arity = nd_arity(noa_book(ctx),name)
  +d = lookup(noa_book(ctx),name)
  nt_choose(NO_Analysis,U32.is_lt(terms_len(args),arity),u => noa_continue(ctx,k,NO_Input{kt("OR",name,0,0,Con{kt("OStack","",0,0,noa_names(stack)),args}),facts,n,fuel}),u =>
  nt_choose(NO_Analysis,Bool.not(U32.is_eq(terms_len(args),arity)),u => noa_fail("observer: saturation",n,fuel),u =>
  nt_choose(NO_Analysis,String.eq(name,noa_owner(ctx)),u => noa_recur(ctx,args,facts,n,fuel,k),u =>
  nt_choose(NO_Analysis,nt_choose(Bool,nc_native_def(d),v => nd_scalar_known(nc_primitive_name(name)),v => False{}),
    u => noa_primitive(ctx,name,args,facts,n,fuel,k),
    u => p128br_reference(ctx,name,args,facts,stack,n,fuel,k,p128br_lookup(name,p128br_helpers(ctx)))))))

@unsafe
def p128br_eval_call(+name: String, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,values,next,error}:
      P113DCode{nt_append(P113DStmt,body,[P113DCall{[p118b_value_name(n)],name,values}]),next,error,[name]}

@unsafe
def p118b_eval(t,env,n):
  nt_choose(P113DCode,String.eq(tg(t),"Var") || String.eq(tg(t),"NWord"),
    u => p113d_emitted(P113DLocal{p118b_value_name(n)},U32.inc(n),p111_value(t,env)),
    u => nt_choose(P113DCode,String.eq(tg(t),"NO_ReadCall"),
      v => p128br_eval_call(nm(t),n,p118b_args(ks(t),env,U32.inc(n))),
      v => nt_choose(P113DCode,String.eq(tg(t),"Ctr") || String.eq(tg(t),"NCtr") || String.eq(tg(t),"NOp"),
        w => p118b_eval_call(t,n,p118b_args(ks(t),env,U32.inc(n))),
        w => p113d_fail("borrowed value: unsupported node",n))))
