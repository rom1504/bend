# Ordinary native F32 boundary witnesses; no unsafe declarations or foreign code.
import Base

def channel.from_bits(value: U32) -> F32:
  U32{word} = value
  F32{word}

def channel.raw_bits(value: F32) -> U32:
  F32{word} = value
  U32{word}

def channel.select(flag: Bool, left: F32, right: F32) -> F32:
  match flag:
    case True{}: left
    case False{}: right

def channel.forward(flag: Bool, value: F32) -> F32:
  channel.select(flag, value, 0.0)

def channel.add(a: F32, b: F32) -> F32:
  F32.add(a, b)

def channel.sub(a: F32, b: F32) -> F32:
  F32.sub(a, b)

def channel.mul(a: F32, b: F32) -> F32:
  F32.mul(a, b)

def channel.rounded(a: F32, b: F32, c: F32) -> F32:
  channel.sub(channel.add(a, b), c)

def channel.unfused(a: F32, b: F32) -> F32:
  channel.sub(channel.mul(a, b), 1.0)

def channel.rebind(flag: Bool, +a: F32, b: F32) -> F32:
  +old = channel.add(a, b)
  alias = old
  a = channel.select(flag, channel.mul(a, 2.0), 0.5)
  channel.sub(alias, a)

def channel.word(value: U32) -> U32:
  U32.add(value, 1)

def channel.boolean(value: Bool) -> U32:
  match value:
    case False{}: 0
    case True{}: 1

def channel.print_bits(value: F32) -> IO(Unit):
  IO.print(U32.show(channel.raw_bits(value)))

def channel.alias(+value: F32) -> IO(Unit):
  do IO<Unit>:
    Unit <- channel.print_bits(channel.add(value, 1.0))
    channel.print_bits(value)

def channel.effect(label: String, value: F32) -> IO(F32):
  do IO<F32>:
    Unit <- IO.print(label)
    IO.pure(F32, value)

# Conversion receives runtime loop arguments; raw input bits are observed too.
def channel.convert_bits(+bits: U32) -> IO(Unit):
  IO.print(U32.show(bits) ++ ":" ++ U32.show(F32.to_u32(channel.from_bits(bits))))

def channel.convert_all(values: List<U32>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit, Unit)
    case head <> rest:
      do IO<Unit>:
        Unit <- channel.convert_bits(head)
        channel.convert_all(rest)

def channel.convert_chain(value: F32) -> IO(Unit):
  IO.print(U32.show(F32.to_u32(F32.mul(value, 2.0))))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(0)))
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(2147483648)))
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(2139095040)))
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(4286578688)))
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(2143289345)))
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(4290772993)))
    Unit <- channel.print_bits(channel.forward(True{}, channel.from_bits(1)))
    Unit <- channel.print_bits(channel.forward(False{}, channel.from_bits(2147483648)))
    Unit <- channel.print_bits(channel.rounded(16777216.0, 1.0, 16777216.0))
    Unit <- channel.print_bits(channel.unfused(1.00000011920928955078125, 0.99999988079071044921875))
    Unit <- channel.print_bits(channel.rebind(True{}, 1.5, 2.5))
    Unit <- channel.print_bits(channel.rebind(False{}, 1.5, 2.5))
    Unit <- IO.print(U32.show(channel.word(1065353216)))
    Unit <- channel.print_bits(channel.add(channel.from_bits(1065353216), 1.0))
    Unit <- IO.print(U32.show(channel.boolean(F32.is_eq(channel.from_bits(2143289345), 1.0))))
    Unit <- IO.print(U32.show(channel.boolean(F32.is_ne(channel.from_bits(2143289345), 1.0))))
    Unit <- channel.alias(1.5)
    first : F32 <- channel.effect("first", 1.5)
    second : F32 <- channel.effect("second", 2.5)
    Unit <- channel.print_bits(channel.sub(first, second))
    Unit <- channel.convert_all([0,2147483648,1,2147483649,8388607,8388608,1065353215,1065353216,3212836864,1069547520,1073741823,1073741824,1325400063,1325400064,1325400065,1333788670,1333788671,1333788672,1333788673,2139095040,4286578688,2143289345,4290772993,2139095041,4286578689])
    Unit <- channel.convert_chain(1.75)
    Unit <- channel.convert_chain(2147483520.0)
    channel.convert_chain(2147483648.0)
