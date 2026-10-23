#!/usr/bin/env python3
"""Summarize fresh compact-carrier profiles beside historical Phase129 evidence.

Offline only. Different compiler/carrier samples are never pooled. Active-owner
contexts and physical leaves overlap; their percentages must not be added.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROF = ROOT/'selfhost/tools/profiler'
sys.path.insert(0, str(PROF))
from run import pin, save, verify
from compare import summarize_reports, capture_reasons
from attribute import attribute

SELECTED = ['p88_digits','p88_digit','p88_number','p88_field','p130m_word',
    'p130m_number_read','p130m_strings_read','p130mc_next','p130mc_number',
    'nq_uses','nq_uses_list','String.order','index_find','index_bucket',
    'index_insert','index_hash','p112s_prepare','p113pl_candidates',
    'p113pl_inspect_request','p113pl_inspect_prepared','p126bp_close']


def read(path): return json.loads(Path(path).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['physical','context','out']: ap.add_argument('--'+name,type=Path,required=True)
    a = ap.parse_args(); out = a.out.resolve(); assert not out.exists()
    manifest = read(a.physical/'manifest.json')
    selected = read(ROOT/'implementation/phase130/candidate.json')
    runtime_report = read(verify(selected['runtimeReport']))
    runtime_input = read(a.context/'runtime-input.json')
    assert runtime_input['runtime'] == runtime_report['source']
    verify(runtime_report['source'])
    for header in runtime_input['headers']:
        inherited = [p for p in runtime_report['inputs'] if Path(p['file']).name == Path(header['file']).name]
        assert inherited and all((p['bytes'],p['sha256']) == (header['bytes'],header['sha256']) for p in inherited)
        verify(header)
    reports = [directory/w['name']/'report.json'
        for directory in [a.physical,a.context] for w in manifest['workloads']]
    summary = summarize_reports(reports, baseline_variants={'phase130-context':'phase130'})
    out.mkdir(parents=True); save(out/'comparison.json',summary)
    # This existing adapter accepts arbitrary capture directories/owner maps.
    context_tool = ROOT/'selfhost/tools/performance/phase129/summarize-context.py'
    subprocess.run([sys.executable,'-B',str(context_tool),'--capture',str(a.context),
                    '--out',str(out/'contexts')],check=True,stdout=subprocess.DEVNULL)
    contexts = read(out/'contexts/report.json')
    historical_path = ROOT/'implementation/phase129/measurements.json'
    historical = read(historical_path)
    verify(selected['source'])
    decoder = set(historical['decoderNames']) | set(re.findall(
        r'^def (p130m\w*)\(',Path(selected['source']['file']).read_text(),re.M))
    result = dict(complete=False,targetsRun=False,inputs=[pin(__file__),pin(context_tool),
        pin(PROF/'compare.py'),pin(PROF/'attribute.py'),pin(historical_path),
        pin(out/'comparison.json'),pin(out/'contexts/report.json'),
        pin(ROOT/'implementation/phase130/candidate.json'),pin(a.context/'runtime-input.json'),
        selected['runtimeReport']],workloads=[],runtimeSourceAndHeadersAuthenticated=True,
        scope='Cold three-request diagnostic refresh, not broad/full-self-build measurement. Historical timings are not an interleaved causal comparison. No upstream speed ratio is newly measured.',
        limitations=['Physical categories and active-owner contexts overlap; do not sum them.',
            'Direct segment dispatches are not all source calls or repeated identical query keys.',
            'Private synchronous calls retain their outer active context.',
            'Counter instrumentation and context-only sampling have separate measured overhead.',
            'Amdahl ceilings assume complete removal of the selected measured work; real gains are smaller.',
            'Historical/new carrier and compiler identities differ; no cross-generation sample pooling.'])
    for name, variants in summary['workloads'].items():
        current, diagnostic = variants['phase130'],variants['phase130-context']
        prior = next(w for w in historical['workloads'] if w['name']==name)
        ctx = next(w for w in contexts['workloads'] if w['name']==name)
        owners = {r['owner']:r['periodWeightedFraction'] for r in ctx['contexts']}
        events_path = out/'contexts'/f'{name}-events.json'; events = read(events_path)
        assert events['quality']['usableCounts'] and events['pairing']['verified']
        entries = Counter()
        for e in events['entrySegmentDispatches']:
            if e['role']=='direct_segment': entries[e['loweredOwner']] += e['dispatches']
        sections = dict(decoder=sum(owners.get(n,0) for n in decoder),
            oldDecimal=sum(owners.get(n,0) for n in ['p88_digits','p88_digit','p88_number']),
            useQuery=sum(owners.get(n,0) for n in ['nq_uses','nq_uses_list']),
            stringOrder=owners.get('String.order',0),
            index=sum(owners.get(n,0) for n in ['index_find','index_bucket','index_insert','index_hash']))
        # Recover register-copy callers in the original image separately from
        # diagnostic ownership contexts. All samples stay in the denominator.
        callers, weighted, accepted, rejected = Counter(),0,[],[]
        run = read(a.physical/name/'report.json')
        for row in run['rows']:
            if row['mode']!='sample': continue
            analysis_path=verify(row['analysis']); analysis=read(analysis_path)
            reasons=capture_reasons(analysis)
            if reasons:
                rejected.append(dict(analysis=row['analysis'],reasons=reasons));continue
            joined,_ = attribute(analysis_path,verify(row['callers']),
                verify(manifest['unwindTable']),None,a.context/'owners.json')
            assert joined['pairing']['verified'] and joined['pairing']['correct']
            period=analysis['header']['period_us']; weighted += analysis['header']['samples']*period
            for cell in joined['matrix']:
                callers[cell['callerSymbol'] or '[unrecovered]'] += cell['samples']*period
            accepted.append(row['analysis'])
        profile=current['profile']
        result['workloads'].append(dict(name=name,identity=current['identity'],
            clean=current['clean'],physicalProfile=profile,
            contextSamples=ctx['acceptedSamples'],contextAdequate=ctx['adequatePooledSamples'],
            rejectedContextCaptures=ctx['rejected'],contextFractions=sections,
            topActiveOwners=ctx['contexts'][:40],topContextLeaves=ctx['contextLeafMatrix'][:50],
            contextOnlyWallOverClean=diagnostic['contextOnlyOverCleanWallRatio'],
            countersWallOverClean=diagnostic['countersOverCleanWallRatio'],
            eventTotals=events['totals'],selectedDirectEntries={n:entries[n] for n in SELECTED},
            topDirectEntries=entries.most_common(35),eventOwners=events['topOwnersPerCounter'],
            eventReceipt=pin(events_path),
            physicalCallerFractions=[dict(caller=k,periodWeightedFraction=v/weighted if weighted else None)
                for k,v in callers.most_common()],acceptedCallerCaptures=accepted,rejectedCallerCaptures=rejected,
            historical=dict(cleanWallSeconds=prior['cleanWallSeconds'],
                cleanCpuSeconds=prior['cleanCpuSeconds'],physicalGroups=prior['physicalGroups'],
                contextFractions={key:prior[key+'ContextFraction'] for key in
                    ['decoder','decimal','useQuery','stringOrder','index']},eventTotals=prior['eventTotals']),
            historicalWallRatio=current['clean']['wallSeconds']['median']/prior['cleanWallSeconds'],
            eventDelta={k:events['totals'].get(k,0)-v for k,v in prior['eventTotals'].items()}))
    result['complete']=True;save(out/'report.json',result)
    print(json.dumps(dict(complete=True,out=str(out),rows=[dict(name=w['name'],
        cleanWallSeconds=w['clean']['wallSeconds']['median'],samples=w['physicalProfile']['samples'],
        contexts=w['contextFractions']) for w in result['workloads']])))


if __name__=='__main__': main()
