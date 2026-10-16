# A scheduler parent may call an already admitted ordinary worker locally.
# Private plans are attached only for checked, provider-certified books without
# reachable bangs. This call permission does not grant layout/sharing changes.
@unsafe
def nf_scheduler_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{source, Con{statics, Con{+plan, rest}}}:
      nt_choose(KDef, String.eq(dk(plan), "NativeLocalPlan") && String.eq(dn(plan), "$native.local.plan"), u => index_first(dc(plan)), u => nf_host_payload(children))
    case _: missing()

@unsafe
def nf_scheduler_selected(+book: List<&2, KDef>, +name: String, +arity: U32) -> Bool:
  +d = index_find(nf_scheduler_payload(dc(index_first(book))), name, index_hash(name, 2166136261), 32)
  U32.is_gt(arity, 0) && String.eq(dk(d), "NativeHostWorker") && U32.is_eq(da(d), arity)

@unsafe
def nf_scheduler_name(+book: List<&2, KDef>, +value: KTerm) -> String:
  +head = nd_head(value)
  nt_choose(String, String.eq(tg(value), "App") && String.eq(tg(head), "Ref") && Bool.not(U32.is_eq(qt(head), 3)),
    u => nt_choose(String, nf_scheduler_selected(book, nm(head), terms_len(nd_args(value, Nil{}))), v => nm(head), v => ""), u => "")

@unsafe
def nf_scheduler_bind(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> NC_Code:
  +name = nf_scheduler_name(book, value)
  nt_choose(NC_Code, String.eq(name, ""), u => nc_let_cut(book, value, body, env, id, n), u =>
    nc_lower(book, nd_bind_value("NFCall", name, nd_args(value, Nil{}), Nil{}, n, id, body), env, U32.add(n, terms_len(nd_args(value, Nil{})))))

# Arguments have been evaluated in source order. The existing local-producer
# rule handles sharing with the remaining body, result drops and fresh scopes.
@unsafe
def nf_scheduler_emitted(+name: String, +words: List<&2, String>, +n: U32) -> N_Emitted:
  +result = "nf_local_" ++ U32.show(n)
  N_Emitted{"Term " ++ result ++ "[1];\nif (!" ++ nf_name(name) ++ "(e, seq, " ++ result ++ nf_arg_c(words) ++ ")) { return 0; }\n", result ++ "[0]", U32.inc(n)}

# These request-local plans require checked providers and no reachable bangs.
# Their segments cannot be offloaded. Use existing host metadata so local NF
# calls never appear in a device switch where NF declarations are unavailable.
@unsafe
def nf_scheduler_host(children: List<&2, KDef>) -> Bool:
  match children:
    case Con{source, Con{statics, Con{+plan, rest}}}:
      (String.eq(dk(plan), "NativeLocalPlan") && String.eq(dn(plan), "$native.local.plan")) || (String.eq(dk(plan), "NativeHostPlan") && String.eq(dn(plan), "$native.host.plan"))
    case _: False{}

@unsafe
def nf_scheduler_host_rev(ss: List<&2, N_Segment>, acc: List<&2, N_Segment>) -> List<&2, N_Segment>:
  match ss:
    case Nil{}: nt_reverse(N_Segment, acc, Nil{})
    case Con{N_Segment{name, params, result, frame, body, refs, host, spin, fork, bang}, rest}:
      nf_scheduler_host_rev(rest, Con{N_Segment{name, params, result, frame, body, refs, True{}, spin, fork, bang}, acc})

@unsafe
def nf_scheduler_segments(+book: List<&2, KDef>, +ss: List<&2, N_Segment>) -> List<&2, N_Segment>:
  nt_choose(List<&2, N_Segment>, nf_scheduler_host(dc(index_first(book))), u => nf_scheduler_host_rev(ss, Nil{}), u => ss)
