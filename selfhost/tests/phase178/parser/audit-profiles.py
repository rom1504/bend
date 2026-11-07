#!/usr/bin/env python3
"""Compare five maintained source closures without executing a Bend target."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly

spec = importlib.util.spec_from_file_location('phase178_closure_transport', ROOT / 'experiments/phase147/tools/prepare.py')
extractor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(extractor)
NAMES = {'p140p_def_context_header', 'p140p_def_header_prior', 'p140p_def_prior',
         'p140p_def_base', 'p140p_def_type', 'p140p_def_body',
         'f_def_signature', 'f_decl_find'}
BASE = '296f288'
RECIPE = ROOT / 'selfhost/src/compiler.json'
EXPORTS = ['selfhost/tools/build/hosted-exports.json', 'selfhost/tools/build/js-c-exports.json']


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_commit(paths):
    paths = sorted(set(paths))
    data = subprocess.run(['git', 'cat-file', '--batch'], cwd=ROOT,
                          input=''.join(f'{BASE}:{path}\n' for path in paths).encode(),
                          stdout=subprocess.PIPE, check=True).stdout
    answer, offset = {}, 0
    for path in paths:
        end = data.index(b'\n', offset)
        header = data[offset:end].split()
        assert len(header) == 3 and header[1] == b'blob', (path, header)
        size = int(header[2]); offset = end + 1
        answer[path] = data[offset:offset + size]
        offset += size
        assert data[offset:offset + 1] == b'\n'
        offset += 1
    assert offset == len(data)
    return answer


def rows(data):
    return {(row['kind'], row['name']): row for row in assembly.blocks(data)[1]}


def canonical_normalized(data):
    return assembly.normalized(assembly.blocks(data)[1])


parser = argparse.ArgumentParser()
parser.add_argument('--out', type=Path)
args = parser.parse_args()
base_recipe_bytes = read_commit(['selfhost/src/compiler.json'])['selfhost/src/compiler.json']
base_recipe = json.loads(base_recipe_bytes)
current_recipe = json.loads(RECIPE.read_bytes())
assert base_recipe['modules'] == current_recipe['modules']
assert base_recipe['preamble'] == current_recipe['preamble']
assert base_recipe['profiles'] == current_recipe['profiles']
assert base_recipe['protectedDeclarations'] == current_recipe['protectedDeclarations']
assert base_recipe['defaultProfile'] == current_recipe['defaultProfile']
assert [row for row in base_recipe['order'] if row[2] not in NAMES] == current_recipe['order']
paths = ['selfhost/' + path for path in base_recipe['modules'] + [base_recipe['preamble']]]
paths += ['selfhost/' + profile['entryModule'] for profile in base_recipe['profiles'].values() if profile.get('entryModule')]
paths += EXPORTS + ['selfhost/src/compiler.json']
frozen = read_commit(paths)
for path in EXPORTS:
    assert frozen[path] == (ROOT / path).read_bytes(), 'Public root manifest changed'
assert frozen['selfhost/' + base_recipe['preamble']] == (ROOT / 'selfhost' / base_recipe['preamble']).read_bytes()

original_read = assembly.read

def frozen_read(path):
    relative = str(Path(path).resolve().relative_to(ROOT))
    assert relative in frozen, relative
    return frozen[relative]

report_rows = []
for profile, config in current_recipe['profiles'].items():
    try:
        assembly.read = frozen_read
        before = assembly.maintained_assemble(RECIPE, ROOT / 'selfhost', profile)
    finally:
        assembly.read = original_read
    after = assembly.maintained_assemble(RECIPE, ROOT / 'selfhost', profile)
    old, new = rows(before), rows(after)
    removed = set(old) - set(new)
    assert len(removed) == 12 and {name for kind, name in removed} == NAMES
    assert sum(kind == 'def' for kind, name in removed) == 8
    assert sum(kind == 'law' for kind, name in removed) == 4
    assert not set(new) - set(old)
    assert all(assembly.normalized([old[key]]) == assembly.normalized([new[key]]) for key in new)
    if config.get('omitMain'):
        roots = sorted(set(name for path in EXPORTS for name in json.loads(frozen[path])['exports']))
        root_scope = EXPORTS
    else:
        roots, root_scope = ['main'], [config.get('entryModule') or 'canonical main']
    left, left_inventory = extractor.extract([('maintained', before)], roots)
    right, right_inventory = extractor.extract([('maintained', after)], roots)
    left_keys = [(r['kind'], r['name']) for r in left_inventory]
    right_keys = [(r['kind'], r['name']) for r in right_inventory]
    assert left_keys == right_keys, 'Profile closure inventory changed: ' + profile
    assert not NAMES.intersection(name for kind, name in left_keys)
    left_normal, right_normal = canonical_normalized(left), canonical_normalized(right)
    assert left_normal == right_normal, 'Profile executable source changed: ' + profile
    report_rows.append({'profile': profile, 'entryScopes': root_scope, 'roots': roots,
                       'declarations': len(left_keys), 'removedNamesReachable': [],
                       'closureInventoryExact': True, 'normalizedClosureExact': True,
                       'normalizedBytes': len(left_normal), 'normalizedSha256': sha(left_normal),
                       'baselineSource': {'bytes': len(before), 'sha256': sha(before)},
                       'candidateSource': {'bytes': len(after), 'sha256': sha(after)}})
report = {
    'kind': 'phase178-five-profile-source-closure-audit', 'complete': True,
    'baselineCommit': BASE, 'targetRuns': False,
    'removedDeclarations': {'definitions': 8, 'laws': 4, 'names': sorted(NAMES)},
    'manifestOrderEqualsBaselineMinusTwelveDeclarations': True,
    'profilesProtectedDeclarationsPreambleAndPublicRootManifestsExact': True,
    'profiles': report_rows,
    'method': 'Maintained source assembly plus the existing Phase147 conservative identifier closure, including declaration laws and constructor-owner references. Normalize blank/comment lines and trailing whitespace only; preserve literal bytes and declaration order.',
    'scope': 'All four main entry closures and the js-api union of both maintained public export manifests are unchanged executable source. Every surviving assembled declaration also normalizes identically.',
    'caveats': [
        'Lexical source closure is not a target-specific lowerer, generated-byte comparison or compiler proof.',
        'The js-api profile omits main; its runtime roots come from the two unchanged explicit export manifests. Arbitrary experimental exports of removed internals are deliberately outside that contract.',
        'Full source checking still reads a smaller book. Global declaration numbering, source spans, emitted names, dead-code emission or host-specific serialization can change target bytes despite identical reachable source; qualification belongs to root.',
        'Comment cleanup in core/term.bend also changes text. Normalized executable declarations match; whole source is not byte-identical.'
    ],
    'inputs': [{'file': str(path.relative_to(ROOT)), 'sha256': sha(path.read_bytes())}
               for path in [Path(__file__), Path(assembly.__file__), Path(extractor.__file__), RECIPE]]
}
if args.out:
    args.out.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'complete': True, 'targetRuns': False,
                  'profiles': [{'profile': row['profile'], 'declarations': row['declarations'], 'normalizedClosureExact': True} for row in report_rows]}))
