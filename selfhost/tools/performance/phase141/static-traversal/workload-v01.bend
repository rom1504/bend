# Small source-level proxy, not a compiler throughput benchmark.
# Final arguments: repetitions warmups list_size mode.
# mode 0 = runtime callback; 1 = handwritten typed; 2 = static callback.

def p141b_type(index: U32) -> N111Type:
  match index:
    case 0: N111U32{}
    case 1: N111U64{}
    case _: N111Ptr{}

def p141b_value(index: U32, +word: U32) -> N111Value:
  match index:
    case 0: N111Local{U32.show(word)}
    case 1: N111Const{word,U32.add(word,17)}
    case 2: N111Symbol{U32.show(word)}
    case 3: N111FuncId{U32.show(word)}
    case _: N111CtorId{U32.show(word)}

def p141b_arg(+index: U32, seed: U32) -> N111Arg:
  N111Arg{p141b_type(U32.mod(index,3)),p141b_value(U32.mod(index,5),U32.add(index,seed))}

def p141b_sentinel(seed: U32) -> N111Arg:
  N111Arg{N111U32{},N111Const{seed,0}}

# Different construction orders produce equal values independently. Inputs are
# retained and reused across repetitions, matching immutable compiler IR lists.
def p141b_left(left: Nat, +index: U32, +seed: U32) -> List<&2,N111Arg>:
  match left:
    case 0n: [p141b_sentinel(seed)]
    case 1n+rest: Con{p141b_arg(index,seed),p141b_left(rest,U32.inc(index),seed)}

def p141b_right(left: Nat, index: U32, +seed: U32, out: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match left:
    case 0n: out
    case 1n+rest:
      +previous = U32.sub(index,1)
      p141b_right(rest,previous,seed,Con{p141b_arg(previous,seed),out})

@unsafe
def p141b_compare(mode: U32, a: List<&2,N111Arg>, b: List<&2,N111Arg>) -> Bool:
  match mode:
    case 0: p134v_list(N111Arg,p140e_arg,a,b)
    case 1: p140e_args(a,b)
    case _: p141st_list(~N111Arg,~p140e_arg,a,b)

@unsafe
def p141b_once(+mode: U32, +a: List<&2,N111Arg>, b: List<&2,N111Arg>, changed: List<&2,N111Arg>, short: List<&2,N111Arg>) -> U32:
  U32.add(Bool.to_u32(p141b_compare(mode,a,b)),
    U32.add(U32.mul(2,Bool.to_u32(p141b_compare(mode,a,changed))),
      U32.add(U32.mul(4,Bool.to_u32(p141b_compare(mode,a,short))),
        U32.add(U32.mul(8,Bool.to_u32(p141b_compare(mode,[],[]))),
          U32.mul(16,Bool.to_u32(p141b_compare(mode,a,a)))))))

@unsafe
def p141b_loop(repetitions: Nat, +mode: U32, +a: List<&2,N111Arg>, +b: List<&2,N111Arg>, +changed: List<&2,N111Arg>, +short: List<&2,N111Arg>, sum: U32) -> U32:
  match repetitions:
    case 0n: sum
    case 1n+rest: p141b_loop(rest,mode,a,b,changed,short,U32.add(sum,p141b_once(mode,a,b,changed,short)))

@unsafe
def p141b_control(mode: U32, +size: U32) -> U32:
  +seed = U32.add(U32.mul(size,17),23)
  p141b_once(mode,p141b_left(U32.to_nat(size),0,seed),
    p141b_right(U32.to_nat(size),size,seed,[p141b_sentinel(seed)]),
    p141b_right(U32.to_nat(size),size,seed,[p141b_sentinel(U32.inc(seed))]),
    p141b_right(U32.to_nat(size),size,seed,[]))

@unsafe
def p141b_check() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p141b_control(0,0)))
    Unit <- IO.print(U32.show(p141b_control(1,0)))
    Unit <- IO.print(U32.show(p141b_control(2,0)))
    Unit <- IO.print(U32.show(p141b_control(0,17)))
    Unit <- IO.print(U32.show(p141b_control(1,17)))
    IO.print(U32.show(p141b_control(2,17)))

def p141b_nat(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p141b_word(value: Maybe<&2,U32>, fallback: U32) -> U32:
  match value:
    case None{}: fallback
    case Some{number}: number

@unsafe
def p141b_execute(repetitions: Nat, warmups: Nat, +size: U32, +mode: U32) -> IO(Unit):
  +seed = U32.add(U32.mul(size,17),23)
  +a = p141b_left(U32.to_nat(size),0,seed)
  +b = p141b_right(U32.to_nat(size),size,seed,[p141b_sentinel(seed)])
  +changed = p141b_right(U32.to_nat(size),size,seed,[p141b_sentinel(U32.inc(seed))])
  +short = p141b_right(U32.to_nat(size),size,seed,[])
  do IO<Unit>:
    Unit <- IO.print(U32.show(p141b_once(mode,a,b,changed,short)))
    Unit <- IO.print(U32.show(p141b_loop(warmups,mode,a,b,changed,short,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p141b_loop(repetitions,mode,a,b,changed,short,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))

@unsafe
def p141b_arguments(args: List<String>) -> IO(Unit):
  match args:
    case repetitions <> warmups <> size <> mode <> Nil{}:
      p141b_execute(p141b_nat(Nat.read(repetitions),64n),p141b_nat(Nat.read(warmups),2n),p141b_word(U32.read(size),256),p141b_word(U32.read(mode),2))
    case head <> rest: p141b_arguments(rest)
    case Nil{}: p141b_check()

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p141b_arguments(args)
