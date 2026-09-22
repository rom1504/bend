import Base

# Disposable component wrapper. Every compiler definition comes from the frozen
# combined source. The original native bundle supplies checked file IO helpers.
type ApPrepared is Data:
  ApPrepared{+context: List<&2,KDef>, +selected: List<&2,KDef>, +stops: List<&2,String>, +error: String}

@unsafe
def ap_error(+error: String) -> ApPrepared:
  ApPrepared{Nil{}, Nil{}, Nil{}, error}

@unsafe
def ap_ready(+book: List<&2,KDef>) -> ApPrepared:
  +context = book_context(book)
  +stops = j_stops(context)
  +selected = reach_book(context, j_roots(context, True{}), stops)
  +error = j_foreign_error(selected)
  ApPrepared{context, selected, stops, error}

@unsafe
def ap_specialized(+result: KSpecialized) -> ApPrepared:
  +error = specialized_error(result)
  kc(ApPrepared, String.eq(error, ""),
    u => ap_emit_owned(specialized_book(result)),
    u => ap_error(error))

@unsafe
def ap_emit_owned(+book: List<&2,KDef>) -> ApPrepared:
  +error = driver_emit_owned(book)
  kc(ApPrepared, String.eq(error, ""), u => ap_ready(book), u => ap_error(error))

@unsafe
def ap_owned(+book: List<&2,KDef>) -> ApPrepared:
  +error = driver_owned(book)
  kc(ApPrepared, String.eq(error, ""),
    u => kc(ApPrepared, U32.is_eq(driver_todos(book), 0),
      v => ap_specialized(specialize_book(book)), v => ap_error("TODO")),
    u => ap_error(error))

@unsafe
def ap_checked(+loaded: FResult) -> ApPrepared:
  match loaded:
    case FResult{+book, +error, imports}:
      kc(ApPrepared, String.eq(error, ""),
        u => ap_check_error(book, check_book(book)), u => ap_error(error))

@unsafe
def ap_check_error(+book: List<&2,KDef>, +error: String) -> ApPrepared:
  kc(ApPrepared, String.eq(error, ""), u => ap_owned(book), u => ap_error(error))

@unsafe
def ap_prepare(+input: String, +base: String, +text: String, +base_text: String) -> ApPrepared:
  ap_checked(f_load_graph(input, [FSource{input, input, text}, FSource{"Base", base, base_text}]))

@unsafe
def ap_len(+ds: List<&2,KDef>) -> U32:
  match ds:
    case Nil{}: 0
    case Con{d, rest}: U32.add(1, ap_len(rest))

@unsafe
def ap_take(+ds: List<&2,KDef>, +n: U32) -> List<&2,KDef>:
  kc(List<&2,KDef>, U32.is_eq(n, 0), u => Nil{}, u => ap_take_more(ds, n))

@unsafe
def ap_take_more(+ds: List<&2,KDef>, +n: U32) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{d, ap_take(rest, U32.sub(n, 1))}

@unsafe
def ap_drop(+ds: List<&2,KDef>, +n: U32) -> List<&2,KDef>:
  kc(List<&2,KDef>, U32.is_eq(n, 0), u => ds, u => ap_drop_more(ds, n))

@unsafe
def ap_drop_more(+ds: List<&2,KDef>, +n: U32) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: ap_drop(rest, U32.sub(n, 1))

@unsafe
def ap_join(+a: List<&2,KDef>, +b: List<&2,KDef>) -> List<&2,KDef>:
  match a:
    case Nil{}: b
    case Con{d, rest}: Con{d, ap_join(rest, b)}

@unsafe
def ap_fork2(+context: List<&2,KDef>, +selected: List<&2,KDef>, +stops: List<&2,String>) -> List<&2,KDef>:
  +half = U32.div(ap_len(selected), 2)
  +left = ap_take(selected, half)
  +right = ap_drop(selected, half)
  a b = ka_defs_except(context, left, stops) ka_defs_except(context, right, stops)
  ap_join(a, b)

@unsafe
def ap_fork4(+context: List<&2,KDef>, +selected: List<&2,KDef>, +stops: List<&2,String>) -> List<&2,KDef>:
  +half = U32.div(ap_len(selected), 2)
  +left = ap_take(selected, half)
  +right = ap_drop(selected, half)
  a b = ap_fork2(context, left, stops) ap_fork2(context, right, stops)
  ap_join(a, b)

@unsafe
def ap_dispatch(+mode: String, +context: List<&2,KDef>, +selected: List<&2,KDef>, +stops: List<&2,String>) -> List<&2,KDef>:
  kc(List<&2,KDef>, String.eq(mode, "serial"), u => ka_defs_except(context, selected, stops),
    u => kc(List<&2,KDef>, String.eq(mode, "fork2"), u => ap_fork2(context, selected, stops),
      u => ap_fork4(context, selected, stops)))

# Canonical, unambiguous complete structural serialization; includes removed
# names and all KDef fields. This is an exact oracle, not pretty-printed terms.
@unsafe
def ap_string(+s: String) -> String:
  Nat.show(String.length(s)) ++ ":" ++ s

@unsafe
def ap_strings(+xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ";"
    case Con{s, rest}: ap_string(s) ++ ap_strings(rest)

@unsafe
def ap_terms(+xs: List<&2,KTerm>) -> String:
  match xs:
    case Nil{}: ";"
    case Con{t, rest}: ap_term(t) ++ ap_terms(rest)

@unsafe
def ap_term(+t: KTerm) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      "T" ++ ap_string(tag) ++ ap_string(name) ++ U32.show(id) ++ "," ++ U32.show(quant) ++ ":" ++ ap_terms(kids) ++ ap_strings(removed)

@unsafe
def ap_def(+d: KDef) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      "D" ++ ap_string(name) ++ ap_string(kind) ++ U32.show(arity) ++ "," ++ U32.show(templates) ++ ":" ++ ap_term(typ) ++ ap_term(value) ++ ap_defs(ctors) ++ Bool.show(native) ++ "," ++ Bool.show(unsafe) ++ ";"

@unsafe
def ap_defs(+ds: List<&2,KDef>) -> String:
  match ds:
    case Nil{}: ";"
    case Con{d, rest}: ap_def(d) ++ ap_defs(rest)

# Structural consumption demands every field without allocating the large
# canonical serialization. Hash collisions cannot pass the later exact oracle.
@unsafe
def ap_mix(+h: U32, +n: U32) -> U32:
  U32.mul(U32.xor(h, n), 16777619)

@unsafe
def ap_hash_strings(+xs: List<&2,String>, +h: U32) -> U32:
  match xs:
    case Nil{}: ap_mix(h, 0)
    case Con{s, rest}: ap_hash_strings(rest, index_hash(s, ap_mix(h, 1)))

@unsafe
def ap_hash_terms(+xs: List<&2,KTerm>, +h: U32) -> U32:
  match xs:
    case Nil{}: ap_mix(h, 2)
    case Con{t, rest}: ap_hash_terms(rest, ap_hash_term(t, ap_mix(h, 3)))

@unsafe
def ap_hash_term(+t: KTerm, +h: U32) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      ap_hash_strings(removed, ap_hash_terms(kids, ap_mix(ap_mix(index_hash(name, index_hash(tag, h)), id), quant)))

@unsafe
def ap_hash_defs(+ds: List<&2,KDef>, +h: U32) -> U32:
  match ds:
    case Nil{}: ap_mix(h, 4)
    case Con{d, rest}: ap_hash_defs(rest, ap_hash_def(d, ap_mix(h, 5)))

@unsafe
def ap_hash_def(+d: KDef, +h: U32) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ap_mix(ap_mix(ap_hash_defs(ctors, ap_hash_term(value, ap_hash_term(typ, ap_mix(ap_mix(index_hash(kind, index_hash(name, h)), arity), templates)))), kc(U32, native, u => 1, u => 0)), kc(U32, unsafe, u => 1, u => 0))

@unsafe
def ap_timed(+mode: String, +output: String, +context: List<&2,KDef>, +selected: List<&2,KDef>, +stops: List<&2,String>) -> IO(U32):
  do IO<U32>:
    before : Nat <- IO.now()
    +annotated : List<&2,KDef> = ap_dispatch(mode, context, selected, stops)
    digest : U32 = ap_hash_defs(annotated, 2166136261)
    after : Nat <- IO.now()
    Unit <- IO.print_err("annotation_consume_ms=" ++ Nat.show(Nat.sub(after, before)))
    Unit <- IO.print_err("digest=" ++ U32.show(digest))
    Unit <- rapid_bundle_write_file(output, ap_defs(annotated))
    IO.pure(U32, 0)

@unsafe
def ap_prepared(+prepared: ApPrepared, +mode: String, +output: String) -> IO(U32):
  match prepared:
    case ApPrepared{+context, +selected, +stops, +error}:
      kc(IO(U32), String.eq(error, ""),
        u => do IO<U32>:
          Unit <- IO.print_err("selected=" ++ U32.show(ap_len(selected)))
          ap_timed(mode, output, context, selected, stops),
        u => IO.die(U32, 1, error))

@unsafe
def ap_paths(+input: String, +base: String, +output: String, +mode: String) -> IO(U32):
  do IO<U32>:
    text : String <- rapid_bundle_read_file(input)
    base_text : String <- rapid_bundle_read_file(base)
    before : Nat <- IO.now()
    +prepared : ApPrepared = ap_prepare(input, base, text, base_text)
    after : Nat <- IO.now()
    Unit <- IO.print_err("prepare_ms=" ++ Nat.show(Nat.sub(after, before)))
    ap_prepared(prepared, mode, output)

@unsafe
def ap_cli(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{input, Con{base, Con{output, Con{+mode, Nil{}}}}}:
      kc(IO(U32), String.eq(mode, "serial") || String.eq(mode, "fork2") || String.eq(mode, "fork4"),
        u => ap_paths(input, base, output, mode), u => IO.die(U32, 2, "unknown annotation mode"))
    case other: IO.die(U32, 2, "usage: annotation INPUT BASE OUTPUT serial|fork2|fork4")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    ap_cli(args)
