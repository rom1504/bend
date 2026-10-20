#!/usr/bin/env python3
"""Exact approved composition26/27, checked API and guarded-array runtime admission."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
INVENTORY_SHA = '609e060beac90592ac8f992f5269e65b5898459f1d0d2844b28d247e5239eea1'
PROFILES = {
    'width26': (26, 'd1b6efed39957538cd2bc5b6eab5a20b4ac9f53b2aa85a98ec9dba2787710835'),
    'wide27': (27, '96e46cf3d259cf0440f23e4506bbde1e461387fcc8741f9269f9ae6ac091a0b8'),
}
COMPOSITION_SHA = '8cccfc89eec1a0b5a651811a09d42d21ce0df3a07195957ecf8dd3310c7bb501'


def pin(file):
    file = Path(file).resolve()
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--variant', choices=sorted(PROFILES), required=True)
    ap.add_argument('--compiler', type=Path, required=True)
    ap.add_argument('--runtime-source', type=Path, required=True)
    ap.add_argument('--runtime-object', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    root = HERE.parents[4]
    if args.out.exists() or not args.out.resolve().is_relative_to(root / 'selfhost/build/phase113'):
        raise ValueError('fresh Phase113 output required')
    version, profile_sha = PROFILES[args.variant]
    profile_file = HERE / ('composition' + str(version) + '.json')
    composition_file = HERE / 'composition.py'
    if pin(profile_file)['sha256'] != profile_sha or pin(composition_file)['sha256'] != COMPOSITION_SHA:
        raise ValueError('frozen composition profile or replay method changed')
    profile = json.loads(profile_file.read_text())
    composition_spec = importlib.util.spec_from_file_location('array_exact_composition', composition_file)
    composition = importlib.util.module_from_spec(composition_spec)
    composition_spec.loader.exec_module(composition)
    composition.authenticate(profile['recipe'])
    composed = composition.validate(profile, args.compiler)
    approved = profile
    for key in ['checkedApi', 'review', 'branchInventory', 'widthInventory', 'heapTransportCorrection']:
        composition.authenticate(approved[key])
    checked = json.loads(Path(approved['checkedApi']['file']).read_text())
    if not checked.get('complete') or not checked.get('checked') or checked.get('status') != 0:
        raise ValueError('completed successful checked API required')
    if composed['source'] not in checked['inputs']:
        raise ValueError('checked API does not bind selected compiler')
    composition.authenticate(checked['api'])
    for name in ['p113a_lower_request', 'p113a_verify', 'p113a_admitted_chunks',
                 'p113ah_control_text', 'p113_width_control_report', 'p113_width_case_qbe']:
        if name not in checked['exports']:
            raise ValueError('missing checked API export: ' + name)
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
    heap_file = HERE / 'heap-modules01.json'
    if pin(heap_file)['sha256'] != '41af82fa6aac271beaed2730b34c0d56525ad8012162850f9b1865cd2b00a0f7':
        raise ValueError('frozen heap inventory changed')
    heap = json.loads(heap_file.read_text())
    for row in heap['modules'] + [heap['controls']]:
        if pin(row['file']) != row:
            raise ValueError('heap dependency changed: ' + row['file'])
    for row in heap['modules']:
        expected.update(base.declarations(Path(row['file']).read_text()))
    inputs.extend(heap['modules'] + [pin(heap_file)])
    for row in approved['overlayModules']:
        composition.authenticate(row)
        expected.update(base.declarations(Path(row['file']).read_text()))
    for name, declaration in approved['pipelineDeclarations'].items():
        expected['def', name] = declaration
    inputs.extend(approved['overlayModules'])
    errors = base.mismatches(actual, expected)
    errors += [name for kind, name in actual if name.startswith(('p113ai_', 'p113ah_', 'p113l_', 'p113w_', 'p113wt_', 'p113_width_')) and (kind, name) not in expected]
    if errors:
        raise ValueError('conjunctive array identity mismatch: ' + repr(errors))
    mutants = []
    for name in ['p113ai_snapshot', 'p113ai_set_done', 'p113ai_intrinsic',
                 'p113p_pair_code', 'p113p_primitive', 'p111_intrinsic',
                 'p113a_template', 'p113a_verify', 'p111_emit_admitted',
                 'p113ah_loop', 'p113ah_private', 'p113ah_function',
                 'p113a_address', 'p113a_registered',
                 'p113k_put', 'p113l_relation', 'p113l_assume', 'p113k_join_fact',
                 'p113w_pair', 'p113w_word', 'p113w_room', 'p113e_stmts',
                 'p113d_lower_request', 'p113k_lowered', 'p113i_lowered',
                 'p113i_function_done', 'p113i_eligible', 'p113i_function',
                 'p113i_optimize', 'p113k_optimize'] :
        changed = dict(actual)
        changed['def', name] += '\n  False{}'
        if not base.mismatches(changed, expected):
            raise AssertionError('mutation accepted: ' + name)
        mutants.append(dict(name=name, rejected=True))
    args.out.mkdir(parents=True)
    report = dict(kind='phase113-array-final-composition-admission', version=version, variant=args.variant, complete=True,
                  admitted=True, targetsExecuted=False, compiler=compiler, runtimeSource=runtime,
                  runtimeObject=obj, method=pin(__file__), inventory=pin(inventory_file),
                  inputs=inputs + inventory['modules'] + [inventory['baseAdmission'], inventory['baseInventory']],
                  exactDeclarations=len(expected), bufferProfile=profile, mutations=mutants,
                  compositionProfile=pin(profile_file), compositionMethod=pin(composition_file),
                  checkedApiReceipt=approved['checkedApi'], checkedApi=checked['api'],
                  review=approved['review'], branchInventory=approved['branchInventory'],
                  widthInventory=approved['widthInventory'], heapTransportCorrection=approved['heapTransportCorrection'],
                  policy=approved['policy'],
                  compositionManifest=pin(Path(args.compiler).parent / 'manifest.json'),
                  compositionModules=composed['moduleSnapshots'],
                  compositionReplay=dict(exact=True, modules=len(composed['modules']), edits=len(composed['edits'])),
                  contract='Original guards/fallbacks/payload loads retained; identity transfer before inlining; stable heap base loaded once before private self-loop. Exact single-context sequential CPU runtime binding.',
                  limitations=['Data-only exact source binding; checked API and native complete-output qualification remain separate.',
                               'No ownership credit added: snapshot aliases are transport words and only the original result credit escapes.',
                               'No raw/dynamic/scalar guard was removed.',
                               'Only the two hardcoded approved source profiles are accepted; no arbitrary module profile.',
                               'Branch/width finite native checks and complete workload observations remain separate.'])
    (args.out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, compiler=compiler['sha256'], declarations=len(expected))))


if __name__ == '__main__':
    main()
