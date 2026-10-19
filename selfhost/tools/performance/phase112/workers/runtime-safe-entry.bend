# Exact strengthening of the original private scalar predicate. The mandatory
# original signature/count/type verifier remains a separate prerequisite.
@unsafe
def p112t_scalar_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,N111Ptr{},value}: False{}
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,N111Ptr{},op,left,right}: False{}
    case N111Bin{name,typ,op,left,right}: True{}
    case N111Call{name,N111U64{},symbol,args}: p112t_runtime_call(symbol) && p112t_runtime_args(args)
    case N111Load{name,N111U64{},N111Local{base},offset}: String.eq(base,"scratch")
    case N111Store{N111U64{},N111Local{base},offset,value}: String.eq(base,"scratch")
    case _: False{}
