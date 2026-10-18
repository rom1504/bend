#!/usr/bin/env python3
"""Frozen held-out compilation-cost comparison; execute only under the serial guard.

Reuses the incumbent/native comparison orchestration and clocks without policy
selection. All three sources and three alternating rounds are mandatory.
"""
import hashlib
import importlib.util
import json
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent


def pin(file):
    file = Path(file).resolve(strict=True)
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    freeze_file = HERE/'heldout-latency-freeze.json'
    freeze = json.loads(freeze_file.read_text())
    frozen = pin(freeze_file)
    assert freeze['kind'] == 'phase107-heldout-latency-freeze' and not freeze['targetsRun']
    for item in freeze['inputs'].values():
        assert pin(item['file']) == item, 'changed frozen input: '+item['file']
    assert pin(sys.executable) == freeze['inputs']['python'], 'unfrozen Python interpreter'
    assert pin(freeze['sourceCorrectness']['file']) == freeze['sourceCorrectness']
    correctness = json.loads(Path(freeze['sourceCorrectness']['file']).read_text())
    assert correctness['complete'] and correctness['passed']
    expected = dict(gcd=math.gcd(987, 610),
                    triangular=(511*512//2+1234567890) % 2**32,
                    saturating=min(4294967000+500, 2**32-1)-2**31)
    assert expected == freeze['expectedMain']
    spec = importlib.util.spec_from_file_location('heldout_legacy_method', freeze['inputs']['legacyMethod']['file'])
    legacy = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(legacy)
    suite = dict(kind='phase107-heldout-incumbent-latency',
        sources={name:freeze['inputs'][name]['file'] for name in expected}, expected=expected,
        identity=freeze['identity'], inputs=list(freeze['inputs'].values()),
        methods=[Path(__file__), freeze_file], freeze=frozen,
        oracle='Independent main results: math.gcd(987,610), triangular closed formula plus seed, and saturated integer sum minus high bit. Exact decimal stdout plus one LF and empty stderr on both paths.',
        scope='Final held-out compilation-cost comparison after source correctness, using fixed native image04 and installed native Bend/C/Clang-O2; both prepared Base, same zero-argument main, three alternating rounds, fresh objects with no object-cache reuse. Sources/answers/method frozen before this timing run. No policy adaptation or retroactive held-out policy-search claim; not a runtime-workload speedup.')
    legacy.main(suite)
    assert pin(freeze_file) == frozen
    for item in freeze['inputs'].values():
        assert pin(item['file']) == item


if __name__ == '__main__':
    main()
