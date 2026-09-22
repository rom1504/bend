#!/usr/bin/env python3
"""Preserve both completed bounded diagnostics; durations are not benchmarks."""
import gzip
import hashlib
import json
import pathlib
import sys


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_text())


def main():
    if len(sys.argv) != 4:
        raise SystemExit("Usage: residual-profile-archive.py B1_PROFILE PRIVATE_PROFILE NEW_ARCHIVE")
    roots = [pathlib.Path(arg).resolve(strict=True) for arg in sys.argv[1:3]]
    out = pathlib.Path(sys.argv[3]).absolute()
    out.mkdir(parents=False, exist_ok=False)
    (out / "objects").mkdir()
    report = {"kind": "phase4-residual-profile-archive", "complete": False,
              "scope": "Two instrumented diagnostics, not a speed comparison.",
              "files": [], "external": [], "profiles": []}
    captured = {}

    def capture(path, expected=None, preserve=True):
        path = pathlib.Path(path).absolute()
        canonical = path.resolve(strict=True)
        raw = path.read_bytes()
        digest = sha(raw)
        if expected is not None and digest != expected:
            raise ValueError("Changed input: " + str(path))
        entry = {"file": str(path), "canonicalPath": str(canonical),
                 "sha256": digest, "bytes": len(raw)}
        previous = captured.get(str(path))
        if previous is not None:
            if any(previous[key] != value for key, value in entry.items()):
                raise ValueError("Input drift: " + str(path))
            return previous
        if preserve:
            target = out / "objects" / (digest + ".gz")
            if not target.exists():
                target.write_bytes(gzip.compress(raw, compresslevel=6, mtime=0))
            packed = target.read_bytes()
            if gzip.decompress(packed) != raw:
                raise ValueError("Archive does not reproduce input: " + str(path))
            entry.update({"object": str(target.relative_to(out)),
                          "gzipSha256": sha(packed), "gzipBytes": len(packed)})
            report["files"].append(entry)
        else:
            entry["reason"] = "Platform Node executable is a separately installed prerequisite."
            report["external"].append(entry)
        captured[str(path)] = entry
        return entry

    try:
        capture(__file__)
        capture(pathlib.Path(__file__).with_name("bounded-profile.mjs"))
        reports = []
        expected_apis = [
            "0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810",
            "4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3",
        ]
        configs = []
        for index, root in enumerate(roots):
            launch = read(root / "launch.json")
            child = read(root / "profile/report.json")
            config = read(root / "config.json")
            if (launch["cpu"] != 2 or launch["timeoutMs"] != 90000
                    or config["intervalUs"] != 10000 or config["mode"] != "library"
                    or child["samplingIntervalMicroseconds"] != 10000
                    or child["samples"] <= 0 or child["mode"] != "library"
                    or child["api"] != config["api"] or child["input"] != config["input"]
                    or child["node"]["args"] != ["--stack-size=4096", "--max-old-space-size=3072"]):
                raise ValueError("Unexpected diagnostic configuration: " + str(root))
            capture(config["api"], expected_apis[index])
            configs.append(config)
            if not (launch.get("complete") is True and launch.get("exitCode") == 0
                    and launch.get("signal") is None and launch.get("timedOut") is False
                    and child.get("complete") is True and child.get("inputsUnchanged") is True
                    and child["result"].get("status") == "ok"
                    and child["result"].get("checked") is True):
                raise ValueError("Incomplete diagnostic: " + str(root))
            for key in ("config", "worker", "input", "childReport"):
                capture(launch[key]["file"], launch[key]["sha256"])
            for item in child["inputs"]:
                capture(item["file"], item["sha256"], item["file"] != child["node"]["path"])
            emitted = capture(child["emitted"]["file"], child["emitted"]["sha256"])
            if emitted["bytes"] != child["emitted"]["bytes"]:
                raise ValueError("Wrong emitted length")
            if emitted["sha256"] != config["expectedCodeSha256"]:
                raise ValueError("Unexpected emitted output")
            for file in root.rglob("*"):
                if file.is_file():
                    capture(file)
            report["profiles"].append({"root": str(root), "api": child["api"],
                                       "reportSha256": sha((root / "profile/report.json").read_bytes()),
                                       "emittedSha256": emitted["sha256"],
                                       "samples": child["samples"],
                                       "samplingIntervalMicroseconds": child["samplingIntervalMicroseconds"]})
            reports.append(child)
        for key in ("driver", "base", "runtime", "input", "expectedCodeSha256", "mode", "cpu"):
            if configs[0][key] != configs[1][key]:
                raise ValueError("Different shared diagnostic input: " + key)
        if pathlib.Path(reports[0]["emitted"]["file"]).read_bytes() != pathlib.Path(reports[1]["emitted"]["file"]).read_bytes():
            raise ValueError("Diagnostic emissions differ")
        for item in captured.values():
            file = pathlib.Path(item["file"])
            if str(file.resolve(strict=True)) != item["canonicalPath"] or sha(file.read_bytes()) != item["sha256"]:
                raise ValueError("Input changed during archival: " + str(file))
        report["complete"] = True
        report["inputsRechecked"] = True
    except Exception as error:
        report["error"] = str(error)
        raise
    finally:
        (out / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"complete": True, "files": len(report["files"]),
                      "objects": len(list((out / "objects").iterdir())),
                      "packedBytes": sum(p.stat().st_size for p in (out / "objects").iterdir())}))


if __name__ == "__main__":
    main()
