"""Check and retain the exact RLE runtime screen, tool pins, and ownership controls."""

import argparse
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / "selfhost/build"


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    name = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)
    return dict(file=name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(path.read_text())


def main(name):
    assert name.startswith("reuse-reverse") and "/" not in name
    directory = BUILD / "phase198" / name
    guard = BUILD / "phase198" / (name + "-guard")
    seal = ROOT / "selfhost/build-retention/phase198" / (name + "-close") / "report.json"
    proc, closure, report = read(guard/"process.json"), read(seal), read(directory/"report.json")
    assert proc["complete"] and proc["returncode"] == 0
    assert closure["complete"] and closure["classification"] == "completed" and report["complete"]
    native_path = BUILD/"phase195/native45-02/test-rle-roundtrip/machine/report.json"
    reference_path = BUILD/"phase195/references01/manifest.json"
    assets_path = BUILD/"phase194/assets.json"
    native = read(native_path)
    reference = next(c for c in read(reference_path)["cases"] if c["id"] == "test-rle-roundtrip")
    assets = read(assets_path)["assets"]
    assert native["object"] == report["original"]
    command = list(native["compilerCommand"])
    assert command[8] == "x86-object"
    command[8] = "x86"
    assert command == report["command"]
    assert report["driver"] == pin(HERE/"screen.py")["sha256"]
    for src in ("rotate.c","control.c"):
        assert report["sources"][src] == pin(HERE/src)["sha256"]
    for role in ("baseline", "candidate"):
        key = role + ".s"
        assert report["sources"][key] == pin(directory/key)["sha256"]
    for label, products in report["products"].items():
        assert products["binary"] == pin(directory/label)["sha256"]
        assert products["object"] == pin(directory/(label+".o"))["sha256"]
    inputs = [native["object"], native["binary"], *native["inputs"], reference["source"],
              reference["expectedFile"], reference["products"]["c"]["artifact"],
              *reference["products"]["c"]["inputs"], *[assets[k] for k in ("assembler","linker","qbe-runtime")]]
    for record in inputs:
        a = pin(ROOT/record["file"])
        assert a["bytes"] == record["bytes"] and a["sha256"] == record["sha256"]
    assert len(report["samples"]) == 30 and len(report["checks"]) == 2
    assert all(s["elapsedMs"] >= 100 for s in report["samples"])
    brief = dict(
        kind="phase198-named-owned-spine-screen", complete=True, run=name,
        status="Named C runtime projection; checked generic compiler rule has not been acquired.",
        inputs=[pin(native_path),pin(reference_path),pin(assets_path),*inputs],
        runReceipt=pin(directory/"report.json"), guard=pin(guard/"process.json"), seal=pin(seal),
        events=report["events"], ownershipControls=report["boundaries"],
        summary=report["summary"], sampleCount=len(report["samples"]),
        wallSeconds=proc["wallSeconds"], method=pin(Path(__file__).resolve()),
    )
    (HERE/"result.json").write_text(json.dumps(brief, indent=2) + "\n")
    raw = [directory/"report.json", directory/"boundaries.stderr", directory/"events.stderr",
           guard/"process.json", guard/"retention.json", seal]
    with (HERE/"receipts.tar.gz").open("wb") as target:
        with gzip.GzipFile(fileobj=target, mode="wb", mtime=0, filename="") as payload:
            with tarfile.open(fileobj=payload, mode="w") as archive:
                for file in raw:
                    data = file.read_bytes()
                    member = tarfile.TarInfo(str(file.relative_to(ROOT)))
                    member.size, member.mode = len(data), 0o644
                    archive.addfile(member, io.BytesIO(data))
    print(brief["events"], brief["ownershipControls"], brief["summary"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", required=True)
    main(parser.parse_args().run)
