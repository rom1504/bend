# Independent call-shape controls. These are not performance training inputs.
def nx_i_mutating_helper() -> NxFunction:
  NxFunction{"mutate", [nx_p("x"), nx_p("y")], NxU32{}, [], [
    NxSet{"x", nx_b("add", nx_v("x"), nx_u(1))},
    NxReturn{nx_b("add", nx_b("mul", nx_v("x"), nx_u(10)), nx_v("y"))}]}

def nx_i_snapshot_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("x")], [
    NxSet{"x", nx_v("n")}, NxSet{"x", NxCall{"mutate", [nx_v("x"), nx_v("x")]}},
    NxReturn{nx_b("add", nx_v("x"), nx_v("seed"))}]}, nx_i_mutating_helper()]}

def nx_i_collision_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("p107_i0_v_x"), nx_p("x")], [
    NxSet{"p107_i0_v_x", nx_v("seed")}, NxSet{"x", NxCall{"mutate", [nx_v("n"), nx_v("n")]}},
    NxReturn{nx_b("add", nx_v("x"), nx_v("p107_i0_v_x"))}]}, nx_i_mutating_helper()]}

def nx_i_branch_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"branch", [nx_v("n"), nx_v("seed")]}}]},
    NxFunction{"branch", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value")], [
      NxSet{"value", nx_b("xor", nx_v("n"), nx_v("seed"))},
      NxIf{nx_b("ult", nx_v("n"), nx_u(10)), [NxReturn{nx_b("add", nx_v("value"), nx_u(1))}], [
        NxIf{nx_b("and", nx_v("seed"), nx_u(1)),
          [NxReturn{nx_b("mul", nx_v("value"), nx_u(3))}],
          [NxReturn{nx_b("sub", nx_v("value"), nx_u(7))}]}]}]}]}

# Same relation through a merge local, matching the checked KTerm lowerer.
def nx_i_merge_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"merge", [nx_v("n"), nx_v("seed")]}}]},
    NxFunction{"merge", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value"), nx_p("dest")], [
      NxSet{"value", nx_b("xor", nx_v("n"), nx_v("seed"))},
      NxIf{nx_b("ult", nx_v("n"), nx_u(10)), [NxSet{"dest", nx_b("add", nx_v("value"), nx_u(1))}], [
        NxIf{nx_b("and", nx_v("seed"), nx_u(1)),
          [NxSet{"dest", nx_b("mul", nx_v("value"), nx_u(3))}],
          [NxSet{"dest", nx_b("sub", nx_v("value"), nx_u(7))}]}]},
      NxReturn{nx_v("dest")}] }]}

def nx_i_reset_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("i"), nx_p("sum"), nx_p("value")], [
    NxSet{"sum", nx_v("seed")}, NxSet{"n", nx_b("and", nx_v("n"), nx_u(65535))},
    NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
      NxSet{"value", NxCall{"reset", [nx_b("and", nx_v("i"), nx_u(1))]}},
      NxSet{"sum", nx_b("add", nx_v("sum"), nx_v("value"))}, NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
    NxReturn{nx_v("sum")}]},
    NxFunction{"reset", [nx_p("flag")], NxU32{}, [nx_p("temporary")], [
      NxIf{nx_v("flag"), [NxSet{"temporary", nx_u(7)}, NxReturn{nx_v("temporary")}], [NxReturn{nx_v("temporary")}]}]}]}

def nx_i_nested_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"wrapper", [nx_v("n"), nx_v("seed")]}}]},
    NxFunction{"wrapper", [nx_p("a"), nx_p("b")], NxU32{}, [], [NxReturn{NxCall{"mutate", [nx_v("a"), nx_v("b")]}}]},
    nx_i_mutating_helper()]}

# Do not execute: the unchanged recursive call graph is a purity-refusal check.
def nx_i_cycle_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [NxReturn{NxCall{"cycle", [nx_v("n")]}}]},
    NxFunction{"cycle", [nx_p("n")], NxU32{}, [], [NxReturn{NxCall{"cycle", [nx_v("n")]}}]}]}

@unsafe
def nx_i_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "snapshot"), u => Some{nx_i_snapshot_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "collision"), u => Some{nx_i_collision_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "branch"), u => Some{nx_i_branch_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "merge"), u => Some{nx_i_merge_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reset"), u => Some{nx_i_reset_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "nested"), u => Some{nx_i_nested_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "cycle"), u => Some{nx_i_cycle_fixture()}, u => nx_workload(name))))))))
