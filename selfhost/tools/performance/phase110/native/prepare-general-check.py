#!/usr/bin/env python3
"""Prepare a general-entry TYPECHECK fixture with exact interfaces and semantic mocks.

Never run the fixture's main or count it as frontend/worker execution evidence.
"""
import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p109_native_typecheck', HERE.parent.parent / 'phase109/native/prepare-check.py')
OLD = importlib.util.module_from_spec(spec)
spec.loader.exec_module(OLD)
pin = OLD.pin


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    prepared, out = args.source.resolve(), args.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase110') or out.exists():
        raise ValueError('fresh Phase110 output required')
    manifest_path = prepared / 'manifest.json'
    manifest = json.loads(manifest_path.read_text())
    if not manifest['complete'] or manifest['kind'] != 'phase110-native-selected-library-source':
        raise ValueError('incomplete native source preparation')
    for row in manifest['inputs']:
        if pin(row['file']) != row:
            raise ValueError('prepared input changed ' + row['file'])
    seed = Path(manifest['selectedSource']['file'])
    if pin(seed) != manifest['selectedSource']:
        raise ValueError('selected seed changed')
    bridge, config = prepared / 'bridge/source.bend', prepared / 'config.bend'
    if pin(bridge) != manifest['bridge'] or pin(config) != manifest['config']:
        raise ValueError('prepared bridge or config changed')
    source = bridge.read_text()
    available = set(re.findall(r'^type ([A-Za-z0-9_.]+)\b', source, re.M))
    declarations = OLD.blocks(seed.read_text())
    types = {name: body for (kind, name), body in declarations.items() if kind == 'type'}
    chosen, todo = set(), ['P86Seed', 'P86Preparation', 'P86Plan', 'NR_Request']
    while todo:
        name = todo.pop()
        if name in chosen or name in available:
            continue
        chosen.add(name)
        todo += [word for word in re.findall(r'\b[A-Za-z_][A-Za-z0-9_.]*\b', types[name]) if word in types and word not in chosen and word not in available]
    type_source = '\n'.join(body for name, body in types.items() if name in chosen)
    mock_bodies = {
        'p86_plan': 'P86PlanError{"TYPECHECK MOCK: no source planning"}',
        'p86_prepare': 'P86PreparationError{"TYPECHECK MOCK: no Base preparation"}',
        'p88_cache_prepare': 'P86PreparationError{"TYPECHECK MOCK: no cache preparation"}',
        'p86_read_file': 'IO.pure(String, "TYPECHECK MOCK: no file read")',
        'ns_body': 'KDef{"mock", "NativeErasedBody", 2, 1, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}'}
    mocks = []
    for name, body in mock_bodies.items():
        signature = declarations['def', name].split(':\n', 1)[0] + ':'
        mocks.append(signature + '\n  ' + body + '\n')
    entry = Path(manifest['entry']['file'])
    if pin(entry) != manifest['entry']:
        raise ValueError('general entry changed')
    final = source + '\n\n# TYPECHECK ONLY: exact interfaces, mocked semantic bodies.\n' + type_source + '\n' + '\n'.join(mocks) + '\n' + entry.read_text() + '\n' + config.read_text()
    if len(re.findall(r'^def main\(', final, re.M)) != 1:
        raise ValueError('expected exactly one main')
    out.mkdir(parents=True)
    (out / 'source.bend').write_text(final)
    (out / 'interface-types.bend').write_text(type_source)
    (out / 'semantic-mocks.bend').write_text('\n'.join(mocks))
    command = [str(ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun'), str(ROOT / 'selfhost/tools/stage0-library.mjs'),
               str(out / 'source.bend'), str(out / 'api.mjs'), 'p110_native_policy_valid', 'nxc_lower_library']
    report = {'kind': 'phase110-native-entry-typecheck-fixture', 'complete': True, 'targetsRun': False,
              'source': pin(out / 'source.bend'), 'types': sorted(chosen), 'mockedFunctions': list(mock_bodies),
              'entryExact': True, 'configExact': True, 'checkCommand': command,
              'inputs': [pin(__file__), pin(HERE.parent.parent / 'phase109/native/prepare-check.py'), pin(manifest_path), pin(seed), pin(bridge), pin(entry), pin(config)],
              'limits': ['TYPECHECK ONLY. Mocked planning/preparation/file-read/fact-lookup bodies provide no frontend execution evidence.',
                         'Never execute the fixture main; the full native source still requires actual checking, acquisition and semantic qualification.']}
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'complete': True, 'targetsRun': False, 'source': report['source'], 'checkCommand': command}))


if __name__ == '__main__':
    main()
