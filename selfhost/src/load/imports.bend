# Module header paths are token sequences, including slash and dot tokens.

law f_import_path:
  for +ts: List<&2, FToken>
  for +path: String
  for +book: List<&2,KDef>
  for +imports: List<&2, KTerm>
  FRawResult

@unsafe
def f_import_path(ts, path, book, imports):
  f_choose(FRawResult, f_eq(f_tx(ts), "as"), u => f_import_alias(ts, path, book, imports), u => f_choose(FRawResult, f_eq(f_tx(ts), "\n") || f_eq(f_tx(ts), "<eof>"), u => f_choose(FRawResult, f_eq(path, "Base"), u => f_tops(ts, book, Con{kt("Import", path, 0, 0, Nil{}), imports}, False{}), u => f_result(book, kt("Error", "a module import requires as followed by an alias", 0, 0, Nil{}), imports)), u => f_import_path(f_tl(ts), path ++ f_tx(ts), book, imports)))

