@unsafe
def p149t_rows(rows: List<&2,String>) -> IO(U32):
  match rows:
    case Nil{}: IO.pure(U32,0)
    case Con{+head,rest}:
      nt_choose(IO(U32),String.starts_with(head,"PASS "),
        u => do IO<U32>:
          Unit <- IO.print(head)
          p149t_rows(rest),
        u => IO.die(U32,1,head))

@unsafe
def p149t_controls() -> List<&2,String>:
  nt_append(String,p149p_controls(),nt_append(String,p149r_controls(),p149n_controls()))

@unsafe
def p149t_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Nil{}}:
      nt_choose(IO(U32),String.eq(program,"phase149-controls"),
        u => p149t_rows(p149t_controls()),u => p149_native_args([program]))
    case _: p149_native_args(args)
