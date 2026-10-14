#!/usr/bin/env python3
"""Restore only the reviewed historical profiles, into a fresh directory."""
import argparse
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import zipfile


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--review", default="implementation/phase90/reclaim-review.json")
    parser.add_argument("--out", required=True, help="New restoration directory; never a live tree")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[4]
    review = json.loads((root / args.review).read_text())
    assert review["complete"] and not review["deletionsPerformed"]
    out = Path(args.out).resolve()
    assert not out.exists(), "Restoration destination already exists"
    # Verify the archive files against their recorded committed Git identities.
    for capsule in review["capsules"]:
        for item in capsule["committedFiles"]:
            actual = subprocess.check_output(
                ["git", "hash-object", item["path"]], cwd=root, text=True).strip()
            assert actual == item["gitBlob"], item["path"]
    out.mkdir(parents=True)
    restored = []
    for capsule in review["capsules"]:
        directory = root / capsule["path"]
        publication = directory / "publication.json"
        metadata = json.loads((publication if publication.exists() else directory / "verification.json").read_text())
        archive = b"".join((directory / part.get("file", part.get("path"))).read_bytes()
                           for part in metadata["parts"])
        assert digest(archive) == capsule["archiveSha256"]
        with zipfile.ZipFile(io.BytesIO(archive)) as source:
            for row in review["files"]:
                if row["capsule"] != capsule["path"]:
                    continue
                relative = PurePosixPath(row["path"])
                assert not relative.is_absolute() and ".." not in relative.parts
                data = source.read(row["archiveMember"])
                assert len(data) == row["bytes"] and digest(data) == row["sha256"]
                target = out / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                with target.open("xb") as destination:
                    destination.write(data)
                target.chmod(row["mode"] & 0o777)
                restored.append(row["path"])
    assert len(restored) == len(review["files"])
    print(json.dumps({"complete": True, "restored": restored, "bytes": review["reclaimBytes"]}))


if __name__ == "__main__":
    main()
