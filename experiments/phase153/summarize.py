#!/usr/bin/env python3
"""Offline Phase153 headroom accounting; no compiler or benchmark execution."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RUN = ROOT / 'selfhost/build/phase153'
OUT = ROOT / 'implementation/phase153/metrics.json'


def read(path):
    return json.loads(path.read_text())


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


stage_path = RUN / 'analysis01/summary.json'
attribute_path = RUN / 'attribution01/report.json'
events_path = RUN / 'events-attribution01/report.json'
stage, attr, events = map(read, [stage_path, attribute_path, events_path])
profile_path = Path(read(RUN / 'full01/capture/report.json')['rows'][0]['analysis']['file'])
profile = read(profile_path)
assert stage['complete'] and stage['quality']['usable_for_process_cpu_attribution']
assert attr['pairing']['verified'] and events['pairing']['verified'] and events['quality']['usableCounts']
n = stage['totalSamples']
assert sum(r['samples'] for r in profile['top_functions']) == n
physical = {r['name']: r['samples'] for r in profile['groups']}
register_direct = sum(r['samples'] for r in profile['top_functions'] if r['decoded'] == 'p111_set_regs')
register_libc = sum(r['samples'] for r in attr['matrix'] if r['callerSymbol'] == 'p111_set_regs')
assert register_libc == attr['coverage']['recoveredCallerSamples']
string_names = {'p113d_FID_$p118borrow.read.p88_string_eq_go',
                'p113d_FID_$p118borrow.read.index_hash',
                'p113d_FID_$p118borrow.read.String.cmp'}
strings = sum(r['samples'] for r in profile['top_functions'] if r['decoded'] in string_names)
rows = [('reclamation', physical['reclamation']), ('ownership_and_products', physical['ownership_and_products']),
        ('allocation', physical['allocation']), ('register_copy_including_recovered_libc', register_direct + register_libc),
        ('selected_string_equality_hash_compare', strings), ('scheduler', physical['scheduler'])]
assert sum(v for _, v in rows) <= n
stages = {r['label']: r for r in stage['rankedExclusiveStages']}
backend_names = ['raw generic/private lowering', 'initial optimizer', 'render/output and teardown until milestone exit']
backend = sum(stages[k]['threadCpuSeconds'] for k in backend_names)
front_names = ['parse/load', 'checking/publication', 'annotation/reach', 'erasure/finalization']
front = sum(stages[k]['threadCpuSeconds'] for k in front_names)
checking = stages['checking/publication']
ordered_path = RUN / 'attribution01/events.jsonl'
ordered = [json.loads(line) for line in ordered_path.read_text().splitlines()]
assert len(ordered) == n
checking_samples = ordered[checking['sampleStartInclusive']:checking['sampleEndExclusive']]
assert len(checking_samples) == checking['samples']
book_final = sum(((r.get('dispatchContext') or {}).get('loweredOwner') or '').startswith('book_final_') for r in checking_samples)
cold = read(ROOT / 'implementation/phase152/metrics.json')['coldNative']['rows'][-1]['wallSeconds']
result = dict(kind='phase153-headroom', version=1, sourceCommit='0a16bb7',
    inputs=[pin(Path(__file__)), pin(stage_path), pin(attribute_path), pin(events_path), pin(profile_path), pin(ordered_path)],
    profile=dict(wallSeconds=stage['diagnosticWallSeconds'], stagedThreadCpuSeconds=stage['stagedThreadCpuSeconds'],
                 samples=n, quality=stage['quality'], stageRows=[{k:r[k] for k in ['label','threadCpuSeconds','samples','quantitativeProfileAdmitted']}
                 for r in stage['rankedExclusiveStages']]),
    disjointPhysicalCategories=[dict(category=k,samples=v,fraction=v/n)for k,v in rows],
    physicalInterpretation='Disjoint sampled-PC buckets, not independent causal savings. They overlap stage/owner attribution. Register libc samples are recovered through the exact CFI table.',
    backendRegion=dict(stages=backend_names,threadCpuSeconds=backend,diagnosticFraction=backend/stage['stagedThreadCpuSeconds']),
    frontendRegion=dict(stages=front_names,threadCpuSeconds=front),
    conditionalCeiling=dict(cleanBuildReferenceSeconds=cold, diagnosticBackendTwofoldSecondsSaved=backend/2,
                           approximateColdReductionIfSameSavingTransfers=(backend/2)/cold,
                           remainingColdSecondsIfSameSavingTransfers=cold-backend/2,
                           qualification='Arithmetic screening scenario; no implementation or measured speedup. Diagnostic and clean clocks differ; machine overlap and migration overhead remain.'),
    publication=dict(stageSeconds=checking['threadCpuSeconds'],bookFinalNamedSamples=book_final,
                     stageSamples=checking['samples'],diagnosticSamplePeriodSeconds=book_final*.032,
                     wholeColdImpossibleTotalEliminationFraction=checking['threadCpuSeconds']/cold,
                     scope='Named active-owner observations only; shared index/hash/reclamation are not causally assigned. Stage bound is a diagnostic-to-clean sizing screen.'),
    smallRequestEvents=dict(sourceBytes=8202,qbeBytes=1237299,totals=events['totals'],
                            topOwnersPerCounter=events['topOwnersPerCounter'],
                            scope='Fresh process including prepared Base loading, compilation, output and cleanup. Counts can reuse pooled cells; not live memory, malloc counts or full-source projections.'),
    changedProduction=False, selfBuilds=0, broadRuntimeCampaigns=0)
OUT.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(backendSeconds=backend,frontendSeconds=front,physicalCategories=result['disjointPhysicalCategories'],publication=result['publication'])))
