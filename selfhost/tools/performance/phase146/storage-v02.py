#!/usr/bin/env python3
"""Restore-verified cleanup of four additional specifically archived diagnostic artifacts.

Default command is verify. No compiler/image/runtime acquisition or target runs.
Apply requires a prior complete verification receipt. Restore refuses overwrites.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import stat
import tarfile
import tempfile
import time

ROOT = Path(__file__).resolve().parents[4]
FILES = {
    142: (
        "selfhost/build/phase142/native-context-plan01/owners.json",
        "selfhost/build/phase142/native-context-plan01/runtime/program",
    ),
    143: (
        "selfhost/build/phase143/profile01/owners.json",
        "selfhost/build/phase143/profile01/runtime/program",
    ),
}
ARCHIVES = {
    142: (14024521, "17c9d8e6b5cde81ec644a1a86b1f908236090091c9ec4afd5f9121d53deaaf37"),
    143: (24957949, "cb0c8d6b398dbdd3b351c8e0fc897eb5b3512ebd92318e1347811ddfe89e2181"),
}
EVIDENCE = {142: "evidence02", 143: "evidence01"}
ALLOWED = {name for names in FILES.values() for name in names}


def require(value, message):
    if not value:
        raise RuntimeError(message)


def digest(stream):
    h, length = hashlib.sha256(), 0
    while block := stream.read(1024 * 1024):
        h.update(block)
        length += len(block)
    return length, h.hexdigest()


def pin(path):
    p = Path(path)
    require(p.is_file() and not p.is_symlink(), f"not a regular file: {p}")
    with p.open("rb") as stream:
        size, sha = digest(stream)
    return {"file": str(p.relative_to(ROOT)), "bytes": size, "sha256": sha}


def same(actual, expected):
    return all(actual[k] == expected[k] for k in ("bytes", "sha256"))


def snapshot(name):
    require(name in ALLOWED, "path not in fixed four-file allowlist")
    p = ROOT / name
    require(p.resolve() == p, f"symlink in input path: {name}")
    s = p.lstat()
    require(stat.S_ISREG(s.st_mode) and s.st_nlink == 1, f"not an exclusive regular file: {name}")
    result = pin(p)
    result.update(mode=stat.S_IMODE(s.st_mode), device=s.st_dev, inode=s.st_ino,
                  mtimeNs=s.st_mtime_ns, links=s.st_nlink, allocatedBytes=s.st_blocks * 512)
    t = p.lstat()
    require((t.st_dev, t.st_ino, t.st_mode, t.st_nlink, t.st_size, t.st_mtime_ns, t.st_ctime_ns) ==
            (s.st_dev, s.st_ino, s.st_mode, s.st_nlink, s.st_size, s.st_mtime_ns, s.st_ctime_ns),
            f"file changed during hashing: {name}")
    return result


def archive_check(restore=False):
    """Verify whole capsule and each chosen member without extracting other data."""
    results, archives = [], []
    for phase, names in FILES.items():
        base = ROOT / f"implementation/phase{phase}/{EVIDENCE[phase]}"
        inventory_path, archive = base / "inventory.json", base / "evidence.tar.gz"
        inv_pin, arc_pin = pin(inventory_path), pin(archive)
        require((arc_pin["bytes"], arc_pin["sha256"]) == ARCHIVES[phase], "capsule identity changed")
        inv = json.loads(inventory_path.read_text())
        require(inv["complete"] is True, "incomplete archive inventory")
        require(inv["roundtripExact"] is True, "unverified archive roundtrip")
        if phase == 143:
            require(inv["currentInputsExact"] is True, "historical input verification missing")
        require(same(arc_pin, inv["archive"]), "inventory archive pin mismatch")
        authority = inv_pin
        expected = {}
        for name in names:
            rows = [row for row in inv["files"] if row["file"] == name]
            require(len(rows) == 1, f"missing/duplicate inventory member: {name}")
            expected[name] = rows[0]
        seen = set()
        with tarfile.open(archive, "r|gz") as tar:
            for member in tar:
                if member.name not in expected:
                    continue
                name, row = member.name, dict(expected[member.name])
                row["mode"] = member.mode  # Historical inventories omit mode; pinned tar authenticates it.
                require(name not in seen and member.isfile(), "duplicate or non-regular archive member")
                seen.add(name)
                require(member.size == row["bytes"], f"archive size mismatch: {name}")
                stream = tar.extractfile(member)
                require(stream is not None, "missing member stream")
                with stream:
                    size, sha = digest(stream)
                require((size, sha) == (row["bytes"], row["sha256"]), f"archive hash mismatch: {name}")
                current = None if restore else snapshot(name)
                if current:
                    require(same(current, row) and current["mode"] == row["mode"], f"current differs: {name}")
                results.append({"member": row, "archive": arc_pin, "current": current})
        require(seen == set(names), "missing archive members")
        require(pin(archive) == arc_pin and pin(inventory_path) == inv_pin, "archive changed during verification")
        archives.append({"archive": arc_pin, "inventory": inv_pin, "authority": authority})
    return results, archives


def write_new(path, data):
    p = Path(path).absolute()
    require(p.is_relative_to(ROOT / "selfhost/build/phase146"), "receipt must be below Phase146 build directory")
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open("x") as out:
        json.dump(data, out, indent=2)
        out.write("\n")
        out.flush()
        os.fsync(out.fileno())


def restore_files(rows):
    """Never extract arbitrary archive paths or replace an existing artifact."""
    restored = []
    for phase, names in FILES.items():
        expected = {row["member"]["file"]: row["member"] for row in rows if row["member"]["file"] in names}
        archive = ROOT / f"implementation/phase{phase}/{EVIDENCE[phase]}/evidence.tar.gz"
        with tarfile.open(archive, "r|gz") as tar:
            for member in tar:
                if member.name not in expected:
                    continue
                row, target = expected[member.name], ROOT / member.name
                require(target.parent.resolve() == target.parent, "symlink in restore parent")
                if target.exists() or target.is_symlink():
                    actual = snapshot(row["file"])
                    require(same(actual, row) and actual["mode"] == row["mode"],
                            f"restore refuses different existing file: {target}")
                    restored.append({"alreadyExact": actual})
                    continue
                fd, temporary = tempfile.mkstemp(prefix=".phase146-restore-", dir=target.parent)
                try:
                    stream = tar.extractfile(member)
                    h, size = hashlib.sha256(), 0
                    with os.fdopen(fd, "wb") as out, stream:
                        while block := stream.read(1024 * 1024):
                            h.update(block); size += len(block); out.write(block)
                        out.flush(); os.fsync(out.fileno())
                    require((size, h.hexdigest()) == (row["bytes"], row["sha256"]), "restore hash mismatch")
                    os.chmod(temporary, row["mode"])
                    os.link(temporary, target)  # Atomic no-overwrite publication.
                    os.unlink(temporary)
                    actual = snapshot(row["file"])
                    require(same(actual, row), "restored file mismatch")
                    restored.append(actual)
                finally:
                    if os.path.exists(temporary):
                        os.unlink(temporary)
    return restored


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("command", choices=("verify", "apply", "restore"))
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--verified", type=Path, help="required complete verify receipt for apply")
    args = ap.parse_args()
    require(not args.out.exists(), "output receipt already exists")
    method, before = pin(Path(__file__).resolve()), os.statvfs(ROOT)
    rows, archives = archive_check(restore=args.command == "restore")
    result = {"kind": "phase146-additional-fixed-archived-diagnostics-cleanup", "complete": False,
              "command": args.command, "targetsRun": False, "method": method,
              "files": rows, "archives": archives, "logicalBytes": sum(r["member"]["bytes"] for r in rows),
              "beforeAvailableBytes": before.f_bavail * before.f_frsize, "timeUnix": time.time()}
    if args.command == "apply":
        require(args.verified is not None, "apply requires --verified receipt")
        previous = json.loads(args.verified.read_text())
        require(previous["complete"] is True and previous["command"] == "verify", "not a complete verification")
        require(previous["method"] == method and previous["files"] == rows and previous["archives"] == archives,
                "inputs changed since verification")
        result["verified"] = pin(args.verified.absolute())
        # Write recoverable intent before the first unlink. Journal records each completed deletion.
        write_new(str(args.out) + ".intent.json", result)
        journal = Path(str(args.out) + ".journal.jsonl")
        with journal.open("x") as log:
            for row in rows:
                name = row["member"]["file"]
                require(snapshot(name) == row["current"], f"current changed before unlink: {name}")
                (ROOT / name).unlink()
                require(not (ROOT / name).exists(), "unlink did not remove path")
                log.write(json.dumps({"removed": name, "sha256": row["member"]["sha256"]}) + "\n")
                log.flush(); os.fsync(log.fileno())
        result["removed"] = [row["member"]["file"] for row in rows]
        for arc in archives:
            require(pin(ROOT / arc["archive"]["file"]) == arc["archive"], "archive changed after cleanup")
    elif args.command == "restore":
        result["restored"] = restore_files(rows)
    result["complete"] = True
    after = os.statvfs(ROOT)
    result["afterAvailableBytes"] = after.f_bavail * after.f_frsize
    write_new(args.out, result)
    print(json.dumps({"complete": True, "command": args.command, "logicalBytes": result["logicalBytes"], "receipt": str(args.out)}))


if __name__ == "__main__":
    main()
