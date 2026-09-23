# P5-011 rejection-only rendering; raw errors retain their legacy text for fallback.
law fpe_error:
  for +ts: List<&2,FToken>
  for +legacy: String
  for +expected: String
  FParsed
law fpe_finish:
  for +source: String
  for +raw: FRawResult
  FResult
law fpe_render:
  for +source: String
  for +error: KTerm
  String
law fpe_seek:
  for +source: String
  for +rest: String
  for +line: U32
  for +column: U32
  for +error: KTerm
  String
law fpe_here:
  for +source: String
  for +rest: String
  for +error: KTerm
  String
law fpe_message:
  for +source: String
  for +error: KTerm
  for +observed: String
  String
law fpe_lines_count:
  for +lines: List<&2,String>
  U32
law fpe_snippet:
  for +lines: List<&2,String>
  for +at: U32
  String
law fpe_snippet_lines:
  for +lines: List<&2,String>
  for +at: U32
  for +end: U32
  for +line: U32
  String
law fpe_pad:
  for +text: String
  for +width: U32
  String

@unsafe
def fpe_error(ts, legacy, expected):
  FParsed{kt("Error", nm(f_pn(f_err(ts, legacy))), f_line(ts), f_col(ts), [kt("ParseExpected", expected, 0, 0, Nil{})]), Nil{}}

@unsafe
def fpe_finish(source, raw):
  match raw:
    case FRawResult{book, error, imports}:
      FResult{book, fpe_render(source, error), imports}

@unsafe
def fpe_render(source, error):
  f_choose(String, String.eq(tg(error), "Absent"), u => "", u => f_choose(String, String.eq(tg(error), "Error") && String.eq(tg(kid(error, 0)), "ParseExpected") && U32.is_gt(ix(error), 0), u => fpe_seek(source, source, 1, 0, error), u => nm(error)))

@unsafe
def fpe_seek(source, rest, line, column, error):
  f_choose(String, U32.is_eq(line, ix(error)) && U32.is_eq(column, qt(error)), u => fpe_here(source, rest, error), u => f_choose(String, String.is_empty(rest), u => nm(error), u => f_choose(String, U32.is_eq(Char.to_u32(f_head(rest)), 10), u => fpe_seek(source, f_tail(rest), U32.add(line, 1), 0, error), u => fpe_seek(source, f_tail(rest), line, U32.add(column, 1), error))))

@unsafe
def fpe_here(source, rest, error):
  f_choose(String, String.is_empty(rest), u => fpe_message(source, error, "end of input"), u => f_choose(String, U32.is_gt(Char.to_u32(f_head(rest)), 65535) || (U32.is_ge(Char.to_u32(f_head(rest)), 55296) && U32.is_le(Char.to_u32(f_head(rest)), 57343)), u => nm(error), u => fpe_message(source, error, "'" ++ SCon{f_head(rest), ""} ++ "'")))

@unsafe
def fpe_message(source, error, observed):
  "Error:\n- expected : " ++ nm(kid(error, 0)) ++ "\n- observed : " ++ observed ++ "\nLocation:" ++ fpe_snippet(String.lines(source), ix(error))

@unsafe
def fpe_lines_count(lines):
  match lines:
    case Nil{}: 0
    case Con{head, tail}: U32.add(1, fpe_lines_count(tail))

@unsafe
def fpe_snippet(lines, at):
  fpe_snippet_lines(lines, at, f_choose(U32, U32.is_lt(fpe_lines_count(lines), U32.add(at, 1)), u => fpe_lines_count(lines), u => U32.add(at, 1)), 1)

@unsafe
def fpe_snippet_lines(lines, at, end, line):
  match lines:
    case Nil{}: ""
    case Con{head, tail}:
      f_choose(String, U32.is_gt(line, end), u => "", u => f_choose(String, U32.is_lt(U32.add(line, 1), at), u => "", u => "\n" ++ fpe_pad(U32.show(line), U32.from_nat(String.length(U32.show(end)))) ++ f_choose(String, U32.is_eq(line, at), u => ">| ", u => " | ") ++ head) ++ fpe_snippet_lines(tail, at, end, U32.add(line, 1)))

@unsafe
def fpe_pad(text, width):
  f_choose(String, U32.is_lt(U32.from_nat(String.length(text)), width), u => fpe_pad(" " ++ text, width), u => text)
