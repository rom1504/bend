# Required private ownership/machine namespace separation.
@unsafe
def nx110rt_workers_ok(+workers: List<&2,Nx110RtWorker>) -> Bool:
  match workers:
    case Nil{}: True{}
    case Con{Nx110RtWorker{name,arity,next,ownership,view,function},rest}:
      nx110rt_view_valid(view) && U32.is_gt(arity,0) && U32.is_lt(arity,9) &&
      nx110rtn_check(ownership,arity,next) && nxo_verify(ownership,arity) &&
      String.eq(nx_json_function(function),nx_json_function(nx110rt_function(name,arity,next,ownership,view))) &&
      nx110rt_workers_ok(rest)
