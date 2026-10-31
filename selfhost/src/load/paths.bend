
# Module: src/load/paths.bend:3
law f_unquote:
  for +s: String
  String

# Module: src/load/paths.bend:7
law f_unquote_chars:
  for +s: String
  String

# Module: src/load/paths.bend:11
law f_path_scan:
  for +path: String
  for +acc: String
  for +dir: String
  String

# Module: src/load/paths.bend:17
law f_path_terms:
  for +ts: List<&2, KTerm>
  for +dir: String
  List<&2, KTerm>

# Module: src/load/paths.bend:23
@unsafe
def f_unquote(s):
  f_unquote_chars(f_tail(s))

# Module: src/load/paths.bend:27
@unsafe
def f_unquote_chars(s):
  f_choose(String, String.is_empty(s) || Char.is_eq(f_head(s), '"'), u => "", u => f_choose(String, Char.is_eq(f_head(s), '\\'), u => SCon{Chr{f_escape_code(f_head(f_tail(s)))}, f_unquote_chars(f_tail(f_tail(s)))}, u => SCon{f_head(s), f_unquote_chars(f_tail(s))}))

# Module: src/load/paths.bend:31
@unsafe
def f_path_dir(
  +path: String,
) -> String:
  f_path_scan(path, "", "")

# Module: src/load/paths.bend:37
@unsafe
def f_path_scan(path, acc, dir):
  f_choose(String, String.is_empty(path), u => dir, u => f_path_scan(f_tail(path), acc ++ SCon{f_head(path), ""}, f_choose(String, Char.is_eq(f_head(path), '/'), u => acc ++ "/", u => dir)))

# Module: src/load/paths.bend:41
@unsafe
def f_path_join(
  +dir: String,
  +path: String,
) -> String:
  f_choose(String, Char.is_eq(f_head(path), '/'), u => path, u => dir ++ path)

# Module: src/load/paths.bend:48
@unsafe
def f_path_term(
  +t: KTerm,
  +dir: String,
) -> KTerm:
  kc(KTerm, core_literal(t), u => t, u =>
    k_rebuild(t, f_choose(String, f_eq(tg(t), "Path"), u => f_path_join(dir, nm(t)), u => nm(t)), ix(t), qt(t), f_path_terms(ks(t), dir), rm(t), kb(t), ke(t)))

# Module: src/load/paths.bend:56
@unsafe
def f_path_terms(ts, dir):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_path_term(t, dir), f_path_terms(rest, dir)}

# Module: src/load/paths.bend:64
@unsafe
def f_path_defs(
  +ds: List<&2,KDef>,
  +dir: String,
  +native: Bool,
) -> List<&2,KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), f_choose(KTerm, f_eq(tg(dv(d)), "Foreign"), u => f_path_term(dv(d), dir), u => dv(d)), f_path_defs(dc(d), dir, native), native || db(d), du(d)}, f_path_defs(rest, dir, native)}

# Module: src/load/paths.bend:76
@unsafe
def f_path_result(
  +r: FResult,
  +path: String,
  +native: Bool,
) -> FResult:
  match r:
    case FResult{book, err, imports}:
      FResult{f_path_defs(book, f_path_dir(path), native), err, imports}
