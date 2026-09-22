#!/usr/bin/env python3
"""Measure a verified private compiler CLI, retaining its process-tree rusage.

The compiler launcher owns request deadlines and input/output validation. This
outer process measures a single CLI invocation; its own final hashing is outside
the wall interval. A new directory is required for every attempt.
"""
import argparse
import hashlib
import json
import pathlib
import resource
import subprocess
import time


def identity(file):
    file = pathlib.Path(file).resolve(strict=True)
    data = file.read_bytes()
    return {"file": str(file), "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}


def save(file, value):
    file.write_text(json.dumps(value, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("node")
    parser.add_argument("launcher")
    parser.add_argument("image")
    parser.add_argument("source")
    parser.add_argument("expected_library")
    parser.add_argument("output")
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--timeout-ms", type=int, default=3600000)
    args = parser.parse_args()
    if args.cpu < 0 or not 1 <= args.timeout_ms <= 3600000:
        parser.error("Invalid CPU or timeout")
    out = pathlib.Path(args.output).resolve()
    out.mkdir(parents=False, exist_ok=False)
    image = pathlib.Path(args.image).resolve(strict=True)
    inputs = [identity(p) for p in [__file__, args.node, args.launcher,
              image / "manifest.json", image / "image.mjs", args.source,
              args.expected_library]]
    command = ["taskset", "-c", str(args.cpu), inputs[1]["file"],
               "--stack-size=4096", "--max-old-space-size=3072", inputs[2]["file"],
               str(image), inputs[5]["file"], "library", str(out / "request"),
               "--cpu=" + str(args.cpu), "--heap-mb=12288",
               "--timeout-ms=" + str(args.timeout_ms)]
    report = {"kind": "phase4-private-full-source", "version": 1,
              "complete": False, "command": command, "inputs": inputs,
              "startedUtc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
              "measurement": "One fresh CLI process; Python RUSAGE_CHILDREN of wrapper and waited descendants; OS caches not flushed"}
    file = out / "measurement.json"
    save(file, report)
    start = time.monotonic()
    try:
        with (out / "stdout").open("xb") as stdout, (out / "stderr").open("xb") as stderr:
            child = subprocess.run(command, stdout=stdout, stderr=stderr, check=False)
        wall_ms = (time.monotonic() - start) * 1000
        usage = resource.getrusage(resource.RUSAGE_CHILDREN)
        report.update(returncode=child.returncode, wallMs=wall_ms,
                      maxRssKiB=usage.ru_maxrss, userSeconds=usage.ru_utime,
                      systemSeconds=usage.ru_stime)
        launch_file = out / "request" / "launch.json"
        report["launch"] = identity(launch_file)
        launch = json.loads(launch_file.read_text())
        assert child.returncode == 0 and launch["complete"] is True, "Private CLI failed"
        emitted = launch["emitted"]
        emitted_file = emitted.get("file") or emitted.get("path")
        assert emitted_file, "No published library identity"
        actual = identity(emitted_file)
        assert actual["sha256"] == inputs[6]["sha256"], "Full-source output differs from proven H"
        assert pathlib.Path(actual["file"]).read_bytes() == pathlib.Path(inputs[6]["file"]).read_bytes()
        for before in inputs:
            assert identity(before["file"]) == before, "Input drift: " + before["file"]
        report.update(complete=True, inputsUnchanged=True, emitted=actual,
                      requestMs=launch["requestMs"], launchWallMs=launch["wallMs"])
    except Exception as error:
        report["error"] = repr(error)
        raise
    finally:
        report["finishedUtc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        save(file, report)
    print(json.dumps(report))


if __name__ == "__main__":
    main()
