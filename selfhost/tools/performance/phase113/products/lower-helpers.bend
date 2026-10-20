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
def p113pl_emitted(+target: P113PTarget, +n: U32, value: P113PValueCode) -> P113DCode:
  match value:
    case P113PValueCode{body,values,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113pl_done(values,target,n)),u => p113d_fail(error,n))

@unsafe
def p113pl_output(shape: KTerm, values: List<&2,N111Value>, +target: P113PTarget, n: U32) -> P113DCode:
  p113pl_emitted(target,n,p113p_transfer(shape,p113pl_shape(target),values))

@unsafe
def p113pl_boxed(value: P111ValueCode, +target: P113PTarget, +n: U32) -> P113DCode:
  match value:
    case P111ValueCode{body,word,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113pl_output(atom("Absent"),[word],target,n)),u => p113d_fail(error,n))

@unsafe
def p113pl_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:
  +names = p113pl_names("p113p_call_" ++ U32.show(n),nq_width(shape),0)
  nt_choose(P113DCode,String.eq(name,p113pl_owner(target)),
    u => nt_choose(P113DCode,p113pl_tail(target) && nq_same(shape,p113pl_shape(target)),
      v => P113DCode{[P113DAgain{args}],n,"",[]},v => p113d_fail("product non-tail self call",n)),
    u => p113d_join(P113DCode{[P113DCall{names,name,args}],U32.inc(n),"",[name]},
      p113pl_output(shape,p113pl_locals(names),target,U32.inc(n))))

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
  p113pl_partition(book,t,target,n,p111_partition(env,nc_uses(t)))

@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = nq_bundle_params(ix(shape),n)
  +bundle = kt("NQBundle",nm(shape),0,0,nd_entry_args(params))
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,nc_words(params),shape),U32.add(n,ix(shape)))
  p113d_prepend(p111_keep(value_env,nc_uses(body)),p113d_join(first,
    p113pl_lower(book,subst(body,id,bundle),nt_append(NC_Binding,nc_live_env(env,body),params),target,p113d_fresh(first))))

@unsafe
def p113pl_bind_boxed(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +uses = nc_uses(body)
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,["v_" ++ U32.show(id)],atom("Absent")),n)
  p113d_prepend(p111_keep(value_env,uses),p113d_join(first,
    p113pl_lower(book,body,nt_append(NC_Binding,nc_live_uses(env,uses),[nk_binding(id,value,env)]),target,p113d_fresh(first))))

@unsafe
def p113pl_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => nq_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape) && p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113pl_bind_boxed(book,value,body,env,id,target,n))

@unsafe
def p113pl_lets(+book: List<&2,KDef>, terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  match terms:
    case Nil{}: p113d_fail("product empty let",n)
    case Con{head,Nil{}}: p113pl_lower(book,head,env,target,n)
    case Con{+head,rest}: p113pl_let(book,kid(head,0),kt("NSeqLet","",0,0,rest),env,ix(head),target,n)
