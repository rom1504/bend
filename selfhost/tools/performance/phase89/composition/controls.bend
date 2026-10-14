import Base

type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}

type N_Param is Data:
  N_Param{+name: String, +kind: N_WordKind}

type N_Frame is Data:
  N_Direct{}
  N_Frame{+pop: U32, +slots: List<&2, String>}

type N_Segment is Data:
  N_Segment{+name: String, +params: List<&2, N_Param>, +result: U32, +frame: N_Frame, +body: String, +refs: List<&2, String>, +host: Bool, +spin: Bool, +fork: Bool, +bang: Bool}

type NC_Code is Data:
  NC_Code{+body: String, +segments: List<&2, N_Segment>, +fresh: U32, +error: String, +calls: List<&2, String>}

@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Chunks arrive in reverse output order. Only each new chunk is traversed by
# append; the growing suffix stays on its right.

@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

@unsafe
def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)

@unsafe
def nt_clean(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}:
      nt_choose(String, Char.is_alpha(h) || Char.is_digit(h) || Char.is_eq(h, '_'), u => SCon{h, ""}, u => "_") ++ nt_clean(t)

@unsafe
def nt_cid(k: String) -> String:
  "CID_" ++ String.to_upper(nt_clean(k))

@unsafe
def nc_id(+n: U32) -> U32:
  U32.sub(4294967295, n)

@unsafe
def nh_field_test(+ctor: String, +i: U32) -> String:
  "!DEVICE && NATIVE_FIELD32_" ++ nt_cid(ctor) ++ "_" ++ U32.show(i)

@unsafe
def nh_field_type(+ctor: String, +i: U32) -> String:
  "#if " ++ nh_field_test(ctor, i) ++ "\nu32\n#else\nTerm\n#endif\n"

@unsafe
def nc_body(+x: NC_Code) -> String:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: body

@unsafe
def nc_segs(+x: NC_Code) -> List<&2, N_Segment>:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: segs

@unsafe
def nc_fresh(+x: NC_Code) -> U32:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: n

@unsafe
def nc_error(+x: NC_Code) -> String:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: err

@unsafe
def nc_first_error(+a: NC_Code, +b: NC_Code) -> String:
  nt_choose(String, String.eq(nc_error(a), ""), u => nc_error(b), u => nc_error(a))

@unsafe
def nc_calls(+code: NC_Code) -> List<&2, String>:
  match code:
    case NC_Code{body, segs, fresh, error, edges}: edges

@unsafe
def nc_condition(+name: String, +word: String) -> String:
  nt_choose(String, String.eq(name, "False"), u => "(!native_bool(" ++ word ++ "))", u =>
  nt_choose(String, String.eq(name, "True"), u => "native_bool(" ++ word ++ ")", u =>
  nt_choose(String, String.eq(name, "Zero"), u => "(" ++ word ++ " == 0)", u =>
  nt_choose(String, String.eq(name, "Succ"), u => "(" ++ word ++ " != 0)", u =>
  nt_choose(String, String.eq(name, "Chr") || String.eq(name, "U32") || String.eq(name, "F32"), u => "1", u =>
  nt_choose(String, String.eq(name, "ALeaf"), u => "(blk_cls(" ++ word ++ ") == 0)", u =>
  nt_choose(String, String.eq(name, "ANode"), u => "(blk_cls(" ++ word ++ ") != 0)", u =>
    "(term_aux(" ++ word ++ ") == " ++ nt_cid(name) ++ ")")))))))

@unsafe
def nc_field_word(+name: String, +word: String, +i: U32) -> String:
  nt_choose(String, String.eq(name, "Succ"), u => "(" ++ word ++ " - 1)", u =>
  nt_choose(String, String.eq(name, "Chr"), u => word, u =>
  nt_choose(String, String.eq(name, "U32") || String.eq(name, "F32"), u => "native_word(e, (u32)" ++ word ++ ")", u =>
  nt_choose(String, String.eq(name, "ALeaf"), u => "blk_leaf(e, " ++ word ++ ")", u =>
  nt_choose(String, String.eq(name, "ANode"), u => "blk_half(e, " ++ word ++ ", " ++ U32.show(i) ++ ")", u =>
    "e.mem[term_peek(e, " ++ word ++ ") + " ++ U32.show(i) ++ "]")))))

@unsafe
def nc_field_decls(+name: String, +word: String, +count: U32, +i: U32, +n: U32, +boxed: Bool) -> String:
  nt_choose(String, U32.is_eq(i, count), u => "", u =>
    nh_field_type(name, i) ++ "v_" ++ U32.show(nc_id(U32.add(n, i))) ++ " = " ++ nt_choose(String, boxed, u => "fields[" ++ U32.show(i) ++ "]", u => nc_field_word(name, word, i)) ++ ";\n" ++ nc_field_decls(name, word, count, U32.inc(i), n, boxed))

@unsafe
def nc_destructure(+name: String, +word: String, +count: U32, +n: U32) -> String:
  +boxed = Bool.not(String.eq(name, "Succ") || String.eq(name, "Zero") || String.eq(name, "True") || String.eq(name, "False") || String.eq(name, "Chr") || String.eq(name, "U32") || String.eq(name, "F32") || String.eq(name, "ALeaf") || String.eq(name, "ANode")) && U32.is_gt(count, 0)
  nt_choose(String, boxed,
    u => "Term fields[" ++ U32.show(count) ++ "];\n" ++ nt_choose(String, U32.is_eq(count, 1), u => "if (term_tag(" ++ word ++ ") == TAG_PAK) { fields[0] = term_loc(" ++ word ++ "); } else {\n", u => "") ++ "spare_free(e, cls_fit(" ++ U32.show(count) ++ "), ctr_take(e, " ++ word ++ ", " ++ U32.show(count) ++ ", fields));\n" ++ nt_choose(String, U32.is_eq(count, 1), u => "}\n", u => ""),
    u => "") ++ nc_field_decls(name, word, count, 0, n, boxed) ++ nt_choose(String, String.eq(name, "ALeaf"), u => "blk_free(e, " ++ word ++ ");\n", u => "")

@unsafe
def nc_match_apply_join(+name: String, +word: String, +count: U32, +n: U32, hit_body: String, hit_segs: List<&2, N_Segment>, +hit_error: String, hit_calls: List<&2, String>, miss: NC_Code) -> NC_Code:
  match miss:
    case NC_Code{miss_body, miss_segs, miss_next, miss_error, miss_calls}:
      +guard = nt_choose(String, String.eq(name, "Emit") || String.eq(name, "Halt"), u => "if (term_aux(" ++ word ++ ") != CID_EMIT && term_aux(" ++ word ++ ") != CID_HALT) { err_post(e.mem, ERR_TAGS); return 0; }\n", u => "")
      NC_Code{guard ++ "if (" ++ nc_condition(name, word) ++ ") {\n" ++ nc_destructure(name, word, count, n) ++ hit_body ++ "} else {\n" ++ miss_body ++ "}\n", nt_append(N_Segment, hit_segs, miss_segs), miss_next, nt_choose(String, String.eq(hit_error, ""), u => miss_error, u => hit_error), List.append(&2, String, hit_calls, List.append(&2, String, miss_calls, Nil{}))}

@unsafe
def p89_original(+name: String, +word: String, +count: U32, +n: U32, +hit: NC_Code, +miss: NC_Code) -> NC_Code:
  +guard = nt_choose(String, String.eq(name, "Emit") || String.eq(name, "Halt"), u => "if (term_aux(" ++ word ++ ") != CID_EMIT && term_aux(" ++ word ++ ") != CID_HALT) { err_post(e.mem, ERR_TAGS); return 0; }\n", u => "")
  NC_Code{guard ++ "if (" ++ nc_condition(name, word) ++ ") {\n" ++ nc_destructure(name, word, count, n) ++ nc_body(hit) ++ "} else {\n" ++ nc_body(miss) ++ "}\n", nt_append(N_Segment, nc_segs(hit), nc_segs(miss)), nc_fresh(miss), nc_first_error(hit, miss), List.append(&2, String, nc_calls(hit), List.append(&2, String, nc_calls(miss), Nil{}))}

type P89Case is Data:
  P89Case{+name: String, +original: NC_Code, +candidate: NC_Code}

@unsafe
def p89_candidate(+name: String, +word: String, +count: U32, +n: U32, hit: NC_Code, miss: NC_Code) -> NC_Code:
  match hit:
    case NC_Code{body, segs, next, error, calls}:
      nc_match_apply_join(name, word, count, n, body, segs, error, calls, miss)

@unsafe
def p89_segment(+name: String, +n: U32) -> N_Segment:
  N_Segment{name, [N_Param{"arg", N_W64{}}], n, N_Frame{n, ["slot"]}, "segment-body:" ++ name, ["seg-ref:" ++ name], True{}, False{}, True{}, False{}}

@unsafe
def p89_child(+side: String, n: U32, error: String) -> NC_Code:
  NC_Code{"BODY:" ++ side ++ ";\n", [p89_segment(side, 3)], n, error, ["first:" ++ side, "dup", "last:" ++ side]}

@unsafe
def p89_case(name: String, +ctor: String, +count: U32, +hit: NC_Code, +miss: NC_Code) -> P89Case:
  P89Case{name, p89_original(ctor, "w", count, 100, hit, miss), p89_candidate(ctor, "w", count, 100, hit, miss)}

@unsafe
def main() -> List<&2, P89Case>:
  [
    p89_case("ordinary", "Box", 2, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("hit-error", "Box", 2, p89_child("hit", 17, "hit-failed"), p89_child("miss", 29, "")),
    p89_case("miss-error", "Box", 2, p89_child("hit", 17, ""), p89_child("miss", 29, "miss-failed")),
    p89_case("both-error", "Box", 2, p89_child("hit", 17, "hit-failed"), p89_child("miss", 29, "miss-failed")),
    p89_case("effect-emit", "Emit", 2, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("effect-halt", "Halt", 1, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-true", "True", 0, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-false", "False", 0, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-zero", "Zero", 0, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-succ", "Succ", 1, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-chr", "Chr", 1, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-u32", "U32", 1, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("primitive-f32", "F32", 1, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("array-leaf", "ALeaf", 1, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("array-node", "ANode", 2, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("generic-nullary", "Empty", 0, p89_child("hit", 17, ""), p89_child("miss", 29, "")),
    p89_case("empty", "Empty", 0, NC_Code{"", Nil{}, 0, "", Nil{}}, NC_Code{"", Nil{}, 7, "", Nil{}}),
    p89_case("no-newline", "Box", 1, NC_Code{"HIT", Nil{}, 0, "", ["h"]}, NC_Code{"MISS", Nil{}, 31, "", ["m"]}),
    p89_case("nested", "True", 0, p89_original("Box", "inner", 2, 200, p89_child("inner-hit", 11, ""), p89_child("inner-miss", 19, "")), p89_child("outer-miss", 43, ""))
  ]
