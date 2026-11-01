import Base

def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

@unsafe
def p148l_depth(+count: U32, +size: U32, +depth: Nat) -> Nat:
  nt_choose(Nat,U32.is_le(count,size),u => depth,u => p148l_depth(count,U32.mul(size,2),Succ{depth}))

@unsafe
def p148l_fill(+words: Array<U32>, +count: U32, +at: U32, +seed: U32) -> Array<U32>:
  nt_choose(Array<U32>,U32.is_lt(at,count),
    u => p148l_fill(Array.set(U32,words,at,U32.add(seed,U32.mul(at,3))),count,U32.inc(at),seed),u => words)

law p148l_sum:
  for +words: Array<U32>
  for +count: U32
  for +at: U32
  for +total: U32
  U32

@unsafe
def p148l_sum_step(pair: Array<U32> & U32, count: U32, at: U32, total: U32) -> U32:
  match pair:
    case Tuple{words,value}: p148l_sum(words,count,at,U32.add(total,value))

@unsafe
def p148l_sum(words,count,at,total):
  nt_choose(U32,U32.is_lt(at,count),
    u => p148l_sum_step(Array.get(U32,words,at),count,U32.inc(at),total),u => total)

law p148l_mix:
  for +words: Array<U32>
  for +count: U32
  for +at: U32
  Array<U32>

@unsafe
def p148l_mix_step(pair: Array<U32> & U32, count: U32, +at: U32) -> Array<U32>:
  match pair:
    case Tuple{words,value}: p148l_mix(Array.set(U32,words,at,U32.xor(value,7)),count,U32.inc(at))

@unsafe
def p148l_mix(words,count,at):
  nt_choose(Array<U32>,U32.is_lt(at,count),
    u => p148l_mix_step(Array.get(U32,words,at),count,at),u => words)

@unsafe
def p148l_name(pair: Array<String> & String, words: Array<U32>, +count: U32) -> U32:
  match pair:
    case Tuple{names,word}: U32.add(Bool.to_u32(String.eq(word,"phase148")),p148l_sum(p148l_mix(words,count,0),count,0,0))

@unsafe
def p148l_once(+count: U32, seed: U32) -> U32:
  p148l_name(Array.get(String,Array.new(String,0n,"phase148"),0),
    p148l_fill(Array.new(U32,p148l_depth(count,1,0n),0),count,0,seed),count)

@unsafe
def p148l_loop(+count: U32, +seed: U32, repeats: U32, total: U32) -> U32:
  match repeats:
    case 0: total
    case _: p148l_loop(count,seed,U32.sub(repeats,1),U32.add(total,p148l_once(count,seed)))

@unsafe
def p148l_run(count: Maybe<&2,U32>, seed: Maybe<&2,U32>, repeats: Maybe<&2,U32>) -> IO(Unit):
  match count seed repeats:
    case Some{+n} Some{s} Some{+r}:
      nt_choose(IO(Unit),U32.is_le(n,16384) && U32.is_le(r,100000),
        u => IO.print(U32.show(p148l_loop(n,s,r,0))),u => IO.die(Unit,2,"layout limits exceeded"))
    case _ _ _: IO.die(Unit,2,"invalid layout arguments")

@unsafe
def p148l_args(args: List<&1,String>) -> IO(Unit):
  match args:
    case Con{program,Con{n,Con{s,Con{r,Nil{}}}}}: p148l_run(U32.read(n),U32.read(s),U32.read(r))
    case _: IO.die(Unit,2,"usage: layout COUNT SEED REPEATS")

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1,String> <- IO.args()
    p148l_args(args)
