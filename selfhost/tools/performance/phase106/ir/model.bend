# Experimental native execution IR; independent of C text and machine registers.
# All locals start at typed zero. Expressions evaluate only in statement roots:
# calls/loads/allocations are forbidden inside operands and argument lists.
type NxType is Data:
  NxU32{}
  NxU64{}
  NxPtr{}
  NxBad{}

type NxParam is Data:
  NxParam{+name: String, +typ: NxType}

type NxExpr is Data:
  NxConst{+typ: NxType, +value: U32}
  NxVar{+name: String}
  NxBin{+op: String, +left: NxExpr, +right: NxExpr}
  NxCall{+name: String, +args: List<&2, NxExpr>}
  NxAlloc{+bytes: NxExpr}
  NxLoad{+typ: NxType, +ptr: NxExpr, +offset: U32}
  NxOffset{+ptr: NxExpr, +bytes: NxExpr}
  NxFunc{+name: String}
  NxICall{+callee: NxExpr, +args: List<&2, NxExpr>, +params: List<&2, NxType>, +result: NxType}

type NxStmt is Data:
  NxSet{+name: String, +value: NxExpr}
  NxIf{+condition: NxExpr, +yes: List<&2, NxStmt>, +no: List<&2, NxStmt>}
  NxWhile{+condition: NxExpr, +body: List<&2, NxStmt>}
  NxReturn{+value: NxExpr}
  NxStore{+typ: NxType, +ptr: NxExpr, +offset: U32, +value: NxExpr}
  NxFree{+ptr: NxExpr}

type NxFunction is Data:
  NxFunction{+name: String, +params: List<&2, NxParam>, +result: NxType, +locals: List<&2, NxParam>, +body: List<&2, NxStmt>}

type NxProgram is Data:
  NxProgram{+entry: String, +functions: List<&2, NxFunction>}

def nx_choose(-A: Type, b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def nx_type_name(t: NxType) -> String:
  match t:
    case NxU32{}: "u32"
    case NxU64{}: "u64"
    case NxPtr{}: "ptr"
    case NxBad{}: "invalid"

def nx_type_equal(a: NxType, b: NxType) -> Bool:
  match a b:
    case NxU32{} NxU32{}: True{}
    case NxU64{} NxU64{}: True{}
    case NxPtr{} NxPtr{}: True{}
    case _ _: False{}

def nx_scalar(t: NxType) -> Bool:
  match t:
    case NxU32{}: True{}
    case NxU64{}: True{}
    case _: False{}

def nx_bool32(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0
