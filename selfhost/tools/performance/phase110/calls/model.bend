# One live owning Term per parameter and one owning Term result. The enclosing
# checked source contract authenticates that representation; erased body labels
# alone are not a proof of arbitrary source ABI compatibility.
type NxcSource is Data:
  NxcSource{+fact: KDef, +symbol: String}

type NxcCallee is Data:
  NxcCallee{+source: String, +symbol: String, +arity: U32}

type NxcBody is Data:
  NxcBody{+source: String, +symbol: String, +ops: List<&2,NxoOp>}

type NxcLibraryResult is Data:
  NxcLibraryResult{+library: NxLibrary, +ownership: List<&2,NxcBody>, +error: String}

@unsafe
def nxc_catalogue(+sources: List<&2,NxcSource>) -> List<&2,NxcCallee>:
  match sources:
    case Nil{}: []
    case Con{NxcSource{fact,symbol},rest}: Con{NxcCallee{dn(fact),symbol,da(fact)},nxc_catalogue(rest)}

@unsafe
def nxc_find(+name: String, +callees: List<&2,NxcCallee>, +by_symbol: Bool) -> Maybe<&2,NxcCallee>:
  match callees:
    case Nil{}: None{}
    case Con{head,rest}:
      match head:
        case NxcCallee{source,symbol,arity}:
          nx_choose(Maybe<&2,NxcCallee>,String.eq(name,nx_choose(String,by_symbol,u => symbol,u => source)),u => Some{head},u => nxc_find(name,rest,by_symbol))

def nxc_missing(found: Maybe<&2,NxcCallee>) -> Bool:
  match found:
    case None{}: True{}
    case Some{value}: False{}
