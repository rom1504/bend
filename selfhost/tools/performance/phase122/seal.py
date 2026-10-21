"""Reuse the bounded receipt archive format for the Phase122 diagnostic."""
import argparse
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('receipt121', ROOT / 'selfhost/tools/performance/phase121/seal.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
S.source_roots = lambda: [ROOT / 'selfhost/build/phase122', Path(__file__).resolve().parent]
original_receipt = S.receipt
S.receipt = lambda p: original_receipt(p) or p.suffix == '.py'

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('mode', choices=['seal', 'replay'])
p.add_argument('path', type=Path)
a = p.parse_args()
if a.mode == 'seal':
    S.seal(a.path.resolve())
else:
    _, manifest = S.replay(a.path.resolve())
    print('Verified', len(manifest['files']), 'payloads;', manifest['rawBytes'], 'bytes')
