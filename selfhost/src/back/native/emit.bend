@unsafe
def ne_stores(+base: String, +ws: List<&2, String>, +i: U32, +seal: Bool) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "e.mem[" ++ base ++ " + " ++ U32.show(i) ++ "] = " ++ nt_choose(String, seal, u => "rfc_seal(e, " ++ h ++ ")", u => h) ++ ";\n" ++ ne_stores(base, t, U32.inc(i), seal)

@unsafe
def ne_node(+prefix: String, +alloc: String, +ws: List<&2, String>, +n: U32, +seal: Bool) -> N_Emitted:
  +name = nt_local(prefix, n)
  N_Emitted{"u64 " ++ name ++ " = " ++ alloc ++ ";\n" ++ ne_stores(name, ws, 0, seal), name, U32.inc(n)}

# A checked no-sharing certificate permits cold non-Base parents. Raw emission
# lacks the macro and keeps the ordinary sealed stores. Other node kinds remain
# on ne_node; constructor identity comes from nc_ctor_identity provenance.
@unsafe
def ne_ctor_node(+k: String, +alloc: String, +ws: List<&2, String>, +n: U32, +hot: Bool) -> N_Emitted:
  +name = nt_local("nd", n)
  +stores = nt_choose(String, hot && String.starts_with(k, "$ctor."),
    u => "#if NATIVE_COLD_USER_CTORS\n" ++ ne_stores(name, ws, 0, False{}) ++ "#else\n" ++ ne_stores(name, ws, 0, True{}) ++ "#endif\n",
    u => ne_stores(name, ws, 0, hot))
  N_Emitted{"u64 " ++ name ++ " = " ++ alloc ++ ";\n#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_" ++ nt_cid(k) ++ "\n" ++ ne_stores(name, ws, 0, False{}) ++ "#else\n" ++ stores ++ "#endif\n", name, U32.inc(n)}

@unsafe
def ne_wrap_ctor(+k: String, +x: N_Emitted) -> N_Emitted:
  match x:
    case N_Emitted{+code, +value, +n}: N_Emitted{code, "term_ctr(" ++ nt_cid(k) ++ ", " ++ value ++ ")", n}

@unsafe
def ne_single_result(+prefix: String, +value: String, +boxed: N_Emitted) -> N_Emitted:
  match boxed:
    case N_Emitted{+code, +box, +next}:
      N_Emitted{prefix ++ code ++ value ++ " = " ++ box ++ ";\n}\n", value, next}

# A fitting payload is a trivial tag-zero word; every other value keeps its box.
@unsafe
def ne_single(+k: String, +h: String, +n: U32, +hot: Bool) -> N_Emitted:
  +word = nt_local("pf", n)
  +value = nt_local("pk", n)
  ne_single_result("Term " ++ word ++ " = " ++ h ++ ";\nTerm " ++ value ++ ";\n#if NATIVE_PACK_CTORS\nif ((" ++ word ++ " & ~LOC_MASK) == 0) {\n" ++ value ++ " = term_pak(" ++ nt_cid(k) ++ ", " ++ word ++ ");\n} else\n#endif\n{\n", value, ne_wrap_ctor(k, ne_ctor_node(k, "heap_alloc(e, cls_fit(1))", [word], n, hot)))

@unsafe
def ne_constructor(+k: String, +ws: List<&2, String>, +packed: Bool, +n: U32, +hot: Bool) -> N_Emitted:
  match ws:
    case Nil{}: N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", 0)", n}
    case Con{+h, +t}:
      nt_choose(N_Emitted, packed,
        u => N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", " ++ h ++ ")", n},
        u => nt_choose(N_Emitted, String.starts_with(k, "$ctor.") && U32.is_eq(nt_count(String, t), 0),
          u => ne_single(k, h, n, hot),
          u => ne_wrap_ctor(k, ne_ctor_node(k, "heap_alloc(e, cls_fit(" ++ U32.show(nt_count(String, ws)) ++ "))", ws, n, hot))))

@unsafe
def ne_closure_wrap(+k: String, +x: N_Emitted) -> N_Emitted:
  match x:
    case N_Emitted{+code, +value, +n}: N_Emitted{code, "term_clo(" ++ nt_fid(k) ++ ", " ++ value ++ ")", n}

@unsafe
def ne_closure(+k: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match ws:
    case Nil{}: N_Emitted{"", "term_clo(" ++ nt_fid(k) ++ ", 0)", n}
    case Con{+h, +t}: ne_closure_wrap(k, ne_node("cl", "heap_alloc(e, cls_fit(" ++ U32.show(nt_count(String, ws)) ++ "))", ws, n, False{}))

@unsafe
def ne_frame_stores(+ws: List<&2, String>, +i: U32) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "STK(" ++ U32.show(i) ++ ") = " ++ h ++ ";\n" ++ ne_frame_stores(t, U32.inc(i))

@unsafe
def ne_frame(+ws: List<&2, String>, +next: String) -> String:
  +n = U32.inc(nt_count(String, ws))
  "WL_ROOM(" ++ U32.show(n) ++ ");\n" ++ ne_frame_stores(List.append(&2, String, ws, Con{nt_fid(next), Nil{}}), 0) ++ "WL_PUSHN(" ++ U32.show(n) ++ ");\n"

@unsafe
def ne_registers(+ws: List<&2, String>, +i: U32) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "r" ++ U32.show(i) ++ " = " ++ h ++ ";\n" ++ ne_registers(t, U32.inc(i))

@unsafe
def ne_jump(+ws: List<&2, String>, +k: String) -> String:
  ne_registers(ws, 0) ++ "WL_JMP(" ++ nt_fid(k) ++ ");\n"

@unsafe
def ne_ret(+ws: List<&2, String>) -> String:
  ne_registers(ws, 0) ++ "WL_RETN(" ++ U32.show(nt_count(String, ws)) ++ ");\n"

@unsafe
def ne_task(+k: String, +rem: U32, +ws: List<&2, String>, +cont: String, +idx: String, +n: U32) -> N_Emitted:
  ne_node("task", "task_node(e, " ++ nt_fid(k) ++ ", " ++ cont ++ ", " ++ idx ++ ", " ++ U32.show(rem) ++ ")", ws, n, False{})

@unsafe
def ne_take_params(+ps: List<&2, N_Param>, +slots: List<&2, String>, +i: U32) -> String:
  match ps, slots:
    case Nil{}, _: ""
    case Con{N_Param{+name, +kind}, +t}, Nil{}: "    " ++ nl_c_type(kind) ++ " " ++ name ++ " = r" ++ U32.show(i) ++ ";\n" ++ ne_take_params(t, Nil{}, U32.inc(i))
    case Con{N_Param{+name, +kind}, +t}, Con{+at, +rest}: "    " ++ nl_c_type(kind) ++ " " ++ name ++ " = STK(" ++ at ++ ");\n" ++ ne_take_params(t, rest, i)

@unsafe
def ne_take(+ps: List<&2, N_Param>, +f: N_Frame) -> String:
  match f:
    case N_Direct{}: ne_take_params(ps, Nil{}, 0)
    case N_Frame{+pop, +at}: nt_choose(String, U32.is_eq(pop, 0), u => "", u => "    WL_POPN(" ++ U32.show(pop) ++ ");\n") ++ ne_take_params(ps, at, 0)

@unsafe
def ne_segment(+seg: N_Segment) -> String:
  match seg:
    case N_Segment{+k, +ps, +r, +f, +body, +refs, +host, +spin, +fork, +bang}:
      nt_choose(String, host, u => "#if !DEVICE\n", u => "")
        ++ "  WL_CASE(" ++ nt_fid(k) ++ ")\n  {\n" ++ ne_take(ps, f) ++ "    WL_OPEN\n"
        ++ nt_choose(String, spin, u => "    WL_SPIN\n", u => "")
        ++ body ++ "\n"
        ++ nt_choose(String, spin, u => "    WL_SPUN\n", u => "") ++ "  }}\n"
        ++ nt_choose(String, host, u => "#endif\n", u => "")

@unsafe
def ne_segments_chunks(ss: List<&2, N_Segment>, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "")
    case Con{h, t}: ne_segments_chunks(t, Con{"\n", Con{ne_segment(h), acc}})

@unsafe
def ne_segments_go(ss: List<&2, N_Segment>, acc: String) -> String:
  acc ++ ne_segments_chunks(ss, Nil{})

@unsafe
def ne_segments(+ss: List<&2, N_Segment>) -> String:
  ne_segments_go(ss, "")

@unsafe
def ne_fill(+src: String, +mark: String, +text: String) -> String:
  nt_replace(src, mark, mark ++ "\n\n" ++ text)

# A private canonical artifact is split by this Bend compiler, then transported
# without rescanning. Raw/custom runtime text retains the original scanner.
type NE_Runtime is Data:
  NE_Text{+text: String}
  NE_Parts{+parts: List<&2, String>}

@unsafe
def ne_runtime_prepare(+src: String) -> NE_Runtime:
  +marks = ne_template_marks()
  ne_runtime_prepared(src, ne_template_scan(src, marks, marks, "", Nil{}))

@unsafe
def ne_runtime_prepared(src: String, parts: Maybe<&2, List<&2, String>>) -> NE_Runtime:
  match parts:
    case None{}: NE_Text{src}
    case Some{pieces}: NE_Parts{pieces}

@unsafe
def ne_runtime_prepend(runtime: NE_Runtime, prefix: String) -> NE_Runtime:
  match runtime:
    case NE_Text{text}: NE_Text{prefix ++ text}
    case NE_Parts{parts}: ne_runtime_prefix(parts, prefix)

@unsafe
def ne_runtime_prefix(+parts: List<&2, String>, +prefix: String) -> NE_Runtime:
  match parts:
    case Nil{}: NE_Text{prefix}
    case Con{head, rest}:
      nt_choose(NE_Runtime, ne_template_plain(prefix, False{}),
        u => NE_Parts{Con{prefix ++ head, rest}},
        u => NE_Text{prefix ++ nt_join(parts, "")})

@unsafe
def ne_runtime_texts(runtime: NE_Runtime, +texts: List<&2, String>) -> String:
  match runtime:
    case NE_Text{src}: ne_program_texts(src, texts)
    case NE_Parts{+parts}:
      nt_choose(String, ne_template_payloads(texts),
        u => ne_template_join(parts, texts),
        u => ne_template_slow(nt_join(parts, ""), ne_template_marks(), texts))

# Split only original runtime text. Suspicious input retains sequential fill.
@unsafe
def ne_template_marks() -> List<&2, String>:
  ["// Tables\n// ======", "// Spins\n// =====", "// Segments\n// ========", "// Requests\n// ========"]

@unsafe
def ne_template_mark(+src: String, marks: List<&2, String>) -> String:
  match marks:
    case Nil{}: ""
    case Con{+h, rest}: nt_choose(String, String.starts_with(src, h), u => h, u => ne_template_mark(src, rest))

@unsafe
def ne_template_scan(+src: String, +marks: List<&2, String>, +todo: List<&2, String>, +acc: String, +parts: List<&2, String>) -> Maybe<&2, List<&2, String>>:
  match todo:
    case Nil{}: Some{nt_reverse(String, Con{acc ++ src, parts}, Nil{})}
    case Con{+want, +more}: ne_template_step(src, marks, want, more, acc, parts)

@unsafe
def ne_template_step(+src: String, +marks: List<&2, String>, +want: String, +more: List<&2, String>, +acc: String, +parts: List<&2, String>) -> Maybe<&2, List<&2, String>>:
  match src:
    case SNil{}: None{}
    case SCon{+h, +rest}:
      +mark = nt_choose(String, Char.is_eq(h, '/'), u => ne_template_mark(src, marks), u => "")
      nt_choose(Maybe<&2, List<&2, String>>, String.eq(mark, ""),
        u => ne_template_step(rest, marks, want, more, acc ++ SCon{h, ""}, parts),
        u => ne_template_take(src, marks, want, more, acc, parts, mark))

@unsafe
def ne_template_take(+src: String, +marks: List<&2, String>, +want: String, +more: List<&2, String>, +acc: String, +parts: List<&2, String>, +mark: String) -> Maybe<&2, List<&2, String>>:
  +rest = String.drop(src, String.length(mark))
  nt_choose(Maybe<&2, List<&2, String>>, String.eq(mark, want) && String.starts_with(rest, "\n"),
    u => ne_template_scan(rest, marks, more, "", Con{acc ++ mark, parts}), u => None{})

@unsafe
def ne_template_plain(src: String, +slash: Bool) -> Bool:
  match src:
    case SNil{}: True{}
    case SCon{+h, rest}: nt_choose(Bool, slash && Char.is_eq(h, '/'), u => False{}, u => ne_template_plain(rest, Char.is_eq(h, '/')))

@unsafe
def ne_template_payloads(texts: List<&2, String>) -> Bool:
  match texts:
    case Nil{}: True{}
    case Con{+h, +rest}: nt_choose(Bool, List.is_empty(&2, String, rest), u => True{}, u => nt_choose(Bool, ne_template_plain(h, False{}), v => ne_template_payloads(rest), v => False{}))

@unsafe
def ne_template_slow(src: String, marks: List<&2, String>, texts: List<&2, String>) -> String:
  match marks, texts:
    case Con{mark, more}, Con{text, rest}: ne_template_slow(ne_fill(src, mark, text), more, rest)
    case _, _: src

@unsafe
def ne_template_join(parts: List<&2, String>, texts: List<&2, String>) -> String:
  match parts, texts:
    case Con{h, rest}, Con{text, more}: h ++ "\n\n" ++ text ++ ne_template_join(rest, more)
    case Con{h, Nil{}}, Nil{}: h
    case _, _: ""

@unsafe
def ne_template_finish(+src: String, +marks: List<&2, String>, +texts: List<&2, String>, parts: Maybe<&2, List<&2, String>>) -> String:
  match parts:
    case None{}: ne_template_slow(src, marks, texts)
    case Some{+pieces}: nt_choose(String, ne_template_payloads(texts), u => ne_template_join(pieces, texts), u => ne_template_slow(src, marks, texts))

@unsafe
def ne_program_texts(+src: String, +texts: List<&2, String>) -> String:
  +marks = ne_template_marks()
  ne_template_finish(src, marks, texts, ne_template_scan(src, marks, marks, "", Nil{}))

@unsafe
def ne_program(src: String, p: N_Program) -> String:
  ne_program_runtime(NE_Text{src}, p)

@unsafe
def ne_program_runtime(+runtime: NE_Runtime, +p: N_Program) -> String:
  match p:
    case N_Program{+ss, +cs, +image, +requests, +decls, +show, +pure}:
      ne_runtime_texts(runtime, [nb_emit(ss, cs, nt_count(String, image), pure) ++ show,
        "CONSTV u64 STAT_IMG[] = { " ++ nt_choose(String, U32.is_eq(nt_count(String, image), 0), u => "0", u => nt_join(image, ", ")) ++ " };\n" ++ decls,
        ne_segments(ss), requests])
