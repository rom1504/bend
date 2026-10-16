# Private host-only tail recursion modulo a final boxed constructor field.
# The ordinary scheduler/device path and public one-Term result ABI remain.
@unsafe
def ntr_target(+target: NC_Target) -> Bool:
  match target:
    case NC_Scheduler{}: False{}
    case NC_Destination{words, +shape, join, owner, params, +tail, signatures}: tail && p98_tag_eq(shape, "NTRMC")

@unsafe
def ntr_owner(+target: NC_Target) -> String:
  match target:
    case NC_Scheduler{}: ""
    case NC_Destination{words, shape, join, +owner, params, tail, signatures}: owner

@unsafe
def ntr_params(+target: NC_Target) -> U32:
  match target:
    case NC_Scheduler{}: 0
    case NC_Destination{words, shape, join, owner, +params, tail, signatures}: nt_count(NC_Binding, params)

@unsafe
def ntr_last(xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{h, Nil{}}: h
    case Con{h, rest}: ntr_last(rest)

@unsafe
def ntr_prefix(xs: List<&2, KTerm>) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, Nil{}}: Nil{}
    case Con{h, rest}: Con{h, ntr_prefix(rest)}

@unsafe
def ntr_refs(xs: List<&2, KTerm>, +owner: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, rest}: nb_contains(nc_refs(h), owner) || ntr_refs(rest, owner)

@unsafe
def ntr_eligible(+t: KTerm, +target: NC_Target, +n: U32) -> Bool:
  +count = terms_len(ks(t))
  nt_choose(Bool, ntr_target(target) && U32.is_ge(count, 2) && U32.is_le(count, 8) && U32.is_lt(n, 4294967200), u =>
    nt_choose(Bool, p88_string_eq(nm(t), "Con") || p88_string_eq(nm(t), "SCon") || String.starts_with(nm(t), "$ctor."), v =>
      ntr_tail_eligible(ntr_last(ks(t)), ntr_prefix(ks(t)), target), v => False{}), u => False{})

@unsafe
def ntr_tail_eligible(+call: KTerm, +prefix: List<&2, KTerm>, +target: NC_Target) -> Bool:
  +head = nd_head(call)
  +args = nd_args(call, Nil{})
  +owner = ntr_owner(target)
  p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && p88_string_eq(nm(head), owner) &&
    U32.is_eq(terms_len(args), ntr_params(target)) &&
    Bool.not(ntr_refs(prefix, owner) || ntr_refs(args, owner))

# Ordinary nested lets retain exact left-to-right evaluation and sharing.
@unsafe
def ntr_sequence(+name: String, +fields: U32, xs: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match xs:
    case Nil{}: kt("NTRCons", name, fields, 0, nt_reverse(KTerm, acc, Nil{}))
    case Con{h, rest}: nc_mklet(nc_id(n), h, ntr_sequence(name, fields, rest, Con{var("", nc_id(n)), acc}, U32.inc(n)))

@unsafe
def ntr_ctor(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, ntr_eligible(t, target, n), u =>
    ntr_ctor_selected(book, t, env, n, target, ntr_prefix(ks(t)), nd_args(ntr_last(ks(t)), Nil{})), u =>
    nc_lower_to(book, nc_sequence("NCtr", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t))), target))

@unsafe
def ntr_ctor_selected(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +prefix: List<&2, KTerm>, +args: List<&2, KTerm>) -> NC_Code:
  +all = nt_append(KTerm, prefix, args)
  nc_lower_to(book, ntr_sequence(nm(t), terms_len(prefix), all, Nil{}, n), env, U32.add(n, terms_len(all)), target)

@unsafe
def ntr_take_words(xs: List<&2, String>, +left: U32) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, +rest}:
      nt_choose(List<&2, String>, U32.is_eq(left, 0), u => Nil{}, u => Con{h, ntr_take_words(rest, U32.sub(left, 1))})

@unsafe
def ntr_drop_words(xs: List<&2, String>, +left: U32) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, +rest}:
      nt_choose(List<&2, String>, U32.is_eq(left, 0), u => Con{h, rest}, u => ntr_drop_words(rest, U32.sub(left, 1)))

@unsafe
def ntr_emit(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, ntr_target(target) && nd_match_vars(ks(t)), u =>
    ntr_emit_ready(book, t, n, target, nc_values(ks(t), env)), u => nc_fail("TRMC: malformed private construction", n))

@unsafe
def ntr_emit_ready(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target, +words: List<&2, String>) -> NC_Code:
  ntr_emitted(book, ix(t), ntr_drop_words(words, ix(t)), target,
    nc_constructor_value(nm(t), nt_append(String, ntr_take_words(words, ix(t)), ["TERM_HOLE"]), n))

@unsafe
def ntr_emitted(+book: List<&2, KDef>, +fields: U32, +args: List<&2, String>, +target: NC_Target, emitted: N_Emitted) -> NC_Code:
  match emitted:
    case N_Emitted{code, word, next}:
      +node = "ntr_node_" ++ U32.show(next)
      nc_prepend(code ++ "Term " ++ node ++ " = " ++ word ++ ";\nif (nf_out[1] != 0) { e.mem[nf_out[1]] = rfc_seal(e, " ++ node ++ "); } else { nf_out[0] = " ++ node ++ "; }\nnf_out[1] = term_loc(" ++ node ++ ") + " ++ U32.show(fields) ++ ";\n",
        nf_call_local(book, ntr_owner(target), args, U32.inc(next), target))

# A terminal result completes the one outstanding slot. No partial root escapes.
@unsafe
def ntr_transfer(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, p98_tag_eq(shape, "Absent") && U32.is_eq(nt_count(String, words), 1), u =>
    NC_Code{nct_leaf("if (nf_out[1] != 0) { e.mem[nf_out[1]] = rfc_seal(e, " ++ nc_head(words) ++ "); } else { nf_out[0] = " ++ nc_head(words) ++ "; }\nreturn 1;\n"), Nil{}, n, "", Nil{}}, u =>
    nt_choose(NC_Code, p98_tag_eq(shape, "NQShape"), v => nq_box_return(shape, words, n, target), v => nc_fail("TRMC: unexpected result shape", n)))

@unsafe
def nf_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>) -> NF_Worker:
  ntr_retry(book, name, signatures, ntr_plain_candidate(book, name, signatures))

@unsafe
def ntr_retry(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>, +old: NF_Worker) -> NF_Worker:
  match old:
    case NF_Worker{k, ps, +code, ds, shape}:
      nt_choose(NF_Worker, p88_string_eq(nc_error(code), "flat worker: non-tail self call") && U32.is_gt(nd_arity(book, name), 0) && U32.is_le(nd_arity(book, name), 8), u =>
        ntr_candidate(book, name, signatures, old), u => old)

@unsafe
def ntr_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>, +old: NF_Worker) -> NF_Worker:
  +params = nk_typed_bindings(nd_entry_params(nd_arity(book, name), 0), nf_worker_kinds(book, name, nd_arity(book, name)))
  +body = nc_compact_definition(book, lookup(book, name), 0)
  nt_choose(NF_Worker, U32.is_gt(nq_layout_remaining([body], 513), 0), u =>
    ntr_candidate_code(name, params, old, nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{["nf_out[0]"], atom("NTRMC"), "", name, params, True{}, signatures})), u => old)

@unsafe
def ntr_candidate_code(+name: String, +params: List<&2, NC_Binding>, +old: NF_Worker, +code: NC_Code) -> NF_Worker:
  nt_choose(NF_Worker, p88_string_eq(nc_error(code), "") && List.is_empty(&2, N_Segment, nc_segs(code)),
    u => NF_Worker{name, nc_params(params), code, nc_calls(code), atom("NTRMC")}, u => old)

@unsafe
def ntr_worker_body(+name: String, +params: List<&2, N_Param>, +code: NC_Code) -> String:
  +inner = nf_name(name) ++ "_trmc"
  nf_inline(code) ++ " Term " ++ inner ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\n{\n" ++ nc_body(code) ++ "}\nreturn 0;\n}\n"
    ++ nf_inline(code) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nTerm ntr_state[2] = { TERM_HOLE, 0 };\nif (!" ++ inner ++ "(e, seq, ntr_state" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { term_sink(e, ntr_state[0]); return 0; }\nnf_out[0] = ntr_state[0];\nreturn 1;\n}\n"

@unsafe
def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, +code, deps, +shape}, +rest}:
      nt_choose(String, p98_tag_eq(shape, "NTRMC"), u =>
        nt_choose(String, nb_contains(ready, name), v => ntr_worker_body(name, params, code), v => "") ++ nf_bodies(rest, ready), u => ntr_plain_bodies(workers, ready))

@unsafe
def nq_transfer(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, ntr_target(target), u => ntr_transfer(shape, words, n, target), u => ntr_plain_transfer(shape, words, n, target))

@unsafe
def nc_lower_live_to(book, t, env, n, target):
  nt_choose(NC_Code, p98_tag_eq(t, "NTRCons"), u => ntr_emit(book, t, env, n, target), u => ntr_plain_lower_live_to(book, t, env, n, target))
