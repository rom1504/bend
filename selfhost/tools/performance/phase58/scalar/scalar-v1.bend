import Base

type ResidualPair is Type:
  ResidualPair{left: Word(30n), right: Word(30n)}

def residual(n: U32) -> U32:
  match n:
    case 34: 900
    case 92: 901
    case 8: 902
    case 9: 903
    case 10: 904
    case 12: 905
    case 13: 906
    case other: U32.add(other, 17)

def prefix(n: U32) -> U32:
  match n:
    case U32{WCon{True{}, WCon{False{}, tail}}}:
      U32{WCon{False{}, WCon{True{}, tail}}}
    case other: other

def swapbits(n: U32) -> U32:
  match n:
    case U32{WCon{False{}, WCon{bit, tail}}}:
      U32{WCon{bit, WCon{False{}, tail}}}
    case _: 0

def mixed(a: U32, b: U32) -> U32:
  match a:
    case U32{WCon{False{}, WCon{low, ta}}}:
      match b:
        case U32{WCon{False{}, WCon{lb, tb}}}:
          U32{WCon{False{}, WCon{low, tb}}}
        case _: 0
    case _: 0

def aliases(n: U32) -> ResidualPair:
  match n:
    case U32{WCon{a, WCon{b, +tail}}}:
      ResidualPair{tail, tail}

def touch(f: Word(30n) -> U32, n: U32) -> U32:
  match n:
    case U32{WCon{a, WCon{b, +tail}}}:
      U32.add(f(tail), U32{WCon{a, WCon{b, tail}}})

def ignore(n: U32) -> U32:
  match n:
    case U32{WCon{a, WCon{b, tail}}}: 7

def whole(n: U32) -> U32:
  match n:
    case U32{word}: U32{word}

def floated(x: F32) -> F32:
  match x:
    case 1.5: 1.5
    case other: other

def converted(x: F32) -> U32:
  match x:
    case F32{word}: U32{word}

def frombits(n: U32) -> F32:
  match n:
    case U32{word}: F32{word}

def high(n: U32) -> U32:
  match n:
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, tail}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      U32{WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, tail}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

    case other: other

def checksum() -> U32:
  U32.add(residual(100), prefix(10))
