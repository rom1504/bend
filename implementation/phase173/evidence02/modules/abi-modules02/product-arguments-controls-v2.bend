# Finite admission, ownership-boundary and independent-verifier controls.
# Native execution/aliases/deep-stack behavior use vertical-abi-workload.bend.
@unsafe
def p173abc_shape() -> KTerm:
  kt("NQShape","Node",3,0,[])

@unsafe
def p173abc_result() -> KTerm:
  kt("NQShape","Tuple",2,0,[])

@unsafe
def p173abc_info(+shapes: List<&2,KTerm>) -> KDef:
  KDef{"observe","NQSignature",terms_len(shapes),0,p173abc_result(),
    kt("NQSig","$product.observe",0,0,shapes),[],False{},False{}}

@unsafe
def p173abc_env() -> List<&2,NC_Binding>:
  [NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}},NC_Binding{3,"c",N_W64{}},
   NC_Binding{4,"d",N_W64{}},NC_Binding{5,"e",N_W64{}}]

@unsafe
def p173abc_target() -> P113PTarget:
  P113PTarget{[],p173abc_result(),True{},"caller",[p173abc_info([p173abc_shape()])]}

@unsafe
def p173abc_code() -> P113DCode:
  p173ab_call([],"observe",[var("",1)],[NC_Binding{1,"a",N_W64{}}],p173abc_target(),100)

@unsafe
def p173abc_functions(+wrong: Bool) -> List<&2,P113DFunction>:
  +callee : P113DFunction = P113DFunction{"$product.observe",
    [NC_Binding{10,"f0",N_W64{}},NC_Binding{11,"f1",N_W64{}},NC_Binding{12,"f2",N_W64{}}],
    nt_choose(U32,wrong,u => 1,u => 2),False{},
    [P113DResult{nt_choose(List<&2,N111Value>,wrong,u => [N111Local{"f0"}],u => [N111Local{"f0"},N111Local{"f1"}])}]}
  +caller : P113DFunction = P113DFunction{"caller",[NC_Binding{1,"a",N_W64{}}],2,False{},
    Con{P113DScalar{N111Alloca{"scratch",2048,8}},p113d_body(p173abc_code())}}
  [callee,caller]

@unsafe
def p173abc_verified(+unknown: Bool, +wrong: Bool) -> Bool:
  +ids : N111Ids = N111Ids{missing(),nt_choose(KDef,unknown,u => missing(),
    u => ns_ctor_index([N_Constructor{"Node",3,False{}}],missing()))}
  +functions = p173abc_functions(wrong)
  String.is_empty(p113e_functions(functions,ids,missing())) &&
    String.is_empty(p147d_functions(functions,ids,missing()))

@unsafe
def p173abc_equal(a: P113DCode, b: P113DCode) -> Bool:
  match a b:
    case P113DCode{ab,af,ae,ac} P113DCode{bb,bf,be,bc}:
      p134v_list(~P113DStmt,~p134v_stmt,ab,bb) && U32.is_eq(af,bf) && String.eq(ae,be) &&
        p134v_list(~String,~String.eq,ac,bc)

@unsafe
def p173abc_row(+name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

@unsafe
def p173ab_controls() -> List<&2,String>:
  +shape = p173abc_shape()
  +info = p173abc_info([shape])
  +env = p173abc_env()
  +bundle = kt("NQBundle","Node",0,0,[var("",1),var("",2),var("",3)])
  +target = p173abc_target()
  +opaque : P113PTarget = P113PTarget{[],kt("Absent","",0,0,[]),True{},"caller",[info]}
  +different : P113PTarget = P113PTarget{[],shape,True{},"caller",[info]}
  [p173abc_row("bridge-boxed-singleton",p173ab_allowed(info,[var("",1)],env,100)),
   p173abc_row("bridge-mixed-flat-boxed",p173ab_allowed(p173abc_info([shape,shape]),[bundle,var("",4)],env,100)),
   p173abc_row("bridge-distinct-owned-tokens",p173ab_allowed(p173abc_info([shape,shape]),[var("",1),var("",2)],env,100)),
   p173abc_row("bridge-duplicate-token-refused",Bool.not(p173ab_allowed(p173abc_info([shape,shape]),[var("",1),var("",1)],env,100))),
   p173abc_row("bridge-token-in-bundle-refused",Bool.not(p173ab_allowed(p173abc_info([shape,shape]),[bundle,var("",1)],env,100))),
   p173abc_row("bridge-nonowning-refused",Bool.not(p173ab_allowed(info,[var("",1)],[NC_Binding{1,"a",N_W32{}}],100))),
   p173abc_row("bridge-unbound-refused",Bool.not(p173ab_allowed(info,[var("",19)],env,100))),
   p173abc_row("bridge-shadow-binding-refused",Bool.not(p173ab_allowed(info,[var("",1)],Con{NC_Binding{1,"other",N_W64{}},env},100))),
   p173abc_row("bridge-aliased-local-refused",Bool.not(p173ab_allowed(info,[var("",1)],Con{NC_Binding{19,"a",N_W64{}},env},100))),
   p173abc_row("bridge-large-shape-refused",Bool.not(p173ab_allowed(p173abc_info([kt("NQShape","Node",9,0,[])]),[var("",1)],env,100))),
   p173abc_row("bridge-special-shape-refused",Bool.not(p173ab_allowed(p173abc_info([kt("NQShape","Succ",1,0,[])]),[var("",1)],env,100))),
   p173abc_row("bridge-missing-signature-refused",Bool.not(p173ab_allowed(missing(),[var("",1)],env,100))),
   p173abc_row("bridge-argument-count-refused",Bool.not(p173ab_allowed(info,[var("",1),var("",2)],env,100))),
   p173abc_row("bridge-fresh-id-collision-refused",Bool.not(p173ab_allowed(info,[var("",1)],Con{NC_Binding{nc_id(100),"extra",N_W64{}},env},100))),
   p173abc_row("bridge-fresh-name-collision-refused",Bool.not(p173ab_allowed(info,[var("",1)],Con{NC_Binding{20,"v_" ++ U32.show(nc_id(100)),N_W64{}},env},100))),
   p173abc_row("bridge-fresh-overflow-refused",Bool.not(p173ab_allowed(info,[var("",1)],env,4294967280))),
   p173abc_row("bridge-final-call-fresh-budget",Bool.not(p173ab_allowed(p173abc_info([kt("NQShape","Oct",8,0,[]),kt("NQShape","Oct",8,0,[]),kt("NQShape","Oct",8,0,[]),kt("NQShape","Oct",8,0,[])]),[var("",1),var("",2),var("",3),var("",4)],env,4294967263))),
   p173abc_row("bridge-removes-result-shape-error",String.is_empty(p113d_error(p173abc_code())) && String.eq(p113d_error(p173ab_original([],"observe",[var("",1)],env,target,100)),"product result shape mismatch")),
   p173abc_row("bridge-both-independent-verifiers",p173abc_verified(False{},False{})),
   p173abc_row("bridge-final-verifier-missing-constructor",Bool.not(p173abc_verified(True{},False{}))),
   p173abc_row("bridge-final-verifier-wrong-result-width",Bool.not(p173abc_verified(False{},True{}))),
   p173abc_row("bridge-fitting-path-byte-identical",p173abc_equal(p173ab_original([],"observe",[bundle],env,target,100),p173ab_call([],"observe",[bundle],env,target,100))),
   p173abc_row("bridge-opaque-target-keeps-boxed-dependency",p173abc_equal(p173ab_original([],"observe",[var("",1)],env,opaque,100),p173ab_call([],"observe",[var("",1)],env,opaque,100))),
   p173abc_row("bridge-incompatible-result-keeps-fallback",p173abc_equal(p173ab_original([],"observe",[var("",1)],env,different,100),p173ab_call([],"observe",[var("",1)],env,different,100))),
   p173abc_row("bridge-unknown-fallback-byte-identical",p173abc_equal(p173ab_original([],"unknown",[var("",1)],env,target,100),p173ab_call([],"unknown",[var("",1)],env,target,100)))]
