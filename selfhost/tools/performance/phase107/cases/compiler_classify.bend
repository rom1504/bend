import Base

law f_ascii_ident_code:
  for +code: U32
  Bool

@unsafe
def f_ascii_ident_code(code):
  U32.is_le(U32.sub(U32.or(code, 32), 97), 25) || U32.is_le(U32.sub(code, 48), 9) || U32.is_eq(code, 95) || U32.is_eq(code, 46)

law f_ascii_space_code:
  for +code: U32
  Bool

@unsafe
def f_ascii_space_code(code):
  U32.is_eq(code, 32) || U32.is_le(U32.sub(code, 9), 4)

def flag(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

def bench(n: U32, seed: U32) -> U32:
  U32.add(flag(f_ascii_ident_code(n)), U32.mul(flag(f_ascii_space_code(seed)), 2))

def main() -> U32:
  bench(19, 23)
