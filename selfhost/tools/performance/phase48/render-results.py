#!/usr/bin/env python3
"""Phase48 derivative of the pinned Phase47 saved-data runtime renderer."""
import hashlib
import json
import math
from pathlib import Path
import statistics
import sys

REPO = Path(__file__).resolve().parents[4]
HERE = REPO / 'implementation/phase48/evidence'
PARENT = REPO / 'implementation/phase47/evidence/render-runtime-results.py'
PARENT_SHA = '238d5ae23faae97bb90c99bed0d7244e157b1e9f05568c9020b3cdfa597c0898'
assert hashlib.sha256(PARENT.read_bytes()).hexdigest() == PARENT_SHA
assert len(sys.argv) == 5, 'render-results.py SUMMARY EXPECTED_API EXPECTED_RUNTIME CANDIDATE_LABEL'
source = Path(sys.argv[1]).resolve()
candidate_label = sys.argv[4]
assert not (HERE / 'runtime-summary.json').exists() and not (HERE.parent / 'results.md').exists()
summary = json.loads(source.read_text())
assert summary['complete'] and summary['pass']
assert (summary['points'], summary['samples'], summary['sourceCount']) == (45, 669, 23)
assert summary['plan']['variants']['candidate']['compiler']['api']['sha256'] == sys.argv[2]
assert summary['plan']['variants']['candidate']['compiler']['runtime']['sha256'] == sys.argv[3]
assert summary['plan']['variants']['baseline']['compiler']['api']['sha256'] == '28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
assert summary['plan']['variants']['baseline']['compiler']['runtime']['sha256'] == '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
checked = {}


def identity(path):
    path = Path(path).resolve()
    with path.open('rb') as file:
        digest = hashlib.sha256()
        for block in iter(lambda: file.read(1024 * 1024), b''):
            digest.update(block)
    return dict(path=str(path), sha256=digest.hexdigest(), bytes=path.stat().st_size)


def verify(item):
    path = item.get('path', item.get('file', item.get('canonicalPath')))
    if path not in checked:
        checked[path] = identity(path)
    actual = checked[path]
    assert actual['sha256'] == item['sha256'], path
    assert item.get('bytes', actual['bytes']) == actual['bytes'], path
    return actual


def audit(value):
    if isinstance(value, list):
        for child in value:
            audit(child)
    elif isinstance(value, dict):
        if value.get('sha256') and any(k in value for k in ['path', 'file', 'canonicalPath']):
            verify(value)
        for child in value.values():
            audit(child)


def close(a, b):
    assert math.isclose(a, b, rel_tol=1e-12, abs_tol=1e-15), (a, b)


def gm(values):
    values = list(values)
    return math.exp(sum(math.log(x) for x in values) / len(values))


summary_identity = identity(source)
producer = identity(__file__)
parent_identity = verify(identity(PARENT))
audit(summary['inputs'])
audit(summary['reports'])
audit(summary['plan']['variants'])
catalog_path = REPO / 'selfhost/tools/performance/phase37/catalog.json'
catalog = json.loads(catalog_path.read_text())
assert catalog['upstreamCommit'] == '018751270e800bc222a93dad7f257083ee53a5f7'
catalog_cases = {case['id']: case for case in catalog['cases']}
reports = [json.loads(Path(item['path']).read_text()) for item in summary['reports']]
roles = summary['plan']['roles']
assert roles == ['typescript', 'baseline', 'candidate']
raw_cases, processes = {}, []
for report in reports:
    assert report['complete'] and report['pass']
    assert report['plan']['variants'] == summary['plan']['variants']
    assert report['plan']['protocol'] == summary['plan']['protocol']
    for case in report['cases']:
        assert case['id'] not in raw_cases
        raw_cases[case['id']] = case
        assert case['point'] == catalog_cases[case['id']]['point']
        rounds = 3 if case['id'] == 'raytrace' else 5
        assert len(case['samples']) == rounds * 3
        assert [(s['round'], s['role']) for s in case['samples']] == [
            (n, role) for n in range(rounds) for role in roles[n % 3:] + roles[:n % 3]]
        for sample in case['samples']:
            result, process = sample['result'], sample['process']
            assert result['complete'] and result['pass'] and process['complete']
            leaf = Path(process['command'][-1])
            assert json.loads(leaf.read_text()) == result
            assert json.loads((leaf.parent / 'process/process.json').read_text()) == process
            processes.append((process['started'], process['finished']))
assert len(processes) == 669 and len(raw_cases) == 45
ordered = sorted(processes)
assert all(a[1] <= b[0] for a, b in zip(ordered, ordered[1:]))
rows = []
for case in summary['cases']:
    raw = raw_cases[case['id']]
    assert case['sourceSha256'] == catalog_cases[case['id']]['source']['sha256']
    medians = {}
    for role in roles:
        samples = [s['result']['msPerCall'] for s in raw['samples'] if s['role'] == role]
        medians[role] = statistics.median(samples)
        close(medians[role], case['rawSummary']['stats'][role]['medianMs'])
    for ratio, actual in case['ratios'].items():
        a, b = ratio.split('/')
        close(medians[a] / medians[b], actual)
    close((medians['candidate'] / medians['baseline'] - 1) * 100, case['candidateChangePercent'])
    rows.append(dict(id=case['id'], sourceSha256=case['sourceSha256'], family=case['family'],
                     point=raw['point'], mediansMs=medians, ratios=case['ratios'],
                     candidateChangePercent=case['candidateChangePercent'],
                     rawSummary=case['rawSummary'], pairedRoundRatios=case['pairedRoundRatios']))
assert set(raw_cases) == {r['id'] for r in rows}
for ratio, result in summary['geometricMeans'].items():
    close(gm(r['ratios'][ratio] for r in rows), result['pointWeighted'])
    for field, groups, metric in [('sourceSha256', 'sources', 'equalSourceWeighted'), ('family', 'families', 'equalFamilyWeighted')]:
        keys = {r[field] for r in rows}
        grouped = {key: gm(r['ratios'][ratio] for r in rows if r[field] == key) for key in keys}
        for key, value in grouped.items():
            close(value, summary[groups][key][ratio])
        close(gm(grouped.values()), result[metric])
wins = sum(r['mediansMs']['candidate'] < r['mediansMs']['baseline'] for r in rows)
regressions = sum(r['mediansMs']['candidate'] > r['mediansMs']['baseline'] for r in rows)
assert summary['medianChanges'] == dict(wins=wins, regressions=regressions, ties=45-wins-regressions)
ts_wins = [r['id'] for r in rows if r['ratios']['candidate/typescript'] < 1]
drift = {role: max(abs(v) for r in rows for v in r['rawSummary']['stats'][role]['halfDriftPercent'] if v is not None) for role in roles}
wall = sum(r['wallSeconds'] for r in reports)
node_version = summary['sampleEnvironment'][0] if isinstance(summary['sampleEnvironment'], list) else summary['sampleEnvironment']
order = {c['id']: i for i, c in enumerate(catalog['cases'])}
rows.sort(key=lambda r: order[r['id']])
for expected_identity in list(checked.values()) + [summary_identity, producer]:
    assert identity(expected_identity['path']) == expected_identity
evidence = dict(kind='phase48-complete-runtime-evidence', complete=True, **{'pass': True},
                scope='Saved-data validation and report generation only; no target execution, historical pooling or installation claim.',
                authoritativeSummary=summary_identity, producer=producer, parent=parent_identity,
                verification=dict(summaryInputs=len(summary['inputs']), uniqueIdentitiesRehashed=len(checked),
                                  sampleLeafAgreements=669, independentlyRecomputedMedians=135, serialProcessIntervals=True),
                reports=summary['reports'], plan=summary['plan'], sampleEnvironment=summary['sampleEnvironment'],
                points=45, samples=669, sourceCount=23, familyCount=summary['familyCount'], wallSeconds=wall,
                geometricMeans=summary['geometricMeans'], medianChanges=summary['medianChanges'],
                pointsFasterThanTypeScript=ts_wins, maximumAbsoluteHalfDriftPercent=drift,
                sources=summary['sources'], families=summary['families'], cases=rows)
(HERE / 'runtime-summary.json').write_text(json.dumps(evidence, indent=2) + '\n')
g = summary['geometricMeans']
text = ['# Phase48 complete generated-program execution comparison', '',
    f'All **669 fresh samples passed across 45 points and 23 source files**. Equal-point execution time changes from **{g["baseline/typescript"]["pointWeighted"]:.4f}×** pinned TypeScript for array06 to **{g["candidate/typescript"]["pointWeighted"]:.4f}×** for {candidate_label}. The baseline/candidate geometric ratio is **{g["baseline/candidate"]["pointWeighted"]:.4f}×**; above 1 means the candidate takes less time.', '',
    'Generated-program execution, compiler request latency, semantic qualification and installation are separate results. This file asserts only the recorded runtime comparison.', '',
    '## Protocol and weighting', '',
    f'The three 600-second-preset batches take {wall:.2f} s combined. Ordinary points use five fresh rotated rounds per role; raytrace uses three. Node {node_version.removeprefix("v")} runs serially on CPU 3 with a 1,024 MiB heap, 2,048 MiB process-tree RSS ceiling, 4,096 MiB available-memory floor and 4,096 KiB stack. Warmup is at least 1,000 ms, calibration targets 50 ms and measurement targets 300 ms. These are warmed repeated-execution windows, not a stationarity proof. Compilation, import and first-call times are excluded from these medians.', '',
    '| Weighting | Array06 / TS | Candidate / TS | Array06 / candidate |',
    '| --- | ---: | ---: | ---: |']
for label, key in [('Equal point', 'pointWeighted'), ('Equal source', 'equalSourceWeighted'), ('Equal family', 'equalFamilyWeighted')]:
    text.append(f'| {label} | {g["baseline/typescript"][key]:.4f}× | {g["candidate/typescript"][key]:.4f}× | {g["baseline/candidate"][key]:.4f}× |')
text += ['', 'Each of 45 point median ratios has one geometric weight in the first row. The second first combines points sharing a source hash and then weights the 23 sources equally. The third uses the catalog family partition. These are not summed-work throughput or a distribution of every Bend program.', '',
    '## All 45 point medians', '', 'Times are milliseconds per call. Candidate / TS below 1 means less time than TypeScript; improvement above 1 means less time than array06.', '',
    '| Point | TypeScript ms | Array06 ms | Candidate ms | Array06 / TS | Candidate / TS | Improvement |',
    '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
for row in rows:
    m, r = row['mediansMs'], row['ratios']
    text.append(f'| `{row["id"]}` | {m["typescript"]:.6f} | {m["baseline"]:.6f} | {m["candidate"]:.6f} | {r["baseline/typescript"]:.3f}× | {r["candidate/typescript"]:.3f}× | {r["baseline/candidate"]:.3f}× |')
text += ['', '## Improvements, regressions and remaining gap', '',
    f'The candidate has lower medians on **{wins} points**, higher medians on **{regressions}**, and exact ties on **{45-wins-regressions}**. It beats TypeScript on **{len(ts_wins)}** points: '+(', '.join('`'+x+'`' for x in ts_wins) if ts_wins else 'none')+'. These sign counts are descriptive, not statistical tests.', '', 'Largest observed improvements:', '']
for row in sorted([r for r in rows if r['ratios']['baseline/candidate'] > 1], key=lambda r: r['ratios']['baseline/candidate'], reverse=True)[:6]:
    text.append(f'- `{row["id"]}`: {row["ratios"]["baseline/candidate"]:.3f}× improvement; {row["ratios"]["candidate/typescript"]:.3f}× TypeScript time.')
text += ['', 'Largest observed regressions:', '']
for row in sorted([r for r in rows if r['candidateChangePercent'] > 0], key=lambda r: r['candidateChangePercent'], reverse=True)[:6]:
    m = row['mediansMs']
    text.append(f'- `{row["id"]}`: **{row["candidateChangePercent"]:.2f}% more time**, {m["baseline"]*1000:.3f} → {m["candidate"]*1000:.3f} µs/call.')
text += ['', 'Largest remaining TypeScript ratios:', '']
for row in sorted(rows, key=lambda r: r['ratios']['candidate/typescript'], reverse=True)[:6]:
    text.append(f'- `{row["id"]}`: {row["ratios"]["candidate/typescript"]:.3f}× TypeScript time; {row["mediansMs"]["candidate"]:.6f} ms/call.')
text += ['', f'Maximum absolute half-window drift is {drift["baseline"]:.2f}% for array06, {drift["candidate"]:.2f}% for the candidate and {drift["typescript"]:.2f}% for TypeScript. Undefined one-call drift is excluded. No confidence interval or significance claim is supplied; observed regressions are not collectively dismissed as noise, and this comparison does not isolate every cause.', '',
    '## Scope and evidence', '',
    'This finite maintained corpus informed implementation and is not an untouched holdout. Independent renamed controls qualify particular mechanisms, not representative speed. No earlier phase, screen, profile or counter-derivative samples are pooled here. Prior aggregate ratios are not divided to manufacture a causal improvement.', '',
    'The [machine-readable evidence](evidence/runtime-summary.json) preserves every median, ratio, raw summary, paired round ratio and source/family grouping. The data-only renderer rehashes all authoritative inputs, agrees with all 669 leaf/process receipts, independently recomputes 135 medians and three geometric weighting schemes, and verifies serial sample intervals. It executes no compiler or generated program.', '',
    f'Authoritative summary: `{source.relative_to(REPO)}`, SHA-256 `{summary_identity["sha256"]}`. Raw report references:', '']
for item in summary['reports']:
    text.append(f'- `{Path(item["path"]).relative_to(REPO)}`: `{item["sha256"]}`.')
text += ['', '| Role | API SHA-256 | Runtime SHA-256 |', '| --- | --- | --- |']
for role, label in [('baseline', 'Array06'), ('candidate', candidate_label)]:
    c = summary['plan']['variants'][role]['compiler']
    text.append(f'| {label} | `{c["api"]["sha256"]}` | `{c["runtime"]["sha256"]}` |')
text += ['', f'All roles bind upstream `{catalog["upstreamCommit"]}` and the recorded Base source. Installation, preservation and semantic qualification belong to the [phase report](README.md).', '']
(HERE.parent / 'results.md').write_text('\n'.join(text))
print(json.dumps(dict(complete=True, **{'pass': True}, points=45, samples=669, geometricMeans=g, wins=wins, regressions=regressions, output=str(HERE.parent / 'results.md'))))
