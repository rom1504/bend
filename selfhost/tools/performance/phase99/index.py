#!/usr/bin/env python3
"""Data-only compact receipt index; run after writers freeze, before sealing."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase99'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); assert not a.out.exists()
    paths = sorted({p for pattern in ['*/changes.json', '*/report.json', '*/*/report.json', '*/collected.json', '*/*/collected.json']
                    for p in BUILD.glob(pattern)})
    rows = []
    for path in paths:
        identity = pin(path); report = json.loads(path.read_text())
        status = {k:report[k] for k in ['kind', 'complete', 'passed', 'qualified', 'inputsUnchanged', 'error'] if k in report}
        sources = [report[k] for k in ['source', 'candidate'] if isinstance(report.get(k), dict) and 'sha256' in report[k]]
        rows.append(dict(receipt=identity, declaredStatus=status, sourceBindings=sources))
        assert pin(path) == identity, 'Receipt changed while indexing'
    result = dict(kind='phase99-receipt-index', complete=True, targetsRun=False, method=pin(Path(__file__).resolve()),
        baseline=pin(ROOT / 'selfhost/tools/performance/phase99/qualification/baseline.json'),
        priorEvidence=pin(ROOT / 'selfhost/tools/performance/phase98/artifacts/evidence01/receipt.json'),
        receipts=rows, scope='Navigation over retained source recipes and top-level/nested suite reports, including failures. '
        'Declared statuses are copied, not independently qualified. Raw guards and deeper outputs remain in their original trees and evidence archive.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, receipts=len(rows), index=str(a.out))))


if __name__ == '__main__': main()
