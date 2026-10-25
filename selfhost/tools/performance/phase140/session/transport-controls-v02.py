#!/usr/bin/env python3
"""Small transport-only controls: no compiler or generated program execution."""
import argparse
import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import shutil
import traceback

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("transport", HERE / "transport-v02.py")
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)


def wire_piece(ordinal, data, ending=False):
    return (f"# P140/2 BEGIN {ordinal} {int(ending)} {len(data)}\n".encode() + data +
            f"\n# P140/2 END {ordinal}\n".encode())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists()
    out.mkdir(parents=True)
    fixtures = out / "fixtures"
    fixtures.mkdir()
    for name, data in [("producer", b"independent producer identity fixture"),
                       ("runtime", b"independent runtime identity fixture"),
                       ("a.bend", b"source A"), ("b.bend", b"source B")]:
        (fixtures / name).write_bytes(data)
    context = {"kind": "phase140-transport-context", "protocol": 2, "session": "transport-controls",
               "producer": T.pin(fixtures / "producer"), "runtime": T.pin(fixtures / "runtime"),
               "source": T.pin(fixtures / "a.bend"), "policy": {"target": "qbe", "testOnly": True}, "inputs": []}
    ctx = fixtures / "context-a.json"
    ctx.write_text(json.dumps(context))
    ctx_sha = T.pin(ctx)["sha256"]
    context_b = copy.deepcopy(context)
    context_b["source"] = T.pin(fixtures / "b.bend")
    ctx_b = fixtures / "context-b.json"
    ctx_b.write_text(json.dumps(context_b))
    ctx_b_sha = T.pin(ctx_b)["sha256"]
    rows = []

    def check(name, action):
        try:
            action()
            rows.append({"name": name, "passed": True})
        except Exception as error:
            rows.append({"name": name, "passed": False, "error": str(error), "trace": traceback.format_exc()})

    def positive(name, wire, expected, prior=None, chosen_context=ctx, chosen_sha=ctx_sha):
        path = out / name
        r = T.decode(io.BytesIO(wire), path, chosen_context, chosen_sha,
                     None if prior is None else prior, None if prior is None else T.pin(prior)["sha256"],
                     hashlib.sha256(expected).hexdigest())
        assert r["complete"] and not r["producerSuccessAttested"]
        assert (path / "payload.bin").read_bytes() == expected
        assert T.pin(path / "payload.bin") == r["payload"]
        return path / "report.json"

    def negative(name, wire, prior=None, chosen_context=ctx, chosen_sha=ctx_sha, prior_sha=None):
        path = out / name
        try:
            T.decode(io.BytesIO(wire), path, chosen_context, chosen_sha,
                     prior, (T.pin(prior)["sha256"] if prior_sha is None else prior_sha) if prior else None)
        except (T.TransportError, KeyError, TypeError):
            if path.exists():
                assert not (path / "payload.bin").exists()
                assert not (path / "payload.partial").exists()
                assert not json.loads((path / "report.json").read_text())["complete"]
            return
        raise AssertionError("Malformed transport was accepted")

    check("empty-complete-stream", lambda: positive("empty", b"# P140/2 DONE 0\n", b""))
    payload = b"partial " + "é😀".encode() + b"\x00\n# P140/2 END 0\n# P140/2 REUSE 1 0\n# P140/1 END 0\n"
    check("marker-unicode-nul-payload-is-opaque", lambda: positive("opaque", wire_piece(0, payload) + b"# P140/2 DONE 1\n", payload))
    large = b"x" * (T.BUFFER + 13) + b"\n"
    check("payload-crosses-copy-buffer", lambda: positive("buffer", wire_piece(0, large, True) + b"# P140/2 DONE 1\n", large))
    baseline_bytes = b"first-part" + b"second\n"
    prior = positive("prior", wire_piece(0, b"first-part") + wire_piece(1, b"second\n", True) + b"# P140/2 DONE 2\n", baseline_bytes)
    check("reuse-only-pinned-ordinal-reordering", lambda: positive("reused",
          b"# P140/2 REUSE 0 1\n# P140/2 REUSE 1 0\n# P140/2 DONE 2\n", b"second\nfirst-part", prior))
    check("new-source-same-epoch-allowed", lambda: positive("source-b",
          b"# P140/2 REUSE 0 0\n" + wire_piece(1, b"changed\n", True) + b"# P140/2 DONE 2\n",
          b"first-partchanged\n", prior, ctx_b, ctx_b_sha))
    check("empty-piece-and-partial-lines", lambda: positive("zero-piece",
          wire_piece(0, b"") + wire_piece(1, b"a") + wire_piece(2, b"b\n", True) + b"# P140/2 DONE 3\n", b"ab\n"))

    malformed = {
        "old-marker-protocol-refused": b"# P140/1 DONE 0\n",
        "unknown-command": b"# P140/2 SURPRISE 0\n",
        "missing-done": wire_piece(0, b"x"),
        "truncated-header": b"# P140/2 BEG",
        "truncated-payload": b"# P140/2 BEGIN 0 0 9\nabc",
        "wrong-end-ordinal": b"# P140/2 BEGIN 0 0 1\nx\n# P140/2 END 1\n# P140/2 DONE 1\n",
        "wrong-done-count": wire_piece(0, b"x") + b"# P140/2 DONE 2\n",
        "skipped-current-ordinal": wire_piece(1, b"x") + b"# P140/2 DONE 1\n",
        "duplicated-current-ordinal": wire_piece(0, b"x") + wire_piece(0, b"y") + b"# P140/2 DONE 2\n",
        "invalid-newline-flag": b"# P140/2 BEGIN 0 2 0\n\n# P140/2 END 0\n# P140/2 DONE 1\n",
        "claimed-newline-missing": wire_piece(0, b"x", True) + b"# P140/2 DONE 1\n",
        "noncanonical-number": b"# P140/2 BEGIN 00 0 0\n",
        "negative-reuse-ordinal": b"# P140/2 REUSE 0 -1\n# P140/2 DONE 1\n",
        "reuse-without-prior": b"# P140/2 REUSE 0 0\n# P140/2 DONE 1\n",
        "overlarge-piece-header": f"# P140/2 BEGIN 0 0 {T.MAX_PIECE + 1}\n".encode(),
        "overlong-header": b"#" * (T.MAX_HEADER + 1) + b"\n",
        "trailing-data-after-done": b"# P140/2 DONE 0\nextra",
    }
    for name, wire in malformed.items():
        check(name, lambda name=name, wire=wire: negative(name, wire))
    check("reuse-outside-prior", lambda: negative("bad-old", b"# P140/2 REUSE 0 2\n# P140/2 DONE 1\n", prior))
    check("prior-manifest-digest-refused", lambda: negative("bad-pin", b"# P140/2 DONE 0\n", prior, prior_sha="0" * 64))
    check("context-manifest-digest-refused", lambda: negative("bad-context-pin", b"# P140/2 DONE 0\n", chosen_sha="0" * 64))

    def changed_epoch():
        changed = copy.deepcopy(context)
        changed["session"] = "different-session"
        file = fixtures / "changed-session.json"
        file.write_text(json.dumps(changed))
        negative("bad-session", b"# P140/2 DONE 0\n", prior, file, T.pin(file)["sha256"])
    check("prior-epoch-mismatch-refused", changed_epoch)

    def corrupt_payload():
        file = prior.parent / "payload.bin"
        saved = file.read_bytes()
        try:
            file.write_bytes(b"!" + saved[1:])
            negative("bad-payload", b"# P140/2 REUSE 0 0\n# P140/2 DONE 1\n", prior)
        finally:
            file.write_bytes(saved)
    check("corrupt-prior-payload-refused", corrupt_payload)

    def corrupted_rows(kind):
        folder = out / ("fixture-" + kind)
        folder.mkdir()
        shutil.copyfile(prior.parent / "payload.bin", folder / "payload.bin")
        manifest = json.loads(prior.read_text())
        manifest["payload"] = T.pin(folder / "payload.bin")
        if kind == "offset":
            manifest["rows"][1]["offset"] += 1
        elif kind == "digest":
            manifest["rows"][0]["sha256"] = "0" * 64
        else:
            manifest["payload"] = T.pin(prior.parent / "payload.bin")
        file = folder / "report.json"
        file.write_text(json.dumps(manifest))
        negative("bad-row-" + kind, b"# P140/2 REUSE 0 0\n# P140/2 DONE 1\n", file)
    for kind in ("offset", "digest", "path"):
        check("prior-" + kind + "-refused", lambda kind=kind: corrupted_rows(kind))

    report = {"kind": "phase140-byte-transport-controls", "complete": all(x["passed"] for x in rows),
              "compilerTargetsRun": False, "scope": "Synthetic byte/identity fixtures only",
              "inputs": [T.pin(__file__), T.pin(HERE / "transport-v02.py")], "rows": rows}
    (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"complete": report["complete"], "rows": len(rows), "failed": [x for x in rows if not x["passed"]], "report": T.pin(out / "report.json")}))
    raise SystemExit(0 if report["complete"] else 1)


if __name__ == "__main__":
    main()
