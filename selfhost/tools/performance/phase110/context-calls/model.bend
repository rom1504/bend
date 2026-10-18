# Diagnostic private call ABI. Original owning graphs and their certificates
# remain unchanged. The machine graph is checked against exact regeneration.
type Nx110CtxLibrary is Data:
  Nx110CtxLibrary{+source: Nx110RtLibrary, +mode: String, +machine: NxLibrary}

def nx110ctx_mode(+mode: String) -> Bool:
  String.eq(mode,"threaded") || String.eq(mode,"context")

def nx110ctx_name(+name: String) -> String:
  "ctx110_" ++ name

@unsafe
def nx110ctx_names(+workers: List<&2,Nx110RtWorker>) -> List<&2,String>:
  match workers:
    case Nil{}: []
    case Con{Nx110RtWorker{name,arity,next,ownership,view,function},rest}:
      Con{name,nx110ctx_names(rest)}
