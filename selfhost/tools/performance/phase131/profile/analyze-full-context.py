#!/usr/bin/env python3
"""Attribute one full-source context-only sample; no extra target or clean clock."""
import argparse
from collections import Counter,defaultdict
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
    for name in ['capture','owners','out']:p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists()
    report_path=a.capture/'report.json';r=read(report_path)
    assert r['complete'] and r['passed'] and len(r['rows'])==1 and not r['changedInputs']
    row=r['rows'][0];assert row['mode']=='sample' and row['periodUs']==32000 and row['correct'] and row['diagnosticRuntime']
    assert 'events' not in row and 'callers' not in row
    manifest_path=a.capture/'manifest.json';m=read(manifest_path);snapshot=pin(manifest_path)
    assert any(x.get('sha256')==snapshot['sha256'] and x.get('bytes')==snapshot['bytes'] for x in r['inputs'])
    assert m['ownerMap']==pin(a.owners)
    summary=summarize_reports([report_path]);view=summary['workloads']['compiler-self-source']['phase131-final-n2-context']
    assert view['clean']['wallSeconds']['count']==0 and not view['profile']['estimateAvailable']
    analysis_path=verify(row['analysis']);analysis=read(analysis_path);reasons=capture_reasons(analysis)
    joined,events=attribute(analysis_path,None,None,verify(row['contexts']),a.owners)
    assert joined['pairing']['verified'] and joined['pairing']['correct'] and joined['contextHeader']['context_available']
    sequence=timeline.windows(events,analysis['header'],joined,window_cpu_seconds=30,top=8)
    sequence.update(identities=joined['identities'],pairing=joined['pairing'],quality=joined['quality'])
    total=len(events);owners=Counter();conditional=defaultdict(Counter)
    for e in events:
        owner=e.get('dispatchContext',{}).get('loweredOwner') or '[unknown]'
        leaf=e['leaf'].get('decoded') or e['leaf'].get('symbol') or '[unknown]'
        owners[owner]+=1
        if '$p118borrow.read.p88_string_eq_go' in leaf:conditional['borrowedStringEquality'][owner]+=1
        if leaf in ['term_drop','span_fade']:conditional['dropAndSpanFade'][owner]+=1
        if 'index_hash' in leaf:conditional['indexHash'][owner]+=1
        if leaf.startswith('p125_rt_take') or leaf=='p111_rt_take':conditional['takes'][owner]+=1
    selected={}
    for name,counts in conditional.items():
        n=sum(counts.values());selected[name]=dict(samples=n,fractionOfAllSamples=n/total,
            owners=[dict(owner=k,samples=v,fractionOfSelectedLeafSamples=v/n,fractionOfAllSamples=v/total) for k,v in counts.most_common()])
    out.mkdir(parents=True);save(out/'comparison.json',summary);save(out/'attribution.json',joined)
    save(out/'timeline.json',sequence);(out/'timeline.md').write_text(timeline.markdown(sequence))
    result=dict(kind='phase131-full-source-context-only-analysis',complete=True,targetsRun=False,
        inputs=[pin(__file__),pin(report_path),pin(manifest_path),row['analysis'],row['contexts'],pin(a.owners),pin(PROF/'compare.py'),pin(PROF/'attribute.py'),pin(PROF/'timeline.py')],
        originalN2=m['lineage']['image'],diagnosticImage=m['diagnosticImage'],source=m['lineage']['source'],
        sampledObservation={k:row[k] for k in ['wallSeconds','cpuSeconds','peakRssKiB','stdout','stderr']},
        cleanObservations=0,newSpeedRatio=None,countersEnabled=False,
        samples=total,adequate=total>=500,qualityReasons=reasons,quality=joined['quality'],contextHeader=joined['contextHeader'],
        topActiveOwners=[dict(owner=k,samples=v,fractionOfAllSamples=v/total) for k,v in owners.most_common(60)],
        conditionalLeaves=selected,ownerLeafMatrix=joined['contextLeafMatrix'],timeline=pin(out/'timeline.json'),
        physicalProfile=view['profile'],
        scope='Single context-only sampled full-source final-N2 diagnostic relink, exact complete-QBE output. Current active owner of selected physical leaves; not source-call ancestry, allocation-creation origin, or independent clean timing.',
        limitations=['Private synchronous calls retain the outer dispatcher context; leaf ownership and active ownership can differ.',
            'Counter hooks are disabled. No allocation volume or term-creation site is inferred from these samples.',
            'Sample-only capture has no paired clean baseline or overhead estimate; earlier physical capture remains separate.',
            'One32ms period may alias repeated computation. Unknown samples stay in all denominators.',
            'Timeline coordinates are approximate sampled-thread CPU time, not wall timestamps or verified phase boundaries.'])
    save(out/'report.json',result)
    print(json.dumps(dict(complete=True,out=str(out),samples=total,qualityReasons=reasons,
        top=result['topActiveOwners'][:12],selected={k:dict(samples=v['samples'],owners=v['owners'][:6]) for k,v in selected.items()})))


if __name__=='__main__':main()
