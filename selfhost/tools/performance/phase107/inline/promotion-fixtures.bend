# Scalar fields begin at typed zero, including zero-trip loops. The existing
# p107_p0_f0 name deliberately forces the generated field namespace to advance.
def nx_pr_zero_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), nx_p("i"), nx_p("value"), nx_p("p107_p0_f0")], [
      NxSet{"p107_p0_f0", nx_v("seed")}, NxSet{"n", nx_b("and", nx_v("n"), nx_u(15))},
      NxSet{"p", NxAlloc{nx_u(4)}}, NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}},
        NxStore{NxU32{}, nx_v("p"), 0, nx_b("add", nx_v("value"), nx_u(1))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")},
      NxReturn{nx_b("add", nx_v("value"), nx_v("p107_p0_f0"))}]}]}

def nx_pr_u64_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), nx_p("i"), NxParam{"wide", NxU64{}}], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(15))}, NxSet{"p", NxAlloc{nx_u(8)}},
      NxStore{NxU64{}, nx_v("p"), 0, NxConst{NxU64{}, 4294967295}},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"wide", NxLoad{NxU64{}, nx_v("p"), 0}},
        NxStore{NxU64{}, nx_v("p"), 0, nx_b("add", nx_v("wide"), NxConst{NxU64{}, 1})},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxSet{"wide", NxLoad{NxU64{}, nx_v("p"), 0}}, NxFree{nx_v("p")},
      NxReturn{nx_b("add", nx_b("eq", nx_v("wide"), NxConst{NxU64{}, 4294967295}),
        nx_b("mul", nx_u(2), nx_b("eq", nx_b("lshr", nx_v("wide"), NxConst{NxU64{}, 32}), NxConst{NxU64{}, 1})))}]}]}

def nx_pr_loop_alloc_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), nx_p("i"), nx_p("value"), nx_p("sum")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(15))},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")},
        NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")},
        NxSet{"sum", nx_b("add", nx_v("sum"), nx_v("value"))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]}, NxReturn{nx_v("sum")}]}]}

def nx_pr_offset_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), nx_pp("at"), nx_p("value")], [
      NxSet{"p", NxAlloc{nx_u(8)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("seed")},
      NxStore{NxU32{}, nx_v("p"), 4, nx_v("n")},
      NxSet{"at", NxOffset{nx_v("p"), nx_b("mul", nx_b("and", nx_v("n"), nx_u(1)), nx_u(4))}},
      NxSet{"value", NxLoad{NxU32{}, nx_v("at"), 0}}, NxFree{nx_v("p")}, NxReturn{nx_v("value")}]}]}

def nx_pr_alias_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("a"), nx_pp("b"), nx_p("before"), nx_p("after")], [
      NxSet{"a", NxAlloc{nx_u(4)}}, NxSet{"b", nx_v("a")},
      NxStore{NxU32{}, nx_v("a"), 0, nx_v("seed")}, NxSet{"before", NxLoad{NxU32{}, nx_v("a"), 0}},
      NxStore{NxU32{}, nx_v("b"), 0, nx_v("n")}, NxSet{"after", NxLoad{NxU32{}, nx_v("a"), 0}},
      NxFree{nx_v("a")}, NxReturn{nx_b("add", nx_b("mul", nx_v("before"), nx_u(33)), nx_v("after"))}]}]}

def nx_pr_pointer_store_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("box"), nx_pp("child"), nx_p("value")], [
      NxSet{"box", NxAlloc{nx_u(8)}}, NxSet{"child", NxAlloc{nx_u(4)}},
      NxStore{NxPtr{}, nx_v("box"), 0, nx_v("child")}, NxStore{NxU32{}, nx_v("child"), 0, nx_v("seed")},
      NxSet{"value", NxLoad{NxU32{}, nx_v("child"), 0}}, NxFree{nx_v("box")}, NxFree{nx_v("child")}, NxReturn{nx_v("value")}]}]}

def nx_pr_branch_alloc_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("p"), nx_p("value")], [
    NxSet{"value", nx_v("seed")},
    NxIf{nx_b("and", nx_v("n"), nx_u(1)), [
      NxSet{"p", NxAlloc{nx_u(4)}}, NxStore{NxU32{}, nx_v("p"), 0, nx_v("n")},
      NxSet{"value", NxLoad{NxU32{}, nx_v("p"), 0}}, NxFree{nx_v("p")}], []},
    NxReturn{nx_v("value")}]}]}

@unsafe
def nx_p_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_zero"), u => Some{nx_pr_zero_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_u64"), u => Some{nx_pr_u64_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_loop_alloc"), u => Some{nx_pr_loop_alloc_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_dynamic_offset"), u => Some{nx_pr_offset_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_alias"), u => Some{nx_pr_alias_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_pointer_store"), u => Some{nx_pr_pointer_store_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "promotion_branch_alloc"), u => Some{nx_pr_branch_alloc_fixture()}, u => nx_m_fixture(name))))))))
