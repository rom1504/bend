# Executable backend bridge, concatenated after ir/workloads.bend.
# ABI main(n, seed): n=0..29 selects a literal expression, n=30..59 the same
# expression using runtime-dependent locals. seed=0 matches cases.json.
# A nonzero seed changes both dynamic operands by XOR; this prevents treating
# the dynamic branch as another constant expression during native compilation.
type NxLawCase is Data:
  NxLawCase{+op: String, +a: U32, +b: U32}

def nx_law_inputs() -> List<&2, NxLawCase>:
  [NxLawCase{"add", 0, 0},
   NxLawCase{"add", 4294967295, 1},
   NxLawCase{"add", 2147483648, 2147483648},
   NxLawCase{"add", 4294967295, 4294967295},
   NxLawCase{"add", 4294967295, 2147483648},
   NxLawCase{"sub", 0, 1},
   NxLawCase{"sub", 1, 2},
   NxLawCase{"sub", 2147483648, 1},
   NxLawCase{"sub", 4294967295, 4294967295},
   NxLawCase{"mul", 65536, 65536},
   NxLawCase{"mul", 4294967295, 4294967295},
   NxLawCase{"mul", 2147483648, 2},
   NxLawCase{"mul", 123456789, 17},
   NxLawCase{"and", 4294967295, 2147483648},
   NxLawCase{"and", 2863311530, 1431655765},
   NxLawCase{"and", 4294967295, 4294967295},
   NxLawCase{"or", 2863311530, 1431655765},
   NxLawCase{"or", 0, 2147483648},
   NxLawCase{"or", 2147483648, 2147483648},
   NxLawCase{"xor", 2863311530, 1431655765},
   NxLawCase{"xor", 2147483648, 2147483648},
   NxLawCase{"xor", 4294967295, 0},
   NxLawCase{"eq", 4294967295, 4294967295},
   NxLawCase{"eq", 0, 4294967295},
   NxLawCase{"eq", 2147483648, 2147483647},
   NxLawCase{"ult", 0, 4294967295},
   NxLawCase{"ult", 4294967295, 0},
   NxLawCase{"ult", 2147483648, 2147483647},
   NxLawCase{"ult", 2147483647, 2147483648},
   NxLawCase{"ult", 4294967295, 4294967295}]

def nx_law_body(dynamic: Bool, +op: String, +a: U32, +b: U32) -> List<&2, NxStmt>:
  match dynamic:
    case False{}: [NxReturn{nx_b(op, nx_u(a), nx_u(b))}]
    case True{}:
      [NxSet{"left", nx_b("xor", nx_u(a), nx_v("seed"))},
       NxSet{"right", nx_b("xor", nx_u(b), nx_v("seed"))},
       NxReturn{nx_b(op, nx_v("left"), nx_v("right"))}]

def nx_law_cases(cases: List<&2, NxLawCase>, +index: U32, +dynamic: Bool) -> List<&2, NxStmt>:
  match cases:
    case Nil{}: [NxReturn{nx_u(0)}]
    case Con{NxLawCase{op, a, b}, rest}:
      [NxIf{nx_b("eq", nx_v("n"), nx_u(index)),
        nx_law_body(dynamic, op, a, b), nx_law_cases(rest, U32.inc(index), dynamic)}]

def nx_law_bridge() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [nx_p("n"), nx_p("seed")], NxU32{},
    [nx_p("left"), nx_p("right")], [
      NxIf{nx_b("ult", nx_v("n"), nx_u(30)),
        nx_law_cases(nx_law_inputs(), 0, False{}),
        nx_law_cases(nx_law_inputs(), 30, True{})}]}]}
