# The ordinary machine verifier bounds pointers but allows state as a bounded
# buffer. A private worker must additionally keep runtime buffers off the state.
@unsafe
def p112t_buffer_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"scratch") && p112t_buffer_args(rest)
    case Con{N111Arg{N111Ptr{},value},rest}: False{}
    case Con{arg,rest}: p112t_buffer_args(rest)

@unsafe
def p112t_runtime_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"state") && p112t_buffer_args(rest)
    case _: False{}
