# Source-derived, late, read-only direct-body experiment. Unsupported branches
# return [declined,0] BEFORE any effect; callers retain all entry roots and can
# restart the unchanged complete owning computation. No runtime helper added.

@unsafe
def p171d_info(name, env):
  match env:
    case Nil{}: P171DUnknown{}
    case Con{P171DLocal{key,+info},rest}:
      nt_choose(P171DInfo,String.eq(name,key),u => info,u => p171d_info(name,rest))

@unsafe
def p171d_value(value, env):
  match value:
    case N111Local{name}: p171d_info(name,env)
    case N111Const{lo,hi}: P171DWord{""}
    case N111CtorId{name}: P171DWord{""}
    case _: P171DUnknown{}

@unsafe
def p171d_known(info):
  match info:
    case P171DUnknown{}: False{}
    case _: True{}

@unsafe
def p171d_path(info):
  match info:
    case P171DWord{path}: path
    case _: ""

@unsafe
def p171d_args(values, env):
  match values:
    case Nil{}: True{}
    case Con{value,rest}: p171d_known(p171d_value(value,env)) && p171d_args(rest,env)

@unsafe
def p171d_env(params, args, env):
  match params args:
    case Con{NC_Binding{id,word,kind},rest} Con{value,more}:
      Con{P171DLocal{word,p171d_value(value,env)},p171d_env(rest,more,env)}
    case _ _: []

@unsafe
def p171d_decline(n):
  P171DCode{[P113DResult{[N111Const{0,0},N111Const{0,0}]}],[],n,0,1,False{}}

@unsafe
def p171d_prefix(prefix, code):
  match code:
    case P171DCode{body,helpers,n,accepted,declined,rooted}:
      P171DCode{nt_append(P113DStmt,prefix,body),helpers,n,accepted,declined,rooted}

@unsafe
def p171d_next(code):
  match code:
    case P171DCode{body,helpers,n,accepted,declined,rooted}: n

@unsafe
def p171d_find(name, functions):
  match functions:
    case Nil{}: None{}
    case Con{+head,rest}:
      match head:
        case P113DFunction{key,params,result,public,body}:
          nt_choose(Maybe<&2,P113DFunction>,String.eq(key,name),u => Some{head},u => p171d_find(name,rest))

@unsafe
def p171d_context_find(ctx, name):
  match ctx:
    case P171DContext{functions,ids,stack,depth}: p171d_find(name,functions)

@unsafe
def p171d_case(path, cases):
  match cases:
    case Nil{}: ""
    case Con{P171DCase{key,ctor},rest}:
      nt_choose(String,String.eq(key,path),u => ctor,u => p171d_case(path,rest))

@unsafe
def p171d_cases(info, yes, cases):
  match info:
    case P171DTest{word,path,ctor,equal}:
      nt_choose(List<&2,P171DCase>,p134v_bool(yes,equal),u => Con{P171DCase{path,ctor},cases},u => cases)
    case _: cases

@unsafe
def p171d_bin_info(op, left, right):
  match left right:
    case P171DTag{word,path} N111CtorId{ctor}:
      nt_choose(P171DInfo,String.eq(op,"eq") || String.eq(op,"ne"),
        u => P171DTest{word,path,ctor,String.eq(op,"eq")},u => P171DWord{""})
    case _ _: P171DWord{""}

@unsafe
def p171d_result(values, env, n):
  match values:
    case Con{+value,Nil{}}: p171d_result_info(value,n,p171d_value(value,env))
    case _: p171d_decline(n)

@unsafe
def p171d_result_info(value, n, info):
  match info:
    case P171DWord{path}:
      P171DCode{[P113DResult{[N111Const{1,0},value]}],[],n,1,0,Bool.not(String.is_empty(path))}
    case _: p171d_decline(n)

@unsafe
def p171d_branch(condition, yes, no):
  match yes no:
    case P171DCode{yb,yh,yn,ya,yd,yr} P171DCode{nb,nh,nn,na,nd,nr}:
      P171DCode{[P113DIf{condition,yb,nb}],nt_append(P113DFunction,yh,nh),nn,U32.add(ya,na),U32.add(yd,nd),yr || nr}

@unsafe
def p171d_branch_yes(ctx, condition, no, env, cases, view, yes):
  p171d_branch(condition,yes,p171d_walk(ctx,no,env,p171d_cases(p171d_value(condition,env),False{},cases),view,p171d_next(yes)))

@unsafe
def p171d_step(ctx, body, env, cases, view, n):
  match body:
    case Nil{}: p171d_decline(n)
    case Con{P113DResult{values},rest}: p171d_result(values,env,n)
    case Con{P113DAgain{+values},rest}:
      nt_choose(P171DCode,p171d_args(values,env),
        u => P171DCode{[P113DAgain{values}],[],n,0,0,False{}},u => p171d_decline(n))
    case Con{P113DIf{+condition,yes,no},+rest}:
      nt_choose(P171DCode,p171d_known(p171d_value(condition,env)),
        u => p171d_branch_yes(ctx,condition,nt_append(P113DStmt,no,rest),env,cases,view,
          p171d_walk(ctx,nt_append(P113DStmt,yes,rest),env,p171d_cases(p171d_value(condition,env),True{},cases),view,n)),
        u => p171d_decline(n))
    case Con{P113DCall{destinations,target,args},rest}:
      p171d_call(ctx,destinations,target,args,rest,env,cases,view,n)
    case Con{P113DScalar{stmt},rest}: p171d_scalar(ctx,stmt,rest,env,cases,view,n)

@unsafe
def p171d_continue(ctx, stmt, rest, env, cases, view, n, name, info):
  p171d_prefix([P113DScalar{stmt}],p171d_walk(ctx,rest,Con{P171DLocal{name,info},env},cases,view,n))

@unsafe
def p171d_scalar(ctx, stmt, rest, env, cases, view, n):
  match stmt:
    case N111Set{+name,typ,+value}:
      nt_choose(P171DCode,p171d_known(p171d_value(value,env)),
        u => p171d_continue(ctx,stmt,rest,env,cases,view,n,name,p171d_value(value,env)),u => p171d_decline(n))
    case N111Bin{+name,typ,+op,+left,+right}:
      nt_choose(P171DCode,p171d_known(p171d_value(left,env)) && p171d_known(p171d_value(right,env)),
        u => p171d_continue(ctx,stmt,rest,env,cases,view,n,name,p171d_bin_info(op,p171d_value(left,env),right)),u => p171d_decline(n))
    case N111Load{name,typ,base,offset}: p171d_load(ctx,stmt,name,typ,base,offset,rest,env,cases,view,n)
    case N111Call{name,typ,symbol,args}: p171d_runtime(ctx,name,typ,symbol,args,rest,env,cases,view,n)
    case _: p171d_decline(n)

@unsafe
def p171d_load(ctx, stmt, name, typ, base, offset, rest, env, cases, view, n):
  match base view:
    case N111Local{buffer} P171DView{+path,+ctor,+width}:
      nt_choose(P171DCode,String.eq(buffer,"scratch") && U32.is_eq(p111v_type(typ),2) && U32.is_eq(U32.mod(offset,8),0) && U32.is_lt(U32.div(offset,8),width),
        u => p171d_continue(ctx,stmt,rest,env,cases,P171DView{path,ctor,width},n,name,
          P171DWord{nt_choose(String,String.is_empty(path),v => "",v => path ++ "/" ++ ctor ++ "/" ++ U32.show(offset))}),u => p171d_decline(n))
    case _ _: p171d_decline(n)

@unsafe
def p171d_ctor_ok(ctx, ctor, count):
  match ctx:
    case P171DContext{functions,ids,stack,depth}:
      +actual = p111v_target(N111CtorId{ctor},ids,True{})
      Bool.not(String.is_empty(ctor) || String.eq(dk(actual),"Absent") || nb_contains(["ALeaf","ANode","U32","F32","Chr","Succ"],ctor)) &&
        U32.is_eq(da(actual),count) && U32.is_ge(count,2) && U32.is_le(count,16)

@unsafe
def p171d_take(ctx, name, typ, word, count, rest, env, cases, n):
  +path = p171d_path(p171d_value(word,env))
  +ctor = p171d_case(path,cases)
  nt_choose(P171DCode,Bool.not(String.is_empty(path)) && p171d_ctor_ok(ctx,ctor,count),
    u => p171d_prefix([P113DScalar{N111Call{name,typ,"p118_rt_borrow_fields",[p111_state(),p111_word(word),p111_scratch(),N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(count)]}}],
      p171d_walk(ctx,rest,Con{P171DLocal{name,P171DWord{""}},env},cases,P171DView{path,ctor,count},n)),u => p171d_decline(n))

@unsafe
def p171d_tag(ctx, name, typ, word, rest, env, cases, view, n):
  nt_choose(P171DCode,p171d_known(p171d_value(word,env)),
    u => p171d_continue(ctx,N111Call{name,typ,"p111_rt_tag",[p111_state(),p111_word(word)]},rest,env,cases,view,n,name,
      P171DTag{word,p171d_path(p171d_value(word,env))}),u => p171d_decline(n))

@unsafe
def p171d_runtime(ctx, name, typ, symbol, args, rest, env, cases, view, n):
  nt_choose(P171DCode,String.eq(symbol,"p111_rt_keep"),
    u => nt_choose(P171DCode,p171d_known(p171d_value(p111v_arg(args,1),env)),
      v => p171d_continue(ctx,N111Set{name,typ,p111v_arg(args,1)},rest,env,cases,view,n,name,p171d_value(p111v_arg(args,1),env)),v => p171d_decline(n)),u =>
  nt_choose(P171DCode,String.eq(symbol,"p111_rt_sink"),
    u => nt_choose(P171DCode,p171d_known(p171d_value(p111v_arg(args,1),env)),v => p171d_walk(ctx,rest,env,cases,view,n),v => p171d_decline(n)),u =>
  nt_choose(P171DCode,String.eq(symbol,"p111_rt_tag"),u => p171d_tag(ctx,name,typ,p111v_arg(args,1),rest,env,cases,view,n),u =>
  nt_choose(P171DCode,String.eq(symbol,"p111_rt_special_ctor") && p171d_nullary_args(args),
    u => p171d_continue(ctx,N111Call{name,typ,symbol,args},rest,env,cases,view,n,name,P171DWord{""}),u =>
  nt_choose(P171DCode,String.eq(symbol,"p111_rt_take"),u =>
    nt_choose(P171DCode,p134v_value(p111v_arg(args,2),N111Local{"scratch"}),
      v => p171d_take(ctx,name,typ,p111v_arg(args,1),p111v_literal(p111v_arg(args,3)),rest,env,cases,n),v => p171d_decline(n)),u =>
  nt_choose(P171DCode,String.eq(symbol,"p118_rt_borrow_fields"),u =>
    nt_choose(P171DCode,p134v_value(p111v_arg(args,2),N111Local{"scratch"}),
      v => p171d_take(ctx,name,typ,p111v_arg(args,1),p111v_literal(p111v_arg(args,4)),rest,env,cases,n),v => p171d_decline(n)),u =>
  nt_choose(P171DCode,String.eq(symbol,"p111_rt_special_take") && U32.is_eq(p111v_literal(p111v_arg(args,4)),1) &&
    (U32.is_eq(p111v_literal(p111v_arg(args,1)),4) || U32.is_eq(p111v_literal(p111v_arg(args,1)),5)),
    u => nt_choose(P171DCode,p171d_known(p171d_value(p111v_arg(args,2),env)) && p134v_value(p111v_arg(args,3),N111Local{"scratch"}),
      v => p171d_continue(ctx,N111Call{name,typ,symbol,args},rest,env,cases,P171DView{"","",1},n,name,P171DWord{""}),v => p171d_decline(n)),u =>
  nt_choose(P171DCode,String.eq(symbol,"p118_rt_borrow_scalar_safe") || String.eq(symbol,"p111_rt_special_test"),
    u => nt_choose(P171DCode,p171d_runtime_args(args,env,0),
      v => p171d_continue(ctx,N111Call{name,typ,symbol,args},rest,env,cases,view,n,name,P171DWord{""}),v => p171d_decline(n)),u => p171d_decline(n)))))))))

@unsafe
def p171d_worker_done(name, params, code):
  match code:
    case P171DCode{+body,helpers,n,accepted,declined,rooted}:
      P171DWorker{name,P171DCode{body,nt_append(P113DFunction,helpers,[P113DFunction{name,params,2,False{},body}]),n,accepted,declined,rooted}}

@unsafe
def p171d_worker(ctx, function, args, env, n):
  match ctx function:
    case P171DContext{+functions,+ids,+stack,+depth} P113DFunction{+name,+params,result,public,body}:
      +reader = "$p171desc." ++ name ++ "." ++ U32.show(n)
      nt_choose(P171DWorker,U32.is_eq(result,1) && U32.is_lt(depth,12) && Bool.not(nb_contains(stack,name)) &&
        U32.is_eq(nt_count(NC_Binding,params),nt_count(N111Value,args)) && p171d_args(args,env),
        u => p171d_worker_done(reader,params,p171d_walk(P171DContext{functions,ids,Con{name,stack},U32.inc(depth)},body,p171d_env(params,args,env),[],P171DView{"","",0},U32.inc(n))),
        u => P171DWorker{reader,p171d_decline(U32.inc(n))})

@unsafe
def p171d_called(ctx, destination, args, rest, env, cases, n, worker):
  match worker:
    case P171DWorker{+reader,P171DCode{body,+helpers,+next,+accepted,+declined,+rooted}}:
      nt_choose(P171DCode,U32.is_gt(accepted,0),
        u => p171d_called_tail(reader,destination,args,helpers,n,
          p171d_walk(ctx,rest,Con{P171DLocal{destination,P171DWord{nt_choose(String,rooted,v => "call." ++ U32.show(n),v => "")}},env},cases,P171DView{"","",0},next)),u => p171d_decline(next))

@unsafe
def p171d_called_tail(reader, destination, args, helpers, n, tail):
  match tail:
    case P171DCode{body,more,next,accepted,declined,rooted}:
      +ok = "p171desc_ok_" ++ U32.show(n)
      +test = "p171desc_test_" ++ U32.show(n)
      P171DCode{[P113DCall{[ok,destination],reader,args},P113DScalar{N111Bin{test,N111U64{},"ne",N111Local{ok},N111Const{0,0}}},P113DIf{N111Local{test},body,[P113DResult{[N111Const{0,0},N111Const{0,0}]}]}],
        nt_append(P113DFunction,helpers,more),next,accepted,U32.inc(declined),rooted}

@unsafe
def p171d_call(ctx, destinations, target, args, rest, env, cases, view, n):
  match destinations:
    case Con{destination,Nil{}}:
      p171d_call_found(ctx,destination,args,rest,env,cases,n,p171d_context_find(ctx,target))
    case _: p171d_decline(n)

@unsafe
def p171d_call_found(ctx, destination, args, rest, env, cases, n, found):
  match found:
    case None{}: p171d_decline(n)
    case Some{function}: p171d_called(ctx,destination,args,rest,env,cases,n,p171d_worker(ctx,function,args,env,n))

@unsafe
def p171d_runtime_args(args, env, i):
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,+value},rest}:
      nt_choose(Bool,U32.is_eq(i,0),u => p134v_value(value,N111Local{"state"}),u => p171d_known(p171d_value(value,env))) && p171d_runtime_args(rest,env,U32.inc(i))

# Shared budget counts actual visited IR statements and helper expansion,
# including both conditional arms. Refusal never commits partial ownership.
@unsafe
def p171d_walk(ctx, body, env, cases, view, n):
  nt_choose(P171DCode,U32.is_lt(n,8192),
    u => p171d_step(ctx,body,env,cases,view,U32.inc(n)),u => p171d_decline(n))

# These exact nullary primitive constructors return0/1 without reading scratch,
# allocating, changing ownership or invoking a user program. Other kinds decline.
@unsafe
def p171d_nullary_args(args):
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+kind,0}},Con{N111Arg{N111Ptr{},N111Local{buffer}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}:
      String.eq(state,"state") && String.eq(buffer,"scratch") && U32.is_ge(kind,1) && U32.is_le(kind,3)
    case _: False{}
