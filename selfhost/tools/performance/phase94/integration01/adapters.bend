# Phase94 boundary: exact checked generic helper, concrete compiler bindings.
@unsafe
def nc_env_plan_hit(uses: NU_Set, binding: NC_Binding) -> Bool:
  match binding:
    case NC_Binding{id, word, kind}: nc_uses_has(uses, id)

@unsafe
def nc_env_plan_drop(binding: NC_Binding, suffix: String) -> String:
  match binding:
    case NC_Binding{id, word, kind}: "term_sink(e, " ++ word ++ ");\n" ++ suffix

@unsafe
def nc_env_plan_finish(parts: NPE_Part<NC_Binding, String>) -> NC_EnvPartition:
  match parts:
    case NPE_Part{live, drop}: NC_EnvPartition{live, drop}

@unsafe
def nc_env_extend(env: List<&2, NC_Binding>, uses: NU_Set, binding: NC_Binding) -> NC_EnvPartition:
  nc_env_plan_finish(npe_extend(~NC_Binding, ~NU_Set, ~String, ~nc_env_plan_hit, ~nc_env_plan_drop, uses, env, binding, ""))
