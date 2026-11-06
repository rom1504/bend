#!/usr/bin/env python3
"""Source-only optional single-final-verifier successor; v2 remains frozen."""
import argparse
import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
BASE = Path(__file__).with_name('prepare-native.py')
spec = importlib.util.spec_from_file_location('phase169_base_prepare', BASE)
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)


def pin(path):
    path = path.resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def definition(path, name):
    text = path.read_text()
    start = text.index('def ' + name + '(')
    end = text.find('\n@unsafe\n', start)
    assert end != -1
    return text[start:end].strip()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--api', action='store_true')
    ap.add_argument('--publication', action='store_true')
    ap.add_argument('--admission', action='store_true', help='Metadata guards and exact eligibility reuse')
    ap.add_argument('--lazy', action='store_true', help='Independent lazy eligibility predicate')
    ap.add_argument('--single-verify', action='store_true', help='Verify the exact public view once after original/private admission')
    args = ap.parse_args()
    inputs = args.out.resolve().with_name(args.out.name + '-inputs')
    inputs.mkdir(parents=True, exist_ok=False)
    modules = [ROOT / ('selfhost/tests/' + x + '.bend') for x in base.MODULES]
    derivation = dict(targetsRun=False, parentMethod=pin(BASE), previousVariantsMethod=pin(Path(__file__).with_name("prepare-native-variants-v2.py")), flags=dict(
        api=args.api, publication=args.publication, admission=args.admission, lazy=args.lazy, singleVerify=args.single_verify))
    extra_inputs = [pin(BASE), pin(Path(__file__)), pin(Path(__file__).with_name("prepare-native-variants-v2.py")),
                    pin(ROOT / "selfhost/tests/phase169/admission-controls.bend")]
    if args.admission:
        previous = ROOT / 'selfhost/tests/phase168/early-scalars-selective.bend'
        before, after = b'def p168_closed(', b'def p169q_previous_closed('
        original = previous.read_bytes()
        assert original.count(before) == 1
        adapted = inputs / 'selective-with-previous-hook.bend'
        adapted.write_bytes(original.replace(before, after, 1))
        assert adapted.read_bytes().replace(after, before, 1) == original
        modules[modules.index(previous)] = adapted
        derivation['selectiveHook'] = dict(original=pin(previous), adapted=pin(adapted),
            before=before.decode(), after=after.decode(), inverseExact=True)
        extra_inputs.append(pin(previous))
        modules += [ROOT / 'selfhost/tests/phase169/admission-work.bend',
                    ROOT / 'selfhost/tests/phase169/admission-controls-v2.bend']
    if args.lazy:
        original = ROOT / 'selfhost/src/back/qbe/borrowed-regions.bend'
        reference = ROOT / 'selfhost/tests/phase169/lazy-eligibility-controls.bend'
        old = definition(original, 'p128bs_eligible')
        renamed = definition(reference, 'p169e_reference').replace('def p169e_reference(', 'def p128bs_eligible(', 1)
        assert old == renamed, 'Finite reference no longer matches exact maintained predicate'
        derivation['eligibilityReference'] = dict(original=pin(original), reference=pin(reference),
            exactRenamedBody=True, comparedBodySha256=hashlib.sha256(old.encode()).hexdigest())
        extra_inputs.append(pin(original))
        modules += [ROOT / 'selfhost/tests/phase169/lazy-eligibility.bend', reference]
    if args.publication:
        modules += [ROOT / 'selfhost/tests/phase169/publication.bend']
    if args.single_verify:
        modules += [ROOT / 'selfhost/tests/phase169/verifier-single.bend',
                    ROOT / 'selfhost/tests/phase169/verifier-single-controls.bend']
    derivation_path = inputs / 'derivation.json'
    derivation_path.write_text(json.dumps(derivation, indent=2) + '\n')
    extra_inputs.append(pin(derivation_path))
    exports = ['p169s_plan', 'p169s_collect_plan', 'p169s_controls', 'p168j_plan',
               'p86_prepare', 'p88_cache_prepare', 'p86_plan',
               'p134e_plan', 'p134e_begin', 'p134e_next',
               'p168tc_controls', 'p167e_controls', 'p167ob_controls',
               'p128bs_controls', 'p128br_call_controls', 'p128bl_controls'] if args.api else ['main']
    if args.api and args.admission:
        exports.append('p169q_controls')
    if args.api and args.lazy:
        exports.append('p169e_controls')
    if args.api and args.single_verify:
        exports.append('p169sv_controls')
    command = [sys.executable, '-B', 'experiments/phase163/tools/prepare.py']
    for path in modules:
        command += ['--module', str(path)]
    for name in exports:
        command += ['--export', name]
    command += ['--allow-overrides', '--out', str(args.out)]
    result = subprocess.call(command, cwd=ROOT)
    if result == 0:
        manifest = args.out / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['inputs'] += extra_inputs
        manifest.write_text(json.dumps(data, indent=2) + '\n')
    return result


if __name__ == '__main__':
    raise SystemExit(main())
