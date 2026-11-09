import Base

# Repeated observation after each comparison exercises the raw/packed Bool
# tests without changing NaN, infinity or signed-zero comparison semantics.
def fact_observe(+value: Bool) -> U32:
  match value:
    case True{}: Bool.to_u32(value)
    case False{}: Bool.to_u32(value)

def fact_compare(+a: F32, +b: F32) -> U32:
  U32.add(fact_observe(F32.is_eq(a,b)),
    U32.add(U32.mul(2,fact_observe(F32.is_ne(a,b))),
      U32.add(U32.mul(4,fact_observe(F32.is_lt(a,b))),
        U32.add(U32.mul(8,fact_observe(F32.is_le(a,b))),
          U32.add(U32.mul(16,fact_observe(F32.is_gt(a,b))),
            U32.mul(32,fact_observe(F32.is_ge(a,b))))))))

def main() -> List<&2,U32>:
  +nan = F32.div(0.0,0.0)
  +inf = F32.div(1.0,0.0)
  [fact_compare(1.0,2.0),fact_compare(2.0,1.0),fact_compare(1.0,1.0),
   fact_compare(0.0,F32.neg(0.0)),fact_compare(nan,1.0),fact_compare(1.0,nan),
   fact_compare(nan,nan),fact_compare(inf,1.0),fact_compare(F32.neg(inf),1.0),fact_compare(inf,inf)]

#|[14, 50, 41, 41, 2, 2, 2, 50, 14, 41]
