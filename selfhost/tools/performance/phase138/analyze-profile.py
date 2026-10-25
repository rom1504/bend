#!/usr/bin/env python3
"""Offline Phase138 attribution using the established generic profiler."""
import argparse
import collections
import json
import pathlib
import sys

sys.dont_write_bytecode = True
ROOT = pathlib.Path(__file__).resolve().parents[4]
PROF = ROOT / 'selfhost/tools/profiler'
sys.path.insert(0, str(PROF))
from run import pin, verify, save
from attribute import attribute
from compare import capture_reasons
import timeline

def read(path):
    return json.loads(pathlib.Path(path).read_text())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', type=pathlib.Path, required=True)
    parser.add_argument('--out', type=pathlib.Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase138') and not out.exists()
    manifest = read(args.profile / 'manifest.json')
    rp = args.profile / 'capture/report.json'
    report = read(rp)
    assert report['complete'] and report['passed'] and not report['changedInputs']
    assert len(report['rows']) == 1
    row = report['rows'][0]
    assert row['mode'] == 'sample' and row['correct'] and 'events' not in row
    analysis = read(verify(row['analysis']))
    joined, events = attribute(verify(row['analysis']), verify(row['callers']),
        verify(manifest['unwindTable']), verify(row['contexts']), verify(manifest['ownerMap']))
    assert joined['pairing']['verified'] and joined['pairing']['correct']
    assert joined['identities']['binary'] == manifest['diagnosticImage']
    assert joined['contextHeader']['context_available']
    owners, leaves = collections.Counter(), collections.Counter()
    by_owner = collections.defaultdict(collections.Counter)
    for event in events:
        owner = event.get('dispatchContext', {}).get('loweredOwner') or '[unknown]'
        leaf = event['leaf'].get('decoded') or event['leaf'].get('symbol') or '[unknown]'
        owners[owner] += 1
        leaves[leaf] += 1
        by_owner[owner][leaf] += 1
    total = len(events)
    def ranked(counts, key):
        return [{key:k, 'samples':n, 'fractionOfAll':n/total} for k,n in counts.most_common(40)]
    selected = []
    for owner in ['f_find','lookup','nc_ctor_owned','has_name','index_remove','p111v_get']:
        counts = by_owner[owner]
        n = sum(counts.values())
        rc = sum(counts[k] for k in ('term_drop','span_fade'))
        selected.append(dict(owner=owner,samples=n,fractionOfAll=n/total,
            dropAndFade=dict(samples=rc,fractionOfAll=rc/total,fractionOfOwner=rc/n if n else None),
            topLeaves=ranked(counts,'leaf')[:10]))
    sequence = timeline.windows(events, analysis['header'], joined, window_cpu_seconds=30, top=8)
    sequence.update(identities=joined['identities'],pairing=joined['pairing'],quality=joined['quality'])
    out.mkdir(parents=True)
    save(out/'attribution.json', joined)
    save(out/'timeline.json', sequence)
    (out/'timeline.md').write_text(timeline.markdown(sequence))
    result = dict(kind='phase138-qualified-n3-full-profile',complete=True,targetsRun=False,
        inputs=[pin(__file__),pin(rp),pin(args.profile/'manifest.json'),row['analysis'],
            row['contexts'],row['callers'],manifest['ownerMap'],manifest['unwindTable'],
            pin(PROF/'attribute.py'),pin(PROF/'timeline.py')],
        lineage=manifest['lineage'],diagnosticImage=manifest['diagnosticImage'],
        observation={k:row[k] for k in ['wallSeconds','cpuSeconds','peakRssKiB','stdout','stderr']},
        samples=total,qualityReasons=capture_reasons(analysis),quality=joined['quality'],
        callerCoverage=joined['coverage'],topActiveOwners=ranked(owners,'owner'),
        topPhysicalLeaves=ranked(leaves,'leaf'),selectedOwnerLeafIntersections=selected,
        attribution=pin(out/'attribution.json'),timeline=pin(out/'timeline.json'),
        scope='Diagnostic exact-clean-digest request; not a clean speed comparison. Contexts include synchronous private calls; intersections overlap. No allocation counts or fresh stage clocks.')
    save(out/'report.json',result)
    print(json.dumps(dict(complete=True,samples=total,qualityReasons=result['qualityReasons'],
        topOwners=result['topActiveOwners'][:12],topLeaves=result['topPhysicalLeaves'][:12])))

if __name__ == '__main__':
    main()
