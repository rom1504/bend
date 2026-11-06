#!/usr/bin/env python3
"""Extract the exact quality-candidate modules with native main as the sole root.

Only the metadata extractor's export arguments change. All compiler semantics
remain the checked candidate's Bend modules; this script runs no compiler job.
"""
import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PREVIOUS = Path(__file__).with_name('prepare-cold-emission.py')


def pin(path):
    path = path.resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    assert '--api' not in sys.argv, 'This adapter selects native main, not an API'
    previous = pin(PREVIOUS)
    assert previous['sha256'] == 'fc6ee9a64b9bb867e7e36f4fd34f735a78954fa22ba742b66dd0e0e4a51e0932'
    spec = importlib.util.spec_from_file_location('phase169_cold_emission', PREVIOUS)
    old = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(old)
    invocations = []

    def extract(command, *, cwd):
        assert not invocations and Path(cwd) == ROOT
        original = list(command)
        retained, removed, index = [], [], 0
        while index < len(command):
            if command[index] == '--export':
                removed.append(command[index + 1])
                index += 2
            else:
                retained.append(command[index])
                index += 1
        assert removed and 'p169s_plan' in removed
        command[:] = [*retained, '--export', 'main']
        invocations.append(dict(beforeExportSelection=original, actualCommand=list(command),
                                removedExports=removed, selectedExports=['main']))
        return subprocess.call(command, cwd=cwd)

    old.subprocess = SimpleNamespace(call=extract)
    sys.argv = [str(PREVIOUS), '--api', *sys.argv[1:]]
    result = old.main()
    if result == 0:
        command = invocations[0]['actualCommand']
        out = Path(command[command.index('--out') + 1]).resolve()
        path = out / 'manifest.json'
        data = json.loads(path.read_text())
        assert data['exports'] == ['main']
        receipt = out / 'native-entry-derivation.json'
        receipt.write_text(json.dumps(dict(targetsRun=False, productionChanged=False,
            method=pin(Path(__file__)), previousMethod=previous, invocation=invocations[0],
            source=data['source'], protocol='qbe-source-v1',
            scope='Source preparation only; six-string native entry unchanged, no image qualification.'), indent=2) + '\n')
        data['inputs'] += [pin(Path(__file__)), pin(receipt)]
        data['nativeEntry'] = pin(receipt)
        path.write_text(json.dumps(data, indent=2) + '\n')
    assert pin(PREVIOUS) == previous
    return result


if __name__ == '__main__':
    raise SystemExit(main())
