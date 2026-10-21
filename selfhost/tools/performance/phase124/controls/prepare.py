"""Freeze independent complete-output oracles; never execute a compiler/target."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MASK = (1 << 32) - 1


def pin(path):
    data = path.read_bytes()
    return {"file": str(path), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def words(values):
    return "".join(str(value) + ";" for value in values)


def list_oracle():
    samples = [[], [[]], [[0, 1, MASK], [], [17, 0]], [[i] for i in range(4095, -1, -1)]]
    output = []
    for rows in samples:
        mapped = [(3 * value + 5) & MASK for row in rows for value in reversed(row)]
        output.extend([words(mapped), "".join("[" + words(row) + "]" for row in rows)])
    return "\n".join(output) + "\n"


def page(values):
    return (values, None, None)


def tree_oracle():
    deep = page([MASK])
    for i in range(2048):
        deep = ([i], deep, page([i + 1]))
    samples = [page([]), page([MASK, 0, 1]), ([3, MASK], page([0, 2]), ([], page([7]), page([]))), deep]
    output = []
    for tree in samples:
        mapped = []
        work = [tree]
        while work:
            values, left, right = work.pop()
            mapped.extend((7 * value + 11) & MASK for value in reversed(values))
            if left is not None:
                work.extend([right, left])
        # Independent iterative preorder grammar; no recursive source evaluator.
        tokens = []
        work = [tree]
        while work:
            item = work.pop()
            if isinstance(item, str):
                tokens.append(item)
                continue
            values, left, right = item
            if left is None:
                tokens.append("P[" + words(values) + "]")
            else:
                tokens.append("B[" + words(values) + "](")
                work.extend([")", right, ")(", left])
        output.extend([words(mapped), "".join(tokens)])
    return "\n".join(output) + "\n"


cases = []
for name, oracle, owner in [
    ("list-resume01", list_oracle, "parcel.collect"),
    ("tree-resume01", tree_oracle, "archive.collect"),
]:
    result = oracle()
    stdout = HERE / (name + ".expected.stdout")
    expected = HERE / (name + ".expected.json")
    stdout.write_text(result)
    expected.write_text(json.dumps({"status": 0, "stdout": result, "stderr": ""}, indent=2) + "\n")
    cases.append({"name": "p124-" + name, "source": pin(HERE / (name + ".bend")),
                  "expected": pin(expected), "expectedStdoutEvidence": pin(expected),
                  "admissionOwner": owner, "stdoutEvidence": pin(stdout)})
(HERE / "cases.json").write_text(json.dumps({"cases": cases}, indent=2) + "\n")
(HERE / "manifest01.json").write_text(json.dumps({
    "compilerExecuted": False, "targetExecuted": False, "sourceChecked": False,
    "purpose": "Finite semantic and local-resume activation controls; not benchmark claims",
    "generator": pin(Path(__file__).resolve()), "cases": pin(HERE / "cases.json"),
    "sources": [case["source"] for case in cases],
    "expectations": [case["expected"] for case in cases],
    "base": pin(ROOT / "selfhost/.bootstrap/upstream-phase66/bend2/base.bend"),
    "depths": {"list": 4096, "tree": 2048},
}, indent=2) + "\n")
print(json.dumps({"cases": len(cases), "stdoutBytes": [case["stdoutEvidence"]["bytes"] for case in cases]}))
