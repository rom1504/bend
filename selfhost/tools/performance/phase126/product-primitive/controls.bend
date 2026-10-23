# Pure analysis controls only; deliberately refused records are never targets.
@unsafe
def p126bpc_info(+shape: KTerm, +inputs: List<&2,KTerm>) -> KDef:
  KDef{"observe","NQSignature",2,0,shape,kt("NQSig","$product.observe",0,0,inputs),[],False{},False{}}

@unsafe
def p126bpc_params() -> List<&2,NC_Binding>:
  [NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}}]

@unsafe
def p126bpc_tuple() -> KTerm:
  kt("NQShape","Tuple",2,0,[])

@unsafe
def p126bpc_wrapper() -> KTerm:
  kt("NCtr","Tuple",0,0,[var("",1),var("",3)])

@unsafe
def p126bpc_allowed(+shape: KTerm, +inputs: List<&2,KTerm>, +wrapper: KTerm) -> Bool:
  p126bp_shape(p126bpc_info(shape,inputs),p126bpc_params(),wrapper)

@unsafe
def p126bpc_schema() -> NO_Schema:
  NO_Schema{[var("",1),var("",2)],[0],p126bpc_wrapper(),3,"Bool",[],4,""}

@unsafe
def p126bpc_verify() -> String:
  +reader : P113DFunction = P113DFunction{p118b_read_name("observe"),p126bpc_params(),1,False{},[P113DResult{[N111Const{1,0}]}]}
  p113e_functions(Con{reader,p126bp_flat("observe",p126bpc_params(),p126bpc_schema(),
    p126bpc_info(p126bpc_tuple(),[atom("Absent"),atom("Absent")]))},N111Ids{missing(),missing()},missing())

@unsafe
def p126bpc_wrong_result() -> String:
  +reader : P113DFunction = P113DFunction{p118b_read_name("observe"),p126bpc_params(),2,False{},[P113DResult{[N111Const{1,0},N111Const{2,0}]}]}
  p113e_functions(Con{reader,p126bp_flat("observe",p126bpc_params(),p126bpc_schema(),
    p126bpc_info(p126bpc_tuple(),[atom("Absent"),atom("Absent")]))},N111Ids{missing(),missing()},missing())

@unsafe
def p126bpc_row(+name: String, +ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126bp_controls() -> List<&2,String>:
  [p126bpc_row("exact-flat-constructor",p126bpc_allowed(p126bpc_tuple(),[atom("Absent"),atom("Absent")],p126bpc_wrapper())),
   p126bpc_row("constant-field",p126bpc_allowed(p126bpc_tuple(),[atom("Absent"),atom("Absent")],kt("NCtr","Tuple",0,0,[var("",1),kt("NWord","",7,0,[])]))),
   p126bpc_row("input-flattening-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[p126bpc_tuple(),atom("Absent")],p126bpc_wrapper()))),
   p126bpc_row("input-count-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[atom("Absent")],p126bpc_wrapper()))),
   p126bpc_row("opaque-result-refused",Bool.not(p126bpc_allowed(atom("Absent"),[atom("Absent"),atom("Absent")],p126bpc_wrapper()))),
   p126bpc_row("constructor-mismatch-refused",Bool.not(p126bpc_allowed(kt("NQShape","Different",2,0,[]),[atom("Absent"),atom("Absent")],p126bpc_wrapper()))),
   p126bpc_row("field-count-refused",Bool.not(p126bpc_allowed(kt("NQShape","Tuple",3,0,[]),[atom("Absent"),atom("Absent")],p126bpc_wrapper()))),
   p126bpc_row("nested-constructor-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[atom("Absent"),atom("Absent")],kt("NCtr","Tuple",0,0,[var("",1),kt("NCtr","Node",0,0,[var("",3)])])))),
   p126bpc_row("primitive-field-refused",Bool.not(p126bpc_allowed(p126bpc_tuple(),[atom("Absent"),atom("Absent")],kt("NCtr","Tuple",0,0,[var("",1),kt("NOp","u32_add",0,0,[var("",2),var("",3)])])))),
   p126bpc_row("full-function-verification",String.is_empty(p126bpc_verify())),
   p126bpc_row("wrong-reader-result-abi-refused",Bool.not(String.is_empty(p126bpc_wrong_result())))]
