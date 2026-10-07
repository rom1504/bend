import Base

def Scalar() -> Data:
  U32

def Real() -> Data:
  F32

def scalar(+x: Scalar) -> Scalar:
  U32.add(x, 9)

def real(+x: Real) -> Real:
  F32.add(x, 0.5)

def probe() -> U32:
  scalar(33)
