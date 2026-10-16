import Base

# Each definition is a target followed by its prerequisites in desired order.
type DPNode is Data:
  DPNode{+name: String, +deps: List<&2, String>}

type DPGraph is Data:
  DPGraph{+nodes: List<&2, DPNode>, +count: U32, +edges: U32, +error: String}

type DPWork is Data:
  DPEnter{+name: String}
  DPExit{+name: String}

type DPState is Data:
  DPState{+work: List<&2, DPWork>, +active: List<&2, String>, +done: List<&2, String>, +order: List<&2, String>, +edges: U32}

type DPResult is Data:
  DPPlan{+order: List<&2, String>, +count: U32, +edges: U32}
  DPProblem{+kind: String, +name: String, +path: List<&2, String>}

type DPUpdate is Data:
  DPNext{+state: DPState}
  DPStop{+result: DPResult}

type DPInput is Data:
  DPInput{+good: Bool, +text: String}

def dp_choose(-A: Type, test: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match test:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def dp_count(names: List<&2, String>, total: U32) -> U32:
  match names:
    case Nil{}: total
    case Con{head, tail}: dp_count(tail, U32.inc(total))

def dp_contains(names: List<&2, String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, +tail}:
      dp_choose(Bool, String.eq(head, name), u => True{}, u => dp_contains(tail, name))

def dp_lookup(nodes: List<&2, DPNode>, +name: String) -> Maybe<&2, DPNode>:
  match nodes:
    case Nil{}: None{}
    case Con{DPNode{+key, +deps}, +tail}:
      dp_choose(Maybe<&2, DPNode>, String.eq(key, name),
        u => Some{DPNode{key, deps}}, u => dp_lookup(tail, name))

def dp_found(found: Maybe<&2, DPNode>) -> Bool:
  match found:
    case None{}: False{}
    case Some{node}: True{}

def dp_declared(nodes: List<&2, DPNode>, name: String) -> Bool:
  dp_found(dp_lookup(nodes, name))

# Only ASCII names are accepted, so printed records need no escaping.
def dp_name_char(c: Char) -> Bool:
  +n = Char.to_u32(c)
  (U32.is_ge(n, 65) && U32.is_le(n, 90)) || (U32.is_ge(n, 97) && U32.is_le(n, 122)) ||
    (U32.is_ge(n, 48) && U32.is_le(n, 57)) || U32.is_eq(n, 95) || U32.is_eq(n, 45) || U32.is_eq(n, 46) || U32.is_eq(n, 47)

def dp_name_tail(text: String, +count: U32) -> Bool:
  match text:
    case SNil{}: U32.is_gt(count, 0)
    case SCon{head, +tail}:
      dp_choose(Bool, U32.is_lt(count, 128) && dp_name_char(head),
        u => dp_name_tail(tail, U32.inc(count)), u => False{})

def dp_bad_name(names: List<&2, String>) -> String:
  match names:
    case Nil{}: ""
    case Con{+head, +tail}:
      dp_choose(String, dp_name_tail(head, 0), u => dp_bad_name(tail), u => head)

def dp_names_valid(names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head, +tail}:
      dp_choose(Bool, dp_name_tail(head, 0), u => dp_names_valid(tail), u => False{})

def dp_flush(token: String, words: List<&2, String>) -> List<&2, String>:
  match token:
    case SNil{}: words
    case SCon{head, tail}: Con{String.reverse(SCon{head, tail}), words}

def dp_words_go(text: String, +token: String, +words: List<&2, String>) -> List<&2, String>:
  match text:
    case SNil{}: List.reverse(&2, String, dp_flush(token, words))
    case SCon{+head, +tail}:
      +n = Char.to_u32(head)
      dp_choose(List<&2, String>, U32.is_eq(n, 35),
        u => List.reverse(&2, String, dp_flush(token, words)),
        u => dp_choose(List<&2, String>, U32.is_eq(n, 32) || U32.is_eq(n, 9) || U32.is_eq(n, 13),
          v => dp_words_go(tail, "", dp_flush(token, words)),
          v => dp_words_go(tail, SCon{head, token}, words)))

def dp_parse_line(graph: DPGraph, words: List<&2, String>, +line: U32) -> DPGraph:
  match graph:
    case DPGraph{+nodes, +count, +edges, error}:
      match words:
        case Nil{}: DPGraph{nodes, count, edges, ""}
        case Con{+name, +deps}:
          +bad = dp_bad_name(Con{name, deps})
          +more = dp_count(deps, 0)
          dp_choose(DPGraph, Bool.not(String.is_empty(bad)),
            u => DPGraph{nodes, count, edges, "error invalid-name " ++ U32.show(line) ++ " " ++ bad},
            u => dp_choose(DPGraph, dp_declared(nodes, name),
              v => DPGraph{nodes, count, edges, "error duplicate " ++ U32.show(line) ++ " " ++ name},
              v => dp_choose(DPGraph, U32.is_ge(count, 4096) || U32.is_gt(U32.add(edges, more), 32768),
                w => DPGraph{nodes, count, edges, "error graph-limit"},
                w => DPGraph{Con{DPNode{name, deps}, nodes}, U32.inc(count), U32.add(edges, more), ""})))

def dp_parse(lines: List<&2, String>, +line: U32, graph: DPGraph) -> DPGraph:
  match lines:
    case Nil{}: graph
    case Con{+head, +tail}:
      match graph:
        case DPGraph{+nodes, +count, +edges, +error}:
          dp_choose(DPGraph, Bool.not(String.is_empty(error)),
            u => DPGraph{nodes, count, edges, error},
            u => dp_parse(tail, U32.inc(line), dp_parse_line(DPGraph{nodes, count, edges, ""}, dp_words_go(head, "", Nil{}), line)))

def dp_push(names: List<&2, String>, tail: List<&2, DPWork>) -> List<&2, DPWork>:
  match names:
    case Nil{}: tail
    case Con{head, rest}: Con{DPEnter{head}, dp_push(rest, tail)}

def dp_enter_found(found: Maybe<&2, DPNode>, +name: String, +rest: List<&2, DPWork>, +active: List<&2, String>, +done: List<&2, String>, +order: List<&2, String>, +edges: U32) -> DPUpdate:
  match found:
    case None{}:
      DPStop{DPProblem{"missing", name, List.reverse(&2, String, Con{name, active})}}
    case Some{DPNode{key, +deps}}:
      DPNext{DPState{dp_push(deps, Con{DPExit{name}, rest}), Con{name, active}, done, order, U32.add(edges, dp_count(deps, 0))}}

def dp_step(+nodes: List<&2, DPNode>, state: DPState) -> DPUpdate:
  match state:
    case DPState{work, +active, +done, +order, +edges}:
      match work:
        case Nil{}: DPStop{DPPlan{List.reverse(&2, String, order), dp_count(done, 0), edges}}
        case Con{item, +rest}:
          match item:
            case DPExit{+name}:
              match active:
                case Nil{}: DPStop{DPProblem{"internal-stack", name, Nil{}}}
                case Con{head, tail}: DPNext{DPState{rest, tail, Con{name, done}, Con{name, order}, edges}}
            case DPEnter{+name}:
              dp_choose(DPUpdate, dp_contains(done, name),
                u => DPNext{DPState{rest, active, done, order, edges}},
                u => dp_choose(DPUpdate, dp_contains(active, name),
                  v => DPStop{DPProblem{"cycle", name, List.reverse(&2, String, Con{name, active})}},
                  v => dp_enter_found(dp_lookup(nodes, name), name, rest, active, done, order, edges)))

# At most one exit per reached node, one enter per edge/root, then completion.
def dp_walk(fuel: Nat, update: DPUpdate, +nodes: List<&2, DPNode>) -> DPResult:
  match fuel update:
    case 0n DPStop{result}: result
    case 0n DPNext{state}: DPProblem{"internal-budget", "", Nil{}}
    case 1n+rest DPStop{result}: result
    case 1n+rest DPNext{state}: dp_walk(rest, dp_step(nodes, state), nodes)

def dp_format(result: DPResult, +roots: List<&2, String>, declared: U32) -> String:
  match result:
    case DPProblem{kind, name, path}:
      "error " ++ kind ++ " " ++ name ++ "\npath " ++ String.join(path, " ")
    case DPPlan{order, count, edges}:
      "plan-v1\nroots " ++ String.join(roots, " ") ++ "\norder " ++ String.join(order, " ") ++
        "\nreachable " ++ U32.show(count) ++ "\nedges " ++ U32.show(edges) ++ "\ndeclared " ++ U32.show(declared)

def dp_run_graph(graph: DPGraph, +roots: List<&2, String>) -> String:
  match graph:
    case DPGraph{+nodes, +count, +edges, +error}:
      +fuel = U32.to_nat(U32.add(U32.inc(U32.add(count, edges)), dp_count(roots, 0)))
      dp_choose(String, String.is_empty(error),
        u => dp_format(dp_walk(fuel, DPNext{DPState{dp_push(roots, Nil{}), Nil{}, Nil{}, Nil{}, 0}}, nodes), roots, count),
        u => error)

def dp_run(+text: String, +roots: List<&2, String>) -> String:
  +bad = dp_bad_name(roots)
  dp_choose(String, U32.is_gt(dp_count(roots, 0), 128), u => "error root-limit",
    u => dp_choose(String, Bool.not(dp_names_valid(roots)), u => "error invalid-root " ++ bad,
      u => dp_run_graph(dp_parse(String.lines(text), 1, DPGraph{Nil{}, 0, 0, ""}), roots)))

# Sized regular-file read plus an EOF check: a short/growing read is rejected.
def dp_read_eof_result(result: Result<&1, &1, U32 & String, String>, +text: String) -> DPInput:
  match result:
    case Fail{error}: DPInput{False{}, "error file-read"}
    case Done{tail}:
      dp_choose(DPInput, String.is_empty(tail),
        u => DPInput{True{}, text}, u => DPInput{False{}, "error incomplete-read"})

def dp_read_eof(pair: File & Result<&1, &1, U32 & String, String>, text: String) -> IO(DPInput):
  (file, result) = pair
  do IO<DPInput>:
    File.close(file)
    IO.pure(DPInput, dp_read_eof_result(result, text))

def dp_read_more(pair: File & Result<&1, &1, U32 & String, String>) -> IO(DPInput):
  (file, result) = pair
  match result:
    case Fail{error}:
      do IO<DPInput>:
        File.close(file)
        IO.pure(DPInput, DPInput{False{}, "error file-read"})
    case Done{text}:
      do IO<DPInput>:
        tail : File & Result<&1, &1, U32 & String, String> <- File.read(file, 1)
        dp_read_eof(tail, text)

def dp_read_limit(file: File, size: U32, allowed: Bool) -> IO(DPInput):
  match allowed:
    case False{}:
      do IO<DPInput>:
        File.close(file)
        IO.pure(DPInput, DPInput{False{}, "error input-limit"})
    case True{}:
      do IO<DPInput>:
        pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, size)
        dp_read_more(pair)

def dp_read_sized(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(DPInput):
  (file, result) = pair
  match result:
    case Fail{error}:
      do IO<DPInput>:
        File.close(file)
        IO.pure(DPInput, DPInput{False{}, "error file-size"})
    case Done{+size}: dp_read_limit(file, size, U32.is_le(size, 1048576))

def dp_read_open(result: Result<&1, &1, U32 & String, File>) -> IO(DPInput):
  match result:
    case Fail{error}: IO.pure(DPInput, DPInput{False{}, "error file-open"})
    case Done{file}:
      do IO<DPInput>:
        pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
        dp_read_sized(pair)

def dp_read(path: String) -> IO(DPInput):
  do IO<DPInput>:
    opened : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    dp_read_open(opened)

def dp_print(input: DPInput, roots: List<&2, String>) -> IO(Unit):
  match input:
    case DPInput{good, +text}:
      IO.print(dp_choose(String, good, u => dp_run(text, roots), u => text))

def dp_roots(args: List<&1, String>) -> List<&2, String>:
  match args:
    case Nil{}: Nil{}
    case Con{head, tail}: Con{head, dp_roots(tail)}

def dp_cli_graph(args: List<&1, String>) -> IO(Unit):
  match args:
    case Nil{}: IO.print("error usage: --graph FILE ROOT...")
    case Con{path, Nil{}}: IO.print("error usage: --graph FILE ROOT...")
    case Con{path, Con{root, rest}}:
      +roots : List<&2, String> = Con{root, dp_roots(rest)}
      do IO<Unit>:
        input : DPInput <- dp_read(path)
        dp_print(input, roots)

def dp_cli(args: List<&1, String>, ready: Bool) -> IO(Unit):
  match args ready:
    case Nil{} True{}: dp_cli_graph(Nil{})
    case Nil{} False{}: IO.print("error usage: --graph FILE ROOT...")
    case Con{head, tail} True{}: dp_cli_graph(Con{head, tail})
    case Con{head, tail} False{}: dp_cli(tail, String.eq(head, "--graph"))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    dp_cli(args, False{})
