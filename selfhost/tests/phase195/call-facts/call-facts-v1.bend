# Optional local-word facts across calls; no memory facts or result-width inference.
# Compose with branch-facts-v2.bend, replacing only x190_v_plain via hook-v1.bend.
def x195cf_enabled() -> Bool: True{}

@unsafe
def x195cf_kill_names(names: List<&2,String>, state: X190Values) -> X190Values:
  match names:
    case Nil{}: state
    case Con{name,rest}: x195cf_kill_names(rest,x190_v_written(name,False{},state))

@unsafe
def x195cf_after_call(names: List<&2,String>, state: X190Values) -> X190Values:
  nt_choose(X190Values,x195cf_enabled(),
    u => x195cf_kill_names(names,state),u => x190_v_empty())

@unsafe
def x195cf_scalar(stmt: N111Stmt, +state: X190Values) -> X190ValueStep:
  match stmt:
    case N111Call{+name,typ,symbol,args}:
      X190ValueStep{P113DScalar{N111Call{name,typ,symbol,x190_v_args(args,state)}},
        x195cf_after_call([name],state)}
    case _: x190_v_scalar(stmt,state)
