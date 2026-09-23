# Refine only the error already selected by graph validation. Success is O(1).
law f_graph_result_at:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  FResult
law fpe_graph_result:
  for +graph: FGraph
  for +sources: List<&2,FSource>
  for +result: FResult
  FResult
law fpe_rejected:
  for +result: FResult
  for +book: List<&2,KDef>
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  FResult
law fpe_term:
  for +t: KTerm
  KTerm
law fpe_terms:
  for +ts: List<&2,KTerm>
  KTerm
law fpe_terms_next:
  for +error: KTerm
  for +rest: List<&2,KTerm>
  KTerm
law fpe_def:
  for +d: KDef
  KTerm
law fpe_defs:
  for +ds: List<&2,KDef>
  KTerm
law fpe_defs_next:
  for +error: KTerm
  for +rest: List<&2,KDef>
  KTerm
law fpe_find:
  for +ds: List<&2,KDef>
  for +index: U32
  KTerm
law fpe_find_next:
  for +error: KTerm
  for +rest: List<&2,KDef>
  for +index: U32
  KTerm
law fpe_selected:
  for +legacy: String
  for +owner: KTerm
  for +done: List<&2,KTerm>
  for +sources: List<&2,FSource>
  String
law fpe_owner_path:
  for +done: List<&2,KTerm>
  for +index: U32
  String
law fpe_unique_source:
  for +path: String
  for +sources: List<&2,FSource>
  for +found: KTerm
  KTerm
law fpe_source_render:
  for +legacy: String
  for +error: KTerm
  for +source: KTerm
  String

@unsafe
def f_graph_result_at(graph, sources):
  fpe_graph_result(graph, sources, f_graph_result(graph))
@unsafe
def fpe_graph_result(graph, sources, result):
  match graph:
    case FGraph{book, error, done}:
      f_choose(FResult, String.is_empty(error), u => fpe_rejected(result, book, done, sources), u => result)
@unsafe
def fpe_rejected(result, book, done, sources):
  match result:
    case FResult{out, +error, imports}:
      FResult{out, f_choose(String, String.is_empty(error), u => error, u => fpe_selected(error, fpe_find(book, 0), done, sources)), imports}

# Exactly the existing f_error_* traversal order, including empty-name Error skip.
@unsafe
def fpe_term(t):
  f_choose(KTerm, f_eq(tg(t), "Error"), u => f_choose(KTerm, String.is_empty(nm(t)), u => atom("Absent"), u => t), u => fpe_terms(ks(t)))
@unsafe
def fpe_terms(ts):
  match ts:
    case Nil{}: atom("Absent")
    case Con{head, tail}: fpe_terms_next(fpe_term(head), tail)
@unsafe
def fpe_terms_next(error, rest):
  f_choose(KTerm, f_eq(tg(error), "Absent"), u => fpe_terms(rest), u => error)
@unsafe
def fpe_def(d):
  fpe_defs_next(fpe_terms([dt(d), dv(d)]), dc(d))
@unsafe
def fpe_defs(ds):
  match ds:
    case Nil{}: atom("Absent")
    case Con{head, tail}: fpe_defs_next(fpe_def(head), tail)
@unsafe
def fpe_defs_next(error, rest):
  f_choose(KTerm, f_eq(tg(error), "Absent"), u => fpe_defs(rest), u => error)
@unsafe
def fpe_find(ds, index):
  match ds:
    case Nil{}: atom("Absent")
    case Con{head, tail}: fpe_find_next(fpe_def(head), tail, index)
@unsafe
def fpe_find_next(error, rest, index):
  f_choose(KTerm, f_eq(tg(error), "Absent"), u => fpe_find(rest, U32.add(index, 1)), u => kt("ParseOwner", "", index, 0, [error]))
@unsafe
def fpe_selected(legacy, owner, done, sources):
  f_choose(String, f_eq(tg(owner), "ParseOwner") && String.eq(nm(kid(owner, 0)), legacy), u => fpe_source_render(legacy, kid(owner, 0), fpe_unique_source(fpe_owner_path(List.reverse(&2, KTerm, done), ix(owner)), sources, atom("Absent"))), u => legacy)
@unsafe
def fpe_owner_path(done, index):
  match done:
    case Nil{}: ""
    case Con{head, tail}:
      f_choose(String, U32.is_lt(index, ix(head)), u => nm(head), u => fpe_owner_path(tail, U32.sub(index, ix(head))))
@unsafe
def fpe_unique_source(path, sources, found):
  match sources:
    case Nil{}: found
    case Con{head, tail}:
      f_choose(KTerm, String.eq(path, f_source_path(head)), u => f_choose(KTerm, f_eq(tg(found), "Absent"), u => fpe_unique_source(path, tail, kt("ParseSource", f_source_text(head), 0, 0, Nil{})), u => atom("Ambiguous")), u => fpe_unique_source(path, tail, found))
@unsafe
def fpe_source_render(legacy, error, source):
  f_choose(String, f_eq(tg(source), "ParseSource"), u => fpe_render(nm(source), error), u => legacy)
