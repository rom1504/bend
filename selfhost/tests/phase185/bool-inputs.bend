import Base

# Ordinary source transfer: booleans arrive from scalar comparisons through
# parameters, and results flow through calls, Bool.and/not and a constructor.
type Verdict is Data:
  Verdict{+either: Bool, +different: Bool}

def combine(+a: Bool, +b: Bool) -> Verdict:
  Verdict{Bool.or(a,b),Bool.xor(a,b)}

def score(verdict: Verdict) -> U32:
  match verdict:
    case Verdict{+either,different}:
      U32.add(Bool.to_u32(either),U32.mul(2,Bool.to_u32(Bool.and(either,Bool.not(Bool.not(different))))))

def from_inputs(+x: U32, +y: U32) -> U32:
  score(combine(U32.is_lt(x,y),U32.is_eq(U32.and(x,7),U32.and(y,7))))

def main() -> U32:
  U32.add(U32.add(from_inputs(0,0),from_inputs(1,0)),
    U32.add(U32.add(from_inputs(0,1),from_inputs(7,15)),
      U32.add(from_inputs(31,7),from_inputs(4294967295,0))))

#|10
