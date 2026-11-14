#!/usr/bin/env python3
"""Offline per-invocation display of maintained physical-profile comparisons."""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/profiler'))
import compare as C
import run as R

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--report', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
if a.out.exists():
    raise ValueError('Fresh output required')
plan = json.loads(a.plan.read_text())
manifest = json.loads(R.verify(plan['manifest']).read_text())
raw = json.loads(a.report.read_text())
if plan['manifest'] not in raw['inputs']:
    raise ValueError('Capture does not bind original plan manifest')
comparison = C.summarize_reports([a.report])  # Existing exact output/pin/quality verification.
if comparison['comparisons']:
    raise ValueError('Unequal-count roles must not have direct cross-role comparisons')
rows = []
for estimate in plan['estimates']:
    name, role, count = estimate['workload'], estimate['role'], estimate['repetitions']
    workload = next(w for w in manifest['workloads'] if w['name'] == name)
    variant, = workload['variants']
    arguments = variant['command']
    # Native calibrated wrappers pass repetitions/warmups after the --RTS marker.
    marker = arguments.index('--RTS')
    if (variant['name'] != role or variant['binary'] != estimate['binary']
            or arguments[marker+1:marker+3] != [str(count), str(estimate['warmups'])]):
        raise ValueError('Plan denominator/role differs from frozen command')
    value = comparison['workloads'][name][role]
    profile = value['profile']
    def scaled(items):
        return [dict(item, estimatedCpuMicrosecondsPerInvocation=(
            item['estimatedCleanCpuSeconds']*1e6/count if profile['estimateAvailable'] else None)) for item in items]
    row = dict(case=estimate['case'], role=role, repetitions=count, warmups=estimate['warmups'],
        cleanCpuMicrosecondsPerInvocation=value['clean']['cpuSeconds']['median']*1e6/count,
        pooledAdequate=profile['adequate'], estimateAvailable=profile['estimateAvailable'],
        samples=profile['samples'], sampleCountsByPeriodUs=profile['sampleCountsByPeriodUs'],
        rejectedCaptures=profile['rejectedCaptures'], unknownSamples=profile['unknownSamples'],
        unknownFraction=profile['unknownPeriodWeightedMicroseconds']/profile['periodWeightedMicroseconds'],
        loss=profile['captureLossTotals'], sampledOverCleanWallRatio=value['sampledOverCleanWallRatio'],
        functions=scaled(profile['functions']), groups=scaled(profile['groups']))
    rows.append(row)
    print(estimate['case'], role, 'CPU us/invocation', row['cleanCpuMicrosecondsPerInvocation'],
          'samples', row['samples'], 'adequate', row['pooledAdequate'], 'unknown', row['unknownFraction'])
R.save(a.out, dict(complete=True, targetsRun=False, method=C.pin(__file__), plan=C.pin(a.plan),
    report=C.pin(a.report), runProfilesUsable=raw['profilesUsable'], rows=rows,
    comparisonEvidence=comparison['evidence'],
    scope='Physical leaves divided by exact role repetition counts; startup, four warmups and output remain included. No dynamic call counts, inclusive source attribution, hardware counters or paired speedup claim.'))
