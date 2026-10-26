# Diagnostic parser slice. Input files and the private Base carrier are
# authenticated by the supervisor before invoking this fixed producer.
type P144PNResult is Data:
  P144PNParsed{+load: FPrefixLoad, +seed: P86Seed}
  P144PNError{+error: String}

@unsafe
def p144pn_loaded(seed: P86Seed, load: FPrefixLoad) -> P144PNResult:
  P144PNParsed{load,seed}

def p144pn_word(value: U32, hash: U32) -> U32:
  U32.mul(U32.xor(hash,value),16777619)

@unsafe
def p144pn_text(text: String, hash: U32) -> U32:
  match text:
    case SNil{}: p144pn_word(1100000,hash)
    case SCon{char,rest}: p144pn_text(rest,p144pn_word(Char.to_u32(char),hash))

@unsafe
def p144pn_texts(values: List<&2,String>, hash: U32) -> U32:
  match values:
    case Nil{}: p144pn_word(10,hash)
    case Con{head,tail}: p144pn_texts(tail,p144pn_text(head,p144pn_word(11,hash)))

@unsafe
def p144pn_terms(values: List<&2,KTerm>, hash: U32) -> U32:
  match values:
    case Nil{}: p144pn_word(20,hash)
    case Con{head,tail}: p144pn_terms(tail,p144pn_term(head,p144pn_word(21,hash)))

@unsafe
def p144pn_term(value: KTerm, hash: U32) -> U32:
  match value:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}:
      +h = p144pn_text(name,p144pn_text(tag,p144pn_word(30,hash)))
      +h = p144pn_word(quant,p144pn_word(id,h))
      +h = p144pn_texts(removed,p144pn_terms(kids,h))
      p144pn_word(end,p144pn_word(begin,h))
    case KLambda{name,id,quant,kids,removed,begin,end,present}:
      +h = p144pn_text(name,p144pn_word(31,hash))
      +h = p144pn_word(quant,p144pn_word(id,h))
      +h = p144pn_texts(removed,p144pn_terms(kids,h))
      p144pn_word(Bool.to_u32(present),p144pn_word(end,p144pn_word(begin,h)))
    case KLiteral{kind,number,text,begin,end}:
      +h = p144pn_text(kind,p144pn_word(32,hash))
      +h = p144pn_text(text,p144pn_word(number,h))
      p144pn_word(end,p144pn_word(begin,h))

@unsafe
def p144pn_defs(values: List<&2,KDef>, hash: U32) -> U32:
  match values:
    case Nil{}: p144pn_word(40,hash)
    case Con{head,tail}: p144pn_defs(tail,p144pn_def(head,p144pn_word(41,hash)))

@unsafe
def p144pn_def(value: KDef, hash: U32) -> U32:
  match value:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      +h = p144pn_text(kind,p144pn_text(name,p144pn_word(50,hash)))
      +h = p144pn_word(templates,p144pn_word(arity,h))
      +h = p144pn_def_terms(typ,value,ctors,h)
      p144pn_word(Bool.to_u32(unsafe),p144pn_word(Bool.to_u32(native),h))
    case KIndexLeaf{bucket_hash,bucket}:
      p144pn_defs(bucket,p144pn_word(bucket_hash,p144pn_word(51,hash)))
    case KIndexNode{bucket_hash,mask,left,right}:
      p144pn_def(right,p144pn_def(left,p144pn_word(mask,p144pn_word(bucket_hash,p144pn_word(52,hash)))))

@unsafe
def p144pn_def_terms(typ: KTerm, value: KTerm, ctors: List<&2,KDef>, hash: U32) -> U32:
  p144pn_defs(ctors,p144pn_term(value,p144pn_term(typ,hash)))

@unsafe
def p144pn_result_hash(result: FResult) -> U32:
  match result:
    case FResult{book,error,imports}:
      p144pn_terms(imports,p144pn_text(error,p144pn_defs(book,2166136261)))

@unsafe
def p144pn_hash(result: P144PNResult) -> U32:
  match result:
    case P144PNError{error}: p144pn_text(error,0)
    case P144PNParsed{load,seed}:
      match load:
        case FPrefixLoad{trace,prefix,suffix,ready}:
          match trace:
            case FLoadTrace{result,done,sources}: p144pn_result_hash(result)

@unsafe
def p144pn_error(result: P144PNResult) -> String:
  match result:
    case P144PNError{error}: error
    case P144PNParsed{load,seed}:
      match load:
        case FPrefixLoad{trace,prefix,suffix,ready}:
          match trace:
            case FLoadTrace{result,done,sources}:
              match result:
                case FResult{book,error,imports}: error

@unsafe
def p144pn_report(prepare_ms: Nat, parse_ms: Nat, observed: Nat, hash: U32) -> IO(U32):
  do IO<U32>:
    finished : Nat <- IO.now()
    Unit <- IO.print("phase144 prepare_ms " ++ Nat.show(prepare_ms))
    Unit <- IO.print("phase144 parse_ms " ++ Nat.show(parse_ms))
    Unit <- IO.print("phase144 observe_ms " ++ Nat.show(Nat.sub(finished,observed)))
    Unit <- IO.print("phase144 hash " ++ U32.show(hash))
    IO.pure(U32,0)

@unsafe
def p144pn_parsed(started: Nat, +prepared: Nat, +result: P144PNResult) -> IO(U32):
  do IO<U32>:
    parsed : Nat <- IO.now()
    p144pn_observe(started,prepared,parsed,result)

@unsafe
def p144pn_observe(started: Nat, +prepared: Nat, +parsed: Nat, +result: P144PNResult) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(p144pn_error(result)),
    u => p144pn_report(Nat.sub(prepared,started),Nat.sub(parsed,prepared),parsed,p144pn_hash(result)),
    u => IO.die(U32,1,p144pn_error(result)))

@unsafe
def p144pn_prepared(started: Nat, input: String, text: String, preparation: P86Preparation) -> IO(U32):
  match preparation:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        prepared : Nat <- IO.now()
        p144pn_parsed(started,prepared,p144pn_parse(seed,input,text))

@unsafe
def p144pn_files(+input: String, +base: String, carrier: String, stamp: String) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    base_text : String <- p86_read_file(base)
    carrier_text : String <- p86_read_file(carrier)
    started : Nat <- IO.now()
    p144pn_prepared(started,input,text,p88_cache_prepare(base,base_text,carrier_text,stamp))

@unsafe
def p144pn_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{input,Con{base,Con{carrier,Con{stamp,Nil{}}}}}}:
      p144pn_files(input,base,carrier,stamp)
    case _: IO.die(U32,2,"expected INPUT BASE CARRIER STAMP")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p144pn_args(args)
