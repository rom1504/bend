#!/usr/bin/env python3
"""Prepare a new native source profile; never compile or mutate its full parent.

This is an experiment in source composition, not a semantic dead-code prover.
Every selected same-name law/definition block remains in original byte order.
"""
import argparse
import collections
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT / 'selfhost/build/phase143/integrated-source03/compiler.bend'
MANIFEST = PARENT.with_name('manifest.json')
SOURCE_SHA = 'a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'
PARSER = ROOT / 'selfhost/tools/performance/phase141/census/read-onlyinventory.py'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': sha(data)}


def main():
    args = argparse.ArgumentParser()
    args.add_argument('--out', required=True)
    args.add_argument('--all-laws', action='store_true')
    opts = args.parse_args()
    out = (ROOT / opts.out).resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase144') or out.exists():
        raise SystemExit('fresh output below selfhost/build/phase144 required')
    original = PARENT.read_bytes()
    if sha(original) != SOURCE_SHA:
        raise SystemExit('qualified source identity differs')
    full = original.decode()
    parent = json.loads(MANIFEST.read_text())
    if parent['source']['sha256'] != SOURCE_SHA:
        raise SystemExit('parent manifest identity differs')
    spec = importlib.util.spec_from_file_location('phase141_inventory', PARSER)
    census = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(census)
    rows = census.parse(str(PARENT))
    # Independently check that declaration names were not matched inside literals.
    masked = census.LEX.sub(lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), full)
    starts = list(re.finditer(r'^(type|law|def)\s+([A-Za-z_][A-Za-z0-9_.]*)', masked, re.M))
    if [(m[1], m[2]) for m in starts] != [(r['kind'], r['name']) for r in rows]:
        raise SystemExit('independent masked declaration scan disagrees')
    prefix = full[:full.index(rows[0]['raw'])]
    if prefix + ''.join(r['raw'] for r in rows) != full:
        raise SystemExit('declaration spans fail full-source reconstruction')
    annotations = re.findall(r'^@[^\n]*', masked, re.M)
    if any(x != '@unsafe' for x in annotations):
        raise SystemExit('unhandled source annotation')
    attached = sum(r['raw'].startswith('@unsafe\n') for r in rows)
    if attached != len(annotations):
        raise SystemExit('annotation is not attached to its exact declaration')
    names = {r['name'] for r in rows}
    owners = collections.defaultdict(set)
    for r in rows:
        if r['kind'] == 'type':
            for constructor in re.findall(r'\b([A-Z][A-Za-z0-9_]*)\s*\{', census.clean(r['raw'])):
                owners[constructor].add(r['name'])
    graph = {name: set() for name in names}
    for r in rows:
        graph[r['name']] |= r['tokens'] & names
        for token in r['tokens']:
            graph[r['name']] |= owners.get(token, set())
    required = {'main'} | set(parent['protectedDeclarations']) | set(parent['unchangedProofDeclarations'])
    if required - names:
        raise SystemExit('required root missing from source')
    roots = required | ({r['name'] for r in rows if r['kind'] == 'law'} if opts.all_laws else set())
    selected = census.reach(graph, roots)
    if any(graph[n] - selected for n in selected):
        raise SystemExit('lexical closure has a missing internal dependency')
    kept = [r for r in rows if r['name'] in selected]
    dropped = [r for r in rows if r['name'] not in selected]
    source = (prefix + ''.join(r['raw'] for r in kept)).encode()
    def counts(rs):
        return {'names': len({r['name'] for r in rs}), 'declarations': len(rs),
                'codeLines': sum(r['codeLines'] for r in rs),
                'physicalDeclarationLines': sum(r['physicalLines'] for r in rs),
                'bytes': sum(r['bytes'] for r in rs),
                'kinds': dict(collections.Counter(r['kind'] for r in rs))}
    def record(r):
        return {'kind': r['kind'], 'name': r['name'], 'originalLine': r['line'],
                'bytes': r['bytes'], 'rawSha256': sha(r['raw'].encode()),
                'codeLines': r['codeLines'], 'physicalLines': r['physicalLines'],
                'dependencies': sorted(graph[r['name']] - {r['name']})}
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_bytes(source)
    result = {'kind': 'phase144-native-source-profile-v1', 'complete': True,
              'checked': False, 'nativeQualified': False, 'selected': False,
              'profile': 'native-cli-all-laws' if opts.all_laws else 'native-cli',
              'source': pin(out / 'compiler.bend'), 'parent': pin(PARENT),
              'parentManifest': pin(MANIFEST), 'method': pin(Path(__file__).resolve()),
              'declarationParser': pin(PARSER), 'requiredRoots': sorted(required),
              'roots': sorted(roots), 'retained': counts(kept), 'excluded': counts(dropped),
              'physicalLines': len(source.splitlines()),
              'codeLines': counts(kept)['codeLines'] + 1,
              'protectedDeclarations': parent['protectedDeclarations'],
              'unchangedProofDeclarations': parent['unchangedProofDeclarations'],
              'overrides': [], 'added': [],
              'preservedHeaderSha256': sha(prefix.encode()),
              'allSameNameBlocksAndAnnotationsPreserved': True,
              'originalDeclarationOrderPreserved': True,
              'fullParentAndPublishedAPIUnmodified': True,
              'compilerTargetsRun': False,
              'caveats': ['Lexical closure is not a semantic dead-code theorem.',
                          'Binder collisions conservatively retain extra declarations.',
                          'Implicit elaboration and foreign/reflection contracts require independent checking.',
                          'Full JS/C/test API remains in the parent composition, not this profile.',
                          'Compilation of changed source measures workflow cost, not same-source algorithm speed.']}
    (out / 'retained.json').write_text(json.dumps([record(r) for r in kept], indent=2) + '\n')
    (out / 'excluded.json').write_text(json.dumps([record(r) for r in dropped], indent=2) + '\n')
    result['retainedDeclarations'] = pin(out / 'retained.json')
    result['excludedDeclarations'] = pin(out / 'excluded.json')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('source', 'profile', 'physicalLines', 'codeLines', 'retained', 'excluded')}, indent=2))


if __name__ == '__main__':
    main()
