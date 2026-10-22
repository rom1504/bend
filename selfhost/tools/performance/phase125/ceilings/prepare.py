"""Freeze source-only spine-elimination ceilings. No compiler/target execution."""
import copy
import difflib
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
CATALOG = ROOT / "selfhost/tools/performance/phase112/benchmark45/manifest01.json"


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def save(name, text):
    path = HERE / name
    if path.exists():
        assert path.read_text() == text, f"refuse to change frozen output {path}"
    else:
        path.write_text(text)
    return pin(path)


def save_json(name, value):
    return save(name, json.dumps(value, indent=2) + "\n")


original = next(c for c in json.loads(CATALOG.read_text())["cases"] if c["name"] == "test-rle-roundtrip")
source = Path(original["source"]["file"])
assert pin(source) == original["source"]
text = source.read_text()
assert text.count("law expand:\n") == 1
old = "lconcat(lrepeat(U32.to_nat(n), v), expand(t))"
assert text.count(old) == 1
helper = '''# Diagnostic only: construct the repeated prefix directly onto its final tail.
def p125.repeat_into(n: Nat, +value: U32, tail: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: tail
    case 1n+p: p125.repeat_into(p, value, value <> tail)

'''
new = text.replace("law expand:\n", helper + "law expand:\n").replace(old, "p125.repeat_into(U32.to_nat(n), v, expand(t))")
assert new.split("# Phase93:", 1)[1] == text.split("# Phase93:", 1)[1]
variant = copy.deepcopy(original)
variant.update(name="test-rle-roundtrip-p125-spine", parentName=original["name"],
               source=save("rle-spine01.bend", new), diagnosticOnly=True, benchmarkClaim=False)
diff = "".join(difflib.unified_diff(text.splitlines(True), new.splitlines(True),
                                 fromfile="frozen/test-rle-roundtrip.bend", tofile="ceilings/rle-spine01.bend"))
save("rle-spine01.diff", diff)
save_json("rle-cases.json", {"kind": "phase125-source-only-producer-concat-ceiling", "cases": [variant]})

# Independent closed-form list mapping, not evaluation of either Bend function.
samples = [([], []), ([""], ["tail"]), (["alpha", "beta", ""], ["omega", "", "end"]),
           (["red", "green", "blue", "green", "red"], ["red", "red"])]
show = lambda values: "".join("[" + item + "]" for item in values)
lines = []
for xs, tail in samples:
    result = ["(" + item + ")" for item in xs] + tail
    lines.extend([show(result), show(result), show(xs), show(tail)])
stdout = "\n".join(lines) + "\n"
stdout_pin = save("producer-concat-control01.expected.stdout", stdout)
expected = save_json("producer-concat-control01.expected.json", {"status": 0, "stdout": stdout, "stderr": ""})
control = dict(name="p125-producer-concat-control01", source=pin(HERE / "producer-concat-control01.bend"),
               expected=expected, expectedStdoutEvidence=expected, stdoutEvidence=stdout_pin)
controls = save_json("controls.json", {"cases": [control]})
cases = save_json("cases.json", {"cases": [variant, control]})
save_json("manifest01.json", dict(compilerExecuted=False, targetExecuted=False, checked=False,
    generator=pin(Path(__file__).resolve()), catalog=pin(CATALOG), original=original["source"],
    variant=variant["source"], diff=pin(HERE / "rle-spine01.diff"), cases=cases, controls=controls,
    counts=dict(frozenRuns=[3, 1, 2], expandedLength=6, originalExpandCons=12,
                fusedExpandCons=6, eliminatedConcatConsVisits=6),
    caveat="Source constructor counts, not runtime malloc counts or benchmark improvements; pure finite evaluation-order ceiling."))
print(json.dumps({"variant": variant["name"], "controls": 1, "oracleLines": len(lines)}))
