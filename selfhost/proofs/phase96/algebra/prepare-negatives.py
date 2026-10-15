#!/usr/bin/env python3
"""Prepare immutable mutation snapshots and serial root-run jobs; run no target."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / "selfhost/build/phase96"


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def verify(item):
    assert pin(item["file"]) == item, item["file"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--proof-report", type=Path,
                        default=BUILD / "algebra-all03/report.json")
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    accepted = json.loads(args.proof_report.read_text())
    assert accepted["complete"] and accepted["independentlyChecked"]
    assert len(accepted["lawNames"]) == 21
    frozen = {}
    for item in accepted["sourceClosure"]:
        verify(item["snapshot"])
        verify(item["origin"])
        relative = Path(item["origin"]["file"]).relative_to(HERE)
        frozen[relative] = Path(item["snapshot"]["file"]).read_bytes()
    assert Path("all.bend") in frozen and Path("phase94/helper.bend") in frozen
    specs_path = HERE / "mutations.json"
    specs = json.loads(specs_path.read_text())
    assert len(specs["mutations"]) == 6
    checker = ROOT / "selfhost/tools/laws/phase96/check.py"
    out.mkdir(parents=True)
    jobs, cases = [], []

    def clone(name):
        folder = out / name
        folder.mkdir()
        for relative, data in frozen.items():
            target = folder / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        return folder

    def job(name, source, expected, classification, requires=None):
        target = out / "checks" / name
        jobs.append(dict(name=name, source=pin(source), expectedExit=expected,
                         classification=classification, requires=requires or [],
                         command=[sys.executable, "-B", str(checker), "--source", str(source),
                                  "--out", str(target), "--source-only"],
                         evidence=str(target / "report.json")))

    for spec in specs["mutations"]:
        folder = clone(spec["name"])
        target = folder / spec["file"]
        before = target.read_text()
        assert before.count(spec["old"]) == 1
        before_pin = pin(target)
        target.write_text(before.replace(spec["old"], spec["new"], 1))
        cases.append(dict(name=spec["name"], spec=spec, before=before_pin, after=pin(target)))
        if spec["kind"].startswith("wrong helper"):
            positive = spec["name"] + "-helper"
            job(positive, target, 0, "well-formed safe semantic mutant; no laws")
            job(spec["name"] + "-law", folder / "environment.bend", 1,
                "frozen environment law rejects well-formed wrong helper", [positive])
        else:
            job(spec["name"] + "-law", folder / spec["file"], 1,
                "false public statement with original proof body")

    constants = clone("constant-observers")
    negative_inputs = []
    for name in ["constant-helpers.bend", "reject-constant-membership.bend", "reject-constant-filter.bend"]:
        source = HERE / "negative-controls" / name
        target = constants / "negative-controls" / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        negative_inputs.append(pin(source))
    job("constant-observers-helper", constants / "negative-controls/constant-helpers.bend", 0,
        "well-formed safe constant membership/filter mutants; no laws")
    for name, source in [("membership", "reject-constant-membership.bend"),
                         ("filter", "reject-constant-filter.bend")]:
        job("constant-" + name + "-anchor", constants / "negative-controls" / source, 1,
            "semantic anchor rejects well-formed constant observer", ["constant-observers-helper"])

    method = pin(Path(__file__))
    files = [pin(f) for f in sorted(out.rglob("*")) if f.is_file()]
    report = dict(schema="phase96-algebra-negative-plan-v1", targetsRun=False,
                  acceptedProof=pin(args.proof_report), method=method, checker=pin(checker),
                  specs=pin(specs_path), negativeInputs=negative_inputs,
                  sourceClosure=accepted["sourceClosure"], cases=cases, jobs=jobs, files=files,
                  interpretation=[
                      "Execute jobs serially, and require each dependency to pass before its negative.",
                      "Expected exit 1 alone is insufficient: inspect the retained checker report and inner check stdout.",
                      "Require a completed source-check rejection, not timeout, memory stop, parse error or missing import.",
                      "Helper-body and constant mutants must pass their separate law-free source checks first.",
                      "False-statement negatives are counted separately from semantic helper mutations.",
                      "These are frontend rejection controls; no independent kernel mutation verdict is claimed."])
    (out / "plan.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(dict(out=str(out), cases=len(cases) + 2, jobs=len(jobs), targetsRun=False)))


if __name__ == "__main__":
    main()
