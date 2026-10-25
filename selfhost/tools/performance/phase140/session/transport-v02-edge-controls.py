#!/usr/bin/env python3
"""Extra boundary/TOCTOU controls for the transport-only v02 optimization."""
import argparse
import hashlib
import importlib.util
import io
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def load(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists()
    out.mkdir(parents=True)
    old = load("old_transport", HERE / "transport.py")
    new = load("new_transport", HERE / "transport-v02.py")
    rows = []
    for name, data, succeeds in [
        ("header-newline-at-256", b"x" * 255 + b"\n", True),
        ("header-no-newline-at-256", b"x" * 256, False),
        ("header-newline-at-257", b"x" * 256 + b"\n", False),
        ("header-truncated-below-bound", b"short", False),
    ]:
        results = []
        for module in (old, new):
            wire = module.Wire(io.BytesIO(data))
            try:
                value = wire.line()
                result = [True, value.hex(), wire.bytes, wire.digest.hexdigest()]
            except module.TransportError as error:
                result = [False, str(error), wire.bytes, wire.digest.hexdigest()]
            results.append(result)
        assert results[0] == results[1] and results[0][0] == succeeds
        rows.append({"name": name, "passed": True})

    fixture = out / "identity.fixture"
    fixture.write_bytes(b"original")
    identity = new.pin(fixture)
    seen = set()
    new.verify(identity, seen)
    bad = dict(identity, sha256="0" * 64)
    try:
        new.verify(bad, seen)
    except new.TransportError:
        rows.append({"name": "different-pin-same-path-is-not-skipped", "passed": True})
    else:
        raise AssertionError("Conflicting pin was silently skipped")

    # Change an authenticated input only after preflight has completed. The
    # memoized preflight must not be reused by postflight validation.
    context = {"kind": "phase140-transport-context", "protocol": 2, "session": "mutation-test",
               "producer": identity, "runtime": identity, "source": identity,
               "policy": {}, "inputs": [identity, identity]}
    file = out / "context.json"
    file.write_text(json.dumps(context))
    class MutatingStream(io.BytesIO):
        def readline(self, count=-1):
            fixture.write_bytes(b"mutated during transport")
            return super().readline(count)
    try:
        new.decode(MutatingStream(b"# P140/2 DONE 0\n"), out / "mutated", file, new.pin(file)["sha256"])
    except new.TransportError:
        report = json.loads((out / "mutated/report.json").read_text())
        assert not report["complete"] and "Artifact identity changed" in report["error"]
        assert not (out / "mutated/payload.bin").exists()
        rows.append({"name": "postflight-rechecks-despite-preflight-memo", "passed": True})
    else:
        raise AssertionError("Postflight mutation was accepted")
    finally:
        fixture.write_bytes(b"original")
    report = {"kind": "phase140-transport-v02-edge-controls", "complete": True, "compilerTargetsRun": False,
              "inputs": [new.pin(__file__), new.pin(HERE / "transport.py"), new.pin(HERE / "transport-v02.py")], "rows": rows}
    (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"complete": True, "rows": len(rows), "report": new.pin(out / "report.json")}))


if __name__ == "__main__":
    main()
