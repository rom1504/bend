#!/usr/bin/env python3
"""Account for retained Phase89 guarded jobs; duplicate copies count once."""
import datetime
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
rows, copies = {}, []
for path in sorted((ROOT / 'selfhost/build/phase89').rglob('process.json')):
    data = path.read_bytes()
    process = json.loads(data)
    digest = hashlib.sha256(data).hexdigest()
    if digest in rows:
        copies.append(dict(file=str(path.relative_to(ROOT)), original=rows[digest]['file']))
        continue
    rows[digest] = dict(file=str(path.relative_to(ROOT)), sha256=digest,
                       process=process)
values = list(rows.values())
finished = [r for r in values if 'wallSeconds' in r['process'] and 'finished' in r['process']]
start = min(r['process']['started'] for r in finished)
end = max(r['process']['finished'] for r in finished)
summary = dict(complete=len(finished) == len(values), uniqueGuardRecords=len(values),
              duplicateCopies=len(copies), successful=sum(r['process'].get('complete', False) for r in values),
              nonzeroOrStopped=sum(not r['process'].get('complete', False) for r in values),
              guardedWallSeconds=sum(r['process']['wallSeconds'] for r in finished),
              campaignSpanSeconds=end-start,
              firstStartedUtc=datetime.datetime.fromtimestamp(start, datetime.timezone.utc).isoformat(),
              lastFinishedUtc=datetime.datetime.fromtimestamp(end, datetime.timezone.utc).isoformat(),
              peakTreeRssBytes=max(r['process'].get('peakTreeRssBytes', 0) for r in values),
              resourceStops=[dict(file=r['file'], reason=r['process']['stoppedFor']) for r in values if r['process'].get('stoppedFor')],
              notes=['Includes retained expected refusals, failed experiments, compiler and diagnostic builds.',
                     'Same process.json bytes copied into launcher evidence are counted once.',
                     'Sum is guard wall occupancy, not total development time, CPU cost or token/quota usage.',
                     'Source audits, shell orchestration, artifact sealing, network and agent reasoning are outside these clocks.'],
              rows=values, copies=copies)
(ROOT / 'implementation/phase89/resource-account.json').write_text(json.dumps(summary, indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k not in ('rows', 'copies')}, indent=2))
