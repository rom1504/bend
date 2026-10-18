#!/usr/bin/env python3
"""Account saved Phase110 process guards and physical source roles, without targets."""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', required=True, type=Path)
a = p.parse_args(); out = a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT / 'implementation/phase110'):
    raise ValueError('fresh Phase110 accounting output required')
start = datetime(2026, 10, 18, 18, 59, 56, tzinfo=timezone.utc).timestamp()
snapshot = time.time()
roots = [ROOT / 'selfhost/build/phase110']
roots += sorted((ROOT / 'selfhost/build/phase108').glob('p110-*'))
roots += sorted((ROOT / 'selfhost/build/phase98').glob('*phase110*'))
pin = lambda f: dict(file=str(f.relative_to(ROOT)), bytes=f.stat().st_size,
                    sha256=hashlib.sha256(f.read_bytes()).hexdigest())
rows = []
for root in roots:
    for path in sorted(root.rglob('process.json')):
        d = json.loads(path.read_text())
        if not all(key in d for key in ['started', 'finished', 'wallSeconds', 'command']):
            continue
        if d['started'] < start or d['finished'] > snapshot:
            continue
        text = str(path)
        category = 'API, admission, semantics and other guarded work'
        if '/phase98/' in text: category = 'Independent law checking'
        elif '/phase108/p110-native-source' in text: category = 'Full native image acquisition (including failed attempt)'
        elif any(s in text for s in ['base-packed', 'base-chunks', 'literal-probe', 'packed-controls']):
            category = 'Constant-representation diagnosis'
        elif any(s in text for s in ['search', 'training', 'heldout', 'transfer', 'production-compare', 'context-machine']):
            category = 'Worker evaluation and transfer campaigns'
        rows.append(dict(receipt=pin(path), category=category, started=d['started'], finished=d['finished'],
                         wallSeconds=d['wallSeconds'], returncode=d.get('returncode'), complete=d.get('complete'),
                         peakTreeRssBytes=d.get('peakTreeRssBytes'), command=d['command']))
intervals = sorted((r['started'], r['finished']) for r in rows)
merged = []
for begin, end in intervals:
    if merged and begin <= merged[-1][1]: merged[-1][1] = max(merged[-1][1], end)
    else: merged.append([begin, end])
occupied = sum(end - begin for begin, end in merged)
by_category = defaultdict(lambda: dict(guards=0, summedWallSeconds=0))
for row in rows:
    g = by_category[row['category']]; g['guards'] += 1; g['summedWallSeconds'] += row['wallSeconds']
source_rows = []
for f in sorted((ROOT / 'selfhost/tools/performance/phase110').rglob('*')):
    if not f.is_file() or '__pycache__' in f.parts or f.suffix not in ['.bend', '.py', '.mjs', '.c', '.h']:
        continue
    rel = f.relative_to(ROOT / 'selfhost/tools/performance/phase110')
    if f.suffix == '.bend':
        role = 'Bend algorithms and additive variants'
        if ('controls' in rel.parts or 'controls' in f.name or f.stem.endswith('probe')
                or rel.as_posix() == 'context-calls/wide.bend'):
            role = 'Bend controls and witnesses'
        elif rel.parts[0] == 'laws': role = 'Bend laws and models'
    elif f.suffix in ['.py', '.mjs']: role = 'Experiment preparation, supervision and analysis'
    else: role = 'C ABI adapters and independent runtime harnesses'
    lines = f.read_text().splitlines()
    source_rows.append(dict(**pin(f), role=role, physicalLines=len(lines),
                            nonblankLines=sum(bool(s.strip()) for s in lines)))
source_totals = defaultdict(lambda: dict(files=0, physicalLines=0, nonblankLines=0, bytes=0))
for row in source_rows:
    g = source_totals[row['role']]; g['files'] += 1
    for key in ['physicalLines', 'nonblankLines', 'bytes']: g[key] += row[key]
report = dict(kind='phase110-observed-resource-and-source-accounting', complete=True,
              method=pin(Path(__file__)), startedUtc='2026-10-18T18:59:56Z', snapshotUtc=datetime.fromtimestamp(snapshot,timezone.utc).isoformat(),
              elapsedSeconds=snapshot-start, guardedIntervalUnionSeconds=occupied,
              remainderSeconds=snapshot-start-occupied, guardCount=len(rows), categories=dict(by_category),
              guardRows=rows, sourceTotals=dict(source_totals), sourceRows=source_rows,
              limitations=['Observed guard occupancy is not CPU time or billing/quota data.',
                'Source preparation, analysis, agent coordination and documentation overlap target work; remainder is not idle time.',
                'Only process.json records under the declared roots are counted; uninstrumented work is excluded.',
                'Physical experiment source counts include rejected/additive variants and comments; they are not production compiler LOC or active-source delta.',
                'Generated fixtures, JSON receipts, composed compiler snapshots, previous phases and Markdown are excluded from source totals.'])
out.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ['elapsedSeconds', 'guardedIntervalUnionSeconds', 'guardCount', 'categories', 'sourceTotals']}))
