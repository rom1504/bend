# Source-only proposal. No production integration or target validation.
# Inputs are accepted plans; the caller separately enforces fresh private
# names, typed residual validation and explicit checked-mode permission.

@unsafe
def no_worker_name(owner: String) -> String:
  "$observer." ++ owner

@unsafe
def no_adapter_name(owner: String) -> String:
  "$observer.adapter." ++ owner

@unsafe
def no_root_index(roots: List<&2, U32>, +i: U32) -> Bool:
  match roots:
    case Nil{}: False{}
    case Con{root, rest}: U32.is_eq(root, i) || no_root_index(rest, i)

@unsafe
def no_owned_roots(params: List<&2, NC_Binding>, +roots: List<&2, U32>, +i: U32) -> List<&2, NC_Binding>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{id, word}, rest}:
      +more = no_owned_roots(rest, roots, U32.inc(i))
      nt_choose(List<&2, NC_Binding>, no_root_index(roots, i), u => Con{NC_Binding{id, "no_root_" ++ U32.show(i)}, more}, u => more)

@unsafe
def no_root_decls(params: List<&2, NC_Binding>, +roots: List<&2, U32>, +i: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{NC_Binding{id, word}, rest}:
      nt_choose(String, no_root_index(roots, i), u => "Term no_root_" ++ U32.show(i) ++ " = " ++ word ++ ";\n", u => "") ++ no_root_decls(rest, roots, U32.inc(i))

@unsafe
def no_wrapper_once(+wrapper: KTerm, env: List<&2, NC_Binding>) -> Bool:
  match env:
    case Nil{}: True{}
    case Con{NC_Binding{id, word}, rest}: U32.is_eq(nq_uses(wrapper, id), 1) && no_wrapper_once(wrapper, rest)

law no_wrapper_children:
  for +book: List<&2, KDef>
  for ts: List<&2, KTerm>
  for +env: List<&2, NC_Binding>
  for +fuel: U32
  U32

@unsafe
def no_wrapper_nodes(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +fuel: U32) -> U32:
  nt_choose(U32, String.eq(tg(t), "Var") && Bool.not(String.eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE")), u => 0, u =>
    nt_choose(U32, String.eq(tg(t), "Ctr") && U32.is_gt(fuel, 0) && Bool.not(nb_contains(["Succ", "Chr", "U32", "F32", "ALeaf", "ANode", "Zero", "True", "False"], nm(t))) && U32.is_eq(terms_len(ks(t)), nc_field_count(book, nm(t))),
      u => U32.min(3, U32.inc(no_wrapper_children(book, ks(t), env, U32.sub(fuel, 1)))), u => 3))

@unsafe
def no_wrapper_children(book, ts, env, fuel):
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(3, U32.add(no_wrapper_nodes(book, h, env, fuel), no_wrapper_children(book, rest, env, fuel)))

@unsafe
def no_guard_code(code: NC_Code) -> NC_Code:
  match code:
    case NC_Code{body, segs, fresh, error, deps}: NC_Code{"#if NATIVE_READONLY_OBSERVERS\n" ++ body ++ "#else\nreturn 0;\n#endif\n", segs, fresh, error, deps}

@unsafe
def no_worker(+owner: String, +params: List<&2, NC_Binding>, layouts: List<&2, NO_Layout>, body: KTerm) -> NF_Worker:
  +code = no_guard_code(no_emit(body, params, params, layouts, 0))
  NF_Worker{no_worker_name(owner), nc_params(params), code, nc_calls(code), atom("Absent")}

@unsafe
def no_adapter_lower(+book: List<&2, KDef>, +owner: String, +params: List<&2, NC_Binding>, +roots: List<&2, U32>, +env: List<&2, NC_Binding>, +wrapper: KTerm, +fresh: U32) -> NC_Code:
  +name = no_adapter_name(owner)
  +observed = no_worker_name(owner)
  +code = nc_lower_to(book, wrapper, env, fresh, NC_Destination{["nf_out[0]"], atom("Absent"), "", name, params, False{}, Nil{}})
  +prefix = no_root_decls(params, roots, 0) ++ "if (!seq && err_seen(e.mem)) { return 0; }\nTerm no_observed[1];\nif (!" ++ nf_name(observed) ++ "(e, seq, no_observed" ++ nf_arg_c(nc_words(params)) ++ ")) { return 0; }\nif (!seq && err_seen(e.mem)) { return 0; }\nTerm no_scalar_result = no_observed[0];\n"
  nt_choose(NC_Code, List.is_empty(&2, N_Segment, nc_segs(code)) && U32.is_le(nc_fresh(code), U32.add(fresh, 64)),
    u => NC_Code{prefix ++ nc_body(code), Nil{}, nc_fresh(code), nc_error(code), Con{observed, nc_calls(code)}},
    u => nc_fail("observer adapter: wrapper needs continuation or exceeds fresh span", fresh))

@unsafe
def no_adapter(+book: List<&2, KDef>, +owner: String, +params: List<&2, NC_Binding>, +roots: List<&2, U32>, +resultId: U32, +wrapper: KTerm, +fresh: U32) -> NF_Worker:
  +owned = no_owned_roots(params, roots, 0)
  +env : List<&2, NC_Binding> = Con{NC_Binding{resultId, "no_scalar_result"}, owned}
  +valid = U32.is_gt(nt_count(U32, roots), 0) && U32.is_le(nt_count(U32, roots), 2) && U32.is_eq(nt_count(U32, roots), nt_count(NC_Binding, owned)) && String.eq(nc_word(resultId, params), "NATIVE_UNBOUND_VARIABLE") && U32.is_le(no_wrapper_nodes(book, wrapper, env, 2), 2) && no_wrapper_once(wrapper, env) && U32.is_le(fresh, 294967231) && nd_comb_fresh(wrapper, Nil{}, List.append(&2, NC_Binding, params, env), fresh, 64)
  +code = no_guard_code(nt_choose(NC_Code, valid, u => no_adapter_lower(book, owner, params, roots, env, wrapper, fresh), u => nc_fail("observer adapter: invalid owned wrapper or fresh span", fresh)))
  NF_Worker{no_adapter_name(owner), nc_params(params), code, nc_calls(code), atom("Absent")}

@unsafe
def no_direct_frame(frame: N_Frame) -> Bool:
  match frame:
    case N_Direct{}: True{}
    case _: False{}

# Apply only after ordinary nf_wrap_segments. The entry's ne_take and WL_OPEN
# already ran before this body; locals, never the shadowed rN bank, are read.
@unsafe
def no_wrap_adapter(+owner: String, +arity: U32, +ready: List<&2, String>, segment: N_Segment) -> N_Segment:
  match segment:
    case N_Segment{+name, +params, result, +frame, +body, refs, host, spin, fork, bang}:
      +entry = nt_choose(String, U32.is_eq(arity, 0), u => owner, u => nd_name(owner))
      +selected = String.eq(name, entry) && U32.is_eq(arity, nt_count(N_Param, params)) && no_direct_frame(frame) && nb_contains(ready, no_adapter_name(owner))
      +call = "#if !DEVICE && NATIVE_READONLY_OBSERVERS\n{\nTerm no_public_result[1];\nif (!" ++ nf_name(no_adapter_name(owner)) ++ "(e, seq, no_public_result" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { return 0; }\nif (!seq && err_seen(e.mem)) { return 0; }\n" ++ ne_ret(["no_public_result[0]"]) ++ "}\n#else\n" ++ body ++ "#endif\n"
      N_Segment{name, params, result, frame, nt_choose(String, selected, u => call, u => body), refs, host, spin, fork, bang}
