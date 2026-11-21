"""Extract literal contiguous scheduling regions from the two generated workers."""

import hashlib
import json
import re
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / "selfhost/build"
SYMBOL = "p114r_FID_" + "".join(f"{ord(c)}_" for c in "$direct.warp")
METHOD = (
    "Exact contiguous scheduling suffixes on one dynamic Node/Node transition. "
    "Original begins after second take2 and stores pending work, new begins after "
    "raw-node guards and enqueues two slot-address pairs. Both stop before their "
    "unconditional transfer; no helper call, tag probe, branch or guessed call "
    "latency is fed to MCA."
)


def pin(path):
    return dict(file=str(path.relative_to(ROOT)), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def extract(role, path, label, begin, end, first, last):
    lines = path.read_text().splitlines()
    label_index = lines.index(label)
    start = lines.index(begin, label_index + 1)
    stop = lines.index(end, start + 1)
    assert all(line.startswith("  ") for line in lines[label_index + 1:stop + 1])
    selected = lines[start + 1:stop]
    assert selected[0] == first and selected[-1] == last
    assert all(not re.match(r"\s*(?:j\w*|callq?|retq?)\b", line) for line in selected)

    output = HERE / (role + ".s")
    output.write_text(".text\n# LLVM-MCA-BEGIN descend\n" + "\n".join(selected)
                      + "\n# LLVM-MCA-END descend\n")
    loads = sum(bool(re.match(r"\s*mov\w+\s+[-\d]*\(", line)) for line in selected)
    stores = sum(bool(re.match(r"\s*mov\w+\s+[^,]+,\s*[-\d]*\(", line)) for line in selected)
    return dict(
        role=role, program=pin(path), sourceLine1=start + 2, sourceLineLast=stop,
        label=label, after=begin, before=end, instructions=len(selected),
        memoryLoads=loads, memoryStores=stores, extracted=pin(output),
    )


def witness(old, new):
    fused = BUILD / "phase198/reuse-pairwise01/report.json"
    local = BUILD / "phase198/reuse-screen01/report.json"

    def counts(path):
        report = json.loads(path.read_text())
        assert report["complete"]
        return next(row for row in report["counts"] if row["args"] == [8, 0])

    full_count, local_count = counts(fused), counts(local)
    nodes = full_count["leaves"] - full_count["hits"]
    assert full_count["fallback"] == 0
    assert nodes == local_count["entries"] == local_count["hits"] == 2815
    return dict(
        fused=pin(fused), local=pin(local), args=[8, 0], roots=full_count["hits"],
        leaves=full_count["leaves"], swaps=full_count["swaps"], internal=nodes,
        modelSliceInstructionsSaved=nodes * (old["instructions"] - new["instructions"]),
        modelSliceLoadsSaved=nodes * (old["memoryLoads"] - new["memoryLoads"]),
        modelSliceStoresSaved=nodes * (old["memoryStores"] - new["memoryStores"]),
    )


def main():
    old = BUILD / "phase197/discoveryBTiming01/tree-bitonic/project-baseline/program.s"
    new = BUILD / "phase198/reuse-fusion-emit04/tree-bitonic/program.s"
    assert pin(old)["sha256"] == "cff945285617f74a49e16d558f1c79e363651cb244b0748b986e2459ca5f2dca"
    report = json.loads((new.parent.parent / "report.json").read_text())
    tree = next(case for case in report["cases"] if case["id"] == "tree-bitonic")
    assert report["complete"] and tree["assembly"]["sha256"] == pin(new)["sha256"]

    old_case = extract(
        "old", old, f".L{SYMBOL}_b20:", "  call p125_rt_take2",
        f"  jmp .L{SYMBOL}_loop", "  movq %rax, -6592(%rbp)", "  movq %r10, %rdi",
    )
    new_case = extract(
        "new", new, f".Lp198pair_{SYMBOL}_node:", f"  ja .Lp198pair_{SYMBOL}_miss",
        f"  jmp .Lp198pair_{SYMBOL}_scan", "  leaq 8(%r12,%rdx,8), %rdi", "  addq $32, %r13",
    )
    plan = dict(symbol=SYMBOL, method=METHOD, cases=[old_case, new_case],
                dynamicWitness=witness(old_case, new_case))
    (HERE / "plan.json").write_text(json.dumps(plan, indent=2) + "\n")


if __name__ == "__main__":
    main()
