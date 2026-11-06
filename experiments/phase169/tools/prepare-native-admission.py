#!/usr/bin/env python3
"""Private successor of prepare-native.py with bounded admission-work changes."""
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MODULES = [
    'phase163/direct-first', 'phase163/direct-optimize',
    'phase164/hybrid-adapter', 'phase164/hybrid-lower',
    *['phase167/demand-' + part for part in
      ['model', 'lower', 'verify', 'emit', 'controls', 'live', 'plain', 'observers']],
    'phase168/early-scalars', 'phase168/early-scalars-selective',
    'phase168/selective-controls', 'phase168/adapter-view', 'phase168/adapter-imports',
    'phase169/streaming', 'phase169/native-entry',
    'phase169/admission-work', 'phase169/admission-controls',
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--api', action='store_true')
    args = parser.parse_args()
    # The shared extractor permits one explicit replacement of an additive
    # declaration. Preserve the prior selective policy under an unused name so
    # this successor replaces the original hook once; do not relax its guard.
    inputs = args.out.resolve().with_name(args.out.name + '-inputs')
    inputs.mkdir(parents=True, exist_ok=False)
    previous = ROOT / 'selfhost/tests/phase168/early-scalars-selective.bend'
    before = b'def p168_closed('
    after = b'def p169q_previous_closed('
    original = previous.read_bytes()
    assert original.count(before) == 1
    adapted = inputs / 'selective-with-previous-hook.bend'
    adapted.write_bytes(original.replace(before, after, 1))
    assert adapted.read_bytes().replace(after, before, 1) == original
    def pin(path):
        path = path.resolve(); data = path.read_bytes()
        return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    derivation = inputs / 'derivation.json'
    derivation.write_text(json.dumps(dict(original=pin(previous), adapted=pin(adapted),
        before=before.decode(), after=after.decode(), inverseExact=True,
        purpose='Keep prior private policy source; replace only one active p168_closed hook'), indent=2)+'\n')
    command = [sys.executable, '-B', 'experiments/phase163/tools/prepare.py']
    for module in MODULES:
        path = adapted if module == 'phase168/early-scalars-selective' else ROOT / ('selfhost/tests/' + module + '.bend')
        command += ['--module', str(path)]
    exports = ['p169s_plan', 'p169s_collect_plan', 'p169s_controls', 'p168j_plan',
               'p86_prepare', 'p88_cache_prepare', 'p86_plan',
               'p134e_plan', 'p134e_begin', 'p134e_next',
               'p168tc_controls', 'p167e_controls', 'p167ob_controls',
               'p128bs_controls', 'p128br_call_controls', 'p128bl_controls',
               'p169q_controls'] if args.api else ['main']
    for name in exports:
        command += ['--export', name]
    command += ['--allow-overrides', '--out', str(args.out)]
    result = subprocess.call(command, cwd=ROOT)
    if result == 0:
        manifest = args.out / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['inputs'] += [pin(Path(__file__)), pin(previous), pin(derivation)]
        manifest.write_text(json.dumps(data, indent=2)+'\n')
    return result


if __name__ == '__main__':
    raise SystemExit(main())
