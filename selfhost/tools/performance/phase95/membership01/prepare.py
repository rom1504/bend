#!/usr/bin/env python3
"""Extract exact D04 membership functions and prepare sources; never run a target."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PIN = "d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097"
NAMES = ("p88_string_eq_go", "p88_string_eq", "has_name", "has_name_next", "nb_contains")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def definition(text, name):
    pattern = r"(?m)^(?:@unsafe\n)?def " + re.escape(name) + r"\("
    matches = list(re.finditer(pattern, text))
    if len(matches) != 1:
        raise ValueError(f"expected one definition of {name}, got {len(matches)}")
    start = matches[0].start()
    end = text.find("\n\n", matches[0].end())
    if end < 0:
        raise ValueError(f"missing definition separator for {name}")
    return start, end + 1, text[start:end + 1]


def patch(text, before, after, path):
    if text.count(before) != 1:
        raise ValueError(f"ambiguous patch in {path}")
    changed = text.replace(before, after, 1)
    diff = "".join(difflib.unified_diff(text.splitlines(True), changed.splitlines(True),
                                     fromfile="a/" + path, tofile="b/" + path))
    return changed, diff


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    source_path = ROOT / "selfhost/build/phase92/upstream-checked01/compiler.bend"
    source_bytes = source_path.read_bytes()
    if sha(source_bytes) != PIN:
        raise ValueError("frozen D04 source hash changed")
    source = source_bytes.decode()
    pieces, extracted = [], []
    for name in NAMES:
        start, end, body = definition(source, name)
        pieces.append(body)
        extracted.append({"name": name, "start_byte": len(source[:start].encode()),
                          "end_byte": len(source[:end].encode()),
                          "start_line": source.count("\n", 0, start) + 1,
                          "sha256": sha(body.encode())})
    module = "import Base\n\n" + "\n".join(pieces)
    template = (HERE / "micro-template.bend").read_text()
    if template.count("@KERNEL@") != 1:
        raise ValueError("expected exactly one kernel placeholder")
    baseline = template.replace("@KERNEL@", "M.nb_contains(rows, key)")
    candidate = template.replace("@KERNEL@", "M.has_name(rows, key)")
    old = pieces[-1]
    new = "@unsafe\ndef nb_contains(+xs: List<&2, String>, +k: String) -> Bool:\n  has_name(xs, k)\n"
    changed, d04_patch = patch(source, old, new, "selfhost/build/phase92/upstream-checked01/compiler.bend")
    canonical_path = ROOT / "selfhost/src/back/native/tables.bend"
    canonical_bytes = canonical_path.read_bytes()
    canonical = canonical_bytes.decode()
    _, _, canonical_old = definition(canonical, "nb_contains")
    if canonical_old != old.replace("p88_string_eq(h, k)", "String.eq(h, k)"):
        raise ValueError("canonical nb_contains differs from expected baseline")
    canonical_changed, canonical_patch = patch(canonical, canonical_old, new,
                                             "selfhost/src/back/native/tables.bend")
    files = {"extracted.bend": module.encode(), "baseline.bend": baseline.encode(),
             "candidate.bend": candidate.encode(),
             "controls.bend": (HERE / "controls.bend").read_bytes(),
             "controls.expected.txt": (HERE / "controls.expected.txt").read_bytes(),
             "nb_contains.d04.patch": d04_patch.encode(),
             "nb_contains.canonical.patch": canonical_patch.encode()}
    receipt = {"schema": "phase95-membership-extraction-v1", "targets_run": False,
               "source": str(source_path), "source_sha256": PIN,
               "extractions": extracted,
               "d04_patch": {"before_sha256": PIN, "after_sha256": sha(changed.encode()),
                             "old": old, "new": new},
               "canonical_patch": {"before_sha256": sha(canonical_bytes),
                                   "after_sha256": sha(canonical_changed.encode()),
                                   "old": canonical_old, "new": new},
               "preparer_sha256": sha(Path(__file__).read_bytes()),
               "template_sha256": sha(template.encode()),
               "files": {name: {"sha256": sha(data), "bytes": len(data)}
                         for name, data in files.items()}}
    args.out.mkdir(parents=True, exist_ok=False)
    for name, data in files.items():
        (args.out / name).write_bytes(data)
    (args.out / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({"out": str(args.out.resolve()), "source_sha256": PIN,
                      "files": len(files), "targets_run": False}))


if __name__ == "__main__":
    main()
