import Base

type N111Type is Data:
  N111U32{}
  N111U64{}
  N111Ptr{}

type N111Value is Data:
  N111Local{+name: String}
  N111Const{+lo: U32, +hi: U32}
  N111Symbol{+name: String}
  N111FuncId{+name: String}
  N111CtorId{+name: String}

type N111Arg is Data:
  N111Arg{+typ: N111Type, +value: N111Value}

type N111Stmt is Data:
  N111Set{+name: String, +typ: N111Type, +value: N111Value}
  N111Bin{+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value}
  N111Call{+name: String, +typ: N111Type, +symbol: String, +args: List<&2, N111Arg>}
  N111If{+condition: N111Value, +yes: List<&2, N111Stmt>, +no: List<&2, N111Stmt>}
  N111Return{+value: N111Value}
  N111Load{+name: String, +typ: N111Type, +base: N111Value, +offset: U32}
  N111Store{+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value}
  N111Offset{+name: String, +base: N111Value, +bytes: N111Value}
  N111Alloca{+name: String, +bytes: U32, +align: U32}

type P113DStmt is Data:
  P113DScalar{+stmt: N111Stmt}
  P113DIf{+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>}
  P113DCall{+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>}
  P113DResult{+values: List<&2,N111Value>}
  P113DAgain{+values: List<&2,N111Value>}

def nt_choose(-A: Type, +b: Bool, t: Unit -> A, f: Unit -> A) -> A:
  match b:
    case True{}: t(Unit{})
    case False{}: f(Unit{})

def agy_str_eq(a: String, b: String) -> Bool:
  String.eq(a, b)

law w2_asr_strip_self:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w2_asr_strip_self(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+a,N111U64{},N111Local{+b}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(a,b),u => w2_asr_strip_self(rest),
        u => Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},w2_asr_strip_self(rest)})
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}
    case Con{P113DScalar{N111Bin{+d,+t,+op,N111Const{2,0},+x}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,N111Const{2,0},x}},w2_asr_strip_self(rest)})
    case Con{P113DScalar{N111Bin{+d,+t,+op,+x,N111Const{2,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,x,N111Const{2,0}}},w2_asr_strip_self(rest)})
    case Con{head,rest}: Con{head,w2_asr_strip_self(rest)}

def len_dstmt(xs: List<&2, P113DStmt>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{_, rest}: U32.add(1, len_dstmt(rest))

@unsafe
def main() -> U32:
  len_dstmt(w2_asr_strip_self([
    P113DScalar{N111Set{"x", N111U64{}, N111Local{"x"}}},
    P113DScalar{N111Set{"x", N111U64{}, N111Local{"y"}}},
    P113DScalar{N111Bin{"z", N111U64{}, "mul", N111Const{2, 0}, N111Local{"a"}}},
    P113DScalar{N111Bin{"w", N111U64{}, "mul", N111Local{"b"}, N111Const{2, 0}}},
    P113DScalar{N111Bin{"q", N111U64{}, "sub", N111Const{3, 0}, N111Const{4, 0}}},
    P113DResult{[N111Local{"w"}]}
  ]))
