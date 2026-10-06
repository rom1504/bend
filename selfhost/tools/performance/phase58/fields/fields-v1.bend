import Base

type P58Fields is Type:
  P58Fields{__proto__: U32, constructor: U32, prototype: U32, default: U32, field.name: U32, snake_case: U32}

type P58NatFields is Type:
  P58NatFields{__proto__: Nat, constructor: Nat, field.name: Nat}

type P58Pair is Type:
  P58Pair{left: P58Fields, right: P58Fields}

def literal() -> P58Fields:
  P58Fields{1, 2, 3, 4, 5, 6}

def dynamic(+n: U32) -> P58Fields:
  P58Fields{n, U32.add(n, 1), U32.add(n, 2), U32.add(n, 3), U32.add(n, 4), U32.add(n, 5)}

def ordered(f: U32 -> U32, g: U32 -> U32, h: U32 -> U32) -> P58Fields:
  P58Fields{f(1), g(2), h(3), 4, 5, 6}

def natural(+n: Nat) -> P58NatFields:
  P58NatFields{n, n, n}

def roundtrip(value: P58NatFields) -> P58NatFields:
  value

def shared(+value: P58Fields) -> P58Pair:
  P58Pair{value, value}

def total(value: P58Fields) -> U32:
  match value:
    case P58Fields{a, b, c, d, e, f}:
      U32.add(a, U32.add(b, U32.add(c, U32.add(d, U32.add(e, f)))))

def checksum() -> U32:
  total(literal())
