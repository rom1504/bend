#!/usr/bin/env python3
"""Check a completed screen and summarize every clean sample."""
import hashlib
import json
import math
import statistics
import sys
from pathlib import Path

file = Path(sys.argv[1]).resolve()
plan = json.loads(file.read_text())
reports = []
for job in plan['jobs']:
    path = file.parent/'runs'/job['name']/'report.json'
    report = json.loads(path.read_text())
    assert report['complete'] and report['pass'] and report['inputsUnchanged']
    if job['action'] == 'request':
        assert report['exactC']
        reports.append(report)
baseline = next(r for r in plan['roles'] if r.startswith('b'))
rows = {}
for case in plan['cases']:
    row = {}
    for role in plan['roles']:
        selected = [r for r in reports if r['role'] == role and r['job']['case'] == case]
        values = [r['timings']['requestMs'] for r in selected]
        assert values
        row[role] = dict(samplesMs=values, medianMs=statistics.median(values))
    row['candidateOverBaseline'] = row['candidate']['medianMs']/row[baseline]['medianMs']
    if 'typescript' in row:
        row['candidateOverTS'] = row['candidate']['medianMs']/row['typescript']['medianMs']
    rows[case] = row
summary = dict(complete=True, allExactC=True, plan=dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest()),
    scope=plan['scope'], cases=rows, candidateOverBaselineGM=math.exp(statistics.mean(math.log(r['candidateOverBaseline']) for r in rows.values())))
Path(sys.argv[2]).write_text(json.dumps(summary, indent=2)+'\n')
print(json.dumps(summary))
