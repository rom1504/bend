import Base
import ./extracted.bend as M

@unsafe
def p95.result(label: String, expected: Bool, baseline: Bool, candidate: Bool) -> String:
  match expected baseline candidate:
    case True{} True{} True{}: label ++ ":PASS\n"
    case False{} False{} False{}: label ++ ":PASS\n"
    case e b c: label ++ ":FAIL\n"

@unsafe
def p95.case(label: String, +rows: List<&2, String>, +key: String, expected: Bool) -> String:
  p95.result(label, expected, M.nb_contains(rows, key), M.has_name(rows, key))

@unsafe
def p95.rows_text(rows: List<&2, String>) -> String:
  match rows:
    case Nil{}: ""
    case Con{head, rest}: "[" ++ head ++ "]" ++ p95.rows_text(rest)

@unsafe
def p95.shared(+rows: List<&2, String>) -> String:
  p95.case("shared-head", rows, "a", True{}) ++
  p95.case("shared-middle", rows, "β", True{}) ++
  p95.case("shared-tail", rows, "🙂", True{}) ++
  p95.case("shared-miss", rows, "absent", False{}) ++
  "shared-consumed:" ++ p95.rows_text(rows) ++ "\n"

@unsafe
def p95.controls() -> String:
  p95.case("empty", Nil{}, "x", False{}) ++
  p95.case("empty-empty-string", Nil{}, "", False{}) ++
  p95.case("singleton-hit", ["x"], "x", True{}) ++
  p95.case("singleton-miss", ["x"], "y", False{}) ++
  p95.case("head", ["a", "b", "c"], "a", True{}) ++
  p95.case("middle", ["a", "b", "c"], "b", True{}) ++
  p95.case("tail", ["a", "b", "c"], "c", True{}) ++
  p95.case("miss", ["a", "b", "c"], "d", False{}) ++
  p95.case("duplicates", ["same", "other", "same"], "same", True{}) ++
  p95.case("empty-string", ["other", "", "tail"], "", True{}) ++
  p95.case("unicode-hit", ["α", "é", "é", "🙂", "終"], "🙂", True{}) ++
  p95.case("unicode-miss", ["α", "é", "é", "🙂", "終"], "😃", False{}) ++
  p95.case("unicode-no-normalization", ["é"], "é", False{}) ++
  p95.case("prefix-distinct", ["prefix", "prefix-long"], "prefix-", False{}) ++
  p95.case("collision-name-hit", ["costarring", "liquid"], "liquid", True{}) ++
  p95.shared(["a", "β", "a", "🙂"])

@unsafe
def main() -> IO(Unit):
  IO.write(p95.controls())
