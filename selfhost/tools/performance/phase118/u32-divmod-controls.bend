import Base

# Default seed1 gives the literal oracle below. Reading argv keeps arithmetic
# inputs dynamic; optional numeric arguments intentionally change the output.
def division_seed(args: List<String>, fallback: U32) -> U32:
  match args:
    case Nil{}: fallback
    case head <> rest: division_next(U32.read(head),rest,fallback)

def division_next(value: Maybe<&2,U32>, rest: List<String>, fallback: U32) -> U32:
  match value:
    case None{}: division_seed(rest,fallback)
    case Some{word}: division_seed(rest,word)

def division_line(+a: U32, +b: U32) -> String:
  U32.show(a) ++ "/" ++ U32.show(b) ++ "=" ++
    U32.show(U32.div(a,b)) ++ "," ++ U32.show(U32.mod(a,b))

def division_run(+seed: U32) -> IO(Unit):
  +zero = U32.sub(seed,seed)
  +maximum = U32.sub(0,seed)
  +near = U32.sub(maximum,seed)
  +high = U32.add(2147483647,seed)
  +two = U32.add(seed,1)
  +three = U32.add(seed,2)
  +seven = U32.add(seed,6)
  +ten = U32.add(seed,9)
  +sixteen = U32.mul(seed,16)
  do IO<Unit>:
    IO.print(division_line(zero,zero))
    IO.print(division_line(seed,zero))
    IO.print(division_line(maximum,zero))
    IO.print(division_line(zero,maximum))
    IO.print(division_line(maximum,seed))
    IO.print(division_line(maximum,two))
    IO.print(division_line(maximum,three))
    IO.print(division_line(maximum,seven))
    IO.print(division_line(maximum,ten))
    IO.print(division_line(maximum,sixteen))
    IO.print(division_line(maximum,maximum))
    IO.print(division_line(near,three))
    IO.print(division_line(near,two))
    IO.print(division_line(high,three))
    IO.print(division_line(high,maximum))
    IO.print(division_line(high,high))
    IO.print(division_line(maximum,high))
    IO.print(division_line(U32.sub(high,seed),high))
    IO.print(division_line(U32.mul(seed,4000000000),U32.mul(seed,3000000000)))
    IO.print(division_line(seven,maximum))
    IO.print(division_line(U32.add(sixteen,seed),sixteen))
    IO.print(division_line(U32.mul(seed,123456789),U32.add(sixteen,seed)))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    division_run(division_seed(args,1))

#|0/0=0,0
#|1/0=0,1
#|4294967295/0=0,4294967295
#|0/4294967295=0,0
#|4294967295/1=4294967295,0
#|4294967295/2=2147483647,1
#|4294967295/3=1431655765,0
#|4294967295/7=613566756,3
#|4294967295/10=429496729,5
#|4294967295/16=268435455,15
#|4294967295/4294967295=1,0
#|4294967294/3=1431655764,2
#|4294967294/2=2147483647,0
#|2147483648/3=715827882,2
#|2147483648/4294967295=0,2147483648
#|2147483648/2147483648=1,0
#|4294967295/2147483648=1,2147483647
#|2147483647/2147483648=0,2147483647
#|4000000000/3000000000=1,1000000000
#|7/4294967295=0,7
#|17/16=1,1
#|123456789/17=7262164,1
