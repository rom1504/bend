# Workloads construct the IR directly; they are not a complete Bend frontend.
# n and seed are runtime arguments to each emitted library's common ABI.
def nx_u(value: U32) -> NxExpr:
  NxConst{NxU32{}, value}

def nx_v(name: String) -> NxExpr:
  NxVar{name}

def nx_b(op: String, a: NxExpr, b: NxExpr) -> NxExpr:
  NxBin{op, a, b}

def nx_p(name: String) -> NxParam:
  NxParam{name, NxU32{}}

def nx_pp(name: String) -> NxParam:
  NxParam{name, NxPtr{}}

# Exact algorithm slice from front/lexer.bend f_ascii_ident_code and
# f_ascii_space_code: unsigned U32 subtraction, folded ASCII, no Unicode loss.
def nx_ascii_ident() -> NxFunction:
  NxFunction{"ascii_ident", [nx_p("code")], NxU32{}, [], [NxReturn{
    nx_b("or",
      nx_b("or", nx_b("ult", nx_b("sub", nx_b("or", nx_v("code"), nx_u(32)), nx_u(97)), nx_u(26)), nx_b("ult", nx_b("sub", nx_v("code"), nx_u(48)), nx_u(10))),
      nx_b("or", nx_b("eq", nx_v("code"), nx_u(95)), nx_b("eq", nx_v("code"), nx_u(46))))}]}

def nx_ascii_space() -> NxFunction:
  NxFunction{"ascii_space", [nx_p("code")], NxU32{}, [], [NxReturn{
    nx_b("or", nx_b("eq", nx_v("code"), nx_u(32)), nx_b("ult", nx_b("sub", nx_v("code"), nx_u(9)), nx_u(5)))}]}

# The classifier control accepts the complete U32 codepoint domain at runtime.
def nx_classify() -> NxProgram:
  NxProgram{"main", [nx_ascii_ident(), nx_ascii_space(),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("a"), nx_p("b"), nx_p("c"), nx_p("d")], [
      NxSet{"a", NxCall{"ascii_ident", [nx_v("n")]}}, NxSet{"b", NxCall{"ascii_space", [nx_v("n")]}},
      NxSet{"c", NxCall{"ascii_ident", [nx_v("seed")]}}, NxSet{"d", NxCall{"ascii_space", [nx_v("seed")]}},
      NxReturn{nx_b("add", nx_b("add", nx_v("a"), nx_b("mul", nx_v("b"), nx_u(2))), nx_b("add", nx_b("mul", nx_v("c"), nx_u(4)), nx_b("mul", nx_v("d"), nx_u(8))))}]}]}

def nx_shift_control() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], [
    NxReturn{nx_b("xor", nx_b("shl", nx_v("seed"), nx_v("n")), nx_b("lshr", nx_v("seed"), nx_v("n")))}]}]}

def nx_reject_body(body: List<&2, NxStmt>) -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [], body}]}

@unsafe
def nx_rejection(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_var"), u => Some{nx_reject_body([NxReturn{nx_v("missing")}])}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_call"), u => Some{nx_reject_body([NxReturn{NxCall{"missing", []}}])}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_type"), u => Some{nx_reject_body([NxReturn{NxConst{NxPtr{}, 0}}])}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_effect"), u => Some{nx_reject_body([NxReturn{nx_b("add", NxLoad{NxU32{}, NxConst{NxPtr{}, 0}, 0}, nx_u(1))}])}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_return"), u => Some{nx_reject_body([NxSet{"n", nx_u(1)}])}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_operator"), u => Some{nx_reject_body([NxReturn{nx_b("unknown", nx_u(1), nx_u(2))}])}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_duplicate"),
    u => Some{NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("n")], [NxReturn{nx_u(0)}]}]}},
    u => nx_choose(Maybe<&2, NxProgram>, String.eq(name, "bad_identifier"),
      u => Some{NxProgram{"1entry", [NxFunction{"1entry", [nx_p("n"), nx_p("seed")], NxU32{}, [], [NxReturn{nx_v("n")}]}]}},
      u => None{}))))))))

def nx_text() -> NxProgram:
  NxProgram{"main", [nx_ascii_ident(), nx_ascii_space(),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
      [nx_pp("text"), nx_p("i"), nx_p("code"), nx_p("ident"), nx_p("space"), nx_p("hash")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(1048575))},
      NxSet{"text", NxAlloc{nx_b("mul", nx_v("n"), nx_u(4))}},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"code", nx_b("and", nx_b("add", nx_b("mul", nx_v("i"), nx_u(17)), nx_v("seed")), nx_u(127))},
        NxStore{NxU32{}, NxOffset{nx_v("text"), nx_b("mul", nx_v("i"), nx_u(4))}, 0, nx_v("code")},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxSet{"i", nx_u(0)}, NxSet{"hash", nx_b("xor", nx_u(2166136261), nx_v("seed"))},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"code", NxLoad{NxU32{}, NxOffset{nx_v("text"), nx_b("mul", nx_v("i"), nx_u(4))}, 0}},
        NxSet{"ident", NxCall{"ascii_ident", [nx_v("code")]}},
        NxSet{"space", NxCall{"ascii_space", [nx_v("code")]}},
        NxSet{"hash", nx_b("mul", nx_b("xor", nx_v("hash"), nx_b("add", nx_v("code"), nx_b("add", nx_b("mul", nx_v("ident"), nx_b("add", nx_u(130), nx_u(1))), nx_b("mul", nx_v("space"), nx_u(17))))), nx_u(16777619))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxFree{nx_v("text")}, NxReturn{nx_v("hash")}]}]}

def nx_list() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_pp("head"), nx_pp("cell"), nx_pp("next"), nx_p("i"), nx_p("value"), nx_p("sum")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(65535))},
      NxSet{"sum", nx_v("seed")},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"cell", NxAlloc{nx_u(16)}},
        NxStore{NxPtr{}, nx_v("cell"), 0, nx_v("head")},
        NxStore{NxU32{}, nx_v("cell"), 8, nx_b("xor", nx_v("i"), nx_v("seed"))},
        NxSet{"head", nx_v("cell")}, NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxWhile{nx_b("eq", nx_b("eq", nx_v("head"), NxConst{NxPtr{}, 0}), nx_u(0)), [
        NxSet{"next", NxLoad{NxPtr{}, nx_v("head"), 0}},
        NxSet{"value", NxLoad{NxU32{}, nx_v("head"), 8}},
        NxSet{"sum", nx_b("add", nx_b("mul", nx_v("sum"), nx_b("add", nx_u(16), nx_u(17))), nx_v("value"))},
        NxFree{nx_v("head")}, NxSet{"head", nx_v("next")}]},
      NxReturn{nx_v("sum")}]}]}

def nx_tree_build() -> NxFunction:
  NxFunction{"tree_build", [nx_p("depth"), nx_p("seed")], NxPtr{},
    [nx_pp("node"), nx_pp("left"), nx_pp("right")], [
      NxSet{"node", NxAlloc{nx_u(24)}},
      NxIf{nx_b("ult", nx_u(0), nx_v("depth")), [
        NxSet{"left", NxCall{"tree_build", [nx_b("sub", nx_v("depth"), nx_u(1)), nx_b("add", nx_b("mul", nx_v("seed"), nx_u(1664525)), nx_u(1013904223))]}},
        NxSet{"right", NxCall{"tree_build", [nx_b("sub", nx_v("depth"), nx_u(1)), nx_b("add", nx_v("seed"), nx_u(2654435769))]}}], []},
      NxStore{NxPtr{}, nx_v("node"), 0, nx_v("left")},
      NxStore{NxPtr{}, nx_v("node"), 8, nx_v("right")},
      NxStore{NxU32{}, nx_v("node"), 16, nx_v("seed")}, NxReturn{nx_v("node")}]}

def nx_tree_reduce() -> NxFunction:
  NxFunction{"tree_reduce", [nx_pp("node")], NxU32{},
    [nx_pp("left"), nx_pp("right"), nx_p("a"), nx_p("b"), nx_p("value")], [
      NxIf{nx_b("eq", nx_v("node"), NxConst{NxPtr{}, 0}), [NxReturn{nx_u(0)}], [
        NxSet{"left", NxLoad{NxPtr{}, nx_v("node"), 0}},
        NxSet{"right", NxLoad{NxPtr{}, nx_v("node"), 8}},
        NxSet{"value", NxLoad{NxU32{}, nx_v("node"), 16}},
        NxSet{"a", NxCall{"tree_reduce", [nx_v("left")]}},
        NxSet{"b", NxCall{"tree_reduce", [nx_v("right")]}},
        NxFree{nx_v("node")}, NxReturn{nx_b("add", nx_v("value"), nx_b("xor", nx_v("a"), nx_v("b")))}]}]}

def nx_tree() -> NxProgram:
  NxProgram{"main", [nx_tree_build(), nx_tree_reduce(),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_pp("root"), nx_p("sum")], [
      NxSet{"root", NxCall{"tree_build", [nx_b("and", nx_v("n"), nx_u(15)), nx_v("seed")]}},
      NxSet{"sum", NxCall{"tree_reduce", [nx_v("root")]}}, NxReturn{nx_v("sum")}]}]}

def nx_closure_worker(+name: String, +coefficient: U32) -> NxFunction:
  NxFunction{name, [nx_pp("env"), nx_p("arg")], NxU32{}, [nx_p("capture")], [
    NxSet{"capture", NxLoad{NxU32{}, nx_v("env"), 8}},
    NxReturn{nx_b("add", nx_b("mul", nx_v("arg"), nx_u(coefficient)), nx_v("capture"))}]}

def nx_closure() -> NxProgram:
  NxProgram{"main", [nx_closure_worker("closure3", 3), nx_closure_worker("closure7", 7),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
      [nx_pp("env"), nx_pp("func"), nx_p("i"), nx_p("value"), nx_p("sum")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(1048575))}, NxSet{"env", NxAlloc{nx_u(16)}},
      NxIf{nx_b("and", nx_v("seed"), nx_u(1)),
        [NxStore{NxPtr{}, nx_v("env"), 0, NxFunc{"closure3"}}],
        [NxStore{NxPtr{}, nx_v("env"), 0, NxFunc{"closure7"}}]},
      NxStore{NxU32{}, nx_v("env"), 8, nx_v("seed")},
      NxSet{"func", NxLoad{NxPtr{}, nx_v("env"), 0}},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"value", NxICall{nx_v("func"), [nx_v("env"), nx_v("i")], [NxPtr{}, NxU32{}], NxU32{}}},
        NxSet{"sum", nx_b("xor", nx_b("mul", nx_v("sum"), nx_u(33)), nx_v("value"))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxFree{nx_v("env")}, NxReturn{nx_v("sum")}]}]}

# Profile-motivated ownership ablation: the original owner keeps a parent and
# its immutable child alive for every observation. Only that explicit lifetime
# permits the borrowed variant. These cells do not claim the production RC ABI.
def nx_shared_observer(owned: Bool) -> NxFunction:
  match owned:
    case False{}:
      NxFunction{"observe", [nx_pp("parent")], NxU32{}, [nx_pp("child"), nx_p("value")], [
        NxSet{"child", NxLoad{NxPtr{}, nx_v("parent"), 8}},
        NxSet{"value", NxLoad{NxU32{}, nx_v("child"), 8}}, NxReturn{nx_v("value")}]}
    case True{}:
      NxFunction{"observe", [nx_pp("parent")], NxU32{}, [nx_pp("child"), nx_p("refs"), nx_p("value")], [
        NxSet{"refs", NxLoad{NxU32{}, nx_v("parent"), 0}},
        NxStore{NxU32{}, nx_v("parent"), 0, nx_b("add", nx_v("refs"), nx_u(1))},
        NxSet{"child", NxLoad{NxPtr{}, nx_v("parent"), 8}},
        NxSet{"refs", NxLoad{NxU32{}, nx_v("child"), 0}},
        NxStore{NxU32{}, nx_v("child"), 0, nx_b("add", nx_v("refs"), nx_u(1))},
        NxSet{"refs", NxLoad{NxU32{}, nx_v("parent"), 0}},
        NxStore{NxU32{}, nx_v("parent"), 0, nx_b("sub", nx_v("refs"), nx_u(1))},
        NxSet{"value", NxLoad{NxU32{}, nx_v("child"), 8}},
        NxSet{"refs", NxLoad{NxU32{}, nx_v("child"), 0}},
        NxStore{NxU32{}, nx_v("child"), 0, nx_b("sub", nx_v("refs"), nx_u(1))}, NxReturn{nx_v("value")}]}

def nx_shared(owned: Bool) -> NxProgram:
  NxProgram{"main", [nx_shared_observer(owned),
    NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
      [nx_pp("parent"), nx_pp("child"), nx_p("i"), nx_p("value"), nx_p("sum"), nx_p("parentrefs"), nx_p("childrefs")], [
      NxSet{"n", nx_b("and", nx_v("n"), nx_u(1048575))},
      NxSet{"parent", NxAlloc{nx_u(16)}}, NxSet{"child", NxAlloc{nx_u(16)}},
      NxStore{NxU32{}, nx_v("parent"), 0, nx_u(1)}, NxStore{NxPtr{}, nx_v("parent"), 8, nx_v("child")},
      NxStore{NxU32{}, nx_v("child"), 0, nx_u(1)}, NxStore{NxU32{}, nx_v("child"), 8, nx_v("seed")},
      NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
        NxSet{"value", NxCall{"observe", [nx_v("parent")]}},
        NxSet{"sum", nx_b("add", nx_b("mul", nx_v("sum"), nx_u(33)), nx_b("xor", nx_v("value"), nx_v("i")))},
        NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]},
      NxSet{"parentrefs", NxLoad{NxU32{}, nx_v("parent"), 0}},
      NxSet{"childrefs", NxLoad{NxU32{}, nx_v("child"), 0}},
      NxFree{nx_v("parent")}, NxFree{nx_v("child")},
      NxReturn{nx_b("xor", nx_v("sum"), nx_b("or", nx_b("xor", nx_v("parentrefs"), nx_u(1)), nx_b("xor", nx_v("childrefs"), nx_u(1))))}]}]}

# A lowered self-tail recurrence: explicit while, with no native stack growth.
# Shifts here have explicitly masked machine-IR semantics, not Base.shln.
def nx_tail() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("i"), nx_p("x")], [
    NxSet{"n", nx_b("and", nx_v("n"), nx_u(16777215))}, NxSet{"x", nx_v("seed")},
    NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
      NxSet{"x", nx_b("xor", nx_v("x"), nx_b("shl", nx_v("x"), nx_u(13)))},
      NxSet{"x", nx_b("xor", nx_v("x"), nx_b("lshr", nx_v("x"), nx_u(17)))},
      NxSet{"x", nx_b("xor", nx_v("x"), nx_b("shl", nx_v("x"), nx_u(5)))},
      NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]}, NxReturn{nx_v("x")}]}]}

@unsafe
def nx_many_helpers(+n: U32) -> List<&2, NxFunction>:
  nx_choose(List<&2, NxFunction>, U32.is_eq(n, 0),
    u => [NxFunction{"helper0", [nx_p("x")], NxU32{}, [], [NxReturn{nx_b("xor", nx_v("x"), nx_u(2654435769))}]}],
    u => Con{NxFunction{"helper" ++ U32.show(n), [nx_p("x")], NxU32{}, [nx_p("value")], [
      NxSet{"value", NxCall{"helper" ++ U32.show(U32.sub(n, 1)), [nx_b("add", nx_v("x"), nx_u(n))]}},
      NxReturn{nx_b("xor", nx_b("mul", nx_v("value"), nx_u(1664525)), nx_u(U32.add(n, 1013904223)))}]}, nx_many_helpers(U32.sub(n, 1))})

@unsafe
def nx_many() -> NxProgram:
  NxProgram{"main", Con{NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{}, [nx_p("i"), nx_p("x")], [
    NxSet{"n", nx_b("and", nx_v("n"), nx_u(65535))}, NxSet{"x", nx_v("seed")},
    NxWhile{nx_b("ult", nx_v("i"), nx_v("n")), [
      NxSet{"x", NxCall{"helper127", [nx_v("x")]}},
      NxSet{"i", nx_b("add", nx_v("i"), nx_u(1))}]}, NxReturn{nx_v("x")}]}, nx_many_helpers(127)} }

@unsafe
def nx_workload(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "text"), u => Some{nx_text()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "list"), u => Some{nx_list()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tree"), u => Some{nx_tree()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "closure"), u => Some{nx_closure()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "tail"), u => Some{nx_tail()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "many"), u => Some{nx_many()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "shared"), u => Some{nx_shared(True{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "shared_borrow"), u => Some{nx_shared(False{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "classify"), u => Some{nx_classify()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "shift"), u => Some{nx_shift_control()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "law_bridge"), u => Some{nx_law_bridge()}, u => nx_rejection(name))))))))))))
