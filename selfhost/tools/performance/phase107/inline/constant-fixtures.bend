# Runtime inputs remain dynamic. Fixture names never enter optimization logic.
def nx_cp_invariant_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_p("i"), nx_p("counter"), nx_p("sum")], [
      NxSet{"counter", nx_u(1)}, NxSet{"sum", nx_v("seed")},
      NxWhile{nx_b("ult", nx_v("i"), nx_b("and", nx_v("n"), nx_u(31))), [
        NxSet{"counter", nx_b("add", nx_v("counter"), nx_u(1))},
        NxSet{"sum", nx_b("add", nx_v("sum"), nx_v("counter"))},
        NxSet{"counter", nx_b("sub", nx_v("counter"), nx_u(1))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxReturn{nx_b("xor", nx_v("sum"), nx_v("counter"))}]}]}

def nx_cp_change_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("i")], [
    NxWhile{nx_b("ult", nx_v("i"), nx_b("and", nx_v("n"), nx_u(31))), [
      NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
    NxReturn{nx_b("add", nx_v("i"), nx_v("seed"))}]}]}

def nx_cp_join_fixture(+same: Bool) -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value")], [
    NxIf{nx_b("and", nx_v("n"), nx_u(1)), [NxSet{"value", nx_u(7)}],
      [NxSet{"value", nx_u(nx_choose(U32, same, u => 7, u => 9))}]},
    NxReturn{nx_b("add", nx_v("value"), nx_v("seed"))}]}]}

def nx_cp_snapshot_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value"), nx_p("saved")], [
    NxSet{"value", nx_u(1)}, NxSet{"saved", nx_v("value")}, NxSet{"value", nx_v("seed")},
    NxReturn{nx_b("add", nx_v("saved"), nx_v("value"))}]}]}

def nx_cp_effect_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"identity", [nx_p("value")], NxU32{}, [], [NxReturn{nx_v("value")}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("loaded"), nx_p("called")], [
      NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")},
      NxSet{"loaded", NxLoad{NxU32{}, nx_v("p"), 0}},
      NxSet{"called", NxCall{"identity", [nx_v("loaded")]}},
      NxStore{NxU32{}, nx_v("p"), 0, nx_v("n")}, NxFree{nx_v("p")},
      NxReturn{nx_b("add", nx_v("loaded"), nx_v("called"))}]}]}

def nx_cp_overflow_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value")], [
    NxSet{"value", nx_u(4294967295)}, NxSet{"value", nx_b("add", nx_v("value"), nx_u(1))},
    NxReturn{nx_b("add", nx_v("value"), nx_v("seed"))}]}]}

def nx_cp_u64_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [NxParam{"wide", NxU64{}}], [
    NxSet{"wide", NxConst{NxU64{}, 4294967295}},
    NxSet{"wide", nx_b("add", nx_v("wide"), NxConst{NxU64{}, 1})},
    NxReturn{nx_b("eq", nx_v("wide"), NxConst{NxU64{}, 0})}]}]}

def nx_cp_nested_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_p("i"), nx_p("j"), nx_p("value")], [
      NxSet{"value", nx_v("seed")},
      NxWhile{nx_b("ult", nx_v("i"), nx_b("and", nx_v("n"), nx_u(7))), [
        NxSet{"j", nx_u(0)},
        NxWhile{nx_b("ult", nx_v("j"), nx_u(3)), [
          NxSet{"value", nx_b("add", nx_v("value"), nx_u(1))},
          NxSet{"j", nx_b("add", nx_v("j"), nx_u(1))}]},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]}, NxReturn{nx_v("value")}]}]}

# More than one header iteration is necessary: b loses its fact before a.
def nx_cp_cascade_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_p("i"), nx_p("a"), nx_p("b")], [
      NxWhile{nx_b("ult", nx_v("i"), nx_b("and", nx_v("n"), nx_u(31))), [
        NxSet{"a", nx_v("b")}, NxSet{"b", nx_b("add", nx_v("i"), nx_u(1))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxReturn{nx_b("add", nx_v("seed"), nx_b("add", nx_v("a"), nx_b("mul", nx_u(2), nx_v("b"))))}]}]}

# Parameter facts must not be zero-initialized; assigning one later can make it known.
def nx_cp_parameter_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("old")], [
    NxSet{"old", nx_v("n")}, NxSet{"n", nx_u(5)},
    NxReturn{nx_b("add", nx_b("add", nx_v("old"), nx_v("n")), nx_v("seed"))}]}]}

def nx_cp_return_arm_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value")], [
    NxIf{nx_b("and", nx_v("n"), nx_u(1)),
      [NxSet{"value", nx_u(7)}, NxReturn{nx_b("add", nx_v("value"), nx_v("seed"))}],
      [NxSet{"value", nx_u(9)}]},
    NxReturn{nx_b("add", nx_v("value"), nx_v("seed"))}]}]}

@unsafe
def nx_cp_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_invariant"), u => Some{nx_cp_invariant_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_change"), u => Some{nx_cp_change_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_join_equal"), u => Some{nx_cp_join_fixture(True{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_join_different"), u => Some{nx_cp_join_fixture(False{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_snapshot"), u => Some{nx_cp_snapshot_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_effect"), u => Some{nx_cp_effect_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_overflow"), u => Some{nx_cp_overflow_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_u64"), u => Some{nx_cp_u64_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_nested"), u => Some{nx_cp_nested_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_cascade"), u => Some{nx_cp_cascade_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_parameter"), u => Some{nx_cp_parameter_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "constant_return_arm"), u => Some{nx_cp_return_arm_fixture()}, u => None{}))))))))))))
