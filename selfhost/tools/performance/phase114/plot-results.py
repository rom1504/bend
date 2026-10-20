#!/usr/bin/env python3
"""Summarize and plot one complete matched Phase114 campaign; no targets."""
import argparse
import csv
import hashlib
import io
import json
import math
import os
from pathlib import Path
import statistics

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
BROAD = HERE.parent / 'phase112/benchmark45'
DEFAULT_REPORT = ROOT / 'selfhost/build/phase112/p114-final-hosted45-runtime01/report.json'
ROLES = ['upstream', 'p113-final31-hosted', 'p114-final-hosted45']
UPSTREAM, BASELINE, FINAL = ROLES
PINS = {
    BROAD / 'manifest01.json': '80b07bdc76528bf58ae322ffed470eaa8ccdc8fa3d5cea73aa6d652d66cc6adc',
    BROAD / 'upstream-50ms-profile01.json': 'd32fa6cae73dee3932ff28a2257e4979c01dbe7612e30ffba9fdd929713b501e',
    HERE / 'bench/manifest01.json': 'cd8c7fb6a1f3f5579f966a0d0980ae8c3dbe8520403ce453fddd130d0d1ae5d1',
}


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def authenticate(row):
    actual = pin(ROOT / row['file'])
    if any(actual[key] != row[key] for key in ['bytes', 'sha256']):
        raise ValueError('changed report evidence: ' + actual['file'])
    return Path(actual['file'])


def geomean(values):
    return math.exp(statistics.mean(math.log(value) for value in values))


def summarize(report_path):
    inputs = [pin(report_path), pin(__file__)]
    documents = []
    for path, sha in PINS.items():
        row = pin(path)
        if row['sha256'] != sha:
            raise ValueError('frozen corpus/profile/screen changed: ' + str(path))
        inputs.append(row)
        documents.append(json.loads(path.read_text()))
    manifest, profile, screen = documents
    report = json.loads(report_path.read_text())
    required = ['complete', 'executionComplete', 'fullRequestedQualification',
                'fullMeasuredCorpus', 'fullCorpusOutputQualified']
    if report.get('kind') != 'phase112-matched-program-runtime' or not all(report.get(key) is True for key in required):
        raise ValueError('complete, fully qualified matched report required')
    if set(report['roles']) != set(ROLES) or len(report['roles']) != 3 or report['rounds'] != 3:
        raise ValueError('exact three roles and three rounds required')
    if report['cpuAffinity'] != [3] or report['acquisitionIncluded'] is not False:
        raise ValueError('one-CPU program-runtime campaign required')
    names = [case['name'] for case in manifest['cases']]
    cases = {case['name']: case for case in manifest['cases']}
    timed = [name for name in names if name != 'scalar-region-0']
    screen_names = screen['names']
    if len(cases) != 45 or len(timed) != 44 or len(set(screen_names)) != 8 or not set(screen_names) <= set(timed):
        raise ValueError('frozen 45/44/8 coverage mismatch')
    if screen['sourceManifest'] != pin(BROAD / 'manifest01.json') or screen['profile'] != pin(BROAD / 'upstream-50ms-profile01.json'):
        raise ValueError('screen is not bound to the frozen broad corpus/profile')
    for field in ['cases', 'requestedCorpusNames']:
        if len(report[field]) != 45 or set(report[field]) != set(names):
            raise ValueError('incomplete or duplicate corpus names: ' + field)
    if (report['requestedCorpusCount'] != 45 or report['ratioCaseCount'] != 44
            or len(report['ratioCaseNames']) != 44 or set(report['ratioCaseNames']) != set(timed)
            or set(report['perProgram']) != set(timed)
            or report['zeroWorkExclusions'] != manifest['zeroWorkExclusions']):
        raise ValueError('full timed corpus plus named zero-work control required')
    profile_pin = pin(BROAD / 'upstream-50ms-profile01.json')
    if report['timingProfile'] != profile_pin or report['qualifiedMinimumMs'] != profile['minimumMs']:
        raise ValueError('frozen timing profile required')
    if profile_pin not in report['inputs'] or pin(BROAD / 'manifest01.json') not in report['inputs']:
        raise ValueError('report missing frozen profile/corpus pins')
    records = {}
    for row in report['records']:
        key = (row['case'], row['role'], row['round'])
        if key in records or key[0] not in cases or key[1] not in ROLES or key[2] not in [1, 2, 3]:
            raise ValueError('unknown or duplicate observation')
        counts = profile['cases'][key[0]]
        if any(row[k] != counts[k] for k in ['repetitions', 'warmups']):
            raise ValueError('changed repetitions/warmups')
        if row.get('correct') is not True or row.get('qualified') is not True or row['exitCode'] != 0:
            raise ValueError('unqualified observation')
        eligible = key[0] != 'scalar-region-0'
        elapsed = row['elapsedMs']
        if (row['ratioEligible'] is not eligible or type(elapsed) is not int or elapsed < 0
                or (eligible and elapsed < profile['minimumMs'])):
            raise ValueError('invalid elapsed interval or zero-work classification')
        expected = (cases[key[0]]['expectedStdout'] + str(counts['warmups']) + '\n'
                    + str(counts['repetitions']) + '\n' + str(elapsed) + '\n').encode()
        if authenticate(row['stdout']).read_bytes() != expected or authenticate(row['stderr']).read_bytes():
            raise ValueError('complete output does not match frozen oracle: ' + key[0])
        records[key] = row
    if len(records) != 405:
        raise ValueError('all 405 observations required')
    for role in ROLES:
        coverage = report['coverage'][role]
        if (coverage['fullRequestedQualified'] is not True or coverage['qualifiedCount'] != 44
                or len(coverage['qualified']) != 44 or set(coverage['qualified']) != set(timed)):
            raise ValueError('incomplete per-role coverage')
    medians, samples, rows = {}, {}, []
    for name in names:
        samples[name] = {role: [records[name, role, rnd]['elapsedMs'] for rnd in [1, 2, 3]] for role in ROLES}
        medians[name] = {role: statistics.median(values) for role, values in samples[name].items()}
        values = medians[name]
        eligible = name in timed
        if eligible and (report['perProgram'][name]['samplesMs'] != samples[name]
                         or report['perProgram'][name]['mediansMs'] != values):
            raise ValueError('report medians disagree with observations')
        row = dict(program=name, family=cases[name]['family'], ratio_eligible=eligible,
                   frozen_screen=name in screen_names, upstream_ms=values[UPSTREAM],
                   phase113_ms=values[BASELINE], phase114_ms=values[FINAL],
                   phase113_upstream_ratio=values[BASELINE] / values[UPSTREAM] if eligible else '',
                   phase114_upstream_ratio=values[FINAL] / values[UPSTREAM] if eligible else '',
                   phase114_phase113_ratio=values[FINAL] / values[BASELINE] if eligible else '')
        for short, role in [('upstream', UPSTREAM), ('phase113', BASELINE), ('phase114', FINAL)]:
            row[short + '_samples_ms'] = ';'.join(map(str, samples[name][role]))
        rows.append(row)

    def group(selected):
        elapsed = {role: sum(sum(samples[name][role]) for name in selected) for role in ROLES}
        ratios = dict(phase113OverUpstream=geomean(medians[n][BASELINE] / medians[n][UPSTREAM] for n in selected),
                      phase114OverUpstream=geomean(medians[n][FINAL] / medians[n][UPSTREAM] for n in selected),
                      phase114OverPhase113=geomean(medians[n][FINAL] / medians[n][BASELINE] for n in selected))
        return dict(count=len(selected), geomeanRatios=ratios,
                    geomeanSpeedup=1 / ratios['phase114OverPhase113'],
                    geomeanTimeReductionPercent=100 * (1 - ratios['phase114OverPhase113']),
                    sameRunElapsedMs=elapsed,
                    summedElapsedPhase114OverPhase113=elapsed[FINAL] / elapsed[BASELINE])

    broad = group(timed)
    for role, field in [(BASELINE, 'phase113OverUpstream'), (FINAL, 'phase114OverUpstream')]:
        if not math.isclose(report['geomeanRatios']['upstream'][role], broad['geomeanRatios'][field], rel_tol=1e-12):
            raise ValueError('report geomean disagrees with observations')
    outside = [name for name in timed if name not in screen_names]
    if len(outside) != 36:
        raise ValueError('exactly 36 timed programs outside frozen screen required')
    summary = dict(kind='phase114-matched-broad-summary', version=1, complete=True,
        inputs=inputs, roles=ROLES, rounds=3, sourcePrograms=45, timingPoints=44,
        outputObservations=405, allOutputsPassed=True, broad=broad,
        frozenScreen=dict(**group(screen_names), names=screen_names),
        outsideFrozenScreen=dict(**group(outside), names=outside,
            scope='Previously seen historical workload coverage outside the frozen eight-program screen; not a blind holdout.'),
        zeroWorkControl=dict(name='scalar-region-0', samplesMs=samples['scalar-region-0'], ratios=None),
        medianComparisons=dict(faster=sum(medians[n][FINAL] < medians[n][BASELINE] for n in timed),
            equal=sum(medians[n][FINAL] == medians[n][BASELINE] for n in timed),
            slower=sum(medians[n][FINAL] > medians[n][BASELINE] for n in timed)),
        comparison='Three-round medians from one rotated, matched campaign. Ratios below one are faster. '
                   'Geomeans weight each program equally; summed elapsed ratio weights all measured batch milliseconds.',
        scope='Generated-program runtime and complete-output qualification only; compiler acquisition/builds excluded. '
              'No native compiler self-hosting qualification or confidence interval is inferred.')
    if pin(report_path) != inputs[0]:
        raise ValueError('report changed while summarizing')
    return rows, summary


def plot(rows, summary, path):
    os.environ.setdefault('MPLCONFIGDIR', '/tmp/phase114-matplotlib')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    timed = sorted((row for row in rows if row['ratio_eligible']), key=lambda row: row['phase114_upstream_ratio'])
    plt.rcParams.update({'font.size': 9, 'svg.hashsalt': 'phase114-results-v1'})
    fig, ax = plt.subplots(figsize=(11, 15))
    fig.subplots_adjust(left=.37, right=.97, top=.91, bottom=.09)
    for y, row in enumerate(timed):
        ax.plot([row['phase113_upstream_ratio'], row['phase114_upstream_ratio']], [y, y],
                color='#b5c1ca', linewidth=1.5, zorder=1)
    for field, color, label in [('phase113_upstream_ratio', '#b5662f', 'Phase113 final31'),
                               ('phase114_upstream_ratio', '#007d91', 'Phase114 selected')]:
        ax.scatter([row[field] for row in timed], range(44), s=26, color=color, label=label, zorder=2)
    ax.axvline(1, color='#353b40', linestyle='--', linewidth=1)
    ax.set_xscale('log')
    maximum = max(row[field] for row in timed for field in ['phase113_upstream_ratio', 'phase114_upstream_ratio'])
    minimum = min(1, *(row[field] for row in timed for field in ['phase113_upstream_ratio', 'phase114_upstream_ratio']))
    ticks = [x for x in [.1, .2, .5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000] if minimum * .85 <= x <= maximum * 1.15]
    ax.set_xlim(minimum * .85, maximum * 1.15)
    ax.set_xticks(ticks, labels=[f'{x:g}×' for x in ticks])
    ax.set_yticks(range(44), labels=[row['program'] + (' *' if row['frozen_screen'] else '') for row in timed])
    ax.set_ylim(-1, 44)
    ax.grid(axis='x', color='#e3e7e9', linewidth=.6)
    ax.set_axisbelow(True)
    ax.set_xlabel('Runtime / pinned upstream C program (log scale; lower is faster)')
    ax.legend(loc='lower right', frameon=False)
    for side in ['top', 'right', 'left']:
        ax.spines[side].set_visible(False)
    ax.tick_params(axis='y', length=0)
    ratios = summary['broad']['geomeanRatios']
    fig.suptitle('Direct QBE: Phase114 program runtime', x=.37, y=.966, ha='left', fontsize=16, fontweight='bold')
    fig.text(.37, .932, f"Geometric mean: {ratios['phase113OverUpstream']:.2f}× → {ratios['phase114OverUpstream']:.2f}× upstream runtime\n"
             f"Same-campaign median ratio (geomean), Phase114 / Phase113: {ratios['phase114OverPhase113']:.3f}", fontsize=10)
    fig.text(.03, .025, 'Three-round medians; all 45 programs pass. Zero-work control excluded from ratios. * Frozen eight-program screen.\n'
             'Other 36 points are previously seen historical workloads, not a blind holdout. No confidence interval is inferred.', fontsize=8)
    fig.savefig(path, format='svg', metadata={'Date': None, 'Creator': 'Phase114 plot-results.py / Matplotlib'})
    plt.close(fig)
    path.write_text('\n'.join(line.rstrip() for line in path.read_text().splitlines()) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, default=DEFAULT_REPORT)
    parser.add_argument('--out-dir', type=Path, default=ROOT / 'implementation/phase114')
    args = parser.parse_args()
    paths = [args.out_dir / name for name in ['broad-runtime.csv', 'broad-runtime.svg', 'results.json']]
    if any(path.exists() for path in paths):
        raise FileExistsError('Fresh result paths required; existing results are never overwritten')
    rows, summary = summarize(args.report.resolve())
    args.out_dir.mkdir(parents=True, exist_ok=True)
    buffer = io.StringIO(newline='')
    writer = csv.DictWriter(buffer, fieldnames=list(rows[0]))
    writer.writeheader()
    writer.writerows(rows)
    plot(rows, summary, paths[1])
    paths[0].write_text(buffer.getvalue())
    summary['artifacts'] = [pin(path) for path in paths[:2]]
    paths[2].write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(dict(outputs=[str(path) for path in paths], broad=summary['broad'],
                          outsideFrozenScreen=summary['outsideFrozenScreen']['geomeanRatios'])))


if __name__ == '__main__':
    main()
