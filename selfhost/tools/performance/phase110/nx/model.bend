# Additive statement facade for atomic two-result calls. Scalar expressions,
# types, declarations and their verifier/emitter remain the shared Nx model.
# A pair result never becomes an address or a first-class NxExpr. Both outputs
# are assigned after the call, and the call remains a statement effect barrier.
type Nx110ImportPair is Data:
  Nx110ImportPair{+name: String, +params: List<&2,NxParam>, +first: NxType, +second: NxType}

type Nx110Stmt is Data:
  Nx110Scalar{+stmt: NxStmt}
  Nx110If{+condition: NxExpr, +yes: List<&2,Nx110Stmt>, +no: List<&2,Nx110Stmt>}
  Nx110While{+condition: NxExpr, +body: List<&2,Nx110Stmt>}
  Nx110CallPair{+first: String, +second: String, +name: String, +args: List<&2,NxExpr>}

type Nx110Function is Data:
  Nx110Function{+name: String, +params: List<&2,NxParam>, +result: NxType, +locals: List<&2,NxParam>, +body: List<&2,Nx110Stmt>}

type Nx110Library is Data:
  Nx110Library{+imports: List<&2,NxImport>, +pairs: List<&2,Nx110ImportPair>, +functions: List<&2,Nx110Function>, +exports: List<&2,String>}

@unsafe
def nx110_signatures(+functions: List<&2,Nx110Function>) -> List<&2,NxFunction>:
  match functions:
    case Nil{}: []
    case Con{Nx110Function{name,params,result,locals,body},rest}:
      Con{NxFunction{name,params,result,[],[]},nx110_signatures(rest)}

@unsafe
def nx110_find_pair(+name: String, +pairs: List<&2,Nx110ImportPair>) -> Maybe<&2,Nx110ImportPair>:
  match pairs:
    case Nil{}: None{}
    case Con{head,rest}:
      match head:
        case Nx110ImportPair{key,params,first,second}:
          nx_choose(Maybe<&2,Nx110ImportPair>,String.eq(name,key),u => Some{head},u => nx110_find_pair(name,rest))
