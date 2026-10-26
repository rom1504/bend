#!/usr/bin/env python3
"""Read all scoped guard receipts; report summed, overlapping and pending costs.

Metadata only. No process launch, benchmark, compiler or source mutation.
"""
import argparse, datetime, hashlib, json, math, re, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
CATEGORIES = ['profile', 'acquisition', 'checks', 'measurement', 'nativeQualification', 'unknown']

def pinned_read(path):
    data=path.read_bytes()
    return json.loads(data),dict(file=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def union(intervals):
    merged=[]
    for start,end in sorted(intervals):
        if merged and start<=merged[-1][1]:merged[-1][1]=max(end,merged[-1][1])
        else:merged.append([start,end])
    return dict(seconds=sum(b-a for a,b in merged),intervals=merged)

def category(path,command):
    """One auditable primary action per receipt; mixed commands remain inclusive."""
    p=str(path).lower();cmd=' '.join(command).lower()
    if re.search(r'/p144-final[0-9]+-q3-guard/process\.json$',p):
        return 'nativeQualification','third-image full self-reproduction against exact Q2 oracle'
    if 'host-smokes' in p or '/host-smokes-' in cmd:
        return 'nativeQualification','native host/IO/runtime smoke qualification, including failed attempts'
    if re.search(r'focused19|full45|reproduc|(?:^|[/_-])n[23](?:[/_-]|$)|self0[0-9]|native45|wrapper',p):
        return 'nativeQualification','qualification path: reproduction/focused/ordinary corpus'
    if '/emission/string-append/profile/observe-' in cmd:
        return 'profile','runtime concat event observer with retained diagnostic bindings'
    if '/profiler/' in cmd or any(k in p for k in ['/profile01/','/stages01/','/stages02/','/integrated-stages01/','/generic-gate01/']):
        return 'profile','profiler/stage capture or diagnostic preparation'
    if '/p144-chooser-laws' in p or '--check-only' in cmd:
        return 'checks','source/kernel law check or explicit check-only'
    if '/emission/string-append/emit-' in cmd:
        return 'acquisition','checked hosted emitter acquiring complete small QBE products'
    if any(k in cmd for k in ['check-api','minimal-check','acquire-native','pipe-build','build-native','build-image','build-aligned','native-build','/build-v','/integrated-relink','/emit-pipe']):
        return 'acquisition','checked API/compiler/machine/runtime acquisition command'
    if any(k in p for k in ['-api','/api-','-acquire','-build','/build-','upstream-c-source','upstream-c-emit','/matched-emission-','final03-n1-']):
        return 'acquisition','artifact acquisition path'
    if '/native-profile-plan02/native-' in p and '/phase130/native-request.py' in cmd and '--expected-qbe' in command:
        return 'checks','packaged native compiler exact-output request checks, not a sample capture'
    if any(k in p for k in ['fast-fixed142-latency-guard','range-produced-latency-plan']) or any(k in cmd for k in ['/existence/screen-','/emission/transport/fast-request-']):
        return 'measurement','explicit native latency, transfer or complete existence-consumer experiment'
    if ('programs-' in p or '/programs/' in cmd) and any(k in p or k in cmd for k in ['measure','resume','recheck']):
        return 'measurement','generated-program runtime campaign/recheck/resume; partial deadline costs retained'
    if any(k in p for k in ['finite','controls','oracle','-check','/check-','safety','relink-full','byte-comparison','-identity','inspect']):
        return 'checks','finite, oracle, identity, safety or inspection path'
    if any(k in p for k in ['timing','-times','-screen','census','range-second-pass','fixed-cold','hosted-','serial-small','runtime-batches','-batch-','-session-','ordinary-']):
        return 'measurement','timing/component/census/request measurement path'
    if any(k in p for k in ['-emit','/new-emit','/old-emit','byte-baseline','byte-candidate','upstream-arity']):
        return 'acquisition','generated product or backend acquisition path'
    if 'render-capture' in p:
        return 'profile','renderer extraction/diagnostic capture'
    return 'unknown','no explicit rule; do not silently assign measurement'

def discover():
    files=set((ROOT/'selfhost/build/phase144').rglob('process.json'))
    scopes=['All process.json recursively below selfhost/build/phase144 (no guard-name suffix filter)']
    # Phase144 authorities outside its own output directory. Scan only matching
    # immediate directories, not all historical build trees or artifact contents.
    for phase in ['phase111','phase131']:
        base=ROOT/'selfhost/build'/phase
        for directory in base.iterdir() if base.exists() else []:
            if directory.is_dir() and re.search(r'(^|[-_])p144(?:[-_]|$)',directory.name):
                files.update(directory.rglob('process.json'))
        scopes.append(f'All process.json below immediate p144-tagged directories of selfhost/build/{phase}')
    return sorted(files),scopes

def expected_negative(path,receipt):
    if path.parent.name!='kernel-negative':return None
    report=path.parent.parent/'report.json'
    if not report.exists():return None
    document,identity=pinned_read(report)
    row=document.get('rows',{}).get('kernel-negative',{})
    if (document.get('complete') and document.get('independentlyChecked') and
        row.get('process')==receipt and receipt.get('returncode')==1 and
        'SOME PROOFS FAIL' in row.get('stdout','')):
        return identity
    return None

def load_row(path):
    try:document,identity=pinned_read(path)
    except (ValueError,OSError) as error:
        return dict(path=str(path),status='unreadable',error=type(error).__name__+': '+str(error)[:200])
    started=document.get('started');finished=document.get('finished');wall=document.get('wallSeconds')
    finite=lambda x:isinstance(x,(float,int)) and math.isfinite(x)
    closed=finite(started) and finite(finished) and finite(wall) and finished>=started and wall>=0
    name=str(path.relative_to(ROOT/'selfhost/build'));kind,basis=category(name,document.get('command',[]))
    expected=expected_negative(path,document) if closed else None
    status=('passed' if document.get('complete') and document.get('returncode')==0 else
            'expectedNegative' if expected else 'failed') if closed else 'pendingOrUnclosed'
    stop=document.get('stoppedFor')
    return dict(path=name,receipt=identity,category=kind,categoryBasis=basis,status=status,
                command=document.get('command'),start=started,end=finished if closed else None,
                seconds=wall if closed else None,reportedWallSeconds=wall,
                returncode=document.get('returncode'),stoppedFor=stop,
                resourceStop=stop in ['tree-rss-limit','available-memory-floor'],
                memoryStopEvidence='guard enforced limit, not proof of kernel OOM' if stop in ['tree-rss-limit','available-memory-floor'] else None,
                peakTreeRssBytes=document.get('peakTreeRssBytes'),minimumAvailableBytes=document.get('minimumAvailableBytes'),
                rssLimitBytes=document.get('rssLimitBytes'),availableFloorBytes=document.get('availableFloorBytes'),
                intervalClockDifferenceSeconds=(finished-started-wall) if closed else None,
                expectedNegativeAuthority=expected)

def summarize(rows):
    closed=[r for r in rows if r['status'] in ['passed','failed','expectedNegative']]
    intervals=union([(r['start'],r['end']) for r in closed]);total=sum(r['seconds'] for r in closed)
    span=(max(r['end'] for r in closed)-min(r['start'] for r in closed)) if closed else 0
    categories={}
    for cat in CATEGORIES:
        rs=[r for r in rows if r.get('category')==cat];done=[r for r in rs if r in closed]
        categories[cat]=dict(receipts=len(rs),closed=len(done),pending=len(rs)-len(done),
            summedGuardSeconds=sum(r['seconds'] for r in done),
            intervalUnionSeconds=union([(r['start'],r['end']) for r in done])['seconds'],
            failedSeconds=sum(r['seconds'] for r in done if r['status']=='failed'))
    nested=[]
    for i,r in enumerate(closed):
        containers=[q for j,q in enumerate(closed) if i!=j and q['start']<=r['start'] and r['end']<=q['end'] and (q['start'],q['end'])!=(r['start'],r['end'])]
        if containers:nested.append(dict(receipt=r['path'],inside=min(containers,key=lambda q:q['end']-q['start'])['path']))
    return dict(receipts=len(rows),closed=len(closed),pending=sum(r['status']=='pendingOrUnclosed' for r in rows),
        unreadable=sum(r['status']=='unreadable' for r in rows),failed=sum(r['status']=='failed' for r in closed),
        expectedNegative=sum(r['status']=='expectedNegative' for r in closed),
        summedGuardSeconds=total,guardIntervalUnion=intervals,closedGuardSpanSeconds=span,
        timeOutsideClosedGuardUnionWithinSpanSeconds=span-intervals['seconds'],
        summedIntervalSeconds=sum(r['end']-r['start'] for r in closed),
        overlapAndNestingSeconds=sum(r['end']-r['start'] for r in closed)-intervals['seconds'],
        failedGuardSeconds=sum(r['seconds'] for r in closed if r['status']=='failed'),
        nonzeroOrFailedGuardSeconds=sum(r['seconds'] for r in closed if r['status']!='passed'),
        expectedNegativeSeconds=sum(r['seconds'] for r in closed if r['status']=='expectedNegative'),
        resourceStopSeconds=sum(r['seconds'] for r in closed if r['resourceStop']),
        resourceStops=[r['path'] for r in closed if r['resourceStop']],nestedIntervals=nested,
        peakTreeRssBytes=max((r['peakTreeRssBytes'] for r in rows if r.get('peakTreeRssBytes') is not None),default=None),
        minimumAvailableBytes=min((r['minimumAvailableBytes'] for r in rows if r.get('minimumAvailableBytes') is not None),default=None),
        categories=categories)

def markdown(result):
    s=result['summary'];lines=['# Phase144 guarded-work cost snapshot','',
        f"As of {result['observedFinishedUtc']}: {s['closed']} closed receipts, {s['pending']} pending/unclosed, {s['unreadable']} unreadable.",
        f"Summed guarded wall: {s['summedGuardSeconds']/60:.2f} min. Interval union: {s['guardIntervalUnion']['seconds']/60:.2f} min.",
        f"Unexpected failed-command wall: {s['failedGuardSeconds']/60:.2f} min; expected negative checks: {s['expectedNegativeSeconds']:.3f} s.",
        '', '| Category | Closed/pending | Sum seconds | Union seconds | Failed seconds |', '| --- | ---: | ---: | ---: | ---: |']
    for name,v in s['categories'].items():lines.append(f"| {name} | {v['closed']}/{v['pending']} | {v['summedGuardSeconds']:.2f} | {v['intervalUnionSeconds']:.2f} | {v['failedSeconds']:.2f} |")
    lines+=['', 'Category sums include inclusive multi-action guards. Category unions may overlap and must not be added.', '',
        'A pending receipt has unknown final duration; it is excluded from closed totals, never charged zero.',
        'Guard wall includes supervised preparation, target work and validation. Its sum is not CPU compute or agent quota.',
        'Time outside the guard union is unobserved by these receipts. It is not a measurement of agent reasoning, idle time or quota.',
        'RSS-limit termination is recorded separately; it does not establish a kernel OOM.', '']
    return '\n'.join(lines)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--markdown',type=Path);p.add_argument('--require-closed',action='store_true');a=p.parse_args()
    outputs=[x.resolve() for x in [a.out,a.markdown] if x]
    assert all(not x.exists() and x.is_relative_to(ROOT) for x in outputs),'Fresh repository outputs required'
    start=time.time();files,scopes=discover();rows=[load_row(path) for path in files];finish=time.time()
    changed=[r['path'] for r in rows if 'receipt' in r and pin(Path(r['receipt']['file']))!=r['receipt']]
    summary=summarize(rows);complete=not(summary['pending'] or summary['unreadable'] or changed)
    result=dict(kind='phase144-guard-cost-ledger-v3',complete=complete,snapshotComplete=True,targetsRun=False,
        observedStartedUnix=start,observedFinishedUnix=finish,
        observedFinishedUtc=datetime.datetime.fromtimestamp(finish,datetime.timezone.utc).isoformat(),
        inputs=[pin(Path(__file__)),pin(Path(__file__).with_name('costs-v02.py')),pin(Path(__file__).with_name('costs-v01.py'))],discovery=scopes,changedDuringSnapshot=changed,summary=summary,rows=rows,
        limits=['Only guarded work in the declared discovery scope is measured; unguarded tools/agent effort/quota are not reconstructed.',
                'One receipt can encompass compilation, checking and measurement; primary category describes purpose, not exclusive inner costs.',
                'Summed wall double counts overlapping/nested guards; interval union describes covered wall, not processor compute.',
                'Failed guards may be harness failures, deadlines or rejected experiments, not compiler semantic failures.',
                'A partial runtime campaign and its resumed campaign are separate guarded costs; reuse of successful observations never removes the original elapsed work.',
                'Existing process files without final receipt are pending/unclosed; no invented duration or zero-cost completion.',
                'Category classification is a visible heuristic; unknown remains explicit. Inspect command and categoryBasis before interpreting.',
                'Peak process-tree RSS is a per-guard maximum, not an additive campaign memory measurement.'])
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    if a.markdown:a.markdown.parent.mkdir(parents=True,exist_ok=True);a.markdown.write_text(markdown(result))
    print(json.dumps(dict(complete=complete,out=str(a.out),summary={k:v for k,v in summary.items() if k not in ['guardIntervalUnion','nestedIntervals']}),indent=2))
    return 0 if complete or not a.require_closed else 1

if __name__=='__main__':raise SystemExit(main())
