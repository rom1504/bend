#!/usr/bin/env python3
"""Summarize a completed native45 runtime report; never run benchmark products."""
import argparse
import csv
import json
import math
import os
from pathlib import Path
import statistics
import sys
import tempfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, require, write_json

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
ROLES = ('handwritten-c', 'bend-qbe', 'bend-c')
LABELS = {'handwritten-c': 'Handwritten C', 'bend-qbe': 'Bend QBE',
          'bend-c': 'Bend C', 'envelope': 'Best Bend envelope'}
RATIOS = ('bend-qbe', 'bend-c', 'envelope')


def close(a, b):
    return isinstance(a, (int, float)) and not isinstance(a, bool) and math.isfinite(a) and math.isclose(a, b, rel_tol=1e-12, abs_tol=1e-15)


def distribution(values):
    median = statistics.median(values)
    return dict(medianUs=median, minimumUs=min(values), maximumUs=max(values),
                madUs=statistics.median(abs(value - median) for value in values),
                rangePercent=100 * (max(values) - min(values)) / median if median else None,
                samplesUs=values)


def derive(document, catalog, catalog_pin):
    """Recompute from timed batches and refuse partial or altered cohorts."""
    require(document.get('kind') == 'phase184-direct-c-runtime-comparison' and document.get('version') == 1,
            'Expected the maintained handwritten-c/run.py runtime report')
    require(document.get('complete') is True and document.get('status') == 'complete'
            and document.get('executionComplete') is True and document.get('aggregate', {}).get('complete') is True
            and not document.get('error') and not document.get('changedInputs') and not document.get('deadlineReached'),
            'Incomplete, invalidated, failed or deadline-limited report: aggregate refused')
    require(document.get('reference') == ROLES[0] and document.get('roles') == list(ROLES), 'Unexpected runtime roles')
    require(document.get('fullCatalog') is True and document.get('allManifestCases') is True
            and document.get('manifestCaseCount') == 45, 'Only complete original45 reports admit an aggregate')
    require(any(row.get('bytes') == catalog_pin['bytes'] and row.get('sha256') == catalog_pin['sha256']
                for row in document.get('methods', [])), 'Runtime report does not bind this native45 catalog')
    originals = {case['id']: case for case in catalog['cases']}
    require(len(originals) == len(catalog['cases']) == 45, 'Original catalog must have 45 unique cases')
    cases, selected = document['cases'], document['selectedCaseIds']
    require(len(cases) == len(selected) == len(set(selected)) == 45
            and {case['id'] for case in cases} == set(selected) == set(originals), 'Missing, duplicate or foreign case')
    rounds = document['rounds']
    require(type(rounds) is int and 1 <= rounds <= 20 and document.get('minimumAcceptedMs') == 100,
            'Unexpected rounds or minimum accepted batch interval')
    rows = []
    for case in cases:
        original = originals[case['id']]
        require(all(case.get(key) == original[key] for key in ('family', 'sourceGroup', 'point')),
                'Changed native45 workload/grouping: ' + case['id'])
        summary, eligible = case['summary'], original['point']['ratioEligible']
        require(case.get('status') == 'complete' and summary.get('admitted') is True
                and summary.get('complete') is True and summary.get('ratioEligible') is eligible,
                'Unadmitted case: ' + case['id'])
        samples = case['samples']
        require(len(samples) == 3 * rounds and
                {(sample['role'], sample['round']) for sample in samples} ==
                {(role, index) for role in ROLES for index in range(rounds)}, 'Incomplete/duplicate timed rounds')
        stats, repetitions = {}, {}
        for role in ROLES:
            calibration = case['calibration'][role]
            count = calibration['repetitions']
            require(calibration.get('complete') is True and type(count) is int and count > 0,
                    'Incomplete role calibration')
            values = []
            for sample in sorted((s for s in samples if s['role'] == role), key=lambda s: s['round']):
                elapsed = sample['elapsedMs']
                require(sample.get('stage') == 'timed' and sample.get('correct') is True
                        and not sample.get('error') and sample['repetitions'] == count
                        and sample.get('warmups') == original['point']['warmups']
                        and type(elapsed) is int and elapsed >= 0
                        and close(sample['metricMs'], elapsed / count), 'Invalid timed sample: ' + case['id'])
                require(not eligible or (elapsed >= 100 and sample.get('lowResolution') is False),
                        'Below-resolution timed case: ' + case['id'])
                values.append(1000.0 * elapsed / count)
            stats[role] = distribution(values)
            repetitions[role] = count
            require(close(summary['stats'][role]['medianMs'], stats[role]['medianUs'] / 1000),
                    'Recorded median differs from timed samples')
        ratios, winner = None, None
        if eligible:
            require(all(stats[role]['medianUs'] > 0 for role in ROLES), 'Nonpositive eligible median')
            ratios = {role: stats[role]['medianUs'] / stats[ROLES[0]]['medianUs'] for role in ROLES[1:]}
            ratios['envelope'] = min(ratios.values())
            winner = 'tie' if ratios['bend-qbe'] == ratios['bend-c'] else min(ROLES[1:], key=ratios.get)
            require(all(close(summary['ratios'][role], ratios[role]) for role in ROLES[1:])
                    and close(summary['bestBendEnvelope']['ratioToHandwrittenC'], ratios['envelope']),
                    'Recorded ratios differ from independently recomputed medians')
        else:
            require(summary.get('ratios') is None and summary.get('bestBendEnvelope') is None,
                    'Correctness-only case must not carry ratios')
        rows.append(dict(id=case['id'], family=case['family'], sourceGroup=case['sourceGroup'],
                         ratioEligible=eligible, rounds=rounds, repetitions=repetitions,
                         stats=stats, ratios=ratios, bestBend=winner))
    require(len([row for row in rows if row['ratioEligible']]) == 44
            and [row['id'] for row in rows if not row['ratioEligible']] == ['scalar-region-0'],
            'Exactly full44 timing plus scalar-region-0 correctness control required')
    return rows


def geomean(values):
    return math.exp(statistics.mean(math.log(value) for value in values))


def aggregate(rows):
    timed = [row for row in rows if row['ratioEligible']]
    answer = dict(timedCases=44, correctnessOnly=['scalar-region-0'], roles={},
                  bestBendCounts={'bend-qbe': 0, 'bend-c': 0, 'tie': 0},
                  fastestRoleCounts={**{role: 0 for role in ROLES}, 'tie': 0})
    for row in timed:
        answer['bestBendCounts'][row['bestBend']] += 1
        fastest = min(row['stats'][role]['medianUs'] for role in ROLES)
        winners = [role for role in ROLES if row['stats'][role]['medianUs'] == fastest]
        answer['fastestRoleCounts'][winners[0] if len(winners) == 1 else 'tie'] += 1
    for role in RATIOS:
        groups = {}
        for key in ('family', 'sourceGroup'):
            groups[key] = {}
            for row in timed:
                groups[key].setdefault(row[key], []).append(row['ratios'][role])
        family = {key: geomean(values) for key, values in sorted(groups['family'].items())}
        source = {key: geomean(values) for key, values in sorted(groups['sourceGroup'].items())}
        ordered = sorted(timed, key=lambda row: row['ratios'][role])
        values = [row['ratios'][role] for row in timed]
        answer['roles'][role] = dict(equalPointGeomean=geomean(values),
            equalFamilyGeomean=geomean(family.values()), equalSourceGeomean=geomean(source.values()),
            familyCount=len(family), sourceCount=len(source), families=family, sources=source,
            casesOver={str(limit): sum(value > limit for value in values) for limit in (1.1, 2, 10)},
            fasterThanC=sum(value < 1 for value in values),
            best=[dict(id=row['id'], ratio=row['ratios'][role]) for row in ordered[:5]],
            worst=[dict(id=row['id'], ratio=row['ratios'][role]) for row in reversed(ordered[-5:])])
    answer['envelopeScope'] = 'Post hoc per-case minimum of Bend medians; not a single backend configuration.'
    return answer


def write_csv(path, rows):
    fields = ['id', 'family', 'sourceGroup', 'ratioEligible', 'rounds']
    metrics = ('medianUs', 'minimumUs', 'maximumUs', 'madUs', 'rangePercent')
    fields += [role + '.' + key for role in ROLES for key in (*metrics, 'repetitions')]
    fields += ['qbeToC', 'bendCToC', 'envelopeToC', 'bestBend']
    with path.open('w', newline='') as output:
        writer = csv.DictWriter(output, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            flat = {key: row[key] for key in fields[:5]}
            for role in ROLES:
                flat.update({role + '.' + key: row['stats'][role][key] for key in metrics})
                flat[role + '.repetitions'] = row['repetitions'][role]
            if row['ratios'] is not None:
                flat.update(qbeToC=row['ratios']['bend-qbe'], bendCToC=row['ratios']['bend-c'],
                            envelopeToC=row['ratios']['envelope'], bestBend=row['bestBend'])
            writer.writerow(flat)


def write_markdown(path, rows, totals, source):
    text = ['# Native45 runtime comparison', '',
        'Source report: `' + source['file'] + '` (SHA256 `' + source['sha256'] + '`).', '',
        'All 45 cases admitted; aggregate uses 44 timed cases. `scalar-region-0` is correctness-only. '
        'Times are normalized in-program microseconds per invocation, including validation and success-count printing. '
        'Dispersion below is median absolute deviation (MAD), not a confidence interval. '
        'Ratios above 1 mean Bend is slower than handwritten C. This excludes acquisition/build time.', '',
        '| Backend | Point geomean | Equal-family geomean | Equal-source geomean | >1.1× | >2× | >10× |',
        '|---|---:|---:|---:|---:|---:|---:|']
    for role in RATIOS:
        row = totals['roles'][role]
        text.append('| ' + LABELS[role] + ' | ' + ' | '.join([
            *(f"{row[key]:.3f}×" for key in ('equalPointGeomean', 'equalFamilyGeomean', 'equalSourceGeomean')),
            *(str(row['casesOver'][key]) for key in ('1.1', '2', '10'))]) + ' |')
    text += ['', totals['envelopeScope'], '',
        'Best Bend backend counts: ' + ', '.join(f'{key} {value}' for key, value in totals['bestBendCounts'].items()) + '.',
        'Fastest among all three roles: ' + ', '.join(f'{key} {value}' for key, value in totals['fastestRoleCounts'].items()) + '.', '',
        'Weighting first averages log ratios within each family/source group, then weights groups equally. '
        f"The timed cohort has {totals['roles']['bend-qbe']['familyCount']} families and "
        f"{totals['roles']['bend-qbe']['sourceCount']} source groups.", '']
    for role in RATIOS:
        row = totals['roles'][role]
        text.append(f"{LABELS[role]}: lowest ratio `{row['best'][0]['id']}` {row['best'][0]['ratio']:.3f}×; "
                    f"highest `{row['worst'][0]['id']}` {row['worst'][0]['ratio']:.3f}×.")
    text += ['', 'Sorted by the best Bend envelope, slowest relative case first. Full min/max dispersion is in `cases.csv`.', '',
        '| Case | C µs ± MAD | QBE µs ± MAD | Bend C µs ± MAD | QBE/C | Bend C/C | Envelope/C |',
        '|---|---:|---:|---:|---:|---:|---:|']
    for row in sorted(rows, key=lambda row: row['ratios']['envelope'] if row['ratios'] else -1, reverse=True):
        times = [f"{row['stats'][role]['medianUs']:.4g} ± {row['stats'][role]['madUs']:.3g}" for role in ROLES]
        ratios = [f"{row['ratios'][role]:.3f}×" if row['ratios'] else '—' for role in RATIOS]
        text.append('| ' + row['id'] + ' | ' + ' | '.join(times + ratios) + ' |')
    path.write_text('\n'.join(text) + '\n')


def plot(out, rows, source_sha):
    # Keep font/config caches temporary; never install or mutate dependencies.
    old = os.environ.get('MPLCONFIGDIR')
    with tempfile.TemporaryDirectory(prefix='phase184-plot-', dir='/tmp') as config:
        os.environ['MPLCONFIGDIR'] = config
        try:
            import matplotlib
            matplotlib.use('Agg')
            import matplotlib.pyplot as plt
            from matplotlib.ticker import FuncFormatter
            matplotlib.rcParams['svg.hashsalt'] = source_sha
            timed = sorted((row for row in rows if row['ratioEligible']),
                           key=lambda row: row['ratios']['envelope'], reverse=True)
            figure, axis = plt.subplots(figsize=(13, 17.5))
            for i, row in enumerate(timed):
                axis.plot([row['ratios']['bend-qbe'], row['ratios']['bend-c']], [i, i],
                          color='#b8bdc5', linewidth=1, zorder=1)
            for role, marker, color in [('bend-qbe', 'o', '#b64a37'), ('bend-c', 's', '#236ba2')]:
                axis.scatter([row['ratios'][role] for row in timed], range(len(timed)),
                             label=LABELS[role], marker=marker, color=color, s=24, zorder=3)
            axis.axvline(1, color='#333333', linewidth=1.2, linestyle='--', label='Handwritten C = 1×')
            axis.set_xscale('log')
            axis.xaxis.set_major_formatter(FuncFormatter(lambda value, _: f'{value:g}×'))
            axis.set_yticks(range(len(timed)), [row['id'] for row in timed], fontsize=8)
            axis.invert_yaxis()
            axis.grid(axis='x', which='both', color='#dddddd', linewidth=.5)
            axis.set_axisbelow(True)
            axis.set_xlabel('Ratio of median normalized runtime to handwritten C (log scale)')
            axis.set_title('Native45: 44 admitted runtime cases\nSorted by best Bend envelope; lower is faster', pad=15)
            axis.legend(loc='lower right', fontsize=9)
            figure.text(.5, .015, 'Envelope ordering is post hoc, not one backend. Zero-work control excluded. '
                        'Validation/printing are included; build time is excluded.', ha='center', fontsize=8)
            figure.tight_layout(rect=(0, .025, 1, 1))
            figure.savefig(out / 'comparison.png', dpi=180, metadata={'Software': 'phase184/summarize.py'})
            figure.savefig(out / 'comparison.svg', metadata={'Date': None, 'Creator': 'phase184/summarize.py'})
            plt.close(figure)
            return matplotlib.__version__
        finally:
            if old is None:
                os.environ.pop('MPLCONFIGDIR', None)
            else:
                os.environ['MPLCONFIGDIR'] = old


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = fresh_output(args.out, ROOT)
    receipt = dict(kind='phase184-runtime-summary', version=1, complete=False, aggregate=None,
                   method=pin(__file__), helper=pin(ROOT / 'selfhost/tools/build/common.py'),
                   outputs=[], targetExecutions=False,
                   scope='Recorded timing metadata revalidated and summarized; no benchmark or oracle re-execution.')
    try:
        source, catalog_pin = pin(args.report), pin(CATALOG)
        receipt.update(source=source, catalog=catalog_pin)
        require(source['bytes'] <= 64 * 1024 * 1024, 'Runtime report exceeds 64 MiB bound')
        document = json.loads(args.report.read_text())
        rows = derive(document, json.loads(CATALOG.read_text()), catalog_pin)
        totals = aggregate(rows)
        write_csv(out / 'cases.csv', rows)
        write_markdown(out / 'summary.md', rows, totals, source)
        version = plot(out, rows, source['sha256'])
        require(pin(args.report) == source and pin(CATALOG) == catalog_pin, 'Analysis input changed while reading')
        receipt.update(complete=True, aggregate=totals, cases=rows, matplotlibVersion=version,
                       outputs=[pin(out / name) for name in ('cases.csv', 'summary.md', 'comparison.png', 'comparison.svg')])
    except (OSError, ValueError, KeyError, TypeError, ImportError) as error:
        receipt['error'] = str(error)
    write_json(out / 'report.json', receipt)
    print(json.dumps(dict(complete=receipt['complete'], report=pin(out / 'report.json'),
                         outputs=receipt['outputs'], error=receipt.get('error')), indent=2))
    return 0 if receipt['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
