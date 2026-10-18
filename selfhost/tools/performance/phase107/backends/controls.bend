# Additional backend ABI/control witnesses. All four graphs must satisfy
# nx_verify before emission. They are controls, not performance workloads.
def nxq_u64_const(value: U32) -> NxExpr:
  NxConst{NxU64{}, value}

def nxq_u64_param(name: String) -> NxParam:
  NxParam{name, NxU64{}}

def nxq_control_u64() -> NxProgram:
  NxProgram{"main", [
    NxFunction{"wide", [nxq_u64_param("value"), nxq_u64_param("count")], NxU64{}, [], [
      NxReturn{nx_b("xor", nx_b("shl", nx_v("value"), nx_v("count")), nx_b("lshr", nx_v("value"), nx_v("count")))}]},
    NxFunction{"main", [nxq_u64_param("n"), nxq_u64_param("seed")], NxU32{}, [nxq_u64_param("value")], [
      NxSet{"value", NxCall{"wide", [nx_v("seed"), nx_v("n")]}},
      NxReturn{nx_b("add",
        nx_b("add", nx_b("eq", nx_v("value"), nxq_u64_const(0)),
          nx_b("mul", nx_u(2), nx_b("ult", nx_v("value"), nx_b("shl", nxq_u64_const(1), nxq_u64_const(63))))),
        nx_b("add", nx_b("mul", nx_u(4), nx_b("eq", nx_b("lshr", nx_v("seed"), nxq_u64_const(32)), nxq_u64_const(4294967295))),
          nx_b("mul", nx_u(8), nx_b("eq", nx_b("add", nx_v("seed"), nxq_u64_const(1)), nxq_u64_const(0)))))}]}]}

def nxq_control_ptr_offset() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("p"), nx_pp("q"), nx_pp("r"), nx_p("same"), nx_p("wrap")], [
      NxSet{"p", NxOffset{NxConst{NxPtr{}, 0}, nx_v("n")}},
      NxSet{"q", NxOffset{NxConst{NxPtr{}, 0}, nx_b("and", nx_v("n"), nx_u(2147483647))}},
      NxIf{nx_b("eq", nx_b("and", nx_v("n"), nx_u(2147483648)), nx_u(0)), [], [
        NxSet{"q", NxOffset{nx_v("q"), nx_u(1073741824)}},
        NxSet{"q", NxOffset{nx_v("q"), nx_u(1073741824)}}]},
      NxSet{"same", nx_b("eq", nx_v("p"), nx_v("q"))},
      NxSet{"p", NxOffset{nx_v("p"), nx_u(1)}},
      NxSet{"r", NxOffset{NxConst{NxPtr{}, 0}, nx_b("add", nx_v("n"), nx_u(1))}},
      NxSet{"wrap", nx_b("eq", nx_v("p"), nx_v("r"))},
      NxReturn{nx_b("add", nx_v("same"), nx_b("mul", nx_u(2), nx_v("wrap")))}]}]}

def nxq_control_zero_alloc() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("empty"), nx_pp("cell"), nx_pp("zero_ptr"), nx_p("zero_word"), nx_p("loaded"), nx_p("result")], [
      NxSet{"empty", NxAlloc{nx_u(0)}}, NxSet{"cell", NxAlloc{nx_u(4)}},
      NxSet{"loaded", NxLoad{NxU32{}, nx_v("cell"), 0}},
      NxSet{"result", nx_b("add", nx_b("eq", nx_v("empty"), NxConst{NxPtr{}, 0}),
        nx_b("add", nx_b("mul", nx_u(2), nx_b("eq", nx_v("loaded"), nx_u(0))),
          nx_b("add", nx_b("mul", nx_u(4), nx_b("eq", nx_v("zero_ptr"), NxConst{NxPtr{}, 0})),
            nx_b("mul", nx_u(8), nx_b("eq", nx_v("zero_word"), nx_u(0))))))},
      NxFree{nx_v("empty")}, NxFree{nx_v("cell")}, NxReturn{nx_v("result")}]}]}

def nxq_control_flow() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("i"), nx_p("sum")], [
    NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [
      NxIf{nx_b("eq", nx_v("seed"), nx_u(0)), [NxReturn{nx_u(11)}], [NxReturn{nx_u(13)}]}], []},
    NxSet{"n", nx_b("and", nx_v("n"), nx_u(31))},
    NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
      NxIf{nx_b("eq", nx_v("i"), nx_v("seed")), [NxReturn{nx_b("xor", nx_v("sum"), nx_u(2147483648))}], []},
      NxSet{"sum", nx_b("add", nx_v("sum"), nx_v("i"))}, NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
    NxReturn{nx_b("add", nx_v("sum"), nx_u(17))}]}]}

@unsafe
def nxq_control_cap_body(+count: U32) -> List<&2, NxStmt>:
  nx_choose(List<&2, NxStmt>, U32.is_eq(count, 0),
    u => [NxReturn{nx_b("add", nx_v("x"), nx_v("seed"))}],
    u => Con{NxSet{"x", nx_b("add", nx_v("x"), nx_u(1))}, nxq_control_cap_body(U32.sub(count, 1))})

@unsafe
def nxq_control_cap(+count: U32) -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("x")], nxq_control_cap_body(count)}]}

def nxq_control_entry_pointer() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("self")], [
    NxIf{nx_b("eq", nx_v("n"), nx_u(0)), [NxReturn{nx_v("seed")}], []},
    NxSet{"self", NxFunc{"main"}},
    NxReturn{NxICall{nx_v("self"), [nx_b("sub", nx_v("n"), nx_u(1)), nx_b("add", nx_v("seed"), nx_u(1))], [NxU32{}, NxU32{}], NxU32{}}}]}]}

@unsafe
def nxq_control(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_u64"), u => Some{nxq_control_u64()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_ptr_offset"), u => Some{nxq_control_ptr_offset()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_zero_alloc"), u => Some{nxq_control_zero_alloc()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_flow"), u => Some{nxq_control_flow()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_cap512"), u => Some{nxq_control_cap(127)}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_cap516"), u => Some{nxq_control_cap(128)}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "qbe_entry_pointer"), u => Some{nxq_control_entry_pointer()}, u => None{})))))))
