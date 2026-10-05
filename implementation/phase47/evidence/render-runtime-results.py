#!/usr/bin/env python3
"""Data-only Phase47 report; rehash evidence and recompute saved observations."""
import hashlib
import json
import math
from pathlib import Path
import statistics
import sys

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
source = Path(sys.argv[1]).resolve()
summary = json.loads(source.read_text())
assert summary['complete'] and summary['pass']
assert (summary['points'], summary['samples'], summary['sourceCount']) == (45, 669, 23)
assert 'checked-array06' in summary['plan']['variants']['candidate']['compiler']['api']['file']
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
assert summary['medianChanges'] == dict(wins=wins, regressions=45-wins, ties=0)
ts_wins = [r['id'] for r in rows if r['ratios']['candidate/typescript'] < 1]
drift = {role: max(abs(v) for r in rows for v in r['rawSummary']['stats'][role]['halfDriftPercent'] if v is not None) for role in roles}
wall = sum(r['wallSeconds'] for r in reports)
node_version = summary['sampleEnvironment'][0] if isinstance(summary['sampleEnvironment'], list) else summary['sampleEnvironment']
order = {c['id']: i for i, c in enumerate(catalog['cases'])}
rows.sort(key=lambda r: order[r['id']])
for expected_identity in list(checked.values()) + [summary_identity, producer]:
    assert identity(expected_identity['path']) == expected_identity
evidence = dict(kind='phase47-complete-runtime-evidence', complete=True, **{'pass': True},
                scope='Saved-data validation and report generation only; no target execution, historical pooling or installation claim.',
                authoritativeSummary=summary_identity, producer=producer,
                verification=dict(summaryInputs=len(summary['inputs']), uniqueIdentitiesRehashed=len(checked),
                                  sampleLeafAgreements=669, independentlyRecomputedMedians=135, serialProcessIntervals=True),
                reports=summary['reports'], plan=summary['plan'], sampleEnvironment=summary['sampleEnvironment'],
                points=45, samples=669, sourceCount=23, familyCount=summary['familyCount'], wallSeconds=wall,
                geometricMeans=summary['geometricMeans'], medianChanges=summary['medianChanges'],
                pointsFasterThanTypeScript=ts_wins, maximumAbsoluteHalfDriftPercent=drift,
                sources=summary['sources'], families=summary['families'], cases=rows)
(HERE / 'runtime-summary.json').write_text(json.dumps(evidence, indent=2) + '\n')
g = summary['geometricMeans']
text = ['# Phase 47 complete generated-program execution comparison', '',
        f'All **669 fresh samples passed across 45 points and 23 source files**. Equal-point execution time changes from **{g["baseline/typescript"]["pointWeighted"]:.4f}×** pinned TypeScript for Phase 45 worker23 to **{g["candidate/typescript"]["pointWeighted"]:.4f}×** for array06: a **{g["baseline/candidate"]["pointWeighted"]:.4f}×** geometric improvement. The equal-source result is **{g["candidate/typescript"]["equalSourceWeighted"]:.4f}× TypeScript**. This is a modest corpus improvement with clear array wins and a substantial short-loop regression; TypeScript parity remains unmet.', '',
        'These are generated-program execution results. Compiler request latency, correctness qualification and release installation are separate decisions in the [phase report](README.md).', '',
        '## Protocol and weighting', '',
        f'Three complete 600-second-preset batches took {wall:.2f} s combined. Every ordinary point has five fresh rounds per role; raytrace has three. All three roles use Node {node_version.removeprefix("v")} on CPU 3, a 1,024 MiB heap, 2,048 MiB process-tree RSS cap and 4,096 MiB available-memory floor. The Node stack is 4,096 KiB. Warmup is at least 1,000 ms and three calls (one call for raytrace), calibration 50 ms, and the target measurement window 300 ms. These are warmed repeated-execution windows, not a proof of stationarity. Compilation, import and first-call time are excluded from the table.', '',
        '| Weighting | Worker23 / TypeScript | Array06 / TypeScript | Worker23 / array06 |',
        '| --- | ---: | ---: | ---: |']
for label, key in [('Equal point','pointWeighted'),('Equal source','equalSourceWeighted'),('Equal family','equalFamilyWeighted')]:
    text.append(f'| {label} | {g["baseline/typescript"][key]:.4f}× | {g["candidate/typescript"][key]:.4f}× | {g["baseline/candidate"][key]:.4f}× |')
text += ['', 'Equal-point weighting gives each of the 45 same-point median ratios one geometric weight. Equal-source weighting first combines points with the same source SHA-256, then weights the 23 source groups equally. Equal-family weighting uses the catalog’s 23 family groups; it is a different partition. These are ratios of medians, not summed-work throughput or a distribution of all Bend programs.', '',
         '## All 45 point medians', '', 'Times are milliseconds per call. Improvement above 1× means array06 takes less time than worker23; candidate / TS below 1× means it takes less time than TypeScript.', '',
         '| Point | TypeScript ms | Worker23 ms | Array06 ms | Worker23 / TS | Array06 / TS | Improvement |',
         '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
for row in rows:
    m, r = row['mediansMs'], row['ratios']
    text.append(f'| `{row["id"]}` | {m["typescript"]:.6f} | {m["baseline"]:.6f} | {m["candidate"]:.6f} | {r["baseline/typescript"]:.3f}× | {r["candidate/typescript"]:.3f}× | {r["baseline/candidate"]:.3f}× |')
text += ['', '## Improvements, regressions and remaining gap', '',
         f'Array06 has lower medians on **{wins} points**, higher medians on **{45-wins}**, and beats TypeScript on **{len(ts_wins)}**: '+', '.join('`'+x+'`' for x in ts_wins)+'. These sign counts are descriptive, not statistical tests.', '',
         'The largest median improvements are:', '']
for row in sorted(rows, key=lambda r: r['ratios']['baseline/candidate'], reverse=True)[:6]:
    text.append(f'- `{row["id"]}`: {row["ratios"]["baseline/candidate"]:.3f}× improvement; {row["ratios"]["candidate/typescript"]:.3f}× TypeScript time.')
text += ['', 'The largest regressions must remain visible:', '']
for row in sorted(rows, key=lambda r: r['candidateChangePercent'], reverse=True)[:5]:
    m = row['mediansMs']
    text.append(f'- `{row["id"]}`: **{row["candidateChangePercent"]:.2f}% more time**, {m["baseline"]*1000:.3f} → {m["candidate"]*1000:.3f} µs per call ({m["candidate"]/m["baseline"]:.3f}×).')
text += ['', 'The 128-iteration fold regresses by about 1.93× while the longer fold cases improve. That is a measured size-dependent tradeoff, not a reason to hide the short case. The main tree-bitonic point regresses by 4.17%, and its larger variant by 5.36%. This run does not isolate an added per-call body or another cause for those tree regressions. The 29 higher medians cannot collectively be dismissed as noise; they require scope-aware follow-up, even though many differences are small.', '',
         'The five largest remaining TypeScript ratios are:', '']
for row in sorted(rows, key=lambda r: r['ratios']['candidate/typescript'], reverse=True)[:5]:
    text.append(f'- `{row["id"]}`: {row["ratios"]["candidate/typescript"]:.3f}× TypeScript time; {row["mediansMs"]["candidate"]:.6f} ms per call.')
text += ['', f'Maximum absolute half-window drift is {drift["baseline"]:.1f}% for worker23, {drift["candidate"]:.1f}% for array06 and {drift["typescript"]:.1f}% for TypeScript. Undefined one-call drift is excluded rather than treated as zero. No confidence interval or significance claim is supplied. Small absolute durations, JIT behavior and allocation can affect these observations; this complete run does not establish the cause of every change.', '',
         '## Scope and evidence', '',
         'This finite maintained corpus informed implementation and is not an untouched holdout. It covers the recorded sources and inputs, including scalar, array, higher-order and library cases; it does not cover every Bend program. Independent renamed correctness witnesses validate narrower mechanisms, not representative speed. The array04 corpus run is an earlier, separate comparison with separately measured baselines. No array04 or Phase 45 samples are pooled into these results, and successive aggregate ratios are not divided to invent a causal gain.', '',
         'The [machine-readable evidence](evidence/runtime-summary.json) retains all per-point sample statistics, ratios, source/family groups and role identities. The [data-only renderer](evidence/render-runtime-results.py) rehashed every authoritative summary input and compiler identity, compared all 669 leaf receipts to their parent reports, recomputed 135 medians and all three weighting schemes, and verified serial sample intervals. It ran no compiler or emitted program.', '',
         f'Authoritative summary: `selfhost/build/phase47/corpus-array06/summary.json`, SHA-256 `{summary_identity["sha256"]}`. All raw paths below are evidence references, not GitHub links to ignored files:', '']
for item in summary['reports']:
    text.append(f'- `{Path(item["path"]).relative_to(REPO)}`: `{item["sha256"]}`.')
text += ['', '| Role | API SHA-256 | Runtime SHA-256 |', '| --- | --- | --- |']
for role, label in [('baseline','Phase 45 worker23'),('candidate','Array06')]:
    c = summary['plan']['variants'][role]['compiler']
    text.append(f'| {label} | `{c["api"]["sha256"]}` | `{c["runtime"]["sha256"]}` |')
text += ['', f'All roles bind upstream `{catalog["upstreamCommit"]}` and the same Base source. Final installation and preservation status belongs to the [phase report](README.md).', '']
(HERE.parent / 'results.md').write_text('\n'.join(text))
print(json.dumps(dict(complete=True, **{'pass': True}, points=45, samples=669, inputIdentities=len(checked),
                      geometricMeans=g, wins=wins, regressions=45-wins, typeScriptWins=ts_wins,
                      output=str(HERE.parent / 'results.md'))))
