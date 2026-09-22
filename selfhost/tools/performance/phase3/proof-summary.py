#!/usr/bin/env python3
"""Verify a completed self-emission report and summarize its trace intervals.

Usage: proof-summary.py REPORT.json NEW_SUMMARY.json
Adjacent markers measure host wall intervals, not isolated function CPU time.
"""
import datetime
import hashlib
import json
from pathlib import Path
import re
import sys


def sha(file):
    return hashlib.sha256(Path(file).read_bytes()).hexdigest()


def verify_identity(item):
    assert str(Path(item['file']).resolve()) == item['canonicalPath'], item['file']
    assert sha(item['file']) == item['sha256'], item['file']


report_file, output = map(Path, sys.argv[1:])
assert not output.exists(), 'Use a new summary path'
report = json.loads(report_file.read_text())
assert report['complete'] is True and len(report['stages']) >= 2
assert not report.get('error') and not report.get('interrupted')
for item in [report['sourceIdentity'], report['base'], report['initialCompiler'],
             report['driver'], *report['hostHelpers']]:
    verify_identity(item)
assert sha(report['source']) == report['sourceSha256']
runtime = report_file.parent / 'runtime.mjs'
assert sha(runtime) == report['runtimeSha256']
stages = []
previous = report['initialCompiler']['file']
digest = None
for stage in report['stages']:
    assert stage['code'] == 0 and stage['signal'] is None and stage['inputsVerified'] is True
    assert Path(stage['compiler']).resolve() == Path(previous).resolve()
    assert sha(stage['compiler']) == stage['compilerSha256']
    assert sha(stage['output']) == stage['outputSha256']
    if digest is None:
        digest = stage['outputSha256']
    assert stage['outputSha256'] == digest
    previous = stage['output']
    log = Path(stage['output'] + '.log')
    markers = []
    for line in log.read_text().splitlines():
        match = re.fullmatch(r'\[typed ([^\]]+)\] (.*)', line)
        if match and not match[2].startswith('ABI '):
            timestamp = datetime.datetime.fromisoformat(match[1].replace('Z', '+00:00'))
            markers.append((timestamp, match[2]))
    assert len(markers) >= 3 and markers[-2][1] == 'emit library'
    assert re.fullmatch(r'emitted \d+ bytes', markers[-1][1])
    assert int(markers[-1][1].split()[1]) == Path(stage['output']).stat().st_size
    intervals = []
    for (start, label), (end, _) in zip(markers, markers[1:]):
        seconds = (end - start).total_seconds()
        assert seconds >= 0
        intervals.append({'marker': label, 'start': start.isoformat(),
                          'end': end.isoformat(), 'seconds': seconds})
    measured_seconds = sum(row['seconds'] for row in intervals)
    stages.append({
        **stage,
        'outputBytes': Path(stage['output']).stat().st_size,
        'log': str(log), 'logSha256': sha(log),
        'adjacentMarkerIntervals': intervals,
        'startupAndUnattributedSeconds': round(stage['ms'] / 1000 - measured_seconds, 3),
    })
summary = {
    'kind': 'verified-phase3-self-emission-summary',
    'complete': True,
    'report': str(report_file), 'reportSha256': sha(report_file),
    'summaryToolSha256': sha(__file__),
    'sourceSha256': report['sourceSha256'], 'runtimeSha256': report['runtimeSha256'],
    'outputSha256': digest, 'resourceConfiguration': report['resourceConfiguration'],
    'scope': 'Completed checked self-emission chain with reverified source, Base, host, runtime and compiler identities. Adjacent non-ABI trace markers measure wall intervals including intervening gates, host work and GC. The residual includes startup before the first marker, output publication after the emitted marker and unattributed work. These are not isolated function CPU timings. This is one chain, not a repeated benchmark.',
    'stages': stages,
}
output.write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps({'complete': True, 'sha256': digest, 'stageMilliseconds': [s['ms'] for s in stages]}))
