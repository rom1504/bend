
# Module: src/back/native/bridge.bend:460
@unsafe
def ntr_destructure_mode(+name: String, +word: String, +count: U32, +n: U32, +reuse: Bool) -> String:
  +boxed = Bool.not(p88_string_eq(name, "Succ") || p88_string_eq(name, "Zero") || p88_string_eq(name, "True") || p88_string_eq(name, "False") || p88_string_eq(name, "Chr") || p88_string_eq(name, "U32") || p88_string_eq(name, "F32") || p88_string_eq(name, "ALeaf") || p88_string_eq(name, "ANode")) && U32.is_gt(count, 0)
  nt_choose(String, boxed,
    u => "Term fields[" ++ U32.show(count) ++ "];\n" ++ nt_choose(String, U32.is_eq(count, 1), u => "if (term_tag(" ++ word ++ ") == TAG_PAK) { fields[0] = term_loc(" ++ word ++ "); } else {\n", u => "") ++ nt_choose(String, reuse, u => "p102_trmc_keep_cell(e, nf_out, cls_fit(", u => "spare_free(e, cls_fit(") ++ U32.show(count) ++ "), ctr_take(e, " ++ word ++ ", " ++ U32.show(count) ++ ", fields));\n" ++ nt_choose(String, U32.is_eq(count, 1), u => "}\n", u => ""),
    u => "") ++ nc_field_decls(name, word, count, 0, n, boxed) ++ nt_choose(String, p88_string_eq(name, "ALeaf"), u => "blk_free(e, " ++ word ++ ");\n", u => "")

# Module: src/back/native/bridge.bend:621
@unsafe
def ntr_plain_lower_live_to(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +tag = tg(t)
  nt_choose(NC_Code, p88_string_eq(tag, "NQBundle") && Bool.not(nf_scheduler(target)), u => nq_bundle_return(t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NQBox") && Bool.not(nf_scheduler(target)), u => nf_emitted(nc_constructor_value(nm(t), nc_values(ks(t), env), n), target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NWord") || p88_string_eq(tag, "NStatic"), u => nt_choose(NC_Code, p88_string_eq(tag, "NStatic"), v => ns_return(book, t, n, target), v => nf_return(nm(t) ++ "ull", n, target)), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Var"), u => nt_choose(NC_Code, p88_string_eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE"), u => nc_fail("native unbound variable " ++ U32.show(ix(t)), n), u => nf_return(nc_word(ix(t), env), n, target)), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Ref"), u => nf_ref(book, t, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Ann") || p88_string_eq(tag, "Loc") || p88_string_eq(tag, "Src") || p88_string_eq(tag, "Cut") || p88_string_eq(tag, "Slf") || p88_string_eq(tag, "Ins"), u => nc_lower_to(book, kid(t, 0), env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Lam"), u => nf_lambda(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "App"), u => nd_app_to(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Let"), u => nt_choose(NC_Code, U32.is_gt(terms_len(ks(t)), 2), u => nf_parallel(book, ks(t), env, n, target), u => nf_lets(book, ks(t), env, n, target)), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NSeqLet"), u => nf_lets(book, ks(t), env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NNatAdd"), u => nc_lower_to(book, nc_sequence("NNatSum", nm(t), ks(t), Nil{}, n), env, U32.inc(n), target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NNatSum"), u => nf_return("nat_chk(e, nat_chk(e, " ++ nc_head(nc_values(ks(t), env)) ++ " + 1) + " ++ nm(t) ++ "ull)", n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Ctr"), u => nc_lower_ctor_to(book, t, env, n, nc_literal(t), target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NCtr"), u => nq_operation(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NApply"), u => nt_choose(NC_Code, nf_scheduler(target), v => nc_apply_code(nc_values(ks(t), env), n), v => nc_fail("flat worker: dynamic application", n)), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NFCall"), u => nq_call(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NCall"), u => nt_choose(NC_Code, nf_scheduler(target), v => NC_Code{nct_leaf(ne_jump(nc_values(ks(t), env), nm(t))), Nil{}, n, "", Nil{}}, v => nc_fail("flat worker: scheduler call node", n)), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Rfl") || p88_string_eq(tag, "Typ") || p88_string_eq(tag, "All") || p88_string_eq(tag, "Qua") || p88_string_eq(tag, "ADT") || p88_string_eq(tag, "Eql"), u => nf_return("0", n, target), u =>
  nt_choose(NC_Code, (p88_string_eq(tag, "Mat") || p88_string_eq(tag, "NWPattern")), u => nf_match_value(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NMatch"), u => nq_match(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "NOp"), u => nq_operation(book, t, env, n, target), u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Efq"), u => NC_Code{nct_leaf("err_post(e.mem, ERR_FIDS); return 0;\n"), Nil{}, n, "", Nil{}}, u =>
  nt_choose(NC_Code, p88_string_eq(tag, "Rwt"), u => nc_lower_to(book, kid(t, 2), env, n, target), u =>
  nc_fail("native lowering does not support core node " ++ tag, n))))))))))))))))))))))))

# Module: src/back/native/flat.bend:171
@unsafe
def ntr_plain_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>) -> NF_Worker:
  +params = nk_typed_bindings(nd_entry_params(nd_arity(book, name), 0), nf_worker_kinds(book, name, nd_arity(book, name)))
  +body = nc_compact_definition(book, lookup(book, name), 0)
  +shape = {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
  +code = nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{nq_words("nf_out", nq_width(shape), 0), shape, "", name, params, True{}, signatures})
  NF_Worker{name, nc_params(params), code, nc_calls(code), shape}

# Module: src/back/native/flat.bend:235
@unsafe
def ntr_plain_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, +code, deps, shape}, rest}:
      nt_choose(String, nb_contains(ready, name), u => nf_inline(name, inline) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\n{\n" ++ nc_body(code) ++ "}\nreturn 0;\n}\n", u => "") ++ nf_bodies(rest, ready, inline)

# Module: src/back/native/product.bend:32
@unsafe
def ntr_plain_transfer(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nq_box_return(shape, words, n, target)
    case NC_Destination{+dests, +wanted, +join, owner, params, tail, signatures}:
      nt_choose(NC_Code, nq_same(shape, wanted) && U32.is_eq(nt_count(String, words), nt_count(String, dests)),
        u => NC_Code{nct_leaf(nq_assign(dests, words) ++ nt_choose(String, p88_string_eq(join, ""), v => "return 1;\n", v => "goto " ++ join ++ ";\n")), Nil{}, n, "", Nil{}},
        u => nt_choose(NC_Code, p98_tag_eq(wanted, "NQShape"), v => nc_fail("flat product: opaque or mismatched result", n), v => nq_box_return(shape, words, n, target)))

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
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
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
  ntr_emitted(book, nm(t), ix(t), ntr_drop_words(words, ix(t)), target,
    ntr_cached_constructor(nm(t), nt_append(String, ntr_take_words(words, ix(t)), ["TERM_HOLE"]), n))

@unsafe
def ntr_emitted(+book: List<&2, KDef>, +ctor: String, +fields: U32, +args: List<&2, String>, +target: NC_Target, emitted: N_Emitted) -> NC_Code:
  match emitted:
    case N_Emitted{code, word, next}:
      +node = "ntr_node_" ++ U32.show(next)
      nc_prepend(code ++ "Term " ++ node ++ " = " ++ word ++ ";\nif (nf_out[1] != 0) { e.mem[nf_out[1]] = nf_out[4] ? rfc_seal(e, " ++ node ++ ") : " ++ node ++ "; } else { nf_out[0] = " ++ node ++ "; }\nnf_out[1] = term_loc(" ++ node ++ ") + " ++ U32.show(fields) ++ ";\n" ++ ntr_hole_policy(ctor),
        nf_call_local(book, ntr_owner(target), args, U32.inc(next), target))

# A terminal result completes the one outstanding slot. No partial root escapes.
@unsafe
def ntr_transfer(+shape: KTerm, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, p98_tag_eq(shape, "Absent") && U32.is_eq(nt_count(String, words), 1), u =>
    NC_Code{nct_leaf("if (nf_out[1] != 0) { e.mem[nf_out[1]] = nf_out[4] ? rfc_seal(e, " ++ nc_head(words) ++ ") : " ++ nc_head(words) ++ "; } else { nf_out[0] = " ++ nc_head(words) ++ "; }\nreturn 1;\n"), Nil{}, n, "", Nil{}}, u =>
    nt_choose(NC_Code, p98_tag_eq(shape, "NQShape"), v => nq_box_return(shape, words, n, target), v => nc_fail("TRMC: unexpected result shape", n)))

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
    ntr_candidate_code(name, params, old, nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{["nf_out[0]"], {KTerm{"NTRMC", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, "", name, params, True{}, signatures})), u => old)

@unsafe
def ntr_candidate_code(+name: String, +params: List<&2, NC_Binding>, +old: NF_Worker, +code: NC_Code) -> NF_Worker:
  nt_choose(NF_Worker, p88_string_eq(nc_error(code), "") && List.is_empty(&2, N_Segment, nc_segs(code)),
    u => NF_Worker{name, nc_params(params), code, nc_calls(code), {KTerm{"NTRMC", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}}, u => old)

@unsafe
def ntr_worker_body(+name: String, +params: List<&2, N_Param>, +code: NC_Code, +inline: List<&2, String>) -> String:
  +inner = nf_name(name) ++ "_trmc"
  nf_inline(name, inline) ++ " Term " ++ inner ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\n{\n" ++ nc_body(code) ++ "}\nreturn 0;\n}\n"
    ++ nf_inline(name, inline) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nTerm ntr_state[5] = { TERM_HOLE, 0, 0, 0, 0 };\nTerm ntr_ok = " ++ inner ++ "(e, seq, ntr_state" ++ nf_arg_c(nf_segment_args(params)) ++ ");\nif (ntr_state[2]) spare_free(e, (Cls)ntr_state[3], (Loc)ntr_state[2]);\nif (!ntr_ok) { term_sink(e, ntr_state[0]); return 0; }\nnf_out[0] = ntr_state[0];\nreturn 1;\n}\n"

# NTRCons admission already proves an ordinary boxed constructor with 2..8
# fields. Preserve ne_ctor_node's normal field stores, packing and seal policy;
# only this final reconstruction allocation may use the private same-class cell.
@unsafe
def ntr_cached_constructor(+name: String, +words: List<&2, String>, +n: U32) -> N_Emitted:
  ne_wrap_ctor(name, ne_ctor_node(name, "p102_trmc_take_cell(e, nf_out, cls_fit(" ++ U32.show(nt_count(String, words)) ++ "))", words, n, True{}))

@unsafe
def ntr_cache_needed(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> Bool:
  match workers:
    case Nil{}: False{}
    case Con{NF_Worker{+name, params, code, deps, +shape}, +rest}:
      nt_choose(Bool, p98_tag_eq(shape, "NTRMC") && nb_contains(ready, name), u => True{}, u => ntr_cache_needed(rest, ready))

@unsafe
def ntr_cache_prelude(+workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  nt_choose(String, ntr_cache_needed(workers, ready), u => ntr_cache_helpers(), u => "")

@unsafe
def ntr_cache_helpers() -> String:
  "/* Experimental private cache of one uniquely transferred constructor cell.\n * ctr_take's returned cell has no remaining owner. Its fields have already\n * moved to ordinary local Terms. Shared inputs return zero; static inputs\n * may return a read-only location below HEAP_OFF and must never be cached.\n * The public wrapper frees any unused cell before publishing its result.\n */\nINLINE void p102_trmc_keep_cell(Env e, Term* state, Cls cls, Loc cell) {\n  if (cell < HEAP_OFF) return;\n  if (state[2]) spare_free(e, (Cls)state[3], (Loc)state[2]);\n  state[2] = cell;\n  state[3] = cls;\n}\n\nINLINE Loc p102_trmc_take_cell(Env e, Term* state, Cls cls) {\n  if (state[2] && state[3] == cls) {\n    Loc cell = (Loc)state[2];\n    state[2] = 0;\n    return cell;\n  }\n  return heap_alloc(e, cls);\n}\n"

# The pending slot belongs to the preceding constructor, not the next value.
# Match ne_ctor_node's policy for hot=True, including user-constructor fallback.
@unsafe
def ntr_hole_policy(+ctor: String) -> String:
  +fallback = nt_choose(String, String.starts_with(ctor, "$ctor."),
    u => "#if NATIVE_COLD_USER_CTORS\nnf_out[4] = 0;\n#else\nnf_out[4] = 1;\n#endif\n",
    u => "nf_out[4] = 1;\n")
  "#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_" ++ nt_cid(ctor) ++ "\nnf_out[4] = 0;\n#else\n" ++ fallback ++ "#endif\n"
