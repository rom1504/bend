import Base

# Upstream-compatible structured diagnostic formatting, without host rendering.
law dg_units:
  for +c: Char
  U32

law dg_width:
  for +s: String
  U32

law dg_line_at:
  for +s: String
  for +offset: U32
  for +line: U32
  U32

law dg_padding:
  for +n: U32
  String

law dg_lpad:
  for +s: String
  for +width: U32
  String

law dg_rpad:
  for +s: String
  for +width: U32
  String

law dg_lines_count:
  for +lines: List<&2, String>
  U32

law dg_snippet:
  for +span: DSpan
  String

law dg_snippet_at:
  for +lines: List<&2, String>
  for +at: U32
  String

law dg_snippet_lines:
  for +lines: List<&2, String>
  for +at: U32
  for +end: U32
  for +line: U32
  String

law dg_scope:
  for +ctx: List<&2, KTerm>
  for +env: List<&2, KPName>
  List<&2, KPName>

law dg_context_width:
  for +ctx: List<&2, KTerm>
  U32

law dg_expr:
  for +book: List<&2, KDef>
  for +expr: DExpr
  for +env: List<&2, KPName>
  String

law dg_context:
  for +book: List<&2, KDef>
  for +ctx: List<&2, KTerm>
  for +env: List<&2, KPName>
  for +width: U32
  String

law dg_location:
  for +name: String
  for +span: DSpan
  String

law dg_location_text:
  for +name: String
  for +snippet: String
  String

law dg_render:
  for +book: List<&2, KDef>
  for +diagnostic: DDiagnostic
  String

law dg_render_parts:
  for +book: List<&2, KDef>
  for +expected: DExpr
  for +observed: DExpr
  for +has_observed: Bool
  for +ctx: List<&2, KTerm>
  for +name: String
  for +span: DSpan
  for +note: String
  String

law diagnostic_render:
  for +result: DResult
  String

law dg_render_checked:
  for +book: List<&2, KDef>
  for +diagnostic: DDiagnostic
  for +error: String
  String

@unsafe
def dg_units(c):
  kc(U32, U32.is_gt(Char.to_u32(c), 65535), u => 2, u => 1)

@unsafe
def dg_width(s):
  match s:
    case SNil{}: 0
    case SCon{c, rest}: U32.add(dg_units(c), dg_width(rest))

@unsafe
def dg_line_at(s, offset, line):
  match s:
    case SNil{}: line
    case SCon{c, rest}:
      kc(U32, U32.is_lt(offset, dg_units(c)), u => line, u => dg_line_at(rest, U32.sub(offset, dg_units(c)), kc(U32, Char.is_eq(c, '\n'), u => U32.add(line, 1), u => line)))

@unsafe
def dg_padding(n):
  kc(String, U32.is_eq(n, 0), u => "", u => " " ++ dg_padding(U32.sub(n, 1)))

@unsafe
def dg_lpad(s, width):
  dg_padding(kc(U32, U32.is_gt(width, dg_width(s)), u => U32.sub(width, dg_width(s)), u => 0)) ++ s

@unsafe
def dg_rpad(s, width):
  s ++ dg_padding(kc(U32, U32.is_gt(width, dg_width(s)), u => U32.sub(width, dg_width(s)), u => 0))

@unsafe
def dg_lines_count(lines):
  match lines:
    case Nil{}: 0
    case Con{h, rest}: U32.add(1, dg_lines_count(rest))

@unsafe
def dg_snippet(span):
  match span:
    case DNoSpan{}: ""
    case DSpan{source, begin, end}: dg_snippet_at(String.lines(source), dg_line_at(source, begin, 1))

@unsafe
def dg_snippet_at(lines, at):
  dg_snippet_lines(lines, at, kc(U32, U32.is_lt(dg_lines_count(lines), U32.add(at, 1)), u => dg_lines_count(lines), u => U32.add(at, 1)), 1)

@unsafe
def dg_snippet_lines(lines, at, end, line):
  match lines:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, U32.is_gt(line, end), u => "", u => kc(String, U32.is_lt(U32.add(line, 1), at), u => "", u => "\n" ++ dg_lpad(U32.show(line), dg_width(U32.show(end))) ++ kc(String, U32.is_eq(line, at), u => ">| ", u => " | ") ++ h) ++ dg_snippet_lines(rest, at, end, U32.add(line, 1)))

@unsafe
def dg_scope(ctx, env):
  match ctx:
    case Nil{}: env
    case Con{h, rest}: dg_scope(rest, kp_bind(env, h))

@unsafe
def dg_context_width(ctx):
  match ctx:
    case Nil{}: 0
    case Con{h, rest}: norm_max(dg_width(nm(h)), dg_context_width(rest))

@unsafe
def dg_expr(book, expr, env):
  match expr:
    case DText{text}: text
    case DTerm{term}: kp_go(strong(book, term), 0, env)

@unsafe
def dg_context(book, ctx, env, width):
  match ctx:
    case Nil{}: ""
    case Con{h, rest}: "\n- " ++ dg_rpad(nm(h), width) ++ " : " ++ dg_expr(book, DTerm{kid(h, 0)}, env) ++ dg_context(book, rest, kp_bind(env, h), width)

@unsafe
def dg_location(name, span):
  dg_location_text(name, dg_snippet(span))

@unsafe
def dg_location_text(name, snippet):
  kc(String, String.eq(name, "") && String.eq(snippet, ""), u => "", u => "\nLocation:" ++ kc(String, String.eq(name, ""), u => "", u => " " ++ name) ++ snippet)

@unsafe
def dg_render(book, diagnostic):
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      dg_render_parts(book, expected, observed, has_observed, List.reverse(&2, KTerm, context), definition, span, note)

@unsafe
def dg_render_parts(book, expected, observed, has_observed, ctx, name, span, note):
  "Error:" ++ kc(String, has_observed, u => "\n- expected : " ++ dg_expr(book, expected, dg_scope(ctx, Nil{})) ++ "\n- observed : " ++ dg_expr(book, observed, dg_scope(ctx, Nil{})), u => "\n- message  : " ++ dg_expr(book, expected, dg_scope(ctx, Nil{}))) ++ kc(String, U32.is_eq(terms_len(ctx), 0), u => "", u => "\nContext:" ++ dg_context(book, ctx, Nil{}, dg_context_width(ctx))) ++ dg_location(name, span) ++ kc(String, String.eq(note, ""), u => "", u => "\n" ++ note)

@unsafe
def diagnostic_render(result):
  match result:
    case DResult{error, book, diagnostic}: kc(String, String.eq(error, ""), u => "", u => dg_render_checked(book, diagnostic, error))

@unsafe
def dg_render_checked(book, diagnostic, error):
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      kc(String, U32.is_eq(terms_len(trail), 0), u => "Error: " ++ error, u => dg_render(book, diagnostic))

