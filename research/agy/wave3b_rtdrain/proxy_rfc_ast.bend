import Base

# Realistic ~1s AST/ADT/RFC/String-heavy compiler-workload proxy:
# Exercises shared RFC takes (span_fade), unique RFC takes, p111_rt_keep,
# p111_rt_sink, p118_rt_borrow_scalar_safe, p111_rt_special_ctor, and p125_rt_ctor*.

type Expr is Data:
  ELit{v: U32}
  EVar{name: String}
  EAdd{l: Expr, r: Expr}
  ELet{name: String, val: Expr, body: Expr}

def mk_leaf(b: Bool, +seed: U32) -> Expr:
  match b:
    case True{}: ELit{seed}
    case False{}: EVar{String.append("v", U32.show(U32.and(seed, 15)))}

def mk_node(b: Bool, +seed: U32, l: Expr, r: Expr) -> Expr:
  match b:
    case True{}: ELet{String.append("x", U32.show(U32.and(seed, 7))), l, r}
    case False{}: EAdd{l, r}

def mk_ast(depth: Nat, +seed: U32) -> Expr:
  match depth:
    case 0n: mk_leaf(U32.is_eq(U32.and(seed, 1), 0), seed)
    case 1n+p:
      +pp = p
      l = mk_ast(pp, U32.add(U32.mul(seed, 3), 1))
      r = mk_ast(pp, U32.add(U32.mul(seed, 5), 2))
      mk_node(U32.is_eq(U32.and(seed, 3), 0), seed, l, r)

def pick_u32(b: Bool, t: U32, f: U32) -> U32:
  match b:
    case True{}: t
    case False{}: f

def eval_ast(e: Expr, +key: String, +kval: U32) -> U32:
  match e:
    case ELit{v}: v
    case EVar{n}: pick_u32(String.eq(n, key), kval, 7)
    case EAdd{l, r}:
      U32.xor(U32.mul(eval_ast(l, key, kval), 31), eval_ast(r, key, kval))
    case ELet{n, v, b}:
      +vv = eval_ast(v, key, kval)
      +next_kv = pick_u32(String.eq(n, key), vv, kval)
      U32.add(vv, eval_ast(b, key, next_kv))

def loop_shared(n: Nat, +ast: Expr, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +k = String.append("v", U32.show(U32.and(acc, 15)))
      +h = eval_ast(ast, k, U32.add(acc, 1))
      loop_shared(p, ast, U32.xor(U32.mul(acc, 131), h))

def main() -> IO(Unit):
  +ast = mk_ast(9n, 17)
  IO.print(U32.show(loop_shared(U32.to_nat(2000), ast, 1)))
