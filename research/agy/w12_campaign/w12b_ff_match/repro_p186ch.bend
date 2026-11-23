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

type P114TExpansion is Data:
  P114TExpansion{+body: List<&2, N111Stmt>, +changed: Bool}

def nt_choose(-A: Type, +b: Bool, t: Unit -> A, f: Unit -> A) -> A:
  match b:
    case True{}: t(Unit{})
    case False{}: f(Unit{})

def agy_str_eq(a: String, b: String) -> Bool:
  String.eq(a, b)

@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111U64{},+word},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+kind,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          u => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

def len_stmt(xs: List<&2, N111Stmt>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{_, rest}: U32.add(1, len_stmt(rest))

def score_exp(e: P114TExpansion) -> U32:
  match e:
    case P114TExpansion{body, changed}:
      U32.add(U32.mul(Bool.to_u32(changed), 10), len_stmt(body))

@unsafe
def main() -> U32:
  U32.add(
    U32.add(
      score_exp(p186ch_expand(N111Call{"r1", N111U64{}, "p111_rt_special_take", [
        N111Arg{N111Ptr{}, N111Local{"state"}},
        N111Arg{N111U32{}, N111Const{5, 0}},
        N111Arg{N111U64{}, N111Local{"w"}},
        N111Arg{N111Ptr{}, N111Local{"buf"}},
        N111Arg{N111U32{}, N111Const{1, 0}}]})),
      score_exp(p186ch_expand(N111Call{"r2", N111U64{}, "p111_rt_special_ctor", [
        N111Arg{N111Ptr{}, N111Local{"state"}},
        N111Arg{N111U32{}, N111Const{5, 0}},
        N111Arg{N111Ptr{}, N111Local{"buf"}},
        N111Arg{N111U32{}, N111Const{1, 0}}]}))),
    U32.add(
      score_exp(p186ch_expand(N111Call{"r3", N111U64{}, "p111_rt_special_ctor", [
        N111Arg{N111Ptr{}, N111Local{"state"}},
        N111Arg{N111U32{}, N111Const{2, 0}},
        N111Arg{N111Ptr{}, N111Local{"buf"}},
        N111Arg{N111U32{}, N111Const{0, 0}}]})),
      score_exp(p186ch_expand(N111Return{N111Const{0, 0}}))))
