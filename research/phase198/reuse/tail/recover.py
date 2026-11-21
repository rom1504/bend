"""Independently close the saved authenticated product rows from the timed-out batch."""

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / "selfhost/build/phase198"
HEAP = ROOT / "research/phase198/heap"
ORIGINAL = BUILD / "heap-pair-emission01"
CASES = ["test-map-set-ops", "lexer"]


def read(path):
    return json.loads(Path(path).read_text())


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def records(value):
    if isinstance(value, dict):
        if {"file", "bytes", "sha256"} <= value.keys():
            yield {k: value[k] for k in ("file", "bytes", "sha256")}
        for child in value.values():
            yield from records(child)
    elif isinstance(value, list):
        for child in value:
            yield from records(child)


def authenticate(*values):
    verified = {}
    for value in values:
        for item in records(value):
            key = str((ROOT / item["file"]).resolve())
            canonical = dict(item, file=key)
            if key in verified:
                assert verified[key] == canonical, key
            else:
                assert pin(key) == canonical, key
                verified[key] = canonical
    return list(verified.values())


def tail_sites(obj):
    command = ["/usr/bin/objdump", "-dr", "--no-show-raw-insn", obj["file"]]
    text = subprocess.check_output(command, text=True)
    caller = None
    rows = []
    history = []
    for line in text.splitlines():
        symbol = re.fullmatch(r"[0-9a-f]+ <(.+)>:", line)
        if symbol:
            caller = symbol[1]
            history = []
        relocation = re.fullmatch(r"\s*[0-9a-f]+:\s+R_X86_64_PC32\s+(p111_FID_\S+?)(?:-0x4)?", line)
        if relocation and history and history[-1][1] in ("jmp", "jmpq"):
            assert history[-3][1:] == ("mov", "%rbp,%rsp"), (obj, caller)
            assert history[-2][1:] == ("pop", "%rbp"), (obj, caller)
            assert any(op == "movl" and args == "$0xffffffff,0x20(%rdi)"
                       for _, op, args in history[-12:-3]), (obj, caller)
            rows.append(dict(caller=caller, address=history[-1][0], target=relocation[1]))
        ins = re.fullmatch(r"\s*([0-9a-f]+):\s+([a-z][a-z0-9]*)\s*(.*)", line)
        if ins:
            history.append((ins[1], ins[2], ins[3].replace(" ", "")))
    return rows


def main(out):
    assert not out.exists()
    original = read(ORIGINAL / "heap/report.json")
    batch = read(ORIGINAL / "report.json")
    historical = read(HEAP / "status.json")
    guard = read(BUILD / "heap-pair-emission01-guard/process.json")
    seal_path = ROOT / "selfhost/build-retention/phase198/heap-pair-emission01-close/report.json"
    seal = read(seal_path)
    assert not original["complete"] and not batch["complete"]
    assert not original.get("error") and not batch.get("error")
    assert guard["stoppedFor"] == "deadline" and guard["returncode"] != 0
    assert seal["complete"] and seal["classification"] == "failed"
    assert seal["process"]["sha256"] == historical["actualPair"]["guard"]["sha256"]
    assert pin(ORIGINAL / "heap/report.json")["sha256"] == historical["actualPair"]["receipt"]["sha256"]
    assert guard["command"][-4:] == ["--plan", "selfhost/build/phase198/heap-pair-plan02.json",
                                    "--out", "selfhost/build/phase198/heap-pair-emission01"]

    plan = read(batch["plan"]["file"])
    assert plan["complete"] and plan["kind"] == "phase195-shared-preparation-plan"
    assert [role["name"] for role in plan["roles"]] == ["heap"]
    producer, candidate = plan["producer"], plan["roles"][0]
    assert candidate["preparationIdentity"] == producer["preparationIdentity"] == batch["preparationIdentity"]
    assert candidate["bindingIdentity"] == producer["bindingIdentity"]
    assert original["sharedPreparation"]["plan"] == batch["plan"]
    assert original["sharedPreparation"]["producer"] == producer["receipt"]
    assert original["sharedPreparation"]["identity"] == candidate["preparationIdentity"]
    assert original["selected"] == CASES == [r["id"] for r in batch["cases"]]
    assert CASES == [c["id"] for c in plan["cases"]] == [r["id"] for r in original["rows"]]
    assert all(r["complete"] and 0 < r["transportObjects"] <= 2000000 for r in batch["cases"])
    assert all(r["complete"] and r["verified"] and r["sameTypedSequence"] for r in original["rows"])
    assert not plan["compareOrdinary"]
    # Match the complete inputs actually checked before emission and the complete
    # input set whose post-emission check was interrupted at the original deadline.
    expected = {p["file"]: p for p in [batch["plan"], *plan["inputs"]]}
    assert expected == {p["file"]: p for p in batch["inputs"]}
    local = dict(expected)
    del local[producer["receipt"]["file"]]
    assert local == {p["file"]: p for p in original["inputs"]}
    for role in (producer, candidate):
        authority = read(role["receipt"]["file"])
        assert authority["complete"] and authority["checked"] and not authority["error"]
        assert authority["api"] == role["api"] and authority["source"] == role["source"]
        assert all(x in authority["exports"] for x in
                   ["p88_cache_prepare", "p86_plan", "p169np_plan", "x181_prepared",
                    "x188_many", "x188_render", "x188_assemble"])

    controls_path = BUILD / "heap-controls03/report.json"
    controls = read(controls_path)
    assert controls["complete"] and controls["authority"]["receipt"] == candidate["receipt"]
    mapping_path = HEAP / "source-mapping.json"
    mapping = read(mapping_path)
    assert mapping["complete"] and mapping["otherSharedDeclarationsByteIdentical"]
    assert mapping["changedDeclarations"] == [["def", "x190_step"]]
    assert mapping["checkedCandidateApiReceipt"] == candidate["receipt"]
    native_path = BUILD / "native45-01/programs.manifest.json"
    native = read(native_path)
    assert native["roles"]["candidate"]["compilerSource"] == mapping["nativeBaselineSource"]
    # Historical status also contains old *failed* attempts. The specific product,
    # current control, and current acquisition citations are the relevant closure.
    checks = [historical["actualPair"], historical["checkedAPI"], historical["machineControls"],
              batch, original, plan, mapping, controls, read(candidate["receipt"]["file"]),
              read(producer["receipt"]["file"])]
    products = []
    for row, planned, prepared in zip(original["rows"], plan["cases"], batch["cases"]):
        baseline = next(c for c in native["cases"] if c["id"] == row["id"])
        reference = baseline["products"]["candidate"]
        for field in ("source", "expectedFile"):
            assert row[field] == planned[field] == prepared[field] == baseline[field]
        assert any(p["sha256"] == row["product"]["sha256"] and p["bytes"] == row["product"]["bytes"]
                   for p in historical["actualPair"]["products"])
        checks.extend([reference, baseline["source"], baseline["expectedFile"]])
        products.append(dict(id=row["id"], baseline=reference["generatedSource"],
                             candidate=row["product"], baselineBinary=reference["artifact"]))
    verified = authenticate(*checks)
    for prod, row in zip(products, original["rows"]):
        flags = {}
        for role in ("baseline", "candidate"):
            flags[role] = tail_sites(prod[role])
        assert not flags["baseline"]
        assert len(flags["candidate"]) == len(re.findall(
            r"^  jmp p111_FID_\S+$", Path(row["assembly"]["file"]).read_text(), re.M))
        assert len(flags["candidate"]) > 0
        prod["tailSites"] = flags
    out.mkdir()
    linking = [pin(p) for p in [__file__, ORIGINAL / "heap/report.json", ORIGINAL / "report.json",
                                BUILD / "heap-pair-emission01-guard/process.json", seal_path,
                                HEAP / "status.json", mapping_path, native_path, controls_path]]
    report = dict(
        kind="phase198-reverified-public-tail-products", complete=True, targetsRun=False,
        originalComplete=False, originalStop=guard["stoppedFor"], originalExit=guard["returncode"],
        originalGuardSeconds=guard["wallSeconds"], citations=linking,
        verifiedInputs=verified, batchInputs=len(batch["inputs"]), roleInputs=len(original["inputs"]),
        products=products, scope="Separate final hash verification of two completed checked emissions. "
        "The historical 45-second guard and original reports remain incomplete.",
    )
    write(out / "report.json", report)
    # The existing machine builder requires this documented checked-emission schema.
    # Its sole checked API remains the actual emitter; the producer and old incomplete
    # batch are fully identified in the independently verifiable recovery receipt.
    inputs = {p["file"]: p for p in original["inputs"]}
    for p in [*linking, pin(out / "report.json")]:
        inputs[p["file"]] = p
    fresh = dict(original, complete=True, inputs=list(inputs.values()),
                 recovery=pin(out / "report.json"), originalComplete=False,
                 scope="Fresh authenticated product materialization. " + report["scope"])
    write(out / "emission.json", fresh)
    print("Verified", len(verified), "distinct files and",
          [(r["id"], len(r["tailSites"]["candidate"])) for r in products], "tail sites")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    main(parser.parse_args().out)
