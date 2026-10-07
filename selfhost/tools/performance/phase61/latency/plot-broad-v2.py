#!/usr/bin/env python3
"""Plot a completed balanced 23-source summary; execute no compiler or workload."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def identity(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('summary', type=Path)
    parser.add_argument('out', type=Path)
    args = parser.parse_args()
    summary_pin = identity(args.summary)
    producer_pin = identity(__file__)
    summary = json.loads(args.summary.read_text())
    assert summary['kind'] == 'phase61-balanced-broad-analysis'
    assert summary['complete'] is True and summary['pass'] is True
    rows = summary['cases']
    assert len(rows) == len({r['id'] for r in rows}) == 23
    metrics = ['importApiAndFirstMs', 'firstRequestMs']
    ratio_keys = ['baselineOverTypescript', 'candidateOverTypescript', 'candidateOverBaseline']
    ratios = {}
    for metric in metrics:
        values = {key: [] for key in ratio_keys}
        for row in rows:
            medians = {}
            for role in ['baseline', 'candidate', 'typescript']:
                stat = row['roles'][role][metric]
                samples = stat['samples']
                assert isinstance(samples, list) and len(samples) == 3
                assert all(isinstance(x, (int, float)) and math.isfinite(x) and x > 0 for x in samples)
                median = stat['median']
                assert all(isinstance(stat[k], (int, float)) and math.isfinite(stat[k]) and stat[k] > 0 for k in ['min', 'median', 'max'])
                assert stat['min'] <= median <= stat['max']
                assert math.isclose(median, statistics.median(samples), rel_tol=1e-10, abs_tol=1e-12)
                assert stat['min'] == min(samples) and stat['max'] == max(samples)
                medians[role] = median
            expected = dict(baselineOverTypescript=medians['baseline'] / medians['typescript'],
                            candidateOverTypescript=medians['candidate'] / medians['typescript'],
                            candidateOverBaseline=medians['candidate'] / medians['baseline'])
            for key, value in expected.items():
                assert math.isclose(row['ratios'][metric][key], value, rel_tol=1e-10, abs_tol=1e-12)
                values[key].append(value)
        for key in ratio_keys:
            gm = math.exp(sum(math.log(v) for v in values[key]) / len(rows))
            assert math.isclose(summary['metrics'][metric]['geomeans'][key], gm, rel_tol=1e-10, abs_tol=1e-12)
            values[key].append(gm)
        ratios[metric] = values

    out = args.out.resolve()
    assert not out.exists(), out
    # The caller selects a fresh publication directory after the timing window.
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.ticker import FuncFormatter
    plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 9,
                         'svg.fonttype': 'none', 'svg.hashsalt': summary_pin['sha256']})
    labels = [r['id'] for r in rows] + ['Equal-source geometric mean']
    positions = list(range(len(labels)))
    fig, axes = plt.subplots(1, 2, figsize=(17, 11.5), sharey=True)
    titles = ['Import + API loading + first request', 'First request after imports and API loading']
    for ax, metric, title in zip(axes, metrics, titles):
        old = ratios[metric]['baselineOverTypescript']
        new = ratios[metric]['candidateOverTypescript']
        ax.set_xscale('log')
        ax.axvline(1, color='#444444', linewidth=1.2, linestyle='--', label='TypeScript = 1')
        for y, before, after in zip(positions, old, new):
            ax.plot([before, after], [y, y], color='#aeb8c0', linewidth=1.25, zorder=1)
        ax.scatter(old, positions, s=31, marker='s', color='#a16418', label='Baseline / TypeScript', zorder=3)
        ax.scatter(new, positions, s=35, marker='o', color='#156f9f', label='Candidate / TypeScript', zorder=4)
        ax.axhline(len(rows) - 0.5, color='#b8c0c8', linewidth=0.8)
        ax.scatter([old[-1]], [positions[-1]], s=70, marker='s', facecolors='none', edgecolors='#a16418', zorder=5)
        ax.scatter([new[-1]], [positions[-1]], s=75, marker='o', facecolors='none', edgecolors='#156f9f', zorder=5)
        lo, hi = min([1] + old + new), max([1] + old + new)
        ax.set_xlim(lo / 1.15, hi * 1.15)
        ax.set_ylim(len(labels) - 0.4, -0.7)
        ax.set_yticks(positions, labels)
        ax.xaxis.set_major_formatter(FuncFormatter(lambda x, _: f'{x:g}×'))
        ax.xaxis.set_minor_formatter(FuncFormatter(lambda x, _: f'{x:g}×' if x in [1.5, 2, 3, 4, 5] else ''))
        ax.grid(axis='x', which='both', color='#e3e7eb', linewidth=0.6)
        ax.set_title(title, fontsize=12, pad=30)
        ax.set_xlabel('Time relative to TypeScript (log scale; lower is faster)')
        for side in ['top', 'right', 'left']:
            ax.spines[side].set_visible(False)
        ax.tick_params(axis='y', length=0)
        ax.text(0.02, 1.012, f'GM: baseline {old[-1]:.3f}×; candidate {new[-1]:.3f}×', transform=ax.transAxes, fontsize=9)
    axes[0].legend(loc='upper center', bbox_to_anchor=(1.05, -0.065), ncol=3, frameon=False)
    fig.suptitle('Phase61: fresh-process compilation across all 23 sources', fontsize=16, y=0.988)
    fig.text(0.5, 0.022, 'Per-source medians from three balanced rounds per role. Medians only; no confidence intervals or steady-state claim.\n'
             'The geometric mean gives each source equal weight. Compiler-image identities and full observations remain in the bound summary.',
             ha='center', va='bottom', fontsize=9, color='#444444')
    fig.subplots_adjust(left=0.245, right=0.985, top=0.90, bottom=0.13, wspace=0.10)
    out.mkdir(parents=True)
    svg, png = out / 'broad-ratios.svg', out / 'broad-ratios.png'
    fig.savefig(svg, metadata={'Date': None, 'Creator': 'Phase61 plot-broad-v1.py'})
    fig.savefig(png, dpi=170, metadata={'Software': 'Phase61 plot-broad-v1.py'})
    plt.close(fig)
    assert identity(args.summary) == summary_pin and identity(__file__) == producer_pin
    receipt = dict(kind='phase61-balanced-broad-figures', complete=True, summary=summary_pin,
                   producer=producer_pin, images=summary['images'], figures=[identity(svg), identity(png)],
                   sources=23, roundsPerRole=3, metrics=metrics, weighting='one equal weight per source',
                   scope='Data-only rendering and arithmetic checks of the bound completed summary. No compiler/workload execution, fresh image qualification, confidence intervals or steady-state claim.')
    receipt['pass'] = True
    with (out / 'figures.json').open('x') as stream:
        json.dump(receipt, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, receipt=identity(out / 'figures.json'))))


if __name__ == '__main__':
    main()
