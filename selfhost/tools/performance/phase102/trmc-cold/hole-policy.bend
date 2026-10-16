# The pending slot belongs to the preceding constructor, not the next value.
# Match ne_ctor_node's policy for hot=True, including user-constructor fallback.
@unsafe
def ntr_hole_policy(+ctor: String) -> String:
  +fallback = nt_choose(String, String.starts_with(ctor, "$ctor."),
    u => "#if NATIVE_COLD_USER_CTORS\nnf_out[4] = 0;\n#else\nnf_out[4] = 1;\n#endif\n",
    u => "nf_out[4] = 1;\n")
  "#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_" ++ nt_cid(ctor) ++ "\nnf_out[4] = 0;\n#else\n" ++ fallback ++ "#endif\n"
