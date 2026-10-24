#!/usr/bin/env python3
"""Analyze one full-source sample offline, without inventing a clean baseline."""
import argparse
from collections import Counter
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[5]
PROF=ROOT/'selfhost/tools/profiler'
sys.dont_write_bytecode=True
sys.path.insert(0,str(PROF))
from run import pin,verify,save
from compare import summarize_reports,capture_reasons
from attribute import attribute
import timeline


def read(path):return json.loads(Path(path).read_text())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--capture',type=Path,required=True);p.add_argument('--owners',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists()
    report_path=a.capture/'report.json';report=read(report_path)
    assert report['complete'] and report['passed'] and len(report['rows'])==1
    row=report['rows'][0];assert row['mode']=='sample' and row['periodUs']==32000 and row['correct']
    manifest_path=a.capture/'manifest.json';manifest=read(manifest_path)
    snapshot=pin(manifest_path)
    assert any(x.get('sha256')==snapshot['sha256'] and x.get('bytes')==snapshot['bytes'] for x in report['inputs'])
    assert len(manifest['workloads'])==1 and manifest['workloads'][0]['name']=='compiler-self-source'
    summary=summarize_reports([report_path]);view=summary['workloads']['compiler-self-source']['phase131-final-n2']
    assert view['clean']['wallSeconds']['count']==0 and not view['profile']['estimateAvailable']
    analysis_path=verify(row['analysis']);analysis=read(analysis_path)
    reasons=capture_reasons(analysis)
    joined,events=attribute(analysis_path,verify(row['callers']),verify(manifest['unwindTable']),None,a.owners)
    assert joined['pairing']['verified'] and joined['pairing']['correct']
    sequence=timeline.windows(events,analysis['header'],joined,window_cpu_seconds=30,top=8)
    sequence.update(identities=joined['identities'],pairing=joined['pairing'],quality=joined['quality'])
    owners=Counter(event['leaf'].get('loweredOwner') or '[unknown-or-runtime]' for event in events)
    out.mkdir(parents=True);save(out/'comparison.json',summary);save(out/'attribution.json',joined)
    save(out/'timeline.json',sequence);(out/'timeline.md').write_text(timeline.markdown(sequence))
    result=dict(kind='phase131-full-source-sample-only-analysis',complete=True,targetsRun=False,
        inputs=[pin(__file__),pin(report_path),pin(manifest_path),row['analysis'],pin(a.owners),pin(PROF/'compare.py'),pin(PROF/'attribute.py'),pin(PROF/'timeline.py')],
        image=manifest['lineage']['image'],source=manifest['lineage']['source'],samplePeriodUs=32000,
        sampledObservation={k:row[k] for k in ['wallSeconds','cpuSeconds','peakRssKiB','stdout','stderr']},
        cleanObservations=0,newSpeedRatio=None,absoluteCleanCpuEstimates=False,
        adjacentHistoricalClean=manifest['adjacentHistoricalClean'],physicalProfile=view['profile'],
        qualityReasons=reasons,physicalCallerCoverage=joined['coverage'],physicalCallerMatrix=joined['matrix'],
        physicalLexicalOwners=[dict(owner=k,samples=v,fractionOfAllSamples=v/len(events)) for k,v in owners.most_common(40)],
        timeline=pin(out/'timeline.json'),
        scope='Single actual final-N2 full compiler-source sampling run with exact pre-existing whole-QBE oracle. Physical leaf fractions and bounded libc caller recovery only; no paired clean baseline, runtime event counters, active dispatch contexts or new gain ratio.',
        limitations=['One32ms sampling period can alias repeated work. Sample size does not eliminate systematic sampling bias.',
            'Timeline ordinal×period is approximate sampled-thread CPU coordinate from sampling start, never wall time or an asserted phase boundary.',
            'Lexical physical owners apply only to sampled code with authenticated symbol/FID mapping; runtime/callee cost is not attributed to source callers.',
            'Earlier379.228s same-source emission is retained as historical context, not a new paired clean profiler observation.'])
    save(out/'report.json',result)
    print(json.dumps(dict(complete=True,out=str(out),samples=view['profile']['samples'],adequate=view['profile']['adequate'],qualityReasons=reasons,
        cpuTimelineAvailable=sequence['clock']['available'],top=[dict(name=x['decoded'],fraction=x['periodWeightedFraction']) for x in view['profile']['functions'][:12]])))


if __name__=='__main__':main()
