#!/usr/bin/env python3
"""Compare existing qualified four-role counter reports; never execute targets."""
import argparse
import hashlib
import json
from pathlib import Path

COUNTERS = ['heap_alloc', 'heap_alloc_miss', 'heap_free', 'rt_frame',
            'rt_keep', 'rt_sink', 'term_keep', 'term_sink', 'rfc_wrap', 'rt_op']


def pin(path):
    path = Path(path).resolve()
    digest, size = hashlib.sha256(), 0
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            digest.update(block)
            size += len(block)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def verify(row):
    if pin(row['file']) != row:
        raise ValueError('Changed pinned input: ' + row['file'])
    return Path(row['file'])


def delta(before, after):
    return dict(difference=after-before, ratio=after/before if before else None)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise ValueError('Fresh summary directory required')
    campaign = read(a.plan)
    if campaign.get('kind') != 'phase113-four-role-counter-plan':
        raise ValueError('Frozen four-role counter plan required')
    for row in campaign['inputs']:
        verify(row)
    inputs = [pin(__file__), pin(a.plan), *campaign['inputs']]
    roles, plans, common_meta, runtime_identity = {}, {}, None, None
    for role in campaign['roles']:
        label, report_path = role['name'], Path(role['report'])
        if label in roles:
            raise ValueError('Duplicate role')
        report = read(report_path)
        original = read(verify(role['plan']))
        copied = pin(report_path.parent/'plan.json')
        if any(copied[key] != role['plan'][key] for key in ['bytes', 'sha256']):
            raise ValueError('Executed plan differs from frozen role plan')
        if (report.get('kind') != 'phase112-diagnostic-batch' or
                not report.get('complete') or not report.get('control', {}).get('complete')):
            raise ValueError('Complete batch and independent counter control required: ' + label)
        for row in report['inputs']:
            verify(row)
        if campaign['runtimeManifest'] not in report['inputs']:
            raise ValueError('Role did not use the frozen additive diagnostic runtime')
        control = read(verify(report['control']['profile']))
        if not control.get('complete') or not control.get('independentCounterControl'):
            raise ValueError('Independent counter control profile missing')
        verify(report['runtimeObject'])
        identity = {key: report['runtimeObject'][key] for key in ['bytes', 'sha256']}
        if runtime_identity is not None and identity != runtime_identity:
            raise ValueError('Instrumented runtime object differs across roles')
        runtime_identity = identity
        expected_names = {row['name'] for row in original['cases']}
        if len(expected_names) != 6 or any(row['repetitions'] != 1 or row['warmups'] != 0
                                          for row in original['cases']):
            raise ValueError('Exact six-case 1/0 diagnostic policy required')
        cases = {}
        for row in report['cases']:
            if row['state'] != 'qualified' or row['name'] in cases:
                raise ValueError('Every diagnostic case must qualify exactly once')
            profile = read(verify(row['profile']))
            if (not profile.get('complete') or not profile.get('diagnosticOnly') or
                    row['counters'] != profile['counters']):
                raise ValueError('Qualified parser output differs from batch counters')
            for item in profile['inputs']:
                verify(item)
            meta = {key: profile['meta'][key] for key in ['version', 'sourceSha256', 'heapRc', 'abi']}
            if common_meta is not None and common_meta != meta:
                raise ValueError('Instrumentation metadata differs')
            common_meta = meta
            counts = {key: profile['counters'][key] for key in COUNTERS}
            if any(type(value) is not int or value < 0 for value in counts.values()):
                raise ValueError('Nonnegative complete counters required')
            cases[row['name']] = dict(counts=counts, profile=row['profile'])
            inputs.append(row['profile'])
        if set(cases) != expected_names:
            raise ValueError('Qualified case membership differs from plan')
        roles[label], plans[label] = cases, original
        inputs += [pin(report_path), copied, report['runtimeObject'], report['control']['profile']]
    if set(roles) != {'facts-n2', 'scalar08', 'enhanced09', 'products11'}:
        raise ValueError('All four frozen roles required')
    baseline = plans['facts-n2']
    per_case = {}
    for case in baseline['cases']:
        name = case['name']
        for label, plan in plans.items():
            if plan['benchmarkManifest'] != baseline['benchmarkManifest']:
                raise ValueError('Benchmark manifest mismatch')
            current = next(row for row in plan['cases'] if row['name'] == name)
            if any(current[key] != case[key] for key in
                   ['source', 'oracle', 'runtimeArgs', 'expected', 'repetitions', 'warmups']):
                raise ValueError('Case semantics differ across roles')
        counts = {label: cases[name]['counts'] for label, cases in roles.items()}
        per_case[name] = dict(counts=counts, relativeToFactsN2={
            label: {key: delta(counts['facts-n2'][key], values[key]) for key in COUNTERS}
            for label, values in counts.items()})
    caveats = [
        'Counts are source-level helper invocations, not CPU shares, speedups or disjoint costs.',
        'heap_alloc counts calls into the actual allocator helper, including reused storage; it is not an OS allocation or byte count.',
        'rt_keep/rt_sink count generic entry calls; term_keep/term_sink count the underlying ownership helpers.',
        'Bypassed generic rt_op calls do not mean logical array operations disappeared.',
        'FID attribution follows dispatcher context; direct callee identities are not inferred.',
        'Each wrapper evaluates its workload once for initial output and once for its sole repetition; setup/readback is included.',
        'A zero baseline counter has no multiplicative ratio; absolute differences remain defined.',
        'Profiles are whole compiler snapshots; a difference is not attributed to one pass without separate evidence.']
    result = dict(kind='phase113-four-role-counter-summary', complete=True, targetsRun=False,
        diagnosticNotTiming=True, inputs=list({row['file']: row for row in inputs}.values()),
        runtimeManifest=campaign['runtimeManifest'], runtimeObjectIdentity=runtime_identity,
        counterNames=COUNTERS, perCase=per_case, caveats=caveats)
    a.out.mkdir(parents=True)
    (a.out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    lines = ['# Four-role counter comparison', '', 'Counts only; instrumented clocks are excluded.', '',
             '| Case | Role | heap_alloc | rt_frame | rt_keep | rt_sink | term_keep | term_sink |',
             '|---|---|---:|---:|---:|---:|---:|---:|']
    shown = ['heap_alloc', 'rt_frame', 'rt_keep', 'rt_sink', 'term_keep', 'term_sink']
    for name, case in per_case.items():
        for label, counts in case['counts'].items():
            lines.append('| '+name+' | '+label+' | '+' | '.join(f'{counts[key]:,}' for key in shown)+' |')
    lines += ['', *['- '+text for text in caveats], '',
              'Exact counts, absolute differences, defined ratios and input pins: [report.json](report.json).', '']
    (a.out/'README.md').write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True, targetsRun=False, report=str(a.out/'report.json'))))


if __name__ == '__main__':
    main()
