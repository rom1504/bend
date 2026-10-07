#!/usr/bin/env python3
"""Reduce a completed scaling screen and render its observed first-request curves."""
import argparse
import hashlib
import json
from pathlib import Path


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def read(file):
    return json.loads(Path(file).read_text())


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('report', type=Path)
parser.add_argument('evidence', type=Path)
parser.add_argument('figures', type=Path)
args = parser.parse_args()
report = read(args.report)
assert report['complete'] and report['pass'] and not report['failures']
assert identity(report['plan']['file']) == report['plan']
plan = read(report['plan']['file'])
assert plan['roles'] == ['b2', 'typescript'] and plan['rounds'] == 1
assert plan['warmRequests'] == 0 and len(plan['cases']) == 8 and len(report['rows']) == 16
rows = []
for case in plan['cases']:
    assert identity(case['source']['file']) == {key: case['source'][key] for key in ['file', 'sha256']}
    entry = {key: case[key] for key in ['id', 'family', 'size', 'definitionCount', 'parameterWidth', 'source']}
    entry['roles'] = {}
    for role in plan['roles']:
        sample = next(x for x in report['rows'] if x['case'] == case['id'] and x['role'] == role)
        assert sample['success'] and sample['execution']['complete']
        assert identity(sample['result']['file']) == sample['result']
        obs = read(sample['result']['file'])
        assert obs == sample['observation'] and obs['complete'] and obs['pass']
        assert obs['source'] == case['source']
        assert identity(obs['output']['file']) == {key: obs['output'][key] for key in ['file', 'sha256']}
        assert len(obs['oracles']) == len(case['points']) == obs['freshRuntimeExecutions']
        for actual, expected in zip(obs['oracles'], case['points']):
            assert {key: actual[key] for key in expected} == expected
            assert actual['pass'] and actual['actual'] == expected['expected']
        entry['roles'][role] = {key: obs[key] for key in [
            'hostImportMs', 'apiLoadMs', 'firstRequestMs', 'importApiAndFirstMs',
            'freshRuntimeExecutions', 'output', 'maxRssKiB', 'preparation', 'image']}
        entry['roles'][role]['result'] = sample['result']
        entry['roles'][role]['exactOraclesPassed'] = len(obs['oracles'])
    for metric in ['firstRequestMs', 'importApiAndFirstMs']:
        entry[metric+'Ratio'] = entry['roles']['b2'][metric]/entry['roles']['typescript'][metric]
    rows.append(entry)
families = []
for family in ['independent-definitions', 'ordinary-telescope-width']:
    points = sorted([row for row in rows if row['family'] == family], key=lambda row: row['size'])
    low, high = points[0], points[-1]
    intervals = []
    for left, right in zip(points, points[1:]):
        intervals.append(dict(low=left['size'], high=right['size'], **{
            role+'MsPerUnit': (right['roles'][role]['firstRequestMs']-left['roles'][role]['firstRequestMs'])/(right['size']-left['size'])
            for role in plan['roles']}))
    deltas = {role: high['roles'][role]['firstRequestMs']-low['roles'][role]['firstRequestMs'] for role in plan['roles']}
    families.append(dict(family=family, firstSize=low['size'], lastSize=high['size'],
                         endpointFirstRequestDeltaMs=deltas,
                         endpointDeltaRatio=deltas['b2']/deltas['typescript'],
                         adjacentFirstRequestSlopes=intervals,
                         note='Whole-request endpoint difference; not an isolated operation cost or fitted complexity class.'))
evidence = dict(kind='phase62-synthetic-scaling-summary', complete=True, pass_=True,
                producer=identity(__file__), report=identity(args.report), plan=report['plan'],
                upstreamCommit=plan['upstreamCommit'], node=plan['node'],
                elapsedSeconds=report['elapsedSeconds'], freshProcesses=len(report['rows']),
                freshExactRuntimeChecks=sum(row['roles'][role]['exactOraclesPassed'] for row in rows for role in plan['roles']),
                cases=rows, families=families,
                limitations=['One fresh-process sample per case and compiler; no error bars or significance claim.',
                             'Prepared Base cache; not OS-cold execution or a steady-state benchmark.',
                             'Declaration counts also change parsing, checking, output and export costs.',
                             'Parameter width also changes balanced expression size, argument spines and wrappers.',
                             'U32 parameters do not isolate dependent-type substitution.',
                             'Numeric execution checks correctness only; generated-program speed was not measured.'])
evidence['pass'] = evidence.pop('pass_')
args.evidence.parent.mkdir(parents=True, exist_ok=True)
args.evidence.write_text(json.dumps(evidence, indent=2)+'\n')

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10, 'svg.fonttype': 'none'})
fig, axes = plt.subplots(1, 2, figsize=(11.6, 4.8), sharey=True)
colors = {'b2': '#2463a8', 'typescript': '#b45c17'}
for ax, family, title, xlabel in zip(axes,
        ['independent-definitions', 'ordinary-telescope-width'],
        ['Independent definitions', 'Width of eight functions + eight probes'],
        ['Definitions retained as exports', 'U32 parameters per wide function']):
    points = sorted([row for row in rows if row['family'] == family], key=lambda row: row['size'])
    for role in plan['roles']:
        ax.plot([row['size'] for row in points], [row['roles'][role]['firstRequestMs'] for row in points],
                marker='o', linewidth=2, color=colors[role], label='State08 B2' if role == 'b2' else 'Pinned TypeScript')
    for row in [points[0], points[-1]]:
        ax.annotate(f'{row["firstRequestMsRatio"]:.2f}× TS',
                    (row['size'], row['roles']['b2']['firstRequestMs']),
                    xytext=(0, 11), textcoords='offset points', ha='center', color=colors['b2'])
    ax.set_title(title, pad=12)
    ax.set_xlabel(xlabel)
    ax.set_ylim(0, 2130)
    ax.margins(x=.12)
    ax.grid(axis='y', alpha=.22)
    ax.spines[['top', 'right']].set_visible(False)
axes[0].set_ylabel('First compilation request (ms)')
axes[0].legend(frameon=False, loc='upper left')
fig.suptitle('More definitions and wider functions widen the observed compilation gap', fontsize=13, y=.98)
fig.text(.5, .03, 'One fresh process per point and role · prepared Base cache · import/API excluded · 1,488 exact runtime checks passed',
         ha='center', fontsize=9, color='#444444')
fig.subplots_adjust(left=.075, right=.98, bottom=.18, top=.84, wspace=.14)
args.figures.mkdir(parents=True, exist_ok=True)
for suffix in ['svg', 'png']:
    fig.savefig(args.figures/('scaling.'+suffix), dpi=160)
print(json.dumps({'evidence': identity(args.evidence), 'checks': evidence['freshExactRuntimeChecks'],
                  'figures': [identity(args.figures/('scaling.'+suffix)) for suffix in ['svg', 'png']]}))
