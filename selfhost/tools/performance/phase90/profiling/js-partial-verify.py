#!/usr/bin/env python3
"""Offline proof that worker-timed inspector stop completed DURING busy main JS."""
import json
import sys
from pathlib import Path
out=Path(sys.argv[1])
meta=json.loads((out/'metadata.json').read_text())
control=json.loads((out/'control.json').read_text())
profile=json.loads((out/'partial.cpuprofile').read_text())
assert meta['captureComplete'] and control['completed']
assert meta['compilerCompletion']=='not-observed' and meta['compilerSuccess'] is None
assert meta['stopReason']=='worker-wall-clock-deadline'
start,end=control['mainStartedUs'],control['mainFinishedUs']
assert meta['startAcknowledgedUs']<=start<meta['stopRequestedUs']<=meta['stopAcknowledgedUs']<end
assert meta['writtenUs']<end, 'Profile was not flushed before main loop ended'
assert end-start>=1_900_000
assert meta['stopAcknowledgedUs']-meta['startAcknowledgedUs']<1_500_000
nodes={row['id']:row for row in profile['nodes']}
ids={node_id for node_id,node in nodes.items() if node['callFrame']['functionName']=='busySpin'}
assert ids,'Missing control function in main-isolate profile'
# Count its subtree because sampled leaf may be performance.now/native clock.
children=list(ids)
while children:
 for child in nodes[children.pop()].get('children',[]):
  if child not in ids:ids.add(child);children.append(child)
samples=sum(sample in ids for sample in profile.get('samples',[]))
assert samples>0,'No samples under busy main function'
print(json.dumps(dict(passed=True,mainBusyMs=(end-start)/1000,
  stopAcknowledgedAfterStartMs=(meta['stopAcknowledgedUs']-meta['startAcknowledgedUs'])/1000,
  stopAckBeforeMainFinishedMs=(end-meta['stopAcknowledgedUs'])/1000,
  busySamples=samples,samples=len(profile.get('samples',[])),
  compilerCompletionInferred=False),indent=2))
