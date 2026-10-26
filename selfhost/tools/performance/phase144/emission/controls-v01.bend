@unsafe
def p144ec_tail(+chunks: List<&2,String>, +terminal: Bool, +error: String, +tail: String, +expected: String) -> Bool:
  +code : P111QCode = P111QCode{chunks,4294967295,terminal,error}
  p88_string_eq(p144e_body_tail(code,tail),expected) &&
    p88_string_eq(p111q_body_text(code) ++ tail,expected)

@unsafe
def p144e_controls() -> List<&2,String>:
  [p114st_row("body-tail-empty-body",p144ec_tail([],True{},"","}\n","}\n")),
   p114st_row("body-tail-empty-suffix",p144ec_tail(["ret 0\n"],True{},"","","ret 0\n")),
   p114st_row("body-tail-reversed-instruction-order",p144ec_tail(["ret 0\n","@entry\n"],True{},"","}\n","@entry\nret 0\n}\n")),
   p114st_row("body-tail-empty-fragments",p144ec_tail(["","ret 0\n","","@entry\n",""],True{},"","}\n","@entry\nret 0\n}\n")),
   p114st_row("body-tail-partial-line-boundaries",p144ec_tail(["0\n","ret ","@entry\n"],True{},"","}\n","@entry\nret 0\n}\n")),
   p114st_row("body-tail-no-terminal-preserves-marker",p144ec_tail(["ignored"],False{},"","}\n","INVALID_N111_FALLTHROUGH\n}\n")),
   p114st_row("body-tail-error-before-terminal",p144ec_tail(["ignored"],True{},"problem","}\n","INVALID_N111_BODY\n}\n")),
   p114st_row("body-tail-error-before-fallthrough",p144ec_tail(["ignored"],False{},"problem","}\n","INVALID_N111_BODY\n}\n")),
   p114st_row("body-tail-error-empty-suffix",p144ec_tail([],True{},"problem","","INVALID_N111_BODY\n")),
   p114st_row("body-tail-unicode-and-embedded-newlines",p144ec_tail(["𐀀\n商"],True{},"","\n}\n","𐀀\n商\n}\n"))]
