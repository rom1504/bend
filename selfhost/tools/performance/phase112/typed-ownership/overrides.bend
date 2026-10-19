# Five exact declaration overrides; source telescope and alias facts are reused.

@unsafe
def p111_extend(+book: List<&2, KDef>, +body: KTerm, +base: P111Code, +name: String, +arity: U32) -> P111Code:
  +params = nk_typed_bindings(nd_entry_params(arity, p111_fresh(base)), nf_worker_kinds(book, name, arity))
  nt_choose(P111Code, U32.is_eq(arity, 0), u => base,
    u => p111_entry_join(base, p111_lower(book, nd_reapply(body, nd_entry_args(params)), params, U32.add(p111_fresh(base), arity)), nc_ref_name(book, name), params))

@unsafe
def p111_bind_value(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = nc_uses(body)
      +held = nc_live_uses(env, uses)
      +rest = p111_lower(book, body, nt_append(NC_Binding, held, [nk_binding(id, value, env)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), rest),
        u => p111_fail(error, n))

@unsafe
def p112_liveness_value(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = p112_liveness_uses(rest)
      +held = nc_live_uses(env, uses)
      +body = p112_liveness_lower(book, rest, nt_append(NC_Binding, held, [nk_binding(id, value, env)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), body),
        u => p111_fail(error, n))

@unsafe
def p111_keep(env: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, N111Stmt>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, nc_uses_has(uses, id) && Bool.not(p112to_nonowning(kind)), u => Con{N111Call{word, N111U64{}, "p111_rt_keep", [p111_state(), p111_word(N111Local{word})]}, p111_keep(rest, uses)}, u => p111_keep(rest, uses))

@unsafe
def p111_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P111Partition) -> P111Partition:
  match parts:
    case P111Partition{+live, +drop}:
      nt_choose(P111Partition, used, u => P111Partition{Con{NC_Binding{id, word, kind}, live}, drop}, u => nt_choose(P111Partition, p112to_nonowning(kind), v => P111Partition{live, drop}, v => P111Partition{live, Con{N111Call{"ignored", N111U64{}, "p111_rt_sink", [p111_state(), p111_word(N111Local{word})]}, drop}}))
