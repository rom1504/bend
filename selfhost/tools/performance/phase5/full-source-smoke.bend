import Base

# Tiny library with the same output oracle interface as the full compiler.
def f_ascii_ident_code(x: U32) -> Bool:
  U32.is_eq(x, 65)
