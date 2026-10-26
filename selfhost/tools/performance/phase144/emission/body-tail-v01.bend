# Preserve the caller's suffix while flattening the existing reversed chunks.
# The successful path constructs the complete body+suffix once. No new QBE
# instructions, output effects, representation, verifier or runtime contract.
@unsafe
def p144e_body_tail(+code: P111QCode, +tail: String) -> String:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(String,Bool.not(String.eq(error,"")),u => "INVALID_N111_BODY\n" ++ tail,u =>
        nt_choose(String,terminal,u => nt_text_finish(chunks,tail),u => "INVALID_N111_FALLTHROUGH\n" ++ tail))
