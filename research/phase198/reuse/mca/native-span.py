"""Compare instructions and encodings for the emitted and native compiler products."""

import hashlib
import json
import re
import subprocess
from pathlib import Path

from prepare import BUILD, HERE, SYMBOL, pin


def span(path, first, last, length):
    output = subprocess.check_output(
        ["/usr/bin/objdump", "-dw", "--disassemble=" + SYMBOL, path], text=True,
    )
    instructions = []
    for line in output.splitlines():
        match = re.fullmatch(r"\s*([0-9a-f]+):\t([0-9a-f ]+)\t(.*)", line)
        if match:
            instructions.append((int(match[1], 16), bytes.fromhex(match[2]), match[3]))
    starts = [
        index for index, (_, _, text) in enumerate(instructions[:len(instructions)-length+1])
        if text == first and instructions[index + length - 1][2] == last
    ]
    assert len(starts) == 1, (path, starts)
    index = starts[0]
    selected = instructions[index:index+length]
    data = b"".join(raw for _, raw, _ in selected)
    offset = selected[0][0]
    assert instructions[index+length][0] == offset + len(data)
    first_address = instructions[0][0]
    return dict(
        object=pin(path), instructionOffset=index, symbolByteOffset=offset-first_address,
        bytes=len(data), sha256=hashlib.sha256(data).hexdigest(),
        instructions=[text for _, _, text in selected],
    )


def main():
    old_gas = BUILD / "phase197/discoveryBTiming01/tree-bitonic/project-baseline/program.o"
    old_native = BUILD / "phase195/native45-02/tree-bitonic/machine/program.o"
    emitted = BUILD / "phase198/reuse-fusion-emit04/tree-bitonic/program.o"
    live = BUILD / "phase198/portfolio-native45-01/tree-bitonic/machine/program.o"
    plan = json.loads((HERE / "plan.json").read_text())
    pairs = []
    for role, paths, first, last in [
        ("old", [old_gas, old_native], "mov    %rax,-0x19c0(%rbp)", "mov    %r10,%rdi"),
        ("new", [emitted, live], "lea    0x8(%r12,%rdx,8),%rdi", "add    $0x20,%r13"),
    ]:
        case = next(case for case in plan["cases"] if case["role"] == role)
        spans = [span(path, first, last, case["instructions"]) for path in paths]
        a, b = spans
        assert a["instructions"] == b["instructions"], role
        same_encoding = a["bytes"] == b["bytes"] and a["sha256"] == b["sha256"]
        if role == "new":
            assert same_encoding
        pairs.append(dict(role=role, matchedSlice=case["extracted"],
                          sameInstructions=True, sameEncoding=same_encoding, spans=spans))
    (HERE / "native-spans.json").write_text(json.dumps(pairs, indent=2) + "\n")
    broad = BUILD / "phase198/portfolio-live-broad01/report.json"
    report = json.loads(broad.read_text())
    assert report["complete"] and report["fullCatalog"] and len(report["cases"]) == 45
    rows = []
    for case in report["cases"]:
        if "tree-bitonic" not in case["id"]:
            continue
        summary = case["summary"]
        assert summary["complete"] and summary["admitted"] and len(case["samples"]) == 16
        assert all(s["correct"] and not s["lowResolution"] for s in case["samples"])
        medians = {role: stats["medianMs"] for role, stats in summary["stats"].items()}
        rows.append(dict(
            id=case["id"], args=case["point"]["runtimeArgs"],
            expected=case["point"]["expectedStdout"], mediansMs=medians,
            liveOverIncumbent=medians["live"] / medians["phase197"],
            liveOverMature=summary["ratios"]["live"],
        ))
    assert len(rows) == 3
    native_timing = dict(report=pin(broad), cpu=report["cpu"], rounds=report["rounds"], rows=rows)
    (HERE / "live-tree.json").write_text(json.dumps(native_timing, indent=2) + "\n")


if __name__ == "__main__":
    main()
