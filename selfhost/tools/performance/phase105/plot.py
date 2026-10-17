#!/usr/bin/env python3
"""Render completed Phase105 compiler-process measurements; execute no targets."""
import argparse
import hashlib
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

ROOT = Path(__file__).resolve().parents[4]
COLORS = {'b1': '#167D8D', 'b2': '#E1812C', 'upstream': '#666666'}
LABELS = {'b1': 'Native B1', 'b2': 'Native B2', 'upstream': 'Upstream TS/Bun'}


def load(root, name):
    path = root / 'selfhost/build/phase105' / name / 'report.json'
    raw = path.read_bytes()
    report = json.loads(raw)
    assert report['kind'] == 'phase105-current-native-upstream-compilation', path
    assert report['complete'] and report['passed'] and report['inputsUnchanged'], path
    assert not report['checkOnly'] and report['rows'], path
    return report, {'file': str(path), 'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)}


def decorate_ratios(ax, rows):
    positions = list(range(len(rows)))
    for offset, role in [(-0.18, 'b1'), (0.18, 'b2')]:
        values = [row['ratios'][role + '/upstream'] for row in rows]
        assert all(value > 0 for value in values)
        bars = ax.barh([y + offset for y in positions], values, height=0.32,
                       color=COLORS[role], label=LABELS[role])
        ax.bar_label(bars, labels=[f'{value:.2f}×' for value in values], padding=4, fontsize=9)
    ax.set_yticks(positions, [row['label'] for row in rows])
    ax.invert_yaxis()
    ax.axvline(1, color='#333333', linestyle='--', linewidth=1)
    ax.set_xlim(0, max(1, max(row['ratios'][role + '/upstream']
                            for row in rows for role in ['b1', 'b2'])) * 1.22)
    ax.set_xlabel('Time / upstream time · lower is faster · 1 = parity')
    ax.grid(axis='x', alpha=0.18)
    ax.set_axisbelow(True)
    for side in ['top', 'right']: ax.spines[side].set_visible(False)


def save_figure(fig, out, name, footnote):
    fig.text(0.015, 0.015, footnote, fontsize=8, color='#444444', va='bottom')
    fig.tight_layout(rect=(0, 0.085, 1, 0.94))
    for suffix in ['svg', 'png']:
        fig.savefig(out / f'{name}.{suffix}', dpi=180, facecolor='white')
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--root', type=Path, default=ROOT, help='Repository root containing completed reports')
    parser.add_argument('--screen-details', action='store_true', help='Also plot the six individual screen cases')
    args = parser.parse_args()
    root, out = args.root.resolve(), args.out.resolve()
    reports, provenance = {}, []
    for name in ['screen01', 'broad01', 'self-prepared01', 'self-live01']:
        reports[name], item = load(root, name)
        provenance.append(item)
    first = reports['screen01']
    for report in reports.values():
        assert report['source']['sha256'] == first['source']['sha256']
        assert report['upstreamRevision'] == first['upstreamRevision']
        assert report['bun']['sha256'] == first['bun']['sha256']
        for stage in ['b1', 'b2']:
            assert report['stages'][stage]['binary']['sha256'] == first['stages'][stage]['binary']['sha256']
    out.mkdir(parents=True, exist_ok=True)
    plt.rcParams.update({'font.size': 10, 'font.family': 'DejaVu Sans', 'svg.fonttype': 'none'})
    ratio_rows = []
    for label, name, weighting in [
        ('Six-case screen', 'screen01', 'equalPointGeometricRatios'),
        ('45 points · equal point', 'broad01', 'equalPointGeometricRatios'),
        ('23 originals · equal source', 'broad01', 'equalOriginalGeometricRatios'),
    ]:
        for mode in ['prepared', 'live']:
            ratio_rows.append({'label': label + '\n' + ('Prepared Base' if mode == 'prepared' else 'Live Base'),
                               'ratios': reports[name]['summary'][mode][weighting]})
    self_rows = []
    for mode, name in [('prepared', 'self-prepared01'), ('live', 'self-live01')]:
        cases = reports[name]['summary'][mode]['cases']
        assert set(cases) == {'compiler'}
        self_rows.append({'mode': mode, 'roles': cases['compiler']['roles']})

    fig, axes = plt.subplots(1, 2, figsize=(14.5, 7.2), gridspec_kw={'width_ratios': [1.6, 1]})
    fig.suptitle('Native Bend compiler: compilation speed versus pinned upstream', fontsize=15, fontweight='bold')
    decorate_ratios(axes[0], ratio_rows)
    axes[0].set_title('Separate corpus summaries · geometric mean of case ratios', fontsize=11)
    axes[0].legend(loc='lower right', frameon=False)
    ax = axes[1]
    for index, role in enumerate(['b1', 'b2', 'upstream']):
        stats = [row['roles'][role]['processMs'] for row in self_rows]
        values = [item['median'] / 1000 for item in stats]
        errors = [[(item['median'] - item['min']) / 1000 for item in stats],
                  [(item['max'] - item['median']) / 1000 for item in stats]]
        bars = ax.bar([x + (index - 1) * 0.24 for x in range(2)], values, width=0.22,
                      color=COLORS[role], label=LABELS[role], yerr=errors, capsize=3)
        ax.bar_label(bars, labels=[f'{value:.1f}s\nn={item["samples"]}'
                                 for value, item in zip(values, stats)], padding=5, fontsize=9)
    ax.set_xticks([0, 1], ['Prepared Base', 'Live Base'])
    ax.set_ylabel('Compiler-process seconds · lower is faster')
    ax.set_title('Full compiler source · separate workload', fontsize=11)
    ax.set_ylim(0, max(row['roles'][role]['processMs']['max'] / 1000
                       for row in self_rows for role in COLORS) * 1.28)
    ax.grid(axis='y', alpha=0.18); ax.set_axisbelow(True)
    for side in ['top', 'right']: ax.spines[side].set_visible(False)
    ax.legend(handles=[Patch(color=COLORS[role], label=LABELS[role]) for role in COLORS],
              loc='upper left', frameon=False, fontsize=9)
    footnote = ('Fresh processes emitting C; includes preparation, output and exit. Clang and generated-program execution excluded.\n'
                'Prepared Base applies to native stages; upstream checks source Base in both modes. Bars use medians; self whiskers show observed min–max, not confidence intervals.')
    save_figure(fig, out, 'compilation-speed', footnote)

    if args.screen_details:
        fig, axes = plt.subplots(1, 2, figsize=(12, 7))
        fig.suptitle('Six-case compiler-process screen', fontsize=15, fontweight='bold')
        for ax, mode in zip(axes, ['prepared', 'live']):
            cases = first['summary'][mode]['cases']
            rows = [{'label': case['name'], 'ratios': cases[case['name']]['processRatios']}
                    for case in first['cases']]
            decorate_ratios(ax, rows)
            ax.set_title('Prepared Base' if mode == 'prepared' else 'Live Base')
            ax.legend(frameon=False)
        save_figure(fig, out, 'compilation-screen', footnote)
    (out / 'plot-data.json').write_text(json.dumps({
        'inputs': provenance, 'source': first['source'], 'upstreamRevision': first['upstreamRevision'],
        'ratioRows': ratio_rows, 'selfRows': self_rows,
        'scope': 'Fresh compiler-process time to C. No combined overall mean, Clang timing or generated-program runtime.'
    }, indent=2) + '\n')
    print(json.dumps({'complete': True, 'out': str(out), 'screenDetails': args.screen_details}))


if __name__ == '__main__': main()
