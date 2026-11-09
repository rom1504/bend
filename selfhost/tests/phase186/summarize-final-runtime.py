#!/usr/bin/env python3
"""Render the completed five-role runtime evidence; no target execution."""
import argparse
import importlib.util
import inspect  # Load stdlib before bench's directory adds its inspect.py to sys.path.
import json
import math
import os
from pathlib import Path
import statistics
import tempfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p186_runtime_analysis', HERE / 'analyze-runtime.py')
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)


def family_rows(current):
    families = {}
    for case in current['cases']:
        if case['ratioEligible']:
            families.setdefault(case['family'], []).append(case)
    rows = []
    for family, cases in families.items():
        ratios = {role: A.gm(c['stats'][role]['medianMs'] / c['stats']['c']['medianMs']
                            for c in cases) for role in current['roles']}
        rows.append(dict(family=family, cases=len(cases), overC=ratios,
            newQbeOverOld=ratios['newqbe'] / ratios['oldqbe'],
            newX86OverOld=ratios['newx86'] / ratios['oldx86']))
    return rows


def plot_families(rows, directory, composite=False):
    with tempfile.TemporaryDirectory(prefix='p186-matplotlib-') as config:
        os.environ.setdefault('MPLCONFIGDIR', config)
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        from matplotlib.ticker import FuncFormatter, LogLocator
        plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 9,
                             'svg.fonttype': 'none', 'pdf.fonttype': 42})
        fig, axes = plt.subplots(1, 2, figsize=(12, max(6, len(rows) * .31 + 1.7)),
                                 sharey=True, layout='constrained')
        for ax, target, color in zip(axes, ('qbe', 'x86'), ('#0072B2', '#D55E00')):
            old = [r['overC']['old' + target] for r in rows]
            new = [r['overC']['new' + target] for r in rows]
            for i, (before, after) in enumerate(zip(old, new)):
                ax.plot([before, after], [i, i], color='#999999', lw=1.2, zorder=1)
            ax.scatter(old, range(len(rows)), s=34, facecolor='white', edgecolor='#666666',
                       label='Phase185 N2', zorder=2)
            ax.scatter(new, range(len(rows)), s=27, color=color, marker='s',
                       label='Phase186 N2', zorder=3)
            ax.axvline(1, color='#333333', lw=1, linestyle='--')
            ax.set_xscale('log', base=2)
            ax.xaxis.set_major_locator(LogLocator(base=2))
            ax.xaxis.set_major_formatter(FuncFormatter(lambda v, _: f'{v:g}×'))
            ax.grid(axis='x', color='#dddddd', linewidth=.6)
            ax.set_title('QBE' if target == 'qbe' else 'Assembly')
            ax.set_xlabel('Runtime / retained C (log scale; lower is better)')
            ax.legend(loc='best', fontsize=8)
        axes[0].set_yticks(range(len(rows)), [f"{r['family']} ({r['cases']})" for r in rows])
        axes[0].invert_yaxis()
        subtitle = ('Complete-case aggregate from immutable blocks; five rotated rounds per case'
                    if composite else 'Same-campaign geometric means; five rotated rounds')
        fig.suptitle('Phase186 native runtime by family\n' + subtitle,
                     fontsize=12)
        paths = []
        for suffix in ('svg', 'png', 'pdf'):
            path = directory / ('runtime-family-comparison.' + suffix)
            fig.savefig(path, dpi=180, metadata={'Creator': 'Phase186 retained-report analysis'})
            paths.append(path)
        plt.close(fig)
        return paths, matplotlib.__version__


def markdown(current, comparisons, families, report_pin, composition=None):
    totals = current['totals']
    lines = ['# Phase186 final native runtime', '',
        'The complete five-role campaign compares actual Phase185 and Phase186 N2 products with the same retained C products. '
        'All45 frozen catalog points execute;44 contribute timing ratios and one is a correctness-only control. '
        'Five serial rotated rounds balance execution positions. Ratios use per-role medians; no paired statistical significance is claimed.', '',
        '| Target | Old / C GM | New / C GM | New / old GM | Runtime reduction |',
        '|---|---:|---:|---:|---:|']
    for target, pair in zip(('qbe', 'x86'), comparisons):
        old, new = totals['old' + target], totals['new' + target]
        lines.append(f"| {'QBE' if target == 'qbe' else 'Assembly'} | {old['geomeanOverReference']:.6f} | "
            f"{new['geomeanOverReference']:.6f} | {pair['normalizedAfterOverBeforeGeomean']:.6f} | "
            f"{pair['timeReductionPercent']:+.2f}% |")
    lines += ['', 'Positive reductions mean less runtime. These are same-campaign target comparisons, not normalization against historical clocks.', '',
        '| Target | Equal-family GM old → new / C | Mean positive log deficit old → new | Cases >1.1× C old → new | Cases >2× C old → new |',
        '|---|---:|---:|---:|---:|']
    for target in ('qbe', 'x86'):
        old, new = totals['old' + target], totals['new' + target]
        lines.append(f"| {'QBE' if target == 'qbe' else 'Assembly'} | "
            f"{old['equalFamilyGeomeanOverReference']:.6f} → {new['equalFamilyGeomeanOverReference']:.6f} | "
            f"{old['meanPositiveLogDeficit']:.6f} → {new['meanPositiveLogDeficit']:.6f} | "
            f"{old['casesOver110']} → {new['casesOver110']} | {old['casesOver2']} → {new['casesOver2']} |")
    lines += ['', '![Family runtime ratios](runtime-family-comparison.png)', '',
        'Each family is the geometric mean of its timing-eligible points; counts appear in parentheses. '
        'The dashed line marks C parity. [SVG](runtime-family-comparison.svg) and [PDF](runtime-family-comparison.pdf) are retained for export.', '',
        '| Role | Projected fixed-catalog total (s) | Positive excess above C (s) |',
        '|---|---:|---:|']
    for role in current['roles']:
        row = totals[role]
        lines.append(f"| {role} | {row['fixedCatalogProjectedMs'] / 1000:.6f} | "
                     f"{row['fixedCatalogPositiveExcessMs'] / 1000:.6f} |")
    lines += ['', 'Fixed-catalog totals multiply per-invocation medians by original frozen repetition counts for the44 timing-eligible cases. '
        'They are projected work totals, not summed adaptive measurement time. Positive excess sums only cases slower than C.', '',
        '## Largest observed regressions', '',
        '| Target | Case | New / old | Runtime change | Target-role spread flag |',
        '|---|---|---:|---:|---|']
    cases = {c['id']: c for c in current['cases']}
    any_regression = False
    for target, pair in zip(('qbe', 'x86'), comparisons):
        regressions = [r for r in pair['worstRegressions'] if r['normalizedAfterOverBefore'] > 1][:5]
        for r in regressions:
            any_regression = True
            flagged = [role for role in ('old' + target, 'new' + target) if cases[r['id']]['stats'][role]['flagged']]
            lines.append(f"| {'QBE' if target == 'qbe' else 'Assembly'} | {r['id']} | "
                f"{r['normalizedAfterOverBefore']:.6f} | {-r['timeReductionPercent']:+.2f}% | {', '.join(flagged) or 'none'} |")
    if not any_regression:
        lines.append('| Both | No median regression observed | — | — | — |')
    lines += ['', 'Small differences are observations, not established regressions. Each target retains its own role-specific dispersion caveat.', '',
        '## Verification and dispersion', '',
        f"Revalidated {current['oracleRevalidated']['samples']} timed samples and {current['oracleRevalidated']['pilots']} pilots, "
        f"including exact output/count suffixes, executable identities, the frozen catalog, and {current['inputPinsVerified']} input pins. "
        'Per-case and aggregate summaries were independently recomputed. No observations were replaced or excluded.', '']
    flagged = [c for c in current['cases'] if c['flagged']]
    if flagged:
        lines += ['Max/min sample spread above10% triggers review; it does not automatically reject a case or establish its cause.', '',
                  '| Case | Flagged roles and max/min spread |', '|---|---|']
        for c in flagged:
            flags = [f"{role} {s['maxOverMin']:.3f}×" for role, s in c['stats'].items() if s['flagged']]
            lines.append(f"| {c['id']} | {', '.join(flags)} |")
        lines += ['', 'A C-only flag cautions new/C ratios; examine old/new target roles separately for same-campaign target effects. '
                  'Any targeted repeats belong in separate reports and do not rewrite this full45 campaign.']
    else:
        lines.append('No timing-eligible role exceeds10% max/min sample spread. This threshold check does not prove stability or significance.')
    lines += ['', f"Original report: `{report_pin['file']}` (SHA256 `{report_pin['sha256']}`). "
        'Exact per-workload ratios, pins, samples, family metrics and comparisons are in [runtime-analysis.json](runtime-analysis.json). '
        'The main phase README and original measurement report remain unchanged.', '']
    if composition:
        note = ('**Derived multi-block result:** the original run stopped at its deadline. '
                'This analytical view includes every complete case from that immutable report and whole-case reruns of its unfinished cases. '
                'No partial case observations are reused and no source report is relabeled complete. '
                'Each case retains five balanced rounds with all five roles measured together; blocks ran at separately recorded times.')
        lines[2:2] = [note, '']
        lines += ['Source blocks:', '']
        for part in composition['parts']:
            lines.append(f"- `{part['report']['file']}`: original complete={part['originalComplete']}; "
                         f"{len(part['includedCases'])} complete cases included; "
                         f"{len(part['discardedWholeCases'])} whole incomplete cases discarded.")
        lines.append('')
        lines = [line.replace('Original report:', 'Derived analytical view:') for line in lines]
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out-dir', type=Path, required=True)
    a = parser.parse_args()
    raw = A.B.read(a.report)
    # This gate intentionally precedes analysis and figure generation.
    A.B.require(raw.get('complete') is True, 'Wait for the complete five-role report')
    A.B.require(list(raw['roles']) == ['c', 'oldqbe', 'newqbe', 'oldx86', 'newx86']
                and raw['rounds'] == 5 and raw['positionBalanced'], 'Exact five-role/five-round campaign required')
    paths = [a.out_dir / n for n in ['runtime-analysis.json', 'runtime-summary.md',
        'runtime-family-comparison.svg', 'runtime-family-comparison.png', 'runtime-family-comparison.pdf']]
    A.B.require(all(not p.exists() for p in paths), 'Fresh summary artifacts required')
    current = A.analyze(a.report)
    catalog = A.B.catalog(A.ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json')
    A.B.require(current['caseCount'] == 45 and current['ratioEligibleCount'] == 44
                and {c['id'] for c in current['cases']} == {c['id'] for c in catalog['cases']}
                and current['oracleRevalidated']['samples'] == 1125,
                'Complete frozen45 catalog required')
    pairs = [A.compare(current, current, 'old' + t, 'new' + t, False) for t in ('qbe', 'x86')]
    families = family_rows(current)
    a.out_dir.mkdir(parents=True, exist_ok=True)
    composition = raw.get('composition') if raw.get('derivedComposite') else None
    figures, plotting_version = plot_families(families, a.out_dir, bool(composition))
    result = dict(kind='phase186-final-five-role-runtime-summary', programsExecuted=False,
        method=A.C.pin(__file__), analyzer=A.C.pin(HERE / 'analyze-runtime.py'), current=current,
        comparisons=pairs, families=families, derivedComposite=bool(composition), composition=composition,
        plotting=dict(tool='matplotlib', version=plotting_version),
        figures=[A.C.pin(p) for p in figures], roleMetadata={role: {k: v for k, v in metadata.items()
            if k != 'inputs'} for role, metadata in raw['roles'].items()})
    A.B.save(paths[0], result, fresh=True)
    paths[1].write_text(markdown(current, pairs, families, current['report'], composition))
    print(json.dumps(dict(summary=str(paths[1]), analysis=str(paths[0]),
        flaggedCases=current['flaggedCases'], comparisons=[dict(target=t,
        newOverOld=p['normalizedAfterOverBeforeGeomean']) for t, p in zip(('qbe', 'x86'), pairs)])))


if __name__ == '__main__':
    main()
