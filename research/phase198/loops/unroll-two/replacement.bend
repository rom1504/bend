def fold.loop(+n: Nat, +i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      st
    case 1n:
      fold.cell(i, st)
    case 2n+q:
      +next = U32.inc(i)
      fold.loop(q, U32.inc(next), fold.cell(next, fold.cell(i, st)))
