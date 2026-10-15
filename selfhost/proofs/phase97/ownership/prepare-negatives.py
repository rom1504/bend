#!/usr/bin/env python3
"""Copy an accepted proof closure and prepare semantic mutants; run no target."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / "selfhost/build/phase97"


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--proof-report", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    accepted = json.loads(args.proof_report.read_text())
    assert accepted["complete"] and accepted["independentlyChecked"]
    assert len(accepted["lawNames"]) == 7
    assert not accepted["opaqueDefinitions"]
    frozen = {}
    for row in accepted["sourceClosure"]:
        assert pin(row["origin"]["file"]) == row["origin"]
        assert pin(row["snapshot"]["file"]) == row["snapshot"]
        relative = Path(row["origin"]["file"]).relative_to(HERE)
        frozen[relative] = Path(row["snapshot"]["file"]).read_bytes()
    assert set(frozen) == {Path(name) for name in
                           ["model.bend", "protocol.bend", "local.bend", "composition.bend"]}
    specs_path = HERE / "mutations.json"
    specs = json.loads(specs_path.read_text())
    checker = ROOT / "selfhost/tools/laws/phase97/check.py"
    out.mkdir(parents=True)
    cases, jobs = [], []
    for spec in specs["mutations"]:
        folder = out / spec["name"]
        folder.mkdir()
        for relative, data in frozen.items():
            (folder / relative).write_bytes(data)
        target = folder / specs["file"]
        before = pin(target)
        source = target.read_text()
        assert source.count(specs["old"]) == 1
        target.write_text(source.replace(specs["old"], spec["new"], 1))
        cases.append(dict(name=spec["name"], spec=spec, before=before, after=pin(target)))
        helper_name = spec["name"] + "-helper"
        for name, entry, expected, requires, kind in [
            (helper_name, target, 0, [], "well-formed safe semantic helper mutant"),
            (spec["name"] + "-law", folder / specs["frozenLawEntry"], 1,
             [helper_name], "unchanged preservation law rejects semantic helper mutant"),
        ]:
            check_out = out / "checks" / name
            jobs.append(dict(name=name, source=pin(entry), expectedExit=expected,
                             requires=requires, classification=kind,
                             command=[sys.executable, "-B", str(checker), "--source", str(entry),
                                      "--out", str(check_out), "--source-only"],
                             evidence=str(check_out / "report.json")))
    plan = dict(schema="phase97-ownership-negative-plan-v1", targetsRun=False,
                acceptedProof=pin(args.proof_report), method=pin(__file__),
                checker=pin(checker), specs=pin(specs_path),
                sourceClosure=accepted["sourceClosure"], cases=cases, jobs=jobs,
                files=[pin(path) for path in sorted(out.rglob("*.bend"))],
                interpretation=[
                    "Execute serially; admit each law-free helper before testing its unchanged law.",
                    "Exit 1 alone is insufficient: inspect the inner check stdout for a proof mismatch in temporary_read_preserves.",
                    "Timeout, memory stop, missing imports, syntax and usage errors do not count as semantic rejection.",
                    "These negatives are source-check controls; do not call them independent kernel rejection."])
    (out / "plan.json").write_text(json.dumps(plan, indent=2) + "\n")
    print(json.dumps(dict(out=str(out), cases=len(cases), jobs=len(jobs), targetsRun=False)))


if __name__ == "__main__":
    main()
