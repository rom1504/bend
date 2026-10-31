
# Module: src/load/imports.bend:13
@unsafe
def f_import_header_error(+ts: FInput) -> KTerm:
  fpe_line(ts, "a module import requires as followed by an alias", "an import ('import Base', or 'import <path> as <Name>')")

# Module: src/load/imports.bend:28
@unsafe
def f_import_alias_head(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}: f_choose(String, Char.is_eq(c, '.'), u => "", u => SCon{c, f_import_alias_head(rest)})



# Local imports use the pinned plain-segment grammar before path resolution.
# Hub/package resolution is unchanged and remains outside this host's scope.

# Module: src/load/imports.bend:38
@unsafe
def f_import_valid(+path: String) -> Bool:
  f_choose(Bool, Bool.not(String.starts_with(path, "./") || String.starts_with(path, "../") || String.starts_with(path, "/")) && (String.starts_with(path, "0x") || String.contains(path, "@")), u => True{}, u => f_import_local(f_strip_bend(f_choose(String, String.starts_with(path, "./"), u => f_drop_chars(path, 2), u => path))))

# Module: src/load/imports.bend:42
@unsafe
def f_import_local(+path: String) -> Bool:
  f_choose(Bool, String.starts_with(path, "/"), u => f_import_segments(f_tail(path), True{}), u => f_import_parents(path))

# Module: src/load/imports.bend:46
@unsafe
def f_import_parents(+path: String) -> Bool:
  f_choose(Bool, String.starts_with(path, "../"), u => f_import_parents(f_drop_chars(path, 3)), u => f_import_segments(path, True{}))

# Module: src/load/imports.bend:50
@unsafe
def f_import_segments(+path: String, +head: Bool) -> Bool:
  match path:
    case SNil{}: Bool.not(head)
    case SCon{c, rest}:
      f_choose(Bool, Char.is_eq(c, '/'), u => Bool.not(head) && f_import_segments(rest, True{}), u => (f_ascii_alpha(c) || Char.is_eq(c, '_') || (Bool.not(head) && (Char.is_digit(c) || Char.is_eq(c, '-')))) && f_import_segments(rest, False{}))

# Import nodes carry the original path token's line and code-point column.
# Convert this location to UTF-16 only when presenting an IO failure.

# Module: src/load/imports.bend:59
@unsafe
def f_import_offset(+source: String, +line: U32, +column: U32, +offset: U32) -> U32:
  match source:
    case SNil{}: offset
    case SCon{c, rest}:
      f_choose(U32, U32.is_gt(line, 1), u => f_import_offset(rest, f_choose(U32, Char.is_eq(c, '\n'), u => U32.sub(line, 1), u => line), column, U32.add(offset, dg_units(c))), u => f_choose(U32, U32.is_eq(column, 0), u => offset, u => f_import_offset(rest, line, U32.sub(column, 1), U32.add(offset, dg_units(c)))))

# Module: src/load/imports.bend:66
@unsafe
def f_import_failure(+source: String, +im: KTerm, +path: String, +cycle: Bool) -> String:
  +offset = f_import_offset(source, ix(im), qt(im), 0)
  "Error:\n- message  : " ++ f_choose(String, cycle, u => "an import cycle through ", u => "no such file: ") ++ path ++ "\nLocation:" ++ dg_snippet(DSpan{source, offset, offset})

# These spellings are the explicit normalized symbol variants of f_lex_symbol.

# Module: src/load/imports.bend:72
@unsafe
def f_import_token_text(+ts: FInput) -> String:
  f_choose(String, f_eq(f_tx(ts), "+bind"), u => "+",
    u => f_choose(String, f_eq(f_tx(ts), ">op"), u => ">",
      u => f_choose(String, f_eq(f_tx(ts), ">>op"), u => ">>", u => f_tx(ts))))

# Module: src/load/imports.bend:78
@unsafe
def f_import_raw(+error: KTerm) -> KTerm:
  k_with_children(error, [kid(error, 0), kid(error, 1), kid(error, 2), {KTerm{"ParseRaw", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])
