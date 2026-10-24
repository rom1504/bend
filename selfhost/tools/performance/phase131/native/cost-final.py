#!/usr/bin/env python3
"""Final snapshot adapter: preserve prior cost method, clarify late guard labels."""
from datetime import datetime,timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode=True
METHOD=Path(__file__).with_name('cost-snapshot.py')
EXPECTED='c0df8a2402b79f5a02b55de5e719e6dbc13be47768885f4bbb3b8b7c70b8acd1'
assert hashlib.sha256(METHOD.read_bytes()).hexdigest()==EXPECTED
spec=importlib.util.spec_from_file_location('p131_prior_cost_snapshot',METHOD)
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
old_classify=M.classify


def classify(path,command,cpu):
    parts=path.relative_to(M.PHASE).parts
    label='/'.join(parts).lower();args=' '.join(command).lower()
    if cpu=='4':return old_classify(path,command,cpu)
    if 'native-request.py' in args and 'compiler.bend' in args and 'reproduce' in label:
        return 'full-compiler-reproduction'
    if any(x in label for x in ['full-profile','full-context']):return 'full-compiler-profiling'
    if any(x in label for x in ['-profile','-context']):return 'profiling-or-instrumentation'
    original=old_classify(path,command,cpu)
    if original=='controls-diagnostics-other' and '-timing' in label:
        return 'clean-other-timing' if cpu=='3' else 'diagnostic-other-timing'
    return original


if __name__=='__main__':
    M.classify=classify
    # Delegate archives this adapter as the actual method. The immutable
    # delegate source is retained in the preceding incremental archive chain.
    M.__file__=str(Path(__file__).resolve())
    M.main()
    out=Path(sys.argv[sys.argv.index('--out')+1]).resolve()
    path=out/'report.json';r=json.loads(path.read_text())
    start=datetime(2026,10,23,22,0,45,tzinfo=timezone.utc).timestamp()
    deadline=datetime(2026,10,24,1,0,45,tzinfo=timezone.utc).timestamp()
    intervals=[(max(start,x['started']),min(r['cutoffUnixSeconds'],x['finished'])) for x in r['rows']
        if x['finished']>start and x['started']<r['cutoffUnixSeconds']]
    union=M.union_seconds(intervals);elapsed=r['cutoffUnixSeconds']-start
    r['methodComponents']=[M.pin_bytes(METHOD.resolve(),METHOD.read_bytes()),M.pin_bytes(Path(__file__).resolve(),Path(__file__).read_bytes())]
    r['campaignWindow']=dict(coordinatorStartUtc='2026-10-23T22:00:45Z',minimumWorkDeadlineUtc='2026-10-24T01:00:45Z',
        requestedMinimumSeconds=deadline-start,cutoffUtc=datetime.fromtimestamp(r['cutoffUnixSeconds'],timezone.utc).isoformat(),
        elapsedAtCutoffSeconds=elapsed,guardIntervalUnionSeconds=union,
        unrepresentedElapsedSeconds=max(0,elapsed-union),
        scope='Coordinator-specified campaign window. Unrepresented wall includes unguarded metadata/storage work, planning, agent work, communication and gaps; it is not a measurement of model reasoning or token quota.')
    r['classificationChanges']=['Reproduce guards separated from initial acquisition.',
        'Late final-profile/final-context names recognized; full-source sampling separated from short profiling.',
        'Other explicit timing guards labeled by CPU lane. Prior raw totals/intervals remain unchanged.',
        'Purpose labels remain command/path classifications; raw rows and nonzero exits are retained.']
    path.write_text(json.dumps(r,indent=2)+'\n')
    with (out/'README.md').open('a') as f:
        f.write('\nCampaign window:22:00:45 UTC start;01:00:45 UTC minimum deadline. '
            f'At cutoff,{elapsed/60:.2f} elapsed minutes; guarded interval union{union/60:.2f} minutes; '
            f'unrepresented wall{max(0,elapsed-union)/60:.2f} minutes. This remainder is not model/token accounting.\n')
    print(json.dumps(dict(finalCostReport=M.pin_bytes(path,path.read_bytes()),campaign=r['campaignWindow'])))
