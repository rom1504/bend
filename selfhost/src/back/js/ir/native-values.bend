# Only JWNative values inside an already admitted complete private graph reach
# this emitter. j_map_native_string proves the canonical two-String signature;
# the public root still checks the native descriptor and all host dependencies.
# The two operands were lowered in source order. The JS + evaluates each once,
# without a temporary runtime argument vector or generic descriptor dispatch.
@unsafe
def jw_emit_native_value(+name: String, +args: List<&2,JWValue>, +direct: Bool) -> String:
  match args:
    case Con{left, Con{right, Nil{}}}:
      kc(String, String.eq(name, "String.append"), u =>
        "(/* private String.append */(" ++ jw_emit_value(left, direct) ++ ")+(" ++
          jw_emit_value(right, direct) ++ "))", u => jw_emit_native_fallback(name, args, direct))
    case other: jw_emit_native_fallback(name, args, direct)

@unsafe
def jw_emit_native_fallback(+name: String, +args: List<&2,JWValue>, +direct: Bool) -> String:
  "callOwned(get(G," ++ j_quote(name) ++ "),[" ++ jw_emit_values(args, direct) ++ "])"
