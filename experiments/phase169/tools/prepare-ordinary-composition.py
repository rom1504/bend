#!/usr/bin/env python3
"""Source-only optional ordinary composition on the frozen certified renderer."""
import argparse
import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PREVIOUS = Path(__file__).with_name('prepare-certified-emission-v2.py')


def pin(path):
    path = path.resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ordinary-composition', action='store_true')
    args, forwarded = parser.parse_known_args()
    assert '--api' in forwarded and '--admission' in forwarded
    previous = pin(PREVIOUS)
    assert previous['sha256'] == '36fcce54e723e3c94e8a4f5f99a32ad5a5b41e9486df6fd1b46d37faba645b01'
    original = ROOT / 'selfhost/tests/phase169/admission-work.bend'
    original_pin = pin(original)
    assert original_pin['sha256'] == '3952e24256f0e70aab26785887c3b51a6f1556825e16270c139cb1a61b68c8fe'
    spec = importlib.util.spec_from_file_location('phase169_certified_v2', PREVIOUS)
    previous_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(previous_module)
    invocations = []

    def extract(command, *, cwd):
        assert not invocations
        record = dict(enabled=args.ordinary_composition)
        if args.ordinary_composition:
            assert command.count(str(original)) == 1
            out = Path(command[command.index('--out') + 1]).resolve()
            adapted = out.with_name(out.name + '-inputs') / 'admission-with-previous-hook.bend'
            before, after = b'def p168_closed(', b'def p169o_previous_closed('
            raw = original.read_bytes()
            assert raw.count(before) == 1
            with adapted.open('xb') as stream:
                stream.write(raw.replace(before, after, 1))
            assert adapted.read_bytes().replace(after, before, 1) == raw
            command[command.index(str(original))] = str(adapted)
            for name in ['ordinary-composition', 'ordinary-composition-controls']:
                command += ['--module', str(ROOT / ('selfhost/tests/phase169/' + name + '.bend'))]
            command += ['--export', 'p169o_controls']
            record.update(original=original_pin, adapted=pin(adapted), inverseExact=True)
        record['command'] = command
        invocations.append(record)
        return subprocess.call(command, cwd=cwd)

    previous_module.subprocess = SimpleNamespace(call=extract)
    sys.argv = [str(PREVIOUS), *forwarded]
    result = previous_module.main()
    if result == 0:
        command = invocations[0]['command']
        out = Path(command[command.index('--out') + 1]).resolve()
        derivation = out / 'ordinary-composition-derivation.json'
        derivation.write_text(json.dumps(dict(targetsRun=False, productionChanged=False,
            method=pin(Path(__file__)), previousMethod=previous,
            invocation=invocations[0]), indent=2) + '\n')
        manifest = out / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['inputs'] += [pin(Path(__file__)), pin(derivation), original_pin]
        manifest.write_text(json.dumps(data, indent=2) + '\n')
    assert pin(PREVIOUS) == previous and pin(original) == original_pin
    return result


if __name__ == '__main__':
    raise SystemExit(main())
