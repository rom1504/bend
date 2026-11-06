#!/usr/bin/env python3
"""Reuse frozen v3 preparation; optionally add the native protocol module.

All v3 flags (--out, --api, --publication, --admission, --lazy, --single-verify)
are forwarded. This adapter extends only its metadata-extractor invocation;
no compiler target runs and no consumed method/source is edited.
"""
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
PREVIOUS = Path(__file__).with_name('prepare-native-variants-v3.py')
PREVIOUS_SHA = '54384f55f7ee9c9e657e853e8eae55a39d3c9e79f50f86168e8763540b04f9f0'
ENTRY_SHA = 'e4dd786c204834a7ca26e2160b9d86e26411c4a7dd0c36ff45c1c211a42981b4'


def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native-protocol', action='store_true',
                        help='Keep frontend errors and restore compile: runtime refusals at native entry')
    args, forwarded = parser.parse_known_args()
    previous = pin(PREVIOUS)
    entry = pin(ROOT / 'selfhost/tests/phase169/native-entry.bend')
    assert previous['sha256'] == PREVIOUS_SHA, 'Frozen v3 method changed'
    assert entry['sha256'] == ENTRY_SHA, 'Native entry changed; review the override again'
    spec = importlib.util.spec_from_file_location('phase169_variants_v3', PREVIOUS)
    old = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(old)
    invocations = []

    def extract(command, *, cwd):
        assert not invocations, 'Unexpected repeated extractor invocation'
        assert command[:3] == [sys.executable, '-B', 'experiments/phase163/tools/prepare.py']
        assert Path(cwd) == ROOT
        extended = list(command)
        if args.native_protocol:
            for name in ['native-protocol', 'native-protocol-controls']:
                extended += ['--module', str(ROOT / ('selfhost/tests/phase169/' + name + '.bend'))]
            if '--api' in forwarded:
                extended += ['--export', 'p169np_plan', '--export', 'p169np_controls']
        invocations.append(dict(original=command, extended=extended))
        return subprocess.call(extended, cwd=cwd)

    # This replaces only v3's subprocess binding, not the global subprocess
    # module. Its ordinary parser/module/authentication logic remains unchanged.
    old.subprocess = SimpleNamespace(call=extract)
    sys.argv = [str(PREVIOUS), *forwarded]
    result = old.main()
    if result == 0:
        command = invocations[0]['extended']
        out = Path(command[command.index('--out') + 1]).resolve()
        derivation = out / 'native-protocol-derivation.json'
        derivation.write_text(json.dumps(dict(targetsRun=False,
            nativeProtocol=args.native_protocol, method=pin(Path(__file__)),
            previousMethod=previous, originalEntry=entry, invocation=invocations[0]), indent=2) + '\n')
        manifest = out / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['inputs'] += [pin(Path(__file__)), pin(derivation)]
        manifest.write_text(json.dumps(data, indent=2) + '\n')
    assert pin(PREVIOUS) == previous and pin(Path(entry['file'])) == entry, 'Frozen inputs changed'
    return result


if __name__ == '__main__':
    raise SystemExit(main())
