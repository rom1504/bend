# Append to the current compiler manifest, replacing its entry. Root owns checks.
# These controls work with both the unmodified and patched helper definitions.

@unsafe
def p87_join_controls() -> Bool:
  String.eq(nt_join([], "/"), "")
    && String.eq(nt_join([""], "/"), "")
    && String.eq(nt_join(["", ""], "-"), "-")
    && String.eq(nt_join(["a", "", "b"], ":"), "a::b")
    && String.eq(nt_join(["α", "🙂"], "|"), "α|🙂")
    && String.eq(nt_join(["a", "b", ""], "\n"), "a\nb\n")
    && String.eq(nt_join_go([], "/", "prefix", False{}), "prefix")
    && String.eq(nt_join_go(["", "x"], "|", "P", False{}), "P||x")
    && String.eq(nt_join_go(["", "x"], "|", "P", True{}), "P|x")

@unsafe
def p87_lines_controls() -> Bool:
  String.eq(nt_lines(""), "")
    && String.eq(nt_lines("a"), "a")
    && String.eq(nt_lines("\n"), "\n    ")
    && String.eq(nt_lines("\n\n"), "\n    \n    ")
    && String.eq(nt_lines("α\n🙂\r\n"), "α\n    🙂\r\n    ")
    && String.eq(nt_lines_go("", "P\n"), "P\n")
    && String.eq(nt_lines_go("x\ny", "P\n"), "P\nx\n    y")
    && String.eq(nt_indent("x\n"), "    x\n    ")

@unsafe
def p87_old_segments_go(ss: List<&2, N_Segment>, acc: String) -> String:
  match ss:
    case Nil{}: acc
    case Con{h, t}: p87_old_segments_go(t, acc ++ ne_segment(h) ++ "\n")

@unsafe
def p87_segment(name: String, body: String, host: Bool, spin: Bool) -> N_Segment:
  N_Segment{name, [], 0, N_Direct{}, body, [], host, spin, False{}, False{}}

@unsafe
def p87_segments_controls() -> Bool:
  +one = p87_segment("alpha", "", False{}, False{})
  +two = p87_segment("beta", "x;\nα🙂\n", True{}, True{})
  String.eq(ne_segments_go([], "P\n"), "P\n")
    && String.eq(ne_segments_go([one], "P\n"), p87_old_segments_go([one], "P\n"))
    && String.eq(ne_segments_go([one, two], "P\n"), p87_old_segments_go([one, two], "P\n"))
    && String.eq(ne_segments([two, one]), p87_old_segments_go([two, one], ""))

@unsafe
def p87_repeat_text(+n: U32, piece: String, acc: String) -> String:
  p87_repeat_text_step(n, piece, acc, U32.is_eq(n, 0))

@unsafe
def p87_repeat_text_step(n: U32, +piece: String, acc: String, done: Bool) -> String:
  match done:
    case True{}: acc
    case False{}: p87_repeat_text(U32.sub(n, 1), piece, piece ++ acc)

@unsafe
def p87_repeat_chunks(+n: U32, piece: String, acc: List<&2, String>) -> List<&2, String>:
  p87_repeat_chunks_step(n, piece, acc, U32.is_eq(n, 0))

@unsafe
def p87_repeat_chunks_step(n: U32, +piece: String, acc: List<&2, String>, done: Bool) -> List<&2, String>:
  match done:
    case True{}: acc
    case False{}: p87_repeat_chunks(U32.sub(n, 1), piece, Con{piece, acc})

@unsafe
def p87_repeat_segments(+n: U32, segment: N_Segment, acc: List<&2, N_Segment>) -> List<&2, N_Segment>:
  p87_repeat_segments_step(n, segment, acc, U32.is_eq(n, 0))

@unsafe
def p87_repeat_segments_step(n: U32, +segment: N_Segment, acc: List<&2, N_Segment>, done: Bool) -> List<&2, N_Segment>:
  match done:
    case True{}: acc
    case False{}: p87_repeat_segments(U32.sub(n, 1), segment, Con{segment, acc})

@unsafe
def p87_scale_lines(n: U32) -> String:
  nt_lines(p87_repeat_text(n, "x\n", ""))

@unsafe
def p87_scale_join(n: U32) -> String:
  nt_join(p87_repeat_chunks(n, "abcdefgh", []), ", ")

@unsafe
def p87_scale_segments(n: U32) -> String:
  ne_segments(p87_repeat_segments(n, p87_segment("sample", "x;\ny;\n", False{}, False{}), []))

@unsafe
def main() -> Bool:
  p87_join_controls() && p87_lines_controls() && p87_segments_controls()

#|True{}
