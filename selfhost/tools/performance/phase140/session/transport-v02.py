#!/usr/bin/env python3
"""Decode compiler-owned P140/2 frames; no compiler decisions or QBE parsing.

Payloads use a counted byte prefix, so arbitrary payload bytes cannot terminate
a frame. Reuse reads only authenticated ordinal ranges of one prior payload.
The supervisor must separately join successful producer status before adopting
the reconstructed output; DONE alone does not prove process success.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys

BUFFER = 65536
MAX_HEADER = 256
MAX_PIECE = 64 * 1024 * 1024
MAX_TOTAL = 512 * 1024 * 1024
MAX_RECORDS = 100000
DECIMAL = rb"(0|[1-9][0-9]*)"
BEGIN = re.compile(rb"# P140/2 BEGIN " + DECIMAL + rb" ([01]) " + DECIMAL + rb"\n\Z")
REUSE = re.compile(rb"# P140/2 REUSE " + DECIMAL + rb" " + DECIMAL + rb"\n\Z")
DONE = re.compile(rb"# P140/2 DONE " + DECIMAL + rb"\n\Z")


class TransportError(ValueError):
    pass


def require(ok, message):
    if not ok:
        raise TransportError(message)


def pin(file):
    file = Path(file).resolve()
    digest = hashlib.sha256()
    size = 0
    with file.open("rb") as handle:
        while data := handle.read(BUFFER):
            size += len(data)
            digest.update(data)
    return {"file": str(file), "bytes": size, "sha256": digest.hexdigest()}


def verify(item, seen=None):
    require(isinstance(item, dict) and set(item) == {"file", "bytes", "sha256"}, "Malformed artifact pin")
    identity = (item["file"], item["bytes"], item["sha256"])
    if seen is not None and identity in seen:
        return
    require(pin(item["file"]) == item, "Artifact identity changed: " + item["file"])
    if seen is not None:
        seen.add(identity)


def json_input(file, expected_sha):
    identity = pin(file)
    require(identity["sha256"] == expected_sha, "Manifest digest mismatch")
    require(identity["bytes"] <= 48 * 1024 * 1024, "Manifest size limit exceeded")
    with Path(file).open() as handle:
        result = json.load(handle)
    require(pin(file) == identity, "Manifest changed while reading")
    return result, identity


def context_input(file, expected_sha, seen=None):
    if seen is None:
        seen = set()
    context, identity = json_input(file, expected_sha)
    require(context.get("kind") == "phase140-transport-context" and context.get("protocol") == 2, "Unknown context schema")
    require(isinstance(context.get("session"), str) and 0 < len(context["session"]) <= 128, "Missing session identity")
    require(isinstance(context.get("policy"), dict), "Missing policy identity")
    for key in ("producer", "runtime", "source"):
        verify(context[key], seen)
    require(isinstance(context.get("inputs", []), list), "Malformed context inputs")
    for item in context.get("inputs", []):
        verify(item, seen)
    return context, identity


def epoch(context):
    return {key: context[key] for key in ("protocol", "session", "producer", "runtime", "policy")}


def prior_input(file, expected_sha, context, seen=None):
    if seen is None:
        seen = set()
    prior, identity = json_input(file, expected_sha)
    require(prior.get("kind") == "phase140-byte-transport" and prior.get("complete") is True, "Prior transport is incomplete")
    require(prior.get("producerSuccessAttested") is False, "Unknown transport status schema")
    require(epoch(prior["context"]) == epoch(context), "Prior producer/runtime/policy/session mismatch")
    for key in ("producer", "runtime", "source"):
        verify(prior["context"][key], seen)
    for item in prior["context"].get("inputs", []):
        verify(item, seen)
    payload = prior["payload"]
    # The wire protocol never supplies paths. Exactly this artifact is allowed.
    require(Path(payload["file"]).resolve() == Path(file).resolve().parent / "payload.bin", "Prior payload escaped its artifact directory")
    verify(payload, seen)
    require(payload["bytes"] <= MAX_TOTAL, "Prior payload exceeds limit")
    rows = prior["rows"]
    require(isinstance(rows, list) and len(rows) <= MAX_RECORDS, "Prior row limit exceeded")
    offset = 0
    for ordinal, row in enumerate(rows):
        require(row.get("ordinal") == ordinal and row.get("offset") == offset, "Prior ordinal/offset order invalid")
        require(type(row.get("bytes")) is int and 0 <= row["bytes"] <= MAX_PIECE, "Prior piece size invalid")
        require(type(row.get("ending")) is bool, "Prior newline flag invalid")
        require(isinstance(row.get("sha256"), str) and re.fullmatch(r"[0-9a-f]{64}", row["sha256"]), "Prior piece digest invalid")
        offset += row["bytes"]
    require(offset == payload["bytes"] and prior.get("pieces") == len(rows), "Prior coverage invalid")
    return prior, identity


class Wire:
    def __init__(self, source):
        self.source = source
        self.bytes = 0
        self.digest = hashlib.sha256()

    def read(self, count):
        data = self.source.read(count)
        require(isinstance(data, bytes), "Input is not a binary stream")
        self.bytes += len(data)
        self.digest.update(data)
        return data

    def line(self):
        # Keep the same 256-byte bound, including an accepted newline at byte
        # 256, while doing one bounded read/hash update rather than one per byte.
        result = self.source.readline(MAX_HEADER)
        require(isinstance(result, bytes), "Input is not a binary stream")
        self.bytes += len(result)
        self.digest.update(result)
        if result.endswith(b"\n"):
            return result
        require(len(result) < MAX_HEADER, "Frame header limit exceeded")
        raise TransportError("Truncated frame header or missing DONE")

    def exact(self, count):
        result = bytearray()
        while len(result) < count:
            data = self.read(min(BUFFER, count - len(result)))
            require(data, "Truncated frame delimiter")
            result.extend(data)
        return bytes(result)


def decode(stream, out, context_file, context_sha, prior_file=None, prior_sha=None, expected_payload_sha=None):
    out = Path(out).resolve()
    require(not out.exists(), "Use a fresh output directory")
    # Verification memoization is local to this preflight. Postflight below
    # starts a NEW set, so mutations during decoding are still checked.
    preflight_seen = set()
    context, context_pin = context_input(context_file, context_sha, preflight_seen)
    require((prior_file is None) == (prior_sha is None), "Prior path and digest must be paired")
    prior, prior_pin = (None, None) if prior_file is None else prior_input(prior_file, prior_sha, context, preflight_seen)
    pins = [context_pin, *[context[x] for x in ("producer", "runtime", "source")], *context.get("inputs", [])]
    if prior is not None:
        pins.extend([prior_pin, prior["payload"]])
    require(all(not Path(item["file"]).resolve().is_relative_to(out) for item in pins), "Output overlaps an input")
    out.mkdir(parents=True)
    partial = out / "payload.partial"
    report = {"kind": "phase140-byte-transport", "protocol": 2, "complete": False,
              "producerSuccessAttested": False, "scope": "Byte transport only; producer status must be joined independently",
              "context": context, "contextManifest": context_pin, "priorManifest": prior_pin,
              "inputs": [pin(__file__), *pins], "rows": [], "pieces": 0, "reusedPieces": 0,
              "freshBytes": 0, "reusedBytes": 0, "bufferBytes": BUFFER}
    wire = Wire(stream)
    total_hash = hashlib.sha256()
    offset = 0
    prior_handle = None
    try:
        if prior is not None:
            prior_handle = Path(prior["payload"]["file"]).open("rb")
        with partial.open("xb") as output:
            while True:
                line = wire.line()
                end = DONE.fullmatch(line)
                if end:
                    require(int(end[1]) == len(report["rows"]), "DONE ordinal mismatch")
                    require(wire.read(1) == b"", "Trailing bytes after DONE")
                    break
                require(len(report["rows"]) < MAX_RECORDS, "Record limit exceeded")
                begin, reuse = BEGIN.fullmatch(line), REUSE.fullmatch(line)
                require(begin is not None or reuse is not None, "Unknown or malformed frame header")
                match = begin if begin is not None else reuse
                ordinal = int(match[1])
                require(ordinal == len(report["rows"]), "Current ordinal mismatch")
                if begin is not None:
                    ending, size, old = bool(int(begin[2])), int(begin[3]), None
                    require(size <= MAX_PIECE, "Piece size limit exceeded")
                    reader = wire.read
                else:
                    old = int(reuse[2])
                    require(prior is not None and old < len(prior["rows"]), "Reuse ordinal is unavailable")
                    previous = prior["rows"][old]
                    ending, size = previous["ending"], previous["bytes"]
                    prior_handle.seek(previous["offset"])
                    reader = prior_handle.read
                require(offset + size <= MAX_TOTAL, "Output size limit exceeded")
                chunk_hash, remaining, last = hashlib.sha256(), size, b""
                while remaining:
                    data = reader(min(BUFFER, remaining))
                    require(data and len(data) <= remaining, "Truncated payload")
                    output.write(data)
                    chunk_hash.update(data)
                    total_hash.update(data)
                    remaining -= len(data)
                    last = data[-1:]
                require(not ending or last == b"\n", "Legacy newline missing from counted payload")
                digest = chunk_hash.hexdigest()
                if old is None:
                    require(wire.exact(len(b"\n# P140/2 END " + str(ordinal).encode() + b"\n")) ==
                            b"\n# P140/2 END " + str(ordinal).encode() + b"\n", "Frame END mismatch")
                    report["freshBytes"] += size
                else:
                    require(digest == previous["sha256"], "Prior piece digest mismatch")
                    report["reusedPieces"] += 1
                    report["reusedBytes"] += size
                report["rows"].append({"ordinal": ordinal, "offset": offset, "bytes": size,
                                       "sha256": digest, "ending": ending, "priorOrdinal": old})
                offset += size
            output.flush()
        require(expected_payload_sha is None or total_hash.hexdigest() == expected_payload_sha, "Reconstructed payload oracle mismatch")
        postflight_seen = set()
        for item in report["inputs"]:
            verify(item, postflight_seen)
        partial.rename(out / "payload.bin")
        report.update(complete=True, pieces=len(report["rows"]),
                      payload={"file": str(out / "payload.bin"), "bytes": offset, "sha256": total_hash.hexdigest()})
    except Exception as error:
        report["error"] = str(error)
        partial.unlink(missing_ok=True)
        raise
    finally:
        if prior_handle is not None:
            prior_handle.close()
        report["wire"] = {"bytes": wire.bytes, "sha256": wire.digest.hexdigest()}
        (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stream", required=True, help="Binary frame file/FIFO, or - for stdin")
    parser.add_argument("--out", required=True)
    parser.add_argument("--context", required=True)
    parser.add_argument("--context-sha256", required=True)
    parser.add_argument("--prior")
    parser.add_argument("--prior-sha256")
    parser.add_argument("--expected-payload-sha256")
    args = parser.parse_args()
    handle = sys.stdin.buffer if args.stream == "-" else open(args.stream, "rb")
    try:
        report = decode(handle, args.out, args.context, args.context_sha256, args.prior, args.prior_sha256,
                        args.expected_payload_sha256)
        print(json.dumps({"complete": True, "pieces": report["pieces"], "reusedPieces": report["reusedPieces"],
                          "payload": report["payload"], "report": pin(Path(args.out) / "report.json")}))
    finally:
        if handle is not sys.stdin.buffer:
            handle.close()


if __name__ == "__main__":
    main()
