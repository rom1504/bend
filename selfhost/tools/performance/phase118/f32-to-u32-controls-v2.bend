import Base

# Filled ASCII-decimal helpers, with self-recursion only. Non-digit and empty
# argv words retain the prior seed; valid decimal words use U32 arithmetic.
# Default seed1 preserves the frozen oracle; numeric argv may change results.
def float_decimal_finish(valid: Bool, value: U32, fallback: U32) -> U32:
  match valid:
    case True{}: value
    case False{}: fallback

def float_decimal_digits(text: String, value: U32, valid: Bool, fallback: U32) -> U32:
  match text:
    case SNil{}: float_decimal_finish(valid,value,fallback)
    case SCon{Chr{word},tail}:
      +digit = U32.sub(word,48)
      float_decimal_digits(tail,U32.add(U32.mul(value,10),digit),Bool.and(valid,U32.is_lt(digit,10)),fallback)

def float_decimal(text: String, fallback: U32) -> U32:
  match text:
    case SNil{}: fallback
    case SCon{Chr{word},tail}:
      +digit = U32.sub(word,48)
      float_decimal_digits(tail,digit,U32.is_lt(digit,10),fallback)

def float_seed(args: List<String>, fallback: U32) -> U32:
  match args:
    case Nil{}: fallback
    case head <> rest: float_seed(rest,float_decimal(head,fallback))

def float_line(label: String, value: F32) -> String:
  label ++ "=" ++ U32.show(F32.to_u32(value))

def float_conversion_run(seed: U32) -> IO(Unit):
  +one = U32.to_f32(seed)
  +zero = F32.sub(one,one)
  +infinity = F32.div(one,zero)
  do IO<Unit>:
    IO.print(float_line("positive-zero",zero))
    IO.print(float_line("negative-zero",F32.neg(zero)))
    IO.print(float_line("negative-one",F32.neg(one)))
    IO.print(float_line("negative-fraction",F32.div(F32.neg(one),4.0)))
    IO.print(float_line("fraction",F32.div(one,4.0)))
    IO.print(float_line("truncate",F32.add(one,0.75)))
    IO.print(float_line("signed-boundary",F32.mul(one,2147483648.0)))
    IO.print(float_line("largest-below-limit",F32.mul(one,4294967040.0)))
    IO.print(float_line("at-limit",F32.mul(one,4294967296.0)))
    IO.print(float_line("above-limit",F32.mul(one,8589934592.0)))
    IO.print(float_line("positive-infinity",infinity))
    IO.print(float_line("negative-infinity",F32.neg(infinity)))
    IO.print(float_line("nan",F32.div(zero,zero)))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    float_conversion_run(float_seed(args,1))

#|positive-zero=0
#|negative-zero=0
#|negative-one=0
#|negative-fraction=0
#|fraction=0
#|truncate=1
#|signed-boundary=2147483648
#|largest-below-limit=4294967040
#|at-limit=0
#|above-limit=0
#|positive-infinity=0
#|negative-infinity=0
#|nan=0
