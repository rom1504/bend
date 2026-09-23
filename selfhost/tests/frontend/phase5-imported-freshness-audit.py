#!/usr/bin/env python3
"""Audit P5-020 exact selected observations; deferred cases remain failures."""
import hashlib, json, pathlib, sys, traceback
ROOT = pathlib.Path(__file__).resolve().parents[2]
RUN = ROOT / 'build/phase5/imported-freshness'
OUT = pathlib.Path(sys.argv[1])
assert not OUT.exists()
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
inputs = []
def read(p):
    p = pathlib.Path(p)
    inputs.append({'file': str(p.resolve()), 'sha256': sha(p)})
    return json.loads(p.read_text())
report = {'kind': 'phase5-imported-freshness-audit', 'complete': False, 'inputs': inputs}
try:
    before = read(ROOT / 'build/phase5/integration/attempt-02/api.mjs.bootstrap.json')
    after = read(RUN / 'candidate-02/api.mjs.bootstrap.json')
    bm = {x['file']: x['sha256'] for x in before['modules']}
    am = {x['file']: x['sha256'] for x in after['modules']}
    assert bm.keys() == am.keys()
    assert [k for k in bm if bm[k] != am[k]] == ['src/load/graph.bend']
    assert after['provenance']['verifiedAfterBuild'] is True
    report['sourceDelta'] = ['src/load/graph.bend']
    report['apiSha256'], report['sourceSha256'] = after['apiSha256'], after['sourceSha256']
    old = read(RUN / 'baseline-final/paired.json')
    new = read(RUN / 'candidate-final/selected/paired.json')
    for paired in [old, new]:
        assert not paired.get('error') and not paired['missing']
        for variant in ['candidate', 'reference']:
            raw = read(paired['attempts'][variant]['file'])
            assert raw['finished'] and not raw.get('changedInputs')
            assert not raw['identity']['changedArtifacts']
            assert raw['identity']['adapterChangedDuringRun'] is False
            assert all(x['status'] not in ['crash', 'timeout', 'unsupported'] for x in raw['results'])
    prior = {(r['id'], r['lane']): r for r in old['rows']}
    assert len(prior) == len(new['rows']) == 45
    names = {'import/duplicate_name.bend', 'import/shadow_lib.bend',
             'import/shadow_tmpl_lib.bend', 'parse/reserved_def_name_000.bend'}
    names |= {'phase5/imported-freshness/' + n for n in
              ['base-law-shadow', 'base-type-shadow', 'earlier-check-error',
               'native-law-fill', 'native-open-law']}
    deferred = {'phase5/imported-freshness/' + n for n in
                ['imported-law-fill', 'malformed-imported-law-fill']}
    positive = {'phase5/imported-freshness/' + n for n in
                ['ordinary-law-fill', 'local-shadow', 'ctor-top-name', 'foreign-law-fill']}
    positive |= {'phase5/freshness/' + n for n in
                 ['distinct-module-constructors', 'namespaced-base-shadow', 'namespaced-base-constructor']}
    positive.add('base/list_sort.bend')
    rows = []
    for row in new['rows']:
        previous = prior[row['id'], row['lane']]
        assert row['reference'] == previous['reference'], row['id']
        assert not previous['exactAgreement'] or row['exactAgreement'], row['id']
        if row['id'] in names:
            assert not previous['semanticAgreement'] and row['semanticAgreement'], row['id']
            assert row['candidate']['phase'] == 'parse' and row['candidate']['checked'] is False
            for side in ['candidate', 'reference']:
                assert 'a fresh name (duplicate declaration:' in row[side]['diagnostic'], row['id']
        else:
            assert row['candidate'] == previous['candidate'], row['id']
        if row['id'] in positive:
            assert row['exactAgreement'] and row['candidateVerdict'] == row['referenceVerdict'] == 'pass'
        if not row['semanticAgreement']:
            assert row['id'] in deferred, row['id']
        rows.append({'id': row['id'], 'lane': row['lane'],
                     'semanticBefore': previous['semanticAgreement'], 'semanticAfter': row['semanticAgreement'],
                     'exactBefore': previous['exactAgreement'], 'exactAfter': row['exactAgreement'],
                     'before': previous['candidate'], 'candidate': row['candidate'], 'reference': row['reference']})
    report['rows'] = rows
    report['pairedObservationsPerVariant'] = len(rows)
    report['positiveFixtures'] = len(positive)
    report['resolvedSemantic'] = sum(not x['semanticBefore'] and x['semanticAfter'] for x in rows)
    report['resolvedExact'] = sum(not x['exactBefore'] and x['exactAfter'] for x in rows)
    report['remainingSemantic'] = sum(not x['semanticAfter'] for x in rows)
    report['remainingExact'] = sum(not x['exactAfter'] for x in rows)
    report['falseAcceptanceRepairs'] = [x['id'] for x in rows if x['lane'] == 'check' and x['before']['status'] == 'ok' and x['candidate']['status'] == 'error']
    assert report['resolvedSemantic'] == 18 and report['remainingSemantic'] == 4
    assert report['falseAcceptanceRepairs'] == ['phase5/imported-freshness/native-open-law']
    for item in inputs:
        assert sha(pathlib.Path(item['file'])) == item['sha256']
    report['complete'] = True
except Exception:
    report['error'] = traceback.format_exc()
OUT.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k: v for k, v in report.items() if k not in ['inputs', 'rows']}))
if not report['complete']:
    sys.exit(1)
