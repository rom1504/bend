import Base
# t3_expr_peephole (std): Functional AST/Expression-tree peephole optimizer & evaluator
# Sealed-Test family 3: depth = 11 balanced trees, 280 rounds.

type Expr is Data:
  ELit{v: U32}
  EVar{id: U32}
  EAdd{a: Expr, b: Expr}
  EMul{a: Expr, b: Expr}
  EXor{a: Expr, b: Expr}
  ENeg{a: Expr}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def build_leaf(is_var: Bool, +seed: U32) -> Expr:
  match is_var:
    case False{}:
      ELit{U32.and(seed, 7)}
    case True{}:
      EVar{U32.and(U32.shrn(seed, 1n), 3)}

def build_expr(+depth: Nat, +seed: U32, op: Nat) -> Expr:
  match depth:
    case 0n:
      build_leaf(U32.is_ne(U32.and(seed, 1), 0), seed)
    case 1n+d:
      match op:
        case 0n:
          +s1 = prng(seed)
          +s2 = prng(U32.xor(s1, 2654435761))
          EAdd{build_expr(d, s1, U32.to_nat(U32.and(s1, 3))), build_expr(d, s2, U32.to_nat(U32.and(s2, 3)))}
        case 1n:
          +s1 = prng(seed)
          +s2 = prng(U32.xor(s1, 2654435761))
          EMul{build_expr(d, s1, U32.to_nat(U32.and(s1, 3))), build_expr(d, s2, U32.to_nat(U32.and(s2, 3)))}
        case 2n:
          +s1 = prng(seed)
          +s2 = prng(U32.xor(s1, 2654435761))
          EXor{build_expr(d, s1, U32.to_nat(U32.and(s1, 3))), build_expr(d, s2, U32.to_nat(U32.and(s2, 3)))}
        case 3n+p:
          +s1 = prng(seed)
          ENeg{build_expr(d, s1, U32.to_nat(U32.and(s1, 3)))}

def simp_neg(sa: Expr) -> Expr:
  match sa:
    case ELit{v}:
      ELit{U32.sub(0, v)}
    case ENeg{inner}:
      inner
    case EVar{id}:
      ENeg{EVar{id}}
    case EAdd{x, y}:
      ENeg{EAdd{x, y}}
    case EMul{x, y}:
      ENeg{EMul{x, y}}
    case EXor{x, y}:
      ENeg{EXor{x, y}}

def simp_add_lit_l(+va: U32, z: Bool, sb: Expr) -> Expr:
  match z:
    case True{}:
      sb
    case False{}:
      EAdd{ELit{va}, sb}

def simp_add_lit_r(+vb: U32, z: Bool, sa: Expr) -> Expr:
  match z:
    case True{}:
      sa
    case False{}:
      EAdd{sa, ELit{vb}}

def simp_add(sa: Expr, sb: Expr) -> Expr:
  match sa:
    case ELit{+va}:
      match sb:
        case ELit{+vb}:
          ELit{U32.add(va, vb)}
        case EVar{id}:
          simp_add_lit_l(va, U32.is_zero(va), EVar{id})
        case EAdd{x, y}:
          simp_add_lit_l(va, U32.is_zero(va), EAdd{x, y})
        case EMul{x, y}:
          simp_add_lit_l(va, U32.is_zero(va), EMul{x, y})
        case EXor{x, y}:
          simp_add_lit_l(va, U32.is_zero(va), EXor{x, y})
        case ENeg{x}:
          simp_add_lit_l(va, U32.is_zero(va), ENeg{x})
    case EVar{id}:
      match sb:
        case ELit{+vb}:
          simp_add_lit_r(vb, U32.is_zero(vb), EVar{id})
        case EVar{id2}:
          EAdd{EVar{id}, EVar{id2}}
        case EAdd{x, y}:
          EAdd{EVar{id}, EAdd{x, y}}
        case EMul{x, y}:
          EAdd{EVar{id}, EMul{x, y}}
        case EXor{x, y}:
          EAdd{EVar{id}, EXor{x, y}}
        case ENeg{x}:
          EAdd{EVar{id}, ENeg{x}}
    case EAdd{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_add_lit_r(vb, U32.is_zero(vb), EAdd{a1, a2})
        case EVar{id2}:
          EAdd{EAdd{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EAdd{EAdd{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EAdd{EAdd{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EAdd{EAdd{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EAdd{EAdd{a1, a2}, ENeg{x}}
    case EMul{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_add_lit_r(vb, U32.is_zero(vb), EMul{a1, a2})
        case EVar{id2}:
          EAdd{EMul{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EAdd{EMul{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EAdd{EMul{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EAdd{EMul{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EAdd{EMul{a1, a2}, ENeg{x}}
    case EXor{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_add_lit_r(vb, U32.is_zero(vb), EXor{a1, a2})
        case EVar{id2}:
          EAdd{EXor{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EAdd{EXor{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EAdd{EXor{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EAdd{EXor{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EAdd{EXor{a1, a2}, ENeg{x}}
    case ENeg{a1}:
      match sb:
        case ELit{+vb}:
          simp_add_lit_r(vb, U32.is_zero(vb), ENeg{a1})
        case EVar{id2}:
          EAdd{ENeg{a1}, EVar{id2}}
        case EAdd{x, y}:
          EAdd{ENeg{a1}, EAdd{x, y}}
        case EMul{x, y}:
          EAdd{ENeg{a1}, EMul{x, y}}
        case EXor{x, y}:
          EAdd{ENeg{a1}, EXor{x, y}}
        case ENeg{x}:
          EAdd{ENeg{a1}, ENeg{x}}

def simp_mul_lit_l(+va: U32, is0: Bool, is1: Bool, sb: Expr) -> Expr:
  match is0:
    case True{}:
      ELit{0}
    case False{}:
      match is1:
        case True{}:
          sb
        case False{}:
          EMul{ELit{va}, sb}

def simp_mul_lit_r(+vb: U32, is0: Bool, is1: Bool, sa: Expr) -> Expr:
  match is0:
    case True{}:
      ELit{0}
    case False{}:
      match is1:
        case True{}:
          sa
        case False{}:
          EMul{sa, ELit{vb}}

def simp_mul(sa: Expr, sb: Expr) -> Expr:
  match sa:
    case ELit{+va}:
      match sb:
        case ELit{+vb}:
          ELit{U32.mul(va, vb)}
        case EVar{id}:
          simp_mul_lit_l(va, U32.is_zero(va), U32.is_eq(va, 1), EVar{id})
        case EAdd{x, y}:
          simp_mul_lit_l(va, U32.is_zero(va), U32.is_eq(va, 1), EAdd{x, y})
        case EMul{x, y}:
          simp_mul_lit_l(va, U32.is_zero(va), U32.is_eq(va, 1), EMul{x, y})
        case EXor{x, y}:
          simp_mul_lit_l(va, U32.is_zero(va), U32.is_eq(va, 1), EXor{x, y})
        case ENeg{x}:
          simp_mul_lit_l(va, U32.is_zero(va), U32.is_eq(va, 1), ENeg{x})
    case EVar{id}:
      match sb:
        case ELit{+vb}:
          simp_mul_lit_r(vb, U32.is_zero(vb), U32.is_eq(vb, 1), EVar{id})
        case EVar{id2}:
          EMul{EVar{id}, EVar{id2}}
        case EAdd{x, y}:
          EMul{EVar{id}, EAdd{x, y}}
        case EMul{x, y}:
          EMul{EVar{id}, EMul{x, y}}
        case EXor{x, y}:
          EMul{EVar{id}, EXor{x, y}}
        case ENeg{x}:
          EMul{EVar{id}, ENeg{x}}
    case EAdd{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_mul_lit_r(vb, U32.is_zero(vb), U32.is_eq(vb, 1), EAdd{a1, a2})
        case EVar{id2}:
          EMul{EAdd{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EMul{EAdd{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EMul{EAdd{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EMul{EAdd{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EMul{EAdd{a1, a2}, ENeg{x}}
    case EMul{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_mul_lit_r(vb, U32.is_zero(vb), U32.is_eq(vb, 1), EMul{a1, a2})
        case EVar{id2}:
          EMul{EMul{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EMul{EMul{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EMul{EMul{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EMul{EMul{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EMul{EMul{a1, a2}, ENeg{x}}
    case EXor{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_mul_lit_r(vb, U32.is_zero(vb), U32.is_eq(vb, 1), EXor{a1, a2})
        case EVar{id2}:
          EMul{EXor{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EMul{EXor{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EMul{EXor{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EMul{EXor{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EMul{EXor{a1, a2}, ENeg{x}}
    case ENeg{a1}:
      match sb:
        case ELit{+vb}:
          simp_mul_lit_r(vb, U32.is_zero(vb), U32.is_eq(vb, 1), ENeg{a1})
        case EVar{id2}:
          EMul{ENeg{a1}, EVar{id2}}
        case EAdd{x, y}:
          EMul{ENeg{a1}, EAdd{x, y}}
        case EMul{x, y}:
          EMul{ENeg{a1}, EMul{x, y}}
        case EXor{x, y}:
          EMul{ENeg{a1}, EXor{x, y}}
        case ENeg{x}:
          EMul{ENeg{a1}, ENeg{x}}

def simp_xor_lit_l(+va: U32, z: Bool, sb: Expr) -> Expr:
  match z:
    case True{}:
      sb
    case False{}:
      EXor{ELit{va}, sb}

def simp_xor_lit_r(+vb: U32, z: Bool, sa: Expr) -> Expr:
  match z:
    case True{}:
      sa
    case False{}:
      EXor{sa, ELit{vb}}

def simp_xor(sa: Expr, sb: Expr) -> Expr:
  match sa:
    case ELit{+va}:
      match sb:
        case ELit{+vb}:
          ELit{U32.xor(va, vb)}
        case EVar{id}:
          simp_xor_lit_l(va, U32.is_zero(va), EVar{id})
        case EAdd{x, y}:
          simp_xor_lit_l(va, U32.is_zero(va), EAdd{x, y})
        case EMul{x, y}:
          simp_xor_lit_l(va, U32.is_zero(va), EMul{x, y})
        case EXor{x, y}:
          simp_xor_lit_l(va, U32.is_zero(va), EXor{x, y})
        case ENeg{x}:
          simp_xor_lit_l(va, U32.is_zero(va), ENeg{x})
    case EVar{id}:
      match sb:
        case ELit{+vb}:
          simp_xor_lit_r(vb, U32.is_zero(vb), EVar{id})
        case EVar{id2}:
          EXor{EVar{id}, EVar{id2}}
        case EAdd{x, y}:
          EXor{EVar{id}, EAdd{x, y}}
        case EMul{x, y}:
          EXor{EVar{id}, EMul{x, y}}
        case EXor{x, y}:
          EXor{EVar{id}, EXor{x, y}}
        case ENeg{x}:
          EXor{EVar{id}, ENeg{x}}
    case EAdd{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_xor_lit_r(vb, U32.is_zero(vb), EAdd{a1, a2})
        case EVar{id2}:
          EXor{EAdd{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EXor{EAdd{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EXor{EAdd{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EXor{EAdd{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EXor{EAdd{a1, a2}, ENeg{x}}
    case EMul{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_xor_lit_r(vb, U32.is_zero(vb), EMul{a1, a2})
        case EVar{id2}:
          EXor{EMul{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EXor{EMul{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EXor{EMul{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EXor{EMul{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EXor{EMul{a1, a2}, ENeg{x}}
    case EXor{a1, a2}:
      match sb:
        case ELit{+vb}:
          simp_xor_lit_r(vb, U32.is_zero(vb), EXor{a1, a2})
        case EVar{id2}:
          EXor{EXor{a1, a2}, EVar{id2}}
        case EAdd{x, y}:
          EXor{EXor{a1, a2}, EAdd{x, y}}
        case EMul{x, y}:
          EXor{EXor{a1, a2}, EMul{x, y}}
        case EXor{x, y}:
          EXor{EXor{a1, a2}, EXor{x, y}}
        case ENeg{x}:
          EXor{EXor{a1, a2}, ENeg{x}}
    case ENeg{a1}:
      match sb:
        case ELit{+vb}:
          simp_xor_lit_r(vb, U32.is_zero(vb), ENeg{a1})
        case EVar{id2}:
          EXor{ENeg{a1}, EVar{id2}}
        case EAdd{x, y}:
          EXor{ENeg{a1}, EAdd{x, y}}
        case EMul{x, y}:
          EXor{ENeg{a1}, EMul{x, y}}
        case EXor{x, y}:
          EXor{ENeg{a1}, EXor{x, y}}
        case ENeg{x}:
          EXor{ENeg{a1}, ENeg{x}}

def simplify(e: Expr) -> Expr:
  match e:
    case ELit{v}:
      ELit{v}
    case EVar{id}:
      EVar{id}
    case ENeg{a}:
      simp_neg(simplify(a))
    case EAdd{a, b}:
      simp_add(simplify(a), simplify(b))
    case EMul{a, b}:
      simp_mul(simplify(a), simplify(b))
    case EXor{a, b}:
      simp_xor(simplify(a), simplify(b))

def lookup_var(id: Nat, +x0: U32, +x1: U32, +x2: U32, +x3: U32) -> U32:
  match id:
    case 0n:
      x0
    case 1n:
      x1
    case 2n:
      x2
    case 3n+p:
      x3

def eval_expr(e: Expr, +x0: U32, +x1: U32, +x2: U32, +x3: U32) -> U32:
  match e:
    case ELit{v}:
      v
    case EVar{id}:
      lookup_var(U32.to_nat(id), x0, x1, x2, x3)
    case ENeg{a}:
      U32.sub(0, eval_expr(a, x0, x1, x2, x3))
    case EAdd{a, b}:
      U32.add(eval_expr(a, x0, x1, x2, x3), eval_expr(b, x0, x1, x2, x3))
    case EMul{a, b}:
      U32.mul(eval_expr(a, x0, x1, x2, x3), eval_expr(b, x0, x1, x2, x3))
    case EXor{a, b}:
      U32.xor(eval_expr(a, x0, x1, x2, x3), eval_expr(b, x0, x1, x2, x3))

def run_rounds(+rem: Nat, +r_idx: U32, +seed: U32, +acc: U32) -> U32:
  match rem:
    case 0n:
      acc
    case 1n+p:
      e = build_expr(11n, seed, U32.to_nat(U32.and(seed, 3)))
      se = simplify(e)
      +v = eval_expr(se, U32.add(r_idx, 3), U32.inc(U32.mul(r_idx, 7)), U32.add(U32.xor(r_idx, 13), 5), U32.add(r_idx, 19))
      run_rounds(p, U32.inc(r_idx), prng(seed), U32.xor(U32.mul(acc, 2654435761), v))

def main() -> U32:
  run_rounds(1120n, 0, 135792468, 2166136261)
