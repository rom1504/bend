#!/usr/bin/env python3
"""Check followup allocation/trace receipts; never executes a target."""
import hashlib
import json
import re
import sys
from pathlib import Path

raw = Path(sys.argv[1]).resolve()
out = Path(sys.argv[2])
inputs = {}


def pin(path, expected=None):
    path = Path(path).resolve()
    row = dict(file=str(path), bytes=path.stat().st_size,
               sha256=hashlib.sha256(path.read_bytes()).hexdigest())
    if expected:
        assert row['sha256'] == expected['sha256']
        assert row['bytes'] == expected.get('bytes', row['bytes'])
    inputs[str(path)] = row
    return row


def read(path, expected=None):
    pin(path, expected)
    return json.loads(Path(path).read_text())


pin(__file__)
allocations, traces, processes = [], [], []
for name in ['cpu01', 'followup01', 'trace01']:
    queue = read(raw / name / 'report.json')
    assert queue['complete'] and queue['inputStabilityVerified']
    for row in queue['inputs']:
        pin(row['file'], row)
    for job in queue['jobs']:
        process = job['process']
        assert process['complete'] and process['returncode'] == 0
        processes.append(process)
        report = read(job['report']['file'], job['report'])
        assert report['complete'] and report.get('pass', report.get('passed'))
        pin(report['module']['file'], report['module'])
        if report.get('profileKind') == 'allocation':
            profile = read(report['profile']['file'], report['profile'])
            estimated = sum(s['size'] for s in profile['samples'])
            assert estimated == report['summary']['estimatedBytes']
            allocations.append(dict(id=job['label'], calls=report['repetitions'],
                estimatedBytesPerCall=estimated / report['repetitions'],
                sampleCount=len(profile['samples']), topSelf=report['summary']['topSelf'][:8],
                accounting=report['summary']['accounting'], warnings=report['summary']['warnings']))
        if name == 'trace01':
            log = Path(job['report']['file']).parents[1] / 'process/stdout.log'
            pin(log)
            text = log.read_text()
            assert text.count('P49_V8 measure-start\n') == text.count('P49_V8 measure-end\n') == 1
            measured = text.split('P49_V8 measure-start\n')[1].split('P49_V8 measure-end\n')[0]
            refusals = [line for line in text.splitlines()
                        if 'SharedFunctionInfo apply>' in line and 'for inlining (reason: 5)' in line]
            traces.append(dict(id=job['label'], measuredBailouts=measured.count('[bailout'),
                totalBailouts=text.count('[bailout'), measuredGcEvents=len(re.findall(r'gc=[a-z]+', measured)),
                applyBytecodeLimitRefusals=len(refusals), exampleRefusal=refusals[:1],
                warmups=report['input']['warmups'], calls=report['input']['calls']))
ordered = sorted(processes, key=lambda p: p['started'])
assert all(a['finished'] <= b['started'] for a, b in zip(ordered, ordered[1:]))
result = dict(kind='phase50-followup-summary', complete=True, diagnosticOnly=True,
    inputs=list(inputs.values()), allocations=allocations, traces=traces,
    jobs=len(processes), processSeconds=sum(p['wallSeconds'] for p in processes),
    maxTreeRssBytes=max(p['peakTreeRssBytes'] for p in processes),
    firstTargetStarted=ordered[0]['started'], lastTargetFinished=ordered[-1]['finished'],
    targetIntervalsDoNotOverlap=True,
    scope='Allocation samples estimate bytes, not exact events or retained heap. '
          'Trace GC counts use different per-role call counts and are not directly comparable. '
          'No instrumented duration is a speed ratio. Reason5 is mapped to kExceedsBytecodeLimit '
          'in Node24.18.0 bundled V8; notices cover the entire trace, not only measurement.')
with out.open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps({k: result[k] for k in ['complete', 'jobs', 'processSeconds', 'maxTreeRssBytes']}))
