#!/usr/bin/env python3
"""Data-only immutable method snapshot for root qualification executions."""
import argparse
import json
from pathlib import Path
from support import ROOT, HERE, pin


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args(); out = a.out.resolve()
    assert out.parent == ROOT / 'selfhost/build/phase98' and not out.exists()
    (out / 'methods').mkdir(parents=True)
    inputs, outputs = [], []
    for file in sorted(HERE.iterdir()):
        if not file.is_file(): continue
        before = pin(file); dest = out / 'methods' / file.name
        dest.write_bytes(file.read_bytes()); after = pin(dest)
        assert pin(file) == before and all(before[k] == after[k] for k in ['sha256', 'bytes'])
        inputs.append(before); outputs.append(after)
    report = dict(kind='phase98-qualification-method-snapshot', complete=True, targetsRun=False,
                  inputs=inputs, frozenInputs=outputs,
                  execution='Run methods/*.py from this immutable snapshot; its source paths then remain valid if development tools change.')
    (out / 'receipt.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, methods=str(out / 'methods'), files=len(outputs))))


if __name__ == '__main__': main()
