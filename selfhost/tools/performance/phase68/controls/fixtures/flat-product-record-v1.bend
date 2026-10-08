# An unshared ordinary product crosses a named result-to-consumer boundary.
# Weighted fields detect both transport and field order: 11*100+31 = 1131.
import Base

type Product68 is Data:
  Product68{left: U32, right: U32}

def product_make68(left: U32, right: U32) -> Product68:
  Product68{left, right}

def product_consume68(value: Product68) -> U32:
  match value:
    case Product68{left, right}:
      U32.add(U32.mul(left, 100), right)

def main() -> U32:
  product_consume68(product_make68(11, 31))

#|1131
