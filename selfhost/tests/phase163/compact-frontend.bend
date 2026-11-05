# Shared baseline/compact-App frontend workload. No imports or main.
# Export only String-input/String-output wrappers, or use p163f_main as main.
# The loader/checker calls below are the maintained p86_plan prefix path, stopped
# before proof reporting, ownership eligibility, annotation and native lowering.

type P163FLoad is Data:
  P163FLoadError{+error: String}
  P163FLoadReady{+load: FPrefixLoad}

# Length-delimited complete observation. Physical App storage alone is erased;
# Lambda/literal variant identity and every public term field are retained.
@unsafe
def p163f_width(text: String, count: U32) -> U32:
  match text:
    case SNil{}: count
    case SCon{head,rest}: p163f_width(rest,U32.inc(count))

@unsafe
def p163f_string(+text: String) -> String:
  U32.show(p163f_width(text,0)) ++ ":" ++ text

def p163f_bool(value: Bool) -> String:
  match value:
    case True{}: "1"
    case False{}: "0"

@unsafe
def p163f_strings(values: List<&2,String>) -> String:
  match values:
    case Nil{}: "]"
    case Con{head,rest}: p163f_string(head) ++ p163f_strings(rest)

@unsafe
def p163f_variant(+term: KTerm) -> U32:
  +variant = prefix_state_variant(term)
  kc(U32,U32.is_eq(variant,3),u => 0,u => variant)

@unsafe
def p163f_term(+term: KTerm) -> String:
  "T" ++ U32.show(p163f_variant(term)) ++ ";" ++ p163f_string(tg(term)) ++ p163f_string(nm(term)) ++
    U32.show(ix(term)) ++ "," ++ U32.show(qt(term)) ++ "," ++ U32.show(kb(term)) ++ "," ++ U32.show(ke(term)) ++ ";" ++
    p163f_bool(k_quantity_present(term)) ++ p163f_bool(core_literal(term)) ++ U32.show(kl_number(term)) ++ ";" ++
    p163f_string(kl_text(term)) ++ p163f_terms(ks(term)) ++ p163f_strings(rm(term))

@unsafe
def p163f_terms(values: List<&2,KTerm>) -> String:
  match values:
    case Nil{}: "]"
    case Con{head,rest}: p163f_term(head) ++ p163f_terms(rest)

@unsafe
def p163f_def(value: KDef) -> String:
  match value:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      "D" ++ p163f_string(name) ++ p163f_string(kind) ++ U32.show(arity) ++ "," ++ U32.show(templates) ++ ";" ++
        p163f_term(typ) ++ p163f_term(value) ++ p163f_defs(ctors) ++ p163f_bool(native) ++ p163f_bool(unsafe)
    case KIndexLeaf{hash,bucket}: "F" ++ U32.show(hash) ++ ";" ++ p163f_defs(bucket)
    case KIndexNode{hash,mask,left,right}:
      "N" ++ U32.show(hash) ++ "," ++ U32.show(mask) ++ ";" ++ p163f_def(left) ++ p163f_def(right)

@unsafe
def p163f_defs(values: List<&2,KDef>) -> String:
  match values:
    case Nil{}: "]"
    case Con{head,rest}: p163f_def(head) ++ p163f_defs(rest)

@unsafe
def p163f_expr(value: DExpr) -> String:
  match value:
    case DText{text}: "S" ++ p163f_string(text)
    case DTerm{term}: "T" ++ p163f_term(term)

@unsafe
def p163f_span(value: DSpan) -> String:
  match value:
    case DNoSpan{}: "N"
    case DSpan{source,begin,end}: "S" ++ p163f_string(source) ++ U32.show(begin) ++ "," ++ U32.show(end) ++ ";"

@unsafe
def p163f_diagnostic(value: DDiagnostic) -> String:
  match value:
    case DDiagnostic{expected,observed,has_observed,context,definition,span,note,trail}:
      p163f_expr(expected) ++ p163f_expr(observed) ++ p163f_bool(has_observed) ++ p163f_terms(context) ++
        p163f_string(definition) ++ p163f_span(span) ++ p163f_string(note) ++ p163f_terms(trail)

@unsafe
def p163f_dresult(result: DResult) -> String:
  match result:
    case DResult{error,book,diagnostic}:
      "C" ++ p163f_defs(book) ++ "E" ++ p163f_string(error) ++ "D" ++ p163f_diagnostic(diagnostic)

@unsafe
def p163f_fresult(result: FResult) -> String:
  match result:
    case FResult{book,error,imports}:
      "P" ++ p163f_defs(book) ++ "E" ++ p163f_string(error) ++ "I" ++ p163f_terms(imports)

# Fixed in-memory source identities make origins identical across binaries and
# independent of the external paths used to transport the same bytes.
@unsafe
def p163f_load(+seed: P86Seed, +text: String) -> P163FLoad:
  match seed:
    case P86Seed{+base,book,fresh,ready,world}:
      +begin = f_source_end(base)
      +source = f_source_located(FSource{"/phase163/Main.bend","/phase163/Main.bend",text},
        begin,U32.add(U32.add(begin,p86_width(text,0)),1))
      p163f_header(seed,source,f_source_header(source))

@unsafe
def p163f_header(+seed: P86Seed, +source: FSource, +header: FHeader) -> P163FLoad:
  match header:
    case FHeader{imports,+error,body,line,offset}:
      kc(P163FLoad,String.is_empty(error),
        u => p163f_imported(seed,source,header,p86_import_error(imports,False{})),
        u => P163FLoadError{"parse: " ++ error})

@unsafe
def p163f_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String) -> P163FLoad:
  kc(P163FLoad,String.is_empty(error),u => p163f_seed(seed,source,header),u => P163FLoadError{"load: " ++ error})

@unsafe
def p163f_seed(+seed: P86Seed, +source: FSource, +header: FHeader) -> P163FLoad:
  match seed:
    case P86Seed{+base,+book,fresh,+ready,world}:
      p163f_seeded(seed,source,header,
        f_prefix_complete_ready_seed(base,"",f_prefix_graph_empty(),f_source_path(base),f_source_text(base),book,ready))

@unsafe
def p163f_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion) -> P163FLoad:
  match seed completion:
    case P86Seed{+base,book,fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      match parsed:
        case FResult{defs,+error,imports}:
          kc(P163FLoad,String.is_empty(error),
            u => p163f_completed(seed,source,
              f_prefix_complete_source(source,"",header,[source,base],carrier,f_path_dir(f_source_path(source)))),
            u => P163FLoadError{"parse: " ++ error})

@unsafe
def p163f_completed(seed: P86Seed, +source: FSource, completion: FPrefixCompletion) -> P163FLoad:
  match seed completion:
    case P86Seed{+base,book,fresh,ready,world} FPrefixCompletion{carrier,parsed}:
      P163FLoadReady{f_prefix_graph_trace(carrier,[source,base],fresh)}

@unsafe
def p163f_load_text(value: P163FLoad) -> String:
  match value:
    case P163FLoadError{error}: "E" ++ p163f_string(error)
    case P163FLoadReady{load}:
      match load:
        case FPrefixLoad{trace,prefix,suffix,eligible}:
          match trace:
            case FLoadTrace{result,done,sources}: p163f_fresult(result)

@unsafe
def p163f_check_loaded(+seed: P86Seed, +loaded: P163FLoad) -> DResult:
  match seed loaded:
    case P86Seed{base,book,fresh,ready,world} P163FLoadError{+error}:
      DResult{error,[],dg_no_report("",error)}
    case P86Seed{base,book,fresh,ready,+world} P163FLoadReady{+load}:
      match load:
        case FPrefixLoad{trace,prefix,+suffix,eligible}:
          match trace:
            case FLoadTrace{result,done,sources}:
              match result:
                case FResult{+original,+error,imports}:
                  kc(DResult,String.is_empty(error),
                    u => nt_choose(DResult,p143cg_enough(suffix,256),
                      v => p143cb_program(load,Nil{},world,True{}),
                      v => check_program_diagnostic_world(load,Nil{},world)),
                    u => DResult{"parse: " ++ error,original,dg_no_report("",error)})

@unsafe
def p163f_prepared(+check: Bool, +source: String, prepared: P86Preparation) -> String:
  match prepared:
    case P86PreparationError{error}: "B" ++ p163f_string(error)
    case P86PreparationReady{+seed}:
      +loaded = p163f_load(seed,source)
      kc(String,check,u => p163f_dresult(p163f_check_loaded(seed,loaded)),u => p163f_load_text(loaded))

@unsafe
def p163f_parse(base: String, source: String) -> String:
  p163f_prepared(False{},source,p86_prepare("/phase163/Base.bend",base))

@unsafe
def p163f_check(base: String, source: String) -> String:
  p163f_prepared(True{},source,p86_prepare("/phase163/Base.bend",base))

# Private generated-API only: the prepared value stays inside the exact image;
# it is never encoded through the public typed-driver term/cache ABI.
@unsafe
def p163f_prepare(base: String) -> P86Preparation:
  p86_prepare("/phase163/Base.bend",base)

@unsafe
def p163f_parse_prepared(seed: P86Seed, source: String) -> String:
  p163f_load_text(p163f_load(seed,source))

@unsafe
def p163f_check_prepared(+seed: P86Seed, source: String) -> String:
  p163f_dresult(p163f_check_loaded(seed,p163f_load(seed,source)))

# Native transport streams one definition at a time; its clocks stop before
# serialization and IO. End-to-end process time still includes observation.
@unsafe
def p163f_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p163f_write(file: File, text: String) -> IO(File):
  do IO<File>:
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
    p163f_written(pair)

@unsafe
def p163f_write_defs(file: File, values: List<&2,KDef>) -> IO(File):
  match values:
    case Nil{}: p163f_write(file,"]")
    case Con{head,rest}:
      do IO<File>:
        next : File <- p163f_write(file,p163f_def(head))
        p163f_write_defs(next,rest)

@unsafe
def p163f_write_result(output: String, prefix: String, book: List<&2,KDef>, tail: String) -> IO(Unit):
  do IO<Unit>:
    opened : File <- IO.try(File,File.open(output,"w"))
    header : File <- p163f_write(opened,prefix)
    body : File <- p163f_write_defs(header,book)
    end : File <- p163f_write(body,tail)
    File.close(end)

@unsafe
def p163f_finish(+error: String, observed: Nat) -> IO(U32):
  do IO<U32>:
    finished : Nat <- IO.now()
    Unit <- IO.print_err("observe_write_ms=" ++ Nat.show(Nat.sub(finished,observed)))
    kc(IO(U32),String.is_empty(error),u => IO.pure(U32,0),u => IO.die(U32,1,error))

@unsafe
def p163f_checked_io(output: String, before: Nat, result: DResult) -> IO(U32):
  match result:
    case DResult{+error,book,diagnostic}:
      do IO<U32>:
        +checked : Nat <- IO.now()
        Unit <- IO.print_err("check_ms=" ++ Nat.show(Nat.sub(checked,before)))
        Unit <- p163f_write_result(output,"C",book,"E" ++ p163f_string(error) ++ "D" ++ p163f_diagnostic(diagnostic))
        p163f_finish(error,checked)

@unsafe
def p163f_parse_io(output: String, observed: Nat, loaded: P163FLoad) -> IO(U32):
  match loaded:
    case P163FLoadError{+error}:
      do IO<U32>:
        Unit <- p86_write_file(output,"E" ++ p163f_string(error))
        p163f_finish(error,observed)
    case P163FLoadReady{load}:
      match load:
        case FPrefixLoad{trace,prefix,suffix,eligible}:
          match trace:
            case FLoadTrace{result,done,sources}:
              match result:
                case FResult{book,+error,imports}:
                  do IO<U32>:
                    Unit <- p163f_write_result(output,"P",book,"E" ++ p163f_string(error) ++ "I" ++ p163f_terms(imports))
                    p163f_finish(error,observed)

@unsafe
def p163f_loaded_io(+check: Bool, +seed: P86Seed, +output: String, before: Nat, +loaded: P163FLoad) -> IO(U32):
  do IO<U32>:
    +parsed : Nat <- IO.now()
    Unit <- IO.print_err("parse_load_ms=" ++ Nat.show(Nat.sub(parsed,before)))
    kc(IO(U32),check,
      u => p163f_checked_io(output,parsed,p163f_check_loaded(seed,loaded)),
      u => p163f_parse_io(output,parsed,loaded))

@unsafe
def p163f_ready_io(check: Bool, source: String, output: String, before: Nat, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{+error}:
      do IO<U32>:
        Unit <- p86_write_file(output,"B" ++ p163f_string(error))
        IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      do IO<U32>:
        +ready : Nat <- IO.now()
        Unit <- IO.print_err("base_prepare_ms=" ++ Nat.show(Nat.sub(ready,before)))
        p163f_loaded_io(check,seed,output,ready,p163f_load(seed,source))

@unsafe
def p163f_files(check: Bool, input: String, base: String, output: String) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    source : String <- p86_read_file(input)
    prelude : String <- p86_read_file(base)
    +read : Nat <- IO.now()
    Unit <- IO.print_err("read_ms=" ++ Nat.show(Nat.sub(read,started)))
    p163f_ready_io(check,source,output,read,p86_prepare("/phase163/Base.bend",prelude))

@unsafe
def p163f_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+command,Con{+mode,Con{+input,Con{+base,Con{+output,Nil{}}}}}}:
      kc(IO(U32),String.eq(command,"phase163-frontend") && (String.eq(mode,"parse") || String.eq(mode,"check")) &&
        String.starts_with(input,"/") && String.starts_with(base,"/") && String.starts_with(output,"/") &&
        Bool.not(String.eq(input,output)) && Bool.not(String.eq(base,output)),
        u => p163f_files(String.eq(mode,"check"),input,base,output),
        u => IO.die(U32,2,"usage: phase163-frontend parse|check ABS_SOURCE ABS_BASE DISTINCT_ABS_OUTPUT"))
    case _: IO.die(U32,2,"usage: phase163-frontend parse|check ABS_SOURCE ABS_BASE DISTINCT_ABS_OUTPUT")

@unsafe
def p163f_main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p163f_args(args)
