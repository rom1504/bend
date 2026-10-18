# First-order owned constructor/match lowering. No emitted C is inspected.
# Lambda and match application use the production checked-erasure field counts.
# Unhandled nodes, foreign calls, non-tail calls and dynamic functions refuse.
@unsafe
def nxo_join(-A: Data, +xs: List<&2,A>, +ys: List<&2,A>) -> List<&2,A>:
  match xs:
    case Nil{}: ys
    case Con{h,t}: Con{h,nxo_join(A,t,ys)}

@unsafe
def nxo_size(-A: Data, +xs: List<&2,A>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h,t}: U32.inc(nxo_size(A,t))

@unsafe
def nxo_ctor(+name: String, +ctors: List<&2,NxoCtor>) -> NxoCtor:
  match ctors:
    case Nil{}: NxoCtor{"",0,0}
    case Con{NxoCtor{key,cid,arity},rest}:
      nx_choose(NxoCtor,String.eq(name,key),u => NxoCtor{key,cid,arity},u => nxo_ctor(name,rest))

@unsafe
def nxo_word(+id: U32, +env: List<&2,NxoBinding>) -> String:
  match env:
    case Nil{}: ""
    case Con{NxoBinding{key,word},rest}:
      nx_choose(String,U32.is_eq(id,key),u => word,u => nxo_word(id,rest))

@unsafe
def nxo_remove(+word: String, +env: List<&2,NxoBinding>) -> List<&2,NxoBinding>:
  match env:
    case Nil{}: []
    case Con{NxoBinding{id,value},rest}:
      nx_choose(List<&2,NxoBinding>,String.eq(word,value),u => nxo_remove(word,rest),u => Con{NxoBinding{id,value},nxo_remove(word,rest)})

@unsafe
def nxo_without(+word: String, +owners: List<&2,String>) -> List<&2,String>:
  match owners:
    case Nil{}: []
    case Con{h,t}: nx_choose(List<&2,String>,String.eq(word,h),u => t,u => Con{h,nxo_without(word,t)})

@unsafe
def nxo_occurs(+t: KTerm, +id: U32) -> U32:
  nx_choose(U32,String.eq(tg(t),"Var"),u => nx_bool32(U32.is_eq(ix(t),id)),u => nxo_occurs_list(ks(t),id))

@unsafe
def nxo_occurs_list(+ts: List<&2,KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{h,t}: U32.add(nxo_occurs(h,id),nxo_occurs_list(t,id))

@unsafe
def nxo_uses(+t: KTerm, +env: List<&2,NxoBinding>) -> List<&2,NxoUse>:
  match env:
    case Nil{}: []
    case Con{NxoBinding{id,word},rest}: Con{NxoUse{id,word,nxo_occurs(t,id)},nxo_uses(t,rest)}

@unsafe
def nxo_live(+word: String, +uses: List<&2,NxoUse>) -> Bool:
  match uses:
    case Nil{}: False{}
    case Con{NxoUse{id,value,left},rest}:
      (String.eq(word,value) && U32.is_gt(left,0)) || nxo_live(word,rest)

@unsafe
def nxo_dead(+owners: List<&2,String>, +uses: List<&2,NxoUse>) -> List<&2,NxoOp>:
  match owners:
    case Nil{}: []
    case Con{word,rest}: nx_choose(List<&2,NxoOp>,nxo_live(word,uses),u => nxo_dead(rest,uses),u => Con{NxoSink{word},nxo_dead(rest,uses)})

@unsafe
def nxo_claim(+id: U32, +uses: List<&2,NxoUse>, +n: U32) -> NxoValue:
  match uses:
    case Nil{}: NxoValue{[],"",[],n,"unbound or consumed Term"}
    case Con{NxoUse{key,word,left},rest}:
      nx_choose(NxoValue,U32.is_eq(id,key),u =>
        nx_choose(NxoValue,U32.is_gt(left,0),v => NxoValue{nx_choose(List<&2,NxoOp>,U32.is_gt(left,1),w => [NxoKeep{word}],w => []),word,Con{NxoUse{key,word,U32.sub(left,1)},rest},n,""},v => NxoValue{[],"",uses,n,"Term used beyond ownership count"}),u =>
          nxo_claim_tail(NxoUse{key,word,left},nxo_claim(id,rest,n)))

@unsafe
def nxo_claim_tail(+head: NxoUse, +tail: NxoValue) -> NxoValue:
  match tail:
    case NxoValue{body,word,uses,n,error}: NxoValue{body,word,Con{head,uses},n,error}

@unsafe
def nxo_value(+t: KTerm, +uses: List<&2,NxoUse>, +ctors: List<&2,NxoCtor>, +n: U32) -> NxoValue:
  nx_choose(NxoValue,String.eq(tg(t),"Var"),u => nxo_claim(ix(t),uses,n),u =>
  nx_choose(NxoValue,String.eq(tg(t),"Ctr"),u => nxo_build(t,nxo_ctor(nm(t),ctors),nxo_values(ks(t),uses,ctors,n)),u =>
    NxoValue{[],"",uses,n,"non-atomic owned value: " ++ tg(t)}))

@unsafe
def nxo_values(+ts: List<&2,KTerm>, +uses: List<&2,NxoUse>, +ctors: List<&2,NxoCtor>, +n: U32) -> NxoValues:
  match ts:
    case Nil{}: NxoValues{[],[],uses,n,""}
    case Con{h,t}: nxo_values_head(t,ctors,nxo_value(h,uses,ctors,n))

@unsafe
def nxo_values_head(+rest: List<&2,KTerm>, +ctors: List<&2,NxoCtor>, +head: NxoValue) -> NxoValues:
  match head:
    case NxoValue{body,word,uses,n,error}:
      nx_choose(NxoValues,String.eq(error,""),u => nxo_values_tail(head,nxo_values(rest,uses,ctors,n)),u => NxoValues{body,[],uses,n,error})

@unsafe
def nxo_values_tail(+head: NxoValue, +tail: NxoValues) -> NxoValues:
  match head tail:
    case NxoValue{hb,hw,hu,hn,he} NxoValues{tb,tw,tu,tn,te}:
      NxoValues{nxo_join(NxoOp,hb,tb),Con{hw,tw},tu,tn,te}

@unsafe
def nxo_build(+t: KTerm, +ctor: NxoCtor, +values: NxoValues) -> NxoValue:
  match ctor values:
    case NxoCtor{name,cid,arity} NxoValues{body,words,uses,n,error}:
      +dest = "v" ++ U32.show(n)
      NxoValue{nxo_join(NxoOp,body,[NxoBuild{dest,cid,words}]),dest,uses,U32.inc(n),
        nx_choose(String,Bool.not(String.eq(error,"")),u => error,u =>
          nx_choose(String,String.eq(name,"") || Bool.not(U32.is_eq(arity,nxo_size(String,words))) || Bool.not(U32.is_eq(arity,0) || U32.is_eq(arity,2)),v => "unsupported constructor identity/arity: " ++ nm(t),v => ""))}

@unsafe
def nxo_head(+t: KTerm) -> KTerm:
  nx_choose(KTerm,String.eq(tg(t),"App"),u => nxo_head(kid(t,0)),u => t)

@unsafe
def nxo_args(+t: KTerm, +args: List<&2,KTerm>) -> List<&2,KTerm>:
  nx_choose(List<&2,KTerm>,String.eq(tg(t),"App"),u => nxo_args(kid(t,0),Con{kid(t,1),args}),u => args)

@unsafe
def nxo_return(+value: NxoValue) -> NxoCode:
  match value:
    case NxoValue{body,word,uses,n,error}: NxoCode{nxo_join(NxoOp,body,[NxoReturn{word}]),n,error}

@unsafe
def nxo_tail(+values: NxoValues, +arity: U32) -> NxoCode:
  match values:
    case NxoValues{body,words,uses,n,error}:
      NxoCode{nxo_join(NxoOp,body,[NxoTail{words}]),n,nx_choose(String,String.eq(error,"") && Bool.not(U32.is_eq(nxo_size(String,words),arity)),u => "partial/oversaturated self call",u => error)}

@unsafe
def nxo_prepend(+prefix: List<&2,NxoOp>, +code: NxoCode) -> NxoCode:
  match code:
    case NxoCode{body,n,error}: NxoCode{nxo_join(NxoOp,prefix,body),n,error}

@unsafe
def nxo_terminal(+t: KTerm, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +name: String, +arity: U32, +n: U32) -> NxoCode:
  +uses = nxo_uses(t,env)
  nxo_prepend(nxo_dead(owners,uses),nx_choose(NxoCode,String.eq(tg(t),"App"),u =>
    nx_choose(NxoCode,String.eq(tg(nxo_head(t)),"Ref") && String.eq(nm(nxo_head(t)),name),v => nxo_tail(nxo_values(nxo_args(t,[]),uses,ctors,n),arity),v => NxoCode{[],n,"external, indirect, or non-tail call"}),u =>
      nxo_return(nxo_value(t,uses,ctors,n))))

@unsafe
def nxo_param_words(+i: U32, +arity: U32) -> List<&2,String>:
  nx_choose(List<&2,String>,U32.is_eq(i,arity),u => [],u => Con{"p" ++ U32.show(i),nxo_param_words(U32.inc(i),arity)})

@unsafe
def nxo_apply(+t: KTerm, +args: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +name: String, +arity: U32, +n: U32) -> NxoCode:
  nx_choose(NxoCode,String.eq(tg(t),"Efq"),u => NxoCode{[NxoFail{1}],n,""},u => nxo_apply_live(t,args,env,owners,ctors,name,arity,n))

@unsafe
def nxo_apply_live(+t: KTerm, +args: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +name: String, +arity: U32, +n: U32) -> NxoCode:
  match args:
    case Nil{}: nxo_terminal(t,env,owners,ctors,name,arity,n)
    case Con{word,rest}:
      nx_choose(NxoCode,String.eq(tg(t),"Lam") && Bool.not(U32.is_eq(qt(t),0)),u =>
        nxo_apply(kid(t,0),rest,Con{NxoBinding{ix(t),word},env},owners,ctors,name,arity,n),u =>
      nx_choose(NxoCode,String.eq(tg(t),"Mat"),u => nxo_match(t,word,rest,env,owners,ctors,name,arity,n,nxo_ctor(nm(t),ctors)),u =>
        NxoCode{[],n,"unsupported function binder: " ++ tg(t)}))

@unsafe
def nxo_match(+t: KTerm, +word: String, +rest: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +name: String, +arity: U32, +n: U32, +ctor: NxoCtor) -> NxoCode:
  match ctor:
    case NxoCtor{key,cid,fields}:
      nx_choose(NxoCode,String.eq(key,"") || Bool.not(U32.is_eq(ix(t),U32.inc(fields))) || Bool.not(U32.is_eq(fields,0) || U32.is_eq(fields,2)),u => NxoCode{[],n,"match lacks checked constructor field count: " ++ nm(t)},u =>
        nxo_match_fields(t,word,rest,env,owners,ctors,name,arity,n,cid,nx_choose(List<&2,String>,U32.is_eq(fields,0),v => [],v => ["v" ++ U32.show(n),"v" ++ U32.show(U32.inc(n))]),U32.add(n,fields)))

@unsafe
def nxo_match_fields(+t: KTerm, +word: String, +rest: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +name: String, +arity: U32, +n: U32, +cid: U32, +fields: List<&2,String>, +next: U32) -> NxoCode:
  nxo_match_yes(t,word,rest,env,owners,ctors,name,arity,cid,
    nxo_prepend([NxoTake{word,fields}],
      nxo_apply(kid(t,0),nxo_join(String,fields,rest),nxo_remove(word,env),nxo_join(String,fields,nxo_without(word,owners)),ctors,name,arity,next)))

@unsafe
def nxo_match_yes(+t: KTerm, +word: String, +rest: List<&2,String>, +env: List<&2,NxoBinding>, +owners: List<&2,String>, +ctors: List<&2,NxoCtor>, +name: String, +arity: U32, +cid: U32, +yes: NxoCode) -> NxoCode:
  match yes:
    case NxoCode{body,n,error}:
      nxo_branch(word,cid,yes,nxo_apply(kid(t,1),Con{word,rest},env,owners,ctors,name,arity,n))

@unsafe
def nxo_branch(+word: String, +cid: U32, +yes: NxoCode, +no: NxoCode) -> NxoCode:
  match yes no:
    case NxoCode{yb,yn,ye} NxoCode{nb,nn,ne}:
      NxoCode{[NxoBranch{word,cid,yb,nb}],nn,nx_choose(String,String.eq(ye,""),u => ne,u => ye)}
