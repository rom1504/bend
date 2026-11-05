#!/usr/bin/env python3
"""Prepare pinned private bendc sources; never invoke a compiler or workload."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "selfhost/build/phase158/current"
BASE = ROOT / "selfhost/build/phase158/upstream-2.0.34/bend2"
PINS = {
    "bendc.bend": "72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99",
    "check.bend": "786514afc1804c00371356943ac6790c16c04c04551e7ab8e0d8f6468e22bf41",
    "core.bend": "776ec5d81269d74ab3e8da0ad0f748e0f0e48695aae667a5d57ed033c433a1b7",
    "asm.bend": "91794842d83c54362a756d0a759ea8fc4979b889184567cc543b640fb6f7a2f9",
    "rt/rtjs.bend": "cb6d37062e77441383ec205d0a89e8bbaa3ac38b58dc0da8764bb6debfeffd24",
    "rt/rtchan.bend": "34ac7e6bb3a91203ccee8fc7d66825aeba611766d51ba62c7ddffa274e50a51f",
}
BASE_SHA = "c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661"
NAMES = ("new", "has", "get", "set", "same", "link")
RENAMES = {("memo." + n).encode(): ("p165memo." + n).encode() for n in NAMES}
START = frozenset(b"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$")
CONT = START | frozenset(b"0123456789.%")


def require(ok, message):
    if not ok:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def identity(path, data=None):
    data = path.read_bytes() if data is None else data
    return {"file": str(path), "bytes": len(data), "sha256": sha(data)}


def tokens(data):
    """ASCII name spans outside Bend # comments and escaped string/char literals.

    The exact source hash is required separately; this is not a general parser.
    Byte offsets preserve UTF-8 payloads, layout, comments and literals verbatim.
    """
    i = 0
    while i < len(data):
        c = data[i]
        if c == 35:
            end = data.find(b"\n", i)
            i = len(data) if end < 0 else end
        elif c in (34, 39):
            quote, begin = c, i
            i += 1
            while i < len(data):
                if data[i] == 92:
                    i += 2
                elif data[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
            else:
                raise ValueError("unterminated literal at byte " + str(begin))
            require(i <= len(data), "incomplete literal escape")
        elif c in START:
            end = i + 1
            while end < len(data) and data[end] in CONT:
                end += 1
            yield i, end, data[i:end]
            i = end
        else:
            i += 1


def transform(data):
    original_tokens = list(tokens(data))
    names = [t[2] for t in original_tokens]
    require(not any(n.startswith(b"p165memo.") for n in names), "destination name collision")
    counts, edits, chunks = {}, [], []
    at, shift = 0, 0
    for old, new in RENAMES.items():
        occurrences = [i for i, t in enumerate(original_tokens) if t[2] == old]
        definitions = sum(i > 0 and names[i - 1] == b"def" for i in occurrences)
        require(len(occurrences) == 2 and definitions == 1,
                "expected one declaration and one reference: " + old.decode())
        counts[old.decode()] = {"declarations": definitions, "references": len(occurrences) - definitions,
                               "candidateIdentifier": new.decode(), "resolvedName": "Chk." + new.decode()}
    for index, (begin, end, name) in enumerate(original_tokens):
        if name not in RENAMES:
            continue
        new = RENAMES[name]
        chunks.extend([data[at:begin], new])
        edits.append({"originalStart": begin, "originalEnd": end,
                      "candidateStart": begin + shift, "candidateEnd": begin + shift + len(new),
                      "line": data.count(b"\n", 0, begin) + 1,
                      "old": name.decode(), "new": new.decode(),
                      "role": "declaration" if index and names[index - 1] == b"def" else "reference"})
        shift += len(new) - len(name)
        at = end
    chunks.append(data[at:])
    candidate = b"".join(chunks)
    inverse = candidate
    for e in reversed(edits):
        a, b = e["candidateStart"], e["candidateEnd"]
        require(inverse[a:b] == e["new"].encode(), "inverse span mismatch")
        inverse = inverse[:a] + e["old"].encode() + inverse[b:]
    require(inverse == data, "non-identifier source bytes changed")
    reverse = {v: k for k, v in RENAMES.items()}
    renamed_tokens = [t[2] for t in tokens(candidate)]
    require([reverse.get(t, t) for t in renamed_tokens] == names, "token stream mismatch")
    require(not (set(RENAMES) & set(renamed_tokens)), "old memo identifier remains")
    return candidate, counts, edits


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True, help="Fresh output directory; refuses existing paths")
    args = parser.parse_args()
    out = args.out.resolve()
    require(not out.exists(), "output already exists")
    require(out.is_relative_to(ROOT / "selfhost/build/phase165"), "output must be under selfhost/build/phase165")
    sources = {name: (SOURCE / name).read_bytes() for name in PINS}
    for name, data in sources.items():
        require(sha(data) == PINS[name], "source pin mismatch: " + name)
    # No external lexical references may silently retain the old checker name.
    qualified = {b"Chk." + x for x in RENAMES}
    for name, data in sources.items():
        if name != "check.bend":
            require(not any(t[2] in qualified for t in tokens(data)), "external checker memo reference: " + name)
    candidate, counts, edits = transform(sources["check.bend"])
    base_data = (BASE / "base.bend").read_bytes()
    require(sha(base_data) == BASE_SHA, "acquisition Base pin mismatch")
    base_manifest_path = ROOT / "selfhost/build/phase158/upstream-2.0.34-manifest.json"
    base_manifest = json.loads(base_manifest_path.read_text())
    base_pins = {x["file"]: x for x in base_manifest["files"]}
    imports = sorted(set(re.findall(rb'^\s+import "(\./effs/[^"\n]+)"', base_data, re.M)))
    require(len(imports) == 68, "unexpected Base foreign import inventory")
    assets = {"base.bend": base_data}
    for raw in imports:
        name = raw.decode().removeprefix("./")
        require(".." not in Path(name).parts, "foreign path escapes private Base")
        data = (BASE / name).read_bytes()
        pin = base_pins.get("bend2/" + name)
        require(pin and sha(data) == pin["sha256"] and len(data) == pin["bytes"], "effect pin mismatch: " + name)
        assets[name] = data
    # All inputs validated before the first output mutation.
    out.mkdir(parents=True)
    written = {}
    for role in ("original", "candidate"):
        written[role] = []
        for name, original in sources.items():
            data = candidate if role == "candidate" and name == "check.bend" else original
            path = out / role / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
            written[role].append(identity(path))
    for name, data in assets.items():
        path = out / "base-acquisition" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    manifest = {
        "kind": "phase165-bendc-portable-memo-source", "version": 1, "complete": True, "targetsRun": False,
        "bendcCommit": "56edcc65b3527a75838011682c231072d5b46097",
        "method": identity(Path(__file__).resolve()),
        "inputs": [identity(SOURCE / n, b) for n, b in sources.items()] +
                  [identity(base_manifest_path)] + [identity(BASE / n, b) for n, b in assets.items()],
        "products": written,
        "acquisitionBase": identity(out / "base-acquisition/base.bend"),
        "privateBaseAssets": [identity(out / "base-acquisition" / n) for n in assets],
        "counts": counts, "edits": edits, "editCount": len(edits),
        "audit": {"exactInverse": True, "tokenStreamModuloSixRenames": True,
                  "allOtherSourceBytesUnchanged": True, "stringsCommentsLayoutUnchanged": True,
                  "nativeTableUnchanged": True, "externalMemoReferences": 0},
        "scope": "Private source-only acquisition input. Renaming makes the checker use its documented nonmemoizing Bend fallbacks. No source-check, emission, runtime equivalence, timing or promotion asserted.",
        "runtimeWorkloadBase": {"file": "selfhost/.bootstrap/upstream-phase66/bend2/base.bend",
                                "bytes": 75064, "sha256": "99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf",
                                "note": "Phase162 common measured-input Base; deliberately distinct from acquisition Base."},
    }
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    # Re-read exact files; do not rely only on in-memory buffers.
    for entries in written.values():
        for entry in entries:
            require(identity(Path(entry["file"])) == entry, "written product mismatch")
    print(json.dumps({"complete": True, "manifest": identity(out / "manifest.json"),
                      "candidateChecker": identity(out / "candidate/check.bend"), "edits": len(edits)}))


if __name__ == "__main__":
    main()
