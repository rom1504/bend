# Phase154 producer-to-consumer experiment. Binder identities stay numeric.
# P154Named is reserved for the producer's fixed/synthetic local spellings.
# A producer must not also spell a P154Binder as P154Named{"v_<id>"}.
type P154Name is Data:
  P154Binder{+id: U32}
  P154Named{+text: String}

type P154Binding is Data:
  P154Binding{+id: U32, +name: P154Name, +kind: N_WordKind}

type P154Value is Data:
  P154Local{+name: P154Name}
  P154Const{+lo: U32, +hi: U32}
  P154Symbol{+name: String}
  P154FuncId{+name: String}
  P154CtorId{+name: String}

type P154Arg is Data:
  P154Arg{+typ: N111Type, +value: P154Value}

type P154Stmt is Data:
  P154Set{+name: P154Name, +typ: N111Type, +value: P154Value}
  P154Bin{+name: P154Name, +typ: N111Type, +op: String, +left: P154Value, +right: P154Value}
  P154Call{+name: P154Name, +typ: N111Type, +symbol: String, +args: List<&2,P154Arg>}
  P154If{+condition: P154Value, +yes: List<&2,P154Stmt>, +no: List<&2,P154Stmt>}
  P154Return{+value: P154Value}
  P154Load{+name: P154Name, +typ: N111Type, +base: P154Value, +offset: U32}
  P154Store{+typ: N111Type, +base: P154Value, +offset: U32, +value: P154Value}
  P154Offset{+name: P154Name, +base: P154Value, +bytes: P154Value}
  P154Alloca{+name: P154Name, +bytes: U32, +align: U32}

type P154DStmt is Data:
  P154DScalar{+stmt: P154Stmt}
  P154DIf{+condition: P154Value, +yes: List<&2,P154DStmt>, +no: List<&2,P154DStmt>}
  P154DCall{+destinations: List<&2,P154Name>, +target: String, +args: List<&2,P154Value>}
  P154DResult{+values: List<&2,P154Value>}
  P154DAgain{+values: List<&2,P154Value>}

type P154DFunction is Data:
  P154DFunction{+name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, +body: List<&2,P154DStmt>}

type P154DCandidate is Data:
  P154DCandidate{+function: P154DFunction, +error: String, +calls: List<&2,String>}

@unsafe
def p154n_text(name: P154Name) -> String:
  match name:
    case P154Binder{id}: "v_" ++ U32.show(id)
    case P154Named{text}: text

@unsafe
def p154n_eq(left: P154Name, right: P154Name) -> Bool:
  match left right:
    case P154Binder{a} P154Binder{b}: U32.is_eq(a,b)
    case P154Named{a} P154Named{b}: String.eq(a,b)
    case _ _: False{}

# The key is not an equality certificate. A leaf resolves hash collisions using
# p154n_eq, including Binder-versus-Named collisions.
@unsafe
def p154n_hash(name: P154Name) -> U32:
  match name:
    case P154Binder{id}: id
    case P154Named{text}: index_hash(text,2166136261)

def p154d_scalars(body: List<&2,P154Stmt>) -> List<&2,P154DStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P154DScalar{stmt},p154d_scalars(rest)}

