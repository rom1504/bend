#!/usr/bin/env python3
"""Offline reversible Phase98 derivative with canonical iterative String append."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT/'selfhost/build/phase98/origin-guard-source01/compiler.bend'
SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'


def pin(file):
    file = Path(file).resolve(); data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve(); assert not out.exists()
    assert out.is_relative_to(ROOT/'selfhost/build/phase102') or out.is_relative_to(HERE)
    sourcePin = pin(BASE); assert sourcePin['sha256'] == SHA
    method = HERE/'integrate.py'
    spec = importlib.util.spec_from_file_location('p102_append_integrate', method)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    original = BASE.read_text()
    candidate, changes = module.patch(original, 'p88_string_eq')
    forward = original
    for change in changes:
        at, old, new = (change[key] for key in ('offset','old','new'))
        assert forward[at:at+len(old)] == old
        forward = forward[:at]+new+forward[at+len(old):]
    assert forward == candidate
    reverse = candidate
    for change in reversed(changes):
        at, old, new = (change[key] for key in ('offset','old','new'))
        assert reverse[at:at+len(new)] == new
        reverse = reverse[:at]+old+reverse[at+len(new):]
    assert reverse == original
    out.mkdir(parents=True)
    (out/'compiler.bend').write_text(candidate)
    report = dict(kind='phase102-linked-append-compiler-source', complete=True,
        targetsRun=False, releaseQualified=False, method=pin(__file__),
        integrationMethod=pin(method), helper=pin(HERE/'append.bend'),
        source=sourcePin, candidate=pin(out/'compiler.bend'), changes=changes,
        forwardReplayExact=True, inverseExact=True,
        physicalLineDelta=len(candidate.splitlines())-len(original.splitlines()),
        byteDelta=len(candidate.encode())-len(original.encode()),
        scope='Checked exact canonical String.append body/owner/signature; consuming original linked ABI; CPU-only helper with original device body fallback; no runtime/template/provider or release mutation.')
    assert pin(BASE)==sourcePin
    (out/'changes.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({key:report[key] for key in ('candidate','physicalLineDelta','byteDelta')}))


if __name__ == '__main__':
    main()
