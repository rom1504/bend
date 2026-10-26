# Native fixture code. Every timed iteration invokes the actual extracted Bend
# function renderer, writes its complete output and releases that output.
@unsafe
def p144ef_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p144ef_write(file: File, text: String) -> IO(File):
  do IO<File>:
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
    p144ef_written(pair)

@unsafe
def p144ef_repeat(file: File, left: Nat, +value: P144EFInput, +context: P134Context) -> IO(File):
  match left:
    case 0n: IO.pure(File,file)
    case 1n+rest:
      do IO<File>:
        file : File <- p144ef_write(file,p144ef_render(value,context))
        p144ef_repeat(file,rest,value,context)

@unsafe
def p144ef_run(repeats: Nat) -> IO(Unit):
  +value = p144ef_value()
  +context = p144ef_context()
  match repeats:
    case 0n:
      do IO<Unit>:
        file : File <- IO.try(File,File.open("/dev/stdout","a"))
        file : File <- p144ef_write(file,p144ef_render(value,context))
        File.close(file)
    case 1n+rest:
      do IO<Unit>:
        file : File <- IO.try(File,File.open("/dev/null","a"))
        start : Nat <- IO.now()
        file : File <- p144ef_repeat(file,1n+rest,value,context)
        Unit <- File.close(file)
        finish : Nat <- IO.now()
        IO.print(Nat.show(Nat.sub(finish,start)))

def p144ef_count(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p144ef_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case Con{head,tail}: p144ef_args(tail,p144ef_count(Nat.read(head),fallback))

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p144ef_run(p144ef_args(args,0n))
