# Complete ordinary functions, before runtime continuation construction.
# Values remain full Terms. Acyclic ordinary calls and self-tail edges are
# admitted separately; physical scalar width never doubles as ownership proof.
type P113DStmt is Data:
  P113DScalar{+stmt: N111Stmt}
  P113DIf{+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>}
  P113DCall{+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>}
  P113DResult{+values: List<&2,N111Value>}
  P113DAgain{+values: List<&2,N111Value>}

type P113DTarget is Data:
  P113DReturn{}
  P113DLocal{+name: String}

type P113DCode is Data:
  P113DCode{+body: List<&2,P113DStmt>, +fresh: U32, +error: String, +calls: List<&2,String>}

type P113DFunction is Data:
  P113DFunction{+name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, +body: List<&2,P113DStmt>}

type P113DCandidate is Data:
  P113DCandidate{+function: P113DFunction, +error: String, +calls: List<&2,String>}

# The original verified/static program is always retained as fallback.
# Only original public segments whose name occurs in functions are wrapped.
type P113DProgram is Data:
  P113DProgram{+original: P112StaticProgram, +functions: List<&2,P113DFunction>}

type P113DLowering is Data:
  P113DLowered{+program: P113DProgram, +error: String}
