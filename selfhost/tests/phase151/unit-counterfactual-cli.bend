# Optional native transport only. The supervisor hashes all three inputs before
# and after execution against the frozen manifest and requires a fresh output.
@unsafe
def p151u_write(path: String, text: String) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open(path,"w"))
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
    Unit <- p86_write_close(pair)
    IO.pure(U32,0)

@unsafe
def p151u_done(path: String, result: P151UText) -> IO(U32):
  match result:
    case P151UError{}: IO.die(U32,1,"unit counterfactual: missing, duplicate or mismatched selector body / call counts")
    case P151UText{text}: p151u_write(path,text)

@unsafe
def p151u_file(input: String, rolesPath: String, binaryPath: String, output: String) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    roles : String <- p86_read_file(rolesPath)
    binary : String <- p86_read_file(binaryPath)
    p151u_done(output,p151u_transform(text,roles,binary))

@unsafe
def p151u_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{input,Con{roles,Con{binary,Con{output,Nil{}}}}}}: p151u_file(input,roles,binary,output)
    case _: IO.die(U32,2,"expected IGNORED INPUT ROLESPIN BINARYPIN OUTPUT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p151u_args(args)
