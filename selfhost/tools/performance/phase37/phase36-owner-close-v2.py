#!/usr/bin/env python3
"""Close inherited Phase36 owners with explicit Phase37 provenance namespaces.

All original semantic/checked-emission assertions remain unchanged. This
successor only repairs identity traversal and records/rechecks pinned Git blobs.
No compiler, test, generated program or profile is executed.
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('attempt', type=Path)
ap.add_argument('catalog', type=Path)
ap.add_argument('cohorts', type=Path)
ap.add_argument('mapping', type=Path, help='JSON object: required gate name -> completed report.json')
ap.add_argument('out', type=Path, help='New report.json; existing evidence is never overwritten')
a = ap.parse_args()
out = a.out.resolve()
assert not out.exists(), 'output must be new'
attempt_file = (a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt).resolve()
catalog_file = (a.catalog/'manifest.json' if a.catalog.is_dir() else a.catalog).resolve()
cohort_file = (a.cohorts/'derive.json' if a.cohorts.is_dir() else a.cohorts).resolve()
mapping_file = a.mapping.resolve()
observed = {}
git_observed = {}
upstream_tree = None
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'
DERIVATION_FILE = Path(__file__).with_name('phase36-owner-close-v2.derivation.json')


def identity(file):
    p = Path(file).resolve()
    digest = hashlib.sha256()
    with p.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            digest.update(block)
    return dict(file=str(p), sha256=digest.hexdigest(), bytes=p.stat().st_size)


def verify(ref, parent=ROOT):
    name = ref.get('file', ref.get('path'))
    assert name and 'sha256' in ref, ('not an identity', ref)
    file = Path(name)
    if not file.is_absolute():
        file = parent/file
    actual = observed.get(str(file.resolve())) or identity(file)
    assert actual['sha256'] == ref['sha256'], ('changed file', actual['file'])
    if 'bytes' in ref:
        assert actual['bytes'] == ref['bytes'], actual['file']
    if 'canonicalPath' in ref:
        assert actual['file'] == ref['canonicalPath'], actual['file']
    observed[actual['file']] = actual
    return Path(actual['file'])


def git_identity(commit, git_path):
    assert upstream_tree is not None and commit == PIN
    relative = Path(git_path)
    assert not relative.is_absolute() and '..' not in relative.parts
    git = verify(identity(shutil.which('git')))
    # Historical benchmark files are outside the sparse checkout, but their
    # pinned Git blobs remain available. This reads bytes; it runs no compiler.
    env = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_REPLACE_OBJECTS='1')
    raw = subprocess.check_output([str(git), '-C', str(upstream_tree), 'cat-file', 'blob',
                                   commit+':'+git_path], env=env, timeout=15)
    return dict(checkout=str(upstream_tree), commit=commit, gitPath=git_path,
                sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw),
                gitBlob=hashlib.sha1(('blob '+str(len(raw))+'\0').encode()+raw).hexdigest())


def verify_contextual(ref, document_file, data):
    name = Path(ref.get('file', ref.get('path')))
    if 'commit' in ref:
        assert not name.is_absolute()
        key = (ref['commit'], name.as_posix())
        actual = git_observed.get(key) or git_identity(*key)
        for field in ['sha256', 'bytes', 'gitBlob']:
            if field in ref:
                assert actual[field] == ref[field], ('Changed Git provenance', key, field)
        git_observed[key] = actual
        return None
    if name.is_absolute():
        return verify(ref)
    kind = data.get('kind') if isinstance(data, dict) else None
    if name.parts[0] == 'selfhost':
        base = ROOT
    elif kind in ['bend-program-catalog', 'bend-program-bundle', 'bend-program-preparation',
                  'phase37-historical-catalog-subset-preparation']:
        base = document_file.parent
    elif kind == 'phase37-application-point-proposal':
        # Proposal source paths deliberately use the phase catalog's base.
        assert document_file.name == 'points-v1.json' and document_file.parent.name == 'fixtures-new'
        base = document_file.parent.parent
    else:
        raise AssertionError(('Unknown relative identity namespace', str(document_file), kind, str(name)))
    return verify(ref, base)


def read(file):
    file = Path(file).resolve()
    actual = identity(file)
    if str(file) in observed:
        assert observed[str(file)] == actual, ('changed during audit', str(file))
    observed[str(file)] = actual
    return json.loads(file.read_text())


def refs(value):
    if isinstance(value, dict):
        if 'sha256' in value and ('file' in value or 'path' in value):
            yield value
        for child in value.values():
            yield from refs(child)
    elif isinstance(value, list):
        for child in value:
            yield from refs(child)


def attempt_check(file):
    d = read(file)
    assert d['kind'] == 'bend-development-attempt' and d['checked'] is True
    assert d['artifactKind'] == 'derived-b1'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'bootstrapReport', 'derivationReport']:
        verify(d[key], file.parent)
    for row in d['snapshot']['sources']:
        verify(row['frozen'], file.parent)
        assert row['frozen']['sha256'] == row['original']['sha256']
    return d


def scan(file, seen=None):
    """Verify identity edges recursively; never bind historical live source paths."""
    seen = {} if seen is None else seen
    file = Path(file).resolve()
    if str(file) in seen:
        return seen
    d = read(file)
    seen[str(file)] = d
    if isinstance(d, dict) and d.get('kind') == 'bend-development-attempt':
        attempt_check(file)
        return seen
    for ref in refs(d):
        target = verify_contextual(ref, file, d)
        if target is not None and target.suffix == '.json':
            scan(target, seen)
    return seen


report = dict(kind='phase36-final-owner-controls', complete=False, pass_=False,
              scope='Named owner gates only. Final canonical-source and inherited conformance audits remain separate.',
              auditVersion=2, derivation=identity(DERIVATION_FILE),
              inputs=[identity(p) for p in [Path(__file__), DERIVATION_FILE, attempt_file, catalog_file, cohort_file, mapping_file]], cases=[])
report['pass'] = report.pop('pass_')
try:
    for ref in report['inputs']:
        verify(ref)
    derivation = read(DERIVATION_FILE)
    assert derivation['kind'] == 'phase37-phase36-owner-close-derivation'
    assert derivation['parent']['sha256'] == '450016f3e719792e0668b26526f1f186c8d3d5c271a8edaffd9c1b606223bc4d'
    assert verify(derivation['parent']) == ROOT/'selfhost/tools/performance/phase36/owner-close.py'
    assert derivation['contextualResolverParent']['sha256'] == '6595799297f1ad4382594f4439b37f6267fa58b19d7b72d329458e453313c0b4'
    assert verify(derivation['contextualResolverParent']) == ROOT/'selfhost/tools/performance/phase37/owner-close-v2.py'
    assert verify(derivation['successor']) == Path(__file__).resolve()
    attempt = attempt_check(attempt_file)
    upstream = Path(attempt['config']['upstream'])
    upstream_tree = (upstream if upstream.is_absolute() else ROOT/upstream).resolve()
    scan(DERIVATION_FILE)
    catalog, cohorts, mapping = [read(p) for p in [catalog_file, cohort_file, mapping_file]]
    assert catalog['complete'] is True and cohorts['complete'] is True and cohorts['pass'] is True
    assert isinstance(mapping, dict)
    compiler = catalog['roles']['candidate']['compiler']
    assert compiler['kind'] == 'checked-development-attempt' and compiler['artifact'] == 'derived-b1'
    for key in ['api', 'runtime', 'base']:
        verify(compiler[key])
        assert compiler[key]['sha256'] == attempt[key]['sha256'], key
    verify(compiler['driver'])
    frozen = {Path(row['frozen']['file']).relative_to(Path(attempt['snapshot']['root'])).as_posix(): row['frozen']
              for row in attempt['snapshot']['sources']}
    tree_file = verify(frozen['src/back/js/tree.bend'])
    tree = tree_file.read_text()
    assert 'j_pure_valid(j_pure_graph(book, d, JPure{Nil{}, 32768, True{}}))' in tree, 'whole-root purity admission missing'
    assert 'j_fold_root_signature(book, dt(d), da(d)) && j_region_has_residual(helpers)' in tree
    assert 'regionProofOpen($guards);try{' in tree and '}finally{regionProofClose($previousProof);}' in tree
    producer_file = verify(frozen['src/back/js/producer.bend'])
    extended = 'def j_producer_ctor(' in producer_file.read_text()
    required = {'guardcolf', 'guardscope', 'error', 'array', 'producerfixture', 'producerreviewed'}
    if extended:
        required.add('selector')
    assert set(mapping) == required, ('wrong owner mapping', sorted(required), sorted(mapping))
    report.update(attempt=identity(attempt_file), api=attempt['api'], runtime=attempt['runtime'],
                  purityAdmission=identity(tree_file), producerSource=identity(producer_file), extended=extended)

    def emission(file, expected_source=None):
        d = read(file)
        assert d['kind'] == 'bend-program-checked-emission' and d['complete'] is True
        o = d['observation']
        assert o['checked'] is True and o['typeAccepted'] is True and o['exitCode'] == 0
        verify(d['attempt'])
        assert d['attempt']['sha256'] == identity(attempt_file)['sha256']
        assert d['compiler'] == compiler, 'emission belongs to a different compiler/source/runtime'
        verify(d['input']); output = verify(d['output'])
        if expected_source is not None:
            assert d['input']['sha256'] == expected_source
        scan(file)
        return dict(receipt=identity(file), output=identity(output), source=d['input'], compiler=d['compiler'])

    preparation_file = verify(catalog['preparation'], catalog_file.parent)
    preparation = read(preparation_file)
    assert preparation['complete'] is True
    catalog_emissions = {}
    for row in preparation['sources']:
        receipt = verify(row['emission'], catalog_file.parent)
        e = emission(receipt, row['source']['sha256'])
        catalog_emissions[row['source']['sha256']] = e
    catalog_cases = {case['id']: case for case in catalog['cases']}
    assert {'symreg', 'raytrace'} <= set(catalog_cases)
    for case in catalog['cases']:
        verify(case['modules']['candidate'], catalog_file.parent)
        assert case['sourceSha256'] in catalog_emissions
        raw_hash = catalog_emissions[case['sourceSha256']]['output']['sha256']
        module_hash = case['modules']['candidate']['sha256']
        if module_hash != raw_hash:
            adapters = [row for row in preparation.get('adapters', [])
                        if row['raw']['sha256'] == raw_hash and row['adapted']['sha256'] == module_hash]
            assert len(adapters) == 1 and case['id'] == 'complete-generic-row32', 'unbound catalog module'
            adapter = adapters[0]
            assert adapter['kind'] == 'complete-generic-row-serialization'
            for key in ['raw', 'adapted', 'producer']:
                verify(adapter[key], catalog_file.parent)
    ray = catalog_emissions[catalog_cases['raytrace']['sourceSha256']]
    assert ray['output']['sha256'] == catalog_cases['raytrace']['modules']['candidate']['sha256']
    final_cohorts = {}
    for name, row in cohorts['cases'].items():
        manifest = verify(row['manifest'], cohort_file.parent)
        d = read(manifest)
        assert d['complete'] is True
        receipt = verify(d['emissions']['candidate'], manifest.parent)
        e = emission(receipt, d['source']['sha256'])
        assert e['output']['sha256'] == d['variants']['candidate']['sha256']
        verify(d['variants']['candidate'], manifest.parent)
        final_cohorts[name] = e
    assert 'overflow-v2' in final_cohorts
    array_names = [n for n in ['array-refusal-v2', 'array-refusal'] if n in final_cohorts]
    assert len(array_names) == 1, 'select exactly one final array refusal fixture'
    producer_names = [n for n in ['producer-fixtures-v2', 'producer-fixtures'] if n in final_cohorts]
    assert len(producer_names) == 1, 'select exactly one final producer fixture'
    expected = {'guardcolf': ray, 'guardscope': ray, 'error': final_cohorts['overflow-v2'],
                'array': final_cohorts[array_names[0]], 'producerfixture': final_cohorts[producer_names[0]],
                'producerreviewed': final_cohorts[producer_names[0]]}
    if extended:
        selector_names = [n for n in ['producer-selectors-v2', 'producer-selectors'] if n in final_cohorts]
        assert len(selector_names) == 1, 'select exactly one final selector fixture'
        expected['selector'] = final_cohorts[selector_names[0]]
    kinds = {'guardcolf': 'phase36-checked-scoped-guard-colf-controls', 'guardscope': 'phase36-scoped-guard-scope-controls',
             'error': 'phase36-checked-error-scope-controls', 'array': 'phase36-checked-array-proof-refusal',
             'producerfixture': 'phase36-producer-fixture-controls', 'producerreviewed': 'phase36-independent-checked-producer-controls',
             'selector': 'phase36-producer-selector-controls'}
    counts = {'guardcolf': {'oracle': 57, 'boundaries': 200}, 'guardscope': {'observations': 10},
              'error': {'oracle': 16, 'boundaries': 4}, 'array': {'oracle': 16, 'boundaries': 4},
              'producerfixture': {'oracle': 175, 'admission': 5},
              'producerreviewed': {'trees': 108, 'aliases': 36, 'entries': 9, 'boundaries': 27, 'structure': 3},
              'selector': {'oracle': 243, 'admission': 10, 'boundaries': 6}}
    for name in sorted(required):
        file = Path(mapping[name])
        if not file.is_absolute():
            file = ROOT/file
        file = file.resolve()
        gate = read(file)
        assert gate['complete'] is True and gate['pass'] is True and not gate.get('error'), name
        if name in kinds:
            assert gate['kind'] == kinds[name], (name, gate.get('kind'))
        for key, size in counts.get(name, {}).items():
            assert len(gate[key]) == size, (name, key, len(gate[key]), size)
        closure = scan(file)
        input_hashes = {ref['sha256'] for ref in gate['inputs']}
        target_hash = expected[name]['output']['sha256']
        if name in ['guardcolf', 'guardscope']:
            derived = [d for d in closure.values() if d.get('acquisitionKind') == 'phase36-checked-scoped-guard-cohort']
            assert len(derived) == 1, name
            d = derived[0]
            assert d['complete'] is True and d['checked'] is True and d['compilers']['candidate'] == compiler
            checked = read(verify(d['checkedEmissions']['candidate']))
            assert checked['output']['sha256'] == target_hash and checked['compiler'] == compiler
            partial = next(row for row in d['modules'] if row['variant'] == 'partial')
            clean = next(row for row in d['modules'] if row['variant'] == 'candidate')
            assert clean['sha256'] == target_hash and partial['sha256'] in input_hashes
        else:
            assert target_hash in input_hashes, ('gate did not consume final candidate module', name)
            if name in ['producerreviewed', 'selector']:
                assert gate['diagnostic']['parent']['sha256'] == target_hash
        report['cases'].append(dict(name=name, returncode=0, reports=[identity(file)], emission=expected[name],
                                    identityDocuments=len(closure), counts={k: len(gate[k]) for k in counts.get(name, {})}))
    # Recheck all observed artifacts after walking the complete proof graph.
    for row in observed.values():
        assert identity(row['file']) == row, ('changed during audit', row['file'])
    for key, row in git_observed.items():
        assert git_identity(*key) == row, ('changed Git provenance during audit', key)
    report['verifiedIdentities'] = list(observed.values())
    report['verifiedGitProvenance'] = list(git_observed.values())
    report['complete'] = report['pass'] = True
except Exception as error:
    report['error'] = repr(error)
    raise
finally:
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(complete=True, groups=len(report['cases']), verifiedIdentities=len(observed), output=str(out))))
