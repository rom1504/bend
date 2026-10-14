#!/usr/bin/env python3
"""Require exact legacy/indexed JS/C outputs and all explicit fixture products.

Usage: compare-reach.py manifest.json old-js old-c new-js new-c new-report.json
"""
import importlib.util
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p90_display', HERE / 'compare.py')
display = importlib.util.module_from_spec(spec)
spec.loader.exec_module(display)
assert len(sys.argv) == 7, __doc__
manifest, *logs, out = map(Path, sys.argv[1:])
meta = json.loads(manifest.read_text())
assert meta['kind'] == 'phase90-indexed-reach-controls'
data = [p.read_bytes() for p in logs]
assert len(set(data)) == 1, 'Complete legacy/indexed JS/C stdout differs'
reader = display.Reader(data[0].decode())
actual = reader.value()
reader.space()
assert reader.at == len(reader.text), 'Unexpected trailing stdout'
assert len(actual) == meta['cases']
for at, (observed, expected) in enumerate(zip(actual, meta['expected'])):
    assert observed == expected, ('Whole product mismatch', at, meta['labels'][at], observed, expected)
report = dict(kind=meta['kind'], complete=True, passed=True, cases=len(actual),
              exactFourOutputs=True, retainedWholeBooks=True, oracle=meta['oracle'], collision=meta['collision'],
              inputs=[display.pin(manifest)]+[display.pin(p) for p in logs],
              methods=[display.pin(Path(__file__)),display.pin(HERE/'compare.py')])
with out.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True,passed=True,cases=len(actual))))
