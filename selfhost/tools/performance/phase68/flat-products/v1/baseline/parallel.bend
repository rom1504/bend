# Forks transfer one owned environment to each child and one to the joiner.
# Continuations have the same register/frame ABI on CPU, Metal and CUDA.
law nc_parallel:
  for +book: List<&2, KDef>
  for +xs: List<&2, KTerm>
  for +env: List<&2, NC_Binding>
  for +n: U32
  NC_Code

@unsafe
def nc_last_term(xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{h, Nil{}}: h
    case Con{h, rest}: nc_last_term(rest)

@unsafe
def nc_parallel_binds(xs: List<&2, KTerm>) -> List<&2, NC_Binding>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, Nil{}}: Nil{}
    case Con{h, rest}: Con{nc_binding(ix(h)), nc_parallel_binds(rest)}

@unsafe
def nc_parallel_uses(xs: List<&2, KTerm>, +id: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, rest}: U32.add(nt_bool(nc_occurs(h, id)), nc_parallel_uses(rest, id))

@unsafe
def nc_keeps(+word: String, +n: U32) -> String:
  nt_choose(String, U32.is_le(n, 1), u => "", u => word ++ " = term_keep(e, " ++ word ++ ");\n" ++ nc_keeps(word, U32.sub(n, 1)))

@unsafe
def nc_parallel_share(env: List<&2, NC_Binding>, +xs: List<&2, KTerm>) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{id, word}, rest}: nc_keeps(word, nc_parallel_uses(xs, id)) ++ nc_parallel_share(rest, xs)

@unsafe
def nc_child_task(+fid: String, +join: String, +idx: U32, +em: N_Emitted) -> String:
  match em:
    case N_Emitted{code, word, fresh}: code ++ "e.mem[" ++ join ++ " + " ++ U32.show(idx) ++ "] = term_tsk(" ++ nt_fid(fid) ++ ", " ++ word ++ ");\n"

@unsafe
def nc_local_calls(+book: List<&2, KDef>, refs: List<&2, String>) -> List<&2, String>:
  match refs:
    case Nil{}: ["$local"]
    case Con{h, rest}: Con{nc_ref_name(book, h), nc_local_calls(book, rest)}

@unsafe
def nc_local_segments(ss: List<&2, N_Segment>, +calls: List<&2, String>, +forked: Bool, acc: List<&2, N_Segment>) -> List<&2, N_Segment>:
  match ss:
    case Nil{}: nt_reverse(N_Segment, acc, Nil{})
    case Con{N_Segment{k, ps, r, f, b, +refs, host, spin, fork, bang}, rest}:
      nc_local_segments(rest, calls, forked, Con{N_Segment{k, ps, r, f, b, nt_choose(List<&2, String>, nb_contains(refs, "$local"), u => refs, u => calls), host, spin, nt_choose(Bool, nb_contains(refs, "$local"), u => fork, u => forked), bang}, acc})

@unsafe
def nc_children(+book: List<&2, KDef>, xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +joinname: String, +joinword: String, +idx: U32, +n: U32) -> NC_Code:
  match xs:
    case Nil{}: NC_Code{"", Nil{}, n, ""}
    case Con{h, Nil{}}: NC_Code{"", Nil{}, n, ""}
    case Con{+h, rest}:
      +name = nc_name(n)
      +caps = nc_live_env(env, kid(h, 0))
      +code = nc_lower(book, kid(h, 0), caps, U32.inc(n))
      +calls = nc_local_calls(book, nc_refs(kid(h, 0)))
      +forked = nc_term_fork(kid(h, 0))
      +task = ne_task(name, 0, nc_words(caps), "term_tsk(" ++ nt_fid(joinname) ++ ", " ++ joinword ++ ")", U32.show(idx), nc_fresh(code))
      +next = nc_children(book, rest, env, joinname, joinword, U32.inc(idx), U32.inc(nc_fresh(code)))
      NC_Code{nc_child_task(name, joinword, idx, task) ++ nc_body(next), Con{N_Segment{name, nc_params(caps), 1, N_Direct{}, nc_body(code), calls, False{}, False{}, forked, False{}}, nt_append(N_Segment, nc_local_segments(nc_segs(code), calls, forked, Nil{}), nc_segs(next))}, nc_fresh(next), nc_first_error(code, next)}

@unsafe
def nc_parallel_finish(+env: List<&2, NC_Binding>, +xs: List<&2, KTerm>, +name: String, +join: NC_Code, +seq: NC_Code, +children: NC_Code, em: N_Emitted, +params: List<&2, NC_Binding>) -> NC_Code:
  match em:
    case N_Emitted{code, +word, n}:
      NC_Code{"if (!seq) {\n" ++ nc_parallel_share(env, xs) ++ code ++ nc_body(children) ++ "return term_tsk(" ++ nt_fid(name) ++ ", " ++ word ++ ");\n}\n" ++ nc_body(seq), Con{N_Segment{name, nc_params(params), 1, N_Direct{}, nc_body(join), Nil{}, False{}, False{}, True{}, False{}}, nt_append(N_Segment, nc_segs(join), nt_append(N_Segment, nc_segs(seq), nc_segs(children)))}, nc_fresh(children), nt_choose(String, String.eq(nc_first_error(seq, join), ""), u => nc_error(children), u => nc_first_error(seq, join))}

@unsafe
def nc_parallel_task(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +name: String, +join: NC_Code, +seq: NC_Code, +task: N_Emitted, +params: List<&2, NC_Binding>, +idx: U32) -> NC_Code:
  match task:
    case N_Emitted{code, +word, +n}: nc_parallel_finish(env, xs, name, join, seq, nc_children(book, xs, env, name, word, idx, n), task, params)

@unsafe
def nc_parallel(book, xs, env, n):
  +seq = nc_lets(book, xs, env, n)
  +name = nc_name(nc_fresh(seq))
  +body = nc_last_term(xs)
  +held = nc_live_env(env, body)
  +params = List.append(&2, NC_Binding, held, nc_parallel_binds(xs))
  +join = nc_lower(book, body, params, U32.inc(nc_fresh(seq)))
  +task = ne_task(name, U32.sub(terms_len(xs), 1), nc_words(held), "WL_CONT", "WL_IDX", nc_fresh(join))
  nc_parallel_task(book, xs, env, name, join, seq, task, params, nt_count(NC_Binding, held))

