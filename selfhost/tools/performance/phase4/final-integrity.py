#!/usr/bin/env python3
"""Read-only identities for the frozen Phase 4 source and compiler artifacts."""
import datetime
import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[4]
BUILD = ROOT / "selfhost/build/phase4"
PIN = "6018e28ecc67cf1fffc0c20c64b11023474c2df8"


def identity(file):
    file = pathlib.Path(file).absolute()
    data = file.read_bytes()
    return {"file": str(file), "canonicalPath": str(file.resolve()),
            "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}


def git(*args, cwd=ROOT):
    # File-backed capture avoids this environment's synchronous pipe anomaly.
    with tempfile.TemporaryFile() as output, tempfile.TemporaryFile() as error:
        result = subprocess.run(["git", *args], cwd=cwd, stdout=output, stderr=error)
        output.seek(0)
        error.seek(0)
        assert result.returncode == 0, error.read().decode()
        return output.read().decode().strip()


def run(destination):
    report = {"kind": "phase4-final-frozen-artifact-integrity", "complete": False,
              "started": datetime.datetime.now(datetime.timezone.utc).isoformat(),
              "scope": "Read-only identity audit. No compiler, conformance or performance run.",
              "tool": identity(__file__), "modules": [], "artifacts": {}}
    try:
        checked_file = BUILD / "combined-checked/report.json"
        proof_file = BUILD / "combined-fixedpoint/report.json"
        checked = json.loads(checked_file.read_bytes())
        proof = json.loads(proof_file.read_bytes())
        report["checkedReport"] = identity(checked_file)
        report["fixedpointReport"] = identity(proof_file)
        assert checked["complete"] and checked["inputsUnchanged"]
        assert checked["requestedRootsExist"] and proof["complete"]
        assert len(checked["modules"]) == 59
        assert len({item["relative"] for item in checked["modules"]}) == 59
        for item in checked["modules"]:
            current = identity(ROOT / "selfhost" / item["relative"])
            frozen = identity(item["destination"])
            assert current["sha256"] == frozen["sha256"] == item["sha256"]
            report["modules"].append({"relative": item["relative"],
                                      "current": current, "frozen": frozen})
        artifacts = {
            "source": (checked["source"]["file"], "34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122"),
            "checkedB1": (checked["api"]["file"], "0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810"),
            "runtime": (ROOT / "selfhost/src/runtime.mjs", "26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b"),
            "base": (proof["base"]["file"], "b8c2734d45ec6b4ce70fee70ff06ef35e08fce885af8852d8eb77dbff020e946"),
            "privateDefault": (BUILD / "private/canonical-integration2/default/image.mjs", "61e7d94c19bbda2de2a55037d5e2b992868a145ab6f29d557f4bc0885e759cb1"),
            "privateProfile": (BUILD / "private/canonical-integration2/combined/image.mjs", "4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3"),
            "derivedB1": (BUILD / "b1-native-equality/prepared/candidate.mjs", "e95e119847307aa215765fcbea63d3b9e4a2bba625f3d30a915f298eb6ed9821"),
        }
        assert len(proof["stages"]) == 2
        for number, stage in enumerate(proof["stages"], 2):
            assert stage["code"] == 0 and stage["signal"] is None and stage["inputsVerified"]
            artifacts[f"stage{number}"] = (stage["output"], "b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8")
        for label, (file, expected) in artifacts.items():
            actual = identity(file)
            assert actual["sha256"] == expected, label
            report["artifacts"][label] = actual
        assert pathlib.Path(proof["stages"][0]["output"]).read_bytes() == pathlib.Path(proof["stages"][1]["output"]).read_bytes()
        assert checked["source"]["sha256"] == proof["sourceSha256"] == proof["sourceIdentity"]["sha256"]
        assert checked["api"]["sha256"] == proof["initialCompiler"]["sha256"] == proof["stages"][0]["compilerSha256"]
        assert proof["stages"][1]["compilerSha256"] == report["artifacts"]["stage2"]["sha256"]
        upstream = ROOT / "selfhost/.bootstrap/upstream"
        assert git("rev-parse", "HEAD", cwd=upstream) == PIN
        assert git("status", "--porcelain", "--untracked-files=no", cwd=upstream) == ""
        unchanged = ["bend2/bend.ts", "selfhost/dist", "selfhost/src/runtime.mjs"]
        assert git("diff", "--name-only", "89e2c83", "--", *unchanged) == ""
        report["reference"] = {"pin": PIN, "trackedCheckoutUnchanged": True}
        report["unchangedSinceStartingRevision"] = {"revision": "89e2c83", "paths": unchanged}
        report["repositoryHeadAtAudit"] = git("rev-parse", "HEAD")
        report["complete"] = True
    except Exception as error:
        report["error"] = repr(error)
    report["finished"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    with pathlib.Path(destination).open("x") as output:
        json.dump(report, output, indent=2)
        output.write("\n")
    print(json.dumps({"complete": report["complete"], "modules": len(report["modules"]),
                      "error": report.get("error")}))
    return 0 if report["complete"] else 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: final-integrity.py NEW_REPORT.json")
    raise SystemExit(run(sys.argv[1]))
