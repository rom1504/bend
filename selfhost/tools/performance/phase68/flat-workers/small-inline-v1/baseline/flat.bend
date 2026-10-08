# Ordinary host C workers reuse native value ownership and matching. A local
# destination replaces a continuation frame; an outer destination returns one
# boxed word. Unsupported candidate bodies never enter the admitted closure.
type NC_Target is Data:
  NC_Scheduler{}
  NC_Destination{+word: String, +join: String, +owner: String, +params: List<&2, NC_Binding>, +tail: Bool}

type NF_Worker is Data:
  NF_Worker{+name: String, +params: List<&2, NC_Binding>, +code: NC_Code, +deps: List<&2, String>}

@unsafe
def nf_scheduler(+target: NC_Target) -> Bool:
  match target:
    case NC_Scheduler{}: True{}
    case _: False{}

@unsafe
def nf_return(+word: String, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nc_return(word, n)
    case NC_Destination{+dest, +join, owner, params, tail}:
      NC_Code{dest ++ " = " ++ word ++ ";\n" ++ nt_choose(String, String.eq(join, ""), u => "return 1;\n", u => "goto " ++ join ++ ";\n"), Nil{}, n, ""}

@unsafe
def nf_emitted(emitted: N_Emitted, +target: NC_Target) -> NC_Code:
  match emitted:
    case N_Emitted{code, word, n}: nc_prepend(code, nf_return(word, n, target))

@unsafe
def nf_local(+target: NC_Target, +word: String, +join: String) -> NC_Target:
  match target:
    case NC_Scheduler{}: NC_Scheduler{}
    case NC_Destination{dest, label, owner, params, tail}: NC_Destination{word, join, owner, params, False{}}

@unsafe
def nf_bind(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target) -> NC_Code:
  +join = "nf_join_" ++ U32.show(n)
  +word = "v_" ++ U32.show(id)
  +rest = nc_lower_to(book, body, List.append(&2, NC_Binding, nc_live_env(env, body), [nc_binding(id)]), U32.inc(n), target)
  +val = nc_lower_to(book, value, nc_live_env(env, value), nc_fresh(rest), nf_local(target, word, join))
  NC_Code{nc_share_env(env, value, body) ++ "Term " ++ word ++ ";\n{\n" ++ nc_body(val) ++ "}\n" ++ join ++ ":;\nif (!seq && err_seen(e.mem)) { return 0; }\n" ++ nc_body(rest), nt_append(N_Segment, nc_segs(val), nc_segs(rest)), nc_fresh(val), nc_first_error(val, rest)}

@unsafe
def nf_lets(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_lets(book, xs, env, n), u => nf_lets_local(book, xs, env, n, target))

@unsafe
def nf_lets_local(+book: List<&2, KDef>, xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  match xs:
    case Nil{}: nc_fail("empty native let", n)
    case Con{h, Nil{}}: nc_lower_to(book, h, env, n, target)
    case Con{+h, +rest}: nf_bind(book, kid(h, 0), kt("NSeqLet", "", 0, 0, rest), env, ix(h), n, target)

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
    case NC_Destination{dest, join, +owner, +params, +tail}:
      nt_choose(NC_Code, String.eq(name, owner),
        u => nt_choose(NC_Code, tail && U32.is_eq(nt_count(NC_Binding, params), nt_count(String, words)),
          u => NC_Code{"{\n" ++ nf_self_temps(words, 0) ++ nf_self_moves(params, words, 0) ++ "goto nf_again;\n}\n", Nil{}, n, ""},
          u => nc_fail("flat worker: non-tail self call", n)),
        u => nc_prepend("Term nf_result_" ++ U32.show(n) ++ ";\nif (!" ++ nf_name(name) ++ "(e, seq, &nf_result_" ++ U32.show(n) ++ nf_arg_c(words) ++ ")) { return 0; }\n", nf_return("nf_result_" ++ U32.show(n), U32.inc(n), target)))

@unsafe
def nf_call(+book: List<&2, KDef>, +name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +d = lookup(book, name)
  nt_choose(NC_Code, nc_native_def(d), u => nf_emitted(nc_intrinsic_value(nc_primitive_name(name), words, n), target), u =>
    nt_choose(NC_Code, String.eq(dk(d), "Def") && Bool.not(nc_foreign(d)), u => nf_call_local(book, name, words, n, target), u => nc_fail("flat worker: foreign or absent call", n)))

@unsafe
def nf_ref(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => NC_Code{ne_jump(Nil{}, nc_ref_name(book, nm(t))), Nil{}, n, ""}, u =>
    nt_choose(NC_Code, U32.is_eq(nd_arity(book, nm(t)), 0) && Bool.not(U32.is_eq(qt(t), 3)), u => nf_call(book, nm(t), Nil{}, n, target), u => nc_fail("flat worker: unsaturated or bang reference", n)))

@unsafe
def nf_candidate(+book: List<&2, KDef>, +name: String) -> NF_Worker:
  +params = nd_entry_params(nd_arity(book, name), 0)
  +body = nc_compact(nc_definition(book, lookup(book, name), 0))
  +code = nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{"*nf_out", "", name, params, True{}})
  NF_Worker{name, params, code, nc_refs(body)}

@unsafe
def nf_candidates(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>) -> List<&2, NF_Worker>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, NF_Worker>, String.eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs, name)),
        u => Con{nf_candidate(book, name), nf_candidates(book, rest, bangs)}, u => nf_candidates(book, rest, bangs))

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
    case Con{NF_Worker{+name, params, +code, +deps}, rest}:
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

@unsafe
def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, code, deps}, +rest}:
      nt_choose(String, nb_contains(ready, name), u => "INLINE Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ");\n", u => "") ++ nf_prototypes(rest, ready)

@unsafe
def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, +code, deps}, rest}:
      nt_choose(String, nb_contains(ready, name), u => "INLINE Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\n{\n" ++ nc_body(code) ++ "}\nreturn 0;\n}\n", u => "") ++ nf_bodies(rest, ready)

@unsafe
def nf_adapter_defs(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, KDef>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, code, deps}, +rest}:
      nt_choose(List<&2, KDef>, nb_contains(ready, name), u => Con{KDef{nt_choose(String, List.is_empty(&2, NC_Binding, params), v => name, v => nd_name(name)), "NFWorker", nt_count(NC_Binding, params), 0, atom("Absent"), kt("NFName", name, 0, 0, Nil{}), Nil{}, False{}, False{}}, nf_adapter_defs(rest, ready)}, u => nf_adapter_defs(rest, ready))

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
        u => "#if !DEVICE\n{\nTerm nf_result;\nif (!" ++ nf_name(nm(dv(d))) ++ "(e, seq, &nf_result" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { return 0; }\n" ++ ne_ret(["nf_result"]) ++ "}\n#else\n" ++ body ++ "#endif\n", u => body)
      Con{N_Segment{name, params, result, frame, wrapped, refs, host, spin, fork, bang}, nf_wrap_segments(rest, index)}

@unsafe
def nf_finish_ready(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> NC_Result:
  nc_with_show(nf_wrap_segments(ss, book_cached(nf_adapter_defs(workers, ready), 0)), cs, runtime, requests, pure, show, "#if !DEVICE\n" ++ nf_prototypes(workers, ready) ++ nf_bodies(workers, ready) ++ "#endif\n")

@unsafe
def nf_finish_workers(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>) -> NC_Result:
  nf_finish_ready(ss, cs, runtime, requests, pure, show, workers, nf_admit(book, workers, Nil{}, nt_count(NF_Worker, workers)))

@unsafe
def nf_finish_show(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show) -> NC_Result:
  nf_finish_workers(book, ss, cs, runtime, requests, pure, show, nf_candidates(book, nc_live_names(book, ["main"], Nil{}), nc_bangs_book(book)))
