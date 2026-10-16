# The existing fresh64 predicate asks whether any Var uses an ID in this
# inclusive interval. nc_occurs treats a Var as a leaf, even in malformed ASTs.
@unsafe
def nbc_range_clear(+t: KTerm, +low: U32, +high: U32) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Var"), u => U32.is_lt(ix(t), low) || U32.is_gt(ix(t), high), u => nbc_ranges_clear(ks(t), low, high))

@unsafe
def nbc_ranges_clear(ts: List<&2, KTerm>, +low: U32, +high: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, +rest}:
      nt_choose(Bool, nbc_range_clear(h, low, high), u => nbc_ranges_clear(rest, low, high), u => False{})

# Preserve nc_word's first-binding/sentinel semantics even on synthetic envs.
# Ordinary environments have no reserved IDs, so this is one linear traversal.
@unsafe
def nbc_env_clear(+env: List<&2, NC_Binding>, scan: List<&2, NC_Binding>, +low: U32, +high: U32) -> Bool:
  match scan:
    case Nil{}: True{}
    case Con{NC_Binding{+id, word, kind}, +rest}:
      nt_choose(Bool, U32.is_lt(id, low) || U32.is_gt(id, high), u => nbc_env_clear(env, rest, low, high), u =>
        nt_choose(Bool, p88_string_eq(nc_word(id, env), "NATIVE_UNBOUND_VARIABLE"), v => nbc_env_clear(env, rest, low, high), v => False{}))

@unsafe
def nbc_fresh(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> Bool:
  +low = nc_id(U32.add(n, 63))
  +high = nc_id(n)
  nt_choose(Bool, nbc_range_clear(body, low, high), u =>
    nt_choose(Bool, nbc_ranges_clear(args, low, high), v => nbc_env_clear(env, env, low, high), v => False{}), u => False{})
