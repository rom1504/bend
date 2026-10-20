#!/usr/bin/env python3
"""Offline exact composition21 + guarded array + identity source/runtime admission."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
INVENTORY_SHA = '609e060beac90592ac8f992f5269e65b5898459f1d0d2844b28d247e5239eea1'
PROFILE_SHA = 'e9934d3421e0edf439df7ebaec07d1ead73b383dabc7a461087eb152e28fbe59'
COMPOSITION_SHA = '8cccfc89eec1a0b5a651811a09d42d21ce0df3a07195957ecf8dd3310c7bb501'


def pin(file):
    file = Path(file).resolve()
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', type=Path, required=True)
    ap.add_argument('--runtime-source', type=Path, required=True)
    ap.add_argument('--runtime-object', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    root = HERE.parents[4]
    if args.out.exists() or not args.out.resolve().is_relative_to(root / 'selfhost/build/phase113'):
        raise ValueError('fresh Phase113 output required')
    profile_file = HERE / 'composition21.json'
    composition_file = HERE / 'composition.py'
    if pin(profile_file)['sha256'] != PROFILE_SHA or pin(composition_file)['sha256'] != COMPOSITION_SHA:
        raise ValueError('frozen composition profile or replay method changed')
    profile = json.loads(profile_file.read_text())
    composition_spec = importlib.util.spec_from_file_location('array_exact_composition', composition_file)
    composition = importlib.util.module_from_spec(composition_spec)
    composition_spec.loader.exec_module(composition)
    composition.authenticate(profile['recipe'])
    composed = composition.validate(profile, args.compiler)
    inventory_file = HERE / 'identity-modules01.json'
    if pin(inventory_file)['sha256'] != INVENTORY_SHA:
        raise ValueError('identity source inventory changed')
    inventory = json.loads(inventory_file.read_text())
    for row in inventory['modules'] + [inventory['controls'], inventory['baseAdmission'], inventory['baseInventory']]:
        if pin(row['file']) != row:
            raise ValueError('identity dependency changed: ' + row['file'])
    spec = importlib.util.spec_from_file_location('array_base_admission', inventory['baseAdmission']['file'])
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    frozen = json.loads(Path(inventory['baseInventory']['file']).read_text())
    for row in frozen['modules'] + frozen['dependencies'] + [frozen['controls']]:
        if pin(row['file']) != row:
            raise ValueError('base dependency changed: ' + row['file'])
    runtime, obj, compiler = map(pin, [args.runtime_source, args.runtime_object, args.compiler])
    if runtime['sha256'] != base.RUNTIME_SHA or obj['sha256'] != base.OBJECT_SHA:
        raise ValueError('exact product runtime source/object required')
    actual = base.declarations(args.compiler.read_text())
    expected, inputs = base.expected_declarations()
    profile = base.buffer_profile(actual, expected, inputs)
    for row in inventory['modules']:
        expected.update(base.declarations(Path(row['file']).read_text()))
    expected['def', 'p111_intrinsic'] = inventory['intrinsicDeclaration']
    errors = base.mismatches(actual, expected)
    errors += [name for kind, name in actual if name.startswith('p113ai_') and (kind, name) not in expected]
    if errors:
        raise ValueError('conjunctive array identity mismatch: ' + repr(errors))
    mutants = []
    for name in ['p113ai_snapshot', 'p113ai_set_done', 'p113ai_intrinsic',
                 'p113p_pair_code', 'p113p_primitive', 'p111_intrinsic',
                 'p113a_template', 'p113a_verify', 'p111_emit_admitted']:
        changed = dict(actual)
        changed['def', name] += '\n  False{}'
        if not base.mismatches(changed, expected):
            raise AssertionError('mutation accepted: ' + name)
        mutants.append(dict(name=name, rejected=True))
    args.out.mkdir(parents=True)
    report = dict(kind='phase113-array-identity-composition21-admission', complete=True,
                  admitted=True, targetsExecuted=False, compiler=compiler, runtimeSource=runtime,
                  runtimeObject=obj, method=pin(__file__), inventory=pin(inventory_file),
                  inputs=inputs + inventory['modules'] + [inventory['baseAdmission'], inventory['baseInventory']],
                  exactDeclarations=len(expected), bufferProfile=profile, mutations=mutants,
                  compositionProfile=pin(profile_file), compositionMethod=pin(composition_file),
                  compositionManifest=pin(Path(args.compiler).parent / 'manifest.json'),
                  compositionModules=composed['moduleSnapshots'],
                  compositionReplay=dict(exact=True, modules=len(composed['modules']), edits=len(composed['edits'])),
                  contract='Original guarded array profile unchanged; all pair calls/effects and second results retained; first result and set return equal pre-call input word.',
                  limitations=['Data-only exact source binding; checked API and native complete-output qualification remain separate.',
                               'No ownership credit added: snapshot aliases are transport words and only the original result credit escapes.',
                               'No raw/dynamic/scalar guard was removed.'])
    (args.out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, compiler=compiler['sha256'], declarations=len(expected))))


if __name__ == '__main__':
    main()
