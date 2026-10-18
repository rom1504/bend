#!/usr/bin/env python3
"""Prepare a small native-entry TYPECHECK fixture with explicit semantic mocks.
Never execute this fixture's main or interpret it as frontend correctness evidence.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SEED_SHA256 = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return {'file': str(path), 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def blocks(source):
    starts = list(re.finditer(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', source, re.M))
    return {(m.group(1), m.group(2)): source[m.start():starts[i + 1].start() if i + 1 < len(starts) else len(source)].split('\n# Module:', 1)[0].strip() + '\n' for i, m in enumerate(starts)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--bridge', type=Path, default=ROOT / 'selfhost/build/phase109/bridge09')
    parser.add_argument('--config', type=Path, default=ROOT / 'selfhost/build/phase109/native-source01/config.bend')
    args = parser.parse_args()
    out = args.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase109') or out.exists():
        raise ValueError('fresh phase109 output required')
    seed = ROOT / 'selfhost/build/phase102/projection-cost-source01/compiler.bend'
    if pin(seed)['sha256'] != SEED_SHA256:
        raise ValueError('selected seed changed')
    bridge = args.bridge.resolve() / 'source.bend'
    bridge_manifest = args.bridge.resolve() / 'manifest.json'
    expected = json.loads(bridge_manifest.read_text())['source']
    if pin(bridge) != expected:
        raise ValueError('bridge source identity differs')
    source = bridge.read_text()
    available = set(re.findall(r'^type ([A-Za-z0-9_.]+)\b', source, re.M))
    declarations = blocks(seed.read_text())
    types = {name: body for (kind, name), body in declarations.items() if kind == 'type'}
    chosen = set()
    todo = ['P86Seed', 'P86Preparation', 'P86Plan', 'NR_Request']
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
        'ns_body': 'KDef{"mock", "NativeErasedBody", 2, 1, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}',
        'sk_quote': 's'}
    mocks = []
    for name, body in mock_bodies.items():
        declaration = declarations['def', name]
        signature = declaration.split(':\n', 1)[0] + ':'
        mocks.append(signature + '\n  ' + body + '\n')
    entry = HERE / 'main.bend'
    config = args.config.resolve()
    final = source + '\n\n# TYPECHECK ONLY: exact interface types and signatures; mocked semantic bodies.\n' + type_source + '\n' + '\n'.join(mocks) + '\n' + entry.read_text() + '\n' + config.read_text()
    if len(re.findall(r'^def main\(', final, re.M)) != 1:
        raise ValueError('expected exactly one main')
    out.mkdir(parents=True)
    (out / 'source.bend').write_text(final)
    (out / 'interface-types.bend').write_text(type_source)
    (out / 'semantic-mocks.bend').write_text('\n'.join(mocks))
    record = {'kind': 'phase109-native-entry-typecheck-fixture', 'complete': True, 'targetsRun': False,
              'source': pin(out / 'source.bend'), 'types': sorted(chosen), 'mockedFunctions': list(mock_bodies),
              'entryExact': True, 'configExact': True,
              'inputs': [pin(__file__), pin(seed), pin(bridge_manifest), pin(bridge), pin(entry), pin(config)],
              'limits': ['TYPECHECK ONLY. Mocked planning, preparation, file reading and fact lookup do not implement frontend semantics.',
                         'Run only compiler checking/acquisition; do not run fixture main or claim actual native frontend validation.',
                         'The full native compiler source still requires its actual check and acquisition gate.']}
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({'complete': True, 'targetsRun': False, 'source': record['source'], 'types': len(chosen)}))


if __name__ == '__main__':
    main()
