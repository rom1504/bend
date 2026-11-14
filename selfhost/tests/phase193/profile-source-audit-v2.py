#!/usr/bin/env python3
"""Offline canonical source/map comparison; no Bend/JS/compiler execution.

Uses the maintained source.py assembler against current sources and an exact
Git baseline. Baseline modules are byte-authenticated before unchanged files
are copied into a temporary overlay. All baseline files are
written only inside that overlay, satisfying source.py path confinement. Generated sources/maps remain in memory.
"""
import argparse
import hashlib
import importlib.util
import json
import subprocess
import tempfile
from pathlib import Path


def sha(data):
    return hashlib.sha256(data).hexdigest()


def identity(data):
    return {"bytes": len(data), "sha256": sha(data)}


def git(repo, *args, data=None):
    return subprocess.run(["git", "-C", str(repo), *args], input=data,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          check=True).stdout


def blobs(repo, revision, paths):
    requests = [(revision + ":selfhost/" + name).encode() for name in paths]
    stream = git(repo, "cat-file", "--batch", data=b"\n".join(requests) + b"\n")
    offset, result = 0, {}
    for name in paths:
        end = stream.index(b"\n", offset)
        fields = stream[offset:end].split()
        if len(fields) != 3 or fields[1] != b"blob":
            raise ValueError("Missing baseline blob: " + name)
        size = int(fields[2]); start = end + 1
        result[name] = stream[start:start + size]
        if stream[start + size:start + size + 1] != b"\n":
            raise ValueError("Malformed git batch result")
        offset = start + size + 1
    if offset != len(stream):
        raise ValueError("Unconsumed git batch output")
    return result


def manifest_paths(manifest):
    names = set(manifest["modules"]) | {manifest["preamble"]}
    for profile in manifest["profiles"].values():
        names.update(profile.get("modules", []))
        if profile.get("entryModule"):
            names.add(profile["entryModule"])
    return names


def declarations(source, manifest, contents):
    result = {}
    for name in manifest["modules"]:
        if name == manifest["preamble"]:
            continue
        prefix, items = source.blocks(contents[name])
        if prefix:
            raise ValueError("Unassigned canonical source bytes: " + name)
        for item in items:
            key = (item["kind"], item["name"])
            if key in result:
                raise ValueError("Duplicate declaration: " + str(key))
            result[key] = {"owner": name, "data": item["data"]}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument("--baseline", default="HEAD")
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    repo = args.repo.resolve(); root = repo / "selfhost"
    revision = git(repo, "rev-parse", args.baseline + "^{commit}").decode().strip()
    output = args.out.resolve()
    output.mkdir(parents=True, exist_ok=False)
    utility = root / "tools/build/source.py"
    spec = importlib.util.spec_from_file_location("phase193_source_transport", utility)
    source = importlib.util.module_from_spec(spec); spec.loader.exec_module(source)
    old_raw = git(repo, "show", revision + ":selfhost/src/compiler.json")
    current_raw = (root / "src/compiler.json").read_bytes()
    old = json.loads(old_raw); current = json.loads(current_raw)
    old_files = blobs(repo, revision, sorted(manifest_paths(old)))
    current_files = {name: (root / name).read_bytes() for name in manifest_paths(current)}
    report = {
        "kind": "phase193-offline-canonical-source-audit", "version": 2,
        "complete": False, "baseline": revision, "compilerExecuted": False,
        "targetExecuted": False, "method": identity(Path(__file__).read_bytes()),
        "sourceUtility": identity(utility.read_bytes()),
        "baselineManifest": identity(old_raw), "candidateManifest": identity(current_raw),
        "profiles": {}, "protectedDeclarations": [],
        "scope": "Exact assembled source and source-map identity for all five non-x86 profiles; lexical source transport and inventory, not compiler or kernel checking."
    }
    (output / "baseline-manifest.json").write_bytes(old_raw)
    (output / "candidate-manifest.json").write_bytes(current_raw)
    report_file = output / "report.json"
    try:
        profiles = sorted(set(current["profiles"]) - {"x86"})
        assert profiles == sorted(set(old["profiles"]) - {"x86"})
        assert len(profiles) == 5
        with tempfile.TemporaryDirectory(prefix="phase193-source-overlay-") as temporary:
            overlay = Path(temporary)
            baseline_manifest = overlay / "compiler.json"
            baseline_manifest.write_bytes(old_raw)
            for name, before in old_files.items():
                target = overlay / name; target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(before)
            for profile in profiles:
                before, before_map = source.maintained_assemble(baseline_manifest, overlay, profile, True)
                after, after_map = source.maintained_assemble(root / "src/compiler.json", root, profile, True)
                serialize = lambda value: (json.dumps(value, indent=2) + "\n").encode()
                bm, am = serialize(before_map), serialize(after_map)
                report["profiles"][profile] = {
                    "sourceEqual": before == after, "mapEqual": bm == am,
                    "baselineSource": identity(before), "candidateSource": identity(after),
                    "baselineMap": identity(bm), "candidateMap": identity(am),
                    "declarations": len(after_map), "profileConfigurationEqual": old["profiles"][profile] == current["profiles"][profile]
                }
                assert before == after and bm == am
        before = declarations(source, old, old_files)
        after = declarations(source, current, current_files)
        protected = current["protectedDeclarations"]
        assert old["protectedDeclarations"] == protected
        for name, expected in protected.items():
            a = [row for (kind, key), row in before.items() if key == name]
            b = [row for (kind, key), row in after.items() if key == name]
            ah, bh = sha(source.normalized(a)), sha(source.normalized(b))
            exact = [row["data"] for row in a] == [row["data"] for row in b]
            assert a and b and exact and ah == bh == expected["normalizedSha256"]
            report["protectedDeclarations"].append({"name": name, "exactBytesEqual": exact,
                "normalizedSha256": bh, "verifier": expected.get("verifier", False), "proof": expected.get("proof", False)})
        report["inventory"] = {
            "canonicalModulesBefore": len(old["modules"]), "canonicalModulesAfter": len(current["modules"]),
            "canonicalDeclarationEntriesBefore": len(before), "canonicalDeclarationEntriesAfter": len(after),
            "canonicalModuleOrderEqual": old["modules"] == current["modules"],
            "canonicalDeclarationOrderEqual": old["order"] == current["order"],
            "canonicalDeclarationBytesEqual": before == after,
            "allSharedSourceFilesChanged": [name for name in sorted(old_files) if current_files.get(name) != old_files[name]],
            "addedProfileSourceFiles": sorted(set(current_files) - set(old_files)),
            "protectedCount": len(protected),
            "protectedVerifierCount": sum(bool(v.get("verifier")) for v in protected.values()),
            "protectedProofCount": sum(bool(v.get("proof")) for v in protected.values()),
        }
        assert before == after and old["modules"] == current["modules"] and old["order"] == current["order"]
        report["sourceInputs"] = [{"file": name, **identity(data)} for name, data in sorted(current_files.items())]
        assert (root / "src/compiler.json").read_bytes() == current_raw
        assert all((root / name).read_bytes() == data for name, data in current_files.items())
        report["unchangedInputs"] = True
        report["complete"] = True
    except Exception as error:
        report["error"] = repr(error)
        raise
    finally:
        report_file.write_text(json.dumps(report, indent=2) + "\n")
    size = sum(p.stat().st_size for p in output.iterdir() if p.is_file())
    assert size < 20 * 1024 * 1024
    print(json.dumps({"complete": report["complete"], "baseline": revision,
        "profiles": profiles, "protected": len(protected), "retainedBytes": size,
        "report": str(report_file)}, indent=2))


if __name__ == "__main__":
    main()
