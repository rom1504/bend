#!/usr/bin/env python3
"""Compact evidence join; raw diagnostics remain independently identified."""
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase68'
OUT=ROOT/'implementation/phase68/evidence/c23-parity-survey.json'

def pin(p):
    p=Path(p).resolve();b=p.read_bytes()
    return dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))

def read(p):return json.loads(Path(p).read_text())

def decode(s):
    return re.sub(r'FID_((?:\d+_)+)',lambda m:''.join(chr(int(x)) for x in m[1].split('_') if x),s)

def contexts(code):
    pattern=r'^(?:INLINE|NF_INLINE|OUTLINE|FAR|static)\s+[^\n;]*?\b(\w+)\([^;\n]*\)\s*\{|^\s*WL_CASE\((\w+)\)'
    return [(code.count('\n',0,m.start())+1,decode(m[1] or m[2])) for m in re.finditer(pattern,code,re.M)]

def main():
    inputs=[pin(__file__)]
    def load(name,complete=True):
        p=RAW/name/'report.json';d=read(p);inputs.append(pin(p))
        if complete:assert d['complete'],name
        if d.get('plan'):
            q=Path(d['plan']['path']);assert pin(q)['sha256']==d['plan']['sha256'];inputs.append(pin(q))
        return d
    counted=load('parity-survey23-counts01')
    countrows=[]
    for row in counted['records']:
        assert row['complete'] and all(x['correct'] for x in row['runs'])
        low,high=row['runs']
        delta={k:high['counts'][k]-v for k,v in low['counts'].items() if isinstance(v,int)}
        sites=[b-a for a,b in zip(low['allocationSites'],high['allocationSites'])]
        assert sum(sites)==delta['heapAllocCalls']
        original=Path(row['job']['source']['path']);assert pin(original)['sha256']==row['job']['source']['sha256']
        owners=contexts(original.read_text())
        selected=[]
        for site,n in sorted(zip(row['sites'],sites),key=lambda x:-x[1])[:15]:
            owner=next((name for line,name in reversed(owners) if line<=site['sourceLine']),'unknown')
            selected.append(dict(**site,calls=n,owner=owner,percentAllocations=100*n/delta['heapAllocCalls']))
        segments=[]
        for s in row['segments']:
            k=str(s['index']);n=high['counts']['segments'].get(k,0)-low['counts']['segments'].get(k,0)
            if n:segments.append(dict(name=decode(s['symbol']),entries=n))
        countrows.append(dict(case=row['job']['case'],role=row['job']['role'],source=pin(original),delta=delta,
            allocationSiteSum=sum(sites),topAllocationSites=selected,topSegments=sorted(segments,key=lambda x:-x['entries'])[:15]))
    profiles=[]
    for folder in ('parity-survey23-samples03','parity-survey23-thread-samples02'):
        d=load(folder)
        for r in d['records']:
            assert r['correct']
            ap=Path(r['analysis']['path']);assert pin(ap)['sha256']==r['analysis']['sha256'];inputs.append(pin(ap))
            a=read(ap);h=a['header']
            p=dict(campaign=folder,case=r['job']['case'],role=r['job']['role'],periodUs=r['job']['periodUs'],
                repetitions=r['job']['repetitions'],samples=h['samples'],overruns=h['overruns'],dropped=h['dropped'],
                mainProcessCpuRatio=h['main_thread_cpu_ns']/int(h['process_cpu_ns']),
                usable=r['broadCoverage'],categories=a['categories'],analysis=pin(ap),
                leafFunctions=[dict(x,name=decode(x['name'])) for x in a['leaf_functions'][:15]],
                leafLocations=[dict(x,name=decode(x['name'])) for x in a['leaf_locations'][:15]])
            if a.get('coverage'):p['coverage']=a['coverage']
            profiles.append(p)
    bang=load('parity-survey23-bangs02')
    assert len(bang['records'])==18 and all(x['qualified'] for x in bang['records'])
    assert len(bang['controls'])==6 and all(x['correct'] for x in bang['controls'])
    debug=load('parity-survey23-debug01')
    assert len(debug['records'])==12 and all(x['textIdentical'] for x in debug['records'])
    mode=load('parity-survey23-mode-counts01')
    modecounts=[]
    for r in mode['records']:
        assert r['complete'] and all(x['correct'] for x in r['runs'])
        lo,hi=r['runs']
        delta={k:hi['counts'][k]-v for k,v in lo['counts'].items() if isinstance(v,int)}
        modecounts.append(dict(case=r['job']['case'],delta=delta))
    overhead=load('parity-survey23-profile-overhead01')
    assert len(overhead['records'])==9 and all(r['correct'] for r in overhead['records'])
    static=load('parity-survey23-static-study01')
    assert len(static['records'])==25 and all(r['qualified'] for r in static['records'])
    assert len(static['controls'])==6 and all(r['correct'] for r in static['controls'])
    static_count_report=load('parity-survey23-static-counts01')
    assert len(static_count_report['records'])==1
    static_count=static_count_report['records'][0]
    assert static_count['complete'] and all(r['correct'] for r in static_count['runs'])
    lo,hi=static_count['runs']
    static_delta={k:hi['counts'][k]-v for k,v in lo['counts'].items() if isinstance(v,int)}
    assert sum(b-a for a,b in zip(lo['allocationSites'],hi['allocationSites']))==static_delta['heapAllocCalls']
    original_lexer=next(r['delta'] for r in countrows if r['case']=='lexer' and r['role']=='selfhost')
    allocation_removed=original_lexer['heapAllocCalls']-static_delta['heapAllocCalls']
    redirects_removed=original_lexer['rfcWrapCalls']-static_delta['rfcWrapCalls']
    assert (allocation_removed,redirects_removed)==(473088,233472)
    med=static['mediansMs']
    static_summary=dict(mediansMs=med,timings=25,controls=6,
        ratiosToOriginal={k:v/med['selfhost'] for k,v in med.items()},
        ratiosToUpstream={k:v/med['upstream'] for k,v in med.items()},
        staticOnlyCounts=static_delta,allocationsRemoved=allocation_removed,redirectsRemoved=redirects_removed,
        allClocks=[{k:r[k] for k in ('role','round','elapsedMs')} for r in static['records']])
    processes=[]
    for directory in sorted(RAW.glob('parity-survey23*')):
        for path in sorted(directory.rglob('process.json')):
            row=read(path)
            if 'wallSeconds' not in row:continue
            command=row.get('command',[])
            if any(Path(str(x)).name in ('clang','clang-22') for x in command):kind='native compilation'
            elif any(Path(str(x)).name in ('addr2line','readelf','objcopy','objdump') for x in command):kind='binary analysis'
            elif any(str(x).endswith('sample-analysis.py') or str(x).endswith('sample-analysis-v2.py') for x in command):kind='sample analysis'
            else:kind='native execution and probes'
            processes.append(dict(path=str(path.relative_to(ROOT)),kind=kind,complete=row['complete'],wallSeconds=row['wallSeconds'],
                started=row.get('started'),finished=row.get('finished'),peakTreeRssBytes=row.get('peakTreeRssBytes',0)))
    account=dict(processes=len(processes),guardedProcessWallSeconds=sum(p['wallSeconds'] for p in processes),
        wallSecondsByKind={k:sum(p['wallSeconds'] for p in processes if p['kind']==k) for k in sorted({p['kind'] for p in processes})},
        maxTreeRssBytes=max(p['peakTreeRssBytes'] for p in processes),firstStart=min(p['started'] for p in processes),
        lastFinish=max(p['finished'] for p in processes),
        scope='Sum of unique guarded process receipt wall times, including failed attempts. Not total human/agent effort or token/quota accounting.',
        receipts=processes)
    failures=[]
    for name in ('parity-survey23-samples01','parity-survey23-samples02','parity-survey23-thread-samples01','parity-survey23-bangs01'):
        d=load(name,False);failures.append(dict(attempt=name,complete=d['complete'],error=d.get('error')))
    result=dict(schema='phase68-c23-parity-survey-v1',complete=True,
        scope='Investigation and saved-C diagnostic only. Compiler/installed release unchanged. Six families; no whole-language parity claim.',
        counts=countrows,profiles=profiles,bangMode=dict(rows=bang['rows'],timings=len(bang['records']),controls=len(bang['controls']),modeCounts=modecounts,
            allClocks=[{k:x[k] for k in ('case','role','round','elapsedMs')} for x in bang['records']]),
        debugTextIdentity=dict(programs=12,allExact=True),failures=failures,staticData=static_summary,timeAccount=account,
        profilerOverhead=[dict(case=r['job']['case'],role=r['job']['role'],mode=r['mode'],elapsedMs=r['elapsedMs']) for r in overhead['records']],
        inputs=list({x['path']:x for x in inputs}.values()),
        limitations=['Counts are instrumented source-operation frequency, not optimized instructions/time.',
            '17 minus1 repetitions adds sixteen inputs plus changed digest/formatting work.',
            'Sampled timings never support speed ratios; startup/shutdown included; per-role repetitions differ by complete input cycles.',
            'Timer delivery is coarser than requested; overruns are recorded, not attributed to sampled PCs.',
            'Main-only tree/lexer candidate profiles lack coverage; use all-thread successors.',
            'Saved-C BANGS0 changes runtime mode only; does not implement reachable-bang analysis or qualify raw/foreign/GPU behavior.',
            'Prior six-family1.724x and fresh saved-C mode/static campaigns are different timing campaigns.',
            'Static-data variants are pinned fixture-specific causality interventions, not a general compiler implementation.'])
    OUT.parent.mkdir(parents=True,exist_ok=True);OUT.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(output=str(OUT),counts=len(countrows),profiles=len(profiles),bang=bang['rows'])))

if __name__=='__main__':main()
