#!/usr/bin/env python3
"""Independent finite controls; never builds or launches a compiler.

The producer, transformations and code generators remain Bend. This imports the
previous phase's independent IR interpreter, not the inliner implementation.
"""
import argparse
import copy
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
P106 = HERE.parents[1] / "phase106"
spec = importlib.util.spec_from_file_location("phase106_reference", P106 / "reference.py")
reference = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reference)


def nodes(program):
    """Independent JSON count matching the documented AST metric, not syntax bytes."""
    def walk(value):
        if isinstance(value, list):
            return sum(map(walk, value))
        if not isinstance(value, dict):
            return 0
        # Every dict is one program/function/parameter/local/statement/expression.
        return 1 + sum(walk(v) for v in value.values())
    return walk(program)


def calls(value):
    if isinstance(value, list):
        return sum(map(calls, value))
    if not isinstance(value, dict):
        return 0
    return int(value.get("kind") == "call") + sum(calls(v) for v in value.values())


def controls(name):
    data = json.loads((HERE / "controls.json").read_text())
    return [row for row in data["cases"] if row["fixture"] == name]


def audit_pair(name, before, after, budget):
    count_before, count_after = nodes(before), nodes(after)
    assert count_after <= count_before + min(budget, 4096), "growth exceeds global budget"
    assert before["entry"] == after["entry"]
    assert [f["name"] for f in before["functions"]] == [f["name"] for f in after["functions"]]
    for function in after["functions"]:
        names = [p["name"] for p in function["params"] + function["locals"]]
        assert len(names) == len(set(names)), "fresh-name collision"
    if budget <= 1 or name in ("cycle", "shared", "shared_borrow"):
        assert before == after, "refusal changed program"
    elif name in ("snapshot", "collision", "branch", "merge", "reset", "nested") and budget == 4096:
        assert calls(after) == 0, "admitted fixture retained direct call"
    rows = []
    for row in controls(name):
        values = [reference.Interpreter(program).run(row["args"])["value"]
                  for program in (before, after)]
        assert values == [row["expected"]] * 2, (name, row, values)
        rows.append(dict(args=row["args"], expected=row["expected"], values=values))
    return dict(fixture=name, budget=budget, before=count_before, after=count_after,
                callsBefore=calls(before), callsAfter=calls(after), observations=rows)


def walk_bodies(body, change):
    result = []
    for stmt in body:
        for key in ("body", "then", "else"):
            if key in stmt:
                stmt[key] = walk_bodies(stmt[key], change)
        if change(stmt):
            result.append(stmt)
    return result


def negative_controls(programs):
    """Mutate accepted output, preserving types; tests oracle sensitivity only.

    This is not a claim that the Bend optimizer itself was mutation-tested.
    """
    results = []
    for name, mutation, args in (("reset", "omit-per-call-zero", [4, 0]),
                                 ("nested", "swap-snapshotted-arguments", [2, 3]),
                                 ("branch", "discard-caller-result", [8, 7])):
        original = programs[name]
        mutant = copy.deepcopy(original)
        main = next(f for f in mutant["functions"] if f["name"] == mutant["entry"])
        edits = 0

        def change(stmt):
            nonlocal edits
            if mutation == "omit-per-call-zero" and stmt["kind"] == "set" \
                    and stmt["name"].endswith("_v_temporary") \
                    and stmt["value"] == {"kind": "const", "type": "u32", "value": 0}:
                edits += 1
                return False
            if mutation == "discard-caller-result" and stmt["kind"] == "return":
                stmt["value"] = {"kind": "const", "type": "u32", "value": 0}
                edits += 1
            return True

        if mutation == "swap-snapshotted-arguments":
            bindings = [s for s in main["body"] if s["kind"] == "set"
                        and s["name"] in ("p107_i0_v_a", "p107_i0_v_b")]
            assert len(bindings) == 2
            bindings[0]["value"], bindings[1]["value"] = bindings[1]["value"], bindings[0]["value"]
            edits = 1
        else:
            main["body"] = walk_bodies(main["body"], change)
        assert edits == 1, (mutation, edits)
        expected = next(r["expected"] for r in controls(name) if r["args"] == args)
        assert reference.Interpreter(original).run(args)["value"] == expected
        actual = reference.Interpreter(mutant).run(args)["value"]
        assert actual != expected, (mutation, actual, expected)
        results.append(dict(mutation=mutation, fixture=name, args=args, expected=expected,
                            mutantValue=actual, detected=True, scope="emitted IR"))
    return results


def audit_tail(name, before, after):
    assert nodes(after) <= nodes(before) + 4096
    assert before["entry"] == after["entry"]
    assert [f["name"] for f in before["functions"]] == [f["name"] for f in after["functions"]]
    if name in ("tail_nontail", "tail_dead", "tail_existingloop", "tail_pointer", "tail_mutual", "shared", "shared_borrow"):
        assert before == after, "unsupported tail shape changed"
    elif name in ("tail_sum", "tail_snapshot", "tail_reset"):
        assert before != after, "expected self-tail function unchanged"
        changed = [(a, b) for a, b in zip(before["functions"], after["functions"]) if a != b]
        assert len(changed) == 1
        function = changed[0][1]
        assert function["body"][0]["kind"] == "while"

        def self_calls(value):
            if isinstance(value, list):
                return sum(map(self_calls, value))
            if not isinstance(value, dict):
                return 0
            return int(value.get("kind") == "call" and value.get("name") == function["name"]) + sum(self_calls(v) for v in value.values())

        assert self_calls(function["body"]) == 0
    data = json.loads((HERE / "tail-controls.json").read_text())
    rows = []
    for row in data["cases"]:
        if row["fixture"] != name or row.get("nativeOnly"):
            continue
        values = [reference.Interpreter(p).run(row["args"])["value"] for p in (before, after)]
        assert values == [row["expected"]] * 2, (name, row, values)
        rows.append(dict(args=row["args"], expected=row["expected"], values=values))
    return dict(fixture=name, before=nodes(before), after=nodes(after), observations=rows)


def prepare_laws(out):
    out.mkdir(parents=True, exist_ok=False)
    source = (HERE / "expand.bend").read_text()
    helper = re.search(r"(?m)^def nx_i_continuation\([^\n]+\n(?:  .*\n)+", source)
    assert helper, "safe continuation helper not found"
    candidate = "import Base\n\n" + (P106 / "ir/model.bend").read_text() + "\n" + helper[0]
    (out / "candidate.bend").write_text(candidate)
    (out / "laws.bend").write_bytes((HERE / "laws.bend").read_bytes())
    pins = [{"file": str(p), "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
            for p in (P106 / "ir/model.bend", HERE / "expand.bend", HERE / "laws.bend",
                      out / "candidate.bend", out / "laws.bend")]
    (out / "source.json").write_text(json.dumps(dict(files=pins, scope="exact safe helper only"), indent=2) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    pair = sub.add_parser("pair")
    pair.add_argument("fixture")
    pair.add_argument("before", type=Path)
    pair.add_argument("after", type=Path)
    pair.add_argument("budget", type=int)
    laws = sub.add_parser("prepare-laws")
    laws.add_argument("out", type=Path)
    args = parser.parse_args()
    if args.command == "prepare-laws":
        prepare_laws(args.out)
    else:
        print(json.dumps(audit_pair(args.fixture, json.loads(args.before.read_text()),
                                   json.loads(args.after.read_text()), args.budget), indent=2))
