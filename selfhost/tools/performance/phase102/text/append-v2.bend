# Checked canonical String.append lowering. The generated CPU helper preserves
# the original linked String ABI; device lowering retains the ordinary body.
# This isolated candidate is not installed by its presence in this directory.

@unsafe
def nx_append_node(+t: KTerm, +tag: String, +name: String, +arity: U32, +quantity: U32) -> Bool:
  String.eq(tg(t), tag) && String.eq(nm(t), name) && U32.is_eq(qt(t), quantity) &&
    U32.is_eq(terms_len(ks(t)), arity) && List.is_empty(&2, String, rm(t))

@unsafe
def nx_append_lambda(+t: KTerm) -> Bool:
  String.eq(tg(t), "Lam") && U32.is_eq(qt(t), 1) &&
    U32.is_eq(terms_len(ks(t)), 1) && List.is_empty(&2, String, rm(t))

@unsafe
def nx_append_var(+t: KTerm, +binder: KTerm) -> Bool:
  nx_append_node(t, "Var", nm(binder), 0, 1) && U32.is_eq(ix(t), ix(binder))

@unsafe
def nx_append_body(+t: KTerm) -> Bool:
  kc(Bool, nx_append_node(t, "Mat", "SNil", 2, 1), u =>
    nx_append_nil(j_strip(kid(t, 0))) && nx_append_match(j_strip(kid(t, 1))), u => False{})

@unsafe
def nx_append_nil(+t: KTerm) -> Bool:
  kc(Bool, nx_append_lambda(t), u => nx_append_var(j_strip(kid(t, 0)), t), u => False{})

@unsafe
def nx_append_match(+t: KTerm) -> Bool:
  kc(Bool, nx_append_node(t, "Mat", "SCon", 2, 1), u =>
    nx_append_head(j_strip(kid(t, 0))) && nx_append_node(j_strip(kid(t, 1)), "Efq", "", 0, 0), u => False{})

@unsafe
def nx_append_head(+head: KTerm) -> Bool:
  kc(Bool, nx_append_lambda(head), u => nx_append_tail(head, j_strip(kid(head, 0))), u => False{})

@unsafe
def nx_append_tail(+head: KTerm, +tail: KTerm) -> Bool:
  kc(Bool, nx_append_lambda(tail) && Bool.not(U32.is_eq(ix(head), ix(tail))),
    u => nx_append_right(head, tail, j_strip(kid(tail, 0))), u => False{})

@unsafe
def nx_append_right(+head: KTerm, +tail: KTerm, +right: KTerm) -> Bool:
  kc(Bool, nx_append_lambda(right) && Bool.not(U32.is_eq(ix(head), ix(right))) && Bool.not(U32.is_eq(ix(tail), ix(right))),
    u => nx_append_construct(head, tail, right, j_strip(kid(right, 0))), u => False{})

@unsafe
def nx_append_construct(+head: KTerm, +tail: KTerm, +right: KTerm, +body: KTerm) -> Bool:
  kc(Bool, nx_append_node(body, "Ctr", "SCon", 2, 1), u =>
    nx_append_var(j_strip(kid(body, 0)), head) && nx_append_call(tail, right, j_strip(kid(body, 1))), u => False{})

# Parser applications carry quantity 1; checked annotation rebuilds them with
# core app(), quantity 0. Ownership lives on binders/signatures, not App metadata.
@unsafe
def nx_append_application(+t: KTerm) -> Bool:
  nx_append_node(t, "App", "", 2, 0) || nx_append_node(t, "App", "", 2, 1)

@unsafe
def nx_append_call(+tail: KTerm, +right: KTerm, +call: KTerm) -> Bool:
  kc(Bool, nx_append_application(call), u =>
    nx_append_var(j_strip(kid(call, 1)), right) && nx_append_recur(tail, j_strip(kid(call, 0))), u => False{})

@unsafe
def nx_append_recur(+tail: KTerm, +call: KTerm) -> Bool:
  kc(Bool, nx_append_application(call), u =>
    nx_append_node(j_strip(kid(call, 0)), "Ref", "String.append", 0, 1) && nx_append_var(j_strip(kid(call, 1)), tail), u => False{})

@unsafe
def nx_append_allowed(+book: List<&2, KDef>, +checked: Bool) -> Bool:
  kc(Bool, checked, u => nx_append_definition(book, lookup(book, "String.append")), u => False{})

@unsafe
def nx_append_definition(+book: List<&2, KDef>, +d: KDef) -> Bool:
  kc(Bool, Bool.not(du(d)) && j_map_native_string(book, d),
    u => nx_append_body(j_strip(dv(d))), u => False{})

@unsafe
def nx_append_segments(+ss: List<&2, N_Segment>, +allowed: Bool) -> List<&2, N_Segment>:
  kc(List<&2, N_Segment>, allowed, u => nx_append_segments_rev(ss, Nil{}), u => ss)

@unsafe
def nx_append_segments_rev(ss: List<&2, N_Segment>, rev: List<&2, N_Segment>) -> List<&2, N_Segment>:
  match ss:
    case Nil{}: nt_reverse(N_Segment, rev, Nil{})
    case Con{seg, rest}: nx_append_segments_rev(rest, Con{nx_append_segment(seg), rev})

@unsafe
def nx_append_segment(+seg: N_Segment) -> N_Segment:
  match seg:
    case N_Segment{+name, +params, +result, +frame, +body, +refs, +host, +spin, +fork, +bang}:
      +text = kc(String, String.eq(name, "$direct.String.append") && U32.is_eq(result, 1),
        u => nx_append_entry(params, frame, body), u => body)
      N_Segment{name, params, result, frame, text, refs, host, spin, fork, bang}

@unsafe
def nx_append_entry(+params: List<&2, N_Param>, +frame: N_Frame, +body: String) -> String:
  match params, frame:
    case Con{N_Param{left, N_W64{}}, Con{N_Param{right, N_W64{}}, Nil{}}}, N_Direct{}:
      "#if !DEVICE\nr0 = native_string_append(e, " ++ left ++ ", " ++ right ++ ");\nWL_RETN(1);\n#else\n" ++ body ++ "\n#endif\n"
    case _, _: body

# Generated offline from linked-append.c; production reuse branch only.
# No runtime template mutation: emitted after existing runtime primitives.
@unsafe
def nx_append_helper() -> String:
  "#if !DEVICE\n"
  ++ "/* Experimental consuming append on the ORIGINAL linked String ABI.\n"
  ++ " * Each ctr_take transfers head/tail ownership. Its reusable heap cell belongs\n"
  ++ " * exclusively to us; shared/static cells are copied. The result stays private\n"
  ++ " * while its forward links are filled. No task, character or String ABI changes.\n"
  ++ " */\n"
  ++ "\n"
  ++ "INLINE Term native_string_append_seal(Env e, Term value) {\n"
  ++ "#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_SCON\n"
  ++ "  return value;\n"
  ++ "#else\n"
  ++ "  return rfc_seal(e, value);\n"
  ++ "#endif\n"
  ++ "}\n"
  ++ "\n"
  ++ "OUTLINE Term native_string_append(Env e, Term left, Term right) {\n"
  ++ "  Term result = term_pak(CID_SNIL, 0);\n"
  ++ "  Loc last = 0;\n"
  ++ "  u32 poll = 0;\n"
  ++ "  while (term_aux(left) == CID_SCON) {\n"
  ++ "    if (err_spun(e.mem, &poll)) return 0;\n"
  ++ "    Term fields[2];\n"
  ++ "    Loc cell = ctr_take(e, left, 2, fields);\n"
  ++ "    left = fields[1];\n"
  ++ "    if (cell < HEAP_OFF) cell = heap_alloc(e, cls_fit(2));\n"
  ++ "    e.mem[cell] = fields[0];\n"
  ++ "    e.mem[cell + 1] = term_pak(CID_SNIL, 0);\n"
  ++ "    Term node = term_ctr(CID_SCON, cell);\n"
  ++ "    if (last) e.mem[last + 1] = native_string_append_seal(e, node);\n"
  ++ "    else result = node;\n"
  ++ "    last = cell;\n"
  ++ "  }\n"
  ++ "  if (term_aux(left) != CID_SNIL) {\n"
  ++ "    term_sink(e, left); term_sink(e, right); term_sink(e, result);\n"
  ++ "    err_post(e.mem, ERR_FIDS); return 0;\n"
  ++ "  }\n"
  ++ "  if (!last) return right;\n"
  ++ "  e.mem[last + 1] = native_string_append_seal(e, right);\n"
  ++ "  return result;\n"
  ++ "}\n"
  ++ "\n"
  ++ "#endif\n"
