#!/usr/bin/env python3
"""Offline aggregation of reproducible native profiles and independent timings.

Small captures may be pooled only within an identical workload/variant identity.
Lost or incomplete captures stay in the report but contribute no CPU estimate.
"""
import argparse
import collections
import hashlib
import json
import math
from pathlib import Path
import re
import statistics


def pin(path):
    path = Path(path).resolve()
    sha = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            sha.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=sha.hexdigest())


class Reader:
    def __init__(self):
        self.identities = {}

    def verify(self, item):
        path = str(Path(item['file']).resolve())
        actual = self.identities.get(path)
        if actual is None:
            actual = pin(path)
            self.identities[path] = actual
        if any(actual[key] != item[key] for key in ('bytes', 'sha256')):
            raise ValueError('Changed evidence: ' + path)
        return Path(path)

    def read(self, item):
        return json.loads(self.verify(item).read_text())


def stats(values):
    return dict(samples=values, count=len(values), median=statistics.median(values) if values else None,
                minimum=min(values) if values else None, maximum=max(values) if values else None)


def timing(rows):
    return {field:stats([row[field] for row in rows])
            for field in ('wallSeconds', 'cpuSeconds', 'peakRssKiB')}


def capture_reasons(analysis):
    h, q = analysis['header'], analysis['quality']
    reasons = []
    for key in ('dropped', 'overruns'):
        if h.get(key, 0): reasons.append(key)
    for key in ('near_complete_process_cpu_coverage', 'thread_lifecycle_complete',
                'handler_intact', 'main_thread_shutdown', 'delivery_plausible'):
        if not q.get(key, False): reasons.append(key)
    if not isinstance(h.get('samples'), int) or h['samples'] < 0:
        raise ValueError('Invalid sample count')
    if not isinstance(h.get('period_us'), int) or h['period_us'] <= 0:
        raise ValueError('Invalid sampling period')
    # Deliberately ignore per-capture enough_samples: repeated short executions
    # are useful when their loss/coverage properties are independently sound.
    return reasons


def pool_captures(captures, clean_cpu_seconds=None, minimum_samples=500):
    tables = {name:collections.defaultdict(lambda: [0, 0])
              for name in ('functions', 'groups', 'categories')}
    metadata = {}
    total, weighted, unknown, unknown_weighted = 0, 0, 0, 0
    accepted, rejected, periods = [], [], collections.Counter()
    group_rules = None
    losses = collections.Counter()
    for capture in captures:
        analysis = capture['analysis']
        reasons = capture_reasons(analysis)
        item = dict(capture['identity'], samples=analysis['header']['samples'],
                    periodUs=analysis['header']['period_us'],
                    dropped=analysis['header'].get('dropped', 0),
                    overruns=analysis['header'].get('overruns', 0))
        process_ns = analysis['header'].get('process_cpu_ns')
        child_cpu = capture.get('childCpuSeconds')
        fraction = None
        if (isinstance(process_ns, (int, float)) and math.isfinite(process_ns) and process_ns >= 0
                and isinstance(child_cpu, (int, float)) and math.isfinite(child_cpu) and child_cpu > 0):
            fraction = process_ns / (child_cpu * 1e9)
        item['captureWindowChildCpuFraction'] = fraction
        item['wholeChildCpuCoverageAdequate'] = fraction is not None and 0.95 <= fraction <= 1.05
        losses.update({name:item[name] for name in ('dropped', 'overruns')})
        if reasons:
            rejected.append(dict(item, reasons=reasons))
            continue
        count, period = item['samples'], item['periodUs']
        current_rules = analysis.get('group_rules')
        if accepted and group_rules != current_rules:
            raise ValueError('Grouping rules changed within pooled captures')
        group_rules = current_rules
        for source in ('top_functions', 'groups', 'categories'):
            if any(not isinstance(row['samples'], int) or row['samples'] < 0
                   for row in analysis[source]):
                raise ValueError('Invalid histogram sample count: ' + source)
            if sum(row['samples'] for row in analysis[source]) != count:
                raise ValueError('Histogram denominator mismatch: ' + source)
        accepted.append(item); total += count; weighted += count * period
        unknown_count = analysis['quality'].get('unknown_samples', 0)
        if not isinstance(unknown_count, int) or not 0 <= unknown_count <= count:
            raise ValueError('Invalid unknown-sample count')
        unknown += unknown_count
        unknown_weighted += unknown_count * period
        periods[period] += count
        for row in analysis['top_functions']:
            # Executable paths differ across versions; source identities remain
            # comparable by decoded name. Library identities remain separate.
            obj = row.get('object')
            role = 'executable' if obj == analysis['header']['exe'] else obj or 'unmapped'
            key = (role, row['decoded'])
            metadata[key] = dict(object=role, name=row['name'], decoded=row['decoded'])
            tables['functions'][key][0] += row['samples']
            tables['functions'][key][1] += row['samples'] * period
        for name in ('groups', 'categories'):
            for row in analysis[name]:
                tables[name][row['name']][0] += row['samples']
                tables[name][row['name']][1] += row['samples'] * period
    adequate = total >= minimum_samples and bool(accepted)
    if clean_cpu_seconds is not None and (not math.isfinite(clean_cpu_seconds) or clean_cpu_seconds < 0):
        raise ValueError('Invalid clean CPU denominator')
    whole_child_covered = bool(accepted) and all(item['wholeChildCpuCoverageAdequate'] for item in accepted)
    estimate_available = adequate and clean_cpu_seconds is not None and whole_child_covered
    estimate_reasons = []
    if not adequate: estimate_reasons.append('Insufficient pooled samples')
    if clean_cpu_seconds is None: estimate_reasons.append('Independent clean CPU denominator unavailable')
    if not whole_child_covered:
        estimate_reasons.append('Capture CPU window does not establish 95% whole-child CPU coverage')

    def rows(name):
        result = []
        for key, (count, weight) in tables[name].items():
            item = dict(metadata[key]) if name == 'functions' else dict(name=key)
            item.update(samples=count, rawFraction=count / total if total else 0,
                        periodWeightedMicroseconds=weight,
                        periodWeightedFraction=weight / weighted if weighted else 0,
                        lowPrecision=count < 20)
            if estimate_available:
                item['estimatedCleanCpuSeconds'] = item['periodWeightedFraction'] * clean_cpu_seconds
            result.append(item)
        return sorted(result, key=lambda row: (-row['periodWeightedMicroseconds'], str(row)))

    return dict(acceptedCaptures=accepted, rejectedCaptures=rejected, samples=total,
        periodWeightedMicroseconds=weighted, sampleCountsByPeriodUs=dict(sorted(periods.items())),
        unknownSamples=unknown, unknownPeriodWeightedMicroseconds=unknown_weighted,
        captureLossTotals=dict(losses), minimumSamples=minimum_samples, adequate=adequate,
        cleanCpuSeconds=clean_cpu_seconds,
        wholeChildCpuCoverageAdequate=whole_child_covered,
        estimateAvailable=estimate_available, estimateUnavailableReasons=estimate_reasons,
        functions=rows('functions'), groups=rows('groups'), categories=rows('categories'),
        groupRules=group_rules,
        weighting='rawFraction pools counts; periodWeightedFraction weights each sample by its capture period. '
                  'Approximate CPU costs multiply period-weighted fractions by independent clean median CPU time.',
        limitations=['A sample count threshold is not a confidence interval.',
            'Repeated periods may alias; retain period-specific captures and compare them.',
            'Unknown samples remain in denominators. Rejected captures remain visible but are excluded.',
            'Fractions describe the captured interval. Absolute CPU estimates additionally require its process CPU to cover 95% of whole-child CPU; unavailable lifetime coverage preserves fractions only.',
            'Physical leaf costs do not identify logical callers or ownership origins.',
            'Diagnostic-runtime samples may distort the clean distribution even with an explicit baseline.'])


def event_totals(events):
    if events.get('schema') != 'bend-native-dispatch-events-v1' or not events.get('complete'):
        raise ValueError('Incomplete or unsupported event report')
    if events.get('counter_overflow') or events.get('invalid_context_events') or not events.get('counts_enabled'):
        raise ValueError('Invalid diagnostic counters')
    names = events['counter_names']
    if len(names) != len(set(names)):
        raise ValueError('Duplicate event names')
    totals = dict.fromkeys(names, 0)
    seen = set()
    for row in events['rows']:
        if row['fid'] in seen or len(row['counts']) != len(names):
            raise ValueError('Duplicate FID or malformed event row')
        seen.add(row['fid'])
        for key, value in zip(names, row['counts']):
            if not isinstance(value, int) or not 0 <= value < 2**64:
                raise ValueError('Invalid event count')
            totals[key] += value
    return totals


def _source_identity(variant, cwd):
    command = variant['command']
    arguments = command[1:]
    files = {item['file']:(item['bytes'], item['sha256']) for item in variant.get('inputs', [])}
    resolved = [str((Path(cwd)/arg).resolve()) for arg in arguments]
    argument_files = [(arg, files[arg]) for arg in resolved if arg in files]
    return dict(cwd=cwd, arguments=arguments, inputFiles=argument_files)


def _output_contract(expected):
    return {**expected, **{stream:{k:v for k,v in expected[stream].items() if k != 'file'}
                           for stream in ('stdout', 'stderr')}}


def _output_matches(path, expected):
    if expected['kind'] == 'exact':
        actual = pin(path)
        return all(actual[key] == expected[key] for key in ('bytes', 'sha256'))
    if expected['kind'] == 'prefix-integer-line':
        content = Path(path).read_bytes(); prefix = expected['prefix'].encode()
        return content.startswith(prefix) and re.fullmatch(rb'[0-9]+\n', content[len(prefix):]) is not None
    raise ValueError('Unknown output expectation')


def _delta(left, right, key, absolute=False):
    a = {key(row):row for row in left}
    b = {key(row):row for row in right}
    result = []
    for name in sorted(a.keys() | b.keys(), key=str):
        # Anonymous generated IDs have no stable cross-version identity.
        if '$p111.k.' in str(name): continue
        x, y = a.get(name, {}), b.get(name, {})
        row = dict(identity=name, rawFractionDelta=x.get('rawFraction', 0)-y.get('rawFraction', 0),
                   periodWeightedFractionDelta=x.get('periodWeightedFraction', 0)-y.get('periodWeightedFraction', 0),
                   variantSamples=x.get('samples', 0), referenceSamples=y.get('samples', 0))
        if absolute and (not x or 'estimatedCleanCpuSeconds' in x) and (not y or 'estimatedCleanCpuSeconds' in y):
            row['estimatedCpuSecondsDelta'] = x.get('estimatedCleanCpuSeconds', 0)-y.get('estimatedCleanCpuSeconds', 0)
        result.append(row)
    return sorted(result, key=lambda row: -abs(row.get('estimatedCpuSecondsDelta', row['periodWeightedFractionDelta'])))


def summarize_reports(paths, reference=None, *, baseline_variants=None, minimum_samples=500):
    if minimum_samples < 1: raise ValueError('minimum_samples must be positive')
    baseline_variants = baseline_variants or {}
    reader, groups, source_ids, records = Reader(), {}, {}, []
    seen_reports = set()
    for path in paths:
        report_pin = pin(path)
        if report_pin['sha256'] in seen_reports: raise ValueError('Duplicate run report')
        seen_reports.add(report_pin['sha256'])
        report = reader.read(report_pin)
        if report.get('schema') != 'bend-native-profile-run-v1' or not report.get('complete') or not report.get('passed'):
            raise ValueError('Completed correct-output run report required')
        if report.get('changedInputs'): raise ValueError('Run recorded changed inputs')
        manifest_path = Path(path).resolve().parent/'manifest.json'
        manifest_pin = pin(manifest_path)
        if not any(item.get('sha256') == manifest_pin['sha256'] and item.get('bytes') == manifest_pin['bytes']
                   for item in report['inputs']):
            raise ValueError('Manifest snapshot is not bound to run inputs')
        manifest = reader.read(manifest_pin)
        variants = {(w['name'],v['name']):v for w in manifest['workloads'] for v in w['variants']}
        records.append(dict(report=report_pin, manifest=manifest_pin,
            elapsedSeconds=report['finished']-report['started'], observations=len(report['rows']),
            childWallSeconds=sum(row['wallSeconds'] for row in report['rows']),
            childCpuSeconds=sum(row['cpuSeconds'] for row in report['rows'])))
        for row in report['rows']:
            if not row.get('correct'): raise ValueError('Incorrect observation in completed report')
            key = (row['workload'], row['variant'])
            variant = variants[key]
            if row['command'] != variant['command']: raise ValueError('Command differs from frozen variant')
            source_id = _source_identity(variant, manifest['cwd'])
            if row['workload'] in source_ids and source_ids[row['workload']] != source_id:
                raise ValueError('Same workload name has different source/arguments: ' + row['workload'])
            source_ids[row['workload']] = source_id
            identity = dict(source=source_id, binary={k:variant['binary'][k] for k in ('bytes','sha256')},
                            expected=_output_contract(variant['expected']), diagnostic=bool(variant.get('dispatchInstrumentation')))
            group = groups.setdefault(key, dict(identity=identity, rows=[], captures=[], events=[]))
            if group['identity'] != identity:
                raise ValueError('Same variant name has different binary/source/expectations: ' + str(key))
            reader.verify(variant['binary'])
            for item in variant.get('inputs', []): reader.verify(item)
            for stream in ('stdout', 'stderr'):
                output = reader.verify(row[stream])
                if not _output_matches(output, variant['expected'][stream]):
                    raise ValueError('Output differs from independent expectation')
            if row.get('returncode') != variant['expected'].get('exitCode', 0) or row.get('timedOut'):
                raise ValueError('Run status differs from independent expectation')
            group['rows'].append(row)
            if row['mode'] == 'sample':
                analysis = reader.read(row['analysis'])
                reader.verify(row['profile'])
                if analysis['identities']['capture']['sha256'] != row['profile']['sha256']:
                    raise ValueError('Analysis/capture mismatch')
                if analysis['identities']['binary']['sha256'] != variant['binary']['sha256']:
                    raise ValueError('Analysis/binary mismatch')
                group['captures'].append(dict(identity=row['analysis'], analysis=analysis,
                                              childCpuSeconds=row['cpuSeconds']))
            if 'events' in row:
                group['events'].append(event_totals(reader.read(row['events'])))
    result = dict(schema='bend-native-profile-comparison-v1', complete=True, method=pin(__file__),
        runs=records, reference=reference, baselineVariants=baseline_variants, workloads={}, comparisons=[])
    for (workload, variant), group in groups.items():
        rows = group['rows']
        clean = [r for r in rows if r['mode'] == 'clean' and not r.get('diagnosticRuntime', False)
                 and not group['identity']['diagnostic']]
        baseline_name = baseline_variants.get(variant, variant)
        baseline = groups.get((workload, baseline_name))
        baseline_rows = [] if not baseline else [r for r in baseline['rows'] if r['mode'] == 'clean'
            and not r.get('diagnosticRuntime', False) and not baseline['identity']['diagnostic']]
        if baseline and baseline_name != variant and baseline['identity']['expected'] != group['identity']['expected']:
            raise ValueError('Diagnostic baseline output contract differs')
        clean_cpu = statistics.median(r['cpuSeconds'] for r in baseline_rows) if baseline_rows else None
        sampled = [r for r in rows if r['mode'] == 'sample']
        diagnostics = [r for r in rows if r['mode'] != 'sample' and r not in clean]
        event_names = set().union(*(e.keys() for e in group['events']))
        if any(set(e) != event_names for e in group['events']): raise ValueError('Counter names changed within variant')
        summary = dict(identity=group['identity'], clean=timing(clean), diagnosticUnsampled=timing(diagnostics),
            sampled=timing(sampled), baselineVariant=baseline_name,
            profile=pool_captures(group['captures'], clean_cpu, minimum_samples),
            eventCounts={name:stats([e[name] for e in group['events']]) for name in sorted(event_names)},
            maximumChildRssKiB=max(r['peakRssKiB'] for r in rows))
        if baseline_rows:
            base_wall = statistics.median(r['wallSeconds'] for r in baseline_rows)
            summary['sampledOverCleanWallRatio'] = statistics.median(r['wallSeconds'] for r in sampled)/base_wall if sampled else None
            summary['diagnosticOverCleanWallRatio'] = statistics.median(r['wallSeconds'] for r in diagnostics)/base_wall if diagnostics else None
        result['workloads'].setdefault(workload, {})[variant] = summary
    if reference:
        for workload, variants in result['workloads'].items():
            if reference not in variants: continue
            ref = variants[reference]
            for variant, value in variants.items():
                if variant == reference: continue
                compare_profiles = bool(value['profile']['samples'] and ref['profile']['samples'])
                absolute = value['profile']['estimateAvailable'] and ref['profile']['estimateAvailable']
                delta = dict(workload=workload, variant=variant, reference=reference, cleanRatios={},
                    profileComparisonAdequate=value['profile']['adequate'] and ref['profile']['adequate'],
                    functionDeltas=_delta(value['profile']['functions'], ref['profile']['functions'],
                                         lambda row:(row['object'], row['decoded']), absolute) if compare_profiles else [],
                    categoryDeltas=_delta(value['profile']['categories'], ref['profile']['categories'], lambda row:row['name'], absolute) if compare_profiles else [],
                    groupDeltas=_delta(value['profile']['groups'], ref['profile']['groups'], lambda row:row['name'], absolute)
                        if compare_profiles and value['profile']['groupRules'] == ref['profile']['groupRules'] else [],
                    eventCountDeltas={})
                for field in ('wallSeconds','cpuSeconds','peakRssKiB'):
                    a, b = value['clean'][field]['median'], ref['clean'][field]['median']
                    if a is not None and b: delta['cleanRatios'][field] = a/b
                event_ref_name = reference
                if not ref['eventCounts']:
                    candidates = [name for name,v in variants.items() if v['eventCounts'] and baseline_variants.get(name) == reference]
                    if len(candidates) == 1: event_ref_name = candidates[0]
                event_ref = variants[event_ref_name]
                delta['eventReference'] = event_ref_name
                for name in value['eventCounts'].keys() & event_ref['eventCounts'].keys():
                    a, b = value['eventCounts'][name]['median'], event_ref['eventCounts'][name]['median']
                    delta['eventCountDeltas'][name] = dict(difference=a-b, ratio=a/b if b else None,
                                                          reference=b, variant=a)
                result['comparisons'].append(delta)
    result['evidence'] = list(reader.identities.values())
    result['limitations'] = ['No confidence intervals or causal speedup estimates are implied.',
        'Event counts overlap and are not CPU percentages or guaranteed machine memory traffic.',
        'Anonymous generated segment names are excluded from cross-version function deltas.',
        'Clean timings exclude diagnostic runtimes; explicit baseline mapping is required to scale their profiles.',
        'Complete run elapsed time includes harness analysis; summed child time is reported separately.']
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, action='append', required=True)
    parser.add_argument('--reference')
    parser.add_argument('--baseline', action='append', default=[], metavar='DIAGNOSTIC=CLEAN')
    parser.add_argument('--minimum-samples', type=int, default=500)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists(): parser.error('Fresh output path required')
    mappings = dict(item.split('=', 1) for item in args.baseline)
    result = summarize_reports(args.report, args.reference, baseline_variants=mappings,
                               minimum_samples=args.minimum_samples)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2, allow_nan=False); stream.write('\n')
    print(json.dumps(dict(complete=True, workloads=len(result['workloads']), comparisons=len(result['comparisons']))))


if __name__ == '__main__':
    main()
