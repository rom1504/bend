# Analysis-only projection of the exact certified predicate/select emitter.
# Original statements, facts, frame slots and emitted stores stay authoritative.
# No row returned by these helpers reaches the instruction emitter.
def x195_sp_enabled() -> Bool: True{}

@unsafe
def x195_sp_copies(names: List<&2,String>, +typ: N111Type, previous: String) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{P113DScalar{N111Set{name,typ,N111Local{previous}}},x195_sp_copies(rest,typ,name)}

# Both choices are read before the first publication. The synthetic operation
# has the same interference event, not the runtime value, of the selected copy.
@unsafe
def x195_sp_choices(names: List<&2,String>, +typ: N111Type, yes: N111Value, no: N111Value) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{P113DScalar{N111Bin{name,typ,"or",yes,no}},x195_sp_copies(rest,typ,name)}

@unsafe
def x195_sp_rows(plan: X194Select) -> List<&2,P113DStmt>:
  match plan:
    case X194Select{rest,typ,op,left,right,invert,X191SelectPlan{st,yes,no,names},removed}:
      Con{P113DScalar{N111Bin{"__x181_select_compare",typ,op,left,right}},x195_sp_choices(names,st,yes,no)}

@unsafe
def x195_sp_pick(pick: Maybe<&2,X194Select>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match pick:
    case Some{+plan}:
      match plan:
        case X194Select{rest,typ,op,left,right,invert,selected,names}:
          nt_choose(List<&2,P113DStmt>,x194_ps_allowed(names,facts),
            u => nt_append(P113DStmt,x195_sp_rows(plan),x191_placement(rest,facts)),
            u => x192_shared_placement(x192_shared_pick(body,facts),body,facts))
    case None{}: x192_shared_placement(x192_shared_pick(body,facts),body,facts)
