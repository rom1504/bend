#!/usr/bin/env python3
"""Root-only observation of the frozen profile11301 runtime boundary binary."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, default=HERE / "array-pair-manifest01.json")
    args = parser.parse_args()
    if sorted(os.sched_getaffinity(0)) != [3]:
        raise ValueError("Root CPU3 process-tree guard required")
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / "selfhost/build/phase113"):
        raise ValueError("Fresh Phase113 output required")
    manifest_path = args.manifest.resolve()
    if not manifest_path.is_relative_to(HERE):
        raise ValueError("Control manifest must be within the independent controls directory")
    manifest = json.loads(manifest_path.read_text())
    for row in manifest["inputs"]:
        actual = pin(ROOT / row["file"])
        if any(actual[key] != row[key] for key in ("bytes", "sha256")):
            raise ValueError("Frozen runtime control changed: " + row["file"])
    out.mkdir(parents=True)
    (out / "manifest.json").write_bytes(manifest_path.read_bytes())
    (out / "method.py").write_bytes(Path(__file__).read_bytes())
    report = dict(kind="phase113-array-pair-boundary-observations", complete=False,
                  inputs=[pin(manifest_path), pin(__file__), pin(args.binary), pin(args.runtime)],
                  cases=[], scope=manifest["scope"])
    def save():
        (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    save()
    try:
        for case in manifest["cases"]:
            name = case["name"]
            command = [str(args.binary.resolve()), name]
            row = dict(name=name, command=command, expected=case["expected"])
            report["cases"].append(row)
            save()
            start = time.monotonic()
            with (out / (name + ".stdout")).open("xb") as so, \
                 (out / (name + ".stderr")).open("xb") as se:
                child = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se, timeout=10)
            row["seconds"] = time.monotonic() - start
            row["observed"] = dict(status=child.returncode,
                stdout=(out / (name + ".stdout")).read_text(),
                stderr=(out / (name + ".stderr")).read_text())
            row["pass"] = row["observed"] == row["expected"]
            save()
            print(json.dumps(dict(name=name, passed=row["pass"])), flush=True)
        report["complete"] = all(row["pass"] for row in report["cases"])
        for row in report["inputs"]:
            if pin(row["file"]) != row:
                raise ValueError("Execution input changed: " + row["file"])
    except BaseException as error:
        report["error"] = repr(error)
        raise
    finally:
        save()
    if not report["complete"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
