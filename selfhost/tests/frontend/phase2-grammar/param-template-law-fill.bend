import Base
law ignore:
  for ~unused: Quant
  for x: U32
  U32
def ignore(unused, x):
  x
def main() -> U32:
  ignore(~&1, 7)
