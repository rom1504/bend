#!/usr/bin/env python3
"""Authenticate Phase185 runtime receipts and report Phase190 comparisons; run no targets."""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


A = module('phase186_analysis', ROOT / 'selfhost/tests/phase186/analyze-runtime.py')
B, C = A.B, A.C
CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
PARTITION = Path(__file__).with_name('cases.json')


def aggregate(cases, role, reference):
    eligible = [c for c in cases if c['ratioEligible']]
    if not eligible:
        return None
    ratios = [c['stats'][role]['medianMs'] / c['stats'][reference]['medianMs'] for c in eligible]
    fixed = lambda r: sum(c['stats'][r]['medianMs'] * c['point']['repetitions'] for c in eligible)
    rows = [dict(id=c['id'], ratio=v, flagged=c['flagged']) for c, v in zip(eligible, ratios)]
    return dict(caseCount=len(eligible), geomean=A.gm(ratios),
        meanPositiveLogSlowdown=statistics.mean(max(0, math.log(v)) for v in ratios),
        casesOver110=sum(v > 1.1 for v in ratios), casesOver2=sum(v > 2 for v in ratios),
        fixedEquivalentMs=fixed(role), referenceFixedEquivalentMs=fixed(reference),
        fixedEquivalentRatio=fixed(role) / fixed(reference),
        worstRegressions=sorted((r for r in rows if r['ratio'] > 1), key=lambda r: -r['ratio'])[:10])


def authenticate_references(filename, current, raw, c_role, baseline_role):
    pin = C.pin(filename)
    doc = B.read(filename)
    C.require(doc.get('schema') == 'bend-benchmark-manifest-v1' and doc.get('kind') == 'programs',
              'Frozen reference program manifest required')
    C.require(pin in raw['inputs'], 'Frozen reference manifest must be pinned by runtime report')
    for item in doc['inputs']:
        C.verify(item)
    cases = {c['id']: c for c in doc['cases']}
    for role in (c_role, baseline_role):
        C.require(role in current['roles'] and role in doc['roles'], 'Reference role missing: ' + role)
    C.require(doc['roles'][c_role]['target'] == 'c' and doc['roles'][baseline_role]['target'] == 'x86',
              'C and frozen direct-object x86 reference roles required')
    for case in current['cases']:
        prior = cases[case['id']]
        C.require(case['point'] == prior['point'], 'Frozen reference point differs')
        for role in (c_role, baseline_role):
            C.require(case['artifacts'][role] == prior['products'][role]['artifact'],
                      'Runtime executable differs from frozen reference: ' + role + '/' + case['id'])
    C.require(C.pin(filename) == pin, 'Reference manifest changed during analysis')
    return pin


def emission_cost(label, filename, runtime_inputs):
    # Reuse the acquisition reader's checked API, product and catalog validation.
    build = module('phase190_products', Path(__file__).with_name('build-programs.py'))
    pin = C.pin(filename)
    doc, authority, _, inputs = build.emission(filename)
    for item in inputs:
        C.verify(item)
    C.require(not doc.get('changedInputs') and not authority.get('error')
              and not authority.get('changedInputs'), 'Changed or failed emission authority')
    fields = ['prepareSeconds', 'selectSeconds', 'renderSeconds']
    if doc['emit'] == 'object':
        fields.append('objectSeconds')
    rows = []
    for row in doc['rows']:
        C.require(all(isinstance(row.get(k), (int, float)) and math.isfinite(row[k]) and row[k] >= 0
                      for k in fields), 'Finite nonnegative API cost fields required')
        rows.append(dict(id=row['id'], **{k: row[k] for k in fields}))
    base = doc.get('baseSeconds')
    C.require(isinstance(base, (int, float)) and math.isfinite(base) and base >= 0,
              'Finite nonnegative Base preparation cost required')
    C.require(C.pin(filename) == pin, 'Emission receipt changed during analysis')
    return dict(label=label, receipt=pin, api=authority['api'], source=authority['source'],
        pinnedByRuntimeReport=pin in runtime_inputs, emit=doc['emit'], baseSeconds=base,
        totals={k: sum(row[k] for row in rows) for k in fields}, cases=rows,
        scope='Observed checked hosted API preparation/selection and emission costs, including host serialization and writes in render/object intervals. Single acquisition observations; not native compiler throughput or runtime. Labels do not assert executable identity.')


def summarize(args):
    C.require(math.isfinite(args.spread_limit) and args.spread_limit >= 1, 'Spread limit must be at least 1')
    partition_pin = C.pin(PARTITION)
    partition = B.read(PARTITION)
    catalog_pin = C.pin(CATALOG)
    C.require(all(partition['catalog'][k] == catalog_pin[k] for k in ('sha256', 'bytes')),
              'Frozen partition catalog changed')
    known = {c['id'] for c in B.catalog(CATALOG)['cases']}
    names = partition['development'] + partition['heldout']
    C.require(len(names) == len(set(names)) == 45 and set(names) == known,
              'Complete unique native45 partition required')
    raw = B.read(args.report)
    ids = [c['id'] for c in raw['cases']]
    C.require(ids and len(ids) == len(set(ids)) and ids == raw['selectedCaseIds'],
              'Unique selected runtime cases required')
    current = A.analyze(args.report, args.spread_limit)
    C.require(C.pin(args.report) == current['report'], 'Runtime receipt changed during analysis')
    C.require(raw == B.read(args.report), 'Runtime receipt changed during analysis')
    refs = authenticate_references(args.references, current, raw, args.c_role, args.baseline_role)
    C.require(args.c_role != args.baseline_role and current['reference'] == args.c_role,
              'Distinct C/baseline roles and C runtime reference required')
    # Report admission alone must not conceal sub-100ms timing observations.
    for case in raw['cases']:
        for row in case['samples']:
            C.require(not case['point']['ratioEligible'] or row['elapsedMs'] >= raw['minimumAcceptedMs'] >= 100,
                      'Low-resolution eligible sample')
    groups, cases = {}, []
    for case in current['cases']:
        split = 'development' if case['id'] in partition['development'] else 'heldout'
        groups.setdefault(split, []).append(case)
        eligible = case['ratioEligible']
        cases.append(dict(id=case['id'], partition=split, ratioEligible=eligible,
            medianMs={r: case['stats'][r]['medianMs'] for r in current['roles']},
            fixedEquivalentMs={r: case['stats'][r]['medianMs'] * case['point']['repetitions']
                               for r in current['roles']} if eligible else None,
            ratios={r: dict(overC=case['stats'][r]['medianMs'] / case['stats'][args.c_role]['medianMs'],
                           overBaseline=case['stats'][r]['medianMs'] / case['stats'][args.baseline_role]['medianMs'])
                    for r in current['roles']} if eligible else None,
            dispersion=case['stats'], artifacts=case['artifacts'], flagged=case['flagged']))
    subsets = {}
    for name, selected in [('all', current['cases']), ('development', groups.get('development', [])),
                           ('heldout', groups.get('heldout', []))]:
        expected = known if name == 'all' else set(partition[name])
        subsets[name] = dict(caseCount=len(selected), expectedCount=len(expected),
            missingCaseIds=sorted(expected - {c['id'] for c in selected}),
            ratioEligibleCount=sum(c['ratioEligible'] for c in selected),
            roles={r: dict(overC=aggregate(selected, r, args.c_role),
                           overBaseline=aggregate(selected, r, args.baseline_role)) for r in current['roles']})
    costs = [emission_cost(label, Path(path), raw['inputs']) for label, path in args.emission]
    C.require(len({c['label'] for c in costs}) == len(costs), 'Unique emission cost labels required')
    C.require(C.pin(PARTITION) == partition_pin, 'Partition changed during analysis')
    return dict(kind='phase190-authenticated-runtime-summary', version=1, programsExecuted=False,
        method=C.pin(__file__), analyzer=C.pin(A.__file__), report=current['report'], references=refs,
        partition=partition_pin, roles=current['roles'], cRole=args.c_role, baselineRole=args.baseline_role,
        rounds=current['rounds'], positionBalanced=current['positionBalanced'],
        oracleRevalidated=current['oracleRevalidated'], inputPinsVerified=current['inputPinsVerified'],
        subsets=subsets, cases=cases, compilerApiCosts=costs, dispersionThreshold=args.spread_limit,
        warnings=([] if current['positionBalanced'] else ['Role positions are not balanced across rounds.']) +
            (['Dispersion exceeds threshold: ' + ', '.join(current['flaggedCases'])] if current['flaggedCases'] else []),
        scope='Ratios are ratios of role medians from this runtime report. Frozen baseline means authenticated executable identities, freshly timed in the same report. All eligible cases remain included, including dispersion flags. Fixed-equivalent sums use original catalog repetitions, never adaptive calibration counts; zero-work cases remain correctness-only. Partial development/heldout coverage is explicit; no unseen results, significance or promotion claim.')


def markdown(result):
    lines = ['# Phase190 runtime summary', '', result['scope'], '',
             'Runtime receipt: `' + result['report']['file'] + '`',
             'Validated observations: ' + json.dumps(result['oracleRevalidated']) + '.', '']
    lines += ['Warning: ' + w for w in result['warnings']]
    for name, subset in result['subsets'].items():
        lines += ['', '## ' + name, '', f"{subset['caseCount']}/{subset['expectedCount']} cases observed; {subset['ratioEligibleCount']} ratio eligible.", '',
                  '| Role | Versus | Geomean | Mean positive log slowdown | >1.1× | >2× | Fixed-equivalent ms | Reference ms |',
                  '|---|---|---:|---:|---:|---:|---:|---:|']
        for role, comparisons in subset['roles'].items():
            for reference, stats in comparisons.items():
                if stats is not None:
                    lines.append(f"| {role} | {reference} | {stats['geomean']:.6g} | {stats['meanPositiveLogSlowdown']:.6g} | {stats['casesOver110']} | {stats['casesOver2']} | {stats['fixedEquivalentMs']:.6g} | {stats['referenceFixedEquivalentMs']:.6g} |")
        if subset['missingCaseIds']:
            lines += ['', 'Unmeasured: ' + ', '.join(subset['missingCaseIds']) + '.']
    lines += ['', '## Per-case ratios', '', '| Case | Partition | Role | / C | / baseline | Dispersion flag |',
              '|---|---|---|---:|---:|---|']
    for case in result['cases']:
        for role in result['roles']:
            ratios = case['ratios'][role] if case['ratios'] else None
            values = f"{ratios['overC']:.6g} | {ratios['overBaseline']:.6g}" if ratios else 'ineligible | ineligible'
            lines.append(f"| {case['id']} | {case['partition']} | {role} | {values} | {case['flagged']} |")
    lines += ['', '## Worst regressions against frozen baseline', '']
    for role, stats in result['subsets']['all']['roles'].items():
        worst = stats['overBaseline']
        if worst is not None:
            lines.append(role + ': ' + (', '.join(f"{r['id']} {r['ratio']:.6g}×" for r in worst['worstRegressions']) or 'none') + '.')
    lines += ['', '## Separate compiler API costs', '']
    if not result['compilerApiCosts']:
        lines.append('No emission receipts supplied; compiler costs unmeasured here.')
    for cost in result['compilerApiCosts']:
        lines += [cost['label'] + ': Base ' + f"{cost['baseSeconds']:.6g}s; " +
                  '; '.join(f'{key}={value:.6g}s' for key, value in cost['totals'].items()) + '.',
                  cost['scope'], 'Receipt pinned by runtime report: ' + str(cost['pinnedByRuntimeReport']) + '.']
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', required=True, type=Path)
    parser.add_argument('--references', required=True, type=Path, help='Frozen Phase190 reference manifest')
    parser.add_argument('--out', required=True, type=Path, help='Fresh JSON file; adjacent .md also created')
    parser.add_argument('--c-role', default='c')
    parser.add_argument('--baseline-role', default='baseline')
    parser.add_argument('--spread-limit', type=float, default=1.10)
    parser.add_argument('--emission', nargs=2, action='append', default=[], metavar=('LABEL', 'RECEIPT'))
    args = parser.parse_args()
    md = args.out.with_suffix('.md')
    C.require(args.out.suffix == '.json' and not args.out.exists() and not md.exists(),
              'Fresh .json and adjacent .md output paths required')
    result = summarize(args)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    B.save(args.out, result, fresh=True)
    with md.open('x') as stream:
        stream.write(markdown(result))
    print(json.dumps(dict(json=str(args.out), markdown=str(md), warnings=result['warnings'])))


if __name__ == '__main__':
    main()
