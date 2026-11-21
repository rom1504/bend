"""Preserve the benchmark observation streams and their portable digests after sealing."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("run", type=Path)
    parser.add_argument("archive", type=Path)
    args = parser.parse_args()
    root = args.run
    guard = root.with_name(root.name + "-guard")
    assert json.loads((guard / "retention.json").read_bytes())["state"] == "sealed"
    summary = json.loads((root / "summary.json").read_bytes())
    assert summary["complete"]
    observations = {}
    for stream in root.rglob("stdout"):
        if not stream.with_name("process.json").is_file():
            continue
        key = str(stream.parent.relative_to(root))
        files = {}
        for name in ("stdout", "stderr", "process.json"):
            data = stream.with_name(name).read_bytes()
            assert len(data) < 65536
            files[name] = dict(sha256=hashlib.sha256(data).hexdigest(), text=data.decode())
        observations[key] = files
    count = sum(key.startswith("timing/timed/") for key in observations)
    assert count == summary["oracleRevalidated"]["samples"]
    payload = json.dumps(observations, sort_keys=True, separators=(",", ":")).encode()
    args.archive.write_bytes(gzip.compress(payload, compresslevel=9, mtime=0))

if __name__ == "__main__":
    main()
