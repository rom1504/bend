#!/usr/bin/env python3
"""Prepare the isolated full D04 membership candidate; never run a target."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = "d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097"
CANDIDATE = "847898094f72898b11eb3ecb8b58ea9530d9ff00c592aabd716947c5543c8169"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = path.resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=sha(data), bytes=len(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / "selfhost/build/phase95") and not out.exists()
    source_path = ROOT / "selfhost/build/phase92/upstream-checked01/compiler.bend"
    source = source_path.read_bytes()
    assert sha(source) == SOURCE
    extraction_path = HERE / "frozen03/receipt.json"
    extraction = json.loads(extraction_path.read_text())
    change = extraction["d04_patch"]
    assert change["before_sha256"] == SOURCE and change["after_sha256"] == CANDIDATE
    old, new = change["old"].encode(), change["new"].encode()
    assert source.count(old) == 1
    assert new == b"@unsafe\ndef nb_contains(+xs: List<&2, String>, +k: String) -> Bool:\n  has_name(xs, k)\n"
    offset = source.index(old)
    candidate = source[:offset] + new + source[offset + len(old):]
    assert sha(candidate) == CANDIDATE
    patch_path = HERE / "frozen03/nb_contains.d04.patch"
    patch = patch_path.read_bytes()
    assert sha(patch) == extraction["files"][patch_path.name]["sha256"]
    out.mkdir(parents=True)
    (out / "compiler.bend").write_bytes(candidate)
    (out / "candidate.patch").write_bytes(patch)
    receipt = dict(schema="phase95-membership-candidate-v1", targetsRun=False,
                   source=pin(source_path), method=pin(Path(__file__)),
                   extraction=pin(extraction_path), patchSource=pin(patch_path),
                   candidateSha256=CANDIDATE, forwardReplayExact=True,
                   changes=[dict(name="nb_contains body delegates to existing has_name",
                                 offsetBytes=offset, old=old.decode(), new=new.decode(),
                                 beforeSha256=SOURCE, afterSha256=CANDIDATE)],
                   outputs={name: pin(out / name) for name in ["compiler.bend", "candidate.patch"]})
    replay = source
    for item in receipt["changes"]:
        at, before, after = item["offsetBytes"], item["old"].encode(), item["new"].encode()
        assert replay[at:at + len(before)] == before
        replay = replay[:at] + after + replay[at + len(before):]
    assert replay == (out / "compiler.bend").read_bytes()
    assert source_path.read_bytes() == source
    (out / "changes.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(dict(out=str(out), candidateSha256=CANDIDATE,
                          forwardReplayExact=True, targetsRun=False)))


if __name__ == "__main__":
    main()
