"""Insert the independently checked public-tail rule in an isolated x86 source tree."""

import argparse
import hashlib
import json
import shutil
import sys
import tarfile
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / "selfhost/tools/build"))
import source as src

P198 = ROOT / "research/phase198"
BUILD = ROOT / "selfhost/build/phase198"
PARENT = BUILD / "progress-portfolio01"
OWNER = Path("src/back/x86/branch-selection.bend")
MODULES = [P198 / "heap/select.bend", P198 / "heap/hook.bend"]
HOOK = ("def", "x190_step")
SIX = [("def", n) for n in ("x198h_public", "x198h_finish", "x198h_target",
                            "x198h_tail", "x198h_selected", "x190_step")]
RECEIPT = "selfhost/build/phase198/heap-api03/report.json"
RECEIPT_HASH = "d7912a39c02590294e4241fd2f5cb06d824721ba86d4d95307421b622903abe8"
PARENT_HASH = "72061fa57c75993b59eaf42e18c6b923eebea640c352d0f7b9cd1d27ce7be91d"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def blocks(data):
    rows = src.blocks(data)[1]
    items = {(r["kind"], r["name"]): r for r in rows}
    assert len(items) == len(rows)
    return items


def body(row):
    return row["data"][row["headerOffset"] - row["offset"]:].rstrip()


def source_rows():
    rows = {}
    for module in MODULES:
        rows.update(blocks(module.read_bytes()))
    assert list(rows) == SIX
    return rows


def archival_authority():
    with tarfile.open(P198 / "reuse/tail/receipts.tar.gz") as archive:
        data = archive.extractfile(RECEIPT).read()
    assert digest(data) == RECEIPT_HASH
    checked = json.loads(data)
    assert checked["kind"] == "bend-checked-hosted-api" and checked["complete"] and checked["checked"]
    assert not checked.get("error") and not checked.get("changedInputs")
    return checked


def capture():
    """Verify the retained full checked source once and certify the six executable bodies."""
    checked = archival_authority()
    for artifact in (checked["source"], checked["api"]):
        assert src.pin(artifact["file"]) == artifact
    source = blocks(Path(checked["source"]["file"]).read_bytes())
    portable = source_rows()
    assert all(body(source[k]) == body(portable[k]) for k in SIX)
    parent = (PARENT/"compiler.bend").read_bytes()
    assert digest(parent) == PARENT_HASH
    original = blocks(parent)
    assert not any(k in original for k in SIX if k != HOOK)
    assert body(blocks((PARENT/"maintained"/OWNER).read_bytes())[HOOK]) == body(original[HOOK])
    return dict(checkedReceipt=RECEIPT_HASH, checkedSource=checked["source"]["sha256"],
                checkedImage=checked["api"]["sha256"], parentAssembly=PARENT_HASH,
                modules={str(p.relative_to(ROOT)):digest(p.read_bytes()) for p in MODULES},
                previousHook=digest(body(original[HOOK])),
                checkedBodies={k[1]:digest(body(source[k])) for k in SIX})


def apply(stage):
    """Apply to a caller's staged maintained directory; other disjoint patches can run in any order."""
    stage = Path(stage).resolve()
    assert stage != (PARENT/"maintained").resolve()
    auth = json.loads((HERE/"tail-authority.json").read_text())
    checked = archival_authority()
    assert (auth["checkedReceipt"], auth["checkedSource"], auth["checkedImage"]) == (
        RECEIPT_HASH, checked["source"]["sha256"], checked["api"]["sha256"])
    additions = source_rows()
    assert all(digest(p.read_bytes()) == auth["modules"][str(p.relative_to(ROOT))] for p in MODULES)
    assert all(digest(body(additions[k])) == auth["checkedBodies"][k[1]] for k in SIX)
    owner = stage / OWNER
    old_bytes = owner.read_bytes()
    old = blocks(old_bytes)
    assert digest(body(old[HOOK])) == auth["previousHook"]
    assert not any(k in old for k in SIX if k != HOOK)
    slot = old[HOOK]
    payload = b"\n\n".join(p.read_bytes().strip() for p in MODULES)
    new_bytes = (old_bytes[:slot["offset"]] + b"\n" + payload + b"\n" +
                 old_bytes[slot["offset"] + len(slot["data"]):])
    new = blocks(new_bytes)
    assert new.keys() == old.keys() | additions.keys()
    assert all(body(new[k]) == body(old[k]) for k in old if k != HOOK)
    assert all(body(new[k]) == body(additions[k]) for k in additions)
    owner.write_bytes(new_bytes)
    return dict(owner=str(OWNER), parentOwner=digest(old_bytes), adaptedOwner=digest(new_bytes),
                replaced=[HOOK[1]], added=[k[1] for k in SIX if k != HOOK],
                checkedBodies=auth["checkedBodies"], checkedReceipt=RECEIPT_HASH)


def freeze(out):
    assert not out.exists()
    out.mkdir(parents=True)
    stage = out / "maintained"
    shutil.copytree(PARENT/"maintained", stage)
    audit = apply(stage)
    whole = src.maintained_assemble(stage/"src/compiler.json", stage, "x86")
    previous = (PARENT/"compiler.bend").read_bytes()
    assert digest(previous) == PARENT_HASH
    old, new = blocks(previous), blocks(whole)
    assert new.keys() - old.keys() == set(SIX) - {HOOK} and not (old.keys() - new.keys())
    assert {k for k in old if body(old[k]) != body(new[k])} == {HOOK}
    assert all(digest(body(new[k])) == audit["checkedBodies"][k[1]] for k in SIX)
    (out/"compiler.bend").write_bytes(whole)
    audit.update(parentSource=PARENT_HASH, source=digest(whole), bytes=len(whole),
                 unchangedExisting=len(old)-1, fullSourceCheck=False)
    (out/"audit.json").write_text(json.dumps(audit, indent=2)+"\n")
    print(json.dumps(audit))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--capture", action="store_true")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if args.capture:
        (HERE/"tail-authority.json").write_text(json.dumps(capture(), indent=2)+"\n")
    if args.out:
        freeze(args.out)
