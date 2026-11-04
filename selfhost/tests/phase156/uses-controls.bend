# Test-only reference and controls. Never splice these into the production image.
@unsafe
def p156u_original(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = nq_bundle_params(ix(shape),n)
  +bundle = kt("NQBundle",nm(shape),0,0,nd_entry_args(params))
  +value_env = nc_live_env(env,value)
  +first = p113pl_lower(book,value,value_env,p113pl_local(target,nc_words(params),shape),U32.add(n,ix(shape)))
  p113d_prepend(p111_keep(value_env,nc_uses(body)),p113d_join(first,
    p113pl_lower(book,subst(body,id,bundle),nt_append(NC_Binding,nc_live_env(env,body),params),target,p113d_fresh(first))))

@unsafe
def p156u_code_equal(a: P113DCode, b: P113DCode) -> Bool:
  match a b:
    case P113DCode{ab,af,ae,ac} P113DCode{bb,bf,be,bc}:
      p134v_list(~P113DStmt,~p134v_stmt,ab,bb) && U32.is_eq(af,bf) &&
        String.eq(ae,be) && p134v_list(~String,~String.eq,ac,bc)

@unsafe
def p156u_analysis(+body: KTerm, +env: List<&2,NC_Binding>, +value: KTerm) -> Bool:
  +value_env = nc_live_env(env,value)
  +uses = nt_choose(NU_Set,List.is_empty(&2,NC_Binding,env),u => NU_Empty{},u => nc_uses(body))
  p134v_list(~N111Stmt,~p134v_scalar,p111_keep(value_env,nc_uses(body)),p111_keep(value_env,uses)) &&
    p134v_list(~NC_Binding,~p134v_binding,nc_live_env(env,body),nc_live_uses(env,uses))

@unsafe
def p156u_complete(+value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +target_shape: KTerm, +expected_error: String) -> Bool:
  +shape = kt("NQShape","Pair",2,0,[])
  +target: P113PTarget = P113PTarget{[],target_shape,True{},"owner",[]}
  +old = p156u_original([],value,body,env,50,target,100,shape)
  +new = p113pl_bind_flat([],value,body,env,50,target,100,shape)
  p113p_known(shape) && p113p_bindable(body,50) &&
    String.eq(p113d_error(old),expected_error) && p156u_code_equal(old,new)

@unsafe
def p156u_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

@unsafe
def p156u_controls() -> List<&2,String>:
  +empty = kt("NQShape","Pair",2,0,[])
  +env: List<&2,NC_Binding> = [NC_Binding{0,"owned",N_Box{}},NC_Binding{1,"word",N_W32{}},
    NC_Binding{2,"opaque",N_W64{}},NC_Binding{3,"packed",N_Imm64{}},
    NC_Binding{4,"unused",N_Box{}},NC_Binding{4294967295,"wide",N_W64{}},NC_Binding{2,"shadow",N_Box{}}]
  +fields = kt("NQBundle","Pair",0,0,[var("",0),var("",1)])
  +constant = kt("NQBundle","Pair",0,0,[kt("NWord","",7,0,[]),kt("NWord","",9,0,[])])
  +mixed = kt("Body","",0,0,[var("",0),var("",1),var("",2),var("",3),var("",4294967295)])
  [p156u_row("empty-environment",p156u_analysis(mixed,[],fields)),
   p156u_row("empty-value-environment",p156u_analysis(mixed,env,constant)),
   p156u_row("mixed-ownership-order-and-shadow",p156u_analysis(mixed,env,mixed)),
   p156u_row("maximum-id",p156u_analysis(var("",4294967295),env,mixed)),
   p156u_row("all-unused",p156u_analysis(kt("Empty","",0,0,[]),env,mixed)),
   p156u_row("var-child-is-not-a-use",p156u_analysis(kt("Var","",0,0,[var("",4)]),env,mixed)),
   p156u_row("complete-empty-environment",p156u_complete(constant,var("",50),[],empty,"")),
   p156u_row("complete-owned-fields",p156u_complete(fields,var("",50),env,empty,"")),
   p156u_row("complete-shared-owned-field",p156u_complete(fields,nc_mklet(60,var("",0),var("",50)),env,empty,"")),
   p156u_row("complete-value-refusal",p156u_complete(kt("Unsupported","",0,0,[]),var("",50),env,empty,"product unsupported core node Unsupported")),
   p156u_row("complete-result-shape-refusal",p156u_complete(constant,var("",50),[],kt("NQShape","Other",2,0,[]),"product result shape mismatch"))]

@unsafe
def p156u_passed(rows: List<&2,String>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{head,rest}: String.ends_with(head,":pass") && p156u_passed(rest)

@unsafe
def p156u_controls_ok() -> Bool:
  p156u_passed(p156u_controls())
