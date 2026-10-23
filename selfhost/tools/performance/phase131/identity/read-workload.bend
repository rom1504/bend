# Read-side discriminator: keep one constructed index alive across repeated
# complete exact-name queries. Construction remains in ordinary correctness
# controls but is outside the IO.now window in both timing variants.

@unsafe
def p131ir_loop(n: Nat, +names: List<&2,String>, +index: KDef, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+rest:
      p131ir_loop(rest,names,index,U32.add(acc,p131ip_digest(names,index,2166136261)))

@unsafe
def p131ip_execute(repetitions: Nat, warmups: Nat, size: Nat) -> IO(Unit):
  +names : List<&2,String> = p131ip_take(size,p131ip_names())
  +index : KDef = p131ip_build(names,p131ip_build(names,missing(),1),1001)
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131ip_digest(names,index,2166136261)))
    Unit <- IO.print(U32.show(p131ir_loop(warmups,names,index,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131ir_loop(repetitions,names,index,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))
