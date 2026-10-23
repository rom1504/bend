@unsafe
def p128br_test_context() -> NO_Context:
  NO_Context{[],"outer",NO_Schema{[var("String",10)],[0],var("Bool",11),11,"Bool",[],12,""},[]}

@unsafe
def p128br_test_arg(+tag: String, +ty: String, +origin: KTerm) -> KTerm:
  kt(tag,ty,0,0,[origin,var("",10)])

@unsafe
def p128br_test_accept(arg: KTerm) -> Bool:
  p128br_arguments(p128br_test_context(),[var("String",20)],[0],[arg],0)

@unsafe
def p128br_test_residual(+arg: KTerm) -> KTerm:
  kt("NO_Let","",11,0,[kt("NO_ReadCall","checked-reader",0,0,[arg]),kt("NO_Return","",0,0,[var("",11)])])

@unsafe
def p128br_test_projection(+arg: KTerm) -> Bool:
  +env : List<&2,NC_Binding> = [nc_binding(10)]
  String.is_empty(nc_error(no_emit(p128br_project_residual(p128br_test_residual(arg),env),env,env,[],0)))

@unsafe
def p128br_call_controls() -> List<&2,String>:
  +root = kt("OArg","",0,0,[])
  +child = kt("OField","SCon",1,0,[root,ref("String")])
  [p128bs_control_row("borrow-call-held-root",p128br_test_accept(p128br_test_arg("OA","String",root))),
   p128bs_control_row("borrow-call-held-descendant",p128br_test_accept(p128br_test_arg("OA","String",child))),
   p128bs_control_row("borrow-call-unheld-refused",Bool.not(p128br_test_accept(p128br_test_arg("OA","String",kt("OArg","",1,0,[]))))),
   p128bs_control_row("borrow-call-fresh-origin-refused",Bool.not(p128br_test_accept(p128br_test_arg("OA","String",kt("OUnique","",1,0,[]))))),
   p128bs_control_row("borrow-call-virtual-root-refused",Bool.not(p128br_test_accept(p128br_test_arg("OC","String",root)))),
   p128bs_control_row("borrow-call-wrong-type-refused",Bool.not(p128br_test_accept(p128br_test_arg("OA","U32",root)))),
   p128bs_control_row("borrow-call-arity-refused",Bool.not(p128br_arguments(p128br_test_context(),[var("String",20)],[0],[],0))),
   p128bs_control_row("borrow-call-bound-atom-projects",p128br_test_projection(var("",10))),
   p128bs_control_row("borrow-call-unbound-atom-refused",Bool.not(p128br_test_projection(var("",99)))),
   p128bs_control_row("borrow-call-owning-constructor-refused",Bool.not(p128br_test_projection(kt("NCtr","SCon",0,0,[var("",10),var("",10)]))))]
