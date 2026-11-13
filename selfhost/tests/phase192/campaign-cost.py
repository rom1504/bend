#!/usr/bin/env python3
"""Read outer Phase192 guards, negative receipts and frozen source sizes; run no jobs."""
import argparse
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HELPER = ROOT/'selfhost/tests/phase191/campaign-cost.py'
spec = importlib.util.spec_from_file_location('phase191_cost', HELPER)
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
cost = prior.cost
CAMPAIGN = ROOT/'selfhost/build/phase192'
cost.CAMPAIGN = CAMPAIGN


def category(name, command):
    words = ' '.join(command)
    if 'qualification.py' in words or name.startswith('native64'):
        return 'native-qualification'
    if 'runtime-controls.py' in words or name.startswith('runtime10'):
        return 'native-runtime-controls'
    if 'compare-native-products.py' in words or 'compare-products.py' in words:
        return 'offline-product-comparison'
    if 'native-programs.py' in words or name.startswith('native45'):
        return 'native-catalog-acquisition'
    if 'native.py' in words:
        return 'native-reproduction' if any(x in name for x in ('self', 'reproduction')) else 'native-acquisition'
    if 'profile' in name:
        return 'profiling'
    if 'runtime-loop.py' in words or 'runtime' in name:
        return 'program-runtime'
    if 'api' in name or 'hosted.mjs acquire' in words:
        return 'checked-api-acquisition'
    if 'controls' in name or 'workers' in name or 'reentry' in name:
        return 'machine-controls'
    if 'emit-programs.mjs' in words or '-emit' in name:
        return 'hosted-emission'
    if 'build-programs.py' in words or '-build' in name:
        return 'machine-build'
    if 'source.py' in words:
        return 'source-assembly'
    if 'check' in name or 'source-diagnose' in words:
        return 'source-check'
    if 'diagnostic' in name or 'probe' in name:
        return 'diagnostic'
    return 'other'


cost.category = category


def diagnostic(path, limit=4096):
    if not path.is_file():
        return None
    data, identity = cost.capture(path)
    if path.read_bytes() != data:
        return dict(file=str(path), changing=True)
    return dict(identity=identity, excerpt=data[-limit:].decode('utf-8', errors='replace'),
                excerptTruncated=len(data) > limit)


def negative(row):
    item = dict(job=row['job'], category=row['category'], stage=row['stage'],
        guardReceipt=row.get('receipt'), returncode=row.get('returncode'),
        stoppedFor=row.get('stoppedFor'), error=row.get('error'),
        wallSeconds=row.get('wallSeconds'), peakTreeRssBytes=row.get('peakTreeRssBytes'),
        peakRunAllocatedBytes=row.get('peakRunAllocatedBytes'),
        meaning='Failed guarded attempt; not automatically a compiler counterexample or scientific rejection.')
    folder = CAMPAIGN/row['job']
    report = folder/'report.json'
    if report.is_file() and report.stat().st_size <= 8*1024**2:
        data, identity = cost.capture(report)
        if report.read_bytes() == data:
            value = json.loads(data)
            item['producerReport'] = identity
            item['producerStatus'] = {k: value[k] for k in ('kind', 'complete', 'passed', 'error', 'changedInputs') if k in value}
    details = []
    for path in [folder/'stderr', folder/'compiler.stderr', CAMPAIGN/(row['job']+'-guard')/'stderr.log']:
        value = diagnostic(path)
        if value and (value.get('changing') or value.get('identity', {}).get('bytes')):
            details.append(value)
    item['diagnostics'] = details
    return item


def pre_admission(path):
    if not path.is_file():
        return []
    data, identity = cost.capture(path)
    assert path.read_bytes() == data and len(data) <= 65536, 'Stable bounded admission log required'
    text = data.decode()
    assert 'Another compiler/benchmark job holds the execution lock' in text, 'Unknown pre-admission failure'
    return [dict(job='scoped-build01', attempt='pre-admission-lock-refusal', status='not-admitted',
        evidence=identity, diagnostic=text, measuredWallSeconds=None, measuredRssBytes=None,
        measuredAllocatedBytes=None, countedInGuardTotals=False,
        scope='Recorded lock refusal before guard admission. No process receipt or measured child duration exists for this attempt. A later admitted job would be a separate attempt.')]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--pre-admission-log', type=Path,
        default=ROOT/'implementation/phase192/pre-admission-scoped-build01.log')
    parser.add_argument('--require-finished', action='store_true', help='Refuse a final snapshot while any outer guard is incomplete')
    args = parser.parse_args()
    assert not args.out.exists() and args.out.suffix == '.json', 'Fresh JSON snapshot required'
    rows = cost.guards()
    for row in rows:
        row['stage'] = row['job'].split('-')[0].rstrip('0123456789') or row['job']
    incomplete = [r['job'] for r in rows if r['status'] == 'incomplete']
    assert not args.require_finished or not incomplete, 'Incomplete outer guards: '+', '.join(incomplete)
    before = prior.source_snapshot(ROOT/'selfhost/build/phase191/selected-source01')
    after = prior.source_snapshot(CAMPAIGN/'selected-source01')
    failed = [negative(r) for r in rows if r['status'] == 'failed']
    refused = pre_admission(args.pre_admission_log)
    result = dict(kind='phase192-offline-campaign-cost-and-negative-attempts', version=1,
        capturedUTC=datetime.now(timezone.utc).isoformat(), programsExecuted=False,
        method=cost.capture(Path(__file__))[1], helpers=[cost.capture(HELPER)[1], cost.capture(prior.HELPER)[1]],
        receiptDirectory=str(CAMPAIGN), finalGuardSetFinished=not incomplete,
        summary=cost.totals(rows), jobs=rows,
        byCategory={c: cost.totals([r for r in rows if r['category'] == c]) for c in sorted({r['category'] for r in rows})},
        byStage={s: cost.totals([r for r in rows if r['stage'] == s]) for s in sorted({r['stage'] for r in rows})},
        failedJobs=[r['job'] for r in failed], incompleteJobs=incomplete, negativeGuardedAttempts=failed,
        preAdmissionFailures=refused, preAdmissionFailureCount=len(refused),
        totalObservedAttempts=len(rows)+len(refused),
        sourceGrowth=dict(baseline=before, selected=after,
            deltaBytes=after['source']['bytes']-before['source']['bytes'],
            deltaLines=after['lines']-before['lines'],
            deltaMappedX86Declarations=after['mappedX86Declarations']-before['mappedX86Declarations'],
            deltaMappedX86SpanBytes=after['mappedX86SpanBytes']-before['mappedX86SpanBytes']),
        scope='Only top-level *-guard/process.json contributes measured cost. Nested compiler/assembler/linker/target subjobs are not summed again. Finished failures remain included; incomplete guards and pre-admission refusal are excluded from wall totals. RSS/allocated/filesystem-decrease are per-job maxima, never total consumption. Budgets are limits. Unguarded work and research elapsed time are not measured. Negative attempts preserve evidence, not inferred scientific rejection; successful screens may still be rejected by the campaign report. Frozen selected source/maps exclude unrelated dirty changes. No atomic campaign-close or installation claim.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(out=str(args.out), summary=result['summary'],
        preAdmissionFailureCount=len(refused), negativeGuardedAttempts=len(failed), incompleteJobs=incomplete,
        selectedSource=after['source'], sourceDeltaBytes=result['sourceGrowth']['deltaBytes'])))


if __name__ == '__main__':
    main()
