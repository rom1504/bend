@unsafe
def p113i_lowered(+lowered: P113DLowering) -> P113DLowering:
  match lowered:
    case P113DLowered{program,+error}:
      nt_choose(P113DLowering,String.is_empty(error),
        u => P113DLowered{p113i_optimize(program),error},u => lowered)

# Exact scalar entry body with only the declaration renamed. The enhanced
# scalar profile's prepared/lowering helpers remain dynamically selected.
@unsafe
def p113i_scalar_lower_request(request: NR_Request) -> P113DLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})
