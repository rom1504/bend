#!/usr/bin/env python3
"""Stage exact Phase175 source integration; --apply explicitly updates three files.

Source transport only. No Bend/compiler execution, backend policy change, or
qualification claim. Default writes a fresh proposal/receipt and no maintained
files. The frozen candidate is an integration input, never a future build input.
"""
import argparse
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
SOURCE_ROOT = ROOT / 'selfhost'
RECIPE = SOURCE_ROOT / 'src/compiler.json'
CANDIDATE = SOURCE_ROOT / 'build/phase175/full-source01/compiler.bend'
PARENT = (3161409, '74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a')
SELECTED = (3163584, 'a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04')
REPLACEMENTS = {'f_grow_base', 'f_grow_existing', 'dr_own_names'}
PARSER_HELPERS = {
    'p175p_grow_word', 'p175p_grow_operator', 'p175p_grow_sign',
    'p175p_grow_shift', 'p175p_shift_end', 'p175p_grow_newline',
    'p175p_grow_suffix', 'p175p_grow_bang',
}
REPORT_HELPERS = {'p175rn_name', 'p175rn_walk'}
OWNERS = {'src/front/parser.bend', 'src/driver/report.bend'}


def identity(data):
    return (len(data), hashlib.sha256(data).hexdigest())


def record(data):
    size, sha = identity(data)
    return {'bytes': size, 'sha256': sha}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True, help='Fresh proposal directory')
    parser.add_argument('--apply', action='store_true',
                        help='After all checks, explicitly update the two modules and recipe')
    args = parser.parse_args()
    out = args.out.resolve()
    require(out.is_relative_to(ROOT) or out.is_relative_to(Path('/tmp')),
            'Proposal must stay in workspace or /tmp')
    require(not out.exists(), 'Fresh proposal directory required')
    spec = importlib.util.spec_from_file_location('phase175_source',
                                                 SOURCE_ROOT / 'tools/build/source.py')
    assembly = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(assembly)

    recipe_bytes = RECIPE.read_bytes()
    config = json.loads(recipe_bytes)
    require(len(config['protectedDeclarations']) == 112, 'Expected 112 protections')
    require(not REPLACEMENTS.intersection(config['protectedDeclarations']),
            'Protected replacement refused')
    baseline = assembly.maintained_assemble(RECIPE, SOURCE_ROOT, 'qbe')
    target = CANDIDATE.read_bytes()
    require(identity(baseline) == PARENT, 'Maintained parent changed')
    require(identity(target) == SELECTED, 'Selected source identity changed')
    preamble, before = assembly.blocks(baseline)
    selected_preamble, after = assembly.blocks(target)
    require(preamble == selected_preamble, 'Preamble changed')
    old = {(r['kind'], r['name']): r for r in before}
    new = {(r['kind'], r['name']): r for r in after}
    require(len(new) == len(after) and len(old) == len(before), 'Duplicate declaration')
    require(set(old) <= set(new), 'Original declaration lost')
    changes = {key for key in old if old[key]['data'] != new[key]['data']}
    require(changes == {('def', n) for n in REPLACEMENTS}, 'Unexpected changed declaration')
    additions = set(new) - set(old)
    expected = ({('def', n) for n in PARSER_HELPERS | REPORT_HELPERS}
                | {('law', n) for n in PARSER_HELPERS | {'p175rn_walk'}})
    require(additions == expected, 'Unexpected helper/law additions')
    require([key for key in new if key in old] == list(old), 'Original global order changed')

    owners, local, inputs = {}, {}, {RECIPE: recipe_bytes}
    for index, module in enumerate(config['modules']):
        path = SOURCE_ROOT / module
        inputs[path] = path.read_bytes()
        if module == config['preamble']:
            continue
        prefix, rows = assembly.blocks(inputs[path])
        require(not prefix, 'Unassigned source bytes')
        local[index] = rows
        for row in rows:
            owners[row['kind'], row['name']] = index
    preamble_path = SOURCE_ROOT / config['preamble']
    inputs[preamble_path] = preamble_path.read_bytes()
    for profile in config['profiles'].values():
        if profile.get('entryModule'):
            path = SOURCE_ROOT / profile['entryModule']
            inputs[path] = path.read_bytes()
    for key in additions:
        owner = 'src/front/parser.bend' if key[1] in PARSER_HELPERS else 'src/driver/report.bend'
        owners[key] = config['modules'].index(owner)

    # Keep each module's existing local order. Only the global recipe controls
    # forward-law placement and the appended helper implementation schedule.
    module_updates = {}
    for index, rows in local.items():
        data = b''.join(new[r['kind'], r['name']]['data'] for r in rows)
        data += b''.join(r['data'] for r in after
                         if (r['kind'], r['name']) in additions
                         and owners[r['kind'], r['name']] == index)
        path = SOURCE_ROOT / config['modules'][index]
        if data != inputs[path]:
            module_updates[path] = data
    require({str(p.relative_to(SOURCE_ROOT)) for p in module_updates} == OWNERS,
            'Integration would touch an unexpected maintained module')
    proposed = copy.deepcopy(config)
    proposed['order'] = [[owners[r['kind'], r['name']], r['kind'], r['name']] for r in after]
    proposed['inventoryChange'] = {
        'phase': 175, 'kind': 'measured-parser-lookahead-and-report-membership',
        'added': [[kind, name] for kind, name in sorted(additions)],
        'removed': [], 'replaced': sorted(REPLACEMENTS),
        'source': record(target),
        'scope': 'Exact measured source transport; target/image qualification is separate.',
    }
    require(proposed['profiles'] == config['profiles'], 'Profile mutation refused')
    require(proposed['protectedDeclarations'] == config['protectedDeclarations'],
            'Protection metadata mutation refused')
    updates = {**module_updates, RECIPE: encode(proposed)}

    # Exercise the REAL maintained assembler with in-memory proposed bytes.
    # This catches declaration boundary/comment ownership errors as well as all
    # 112 protections, duplicate names, inventory, and split law/def ownership.
    old_read = assembly.read
    profile_results = {}
    try:
        assembly.read = lambda p: updates.get(Path(p).resolve(), old_read(p))
        for name, profile in config['profiles'].items():
            actual = assembly.maintained_assemble(RECIPE, SOURCE_ROOT, name)
            expected_parts = [preamble]
            for row in after:
                if (row['kind'], row['name']) == ('def', 'main'):
                    if profile.get('omitMain'):
                        continue
                    if profile.get('entryModule'):
                        expected_parts.append(inputs[SOURCE_ROOT / profile['entryModule']])
                        continue
                expected_parts.append(row['data'])
            require(actual == b''.join(expected_parts), 'Profile assembly differs: ' + name)
            profile_results[name] = record(actual)
        require(profile_results['qbe'] == record(target), 'QBE source not byte identical')
    finally:
        assembly.read = old_read
    for path, data in inputs.items():
        require(path.read_bytes() == data, 'Input changed during preparation: ' + str(path))
    require(CANDIDATE.read_bytes() == target, 'Candidate changed during preparation')

    out.mkdir(parents=True)
    writes = []
    for path, data in updates.items():
        relative = path.relative_to(SOURCE_ROOT)
        staged = out / 'files' / relative
        staged.parent.mkdir(parents=True, exist_ok=True)
        staged.write_bytes(data)
        writes.append({'file': str(path), 'proposal': str(staged),
                       'before': record(inputs[path]), 'after': record(data)})
    if args.apply:
        # Opt-in only. Recheck all maintained inputs immediately before writes;
        # preserve an already present file's permissions during atomic replace.
        for path, data in inputs.items():
            require(path.read_bytes() == data, 'Input changed before application: ' + str(path))
        for path, data in updates.items():
            mode = path.stat().st_mode & 0o777
            with tempfile.NamedTemporaryFile(dir=path.parent, prefix='.phase175-', delete=False) as handle:
                temporary = Path(handle.name)
                handle.write(data)
            os.chmod(temporary, mode)
            os.replace(temporary, path)
        require(assembly.maintained_assemble(RECIPE, SOURCE_ROOT, 'qbe') == target,
                'Applied assembly differs')
    receipt = {'kind': 'phase175-selected-integration', 'version': 1, 'complete': True,
               'targetsRun': False, 'applied': args.apply, 'method': record(Path(__file__).read_bytes()),
               'parent': record(baseline), 'selected': record(target), 'writes': writes,
               'protectedDeclarations': 112, 'replacements': 3,
               'helperDefinitions': 10, 'forwardLaws': 9,
               'originalOrderPreserved': True, 'allProfilesExact': profile_results,
               'sourceCounts': {'before': len(before), 'after': len(after)},
               'scope': 'Assembly equality only; no compiler execution or qualification.'}
    (out / 'report.json').write_bytes(encode(receipt))
    print(json.dumps({'complete': True, 'applied': args.apply,
                      'qbe': profile_results['qbe'], 'files': len(writes),
                      'report': str(out / 'report.json')}))


if __name__ == '__main__':
    main()
