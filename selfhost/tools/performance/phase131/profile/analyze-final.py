#!/usr/bin/env python3
"""Offline final-N2 refresh using existing attribution and measurement gates."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROF = ROOT / 'selfhost/tools/profiler'
sys.dont_write_bytecode = True
sys.path.insert(0, str(PROF))
from run import pin, verify, save, all_pins
from compare import summarize_reports, capture_reasons
from attribute import attribute


def read(path): return json.loads(Path(path).read_text())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['physical','context','out']:p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists()
    manifest=read(a.physical/'manifest.json');context_manifest=read(a.context/'manifest.json')
    assert manifest['lineage']['experimental'] and manifest['lineage']['nativeQualified'] is False
    for item in [*all_pins(manifest),*all_pins(context_manifest)]:verify(item)
    old_path=ROOT/'selfhost/build/phase131/profile-analysis01/report.json';old=read(old_path)
    reports=[directory/w['name']/'report.json' for directory in [a.physical,a.context] for w in manifest['workloads']]
    summary=summarize_reports(reports,baseline_variants={'phase131-final-n2-context':'phase131-final-n2'})
    out.mkdir(parents=True);save(out/'comparison.json',summary)
    context_tool=ROOT/'selfhost/tools/performance/phase129/summarize-context.py'
    subprocess.run([sys.executable,'-B',str(context_tool),'--capture',str(a.context),'--out',str(out/'contexts')],check=True,stdout=subprocess.DEVNULL)
    contexts=read(out/'contexts/report.json')
    result=dict(complete=False,targetsRun=False,inputs=[pin(__file__),pin(context_tool),pin(PROF/'compare.py'),
        pin(PROF/'attribute.py'),pin(a.physical/'manifest.json'),pin(a.context/'manifest.json'),pin(a.context/'lineage.json'),
        pin(out/'comparison.json'),pin(out/'contexts/report.json'),pin(old_path)],workloads=[],
        source=manifest['lineage']['source'],image=manifest['lineage']['image'],
        scope='Final N2 three-request diagnostic refresh. Earlier Phase130 profiles are separate historical blocks; performance conclusions use the independent interleaved timing screen.',
        limitations=['Physical leaf and active dispatch context distributions overlap; do not add their fractions.',
            'Private synchronous calls retain outer context; no inclusive stack, allocation-creation origin or complete source-call count.',
            'Entry counts are actual direct/factory dispatches only. They cannot identify repeated identical query keys.',
            'Named family buckets expose their exact owner names and are incomplete semantic approximations, not exclusive pipeline stages.',
            'Context-only and counter-enabled runtime overhead are reported separately.',
            'Source/compiler generations and diagnostic/clean captures are never pooled together.',
            'Zero observed samples is not proof of no cost. Minimum pooled sample/coverage gates remain explicit.'])
    select=['nc_bangs_names','nc_bangs_names_loop','nq_uses','nq_uses_list','p112s_prepare','p113pl_inspect_request',
        'p113pl_inspect_prepared','p126bp_close','p128raw_plan_finish','String.append','String.order','String.eq',
        'p111v_verify','p111v_get','p111v_name_chars','p88_number','p130m_word','p130mc_next']
    for name,variants in summary['workloads'].items():
        current,diagnostic=variants['phase131-final-n2'],variants['phase131-final-n2-context']
        prior=next(w for w in old['workloads'] if w['name']==name)
        ctx=next(w for w in contexts['workloads'] if w['name']==name)
        owner_fractions={x['owner']:x['periodWeightedFraction'] for x in ctx['contexts']}
        events_path=out/'contexts'/f'{name}-events.json';events=read(events_path)
        assert events['quality']['usableCounts'] and events['pairing']['verified']
        entries=Counter()
        for entry in events['entrySegmentDispatches']:
            if entry['role']=='direct_segment': entries[entry['loweredOwner']]+=entry['dispatches']
        group_rules=dict(bangAnalysis=r'^nc_bangs_', useQueries=r'^(?:nq_uses(?:_|$)|p131u_)',
            carrierDecoder=r'^(?:p88_|p130m)', strings=r'^String\.',
            qbeAndTextEmission=r'^(?:p111q_|p113e_|nt_text_)', independentVerifier=r'^p111v_')
        groups={k:dict(owners=[n for n in owner_fractions if re.search(rule,n)],
            periodWeightedFraction=sum(v for n,v in owner_fractions.items() if re.search(rule,n)),rule=rule)
            for k,rule in group_rules.items()}
        callers=Counter();weighted=0;accepted=[];rejected=[]
        run=read(a.physical/name/'report.json')
        for row in run['rows']:
            if row['mode']!='sample':continue
            path=verify(row['analysis']);analysis=read(path);reasons=capture_reasons(analysis)
            if reasons:rejected.append(dict(analysis=row['analysis'],reasons=reasons));continue
            joined,_=attribute(path,verify(row['callers']),verify(manifest['unwindTable']),None,a.context/'owners.json')
            assert joined['pairing']['verified'] and joined['pairing']['correct']
            period=analysis['header']['period_us'];weighted+=analysis['header']['samples']*period
            for cell in joined['matrix']:callers[cell['callerSymbol'] or '[unrecovered]']+=cell['samples']*period
            accepted.append(row['analysis'])
        result['workloads'].append(dict(name=name,identity=current['identity'],clean=current['clean'],
            physicalProfile=current['profile'],contextSamples=ctx['acceptedSamples'],contextAdequate=ctx['adequatePooledSamples'],
            rejectedContexts=ctx['rejected'],topActiveOwners=ctx['contexts'][:40],topContextLeaves=ctx['contextLeafMatrix'][:50],
            familyContexts=groups,selectedActiveFractions={n:owner_fractions.get(n,0) for n in select},
            selectedDirectEntries={n:entries[n] for n in select},topDirectEntries=entries.most_common(40),
            eventTotals=events['totals'],eventOwners=events['topOwnersPerCounter'],eventReceipt=pin(events_path),
            contextOnlyWallOverClean=diagnostic['contextOnlyOverCleanWallRatio'],countersWallOverClean=diagnostic['countersOverCleanWallRatio'],
            physicalCallerFractions=[dict(caller=k,periodWeightedFraction=v/weighted if weighted else None) for k,v in callers.most_common()],
            acceptedCallerCaptures=accepted,rejectedCallerCaptures=rejected,
            prior=dict(clean=prior['clean'],contextSamples=prior['contextSamples'],topActiveOwners=prior['topActiveOwners'][:15],eventTotals=prior['eventTotals']),
            eventDelta={k:v-prior['eventTotals'].get(k,0) for k,v in events['totals'].items()}))
    result['complete']=True;save(out/'report.json',result)
    lines=['# Final N2 profile refresh','',result['scope'],'',
        '| Request | Clean CPU s | Physical samples | Context samples | Context-only overhead | Counters overhead |',
        '|---|---:|---:|---:|---:|---:|']
    for w in result['workloads']:
        lines.append(f"| {w['name']} | {w['clean']['cpuSeconds']['median']:.4f} | {w['physicalProfile']['samples']} | {w['contextSamples']} | {w['contextOnlyWallOverClean']:.3f}× | {w['countersWallOverClean']:.3f}× |")
    for w in result['workloads']:
        lines += ['', '**'+w['name']+'**', '', 'Active lowered owners: '+', '.join(f"`{r['owner']}` {100*r['periodWeightedFraction']:.1f}%" for r in w['topActiveOwners'][:10])+'.', '',
            'Physical leaves: '+', '.join(f"`{r['decoded']}` {100*r['periodWeightedFraction']:.1f}%" for r in w['physicalProfile']['functions'][:8])+'.', '',
            '`nc_bangs_names` direct dispatch entries: '+str(w['selectedDirectEntries']['nc_bangs_names'])+
            '; observed active share '+f"{100*w['selectedActiveFractions']['nc_bangs_names']:.2f}%"+'. Private worker calls and equal query keys are not counted by this hook.']
    lines += ['', *['- '+x for x in result['limitations']],'','Complete identities, quality gates, counter owners and exact bucket membership are in `report.json`.']
    (out/'README.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(dict(complete=True,out=str(out),cases=[dict(name=w['name'],samples=w['physicalProfile']['samples'],contexts=w['contextSamples'],topOwners=w['topActiveOwners'][:5]) for w in result['workloads']])))


if __name__=='__main__':main()
