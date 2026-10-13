#!/usr/bin/env python3
"""Offline, complete-receipt-only Phase85 summaries. Never runs a target.

Use CPU0, e.g. taskset -c 0 python3 summarize.py --root-data RAW --out NEW.json.
Select --lanes explicitly for a scoped interim summary; missing/partial jobs fail.
"""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
import math
from pathlib import Path
import re
import statistics
import sys
from urllib.parse import unquote, urlparse

sys.dont_write_bytecode = True


def pin(file):
    file = Path(file).resolve(strict=True)
    digest, size = hashlib.sha256(), 0
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1048576), b''):
            digest.update(chunk)
            size += len(chunk)
    return dict(file=str(file), sha256=digest.hexdigest(), bytes=size)


def verify(item):
    actual = pin(item['file'])
    assert actual['sha256'] == item['sha256'], item['file']
    if 'bytes' in item:
        assert actual['bytes'] == item['bytes'], item['file']
    return actual


def stats(values):
    assert values and all(math.isfinite(x) and x >= 0 for x in values)
    return dict(count=len(values), median=statistics.median(values),
                minimum=min(values), maximum=max(values))


def geomean(values):
    assert values and all(x > 0 and math.isfinite(x) for x in values)
    return math.exp(sum(map(math.log, values))/len(values))


def frame_key(frame):
    return (frame.get('functionName', ''), frame.get('url', ''),
            frame.get('lineNumber', -1), frame.get('columnNumber', -1))


def classifier(role):
    def location(url):
        return unquote(urlparse(url).path) if url.startswith('file:') else url
    api = role.get('api', {}).get('file')
    runtime = role.get('runtime', {}).get('file')
    driver = role.get('driver', {}).get('file')
    upstream = {role.get(k, {}).get('file') for k in ['bend', 'compiler']}
    runtime_names = set()
    first_compiler_line = None
    if api:
        text = Path(api).read_text()
        boundary = text.find('function $jd$')
        if boundary >= 0:
            first_compiler_line = text.count('\n', 0, boundary)  # CPU line numbers are zero based.
            runtime_names = set(re.findall(r'\bfunction\s+([\w$]+)\s*\(', text[:boundary]))

    def classify(name, url='', line=-1):
        file = location(url)
        if url.startswith('node:inspector'):
            return 'profiler-protocol'
        if url.startswith('node:'):
            return 'node'
        if name in ['(garbage collector)', '(idle)', '(program)', '(root)']:
            return {'(garbage collector)': 'gc', '(idle)': 'idle', '(program)': 'program'}.get(name, 'other')
        if file == api:
            if name.startswith('$jd$'):
                return 'image-compiler'
            if name in runtime_names or (0 <= line < (first_compiler_line or 0)):
                return 'runtime'
            # Anonymous closures cannot be assigned to the runtime from names alone.
            if first_compiler_line is not None and line >= first_compiler_line:
                return 'image-compiler'
            return 'other'
        if runtime and file == runtime:
            return 'runtime'
        if driver and file == driver:
            return 'driver'
        if file and file in upstream:
            return 'upstream'
        if '/tools/' in file and file.endswith('.mjs'):
            return 'driver'
        return 'other'
    return classify


def clean_summary(rows):
    cases = defaultdict(lambda: defaultdict(list))
    for row in rows:
        job, report = row['job'], row['report']
        match = re.match(r'^[^-]+-(\d+)-', job['name'])
        cases[job['case']][job['role']].append(dict(
            job=job['name'], round=int(match[1]) if match else None,
            report=row['receipt'], importsMs=report['importsMs'],
            importsPlusFirstMs=report['importsMs']+report['calls'][0]['requestMs'],
            calls=[dict(call=c['call'], requestMs=c['requestMs'], sha256=c['sha256'],
                        **{k: c[k] for k in ['loadCheckMs', 'emitMs'] if k in c})
                   for c in report['calls']]))
    result = {}
    for case, roles in cases.items():
        result[case] = {}
        for role, runs in roles.items():
            calls = sorted({c['call'] for r in runs for c in r['calls']})
            assert all([c['call'] for c in r['calls']] == calls for r in runs)
            result[case][role] = dict(runs=runs,
                importsMs=stats([r['importsMs'] for r in runs]),
                importsPlusFirstMs=stats([r['importsPlusFirstMs'] for r in runs]),
                callMs={str(c): stats([r['calls'][c-1]['requestMs'] for r in runs]) for c in calls},
                lastVsFirst=[r['calls'][-1]['requestMs']/r['calls'][0]['requestMs'] for r in runs])
    ratios = {}
    for role in sorted({r for roles in result.values() for r in roles} - {'typescript'}):
        paired = {c: r for c, r in result.items() if role in r and 'typescript' in r}
        if not paired:
            continue
        fields = ['importsPlusFirstMs', *['call'+c for c in next(iter(paired.values()))[role]['callMs']]]
        ratios[role] = {}
        for field in fields:
            def value(row):
                return row['callMs'][field[4:]]['median'] if field.startswith('call') else row[field]['median']
            values = {c: value(r[role])/value(r['typescript']) for c, r in paired.items()}
            ratios[role][field] = dict(caseMedianRatios=values, equalCaseGeomean=geomean(list(values.values())))
    return dict(cases=result, ratiosToTypescript=ratios,
        weighting='Equal case geometric mean of same-lane per-role medians. Imports-plus-first is summed within each process before taking its median. Per-round samples remain visible; five calls share one process and are not five independent repetitions.')


JS_FUNCTION = re.compile(r'<JSFunction\s*(.*?)\s*\(sfi = (0x[0-9a-fA-F]+)\)>')
SHARED_FUNCTION = re.compile(r'(0x[0-9a-fA-F]+) <SharedFunctionInfo\s*([^>]*)>')


def js_frame(line):
    match = JS_FUNCTION.search(line)
    if not match:
        return None
    name = match[1].strip()
    url = re.search(r'\s*<([^<>]+)>$', name)
    return dict(functionName=name[:url.start()].strip() if url else name,
                url=url[1] if url else '', sfi=hex(int(match[2], 16)))


def trace_summary(file, role, expected_calls):
    # Immutable completed stdout is read twice; no running trace is summarized.
    lines = file.read_text(errors='strict').splitlines()
    classify = classifier(role)
    sources = {}
    for text in lines:
        frame = js_frame(text)
        if frame and frame['url']:
            old = sources.get(frame['sfi'])
            assert not old or old == frame, 'Conflicting SFI source attribution'
            sources[frame['sfi']] = frame
    phase, call = 'setup', 0
    buckets, events, markers = {}, [], []

    def record(kind, line_number, text, frame=None, **extra):
        frame = frame or dict(functionName='', url='')
        event = dict(kind=kind, phase=phase, call=call, line=line_number,
                     functionName=frame['functionName'], url=frame.get('url', ''),
                     namespace='gc' if kind == 'gc' else classify(frame['functionName'], frame.get('url', '')),
                     **extra)
        events.append(event)
        key = (call, phase)
        if key not in buckets:
            buckets[key] = dict(call=call, phase=phase, counts=Counter(), namespaces=Counter(),
                                gcPauseMs=0, gcSecondaryMs=0, completionCompilerMs=0)
        bucket = buckets[key]
        bucket['counts'][kind] += 1
        bucket['namespaces'][event['namespace']] += 1
        if kind == 'gc':
            bucket['gcPauseMs'] += event['pauseMs']
            bucket['gcSecondaryMs'] += event['secondaryMs']
        if kind == 'compilation-completed':
            bucket['completionCompilerMs'] += sum(event.get('durationComponentsMs', []))
        return event

    for number, text in enumerate(lines, 1):
        if text.startswith('P85 '):
            marker = json.loads(text[4:]);marker['line'] = number;markers.append(marker)
            call = marker['call']
            phase = {'import-start': 'import', 'import-end': 'after-import',
                     'request-start': 'request', 'request-end': 'validation',
                     'validation-end': 'between-requests'}[marker['phase']]
            continue
        frame = js_frame(text)
        if '[completed compiling ' in text or '[completed optimizing ' in text:
            assert frame, text
            tier = re.search(r'\(target ([^)]+)\)', text)
            durations = re.search(r'- took ([\d., ]+) ms', text)
            values = [float(v.strip()) for v in durations[1].split(',')] if durations else []
            record('compilation-completed' if '[completed compiling ' in text else 'optimization-completed',
                   number, text, frame, tier=tier[1] if tier else 'unknown',
                   durationComponentsMs=values, osr=' OSR' in text)
        elif '[bailout ' in text:
            reason = re.search(r'kind: ([^,]+), reason: (.*?)\):', text)
            tier = re.search(r'<Code ([^>]+)>', text)
            record('deopt', number, text, frame, reason=reason[2] if reason else 'unparsed',
                   deoptKind=reason[1] if reason else 'unparsed', tier=tier[1] if tier else 'unknown')
        elif ' for inlining (' in text and ('Cannot consider' in text or 'Not inlining' in text):
            shared = SHARED_FUNCTION.search(text)
            if shared:
                frame = sources.get(hex(int(shared[1], 16)), dict(functionName=shared[2], url=''))
            reason = re.search(r'for inlining \(([^)]+)\)', text)
            record('inlining-rejection', number, text, frame, reason=reason[1] if reason else 'unparsed')
        elif text.startswith('Inlining ') and ' into ' in text:
            shared = list(SHARED_FUNCTION.finditer(text))
            frame = sources.get(hex(int(shared[0][1], 16)), dict(functionName=shared[0][2], url='')) if shared else None
            record('inlining-success', number, text, frame,
                   caller=shared[1][2] if len(shared) > 1 else 'unknown')
        elif ' ms: ' in text and ' MB,' in text:
            kind = re.search(r'\]\s*([\d.]+) ms:\s*(.*?)\s+[\d.]+ \(', text)
            duration = re.search(r',\s*([\d.]+)\s*/\s*([\d.]+) ms', text)
            assert kind and duration, 'Unparsed GC line: '+text
            record('gc', number, text, gcKind=kind[2], processMs=float(kind[1]),
                   pauseMs=float(duration[1]), secondaryMs=float(duration[2]))
    for marker in ['request-start', 'request-end', 'validation-end']:
        assert [m['call'] for m in markers if m['phase'] == marker] == list(range(1, expected_calls+1)), marker
    assert len([m for m in markers if m['phase'] == 'import-start']) == 1
    assert len([m for m in markers if m['phase'] == 'import-end']) == 1

    grouped = {}
    for event in events:
        key = tuple(event.get(k) for k in ['kind', 'call', 'phase', 'namespace', 'functionName', 'url', 'tier', 'reason', 'gcKind'])
        if key not in grouped:
            grouped[key] = {k: event[k] for k in ['kind', 'call', 'phase', 'namespace', 'functionName', 'url', 'tier', 'reason', 'gcKind'] if k in event}
            grouped[key].update(count=0, firstLine=event['line'], lastLine=event['line'], compilerDurationMs=[], gcPauseMs=0)
        row = grouped[key];row['count'] += 1;row['lastLine'] = event['line']
        row['compilerDurationMs'] += [sum(event['durationComponentsMs'])] if event.get('durationComponentsMs') else []
        row['gcPauseMs'] += event.get('pauseMs', 0)
    for row in grouped.values():
        durations = row.pop('compilerDurationMs')
        if durations:
            row['compilerDurationMs'] = dict(sum=sum(durations), **stats(durations))
        if not row['gcPauseMs']:
            del row['gcPauseMs']

    def tops(kind, key, limit=20):
        selected = sorted([e for e in events if e['kind'] == kind], key=key, reverse=True)[:limit]
        return [{**e, 'raw': lines[e['line']-1]} for e in selected]
    return dict(stdout=pin(file), lineCount=len(lines), markers=markers,
        byPhase=list(buckets.values()), totals=dict(Counter(e['kind'] for e in events)),
        eventsByFunction=list(grouped.values()),
        topCompilationEvents=tops('compilation-completed', lambda e: sum(e['durationComponentsMs'])),
        topGcEvents=tops('gc', lambda e: e['pauseMs']),
        deoptExamples=[{**e, 'raw': lines[e['line']-1]} for e in events if e['kind'] == 'deopt'][:30],
        caveats=['Phase assignment follows stdout marker order, not causal ownership of concurrent compilation.',
                 'Compilation durations can overlap each other and request execution; their sums are diagnostic work, never additive request or wall time.',
                 'Compiling and optimizing completion records are separate kinds and may describe one optimized artifact; do not add their counts as unique functions.',
                 'GC pause is the first displayed ms component; secondary component stays separate. Pauses are observed trace values, not weighted CPU samples.',
                 'Inlining counts are compiler events, not dynamic calls. Reason numbers remain raw, version-specific codes.',
                 'SFI addresses join named inlining events to file-bearing JSFunction records. Missing/ambiguous namespace evidence stays other.',
                 'No reported optimization completion does not prove interpreter execution or that code never optimized.'])


def cpu_summary(file, role):
    data = json.loads(file.read_text())
    nodes = {n['id']: n for n in data['nodes']}
    assert len(nodes) == len(data['nodes'])
    assert len(data['samples']) == len(data['timeDeltas'])
    parents, self_ms, inclusive_ms, samples = {}, Counter(), Counter(), Counter()
    classify = classifier(role)
    for node in nodes.values():
        for child in node.get('children', []):
            assert child in nodes and child not in parents
            parents[child] = node['id']
    anomalies = []
    for index, (leaf, delta) in enumerate(zip(data['samples'], data['timeDeltas'])):
        assert leaf in nodes and math.isfinite(delta)
        if delta < 0:
            anomalies.append(dict(sampleIndex=index, nodeId=leaf, timeDeltaUs=delta,
                                  frame=nodes[leaf]['callFrame']))
            continue
        key = frame_key(nodes[leaf]['callFrame']);self_ms[key] += delta/1000;samples[key] += 1
        seen, ancestors = set(), set()
        current = leaf
        while current is not None:
            assert current not in ancestors
            ancestors.add(current);seen.add(frame_key(nodes[current]['callFrame']));current = parents.get(current)
        for key in seen:
            inclusive_ms[key] += delta/1000
    total = sum(self_ms.values())
    namespaces = Counter()
    for (name, url, line, column), ms in self_ms.items():
        namespaces[classify(name, url, line)] += ms
    def rows(weights):
        return [dict(functionName=k[0], url=k[1], line=k[2]+1 if k[2] >= 0 else None,
                     column=k[3]+1 if k[3] >= 0 else None, namespace=classify(k[0], k[1], k[2]),
                     selfMs=self_ms[k], inclusiveMs=inclusive_ms[k], selfSamples=samples[k],
                     selfPercent=100*self_ms[k]/total if total else None)
                for k, value in weights.most_common(30)]
    return dict(profile=pin(file), profileDurationMs=(data['endTime']-data['startTime'])/1000,
                totalSampleWeightMs=total, sampleCount=len(data['samples']),
                weightAccounting=dict(nonnegativeDeltasValid=not anomalies,
                    signedRawDeltaSumMs=sum(data['timeDeltas'])/1000,
                    positiveDeltaSumMs=total, negativeDeltaSumMs=sum(x['timeDeltaUs'] for x in anomalies)/1000,
                    negativeDeltas=anomalies,
                    policy='Negative deltas are retained here and excluded from hotspot weights, without reordering or repairing the raw profile. If present, weighted attribution is only a positive-delta diagnostic estimate and ordinary timing validity is not claimed.'),
                namespaceSelfMs=dict(namespaces), topSelf=rows(self_ms), topInclusive=rows(inclusive_ms),
                profilerProtocolSelfMs=namespaces['profiler-protocol'],
                percentagesDenominator='Sum of nonnegative preceding timeDeltas, including protocol/harness/GC/program/idle; anomalous negative deltas are separately preserved. Not the clean or instrumented request stopwatch.',
                caveat='Inclusive ancestors overlap and cannot be summed. Inspector post/protocol self cost can lie outside the request stopwatch and is not removable compiler work. Profile and performance.now timestamps have no established alignment. Names/URLs/locations retain frame identity; anonymous compiler-line attribution is lexical, not a dynamic caller claim.')


def read_lane(directory):
    plan_file = directory/'plan.json'
    plan = json.loads(plan_file.read_text());plan_pin = pin(plan_file)
    assert plan['kind'] == 'phase85-v8-compiler-plan'
    rows = []
    for job in plan['jobs']:
        report_file = directory/'runs'/job['name']/'report.json'
        assert report_file.exists(), 'Missing report: '+str(report_file)
        report = json.loads(report_file.read_text())
        assert report.get('complete') and report.get('pass') and report.get('inputsUnchanged'), 'Incomplete/failed report: '+str(report_file)
        assert report['job'] == job and report['plan'] == plan_pin
        assert [c['call'] for c in report['calls']] == list(range(1, job['calls']+1))
        expected = plan['cases'][job['case']]['expected'][job['role']]
        for call in report['calls']:
            assert call['exactC'] and call['sha256'] == expected['sha256']
            assert call['observation']['status'] == 'ok' and call['observation']['checked']
        guard_file = report_file.parent.with_name(report_file.parent.name+'-guard')/'process.json'
        guard = json.loads(guard_file.read_text())
        assert guard['complete'] and guard['returncode'] == 0, str(guard_file)
        rows.append(dict(job=job, report=report, receipt=pin(report_file), guard=pin(guard_file),
                         process=guard, directory=report_file.parent))
    return plan, plan_pin, rows


def compact_summary(full, full_pin):
    result = {k: full[k] for k in ['kind', 'complete', 'targetExecution', 'selectedLanes',
              'intervalsDoNotOverlap', 'targetOccupancySeconds', 'recordedSpanSeconds', 'scope']}
    for key in ['totalJobs', 'totalValidatedCalls', 'peakTreeRssBytes']:
        if key in full:
            result[key] = full[key]
    result.update(kind='phase85-offline-summary-compact', producer=pin(Path(__file__)),
                  rawFullSummary=full_pin, identities={}, lanes={})
    for name, lane in full['lanes'].items():
        small = {k: lane[k] for k in ['plan', 'modes', 'nodeArgs', 'jobs', 'totalValidatedCalls',
                                     'runtimeVersions']}
        for key in ['cpuAffinity', 'methodClassification']:
            if key in lane:
                small[key] = lane[key]
        small['identityBindings'] = {}
        for role, identities in lane['identities'].items():
            small['identityBindings'][role] = {}
            for key, item in identities.items():
                result['identities'][item['sha256']] = item
                small['identityBindings'][role][key] = item['sha256']
        if 'timings' in lane:
            small['timings'] = json.loads(json.dumps(lane['timings']))
            small['timingClass'] = lane['timingClass']
            for roles in small['timings']['cases'].values():
                for role in roles.values():
                    for run in role['runs']:
                        del run['report']  # Exact receipt remains in the pinned full summary.
                        for call in run['calls']:
                            del call['sha256']  # Full summary verifies every C hash.
        if 'traces' in lane:
            small['traces'] = {}
            for job, trace in lane['traces'].items():
                phases = { (row['call'], row['phase']): dict(row) for row in trace['byPhase'] }
                for group in trace['eventsByFunction']:
                    phase = phases[(group['call'], group['phase'])]
                    if group['kind'] in ['compilation-completed', 'optimization-completed']:
                        target = phase.setdefault('completionTiers', {}).setdefault(group['kind'], {})
                        tier = group.get('tier', 'unknown');target[tier] = target.get(tier, 0)+group['count']
                def relevant(rows):
                    return [r for r in rows if r['namespace'] in ['image-compiler', 'upstream', 'runtime']]
                def frequent(kind):
                    groups = {}
                    for row in relevant(trace['eventsByFunction']):
                        if row['kind'] != kind or row['phase'] != 'request':
                            continue
                        key = tuple(row.get(k) for k in ['functionName', 'url', 'reason', 'tier'])
                        if key not in groups:
                            groups[key] = {k: row[k] for k in ['functionName', 'url', 'reason', 'tier', 'namespace'] if k in row}
                            groups[key].update(count=0, byCall={}, firstLine=row['firstLine'], lastLine=row['lastLine'])
                        group = groups[key];group['count'] += row['count'];group['lastLine'] = row['lastLine']
                        group['byCall'][str(row['call'])] = group['byCall'].get(str(row['call']), 0)+row['count']
                    return sorted(groups.values(), key=lambda r: r['count'], reverse=True)[:5]
                small['traces'][job] = dict(stdout=trace['stdout'], totals=trace['totals'],
                    byPhase=list(phases.values()),
                    topRelevantCompilationEvents=relevant(trace['topCompilationEvents'])[:3],
                    topGcEvents=trace['topGcEvents'][:2],
                    frequentRequestDeopts=frequent('deopt'),
                    frequentRequestInliningRejections=frequent('inlining-rejection'))
            small['traceLimitations'] = next(iter(lane['traces'].values()))['caveats']
        if 'cpu' in lane:
            small['cpu'] = {}
            for job, profiles in lane['cpu'].items():
                small['cpu'][job] = []
                for p in profiles:
                    row = {k: p[k] for k in ['call', 'requestMsDiagnostic', 'profile', 'profileDurationMs',
                            'totalSampleWeightMs', 'sampleCount', 'weightAccounting', 'namespaceSelfMs',
                            'profilerProtocolSelfMs', 'percentagesDenominator', 'caveat']}
                    row['topSelf'] = p['topSelf'][:8]
                    row['topRelevantInclusive'] = [r for r in p['topInclusive'] if r['namespace'] in ['image-compiler', 'upstream', 'runtime']][:4]
                    small['cpu'][job].append(row)
        result['lanes'][name] = small
    result['limitations'] = [
        'Exploratory four-source repeated-process calls, not the qualified three-source cold parity metric or a steady-state claim.',
        'Upstream loads/checks Base and omits its CLI proof reporter; Bend uses an explicitly prepared Base and includes ordinary reporting.',
        'Cold request, imports-plus-first, subsequent request, trace, CPU and altered-tier results remain separate.',
        'Only complete/pass receipts and complete successful process guards enter the full summary; raw input/event groups remain in the pinned full artifact.',
        'Compiler event durations overlap and cannot be added to request time; event counts are not dynamic cost or unique code versions.',
        'Inspector protocol samples can fall outside request clocks. Two TS first-call profiles contain explicitly preserved negative deltas; positive-only attribution is diagnostic.',
        'GC pauses are displayed trace values; CPU GC attribution uses sample weights. They are different measurements.'
    ]
    return result


def method_classification(name, modes):
    if name.startswith('choice-screen'):
        return 'Unchecked saved compiler-image derivative. Exact C controls only; no production/semantic promotion or ordinary installed-performance claim.'
    if name.startswith('choice-control'):
        return 'Unmodified B2 control for paired saved-image experiment; separate from original clean survey.'
    if name.startswith('choice-code'):
        return 'Unchecked saved compiler-image derivative with V8 code dumps; diagnostic only.'
    if name.startswith('cpu-two'):
        return 'Two-CPU affinity hardware counterfactual, despite clean worker mode; no production compiler change.'
    if name.startswith('cpu-one'):
        return 'One-CPU control for hardware-affinity experiment; one cold request per process.'
    if modes == ['tier']:
        return 'Altered V8 tier/filter counterfactual, not production compiler performance.'
    if modes == ['clean']:
        return 'Ordinary complete native requests with default V8 flags; first and subsequent calls remain separate.'
    return 'Instrumented diagnostic only; no clean timing comparison.'


def comparisons(full):
    result = dict(kind='phase85-diagnostic-comparisons', complete=True,
                  ratioDirection='Candidate/request time divided by control/request time; below 1 is faster.',
                  comparisons={})
    specs = [('sparkplug-vs-default', 'sparkplug01', 'clean01', False),
             ('maglev-vs-default', 'maglev01', 'clean01', False),
             ('no-lexer-tf-vs-default', 'no-lexer-tf01', 'clean01', False),
             ('saved-choice-vs-control', 'choice-screen01', 'choice-control01', True),
             ('two-cpu-vs-one', 'cpu-two01', 'cpu-one01', True)]
    for name, candidate, control, paired in specs:
        if candidate not in full['lanes'] or control not in full['lanes']:
            continue
        c, b = full['lanes'][candidate], full['lanes'][control]
        row = dict(candidateLane=candidate, controlLane=control,
                   candidatePlan=c['plan'], controlPlan=b['plan'],
                   candidateCpu=c.get('cpuAffinity'), controlCpu=b.get('cpuAffinity'),
                   candidateClass=c['methodClassification'],
                   relationship='Matching source/role/round experiment; sample orders are retained in raw guards.' if paired else
                       'Separate lane versus earlier default survey, not interleaved paired timing; variation/temperature/tiering can confound differences.',
                   roles={})
        cc, bc = c['timings']['cases'], b['timings']['cases']
        for role in sorted(set.intersection(*[set(r) for r in cc.values()])):
            cases = sorted(case for case in cc if case in bc and role in bc[case])
            if not cases:
                continue
            detail = {}
            for case in cases:
                cr, br = cc[case][role], bc[case][role]
                measures = {'importsPlusFirstMs': (cr['importsPlusFirstMs'], br['importsPlusFirstMs'])}
                for call in ['1', '5']:
                    if call in cr['callMs'] and call in br['callMs']:
                        measures['call'+call] = (cr['callMs'][call], br['callMs'][call])
                detail[case] = {}
                for metric, (cs, bs) in measures.items():
                    def samples(runs):
                        return [dict(round=r['round'], job=r['job'], valueMs=r['importsPlusFirstMs']
                            if metric == 'importsPlusFirstMs' else r['calls'][int(metric[4:])-1]['requestMs']) for r in runs]
                    ca, ba = samples(cr['runs']), samples(br['runs'])
                    entry = dict(candidateMedianMs=cs['median'], controlMedianMs=bs['median'],
                                 medianRatio=cs['median']/bs['median'],
                                 candidateSamples=ca, controlSamples=ba)
                    if paired:
                        cm, bm = {x['round']: x for x in ca}, {x['round']: x for x in ba}
                        assert cm.keys() == bm.keys() and len(cm) == len(ca) == len(ba)
                        entry['matchingRoundRatios'] = {str(n): cm[n]['valueMs']/bm[n]['valueMs'] for n in sorted(cm)}
                    detail[case][metric] = entry
            all_metrics = set.intersection(*[set(v) for v in detail.values()])
            row['roles'][role] = dict(cases=detail, equalCaseGeomean={
                metric: geomean([detail[case][metric]['medianRatio'] for case in cases]) for metric in sorted(all_metrics)})
        result['comparisons'][name] = row
    result['limitations'] = [
        'Ratios compare medians within the stated diagnostic protocols, not confidence intervals or an installed compiler improvement.',
        'Five calls share a process; no convergence is established. Hardware lanes run one cold call, so they have no request5 and must not be mixed into warmed comparisons.',
        'Choice is a saved unchecked image intervention. Exact generated C on these requests establishes output preservation only for this scope.',
        'Tier ceiling/filter jobs alter V8 semantics of optimization; their timings are diagnostic counterfactuals.',
        'Equal-case geometric means weight sources equally, not elapsed seconds or representative application frequency.'
    ]
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root-data', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--lanes', default='clean01,trace01,cpu01')
    parser.add_argument('--compact-from', type=Path, help='Derive a small report from an immutable complete full summary; no target or raw profile reread')
    parser.add_argument('--comparisons-out', type=Path, help='Optional separate exact diagnostic comparison tables')
    args = parser.parse_args()
    if args.compact_from:
        full_pin = pin(args.compact_from);full = json.loads(args.compact_from.read_text())
        assert full['kind'] == 'phase85-offline-summary' and full['complete']
        if args.out.exists():
            old = json.loads(args.out.read_text())
            assert old['kind'] == 'phase85-offline-summary-compact'
            verify(old['rawFullSummary'])  # Its complete source remains independently preserved.
        compact = compact_summary(full, full_pin)
        if args.comparisons_out:
            comparison = comparisons(full);comparison['rawFullSummary'] = full_pin
            assert not args.comparisons_out.exists(), 'Choose a fresh comparisons artifact'
            args.comparisons_out.write_text(json.dumps(comparison, indent=1)+'\n')
            compact['comparisons'] = pin(args.comparisons_out)
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(json.dumps(compact, indent=1)+'\n')
        verify(full_pin)
        print(json.dumps(dict(complete=True, output=pin(args.out), raw=full_pin)))
        return
    assert args.root_data, '--root-data is required for a full summary'
    assert not args.out.exists(), 'Do not overwrite a consumed full summary; choose a fresh output'
    output = dict(kind='phase85-offline-summary', complete=False, targetExecution=False,
                  producer=pin(Path(__file__)), selectedLanes=args.lanes.split(','), lanes={})
    inputs = {}
    intervals = []
    for name in args.lanes.split(','):
        plan, plan_pin, rows = read_lane(args.root_data/name)
        for item in plan['inputs']:
            if item['file'] not in inputs:
                inputs[item['file']] = verify(item)
            assert inputs[item['file']]['sha256'] == item['sha256']
        modes = sorted({r['job']['mode'] for r in rows})
        lane = dict(plan=plan_pin, modes=modes, nodeArgs=plan['nodeArgs'], jobs=len(rows),
                    cpuAffinity=plan['cpu'], methodClassification=method_classification(name, modes),
                    totalValidatedCalls=sum(len(r['report']['calls']) for r in rows),
                    identities={role: {k: v for k, v in values.items() if k in ['node', 'api', 'runtime', 'base', 'driver', 'bend', 'compiler']}
                                for role, values in plan['roles'].items()},
                    runtimeVersions={r['job']['role']: r['report']['execution'] for r in rows},
                    receipts=[dict(job=r['job'], report=r['receipt'], guard=r['guard']) for r in rows])
        for row in rows:
            process = row['process'];intervals.append((process['started'], process['finished'], row['job']['name']))
        if modes == ['clean'] or modes == ['tier']:
            lane['timings'] = clean_summary(rows)
            lane['timingClass'] = ('unchecked-image-diagnostic' if name.startswith('choice-screen') else
                'hardware-affinity-diagnostic' if name.startswith(('cpu-one', 'cpu-two')) else
                'paired-unmodified-control' if name.startswith('choice-control') else
                'ordinary-clean' if modes == ['clean'] else 'altered-tier-counterfactual-not-production-performance')
        if modes == ['trace']:
            lane['traces'] = {r['job']['name']: trace_summary(
                r['directory'].with_name(r['directory'].name+'-guard')/'stdout.log',
                plan['roles'][r['job']['role']], r['job']['calls']) for r in rows}
        if modes == ['cpu']:
            lane['cpu'] = {r['job']['name']: [dict(call=c['call'], requestMsDiagnostic=c['requestMs'],
                **cpu_summary(Path(verify(c['profile'])['file']), plan['roles'][r['job']['role']]))
                for c in r['report']['calls'] if 'profile' in c] for r in rows}
            for r in rows:
                assert [c['call'] for c in lane['cpu'][r['job']['name']]] == r['job']['profileCalls']
        output['lanes'][name] = lane
    intervals.sort()
    for a, b in zip(intervals, intervals[1:]):
        assert a[1] <= b[0], 'Overlapping recorded target processes: '+a[2]+' / '+b[2]
    output.update(complete=True, inputs=list(inputs.values()), intervalsDoNotOverlap=True,
                  totalJobs=sum(lane['jobs'] for lane in output['lanes'].values()),
                  totalValidatedCalls=sum(lane['totalValidatedCalls'] for lane in output['lanes'].values()),
                  peakTreeRssBytes=max(json.loads(Path(row['guard']['file']).read_text())['peakTreeRssBytes']
                      for lane in output['lanes'].values() for row in lane['receipts']),
                  targetOccupancySeconds=sum(end-start for start, end, _ in intervals),
                  recordedSpanSeconds=intervals[-1][1]-intervals[0][0],
                  scope='Only the explicitly selected complete lanes. Target occupancy is sum of nonoverlapping process intervals, not total phase time. Trace/CPU/tier-counterfactual durations never enter ordinary-clean ratios.')
    # Receipts/logs must remain unchanged through analysis. Inputs were frozen by each worker.
    for lane in output['lanes'].values():
        verify(lane['plan'])
        for row in lane['receipts']:
            verify(row['report']);verify(row['guard'])
        for row in lane.get('traces', {}).values():
            verify(row['stdout'])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(output, stream, indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True, output=pin(args.out), lanes=output['selectedLanes'])))


if __name__ == '__main__':
    main()
