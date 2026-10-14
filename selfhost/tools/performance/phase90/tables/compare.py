#!/usr/bin/env python3
"""Exact whole-output and independent codepoint oracle for actual table helpers."""
import hashlib
import json
import sys
from pathlib import Path

assert len(sys.argv) == 5, 'compare.py CONTROLS.json JS_STDOUT NATIVE_STDOUT FRESH_REPORT.json'
meta, js, native, out = map(Path, sys.argv[1:])
assert not out.exists()
control = json.loads(meta.read_text())
assert js.read_bytes() == native.read_bytes(), 'Complete JS/native output differs'
words = json.loads(js.read_text())
assert isinstance(words, list) and all(type(v) is int for v in words)
assert words == control['expectedWords'], 'Table text/codepoint oracle mismatch'
pin = lambda p: dict(file=str(p.resolve()), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)
assert pin(Path(control['source']['file'])) == control['source'], 'Changed controls source'
for value in control['dependencies']:
    assert pin(Path(value['file'])) == value, 'Changed actual function dependency'
report = dict(kind='phase90-actual-table-control-comparison', complete=True, passed=True,
    cases=len(control['cases']), exactStringObservations=len(control['observations']),
    codepointWords=len(words), exactOutput=True, inputs=[pin(p) for p in [meta, js, native]], method=pin(Path(__file__)))
with out.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, observations=report['exactStringObservations'], words=len(words))))
