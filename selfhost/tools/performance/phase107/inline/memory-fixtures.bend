# A general pointer-field traversal with independent writes to counters/payload.
# Alias and mutation flags construct separate graphs before evaluation.
@unsafe
def nx_m_loop_fixture(+alias: Bool, +mutates: Bool) -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("box"), nx_pp("data"), nx_pp("p"), nx_p("i"), nx_p("before"), nx_p("after"), nx_p("payload"), nx_p("sum")],
    nx_i_join([
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(15))},
      NxSet{"box", NxAlloc{nx_u(32)}},
      NxSet{"data", nx_choose(NxExpr, alias, u => nx_v("box"), u => NxAlloc{nx_u(32)})},
      NxStore{NxPtr{}, nx_v("box"), 8, nx_v("data")},
      NxStore{NxU32{}, nx_v("box"), 0, nx_v("seed")},
      NxStore{NxU32{}, nx_v("data"), 16, nx_v("seed")},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), nx_i_join([
        NxSet{"p", NxLoad{NxPtr{}, nx_v("box"), 8}},
        NxSet{"before", NxLoad{NxU32{}, nx_v("box"), 0}},
        NxStore{NxU32{}, nx_v("p"), 0, nx_v("i")},
        NxSet{"after", NxLoad{NxU32{}, nx_v("box"), 0}},
        NxSet{"payload", NxLoad{NxU32{}, nx_v("p"), 16}},
        NxSet{"sum", nx_b("add", nx_v("sum"), nx_b("add", nx_v("before"), nx_b("add", nx_v("after"), nx_v("payload"))))},
        NxStore{NxU32{}, nx_v("box"), 0, nx_v("i")}],
        nx_i_join(nx_choose(List<&2, NxStmt>, mutates, u => [NxStore{NxU32{}, nx_v("p"), 16, nx_v("i")}], u => []),
          [NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]))}],
      nx_i_join(nx_choose(List<&2, NxStmt>, alias, u => [], u => [NxFree{nx_v("data")}]),
        [NxFree{nx_v("box")}, NxReturn{nx_v("sum")}]))}]}

def nx_m_overlap_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), NxParam{"wide", NxU64{}}], [
      NxSet{"p", NxAlloc{nx_u(8)}}, NxStore{NxU64{}, nx_v("p"), 0, NxConst{NxU64{}, 0}},
      NxStore{NxU32{}, nx_v("p"), 4, nx_b("xor", nx_v("n"), nx_v("seed"))},
      NxSet{"wide", NxLoad{NxU64{}, nx_v("p"), 0}}, NxFree{nx_v("p")},
      NxReturn{nx_b("eq", nx_v("wide"), NxConst{NxU64{}, 0})}]}]}

def nx_m_dependency_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("value")], [
    NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")},
    NxSet{"seed", nx_b("add", nx_v("seed"), nx_u(1))},
    NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")}, NxReturn{nx_v("value")}]}]}

def nx_m_reassign_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("a"), nx_pp("b"), nx_pp("saved"), nx_p("x"), nx_p("y")], [
      NxSet{"a", NxAlloc{nx_u(4)}}, NxSet{"b", NxAlloc{nx_u(4)}},
      NxStore{NxU32{}, nx_v("a"), 0, nx_v("seed")}, NxStore{NxU32{}, nx_v("b"), 0, nx_v("n")},
      NxSet{"saved", nx_v("a")}, NxSet{"a", nx_v("b")},
      NxSet{"x", NxLoad{NxU32{}, nx_v("saved"), 0}}, NxSet{"y", NxLoad{NxU32{}, nx_v("a"), 0}},
      NxFree{nx_v("saved")}, NxFree{nx_v("b")}, NxReturn{nx_b("xor", nx_v("x"), nx_v("y"))}]}]}

def nx_m_zero_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("value")], [
    NxWhile{nx_b("and", nx_v("n"), nx_u(1)), [
      NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxSet{"n", nx_u(0)}]},
    NxReturn{nx_b("add", nx_v("value"), nx_v("seed"))}]}]}

def nx_m_call_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"write", [nx_pp("p"), nx_p("n")], NxU32{}, [], [NxStore{NxU32{}, nx_v("p"), 0, nx_v("n")}, NxReturn{nx_u(0)}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("value")], [
      NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")},
      NxSet{"value", NxCall{"write", [nx_v("p"), nx_v("n")]}},
      NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")}, NxReturn{nx_v("value")}]}]}

def nx_m_free_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("value")], [
    NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")}, NxFree{nx_v("p")},
    NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("n")},
    NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")}, NxReturn{nx_v("value")}]}]}

def nx_m_selfassign_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), nx_pp("old"), nx_pp("child"), nx_p("value")], [
      NxSet{"p", NxAlloc{nx_u(8)}}, NxSet{"old", nx_v("p")}, NxSet{"child", NxAlloc{nx_u(4)}},
      NxStore{NxPtr{}, nx_v("p"), 0, nx_v("child")}, NxStore{NxU32{}, nx_v("child"), 0, nx_v("seed")},
      NxSet{"p", NxLoad{NxPtr{}, nx_v("p"), 0}},
      NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("old")}, NxFree{nx_v("p")}, NxReturn{nx_v("value")}]}]}

# First probe resolves p through a preheader field; the field is then written.
# Removing that fact makes the second probe's p-store unknown: refuse the loop.
def nx_m_second_probe_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("box"), nx_pp("first"), nx_pp("later"), nx_pp("p"), nx_p("i"), nx_p("a"), nx_p("b")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(15))},
      NxSet{"box", NxAlloc{nx_u(8)}}, NxSet{"first", NxAlloc{nx_u(4)}}, NxSet{"later", NxAlloc{nx_u(4)}},
      NxStore{NxPtr{}, nx_v("box"), 0, nx_v("first")}, NxStore{NxU32{}, nx_v("first"), 0, nx_v("seed")},
      NxStore{NxU32{}, nx_v("later"), 0, nx_b("add", nx_v("seed"), nx_u(1))},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"p", NxLoad{NxPtr{}, nx_v("box"), 0}}, NxStore{NxPtr{}, nx_v("box"), 0, nx_v("later")},
        NxStore{NxU32{}, nx_v("p"), 0, nx_v("i")}, NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxSet{"a", NxLoad{NxU32{}, nx_v("first"), 0}}, NxSet{"b", NxLoad{NxU32{}, nx_v("later"), 0}},
      NxFree{nx_v("box")}, NxFree{nx_v("first")}, NxFree{nx_v("later")}, NxReturn{nx_b("add", nx_b("mul", nx_v("a"), nx_u(33)), nx_v("b"))}]}]}

def nx_m_early_return_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("value")], [
    NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")},
    NxWhile{nx_b("and", nx_v("n"), nx_u(1)), [
      NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")}, NxReturn{nx_v("value")}]},
    NxFree{nx_v("p")}, NxReturn{nx_v("seed")}]}]}

@unsafe
def nx_m_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_distinct"), u => Some{nx_m_loop_fixture(False{}, False{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_alias"), u => Some{nx_m_loop_fixture(True{}, False{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_payload"), u => Some{nx_m_loop_fixture(False{}, True{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_alias_payload"), u => Some{nx_m_loop_fixture(True{}, True{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_overlap"), u => Some{nx_m_overlap_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_dependency"), u => Some{nx_m_dependency_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_reassign"), u => Some{nx_m_reassign_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_zero"), u => Some{nx_m_zero_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_call"), u => Some{nx_m_call_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_free"), u => Some{nx_m_free_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_selfassign"), u => Some{nx_m_selfassign_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_second_probe"), u => Some{nx_m_second_probe_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "memory_early_return"), u => Some{nx_m_early_return_fixture()}, u => None{})))))))))))))
