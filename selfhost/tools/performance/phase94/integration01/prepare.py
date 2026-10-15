#!/usr/bin/env python3
"""Prepare an isolated Phase94 candidate; never invoke a compiler or edit inputs.

  python3 prepare.py --out /fresh/builddir --with-controls
  python3 prepare.py --replay /fresh/builddir/changes.json --out /fresh/replaydir

The canonical bridge.patch is a review artifact, not applied by this script.
"""
import argparse
import difflib
import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / "selfhost/build/phase92/upstream-checked01/compiler.bend"
PROOF = ROOT / "selfhost/build/phase94/proof-frozen01"
BRIDGE = ROOT / "selfhost/src/back/native/bridge.bend"
SOURCE_SHA = "d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097"
BRIDGE_SHA = "d2165a184703a0e2c9355f6cf1081b5582c9f34dd0cb22757495e8bc8fd30358"
PROOF_SHAS = {
    "helper.bend": "52eda588add346afdb6cd9d9fa64d7bf9e5cd27db2863fe0244d82be840b3887",
    "reference.bend": "c5686a6c0d166a4285a01f0b41bf1acfb470c62274f29abc8ad64346d03c84d1",
    "proof.bend": "5758d62ec0993d9cc8678929e800170b9b38f919592270827a0958bc41518745",
}
IMPORT = b"import Base\n"
ATOM_ANCHOR = b"@unsafe\ndef nc_let_atom("
ATOM_OLD = (
    b"  +held = nc_live_uses(env, bodyUses)\n"
    b"  +rest = nc_lower_partition(book, body, n, NC_Scheduler{}, nc_partition_uses(List.append(&2, NC_Binding, held, [nk_binding(id, value, env)]), bodyUses))\n"
)
ATOM_NEW = b"  +rest = nc_lower_partition(book, body, n, NC_Scheduler{}, nc_env_extend(env, bodyUses, nk_binding(id, value, env)))\n"
EMITTED_OLD = b"      +rest = nc_lower_partition(book, body, n, NC_Scheduler{}, nc_partition_uses(List.append(&2, NC_Binding, nc_live_uses(env, bodyUses), [nk_binding(id, value, env)]), bodyUses))\n"
EMITTED_NEW = b"      +rest = nc_lower_partition(book, body, n, NC_Scheduler{}, nc_env_extend(env, bodyUses, nk_binding(id, value, env)))\n"
MAIN_OLD = (
    b"@unsafe\ndef main() -> IO(U32):\n"
    b"  do IO<U32>:\n"
    b"    args : List<&1,String> <- IO.args()\n"
    b"    p86_cli(args)\n"
)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def identity(path, data=None):
    data = path.read_bytes() if data is None else data
    return {"file": str(path.resolve()), "bytes": len(data), "sha256": digest(data)}


def authenticated(path, expected):
    data = path.read_bytes()
    require(digest(data) == expected, "input identity changed: " + str(path))
    return data


def splice(data, label, old, new, changes):
    require(data.count(old) == 1, label + ": expected exactly one original span")
    offset = data.index(old)
    result = data[:offset] + new + data[offset + len(old):]
    changes.append({
        "label": label,
        "offsetBytes": offset,
        "beforeSha256": digest(data),
        "afterSha256": digest(result),
        "oldSha256": digest(old),
        "newSha256": digest(new),
        "old": old.decode("utf-8"),
        "new": new.decode("utf-8"),
    })
    return result


def replay(data, changes):
    for row in changes:
        old, new = row["old"].encode("utf-8"), row["new"].encode("utf-8")
        require(digest(old) == row["oldSha256"], "replay old-span hash changed")
        require(digest(new) == row["newSha256"], "replay new-span hash changed")
        require(digest(data) == row["beforeSha256"], "replay input hash changed")
        offset = row["offsetBytes"]
        require(data[offset:offset + len(old)] == old, "replay original span changed")
        data = data[:offset] + new + data[offset + len(old):]
        require(digest(data) == row["afterSha256"], "replay output hash changed")
    return data


def integrate(data, helper_body, adapters, canonical=False):
    changes = []
    require(b"def npe_extend(" not in data, "helper already present")
    require(b"def nc_env_extend(" not in data, "adapter already present")
    if canonical:
        anchor = b"type NC_Literal is Data:\n"
        data = splice(data, "embed-exact-checked-helper", anchor, helper_body + b"\n" + anchor, changes)
    else:
        require(data.startswith(IMPORT), "compiler import prefix changed")
        data = splice(data, "embed-exact-checked-helper", IMPORT, IMPORT + helper_body + b"\n", changes)
    data = splice(data, "insert-concrete-adapters", ATOM_ANCHOR, adapters + b"\n" + ATOM_ANCHOR, changes)
    data = splice(data, "fuse-nc_let_atom-environment", ATOM_OLD, ATOM_NEW, changes)
    data = splice(data, "fuse-nc_let_emitted-environment", EMITTED_OLD, EMITTED_NEW, changes)
    require(data.count(helper_body) == 1, "checked helper body must occur exactly once")
    require(data.index(helper_body) < data.index(b"def nc_env_plan_hit("), "helper must precede adapters")
    require(data.index(b"def nc_env_plan_hit(") < data.index(b"def nc_env_extend("), "callback must precede instantiation")
    require(data.index(b"def nc_env_extend(") < data.index(b"def nc_let_atom("), "adapter must precede calls")
    return data, changes


def write_new(path, data):
    with path.open("xb") as handle:
        handle.write(data)


def save(path, obj):
    write_new(path, (json.dumps(obj, indent=2) + "\n").encode("utf-8"))


def prepare(args):
    source = authenticated(args.source, SOURCE_SHA)
    bridge = authenticated(args.bridge, BRIDGE_SHA)
    proof_files = {name: authenticated(args.proof_dir / name, sha) for name, sha in PROOF_SHAS.items()}
    helper = proof_files["helper.bend"]
    require(helper.startswith(IMPORT), "checked helper import prefix changed")
    helper_body = helper[len(IMPORT):]  # This is the ONLY transformation of the checked helper.
    adapters = (HERE / "adapters.bend").read_bytes()
    candidate, changes = integrate(source, helper_body, adapters)
    canonical, canonical_changes = integrate(bridge, helper_body, adapters, canonical=True)
    require(replay(source, changes) == candidate, "candidate forward replay failed")
    require(replay(bridge, canonical_changes) == canonical, "canonical forward replay failed")
    patch = "".join(difflib.unified_diff(
        bridge.decode("utf-8").splitlines(keepends=True),
        canonical.decode("utf-8").splitlines(keepends=True),
        fromfile="a/selfhost/src/back/native/bridge.bend",
        tofile="b/selfhost/src/back/native/bridge.bend",
    )).encode("utf-8")
    outputs = {
        "compiler.bend": candidate,
        "bridge.candidate.bend": canonical,
        "bridge.patch": patch,
        "helper.embedded.bend": helper_body,
    }
    report = {
        "schema": "phase94-exact-source-splices-v1",
        "method": identity(Path(__file__)),
        "source": identity(args.source, source),
        "proofInputs": [identity(args.proof_dir / name, data) for name, data in proof_files.items()],
        "adapters": identity(HERE / "adapters.bend", adapters),
        "helperTransformation": {"removedPrefix": IMPORT.decode(), "embeddedBytes": len(helper_body), "embeddedSha256": digest(helper_body)},
        "changes": changes,
        "canonical": {"source": identity(args.bridge, bridge), "changes": canonical_changes, "candidateSha256": digest(canonical)},
        "candidateSha256": digest(candidate),
        "forwardReplayExact": True,
        "targetsRun": False,
        "scope": "Only immediate atom and emitted-value environment preparation; nc_let_cut and all guards remain as source.",
    }
    if args.with_controls:
        entry = (HERE / "edge-controls.bend").read_bytes()
        expected = (HERE / "edge-controls.expected.txt").read_bytes()
        control_changes = []
        controls = splice(candidate, "replace-cli-with-edge-controls", MAIN_OLD, entry, control_changes)
        require(replay(candidate, control_changes) == controls, "control forward replay failed")
        outputs["edge-controls.bend"] = controls
        outputs["edge-controls.expected.txt"] = expected
        report["controls"] = {
            "entry": identity(HERE / "edge-controls.bend", entry),
            "expected": identity(HERE / "edge-controls.expected.txt", expected),
            "changes": control_changes,
            "candidateSha256": digest(controls),
            "status": "prepared-not-executed",
        }
    args.out.mkdir(parents=True, exist_ok=False)
    for name, data in outputs.items():
        write_new(args.out / name, data)
    report["outputs"] = {name: identity(args.out / name, data) for name, data in outputs.items()}
    save(args.out / "changes.json", report)
    print(json.dumps({"out": str(args.out), "candidateSha256": digest(candidate), "forwardReplayExact": True, "targetsRun": False}))


def replay_manifest(args):
    report = json.loads(args.replay.read_text())
    require(report["schema"] == "phase94-exact-source-splices-v1", "unsupported replay schema")
    require(report["source"]["sha256"] == SOURCE_SHA, "replay is not the frozen D04 source")
    source = authenticated(args.source, SOURCE_SHA)
    candidate = replay(source, report["changes"])
    require(digest(candidate) == report["candidateSha256"], "final replay identity changed")
    args.out.mkdir(parents=True, exist_ok=False)
    write_new(args.out / "compiler.bend", candidate)
    replayed = {"manifest": identity(args.replay), "source": identity(args.source, source), "candidate": identity(args.out / "compiler.bend", candidate), "forwardReplayExact": True, "targetsRun": False}
    if "controls" in report:
        controls = replay(candidate, report["controls"]["changes"])
        require(digest(controls) == report["controls"]["candidateSha256"], "control replay identity changed")
        write_new(args.out / "edge-controls.bend", controls)
        replayed["controls"] = identity(args.out / "edge-controls.bend", controls)
    save(args.out / "replay.json", replayed)
    print(json.dumps({"out": str(args.out), "candidateSha256": digest(candidate), "forwardReplayExact": True, "targetsRun": False}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--proof-dir", type=Path, default=PROOF)
    parser.add_argument("--bridge", type=Path, default=BRIDGE)
    parser.add_argument("--with-controls", action="store_true")
    parser.add_argument("--replay", type=Path)
    args = parser.parse_args()
    args.out = args.out.resolve()
    require(not args.out.exists(), "output directory must be fresh")
    if args.replay:
        replay_manifest(args)
    else:
        prepare(args)


if __name__ == "__main__":
    main()
