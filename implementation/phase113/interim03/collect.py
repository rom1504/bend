#!/usr/bin/env python3
"""Copy an explicit bounded receipt set; never execute or modify build artifacts."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MAX_FILE = 512 * 1024
MAX_TOTAL = 6 * 1024 * 1024
FILES = '''
design/phase113/qbe-program-parity.md
implementation/phase113/evidence/interim02/index.json
selfhost/tools/performance/phase113/direct/ray16-static-delta.json
selfhost/tools/performance/phase113/direct/inspect-ray16.py
selfhost/tools/performance/phase113/direct-opt-products/residual-audit.md
selfhost/tools/performance/phase113/scalar-facts/README.md
selfhost/tools/performance/phase113/scalar-facts/bottom-up.md
selfhost/tools/performance/phase113/scalar-facts/bottom-up.bend
selfhost/tools/performance/phase113/array-fast/composition21.json
selfhost/tools/performance/phase113/array-fast/identity.bend
selfhost/tools/performance/phase113/array-fast/identity-entry.bend
selfhost/tools/performance/phase113/array-fast/heap.bend
selfhost/tools/performance/phase113/array-fast/heap-entry.bend
selfhost/tools/performance/phase113/controls/scalar-facts/manifest02.json
selfhost/tools/performance/phase113/controls/scalar-facts/native-manifest01.json
selfhost/tools/performance/phase113/controls/inliner/comparison-correction01.json
selfhost/build/phase111/p113-shared-api16/report.json
selfhost/build/phase111/p113-arrays-api17/report.json
selfhost/build/phase111/p113-wide-api18/report.json
selfhost/build/phase111/p113-ranges-api19/report.json
selfhost/build/phase111/p113-bottom-api20/report.json
selfhost/build/phase111/p113-identity-api21/report.json
selfhost/build/phase113/shared-source16/manifest.json
selfhost/build/phase113/arrays-source17/manifest.json
selfhost/build/phase113/wide-source18/manifest.json
selfhost/build/phase113/ranges-source19/manifest.json
selfhost/build/phase113/shared-controls16/report.json
selfhost/build/phase113/shared-all16/report.json
selfhost/build/phase113/array-fast-admission02/manifest.json
selfhost/build/phase113/p113-array-structural17/report.json
selfhost/build/phase113/array-all17/report.json
selfhost/build/phase113/field-array17-jobs01/report.json
selfhost/build/phase113/field-array17-jobs01/1.stdout
selfhost/build/phase113/field-array17-jobs02/report.json
selfhost/build/phase113/field-array17-jobs02/3.stdout
selfhost/build/phase113/field-array17-jobs03/report.json
selfhost/build/phase111/p113-field-array17-matched01-baseline-scalar-array-wrap-emit/report.json
selfhost/build/phase111/p113-field-array17-matched02-baseline-shared-array-capture-emit/report.json
selfhost/build/phase113/scalar-facts-controls01/report.json
selfhost/build/phase113/checks18-19/report.json
selfhost/build/phase113/screen-controls17-19/report.json
selfhost/build/phase113/wide-audit18/report.json
selfhost/build/phase113/wide-audit18/before.txt
selfhost/build/phase113/wide-audit18/after.txt
selfhost/build/phase113/wide-ranges18-19/report.json
selfhost/build/phase111/p113-range-native19-baseline-native-bools-nat-observe/report.json
selfhost/build/phase111/p113-range-native19-candidate-native-bools-nat-observe/report.json
selfhost/build/phase112/p113-shared-screen16/phase113-report.json
selfhost/build/phase112/p113-array-screen17/phase113-report.json
selfhost/build/phase112/p113-wide-ranges-screen19/phase113-report.json
selfhost/build/phase112/p113-wide-ranges-screen19/report.json
'''.split()


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    if (HERE / 'index.json').exists() or (HERE / 'files').exists():
        raise ValueError('Fresh capsule required; never overwrite a sealed snapshot')
    rows, payloads, total = [], [], 0
    for number, relative in enumerate(FILES, 1):
        source = ROOT / relative
        before = source.stat()
        raw = source.read_bytes()
        after = source.stat()
        if (before.st_ino, before.st_size, before.st_mtime_ns) != (after.st_ino, after.st_size, after.st_mtime_ns):
            raise ValueError('Changing evidence: ' + relative)
        row = dict(source=relative, bytes=len(raw), sha256=sha(raw), sourceMtimeNs=after.st_mtime_ns)
        if len(raw) <= MAX_FILE and total + len(raw) <= MAX_TOTAL:
            stored = f'files/{number:03d}-{source.name}'
            row.update(storage='copied', file=stored)
            payloads.append((stored, raw))
            total += len(raw)
        else:
            row.update(storage='hash-only', reason='Explicit capsule byte bound')
        rows.append(row)
    (HERE / 'files').mkdir()
    for relative, raw in payloads:
        destination = HERE / relative
        destination.write_bytes(raw)
        if destination.read_bytes() != raw:
            raise ValueError('Copy verification failed: ' + relative)
    method = Path(__file__).read_bytes()
    index = dict(kind='phase113-interim03-bounded-receipt-capsule', complete=True,
                 collectedUtc=datetime.now(timezone.utc).isoformat(), targetsExecuted=False,
                 buildArtifactsModified=False,
                 method=dict(file='collect.py', bytes=len(method), sha256=sha(method)),
                 scope='Completed diagnostics through source19, preserved failed field/array fixtures, and source-check-only API snapshots20/21. No native/runtime success assertion for20/21; no heap qualification.',
                 limits=dict(maximumFileBytes=MAX_FILE, maximumTotalBytes=MAX_TOTAL),
                 copiedFiles=len(payloads), copiedBytes=total, receipts=rows,
                 exclusions=['Full compiler sources, APIs, SSA, objects and executables remain at their original pinned paths.',
                             'Receipt references are retained verbatim; this is not a transitive archive or permission to remove originals.',
                             'Screens are one-round diagnostic1, not qualified paired performance or full45.',
                             'Later mutable run receipts are deliberately outside this snapshot.'])
    (HERE / 'index.json').write_text(json.dumps(index, indent=2) + '\n')
    print(json.dumps(dict(complete=True, copiedFiles=len(payloads), copiedBytes=total,
                          hashOnlyFiles=len(rows)-len(payloads))))


if __name__ == '__main__':
    main()
