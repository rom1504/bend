#!/usr/bin/env python3
"""Data-only: restore the old occurrence-insertion call in two saved JS images."""
import difflib
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / "selfhost/build/phase70/occurrence-ablation-images01"
ROLES = [
    dict(role="b1", current="selfhost/build/phase70/compiler02/equality/api.mjs",
         currentSha="f326862f5163fce83e47642c9b8dcfdb6596683bafe36054b7fb6d5430376f2f",
         previous="selfhost/build/phase69/typed-build10/equality/api.mjs",
         previousSha="674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553",
         name="$nc_uses_term$", renames={}),
    dict(role="b2", current="selfhost/build/phase70/compiler02-b2/full/compiler.mjs",
         currentSha="7c638e4ae4ae57a9ae759247a30ede1b27a24a2d07e239d94c0b2ee9828cee56",
         previous="selfhost/build/phase69/typed10-b2-v2/full/compiler.mjs",
         previousSha="c858dfa5424c534444a2b733c0336a7009fc260da272d64c52f33a188d3f066e",
         name="$jd$nc_95_uses_95_term", renames={"41561": "41659", "41562": "41660", "41563": "41661"}),
]


def pin(path):
    path = path.resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def function(source, name):
    marker = "function " + name + "("
    assert source.count(marker) == 1
    start = source.index(marker)
    end = source.index("\nfunction ", start + 1)
    return start, end, source[start:end]


def main():
    OUT.mkdir(exist_ok=False)
    receipt = dict(kind="phase70-occurrence-only-generated-image-ablation-v1",
                   complete=False, dataOnly=True, targetExecuted=False,
                   shippingCandidate=False, producer=pin(Path(__file__)), rows=[])
    report = OUT / "derivation.json"
    def save():
        report.write_text(json.dumps(receipt, indent=2) + "\n")
    save()
    try:
        for spec in ROLES:
            original, previous = ROOT/spec["current"], ROOT/spec["previous"]
            originalPin, previousPin = pin(original), pin(previous)
            assert originalPin["sha256"] == spec["currentSha"]
            assert previousPin["sha256"] == spec["previousSha"]
            source, old = original.read_text(), previous.read_text()
            start, end, before = function(source, spec["name"])
            _, _, after = function(old, spec["name"])
            for was, now in spec["renames"].items():
                after = after.replace("$x"+was, "$x"+now).replace("JD_USE:"+was, "JD_USE:"+now)
            if spec["role"] == "b1":
                expected = before.replace("$nc_uses_put$(_uses_0, _mark_0, ($ix$(_t_0)))", "$index_set$(_uses_0, _mark_0, ($ix$(_t_0)), 32)")
            else:
                expected = before.replace("$jd$nc_95_uses_95_put", "$jd$index_95_set")
                expected = expected.replace("/*JD_USE:41659*/$x41659)))));", "/*JD_USE:41659*/$x41659))),32));")
            assert before != after and after == expected, spec["role"]
            derived = source[:start] + after + source[end:]
            assert derived[:start] == source[:start]
            assert derived[start+len(after):] == source[end:]
            assert derived[:start] + before + derived[start+len(after):] == source
            destination = OUT/(spec["role"]+"-occurrence-off.mjs")
            with destination.open("x") as stream:
                stream.write(derived)
            diff = OUT/(spec["role"]+"-occurrence-off.patch")
            with diff.open("x") as stream:
                stream.write("".join(difflib.unified_diff(source.splitlines(keepends=True), derived.splitlines(keepends=True), fromfile=str(original), tofile=str(destination))))
            assert pin(original) == originalPin and pin(previous) == previousPin
            receipt["rows"].append(dict(role=spec["role"], original=originalPin, previous=previousPin,
                output=pin(destination), patch=pin(diff), function=spec["name"], offset=start,
                exactBefore=before, exactAfter=after, previousBinderRenames=spec["renames"],
                unchangedOutsideFunction=True, reverseRecoveryExact=True))
            save()
        receipt["complete"] = True
        receipt["scope"] = "Diagnostic generated images only. Only nc_uses_term returns to index_set(...,32); all other compiler02 bytes and helpers remain. No target executed."
        save()
    except BaseException as error:
        receipt["error"] = repr(error)
        save()
        raise


if __name__ == "__main__":
    main()
