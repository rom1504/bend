#!/usr/bin/env python3
"""Prepare a metadata-only successor of the frozen Phase47 baseline packer.

Root runs the emitted packer separately on CPU0. This factory does not compile,
import generated programs, time targets, or edit any historical evidence.
"""
import argparse
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PARENT = HERE.parent / 'phase47/freeze-baseline.py'
PARENT_SHA = '2a8d75939f0337ae559bdbfd0f1e6831a1a2e2e1570687c8f1f5ef596518ae27'


def identity(file):
    data = file.read_bytes()
    return dict(file=str(file.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True, help='Fresh derivation directory')
    args = parser.parse_args()
    parent = identity(PARENT)
    assert parent['sha256'] == PARENT_SHA
    source = PARENT.read_text()
    changes = [
        ('HERE = Path(__file__).resolve().parent', f'HERE = Path({str(PARENT.parent)!r})'),
        ('Phase47 starting Phase45 worker23 (retained verified portable acquisition)',
         'Phase48 starting Phase47 array06 (retained verified portable acquisition)'),
        ("kind='phase47-retained-checked-reference'", "kind='phase48-retained-checked-reference'"),
        ('Repackages exact retained Phase45 worker23 current and pinned TS outputs.',
         'Repackages exact retained Phase47 array06 current and pinned TS outputs.'),
        ("parentTool=identity(HERE.parent/'phase44/freeze-baseline.py')",
         "parentTool=identity(HERE/'freeze-baseline.py')"),
    ]
    for before, after in changes:
        assert source.count(before) == 1, 'Frozen parent no longer matches'
        source = source.replace(before, after, 1)
    ast.parse(source)
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out / 'phase47-freeze-baseline.py').write_bytes(PARENT.read_bytes())
    (out / 'freeze-baseline.py').write_text(source)
    receipt = dict(kind='phase48-baseline-method-derivation', complete=True,
        targetExecuted=False, baselineAcquired=False, producer=identity(Path(__file__)),
        parent=parent, preservedParent=identity(out / 'phase47-freeze-baseline.py'),
        derived=identity(out / 'freeze-baseline.py'), changes=changes,
        unchanged=['Checked bundle loading and all module/source/catalog checks',
                   'Explicit expected API and runtime assertions',
                   'Exact pinned TypeScript role bytes',
                   'Archive construction, reopen verification and input rehash',
                   'No compiler or generated-program execution'])
    assert identity(PARENT) == parent
    with (out / 'derivation.json').open('x') as stream:
        json.dump(receipt, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, targetExecuted=False, baselineAcquired=False,
                         packer=str(out / 'freeze-baseline.py'), receipt=str(out / 'derivation.json'))))


if __name__ == '__main__':
    main()
