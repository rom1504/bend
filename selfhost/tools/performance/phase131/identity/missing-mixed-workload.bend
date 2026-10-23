# Alternate an actual present compiler name with a guaranteed absent spelling.
# The query strings and index are created outside both timing windows.
def p131im_queries(names: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name,rest}:
      Con{name,Con{":missing:" ++ name,p131im_queries(rest)}}

@unsafe
def p131ip_once(+names: List<&2,String>) -> U32:
  +index = p131ip_build(names,p131ip_build(names,missing(),1),1001)
  p131ip_digest(p131im_queries(names),index,2166136261)

@unsafe
def p131ip_execute(repetitions: Nat, warmups: Nat, size: Nat) -> IO(Unit):
  +names : List<&2,String> = p131ip_take(size,p131ip_names())
  +index : KDef = p131ip_build(names,p131ip_build(names,missing(),1),1001)
  +queries : List<&2,String> = p131im_queries(names)
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131ip_digest(queries,index,2166136261)))
    Unit <- IO.print(U32.show(p131ir_loop(warmups,queries,index,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131ir_loop(repetitions,queries,index,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))
