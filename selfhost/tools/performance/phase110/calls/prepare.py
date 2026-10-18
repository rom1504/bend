#!/usr/bin/env python3
"""Compose an additive call profile from exact audited declaration replacements.

No compiler/target execution. The input is a frozen Phase110 assembled source;
unknown originals, missing or duplicate declarations are refused.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def blocks(text):
    starts = list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_]+)\b', text, re.M))
    result = {}
    for index, match in enumerate(starts):
        name = match.group(1)
        if name in result:
            raise ValueError('duplicate declaration ' + name)
        end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
        result[name] = text[match.start():end].strip()
    return result


def prepare(source_path, out):
    source_path, out = source_path.resolve(), out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase110') or out.exists():
        raise ValueError('fresh output under selfhost/build/phase110 required')
    source = source_path.read_text()
    old = blocks(source)
    manifest_path = HERE / 'overrides.json'
    spec = json.loads(manifest_path.read_text())
    replacements_path = HERE / 'overrides.bend'
    replacements = blocks(replacements_path.read_text())
    edits = []
    for item in spec['declarations']:
        name = item['name']
        original = old[name]
        # Assembly may append a module's trailing comments before the next
        # declaration. Match the authenticated original declaration prefix;
        # never search/replace an unauthenticated function body substring.
        baseline = blocks((ROOT / item['original']).read_text())[name]
        if hashlib.sha256(baseline.encode()).hexdigest() != item['sha256']:
            raise ValueError('historical declaration changed ' + name)
        if not original.startswith(baseline) or source.count(baseline) != 1:
            raise ValueError('input does not contain one exact original ' + name)
        source = source.replace(baseline, replacements[name], 1)
        edits.append({'name': name, 'beforeSha256': item['sha256'], 'afterSha256': hashlib.sha256(replacements[name].encode()).hexdigest()})
    modules = [HERE / (name + '.bend') for name in ['model', 'verify', 'lower', 'nx', 'controls']]
    extra_inputs = []
    # A source carrying private runtime templates must also carry the closed
    # worker catalogue. Old frozen source snapshots remain untouched.
    if 'nx110rt_verify' in old:
        runtime_manifest = HERE / 'runtime-overrides.json'
        runtime_file = HERE / 'runtime-overrides.bend'
        namespace_manifest = HERE.parent / 'runtime-ir/namespace-overrides.json'
        extra_inputs += [runtime_manifest, runtime_file, namespace_manifest, namespace_manifest.with_suffix('.bend')]
        for exact_manifest in [runtime_manifest, namespace_manifest]:
            for row in json.loads(exact_manifest.read_text())['replacements']:
                if hashlib.sha256(row['old'].encode()).hexdigest() != row['oldSha256'] or hashlib.sha256(row['new'].encode()).hexdigest() != row['newSha256']:
                    raise ValueError('runtime override hash mismatch ' + row['name'])
                if (ROOT / row['origin']).read_text().count(row['old']) != 1 or source.count(row['old']) != 1:
                    raise ValueError('runtime override original mismatch ' + row['name'])
                source = source.replace(row['old'], row['new'], 1)
                edits.append({'name': row['name'], 'beforeSha256': row['oldSha256'], 'afterSha256': row['newSha256']})
        modules += [HERE / 'runtime-library.bend', HERE / 'runtime-controls.bend',
                    HERE.parent / 'runtime-ir/namespace.bend', HERE.parent / 'runtime-ir/namespace-controls.bend']
    added = '\n\n'.join(path.read_text() for path in modules)
    collision = set(blocks(source)) & set(blocks(added))
    if collision:
        raise ValueError('new declaration collision ' + str(sorted(collision)))
    source += '\n\n' + added + '\n'
    out.mkdir(parents=True)
    target = out / 'source.bend'
    target.write_text(source)
    report = {'kind': 'phase110-owned-call-source', 'complete': True, 'targetsRun': False,
              'inputs': [pin(source_path), pin(manifest_path), pin(replacements_path), pin(Path(__file__)), *map(pin, modules + extra_inputs)],
              'replacements': edits, 'source': pin(target)}
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    return target


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    print(prepare(args.source, args.out))
