
# Module: src/back/js/ir/native-values.bend:7
@unsafe
def jw_emit_native_value(+name: String, +args: List<&2,JWValue>, +direct: Bool) -> String:
  match args:
    case Con{left, Con{right, Nil{}}}:
      kc(String, p88_string_eq(name, "String.append"), u =>
        "(/* private String.append */(" ++ jw_emit_value(left, direct) ++ ")+(" ++
          jw_emit_value(right, direct) ++ "))", u => jw_emit_native_fallback(name, args, direct))
    case other: jw_emit_native_fallback(name, args, direct)

# Module: src/back/js/ir/native-values.bend:16
@unsafe
def jw_emit_native_fallback(+name: String, +args: List<&2,JWValue>, +direct: Bool) -> String:
  "callOwned(get(G," ++ j_quote(name) ++ "),[" ++ jw_emit_values(args, direct) ++ "])"
