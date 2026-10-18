# Memory semantics witnesses; all inputs are U32, allocation lifetimes are explicit.
def nx_l_observe_alias() -> NxFunction:
  NxFunction{"observe", [nx_pp("a"), nx_pp("b"), nx_p("value")], NxU32{}, [nx_p("before"), nx_p("after")], [
    NxSet{"before", NxLoad{NxU32{}, nx_v("a"), 0}},
    NxStore{NxU32{}, nx_v("a"), 0, nx_v("value")},
    NxSet{"after", NxLoad{NxU32{}, nx_v("b"), 0}},
    NxReturn{nx_b("add", nx_b("mul", nx_v("before"), nx_u(33)), nx_v("after"))}]}

def nx_l_alias_fixture(+alias: Bool) -> NxProgram:
  NxProgram{"main", [nx_l_observe_alias(),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("a"), nx_pp("b"), nx_p("value"), nx_p("after")], [
      NxSet{"a", NxAlloc{nx_u(4)}}, NxSet{"b", NxAlloc{nx_u(4)}},
      NxStore{NxU32{}, nx_v("a"), 0, nx_v("seed")},
      NxStore{NxU32{}, nx_v("b"), 0, nx_b("add", nx_v("seed"), nx_u(1))},
      NxSet{"value", NxCall{"observe", [nx_v("a"), nx_choose(NxExpr, alias, u => nx_v("a"), u => nx_v("b")), nx_v("n")]}},
      NxSet{"after", NxLoad{NxU32{}, nx_v("a"), 0}},
      NxFree{nx_v("a")}, NxFree{nx_v("b")}, NxReturn{nx_b("xor", nx_v("value"), nx_v("after"))}]}]}

def nx_l_return_pointer_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"interior", [nx_pp("p"), nx_p("offset"), nx_p("value")], NxPtr{}, [], [
      NxSet{"p", NxOffset{nx_v("p"), nx_v("offset")}},
      NxStore{NxU32{}, nx_v("p"), 0, nx_v("value")}, NxReturn{nx_v("p")}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("base"), nx_pp("part"), nx_p("value")], [
      NxSet{"base", NxAlloc{nx_u(8)}},
      NxSet{"part", NxCall{"interior", [nx_v("base"), nx_u(4), nx_b("add", nx_v("n"), nx_v("seed"))]}},
      NxSet{"value", NxLoad{NxU32{}, nx_v("part"), 0}}, NxFree{nx_v("base")}, NxReturn{nx_v("value")}]}]}

def nx_l_store_pointer_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"install", [nx_pp("cell"), nx_pp("target"), nx_p("value")], NxU32{}, [], [
      NxStore{NxPtr{}, nx_v("cell"), 0, nx_v("target")},
      NxSet{"target", NxOffset{nx_v("target"), nx_u(4)}},
      NxStore{NxU32{}, nx_v("target"), 0, nx_v("value")}, NxReturn{nx_u(0)}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("cell"), nx_pp("base"), nx_pp("saved"), nx_p("value")], [
      NxSet{"cell", NxAlloc{nx_u(8)}}, NxSet{"base", NxAlloc{nx_u(8)}},
      NxSet{"value", NxCall{"install", [nx_v("cell"), nx_v("base"), nx_b("xor", nx_v("n"), nx_v("seed"))]}},
      NxSet{"saved", NxLoad{NxPtr{}, nx_v("cell"), 0}},
      NxSet{"value", NxLoad{NxU32{}, nx_v("saved"), 4}},
      NxFree{nx_v("cell")}, NxFree{nx_v("base")}, NxReturn{nx_v("value")}]}]}

def nx_l_alloc_free_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"scratch", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("cell"), nx_p("a"), nx_p("b")], [
      NxSet{"cell", NxAlloc{nx_u(8)}}, NxStore{NxU32{}, nx_v("cell"), 0, nx_v("n")},
      NxStore{NxU32{}, nx_v("cell"), 4, nx_v("seed")},
      NxSet{"a", NxLoad{NxU32{}, nx_v("cell"), 0}}, NxSet{"b", NxLoad{NxU32{}, nx_v("cell"), 4}},
      NxFree{nx_v("cell")}, NxReturn{nx_b("add", nx_b("mul", nx_v("a"), nx_u(3)), nx_v("b"))}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [NxReturn{NxCall{"scratch", [nx_v("n"), nx_v("seed")]}}]}]}

def nx_l_alloc_return_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"make", [nx_p("value")], NxPtr{}, [nx_pp("cell")], [
      NxSet{"cell", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("cell"), 0, nx_v("value")}, NxReturn{nx_v("cell")}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("cell"), nx_p("value")], [
      NxSet{"cell", NxCall{"make", [nx_b("add", nx_v("n"), nx_v("seed"))]}},
      NxSet{"value", NxLoad{NxU32{}, nx_v("cell"), 0}}, NxFree{nx_v("cell")}, NxReturn{nx_v("value")}]}]}

def nx_l_reset_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"observe", [nx_p("flag"), nx_pp("cell"), nx_p("seed")], NxU32{}, [nx_pp("saved"), nx_p("value")], [
      NxIf{nx_v("flag"), [NxSet{"saved", nx_v("cell")}], []},
      NxIf{nx_b("eq", nx_v("saved"), NxConst{NxPtr{}, 0}), [NxReturn{nx_v("seed")}], [
        NxStore{NxU32{}, nx_v("saved"), 0, nx_u(7)}, NxSet{"value", NxLoad{NxU32{}, nx_v("saved"), 0}}, NxReturn{nx_v("value")}]}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("cell"), nx_p("i"), nx_p("value"), nx_p("sum")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(65535))}, NxSet{"cell", NxAlloc{nx_u(4)}},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"value", NxCall{"observe", [nx_b("and", nx_v("i"), nx_u(1)), nx_v("cell"), nx_v("seed")]}},
        NxSet{"sum", nx_b("add", nx_v("sum"), nx_v("value"))}, NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxFree{nx_v("cell")}, NxReturn{nx_v("sum")}]}]}

def nx_l_branch_fixture() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"update", [nx_pp("cell"), nx_p("flag"), nx_p("value")], NxU32{}, [nx_p("answer")], [
      NxIf{nx_v("flag"), [NxStore{NxU32{}, nx_v("cell"), 0, nx_v("value")}], [
        NxStore{NxU32{}, nx_v("cell"), 0, nx_b("add", nx_v("value"), nx_u(1))}]},
      NxSet{"answer", NxLoad{NxU32{}, nx_v("cell"), 0}}, NxReturn{nx_v("answer")}]},
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("cell"), nx_p("answer")], [
      NxSet{"cell", NxAlloc{nx_u(4)}}, NxSet{"answer", NxCall{"update", [nx_v("cell"), nx_b("and", nx_v("n"), nx_u(1)), nx_v("seed")]}},
      NxFree{nx_v("cell")}, NxReturn{nx_v("answer")}]}]}

@unsafe
def nx_l_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_alias"), u => Some{nx_l_alias_fixture(True{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_distinct"), u => Some{nx_l_alias_fixture(False{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_return_pointer"), u => Some{nx_l_return_pointer_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_store_pointer"), u => Some{nx_l_store_pointer_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_alloc_free"), u => Some{nx_l_alloc_free_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_alloc_return"), u => Some{nx_l_alloc_return_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_reset"), u => Some{nx_l_reset_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "leaf_branch"), u => Some{nx_l_branch_fixture()}, u => None{}))))))))
