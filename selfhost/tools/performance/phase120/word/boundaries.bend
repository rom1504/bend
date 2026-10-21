import Base

# Ordinary argv-seeded programs; literal expected lines are independent oracles.
def word_decimal_finish(valid: Bool, value: U32, fallback: U32) -> U32:
  match valid:
    case True{}: value
    case False{}: fallback

def word_decimal_digits(text: String, value: U32, valid: Bool, fallback: U32) -> U32:
  match text:
    case SNil{}: word_decimal_finish(valid,value,fallback)
    case SCon{Chr{word},tail}:
      +digit = U32.sub(word,48)
      word_decimal_digits(tail,U32.add(U32.mul(value,10),digit),Bool.and(valid,U32.is_lt(digit,10)),fallback)

def word_decimal(text: String, fallback: U32) -> U32:
  match text:
    case SNil{}: fallback
    case SCon{Chr{word},tail}:
      +digit = U32.sub(word,48)
      word_decimal_digits(tail,digit,U32.is_lt(digit,10),fallback)

def word_seed(args: List<String>, fallback: U32) -> U32:
  match args:
    case Nil{}: fallback
    case head <> rest: word_seed(rest,word_decimal(head,fallback))

def word_select_case(condition: Bool, yes: U32, no: U32) -> U32:
  match condition:
    case True{}: yes
    case False{}: no

def word_select(value: U32, yes: U32, no: U32) -> U32:
  word_select_case(U32.is_zero(value),yes,no)

def word_shift8(+x: U32) -> U32:
  U32.or(U32.shrn(x,8n),word_select(U32.shrn(x,31n),0,4278190080))

def word_shift1(+x: U32) -> U32:
  U32.or(U32.shrn(x,1n),word_select(U32.shrn(x,31n),0,2147483648))

def word_shift16(+x: U32) -> U32:
  U32.or(U32.shrn(x,16n),word_select(U32.shrn(x,31n),0,4294901760))

def word_shift31(+x: U32) -> U32:
  U32.or(U32.shrn(x,31n),word_select(U32.shrn(x,31n),0,4294967294))

# Independent arithmetic formulation: complemented unsigned division gives the
# floor of signed division for negative two's-complement integers.
def word_reference_case(nonnegative: Bool, x: U32) -> U32:
  match nonnegative:
    case True{}: U32.div(x,256)
    case False{}: U32.not(U32.div(U32.not(x),256))

def word_reference8(+x: U32) -> U32:
  word_reference_case(U32.is_lt(x,2147483648),x)

def word_line(+x: U32) -> String:
  U32.show(x) ++ ":" ++ U32.show(word_shift8(x)) ++ "," ++ U32.show(word_reference8(x)) ++
    "," ++ U32.show(word_shift1(x)) ++ "," ++ U32.show(word_shift16(x)) ++ "," ++ U32.show(word_shift31(x))

def word_run(+seed: U32) -> IO(Unit):
  +delta = U32.xor(seed,1)
  do IO<Unit>:
    IO.print(word_line(U32.xor(0,delta)))
    IO.print(word_line(U32.xor(1,delta)))
    IO.print(word_line(U32.xor(255,delta)))
    IO.print(word_line(U32.xor(256,delta)))
    IO.print(word_line(U32.xor(2147483392,delta)))
    IO.print(word_line(U32.xor(2147483647,delta)))
    IO.print(word_line(U32.xor(2147483648,delta)))
    IO.print(word_line(U32.xor(2147483649,delta)))
    IO.print(word_line(U32.xor(2147483903,delta)))
    IO.print(word_line(U32.xor(4294967040,delta)))
    IO.print(word_line(U32.xor(4294967294,delta)))
    IO.print(word_line(U32.xor(4294967295,delta)))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    word_run(word_seed(args,1))

#|0:0,0,0,0,0
#|1:0,0,0,0,0
#|255:0,0,127,0,0
#|256:1,1,128,0,0
#|2147483392:8388607,8388607,1073741696,32767,0
#|2147483647:8388607,8388607,1073741823,32767,0
#|2147483648:4286578688,4286578688,3221225472,4294934528,4294967295
#|2147483649:4286578688,4286578688,3221225472,4294934528,4294967295
#|2147483903:4286578688,4286578688,3221225599,4294934528,4294967295
#|4294967040:4294967295,4294967295,4294967168,4294967295,4294967295
#|4294967294:4294967295,4294967295,4294967295,4294967295,4294967295
#|4294967295:4294967295,4294967295,4294967295,4294967295,4294967295
