def nx_r_leaf(+name: String) -> NxFunction:
  NxFunction{name, [nx_p("n"), nx_p("seed")], NxU32{}, [], [NxReturn{nx_b("add", nx_v("n"), nx_v("seed"))}]}

def nx_r_direct_fixture() -> NxProgram:
  NxProgram{"main", [nx_r_leaf("unused"), nx_r_leaf("leaf"),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [NxReturn{NxCall{"middle", [nx_v("n"), nx_v("seed")]}}]},
    NxFunction{"middle", [nx_p("n"), nx_p("seed")], NxU32{}, [], [NxReturn{NxCall{"leaf", [nx_v("n"), nx_v("seed")]}}]}]}

def nx_r_stored_fixture() -> NxProgram:
  NxProgram{"main", [nx_r_leaf("unused"), nx_r_leaf("target"),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("cell"), nx_pp("callable"), nx_p("value")], [
      NxSet{"cell", NxAlloc{nx_u(8)}}, NxStore{NxPtr{}, nx_v("cell"), 0, NxFunc{"target"}},
      NxSet{"callable", NxLoad{NxPtr{}, nx_v("cell"), 0}},
      NxSet{"value", NxICall{nx_v("callable"), [nx_v("n"), nx_v("seed")], [NxU32{}, NxU32{}], NxU32{}}},
      NxFree{nx_v("cell")}, NxReturn{nx_v("value")}]}]}

def nx_r_returned_fixture() -> NxProgram:
  NxProgram{"main", [nx_r_leaf("unused"),
    NxFunction{"factory", [], NxPtr{}, [], [NxReturn{NxFunc{"target"}}]}, nx_r_leaf("target"),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("callable")], [
      NxSet{"callable", NxCall{"factory", []}},
      NxReturn{NxICall{nx_v("callable"), [nx_v("n"), nx_v("seed")], [NxU32{}, NxU32{}], NxU32{}}}]}]}

def nx_r_dead_cycle_fixture() -> NxProgram:
  NxProgram{"main", [nx_r_leaf("main"),
    NxFunction{"dead_a", [], NxU32{}, [], [NxReturn{NxCall{"dead_b", []}}]},
    NxFunction{"dead_b", [], NxU32{}, [], [NxReturn{NxCall{"dead_a", []}}]}]}

def nx_r_branch_fixture() -> NxProgram:
  NxProgram{"main", [nx_r_leaf("unused"), nx_r_leaf("target"),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
      NxIf{nx_u(0), [NxReturn{NxCall{"target", [nx_v("n"), nx_v("seed")]}}], [NxReturn{nx_b("add", nx_v("n"), nx_v("seed"))}]}]}]}

@unsafe
def nx_r_cap_helpers(+n: U32) -> List<&2, NxFunction>:
  nx_choose(List<&2, NxFunction>, U32.is_eq(n, 0), u => [],
    u => Con{nx_r_leaf("unused" ++ U32.show(n)), nx_r_cap_helpers(U32.sub(n, 1))})

@unsafe
def nx_r_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_direct"), u => Some{nx_r_direct_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_stored"), u => Some{nx_r_stored_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_returned"), u => Some{nx_r_returned_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_dead_cycle"), u => Some{nx_r_dead_cycle_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_branch"), u => Some{nx_r_branch_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_cycle"), u => Some{nx_i_cycle_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reach_cap"),
    u => Some{NxProgram{"main", Con{nx_r_leaf("main"), nx_r_cap_helpers(256)}}}, u => None{})))))))
