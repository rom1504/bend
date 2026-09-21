# Source-relative foreign file paths and trusted Base declaration metadata.

law f_unquote:
  for +s: String
  String

law f_unquote_chars:
  for +s: String
  String

law f_path_dir:
  for +path: String
  String

law f_path_scan:
  for +path: String
  for +acc: String
  for +dir: String
  String

law f_path_join:
  for +dir: String
  for +path: String
  String

law f_path_term:
  for +t: KTerm
  for +dir: String
  KTerm

law f_path_terms:
  for +ts: List<&2, KTerm>
  for +dir: String
  List<&2, KTerm>

law f_path_defs:
  for +ds: List<&2,KDef>
  for +dir: String
  for +native: Bool
  List<&2,KDef>

law f_path_result:
  for +r: FResult
  for +path: String
  for +native: Bool
  FResult

@unsafe
def f_unquote(s):
  f_unquote_chars(f_tail(s))

@unsafe
def f_unquote_chars(s):
  f_choose(String, String.is_empty(s) || Char.is_eq(f_head(s), '"'), u => "", u => f_choose(String, Char.is_eq(f_head(s), '\\'), u => SCon{Chr{f_escape_code(f_head(f_tail(s)))}, f_unquote_chars(f_tail(f_tail(s)))}, u => SCon{f_head(s), f_unquote_chars(f_tail(s))}))

@unsafe
def f_path_dir(path):
  f_path_scan(path, "", "")

@unsafe
def f_path_scan(path, acc, dir):
  f_choose(String, String.is_empty(path), u => dir, u => f_path_scan(f_tail(path), acc ++ SCon{f_head(path), ""}, f_choose(String, Char.is_eq(f_head(path), '/'), u => acc ++ "/", u => dir)))

@unsafe
def f_path_join(dir, path):
  f_choose(String, Char.is_eq(f_head(path), '/'), u => path, u => dir ++ path)

@unsafe
def f_path_term(t, dir):
  KTerm{tg(t), f_choose(String, f_eq(tg(t), "Path"), u => f_path_join(dir, nm(t)), u => nm(t)), ix(t), qt(t), f_path_terms(ks(t), dir), rm(t)}

@unsafe
def f_path_terms(ts, dir):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_path_term(t, dir), f_path_terms(rest, dir)}

@unsafe
def f_path_defs(ds, dir, native):
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), f_choose(KTerm, f_eq(tg(dv(d)), "Foreign"), u => f_path_term(dv(d), dir), u => dv(d)), f_path_defs(dc(d), dir, native), native || db(d), du(d)}, f_path_defs(rest, dir, native)}

@unsafe
def f_path_result(r, path, native):
  match r:
    case FResult{book, err, imports}:
      FResult{f_path_defs(book, f_path_dir(path), native), err, imports}

