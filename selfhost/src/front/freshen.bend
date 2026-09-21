# Alpha-renaming assigns globally unique binder IDs after graph assembly.
type FFresh is Data:
  FFresh{+term: KTerm, next: U32}

type FFreshTerms is Data:
  FFreshTerms{+terms: List<&2, KTerm>, next: U32}

type FFreshDefs is Data:
  FFreshDefs{+defs: List<&2, KDef>, next: U32}

law f_fresh_term:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +next: U32
  FFresh

law f_rename_var:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

law f_fresh_terms:
  for +ts: List<&2, KTerm>
  for +env: List<&2, KTerm>
  for +next: U32
  FFreshTerms

law f_fresh_cons:
  for +r: FFresh
  for +rest: List<&2, KTerm>
  for +env: List<&2, KTerm>
  FFreshTerms

law f_fresh_prepend:
  for +t: KTerm
  for +r: FFreshTerms
  FFreshTerms

law f_fresh_generic:
  for +t: KTerm
  for +r: FFreshTerms
  FFresh

law f_fresh_all:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +id: U32
  for +r: FFresh
  FFresh

law f_fresh_all_body:
  for +t: KTerm
  for +id: U32
  for +a: KTerm
  for +r: FFresh
  FFresh

law f_fresh_lam:
  for +t: KTerm
  for +id: U32
  for +r: FFresh
  FFresh

law f_fresh_let:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +bodyenv: List<&2, KTerm>
  for +next: U32
  for +items: List<&2, KTerm>
  for +acc: List<&2, KTerm>
  FFresh

law f_fresh_let_body:
  for +acc: List<&2, KTerm>
  for +r: FFresh
  FFresh

law f_fresh_let_value:
  for +t: KTerm
  for +env: List<&2, KTerm>
  for +bodyenv: List<&2, KTerm>
  for +id: U32
  for +binding: KTerm
  for +rest: List<&2, KTerm>
  for +acc: List<&2, KTerm>
  for +r: FFresh
  FFresh

law f_fresh_defs:
  for +ds: List<&2,KDef>
  for +next: U32
  FFreshDefs

law f_fresh_def_type:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +r: FFresh
  FFreshDefs

law f_fresh_def_value:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +ty: KTerm
  for +r: FFresh
  FFreshDefs

law f_fresh_def_ctors:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +ty: KTerm
  for +value: KTerm
  for +r: FFreshDefs
  FFreshDefs

law f_fresh_defs_prepend:
  for +d: KDef
  for +r: FFreshDefs
  FFreshDefs

law f_fresh_result:
  for +r: FResult
  FResult

law f_fresh_result_end:
  for +r: FFreshDefs
  for +err: String
  for +imports: List<&2, KTerm>
  FResult

@unsafe
def f_fresh_term(t, env, next):
  f_fresh_stack(t, env, next)

@unsafe
def f_rename_var(t, env):
  match env:
    case Nil{}:
      t
    case Con{+m, ms}:
      f_choose(KTerm, U32.is_eq(ix(t), ix(m)), u => kt("Var", nm(t), ix(kid(m, 0)), qt(t), Nil{}), u => f_rename_var(t, ms))

@unsafe
def f_fresh_terms(ts, env, next):
  match ts:
    case Nil{}:
      FFreshTerms{Nil{}, next}
    case Con{t, rest}:
      f_fresh_cons(f_fresh_term(t, env, next), rest, env)

@unsafe
def f_fresh_cons(r, rest, env):
  match r:
    case FFresh{t, next}:
      f_fresh_prepend(t, f_fresh_terms(rest, env, next))

@unsafe
def f_fresh_prepend(t, r):
  match r:
    case FFreshTerms{ts, next}:
      FFreshTerms{Con{t, ts}, next}

@unsafe
def f_fresh_generic(t, r):
  match r:
    case FFreshTerms{ts, next}:
      FFresh{KTerm{tg(t), nm(t), ix(t), qt(t), ts, rm(t)}, next}

@unsafe
def f_fresh_all(t, env, id, r):
  match r:
    case FFresh{a, next}:
      f_fresh_all_body(t, id, a, f_fresh_term(kid(t, 1), Con{kt("Map", "", ix(t), 0, [var(nm(t), id)]), env}, next))

@unsafe
def f_fresh_all_body(t, id, a, r):
  match r:
    case FFresh{b, next}:
      FFresh{kt("All", nm(t), id, qt(t), [a, b]), next}

@unsafe
def f_fresh_lam(t, id, r):
  match r:
    case FFresh{b, next}:
      FFresh{kt("Lam", nm(t), id, qt(t), [b]), next}

@unsafe
def f_fresh_let(t, env, bodyenv, next, items, acc):
  match items:
    case Nil{}:
      FFresh{kt("Error", "empty core let", 0, 0, Nil{}), next}
    case Con{+x, +xs}:
      f_choose(FFresh, U32.is_eq(f_len(xs), 0), u => f_fresh_let_body(acc, f_fresh_term(x, bodyenv, next)), u => f_fresh_let_value(t, env, bodyenv, next, x, xs, acc, f_fresh_term(kid(x, 0), env, U32.add(next, 1))))

@unsafe
def f_fresh_let_body(acc, r):
  match r:
    case FFresh{body, next}:
      FFresh{kt("Let", "", 0, 1, f_concat(List.reverse(&2, KTerm, acc), [body])), next}

@unsafe
def f_fresh_let_value(t, env, bodyenv, id, binding, rest, acc, r):
  match r:
    case FFresh{value, next}:
      f_fresh_let(t, env, Con{kt("Map", "", ix(binding), 0, [var(nm(binding), id)]), bodyenv}, next, rest, Con{kt("Bind", nm(binding), id, qt(binding), [value]), acc})

@unsafe
def f_fresh_defs(ds, next):
  f_fresh_book_stack(ds, next)

@unsafe
def f_fresh_def_type(d, rest, r):
  match r:
    case FFresh{ty, next}:
      f_fresh_def_value(d, rest, ty, f_fresh_term(dv(d), Nil{}, next))

@unsafe
def f_fresh_def_value(d, rest, ty, r):
  match r:
    case FFresh{value, next}:
      f_fresh_def_ctors(d, rest, ty, value, f_fresh_defs(dc(d), next))

@unsafe
def f_fresh_def_ctors(d, rest, ty, value, r):
  match r:
    case FFreshDefs{ctors, next}:
      f_fresh_defs_prepend(KDef{dn(d), dk(d), da(d), dx(d), ty, value, ctors, db(d), du(d)}, f_fresh_defs(rest, next))

@unsafe
def f_fresh_defs_prepend(d, r):
  match r:
    case FFreshDefs{ds, next}:
      FFreshDefs{Con{d, ds}, next}

@unsafe
def f_fresh_result(r):
  match r:
    case FResult{book, err, imports}:
      f_fresh_result_end(f_fresh_defs(book, 1), err, imports)

@unsafe
def f_fresh_result_end(r, err, imports):
  match r:
    case FFreshDefs{book, next}:
      FResult{book, err, imports}

