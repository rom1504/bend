#!/usr/bin/env python3
"""Summarize retained receipts and draw standalone figures; runs no benchmarks.

The latest *complete* measureNN is selected by number, never by its speed.
Historical inputs are recorded as pinned by their receipts, not requalified.
"""
import argparse
import hashlib
import json
import math
import os
import re
import statistics
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / 'selfhost/build/phase107'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def stats(samples):
    assert samples and all(math.isfinite(x) and x > 0 for x in samples)
    return dict(samplesSeconds=samples, medianSeconds=statistics.median(samples),
                minSeconds=min(samples), maxSeconds=max(samples), count=len(samples))


def geomean(values):
    return math.exp(statistics.mean(math.log(v) for v in values))


def receipt(path, successful=True):
    report = read(path)
    if successful:
        assert report['complete'] and report.get('passed', True) and not report.get('error'), path
    return report, dict(report=pin(path), kind=report.get('kind'),
        complete=report.get('complete'), passed=report.get('passed'),
        wallSeconds=report.get('wallSeconds'), inputPinsAsRecorded=report.get('inputs', []),
        scope=report.get('scope'), clockScope=report.get('clockScope'))


def backend(path):
    report, provenance = receipt(path)
    assert all(j['returncode'] == 0 for j in report['jobs'])
    artifact_pins = [p for p in report['inputs'] if '/artifacts' in p['file'] and p['file'].endswith('/report.json')]
    assert len(artifact_pins) == 1
    artifact_path = Path(artifact_pins[0]['file'])
    artifact_pin = pin(artifact_path)
    assert artifact_pin['sha256'] == artifact_pins[0]['sha256']
    artifacts = read(artifact_path)
    provenance.update(artifactReport=artifact_pin, pipeline=artifacts.get('pipeline'),
                      optimizer=artifacts.get('method'), api=artifacts.get('api'))
    table = []
    for name in sorted({r['name'] for r in report['runtimes']}):
        values = {}
        for budget in [0, 4096]:
            for target in ['c', 'cl', 'qbe']:
                rows = [r for r in report['runtimes'] if (r['name'], r['budget'], r['backend']) == (name, budget, target)]
                assert len({r['round'] for r in rows}) == len(rows) >= 2
                assert len({(tuple(r['args']), r['repeat'], r['expected']) for r in rows}) == 1
                value = stats([r['seconds'] for r in sorted(rows, key=lambda r: r['round'])])
                builds = [r for r in report['builds'] if (r['name'], r['budget'], r['backend']) == (name, budget, target)]
                assert len(builds) == 1
                value.update(args=rows[0]['args'], repeat=rows[0]['repeat'], expected=rows[0]['expected'],
                             buildObservation=builds[0])
                values[f'{budget}-{target}'] = value
        denominator = values['0-c']['medianSeconds']
        assert len({(tuple(v['args']), v['repeat'], v['expected']) for v in values.values()}) == 1
        for value in values.values():
            value['ratioToRawClang'] = value['medianSeconds'] / denominator
        old = next(r for r in report['summary'] if r['name'] == name)
        assert all(math.isclose(values[k]['medianSeconds'], v, rel_tol=1e-12) for k, v in old['seconds'].items())
        table.append(dict(name=name, variants=values))
    return dict(provenance=provenance, samples=table,
        geometricMeanRatioToRawClang={target: geomean(r['variants'][f'4096-{target}']['ratioToRawClang'] for r in table)
                                      for target in ['c', 'cl', 'qbe']},
        scope='Checked repeated generated-program process runtime; median per case. Baseline is '
        'the same workload in raw experimental IR emitted through C/Clang O2, NOT upstream Bend. '
        'Budget 4096 denotes this receipt\'s pipeline, which changes across screens. Build observations '
        'are single measurements, separate from the repeated runtime samples. Equal-case geometric '
        'mean is descriptive of this fixed small corpus, not representative language-wide parity.')


def source_latency(path, legacy):
    report, provenance = receipt(path)
    assert report['passed']
    pairs = report['pairs'] if legacy else report['comparisons']
    assert all(p['stdoutEqual'] if legacy else p['qbeEqual'] for p in pairs)
    baseline = 'legacy' if legacy else 'js'
    groups = []
    for original in report['summaries']:
        case = original['case']
        metric = original['metric'] if legacy else original['state']
        rows = [r for r in report['builds'] if r['case'] == case and (legacy or r['state'] == metric)]
        field = metric if legacy else 'wallSeconds'
        measurements = {engine: stats([r[field] for r in sorted(rows, key=lambda r: r['round'])
                                       if r['engine'] == engine]) for engine in [baseline, 'native']}
        assert all(math.isclose(v['medianSeconds'], original['medianSeconds'][k], rel_tol=1e-12)
                   for k, v in measurements.items())
        groups.append(dict(case=case, metric=metric, measurements=measurements,
            nativeRatio=measurements['native']['medianSeconds'] / measurements[baseline]['medianSeconds']))
    return dict(provenance=provenance, rows=groups,
        geometricMeanRatios={metric: geomean(r['nativeRatio'] for r in groups if r['metric'] == metric)
                             for metric in sorted({r['metric'] for r in groups})},
        sourcePins=list({r['source']['sha256']: r['source'] for r in report['builds']}.values()),
        scope=report['scope'], clockScope=report['clockScope'])


def kernels(path):
    report, provenance = receipt(path)
    assert report['passed'] and len(report['comparisons']) * 2 == len(report['jobs'])
    table = []
    for original in report['summary']:
        key = original['name'], original['policy'], original['format']
        samples = {host: stats([r['seconds'] for r in report['jobs']
                                if (r['name'], r['policy'], r['format'], r['host']) == (*key, host)])
                   for host in ['native', 'js']}
        assert all(math.isclose(v['medianSeconds'], original['median'][host], rel_tol=1e-12)
                   for host, v in samples.items())
        table.append(dict(name=key[0], policy=key[1], format=key[2], measurements=samples,
            nativeRatio=samples['native']['medianSeconds'] / samples['js']['medianSeconds']))
    return dict(provenance=provenance, rows=table, outputComparisons=report['comparisons'],
        scope=report['scope'] + ' Fresh-process request latency, not warmed throughput; '
        'no source parsing, object generation, linking or generated-program execution in this metric.')


def pipeline(path):
    report, provenance = receipt(path)
    assert report['passed'] and all(r['passed'] for r in report['rows'])
    table = []
    for original in report['summary']:
        measurements = {role: stats([r['seconds'] for r in report['timings']
                                     if r['name'] == original['name'] and r['role'] == role])
                        for role in ['checked', 'fast']}
        assert all(math.isclose(v['medianSeconds'], original['roles'][role]['medianSeconds'], rel_tol=1e-12)
                   for role, v in measurements.items())
        table.append(dict(name=original['name'], measurements=measurements,
                         fastOverChecked=measurements['fast']['medianSeconds'] / measurements['checked']['medianSeconds']))
    return dict(provenance=provenance, rows=table, counts=report['counts'],
                timingProtocol=report['timingProtocol'], scope=report['scope'],
                clockScope=report['clockScope'])


def draw(metrics, directory, preview=None):
    os.environ.setdefault('MPLCONFIGDIR', '/tmp/bend-phase107-matplotlib')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    plt.rcParams.update({'svg.hashsalt': 'phase107-metrics', 'font.size': 10,
                         'axes.spines.top': False, 'axes.spines.right': False})
    directory.mkdir(parents=True, exist_ok=True)
    if preview is not None:
        preview.mkdir(parents=True, exist_ok=True)
    paths = []
    def finish(fig, name):
        fig.tight_layout()
        path = directory / name
        fig.savefig(path, format='svg', metadata={'Date': None, 'Creator': 'Phase107 receipt summarizer'})
        if preview is not None:
            fig.savefig(preview / Path(name).with_suffix('.png'), dpi=130)
        plt.close(fig)
        paths.append(pin(path))
    latest = metrics['backendScreens'][metrics['latestBackendScreen']]
    rows = latest['samples']
    fig, ax = plt.subplots(figsize=(14, 5.5))
    for shift, (variant, label, color) in enumerate([
        ('0-qbe', 'Raw QBE', '#bdc3c7'), ('4096-qbe', 'Optimized QBE', '#167d9a'),
        ('4096-cl', 'Optimized Cranelift', '#b65c22')]):
        ax.bar([i + (shift - 1) * .24 for i in range(len(rows))],
               [r['variants'][variant]['ratioToRawClang'] for r in rows], .23, label=label, color=color)
    ax.axhline(1, color='#333333', linestyle='--', linewidth=1)
    ax.set_xticks(range(len(rows)), [r['name'] for r in rows], rotation=40, ha='right')
    ax.set_ylabel('Runtime / raw C-Clang O2 runtime (lower is faster)')
    ax.set_title(f"Generated programs: {metrics['latestBackendScreen']} / {latest['provenance']['pipeline']}\n"
                 'Same experimental workload baseline; NOT upstream Bend. Medians of repeated process runs.')
    ax.legend(loc='upper right')
    finish(fig, 'backend-runtime.svg')
    fig, axes = plt.subplots(1, 2, figsize=(12, 4.8))
    for ax, section, metric, baseline, label in [
        (axes[0], metrics['installedVsNativeSource'], 'sourceToExecutableSeconds', 'legacy', 'Installed native → C/Clang'),
        (axes[1], metrics['jsVsNativeSource'], 'cold', 'js', 'JS-hosted → QBE')]:
        chosen = [r for r in section['rows'] if r['metric'] == metric]
        for shift, engine, title, color in [(-.18, baseline, label, '#92999f'), (.18, 'native', 'Native → QBE', '#167d9a')]:
            vals = [r['measurements'][engine] for r in chosen]
            med = [r['medianSeconds'] * 1000 for r in vals]
            errors = [[(r['medianSeconds'] - r['minSeconds']) * 1000 for r in vals],
                      [(r['maxSeconds'] - r['medianSeconds']) * 1000 for r in vals]]
            ax.bar([i + shift for i in range(len(chosen))], med, .34, label=title,
                   color=color, yerr=errors, capsize=3)
        ax.set_xticks(range(len(chosen)), [r['case'] for r in chosen], rotation=15)
        ax.set_ylabel('Source-to-executable time (ms)')
        ax.legend(fontsize=8)
    axes[0].set_title('Installed compiler versus experimental native path\nCompiler-process wall sums; rebuilt objects')
    axes[1].set_title('Same QBE output, different frontend hosting\nComplete driver wall; fresh object cache')
    finish(fig, 'source-to-executable.svg')
    fig, axes = plt.subplots(1, 2, figsize=(10, 4.5))
    for ax, fmt in zip(axes, ['json', 'qbe']):
        chosen = [next(r for r in metrics['identicalKernel']['rows']
                       if r['name'] == 'many' and r['policy'] == policy and r['format'] == fmt)
                  for policy in ['raw', 'pure', 'memory']]
        for shift, host, color in [(-.18, 'js', '#92999f'), (.18, 'native', '#167d9a')]:
            vals = [r['measurements'][host] for r in chosen]
            ax.bar([i + shift for i in range(3)], [r['medianSeconds'] for r in vals], .34,
                   label=host, color=color)
        ax.set_xticks(range(3), ['raw', 'pure', 'memory'])
        ax.set_ylabel('Fresh-process request time (s)')
        ax.set_title(f'Identical 128-helper IR kernel → {fmt.upper()}')
        ax.legend()
    fig.suptitle('Construction, optimization, verification and emission only; byte-identical output', fontsize=11)
    finish(fig, 'identical-kernel.svg')
    if metrics.get('nativePipelineRequests'):
        reports = metrics['nativePipelineRequests']
        fig, axes = plt.subplots(2, len(reports), figsize=(11, 7), squeeze=False)
        for column, (name, report) in enumerate(reports.items()):
            chosen = [r for r in report['rows'] if r['name'] == 'many' and r['format'] == 'json']
            for row_index, host in enumerate(['native', 'js']):
                ax = axes[row_index][column]
                values = [r['measurements'][host] for r in chosen]
                medians = [r['medianSeconds'] * 1000 for r in values]
                errors = [[(r['medianSeconds'] - r['minSeconds']) * 1000 for r in values],
                          [(r['maxSeconds'] - r['medianSeconds']) * 1000 for r in values]]
                bars = ax.bar([r['policy'] for r in chosen], medians, yerr=errors, capsize=4,
                              color=['#92999f' if r['policy'] == 'checked' else
                                     '#167d9a' if r['policy'] == 'fast' else '#b65c22' for r in chosen])
                ax.bar_label(bars, labels=[f'{m:.2f}' for m in medians], padding=5)
                ax.set_ylim(0, max(r['maxSeconds'] * 1000 for r in values) * 1.22)
                ax.set_ylabel(f'{host.upper()} fresh request (ms)')
                ax.set_title(name + (' / original promotion' if name.endswith('02') else ' / promotion prefilter'))
        fig.suptitle('128-helper IR → JSON: three fresh processes per policy and host\n'
                     'Same image within each panel; different images between columns. No cross-metric gain multiplication.', fontsize=11)
        finish(fig, 'native-pipeline-requests.svg')
    if metrics.get('pipelineAudit'):
        rows = metrics['pipelineAudit']['rows']
        fig, ax = plt.subplots(figsize=(8, 4.5))
        bars = ax.bar([r['name'] for r in rows], [r['fastOverChecked'] for r in rows], color='#167d9a')
        ax.bar_label(bars, labels=[f"{r['fastOverChecked']:.3f}×" for r in rows], padding=4)
        ax.axhline(1, color='#333333', linestyle='--', linewidth=1)
        ax.set_ylim(0, 1.12)
        ax.set_ylabel('Fast pipeline / checked pipeline time')
        ax.set_title('Warm same-process optimization cost, six samples per policy\n'
                     'Excludes cloning, emission, startup and generated-program execution')
        finish(fig, 'pipeline-cost.svg')
    return paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT / 'implementation/phase107')
    parser.add_argument('--preview-dir', type=Path, help='Optional PNG previews outside the repository')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out == ROOT / 'implementation/phase107', 'only the owned report directory may be written'
    preview = args.preview_dir.resolve() if args.preview_dir else None
    assert preview is None or not preview.is_relative_to(ROOT), 'PNG previews must stay outside the repository'
    screens, excluded = {}, []
    paths = sorted(BUILD.glob('measure[0-9]*/report.json'),
                   key=lambda p: int(re.fullmatch(r'measure(\d+)', p.parent.name).group(1)))
    for path in paths:
        report = read(path)
        if report.get('complete') and not report.get('error'):
            screens[path.parent.name] = backend(path)
        else:
            excluded.append(dict(report=pin(path), reason='Incomplete or failed; never used in timing summaries'))
    assert screens
    result = dict(schema='phase107-metrics-v1', method=pin(__file__),
        latestBackendScreen=list(screens)[-1], backendScreens=screens, excludedScreens=excluded,
        installedVsNativeSource=source_latency(BUILD / 'legacy-latency02/report.json', True),
        jsVsNativeSource=source_latency(BUILD / 'native-latency02/report.json', False),
        identicalKernel=kernels(BUILD / 'kernel-measure01/report.json'),
        scope='Offline summary only. Ratios use the denominators named in each section; none is '
        'an upstream compiler parity claim. Samples are retained, medians recomputed and checked. '
        'Historical method/input hashes are preserved as recorded, not asserted to match evolving '
        'working-tree files. Screening differences are not statistical significance claims.')
    result['supplementalEvidence'] = [receipt(p, successful=False)[1]
        for pattern in ['*pipeline*/report.json', '*promotion*/report.json'] for p in sorted(BUILD.glob(pattern))]
    pipelines = [p for p in sorted(BUILD.glob('pipeline-audit*/report.json'))
                 if read(p).get('complete') and read(p).get('passed')]
    if pipelines:
        result['pipelineAudit'] = pipeline(pipelines[-1])
    result['nativePipelineRequests'] = {}
    for name in ['kernel-measure02', 'kernel-measure03']:
        path = BUILD / name / 'report.json'
        if path.exists() and read(path).get('complete') and read(path).get('passed'):
            section = kernels(path)
            section['withinImageComparisons'] = []
            for workload in sorted({r['name'] for r in section['rows']}):
                rows = {r['policy']: r for r in section['rows'] if r['name'] == workload and r['format'] == 'json'}
                for left, right in [('fast', 'checked'), ('promote', 'fast')]:
                    if left in rows and right in rows:
                        section['withinImageComparisons'].append(dict(name=workload, numerator=left, denominator=right,
                            ratios={host: rows[left]['measurements'][host]['medianSeconds'] /
                                    rows[right]['measurements'][host]['medianSeconds'] for host in ['native', 'js']}))
            section['scope'] += ' Output equality compares native versus JS for the same policy. '
            section['scope'] += 'Within-image policy ratios are separate from host ratios and from warm optimizer timings; gains are not multiplied.'
            result['nativePipelineRequests'][name] = section
    result['figures'] = draw(result, out / 'figures', preview)
    (out / 'metrics.json').write_text(json.dumps(result, indent=2) + '\n')
    latest = screens[result['latestBackendScreen']]
    lines = ['# Phase107 measured metrics', '', f"Backend screen: **{result['latestBackendScreen']}** "
             f"(`{latest['provenance']['pipeline']}`). Ratios are time ratios; lower is faster.", '',
             '**Runtime baseline: raw experimental IR → C/Clang O2, not upstream Bend.**', '',
             '| Workload | Optimized C / raw C | Optimized CL / raw C | Optimized QBE / raw C |',
             '| --- | ---: | ---: | ---: |']
    for row in latest['samples']:
        lines.append('| ' + row['name'] + ' | ' + ' | '.join(f"{row['variants'][f'4096-{b}']['ratioToRawClang']:.3f}×" for b in ['c', 'cl', 'qbe']) + ' |')
    lines += ['', '## Source-to-executable latency', '',
        'Installed native compiler → C/Clang versus experimental native frontend → QBE; '
        'three cases, rebuilt objects, prepared Base. Compiler-process wall sums exclude setup.', '',
        '| Case | Installed C/Clang, ms | Native QBE, ms | Native / installed |', '| --- | ---: | ---: | ---: |']
    for row in result['installedVsNativeSource']['rows']:
        if row['metric'] == 'sourceToExecutableSeconds':
            m = row['measurements']
            lines.append(f"| {row['case']} | {m['legacy']['medianSeconds']*1000:.2f} | {m['native']['medianSeconds']*1000:.2f} | {row['nativeRatio']:.3f}× |")
    lines += ['', '## Identical 128-helper kernel: fresh requests', '',
        'Same Bend IR construction/optimization/verification/emission; byte-identical output. '
        'Includes process startup. Excludes parsing source, object generation, linking and program runtime.', '',
        '| Policy | Format | JS, ms | Native, ms | Native / JS |', '| --- | --- | ---: | ---: | ---: |']
    for row in result['identicalKernel']['rows']:
        if row['name'] == 'many':
            m = row['measurements']
            lines.append(f"| {row['policy']} | {row['format']} | {m['js']['medianSeconds']*1000:.2f} | {m['native']['medianSeconds']*1000:.2f} | {row['nativeRatio']:.3f}× |")
    if result.get('pipelineAudit'):
        lines += ['', '## Warm optimization pipeline cost', '',
            result['pipelineAudit']['clockScope'] + ' These are optimizer timings, not generated-program speed gains.', '',
            '| Case | Checked, ms | Fast, ms | Fast / checked |', '| --- | ---: | ---: | ---: |']
        for row in result['pipelineAudit']['rows']:
            m = row['measurements']
            lines.append(f"| {row['name']} | {m['checked']['medianSeconds']*1000:.3f} | {m['fast']['medianSeconds']*1000:.3f} | {row['fastOverChecked']:.3f}× |")
    if result['nativePipelineRequests']:
        lines += ['', '## Fresh native pipeline requests', '',
            'The 128-helper kernel emits JSON. Each row has three fresh processes per host. '
            'Policies within each report use the same image; the two reports use different images. '
            'Native/JS equality is checked for each same-policy pair. These are complete kernel '
            'requests, not source compilation or generated-program execution, and are not multiplied '
            'with the warm optimizer or hosting gains above.', '',
            '| Report | Policy | Native, ms | JS, ms | Same-policy host pairs in report |',
            '| --- | --- | ---: | ---: | ---: |']
        for name, section in result['nativePipelineRequests'].items():
            for row in section['rows']:
                if row['name'] == 'many' and row['format'] == 'json':
                    m = row['measurements']
                    lines.append(f"| {name} | {row['policy']} | {m['native']['medianSeconds']*1000:.3f} | "
                                 f"{m['js']['medianSeconds']*1000:.3f} | {len(section['outputComparisons'])} |")
    lines += ['', 'All samples, ranges, recorded input hashes, report hashes and precise scopes are in '
              '[metrics.json](metrics.json). Figures are standalone SVGs in [figures/](figures/). '
              'Reproduce offline with `python3 -B selfhost/tools/performance/phase107/summarize.py`.', '']
    (out / 'metrics.md').write_text('\n'.join(lines))
    print(json.dumps(dict(latest=result['latestBackendScreen'], reports=len(screens), figures=result['figures'])))


if __name__ == '__main__':
    main()
