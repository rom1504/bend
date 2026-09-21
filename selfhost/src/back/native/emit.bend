@unsafe
def ne_stores(+base: String, +ws: List<&2, String>, +i: U32, +seal: Bool) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "e.mem[" ++ base ++ " + " ++ U32.show(i) ++ "] = " ++ nt_choose(String, seal, u => "rfc_seal(e, " ++ h ++ ")", u => h) ++ ";\n" ++ ne_stores(base, t, U32.inc(i), seal)

@unsafe
def ne_node(+prefix: String, +alloc: String, +ws: List<&2, String>, +n: U32, +seal: Bool) -> N_Emitted:
  +name = nt_local(prefix, n)
  N_Emitted{"u64 " ++ name ++ " = " ++ alloc ++ ";\n" ++ ne_stores(name, ws, 0, seal), name, U32.inc(n)}

@unsafe
def ne_wrap_ctor(+k: String, +x: N_Emitted) -> N_Emitted:
  match x:
    case N_Emitted{+code, +value, +n}: N_Emitted{code, "term_ctr(" ++ nt_cid(k) ++ ", " ++ value ++ ")", n}

@unsafe
def ne_constructor(+k: String, +ws: List<&2, String>, +packed: Bool, +n: U32, +hot: Bool) -> N_Emitted:
  match ws:
    case Nil{}: N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", 0)", n}
    case Con{+h, +t}:
      nt_choose(N_Emitted, packed,
        u => N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", " ++ h ++ ")", n},
        u => ne_wrap_ctor(k, ne_node("nd", "heap_alloc(e, cls_fit(" ++ U32.show(nt_count(String, ws)) ++ "))", ws, n, hot)))

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
        ++ nt_indent(body) ++ "\n"
        ++ nt_choose(String, spin, u => "    WL_SPUN\n", u => "") ++ "  }}\n"
        ++ nt_choose(String, host, u => "#endif\n", u => "")

@unsafe
def ne_segments_go(ss: List<&2, N_Segment>, acc: String) -> String:
  match ss:
    case Nil{}: acc
    case Con{h, t}: ne_segments_go(t, acc ++ ne_segment(h) ++ "\n")

@unsafe
def ne_segments(+ss: List<&2, N_Segment>) -> String:
  ne_segments_go(ss, "")

@unsafe
def ne_fill(+src: String, +mark: String, +text: String) -> String:
  nt_replace(src, mark, mark ++ "\n\n" ++ text)

@unsafe
def ne_program(+src: String, +p: N_Program) -> String:
  match p:
    case N_Program{+ss, +cs, +image, +requests, +decls, +show, +pure}:
      a = ne_fill(src, "// Tables\n// ======", nb_emit(ss, cs, nt_count(String, image), pure) ++ show)
      b = ne_fill(a, "// Spins\n// =====", "CONSTV u64 STAT_IMG[] = { " ++ nt_choose(String, U32.is_eq(nt_count(String, image), 0), u => "0", u => nt_join(image, ", ")) ++ " };\n" ++ decls)
      c = ne_fill(b, "// Segments\n// ========", ne_segments(ss))
      ne_fill(c, "// Requests\n// ========", requests)
