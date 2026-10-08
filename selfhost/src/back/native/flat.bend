# Ordinary host C workers reuse native value ownership and matching. A local
# destination replaces a continuation frame; an outer destination returns one
# boxed word. Unsupported candidate bodies never enter the admitted closure.
type NC_Target is Data:
  NC_Scheduler{}
  NC_Destination{+words: List<&2, String>, +shape: KTerm, +join: String, +owner: String, +params: List<&2, NC_Binding>, +tail: Bool, +signatures: List<&2, KDef>}

type NF_Worker is Data:
  NF_Worker{+name: String, +params: List<&2, NC_Binding>, +code: NC_Code, +deps: List<&2, String>, +shape: KTerm}

@unsafe
def nf_scheduler(+target: NC_Target) -> Bool:
  match target:
    case NC_Scheduler{}: True{}
    case _: False{}

@unsafe
def nf_return(+word: String, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_return(word, n), u => nq_transfer(atom("Absent"), [word], n, target))

@unsafe
def nf_emitted(emitted: N_Emitted, +target: NC_Target) -> NC_Code:
  match emitted:
    case N_Emitted{code, word, n}: nc_prepend(code, nf_return(word, n, target))

@unsafe
def nf_local(+target: NC_Target, +word: String, +join: String) -> NC_Target:
  nq_local(target, [word], atom("Absent"), join)

@unsafe
def nf_bind_boxed(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target) -> NC_Code:
  +join = "nf_join_" ++ U32.show(n)
  +word = "v_" ++ U32.show(id)
  +bodyUses = nc_uses(body)
  +rest = nc_lower_partition(book, body, U32.inc(n), target, nc_partition_uses(List.append(&2, NC_Binding, nc_live_uses(env, bodyUses), [nc_binding(id)]), bodyUses))
  +valueEnv = nc_live_env(env, value)
  +val = nc_lower_live_to(book, value, valueEnv, nc_fresh(rest), nf_local(target, word, join))
  NC_Code{nc_keep_uses(valueEnv, bodyUses) ++ "Term " ++ word ++ ";\n{\n" ++ nc_body(val) ++ "}\n" ++ join ++ ":;\nif (!seq && err_seen(e.mem)) { return 0; }\n" ++ nc_body(rest), nt_append(N_Segment, nc_segs(val), nc_segs(rest)), nc_fresh(val), nc_first_error(val, rest), List.append(&2, String, nc_calls(val), List.append(&2, String, nc_calls(rest), Nil{}))}

@unsafe
def nf_lets(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_lets(book, xs, env, n), u => nf_lets_local(book, xs, env, n, target))

@unsafe
def nf_lets_local(+book: List<&2, KDef>, xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  match xs:
    case Nil{}: nc_fail("empty native let", n)
    case Con{h, Nil{}}: nc_lower_to(book, h, env, n, target)
    case Con{+h, +rest}: nq_bind_choose(book, kid(h, 0), kt("NSeqLet", "", 0, 0, rest), env, ix(h), n, target)

@unsafe
def nf_parallel(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_parallel(book, xs, env, n), u => nc_fail("flat worker: parallel let", n))

@unsafe
def nf_lambda(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_lambda(book, t, env, n), u => nc_fail("flat worker: escaping closure", n))

@unsafe
def nf_match_value(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_match(book, t, env, n), u => nc_fail("flat worker: escaping matcher", n))

@unsafe
def nf_slow_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_app_slow(book, t, env, n), u => nc_fail("flat worker: partial, dynamic or bang call", n))

@unsafe
def nf_name(+name: String) -> String:
  "NF_" ++ nt_fid(name)

@unsafe
def nf_param_c(params: List<&2, NC_Binding>) -> String:
  match params:
    case Nil{}: ""
    case Con{NC_Binding{id, word}, rest}: ", Term " ++ word ++ nf_param_c(rest)

@unsafe
def nf_arg_c(words: List<&2, String>) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: ", " ++ word ++ nf_arg_c(rest)

@unsafe
def nf_self_moves(params: List<&2, NC_Binding>, words: List<&2, String>, +i: U32) -> String:
  match params, words:
    case Con{NC_Binding{id, word}, rest}, Con{value, more}: word ++ " = nf_arg_" ++ U32.show(i) ++ ";\n" ++ nf_self_moves(rest, more, U32.inc(i))
    case _, _: ""

@unsafe
def nf_self_temps(words: List<&2, String>, +i: U32) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: "Term nf_arg_" ++ U32.show(i) ++ " = " ++ word ++ ";\n" ++ nf_self_temps(rest, U32.inc(i))

@unsafe
def nf_call_local(+book: List<&2, KDef>, +name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nc_fail("flat worker: scheduler destination", n)
    case NC_Destination{dests, shape, join, +owner, +params, +tail, signatures}:
      nt_choose(NC_Code, String.eq(name, owner),
        u => nt_choose(NC_Code, tail && U32.is_eq(nt_count(NC_Binding, params), nt_count(String, words)),
          u => NC_Code{"{\n" ++ nf_self_temps(words, 0) ++ nf_self_moves(params, words, 0) ++ "goto nf_again;\n}\n", Nil{}, n, "", Nil{}},
          u => nc_fail("flat worker: non-tail self call", n)),
        u => nq_call_result(name, words, n, target))

@unsafe
def nf_call(+book: List<&2, KDef>, +name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +d = lookup(book, name)
  nt_choose(NC_Code, nc_native_def(d), u => nq_intrinsic(nc_primitive_name(name), words, n, target), u =>
    nt_choose(NC_Code, String.eq(dk(d), "Def") && Bool.not(nc_foreign(d)), u => nf_call_local(book, name, words, n, target), u => nc_fail("flat worker: foreign or absent call", n)))

@unsafe
def nf_ref(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => NC_Code{ne_jump(Nil{}, nc_ref_name(book, nm(t))), Nil{}, n, "", Nil{}}, u =>
    nt_choose(NC_Code, U32.is_eq(nd_arity(book, nm(t)), 0) && Bool.not(U32.is_eq(qt(t), 3)), u => nq_call(book, kt("NFCall", nm(t), 0, 0, Nil{}), Nil{}, n, target), u => nc_fail("flat worker: unsaturated or bang reference", n)))

@unsafe
def nf_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>) -> NF_Worker:
  +params = nd_entry_params(nd_arity(book, name), 0)
  +body = nc_compact(nc_definition(book, lookup(book, name), 0))
  +shape = atom("Absent")
  +code = nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{nq_words("nf_out", nq_width(shape), 0), shape, "", name, params, True{}, signatures})
  NF_Worker{name, params, code, nc_calls(code), shape}

@unsafe
def nf_candidates(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>, +signatures: List<&2, KDef>) -> List<&2, NF_Worker>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, NF_Worker>, String.eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs, name)),
        u => Con{nf_candidate(book, name, signatures), nf_candidates(book, rest, bangs, signatures)}, u => nf_candidates(book, rest, bangs, signatures))

@unsafe
def nf_deps_ready(+book: List<&2, KDef>, deps: List<&2, String>, +owner: String, +ready: List<&2, String>) -> Bool:
  match deps:
    case Nil{}: True{}
    case Con{+name, rest}:
      +ok = nt_choose(Bool, String.eq(name, owner), u => True{}, u =>
        nt_choose(Bool, nb_contains(ready, name), u => True{}, u => nc_native_def(lookup(book, name))))
      nt_choose(Bool, ok, u => nf_deps_ready(book, rest, owner, ready), u => False{})

@unsafe
def nf_admit_pass(+book: List<&2, KDef>, workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, String>:
  match workers:
    case Nil{}: ready
    case Con{NF_Worker{+name, params, +code, +deps, shape}, rest}:
      nf_admit_pass(book, rest, nt_choose(List<&2, String>, nb_contains(ready, name), u => ready, u =>
        nt_choose(List<&2, String>, String.eq(nc_error(code), "") && List.is_empty(&2, N_Segment, nc_segs(code)),
          u => nt_choose(List<&2, String>, nf_deps_ready(book, deps, name, ready), u => Con{name, ready}, u => ready), u => ready)))

law nf_admit_next:
  for +book: List<&2, KDef>
  for +workers: List<&2, NF_Worker>
  for +old: List<&2, String>
  for +next: List<&2, String>
  for +fuel: U32
  List<&2, String>

@unsafe
def nf_admit(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(fuel, 0), u => ready, u => nf_admit_next(book, workers, ready, nf_admit_pass(book, workers, ready), U32.sub(fuel, 1)))

@unsafe
def nf_admit_next(book, workers, old, next, fuel):
  nt_choose(List<&2, String>, U32.is_eq(nt_count(String, old), nt_count(String, next)), u => next, u => nf_admit(book, workers, next, fuel))

# The explicit inline hint has a local source-size cutoff. Admission already
# excludes C recursion cycles; this is not a transitive code-growth bound.
@unsafe
def nf_inline(+code: NC_Code) -> String:
  nt_choose(String, Nat.is_le(String.length(nc_body(code)), 4096n), u => "NF_INLINE", u => "INLINE")

@unsafe
def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, code, deps, +shape}, +rest}:
      nt_choose(String, nb_contains(ready, name), u => nf_inline(code) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ");\n", u => "") ++ nf_prototypes(rest, ready)

@unsafe
def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, +code, deps, shape}, rest}:
      nt_choose(String, nb_contains(ready, name), u => nf_inline(code) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\n{\n" ++ nc_body(code) ++ "}\nreturn 0;\n}\n", u => "") ++ nf_bodies(rest, ready)

@unsafe
def nf_adapter_defs(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, KDef>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, code, deps, +shape}, +rest}:
      nt_choose(List<&2, KDef>, nb_contains(ready, name), u => Con{KDef{nt_choose(String, List.is_empty(&2, NC_Binding, params), v => name, v => nd_name(name)), "NFWorker", nt_count(NC_Binding, params), 0, shape, kt("NFName", name, 0, 0, Nil{}), Nil{}, False{}, False{}}, nf_adapter_defs(rest, ready)}, u => nf_adapter_defs(rest, ready))

@unsafe
def nf_segment_args(params: List<&2, N_Param>) -> List<&2, String>:
  match params:
    case Nil{}: Nil{}
    case Con{N_Param{name, kind}, rest}: Con{name, nf_segment_args(rest)}

@unsafe
def nf_wrap_segments(segments: List<&2, N_Segment>, +index: List<&2, KDef>) -> List<&2, N_Segment>:
  match segments:
    case Nil{}: Nil{}
    case Con{N_Segment{+name, +params, result, frame, +body, refs, host, spin, fork, bang}, rest}:
      +d = lookup(index, name)
      +wrapped = nt_choose(String, String.eq(dk(d), "NFWorker") && U32.is_eq(da(d), nt_count(N_Param, params)),
        u => nq_wrap_segment(d, params, body), u => body)
      Con{N_Segment{name, params, result, frame, wrapped, refs, host, spin, fork, bang}, nf_wrap_segments(rest, index)}

@unsafe
def nf_finish_ready(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> NC_Result:
  nc_with_show(nf_wrap_segments(ss, book_cached(nf_adapter_defs(workers, ready), 0)), cs, runtime, requests, pure, show, "#if !DEVICE\n#if defined(__GNUC__) || defined(__clang__)\n#define NF_INLINE INLINE __attribute__((always_inline))\n#else\n#define NF_INLINE INLINE\n#endif\n" ++ nf_prototypes(workers, ready) ++ nf_bodies(workers, ready) ++ "#undef NF_INLINE\n#endif\n")

@unsafe
def nf_finish_workers(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>) -> NC_Result:
  nf_finish_ready(ss, cs, runtime, requests, pure, show, workers, nf_admit(book, workers, Nil{}, nt_count(NF_Worker, workers)))

@unsafe
def nf_finish_show(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show) -> NC_Result:
  +names = nc_live_names(book, ["main"], Nil{})
  +signatures = book_cached(nq_signatures(book, names), 0)
  +bangs = nc_bangs_book(book)
  nf_finish_workers(book, ss, cs, runtime, requests, pure, show, List.append(&2, NF_Worker, nf_candidates(book, names, bangs, signatures), nq_candidates(book, names, bangs, signatures)))
