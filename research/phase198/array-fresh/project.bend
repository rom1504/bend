def p198_project_choose(fresh: Bool, +n: U32, +seed: U32) -> U32:
  match fresh:
    case True{}:
      U32.mul(n, seed)
    case False{}:
      fold.finish(fold.loop(U32.to_nat(n), 0, ([seed : U32*128n], 0)))

def bench(+n: U32, +seed: U32) -> U32:
  p198_project_choose(U32.is_lt(n, 129), n, seed)
