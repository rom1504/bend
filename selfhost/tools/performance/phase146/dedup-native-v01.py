#!/usr/bin/env python3
"""Content-preserving storage dedup of the two frozen Phase146 N1/N2 products.

Only program.s and program.o are eligible. No compiler or machine tool is run.
Run verify after both builds finish; apply requires that exact receipt.
Hardlinks must remain immutable: rebuilding either directory in place is forbidden.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import stat

ROOT = Path(__file__).resolve().parents[4]
N1 = ROOT / "selfhost/build/phase134/p146-context01-n1"
N2 = ROOT / "selfhost/build/phase134/p146-context01-n2"
PRODUCTS = {"assembly": "program.s", "object": "program.o"}


def need(value, message):
    if not value:
        raise RuntimeError(message)


def identity(path):
    need(path.resolve() == path, f"symlinked path refused: {path}")
    s = path.lstat()
    need(stat.S_ISREG(s.st_mode), f"not a regular file: {path}")
    return dict(device=s.st_dev, inode=s.st_ino, bytes=s.st_size,
                mode=stat.S_IMODE(s.st_mode), uid=s.st_uid, gid=s.st_gid,
                links=s.st_nlink, mtimeNs=s.st_mtime_ns, ctimeNs=s.st_ctime_ns)


def pin(path):
    before = identity(path)
    h = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(1024 * 1024):
            h.update(block)
    need(identity(path) == before, f"changed while reading: {path}")
    return dict(file=str(path), bytes=before["bytes"], sha256=h.hexdigest())


def equal_bytes(left, right):
    with left.open("rb") as a, right.open("rb") as b:
        while True:
            x, y = a.read(1024 * 1024), b.read(1024 * 1024)
            need(x == y, "literal comparison failed")
            if not x:
                return


def write_new(path, data):
    path = path.absolute()
    need(path.is_relative_to(ROOT / "selfhost/build/phase146"), "receipt must be below Phase146")
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("x") as stream:
        json.dump(data, stream, indent=2); stream.write("\n")
        stream.flush(); os.fsync(stream.fileno())


def inspect():
    reports = [json.loads((d / "report.json").read_text()) for d in (N1, N2)]
    for report in reports:
        need(report["kind"] == "phase134-supervised-qbe-stdin-build" and report["complete"] is True,
             "both immutable build receipts must be complete")
        need(report["compilerExitCode"] == report["qbeExitCode"] == 0, "producer failed")
        need([j["label"] for j in report["jobs"]] == ["assemble", "link"] and
             all(j["exitCode"] == 0 for j in report["jobs"]), "machine build failed")
    a, b = reports
    need(a["source"] == b["source"] and a["runtime"] == b["runtime"] and
         a["irDigest"] == b["irDigest"], "different source/runtime/IR")
    need(b["image"] == a["binary"] and b["comparedToReference"] is True and
         b["expectedQbe"] == a["retainedIR"], "N2 lineage or exact IR bridge missing")
    report_pins = [pin(d / "report.json") for d in (N1, N2)]
    rows = []
    for key, filename in PRODUCTS.items():
        left, right = N1 / filename, N2 / filename
        li, ri = identity(left), identity(right)
        need(li["device"] == ri["device"], "hardlink crosses devices")
        need(all(li[k] == ri[k] for k in ("bytes", "mode", "uid", "gid")), "metadata differs")
        lp, rp = pin(left), pin(right)
        need(lp == a[key] and rp == b[key], "product no longer matches completed receipt")
        need(lp["bytes"] == rp["bytes"] and lp["sha256"] == rp["sha256"], "product hashes differ")
        equal_bytes(left, right)
        need(identity(left) == li and identity(right) == ri, "product changed during comparison")
        linked = li["inode"] == ri["inode"]
        need((linked and li["links"] == ri["links"] == 2) or
             (not linked and li["links"] == ri["links"] == 1), "unexpected aliases")
        rows.append(dict(key=key, left=lp, right=rp, leftIdentity=li, rightIdentity=ri,
                         literalEqual=True, alreadyLinked=linked))
    need([pin(d / "report.json") for d in (N1, N2)] == report_pins, "build reports changed")
    return dict(reports=report_pins, source=a["source"], runtime=a["runtime"],
                irDigest=a["irDigest"], products=rows)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("command", choices=("verify", "apply", "split"))
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--verified", type=Path)
    args = ap.parse_args()
    need(not args.out.exists(), "fresh receipt required")
    method, observed = pin(Path(__file__).resolve()), inspect()
    result = dict(kind="phase146-identical-native-artifact-dedup", complete=False,
                  command=args.command, targetsRun=False, method=method, before=observed,
                  scope="Only frozen N2 assembly/object storage identity changes; paths, bytes, modes and build receipts stay exact.",
                  futureWrites="Both artifact paths must remain immutable; split before any in-place write.")
    if args.command == "apply":
        need(args.verified is not None, "apply requires --verified")
        previous = json.loads(args.verified.read_text())
        need(previous["complete"] is True and previous["command"] == "verify" and
             previous["method"] == method and previous["before"] == observed, "verification became stale")
        result["verified"] = pin(args.verified.absolute())
    if args.command != "verify":
        write_new(Path(str(args.out) + ".intent.json"), result)
        with Path(str(args.out) + ".journal.jsonl").open("x") as journal:
            for row in observed["products"]:
                if row["alreadyLinked"] == (args.command == "apply"):
                    continue
                left, right = Path(row["left"]["file"]), Path(row["right"]["file"])
                need(identity(left) == row["leftIdentity"] and identity(right) == row["rightIdentity"],
                     "file changed before storage replacement")
                temp = right.with_name(right.name + ".phase146-dedup-tmp")
                need(not temp.exists() and not temp.is_symlink(), "temporary path exists")
                try:
                    if args.command == "apply":
                        os.link(left, temp)
                    else:
                        with left.open("rb") as src, temp.open("xb") as dst:
                            while block := src.read(1024 * 1024):
                                dst.write(block)
                            dst.flush(); os.fsync(dst.fileno())
                        os.chmod(temp, row["rightIdentity"]["mode"])
                        os.utime(temp, ns=(row["rightIdentity"]["mtimeNs"], row["rightIdentity"]["mtimeNs"]))
                    need(pin(temp)["sha256"] == row["right"]["sha256"], "temporary bytes differ")
                    equal_bytes(temp, right)
                    need(identity(right) == row["rightIdentity"], "destination changed before atomic replacement")
                    os.replace(temp, right)
                    journal.write(json.dumps(dict(command=args.command, file=str(right),
                                                  sha256=row["right"]["sha256"])) + "\n")
                    journal.flush(); os.fsync(journal.fileno())
                finally:
                    if temp.exists():
                        temp.unlink()
    result["after"] = inspect()
    result["complete"] = True
    result["deduplicatedBytes"] = sum(r["right"]["bytes"] for r in result["after"]["products"] if r["alreadyLinked"])
    write_new(args.out, result)
    print(json.dumps(dict(complete=True, command=args.command, deduplicatedBytes=result["deduplicatedBytes"], receipt=str(args.out))))


if __name__ == "__main__":
    main()
