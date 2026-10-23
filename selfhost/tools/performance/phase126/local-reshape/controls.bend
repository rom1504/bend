# Finite analysis/verifier controls only. Invented terms are never emitted.
@unsafe
def p126lrc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126lrc_result(+name: String, +a: KTerm, +b: KTerm, +c: KTerm, +d: KTerm) -> KTerm:
  kt("Ctr",name,0,1,[kt("Ctr",name,0,1,[a,c]),kt("Ctr",name,0,1,[b,d])])

@unsafe
def p126lrc_import_ok(flow: P111VFlow) -> Bool:
  match flow:
    case P111VFlow{live,terminal,error}: String.is_empty(error)

@unsafe
def p126lrc_import(+typ: N111Type, +state: String, +cid: N111Value, +arity: U32, +extra: Bool) -> Bool:
  +live : KDef = p111v_put(p111v_put(p111v_put(missing(),"state","parameter",3,2088),"left","parameter",2,0),"right","parameter",2,0)
  +schema : KDef = p111v_put(live,"result","local",2,0)
  +ids : N111Ids = N111Ids{missing(),p111v_put(missing(),"Branch","constructor",arity,0)}
  +args : List<&2,N111Arg> = [N111Arg{N111Ptr{},N111Local{state}},p111_word(N111Local{"left"}),p111_word(N111Local{"right"}),N111Arg{N111U32{},cid}]
  p126lrc_import_ok(p126lr_import("result",typ,nt_choose(List<&2,N111Arg>,extra,u => nt_append(N111Arg,args,[p111_u32(0)]),u => args),schema,live,ids))

@unsafe
def p126lr_controls() -> List<&2,String>:
  +good : KTerm = p126lrc_result("Branch",var("",1),var("",2),var("",3),var("",4))
  +params : List<&2,NC_Binding> = [NC_Binding{1,"left",N_Box{}},NC_Binding{2,"right",N_Box{}}]
  [p126lrc_row("exact-four-field-transpose",p126lr_result(good,"Branch",1,2,3,4)),
   p126lrc_row("renamed-constructor",p126lr_result(p126lrc_result("Other",var("",1),var("",2),var("",3),var("",4)),"Other",1,2,3,4)),
   p126lrc_row("wrong-constructor",Bool.not(p126lr_result(good,"Other",1,2,3,4))),
   p126lrc_row("swapped-fields",Bool.not(p126lr_result(good,"Branch",1,2,4,3))),
   p126lrc_row("aliased-binder",Bool.not(p126lr_result(good,"Branch",1,2,3,3))),
   p126lrc_row("duplicated-field",Bool.not(p126lr_result(p126lrc_result("Branch",var("",1),var("",2),var("",3),var("",3)),"Branch",1,2,3,4))),
   p126lrc_row("observed-field",Bool.not(p126lr_result(p126lrc_result("Branch",app(ref("observe"),var("",1)),var("",2),var("",3),var("",4)),"Branch",1,2,3,4))),
   p126lrc_row("free-field",Bool.not(p126lr_result(p126lrc_result("Branch",var("",1),var("",2),var("",3),var("",5)),"Branch",1,2,3,4))),
   p126lrc_row("exact-import",p126lrc_import(N111U64{},"state",N111CtorId{"Branch"},2,False{})),
   p126lrc_row("wrong-result-width",Bool.not(p126lrc_import(N111U32{},"state",N111CtorId{"Branch"},2,False{}))),
   p126lrc_row("wrong-state",Bool.not(p126lrc_import(N111U64{},"left",N111CtorId{"Branch"},2,False{}))),
   p126lrc_row("unknown-constructor-id",Bool.not(p126lrc_import(N111U64{},"state",N111CtorId{"Other"},2,False{}))),
   p126lrc_row("literal-constructor-id",Bool.not(p126lrc_import(N111U64{},"state",N111Const{1,0},2,False{}))),
   p126lrc_row("wrong-constructor-arity",Bool.not(p126lrc_import(N111U64{},"state",N111CtorId{"Branch"},1,False{}))),
   p126lrc_row("extra-import-argument",Bool.not(p126lrc_import(N111U64{},"state",N111CtorId{"Branch"},2,True{}))),
   p126lrc_row("fresh-worker-locals",p126lr_hygiene(p113e_schema([P113DResult{[N111Local{"left"}]}],p113e_seed(params)))),
   p126lrc_row("worker-local-collision",Bool.not(p126lr_hygiene(p113e_schema([P113DScalar{N111Set{"p126_reshape_result",N111U64{},N111Const{0,0}}},P113DResult{[N111Local{"left"}]}],p113e_seed(params))))),
   p126lrc_row("worker-parameter-collision",Bool.not(p126lr_hygiene(p113e_seed([NC_Binding{1,"p126_reshape_yes",N_Box{}},NC_Binding{2,"right",N_Box{}}]))))]
