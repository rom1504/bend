import Base

# Ordinary typed FP dataflow with three values live across sqrt. The standalone
# native control invokes this worker with both positive and negative radicands.
def sqrt_hold(+x: F32, +y: F32, +z: F32) -> U32:
  +a = F32.add(x,y)
  +b = F32.mul(y,z)
  +c = F32.sub(x,z)
  +d = F32.sqrt(a)
  F32.bits(F32.add(F32.add(F32.mul(d,b),c),F32.mul(a,z)))

def main() -> IO(Unit):
  IO.print(U32.show(sqrt_hold(U32.to_f32(4),U32.to_f32(5),U32.to_f32(2))))
