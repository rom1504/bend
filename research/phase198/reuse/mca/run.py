"""Run the acquired LLVM 11 Ivy Bridge scheduler model on pinned program regions."""

import argparse
import hashlib
import json
import os
import re
import subprocess
import time
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
METRICS = (
    "Iterations", "Instructions", "Total Cycles", "Total uOps",
    "Dispatch Width", "IPC", "Block RThroughput",
)


def verify(record):
    path = ROOT / record["file"]
    assert path.stat().st_size == record["bytes"], path
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record["sha256"], path
    return path


def measure(out, tool, asm, case, iterations, no_alias):
    command = [
        str(tool), "-mtriple=x86_64-unknown-linux-gnu", "-mcpu=ivybridge",
        f"-iterations={iterations}", "-noalias=" + str(no_alias).lower(), str(asm),
    ]
    start = time.monotonic()
    process = subprocess.run(command, capture_output=True, text=True, timeout=2)
    elapsed = time.monotonic() - start
    mode = "noalias" if no_alias else "mayalias"
    stem = f"{case['role']}-{iterations}-{mode}"
    (out / (stem + ".stdout")).write_text(process.stdout)
    (out / (stem + ".stderr")).write_text(process.stderr)
    assert process.returncode == 0 and not process.stderr, process.stderr

    fields = {}
    for name in METRICS:
        match = re.search(r"^" + name + r":\s*([\d.]+)\s*$", process.stdout, re.M)
        assert match, name
        fields[name] = float(match[1])
    assert fields["Iterations"] == iterations
    assert fields["Instructions"] == case["instructions"] * iterations
    return dict(role=case["role"], iterations=iterations, noAlias=no_alias,
                metrics=fields, seconds=elapsed, argv=command)


def main(out):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir()
    cpu = Path("/proc/cpuinfo").read_text().split("\n\n")[0]
    assert re.search(r"^cpu family\s*:\s*6$", cpu, re.M)
    assert re.search(r"^model\s*:\s*58$", cpu, re.M)
    acquisition = ROOT / "selfhost/build/phase195/hardware-tool01/acquisition.json"
    receipt = json.loads(acquisition.read_text())
    tool = verify(receipt["tool"])
    for library in receipt["libraries"]:
        verify(library)

    plan = json.loads((HERE / "plan.json").read_text())
    rows = []
    for case in plan["cases"]:
        asm = verify(case["extracted"])
        verify(case["program"])
        for iterations, no_alias in ((1, False), (100, False), (100, True)):
            rows.append(measure(out, tool, asm, case, iterations, no_alias))

    result = dict(
        complete=True, tool=receipt["tool"], libraries=receipt["libraries"],
        model="ivybridge", cpu=re.search(r"^model name\s*:\s*(.+)$", cpu, re.M)[1],
        scope=plan["method"], rows=rows,
    )
    (out / "report.json").write_text(json.dumps(result, indent=2) + "\n")
    for row in rows:
        print(row["role"], row["iterations"], row["noAlias"], row["metrics"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    main(parser.parse_args().out)
