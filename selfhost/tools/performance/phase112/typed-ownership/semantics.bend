import Base

def P112TOAlias() -> Data:
  U32

def p112to_step(x: U32) -> U32:
  U32.inc(x)

def p112to_duplicate(+x: U32) -> U32:
  +alias = x
  U32.add(alias, alias)

def p112to_alias_type(+x: P112TOAlias()) -> U32:
  U32.add(x, x)

def p112to_capture(+x: U32, +text: String) -> String:
  sum = U32.add(p112to_step(x), x)
  String.append(String.append(text, U32.show(sum)), text)

def p112to_shadow(x: U32) -> String:
  +x = U32.show(x)
  String.append(x, x)

def p112to_owned_capture(+text: String) -> String:
  +kept = String.append(text, "!")
  String.append(String.append(kept, text), kept)

def p112to_boolean(+value: Bool) -> U32:
  U32.add(Bool.to_u32(value), Bool.to_u32(value))

def p112to_character(+value: Char) -> U32:
  U32.add(Char.to_u32(value), Char.to_u32(value))

def p112to_float(+value: F32) -> U32:
  U32.add(F32.bits(value), F32.bits(value))

def p112to_natural(+value: Nat) -> Nat:
  Nat.add(value, value)

def p112to_unused(value: U32) -> U32:
  42

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p112to_duplicate(2147483648)))
    Unit <- IO.print(U32.show(p112to_alias_type(4294967295)))
    Unit <- IO.print(p112to_capture(7, String.reverse("ab")))
    Unit <- IO.print(p112to_shadow(17))
    Unit <- IO.print(p112to_owned_capture(String.reverse("xy")))
    Unit <- IO.print(U32.show(p112to_boolean(True{})))
    Unit <- IO.print(U32.show(p112to_boolean(False{})))
    Unit <- IO.print(U32.show(p112to_character('λ')))
    Unit <- IO.print(U32.show(p112to_float(1.0)))
    Unit <- IO.print(Nat.show(p112to_natural(9n)))
    IO.print(U32.show(p112to_unused(4294967295)))

#|0
#|4294967294
#|ba15ba
#|1717
#|yx!yxyx!
#|2
#|0
#|1910
#|2130706432
#|18
#|42
