# Public native compiler entry. Assembly supplies the immutable asset identities.
# The three effects do OS/byte work only; request and compiler policy stay here.
def NativeHost.read(path: String, digest: String, limit: U32) -> IO(Result<&1,&1,U32 & String,String>):
  import "./native-os.c"

def NativeHost.path(path: String) -> IO(Result<&1,&1,U32 & String,String>):
  import "./native-os.c"

def NativeHost.publish(path: String, text: String) -> IO(Result<&1,&1,U32 & String,Unit>):
  import "./native-os.c"

type NativeCLI is Type:
  CLIError {message: String}
  CLIHelp {}
  CLIVersion {}
  CLIRequest {input: String, output: String, live: Bool}

def cli_help() -> String:
  "Usage: bend INPUT.bend -o OUTPUT.c [--live]\n\nCompile one Base-importing Bend source to C. Existing outputs are refused.\nOptions: -o, --output PATH; --live (prepare Base without its cache);\n         --help; --version; -- (remaining arguments are input paths).\nSupported effects: IO.args/print/print_err/now and File.open/read/size/write/close.\nCompiler execution uses one CPU worker. Build emitted C separately."

@unsafe
def cli_parse(args: List<&1,String>) -> NativeCLI:
  match args:
    case Con{+arg, Nil{}}:
      kc(NativeCLI, String.eq(arg, "--help"), u => CLIHelp{}, u =>
        kc(NativeCLI, String.eq(arg, "--version"), v => CLIVersion{},
          v => cli_options(Con{arg, Nil{}}, "", "", False{}, False{})))
    case other: cli_options(other, "", "", False{}, False{})

@unsafe
def cli_options(args: List<&1,String>, +input: String, +output: String, +live: Bool, +positional: Bool) -> NativeCLI:
  match args:
    case Nil{}:
      kc(NativeCLI, String.is_empty(input) || String.is_empty(output),
        u => CLIError{"one input and -o OUTPUT.c are required"},
        u => CLIRequest{input, output, live})
    case Con{+arg, +rest}:
      kc(NativeCLI, Bool.not(positional) && (String.eq(arg, "-o") || String.eq(arg, "--output")),
        u => cli_output(rest, input, output, live), u =>
      kc(NativeCLI, Bool.not(positional) && String.eq(arg, "--"),
        u => cli_options(rest, input, output, live, True{}), u =>
      kc(NativeCLI, Bool.not(positional) && String.eq(arg, "--live"),
        u => kc(NativeCLI, live, v => CLIError{"duplicate --live"}, v => cli_options(rest, input, output, True{}, positional)), u =>
      kc(NativeCLI, Bool.not(positional) && String.starts_with(arg, "-"),
        u => CLIError{"unknown option: " ++ arg}, u =>
      kc(NativeCLI, String.is_empty(input) && Bool.not(String.is_empty(arg)),
        u => cli_options(rest, arg, output, live, positional),
        u => CLIError{"expected exactly one nonempty input path"})))))

@unsafe
def cli_output(args: List<&1,String>, input: String, +output: String, live: Bool) -> NativeCLI:
  match args:
    case Con{+path, rest}:
      kc(NativeCLI, Bool.not(String.is_empty(output)), u => CLIError{"duplicate output option"}, u =>
        kc(NativeCLI, String.is_empty(path), v => CLIError{"empty output path"},
          v => cli_options(rest, input, path, live, False{})))
    case Nil{}: CLIError{"missing output path"}

# All OS failures use exit 1; usage uses exit 2. Keep the operation/path message.
def cli_pass(-A: Type, result: Result<&1,&1,U32 & String,A>) -> IO(A):
  match result:
    case Done{value}: IO.pure(A, value)
    case Fail{(code, message)}: IO.die(A, 1, message)

@unsafe
def cli_read(+path: String, digest: String) -> IO(String):
  do IO<String>:
    result : Result<&1,&1,U32 & String,String> <- NativeHost.read(path, digest, 16777216)
    cli_read_done(result, path)

def cli_read_done(result: Result<&1,&1,U32 & String,String>, path: String) -> IO(String):
  match result:
    case Done{text}: IO.pure(String, text)
    case Fail{(code, message)}: IO.die(String, 1, "read " ++ path ++ ": " ++ message)

@unsafe
def cli_asset(+root: String, +name: String) -> IO(String):
  +digest = cli_digest(name)
  kc(IO(String), String.is_empty(digest), u => IO.die(String, 1, "unknown compiler asset: " ++ name),
    u => cli_read(root ++ "/assets/" ++ name, digest))

@unsafe
def cli_runtime(+root: String) -> IO(NE_Runtime):
  do IO<NE_Runtime>:
    p0 : String <- cli_asset(root, "runtime.c.part0")
    p1 : String <- cli_asset(root, "runtime.c.part1")
    p2 : String <- cli_asset(root, "runtime.c.part2")
    p3 : String <- cli_asset(root, "runtime.c.part3")
    p4 : String <- cli_asset(root, "runtime.c.part4")
    IO.pure(NE_Runtime, NE_Parts{[p0, p1, p2, p3, p4]})

@unsafe
def cli_prepared(+root: String, +input: String, text: String, output: String, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        runtime : NE_Runtime <- cli_runtime(root)
        result : P86Result <- p86_compile(p86_plan(seed, input, text), runtime, cli_base_identity(), root ++ "/assets/effs")
        cli_finish(output, result)

@unsafe
def cli_finish(output: String, result: P86Result) -> IO(U32):
  match result:
    case P86Result{+source, +error, verdict}:
      kc(IO(U32), String.is_empty(error), u =>
        kc(IO(U32), String.is_empty(source), v => IO.die(U32, 1, "compiler produced empty C"), v =>
          do IO<U32>:
            result : Result<&1,&1,U32 & String,Unit> <- NativeHost.publish(output, source)
            Unit <- cli_pass(Unit, result)
            Unit <- IO.print_err(verdict)
            IO.pure(U32, 0)),
        u => IO.die(U32, 1, error))

@unsafe
def cli_request(+input: String, +output: String, live: Bool) -> IO(U32):
  do IO<U32>:
    root_result : Result<&1,&1,U32 & String,String> <- NativeHost.path("")
    +root : String <- cli_pass(String, root_result)
    path_result : Result<&1,&1,U32 & String,String> <- NativeHost.path(input)
    +path : String <- cli_pass(String, path_result)
    +text : String <- cli_read(path, "")
    +base : String <- cli_asset(root, "base.bend")
    kc(IO(U32), live,
      u => cli_prepared(root, path, text, output, p86_prepare(cli_base_identity(), base)),
      u => do IO<U32>:
        cache : String <- cli_asset(root, "base.p88")
        cli_prepared(root, path, text, output, p88_cache_prepare(cli_base_identity(), base, cache, cli_cache_stamp())))

def cli_dispatch(request: NativeCLI) -> IO(U32):
  match request:
    case CLIError{message}: IO.die(U32, 2, message ++ "\n" ++ cli_help())
    case CLIHelp{}:
      do IO<U32>:
        Unit <- IO.print(cli_help())
        IO.pure(U32, 0)
    case CLIVersion{}:
      do IO<U32>:
        Unit <- IO.print("bend-native phase103 / phase102-lowering04 / native B2")
        IO.pure(U32, 0)
    case CLIRequest{input, output, live}: cli_request(input, output, live)

# The image startup adapter supplies one program-name slot on both runtime ABIs.
def cli_main(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program, rest}: cli_dispatch(cli_parse(rest))
    case Nil{}: IO.die(U32, 2, cli_help())

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    cli_main(args)
