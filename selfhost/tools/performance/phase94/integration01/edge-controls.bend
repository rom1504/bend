# Append to the integrated compiler after replacing its CLI main. These cases
# exercise the actual adapter, an independent literal answer, and the old path.
@unsafe
def p94_kind_text(kind: N_WordKind) -> String:
  match kind:
    case N_W32{}: "32"
    case N_W64{}: "64"
    case N_Box{}: "box"

@unsafe
def p94_rows_text(rows: List<&2, NC_Binding>) -> String:
  match rows:
    case Nil{}: ""
    case Con{NC_Binding{id, word, kind}, rest}:
      U32.show(id) ++ ":" ++ word ++ ":" ++ p94_kind_text(kind) ++ "|" ++ p94_rows_text(rest)

@unsafe
def p94_part_text(parts: NC_EnvPartition) -> String:
  match parts:
    case NC_EnvPartition{live, drop}: p94_rows_text(live) ++ "DROP[" ++ drop ++ "]"

@unsafe
def p94_case(+label: String, +env: List<&2, NC_Binding>, +uses: NU_Set, +binding: NC_Binding, +expected: String) -> String:
  +actual = p94_part_text(nc_env_extend(env, uses, binding))
  +reference = p94_part_text(nc_partition_uses(List.append(&2, NC_Binding, nc_live_uses(env, uses), [binding]), uses))
  nt_choose(String, String.eq(actual, expected) && String.eq(reference, expected),
    u => label ++ ":PASS\n",
    u => label ++ ":FAIL actual=[" ++ actual ++ "] reference=[" ++ reference ++ "] expected=[" ++ expected ++ "]\n")

@unsafe
def p94_env() -> List<&2, NC_Binding>:
  [NC_Binding{7, "a", N_W32{}}, NC_Binding{2, "dead", N_Box{}}, NC_Binding{7, "b", N_W64{}}, NC_Binding{3, "c", N_Box{}}]

@unsafe
def p94_controls() -> String:
  p94_case("empty-dead", Nil{}, NU_Empty{}, NC_Binding{9, "fresh", N_W64{}}, "DROP[term_sink(e, fresh);\n]") ++
  p94_case("empty-live", Nil{}, nu_add(NU_Empty{}, 9), NC_Binding{9, "fresh", N_W64{}}, "9:fresh:64|DROP[]") ++
  p94_case("duplicates-and-kinds", p94_env(), nu_add(nu_add(nu_add(NU_Empty{}, 7), 3), 9), NC_Binding{9, "fresh", N_Box{}}, "7:a:32|7:b:64|3:c:box|9:fresh:box|DROP[]") ++
  p94_case("duplicate-new-id", p94_env(), nu_add(NU_Empty{}, 7), NC_Binding{7, "new", N_Box{}}, "7:a:32|7:b:64|7:new:box|DROP[]") ++
  p94_case("only-new-dropped", p94_env(), nu_add(nu_add(NU_Empty{}, 7), 3), NC_Binding{9, "a[2]", N_W32{}}, "7:a:32|7:b:64|3:c:box|DROP[term_sink(e, a[2]);\n]") ++
  p94_case("all-prefix-dead", p94_env(), NU_Empty{}, NC_Binding{9, "fresh", N_Box{}}, "DROP[term_sink(e, fresh);\n]")

@unsafe
def main() -> IO(Unit):
  IO.write(p94_controls())
