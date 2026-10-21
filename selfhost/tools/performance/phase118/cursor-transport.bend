# Separate necessary transport whitelist update. Both cursor helpers use only
# state->e and program metadata; no register-bank read/write or transition.
# Prefix output is a verified non-state local allocation.
@unsafe
def p118z_runtime(+symbol: String) -> Bool:
  Bool.not(List.is_empty(&2,U32,p111v_signature(symbol))) ||
    String.eq(symbol,"p113_rt_array_pair") || String.eq(symbol,"p118_rt_extend") ||
    String.eq(symbol,"p118_rt_finish") || String.eq(symbol,"p118_rt_borrow_fields") ||
    String.eq(symbol,"p118_rt_borrow_scalar_safe") || String.eq(symbol,"p118_rt_extend_cursor") ||
    String.eq(symbol,"p118_rt_finish_cursor")
