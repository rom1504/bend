#!/usr/bin/env python3
"""API-only v4 successor selecting an explicitly typed protocol-control fixture."""
import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PREVIOUS = Path(__file__).with_name('prepare-native-variants-v4.py')
PREVIOUS_SHA = '8d54373955120d33f1bde1fdceb499f67599206879e2ef6168116761d5c8db51'


def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    forwarded = sys.argv[1:]
    assert '--api' in forwarded and '--native-protocol' in forwarded, 'API protocol preparation only'
    previous = pin(PREVIOUS)
    assert previous['sha256'] == PREVIOUS_SHA, 'Frozen v4 method changed'
    old_control = ROOT / 'selfhost/tests/phase169/native-protocol-controls.bend'
    new_control = old_control.with_name('native-protocol-controls-v2.bend')
    before, after = old_control.read_bytes(), new_control.read_bytes()
    old = b'  +book = [p169npc_foreign'
    new = b'  +book : List<&2,KDef> = [p169npc_foreign'
    assert before.count(old) == after.count(new) == 1
    assert before.replace(old, new, 1) == after and after.replace(new, old, 1) == before
    spec = importlib.util.spec_from_file_location('phase169_variants_v4', PREVIOUS)
    v4 = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v4)
    invocations = []

    def extract(command, *, cwd):
        assert not invocations and command.count(str(old_control)) == 1
        at = command.index(str(old_control))
        assert command[at - 1] == '--module'
        # v4 retains this same list in its derivation, so the receipt records
        # the actual substituted command, not the unexecuted predecessor.
        command[at] = str(new_control)
        invocations.append(list(command))
        return subprocess.call(command, cwd=cwd)

    v4.subprocess = SimpleNamespace(call=extract)
    result = v4.main()
    if result == 0:
        command = invocations[0]
        out = Path(command[command.index('--out') + 1]).resolve()
        repair = out / 'protocol-control-repair.json'
        repair.write_text(json.dumps(dict(targetsRun=False, productionChanged=False,
            previousMethod=previous, method=pin(Path(__file__)), original=pin(old_control),
            successor=pin(new_control), inverseExact=True,
            change='Explicit List<&2,KDef> annotation on the finite fixture book'), indent=2) + '\n')
        manifest = out / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['inputs'] += [pin(Path(__file__)), pin(repair), pin(old_control)]
        manifest.write_text(json.dumps(data, indent=2) + '\n')
    assert pin(PREVIOUS) == previous, 'Frozen v4 method changed'
    assert old_control.read_bytes() == before and new_control.read_bytes() == after, 'Control inputs changed'
    return result


if __name__ == '__main__':
    raise SystemExit(main())
