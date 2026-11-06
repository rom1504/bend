#!/usr/bin/env python3
"""Optional source-authorized mode2 with fully typed protocol control locals."""
import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PREVIOUS = Path(__file__).with_name('prepare-native-variants-v5.py')


def pin(path):
    path = path.resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    assert '--api' in sys.argv and '--single-verify' in sys.argv and '--native-protocol' in sys.argv
    previous = pin(PREVIOUS)
    assert previous['sha256'] == '99918bac786d6f85c879256e8c65001d93b79f0b25f4f527c821748c759a6843'
    original = ROOT / 'selfhost/tests/phase169/verifier-single.bend'
    original_pin = pin(original)
    assert original_pin['sha256'] == '640e98df3324d9e1ea8d107d8d0d3388551ed3f7afe89aba7fbe039d01d41b0c'
    spec = importlib.util.spec_from_file_location('phase169_variants_v5', PREVIOUS)
    v5 = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v5)
    invocations = []
    control_before = ROOT / 'selfhost/tests/phase169/native-protocol-controls-v2.bend'
    control_after = control_before.with_name('native-protocol-controls-v3.bend')
    control_raw = control_before.read_bytes()
    changes = [
        (b'  +request = p169npc_request(', b'  +request : NR_Request = p169npc_request('),
        (b'  +error = "foreign provider unavailable', b'  +error : String = "foreign provider unavailable')]
    changed = control_raw
    for before, after in changes:
        assert changed.count(before) == 1
        changed = changed.replace(before, after, 1)
    assert changed == control_after.read_bytes()
    for before, after in reversed(changes):
        assert changed.count(after) == 1
        changed = changed.replace(after, before, 1)
    assert changed == control_raw

    def extract(command, *, cwd):
        assert not invocations and command.count(str(original)) == 1
        assert command.count(str(control_before)) == 1
        command[command.index(str(control_before))] = str(control_after)
        out = Path(command[command.index('--out') + 1]).resolve()
        adapted = out.with_name(out.name + '-inputs') / 'single-with-previous-hook.bend'
        before, after = b'def p169s_lowered(', b'def p169a_previous_lowered('
        raw = original.read_bytes()
        assert raw.count(before) == 1
        with adapted.open('xb') as stream:
            stream.write(raw.replace(before, after, 1))
        assert adapted.read_bytes().replace(after, before, 1) == raw
        command[command.index(str(original))] = str(adapted)
        for name in ['certified-emission', 'certified-emission-controls']:
            command += ['--module', str(ROOT / ('selfhost/tests/phase169/' + name + '.bend'))]
        command += ['--export', 'p169a_controls']
        invocations.append(dict(command=command, original=original_pin, adapted=pin(adapted), inverseExact=True))
        return subprocess.call(command, cwd=cwd)

    v5.subprocess = SimpleNamespace(call=extract)
    result = v5.main()
    if result == 0:
        command = invocations[0]['command']
        out = Path(command[command.index('--out') + 1]).resolve()
        derivation = out / 'certified-emission-derivation.json'
        derivation.write_text(json.dumps(dict(targetsRun=False, productionChanged=False,
            method=pin(Path(__file__)), previousMethod=previous, invocation=invocations[0],
            controlRepair=dict(original=pin(control_before), successor=pin(control_after),
                inverseExact=True, changes="Explicit NR_Request and String local types only")), indent=2) + '\n')
        manifest = out / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['inputs'] += [pin(Path(__file__)), pin(derivation), original_pin, pin(control_before)]
        manifest.write_text(json.dumps(data, indent=2) + '\n')
    assert pin(original) == original_pin and pin(PREVIOUS) == previous
    return result


if __name__ == '__main__':
    raise SystemExit(main())
