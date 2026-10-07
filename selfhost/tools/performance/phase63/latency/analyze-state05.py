#!/usr/bin/env python3
"""Summarize already completed State05 clean, byte, and host-helper experiments."""
import hashlib
import json
import math
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'build/phase63'
OUT = ROOT.parent / 'implementation/phase63/evidence/state05-followups.json'


def identity(path):
    path = Path(path).resolve(strict=True)
    return dict(file=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def load(name):
    path = BUILD / name / 'report.json'
    value = json.loads(path.read_text())
    assert value['complete'] and value['pass'] and all(r['success'] for r in value['rows'])
    return value, identity(path)


screen, screen_id = load('state05-b2-latency/screen')
clocks = ['firstRequestMs', 'importApiAndFirstMs']
ratios = {}
for clock in clocks:
    def gm_ratio(reference):
        return math.exp(statistics.mean(math.log(s['candidate'][clock]['median'] /
                                                s[reference][clock]['median'])
                                        for s in screen['statistics'].values()))
    ratios[clock] = dict(candidateOverBaseline=gm_ratio('baseline'), candidateOverTS=gm_ratio('typescript'))
gate, gate_id = load('state05-b2-bytegate23')
hosts = []
for name in ['state05-host-shapes01/screen', 'state05-host-fast01/screen', 'state05-host-fastv2/confirm']:
    report, report_id = load(name)
    groups = {}
    for row in report['rows']:
        observation = row['observation']
        assert observation['diagnosticOnly'] and not observation['productionQualified']
        groups.setdefault(row['case'], {}).setdefault(row['role'], []).append(
            {k: observation[k] for k in clocks} | dict(sample=row['sample']))
    comparisons = []
    for case, roles in groups.items():
        baseline = roles['baseline']
        for role, samples in roles.items():
            if role == 'baseline':
                continue
            comparisons.append(dict(case=case, role=role, baseline=baseline, variant=samples,
                meanRatio={clock: statistics.mean(r[clock] for r in samples) /
                                 statistics.mean(r[clock] for r in baseline) for clock in clocks}))
    hosts.append(dict(report=report_id, workers=len(report['rows']), wallSeconds=report['wallSeconds'],
                      executionOrder=[{k:r[k] for k in ['case','role','sample']} for r in report['rows']],
                      comparisons=comparisons))

result = dict(kind='phase63-state05-followup-summary', dataOnly=True, targetExecuted=False,
    producer=identity(__file__),
    cleanB2=dict(report=screen_id, pass_=screen['pass'], workers=len(screen['rows']),
                 wallSeconds=screen['wallSeconds'], coverage=screen['coverage'],
                 statistics=screen['statistics'], geometricMeanRatios=ratios,
                 limitation='One fixed-order sample per role/input; two sources, not a broad headline.'),
    raw23=dict(report=gate_id, pass_=gate['pass'], workers=len(gate['rows']),
               wallSeconds=gate['wallSeconds'], coverage=gate['coverage'],
               limitation='Candidate-only byte equality; no fresh runtime execution or paired speed conclusion.'),
    hostVariants=hosts,
    hostLimitation='Same genuine State05 B2 API with only a recorded private graph-helper replacement. '
                   'Diagnostic, not production-qualified. Compare each variant with its own campaign baseline; '
                   'no TS role and no cross-campaign comparison.')
with OUT.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=identity(OUT), geometricMeanRatios=ratios,
                     hostRatios=[dict(report=h['report']['file'],
                                      ratios=[dict(case=c['case'], **c['meanRatio']) for c in h['comparisons']])
                                 for h in hosts])))
