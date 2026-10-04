# These helpers are used only after exact type/JPure/source ownership admission.
@unsafe
def j_string_match_condition(+book: List<&2,KDef>, +input: KTerm, +arg: String, +name: String) -> String:
  kc(String, j_string_string(book, input) && (String.eq(name, "SNil") || String.eq(name, "SCon")),
    u => "(" ++ arg ++ ")" ++ kc(String, String.eq(name, "SNil"), u => "===\"\"", u => "!==\"\""), u =>
  kc(String, j_string_char(book, input) && String.eq(name, "Chr"), u => "true", u => ""))

@unsafe
def j_string_match_fields(+at: U32, +total: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => rest, u =>
    Con{"$native[" ++ U32.show(at) ++ "]", j_string_match_fields(U32.inc(at), total, rest)})
