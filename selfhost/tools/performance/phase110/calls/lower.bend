# Only the recursive traversals needing an explicit callee catalogue are new.
# Constructor lookup, source admission, occurrence budgets, fresh numbering,
# ownership verification, branch assembly and tail moves reuse Phase109.
@unsafe
def nxc_value(+t: KTerm, +uses: List<&2,NxoUse>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +n: U32) -> NxoValue:
  nx_choose(NxoValue,String.eq(tg(t),"Var"),u => nxo_claim(ix(t),uses,n),u =>
  nx_choose(NxoValue,String.eq(tg(t),"Ctr"),u => nxo_build(t,nxo_ctor(nm(t),ctors),nxc_values(ks(t),uses,ctors,callees,n)),u =>
  nx_choose(NxoValue,String.eq(tg(t),"App"),u => nxc_call(t,nxo_head(t),uses,ctors,callees,n),u =>
    NxoValue{[],"",uses,n,"unsupported owned call value: " ++ tg(t)})))

@unsafe
def nxc_call(+t: KTerm, +head: KTerm, +uses: List<&2,NxoUse>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +n: U32) -> NxoValue:
  nx_choose(NxoValue,String.eq(tg(head),"Ref"),u =>
    nxc_call_found(nxc_find(nm(head),callees,False{}),nxo_args(t,[]),uses,ctors,callees,n),u =>
    NxoValue{[],"",uses,n,"indirect owned call refused"})

@unsafe
def nxc_call_found(+found: Maybe<&2,NxcCallee>, +args: List<&2,KTerm>, +uses: List<&2,NxoUse>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +n: U32) -> NxoValue:
  match found:
    case None{}: NxoValue{[],"",uses,n,"owned callee is not in the closed checked source catalogue"}
    case Some{NxcCallee{source,symbol,arity}}:
      nx_choose(NxoValue,U32.is_eq(nxo_size(KTerm,args),arity),u => nxc_called(symbol,nxc_values(args,uses,ctors,callees,n)),u =>
        NxoValue{[],"",uses,n,"partial or oversaturated owned call"})

@unsafe
def nxc_called(+symbol: String, +values: NxoValues) -> NxoValue:
  match values:
    case NxoValues{body,words,uses,n,error}:
      +dest = "v" ++ U32.show(n)
      NxoValue{nxo_join(NxoOp,body,[NxoCall{dest,symbol,words}]),dest,uses,U32.inc(n),error}

@unsafe
def nxc_values(+terms: List<&2,KTerm>, +uses: List<&2,NxoUse>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +n: U32) -> NxoValues:
  match terms:
    case Nil{}: NxoValues{[],[],uses,n,""}
    case Con{head,rest}: nxc_values_head(rest,ctors,callees,nxc_value(head,uses,ctors,callees,n))

@unsafe
def nxc_values_head(+rest: List<&2,KTerm>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +head: NxoValue) -> NxoValues:
  match head:
    case NxoValue{body,word,uses,n,error}:
      nx_choose(NxoValues,String.eq(error,""),u => nxo_values_tail(head,nxc_values(rest,uses,ctors,callees,n)),u => NxoValues{body,[],uses,n,error})

@unsafe
def nxc_terminal(+t: KTerm, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +name: String, +arity: U32, +n: U32) -> NxoCode:
  +uses = nxo_uses(t,env)
  +head = nxo_head(t)
  nxo_prepend(nxo_dead(owners,uses),nx_choose(NxoCode,String.eq(tg(t),"App") && String.eq(tg(head),"Ref") && String.eq(nm(head),name),
    u => nxo_tail(nxc_values(nxo_args(t,[]),uses,ctors,callees,n),arity),
    u => nxo_return(nxc_value(t,uses,ctors,callees,n))))

@unsafe
def nxc_apply(+t: KTerm, +args: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +name: String, +arity: U32, +n: U32) -> NxoCode:
  nx_choose(NxoCode,String.eq(tg(t),"Efq"),u => NxoCode{[NxoFail{1}],n,""},u => nxc_apply_live(t,args,env,owners,ctors,callees,name,arity,n))

@unsafe
def nxc_apply_live(+t: KTerm, +args: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +name: String, +arity: U32, +n: U32) -> NxoCode:
  match args:
    case Nil{}: nxc_terminal(t,env,owners,ctors,callees,name,arity,n)
    case Con{word,rest}:
      nx_choose(NxoCode,String.eq(tg(t),"Lam") && Bool.not(U32.is_eq(qt(t),0)),u =>
        nxc_apply(kid(t,0),rest,Con{NxoBinding{ix(t),word},env},owners,ctors,callees,name,arity,n),u =>
      nx_choose(NxoCode,String.eq(tg(t),"Mat"),u => nxc_match(t,word,rest,env,owners,ctors,callees,name,arity,n,nxo_ctor(nm(t),ctors)),u =>
        NxoCode{[],n,"unsupported owned function binder: " ++ tg(t)}))

@unsafe
def nxc_match(+t: KTerm, +word: String, +rest: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +name: String, +arity: U32, +n: U32, +ctor: NxoCtor) -> NxoCode:
  match ctor:
    case NxoCtor{key,cid,fields}:
      nx_choose(NxoCode,String.eq(key,"") || Bool.not(U32.is_eq(ix(t),U32.inc(fields))) || Bool.not(U32.is_eq(fields,0) || U32.is_eq(fields,2)),u => NxoCode{[],n,"match lacks checked constructor field count: " ++ nm(t)},u =>
        nxc_match_fields(t,word,rest,env,owners,ctors,callees,name,arity,n,cid,nx_choose(List<&2,String>,U32.is_eq(fields,0),v => [],v => ["v" ++ U32.show(n),"v" ++ U32.show(U32.inc(n))]),U32.add(n,fields)))

@unsafe
def nxc_match_fields(+t: KTerm, +word: String, +rest: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +name: String, +arity: U32, +n: U32, +cid: U32, +fields: List<&2,String>, +next: U32) -> NxoCode:
  nxc_match_yes(t,word,rest,env,owners,ctors,callees,name,arity,cid,
    nxo_prepend([NxoTake{word,fields}],nxc_apply(kid(t,0),nxo_join(String,fields,rest),nxo_remove(word,env),nxo_join(String,fields,nxo_without(word,owners)),ctors,callees,name,arity,next)))

@unsafe
def nxc_match_yes(+t: KTerm, +word: String, +rest: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +name: String, +arity: U32, +cid: U32, +yes: NxoCode) -> NxoCode:
  match yes:
    case NxoCode{body,n,error}: nxo_branch(word,cid,yes,nxc_apply(kid(t,1),Con{word,rest},env,owners,ctors,callees,name,arity,n))
