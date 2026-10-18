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

def nx_t_sum_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"sum", [nx_v("n"), nx_v("seed")]}}]},
    NxFunction{"sum", [nx_p("n"), nx_p("sum")], NxU32{}, [nx_p("call"), nx_p("result")], [
      NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxSet{"result", nx_v("sum")}], [
        NxSet{"call", NxCall{"sum", [nx_b("sub", nx_v("n"), nx_u(1)), nx_b("add", nx_v("sum"), nx_v("n"))]}},
        NxSet{"result", nx_v("call")}]}, NxReturn{nx_v("result")}] }]}

def nx_t_snapshot_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"fib", [nx_b("and", nx_v("n"), nx_u(31)), nx_v("seed"), nx_b("add", nx_v("seed"), nx_u(1))]}}]},
    NxFunction{"fib", [nx_p("n"), nx_p("x"), nx_p("y")], NxU32{}, [], [
      NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("x")}], [
        NxReturn{NxCall{"fib", [nx_b("sub", nx_v("n"), nx_u(1)), nx_v("y"), nx_b("add", nx_v("x"), nx_v("y"))]}}]}]}]}

def nx_t_reset_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"count", [nx_b("and", nx_v("n"), nx_u(65535)), nx_v("seed"), nx_u(0)]}}]},
    NxFunction{"count", [nx_p("n"), nx_p("sum"), nx_p("flag")], NxU32{}, [nx_p("temporary")], [
      NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("sum")}], [
        NxIf{nx_v("flag"), [NxSet{"temporary", nx_u(7)}], []},
        NxReturn{NxCall{"count", [nx_b("sub", nx_v("n"), nx_u(1)), nx_b("add", nx_v("sum"), nx_v("temporary")), nx_b("xor", nx_v("flag"), nx_u(1))]}}]}]}]}

# Terminates for small inputs, but recursive result is consumed: must refuse.
def nx_t_nontail_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"nontail", [nx_b("and", nx_v("n"), nx_u(31)), nx_v("seed")]}}]},
    NxFunction{"nontail", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("value")], [
      NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("seed")}], [
        NxSet{"value", NxCall{"nontail", [nx_b("sub", nx_v("n"), nx_u(1)), nx_v("seed")]}},
        NxReturn{nx_b("add", nx_v("value"), nx_u(1))}]}]}]}

# Deliberately unsupported early-return/dead-tail structure, not a DCE pass.
def nx_t_dead_tail_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxIf{nx_v("n"), [NxReturn{nx_v("n")}], [NxReturn{nx_v("seed")}]},
    NxReturn{NxCall{"main", [nx_v("n"), nx_v("seed")]}}]}]}

# An existing loop forbids this pass, even if its condition is zero.
def nx_t_loop_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxWhile{nx_u(0), []},
    NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("seed")}], [
      NxReturn{NxCall{"main", [nx_b("sub", nx_v("n"), nx_u(1)), nx_v("seed")]}}]}]}]}

def nx_t_pointer_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [NxParam{"pointer", NxPtr{}}], [
    NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("seed")}], [
      NxReturn{NxCall{"main", [nx_b("sub", nx_v("n"), nx_u(1)), nx_v("seed")]}}]}]}]}

def nx_t_mutual_helper(+name: String, +next: String) -> NxFunction:
  NxFunction{name, [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("seed")}], [
      NxReturn{NxCall{next, [nx_b("sub", nx_v("n"), nx_u(1)), nx_b("add", nx_v("seed"), nx_u(1))]}}]}]}

def nx_t_mutual_fixture() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{NxCall{"mutual_a", [nx_b("and", nx_v("n"), nx_u(31)), nx_v("seed")]}}]},
    nx_t_mutual_helper("mutual_a", "mutual_b"), nx_t_mutual_helper("mutual_b", "mutual_a")]}

@unsafe
def nx_i_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "snapshot"), u => Some{nx_i_snapshot_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "collision"), u => Some{nx_i_collision_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "branch"), u => Some{nx_i_branch_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "merge"), u => Some{nx_i_merge_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "reset"), u => Some{nx_i_reset_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "nested"), u => Some{nx_i_nested_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "cycle"), u => Some{nx_i_cycle_fixture()}, u => nx_t_fixture(name))))))))

@unsafe
def nx_t_fixture(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_sum"), u => Some{nx_t_sum_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_snapshot"), u => Some{nx_t_snapshot_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_reset"), u => Some{nx_t_reset_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_nontail"), u => Some{nx_t_nontail_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_dead"), u => Some{nx_t_dead_tail_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_existingloop"), u => Some{nx_t_loop_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_pointer"), u => Some{nx_t_pointer_fixture()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail_mutual"), u => Some{nx_t_mutual_fixture()}, u => nx_workload(name)))))))))
