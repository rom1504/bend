#!/usr/bin/env python3
"""Report Phase114 recorded guard interval unions, with no idle/quota inference."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--start',required=True);p.add_argument('--until',required=True,help='UTC ISO timestamp or now')
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    if a.out.exists():raise ValueError('Fresh accounting receipt required')
    binding_path=HERE/'native-binding01.json';binding=json.loads(binding_path.read_text());expected=binding['accountingHelper']
    method=ROOT/expected['file'];raw=method.read_bytes()
    if len(raw)!=expected['bytes'] or hashlib.sha256(raw).hexdigest()!=expected['sha256']:raise ValueError('Accounting helper changed')
    spec=importlib.util.spec_from_file_location('phase114_original_interval_helpers',method)
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    captured=time.time();start=m.timestamp(a.start);until=captured if a.until=='now' else m.timestamp(a.until)
    if start is None or until is None or not start<until<=captured+1:raise ValueError('Require start < cutoff <= now')
    roots=[ROOT/'selfhost/build/phase114']
    for phase in ['phase111','phase112','phase113']:
        roots += sorted(path for path in (ROOT/'selfhost/build'/phase).glob('p114-*') if path.is_dir())
    rows=[];pending=[];inputs=[]
    for path in sorted({path for root in roots for path in root.rglob('process.json')}):
        report,pin=m.read(path);begin=m.timestamp(report.get('started'));end=m.timestamp(report.get('finished'))
        if begin is None or begin>=until or (end is not None and end<=start):continue
        inputs.append(pin)
        row=dict(receipt=pin,startUtc=m.iso(begin),command=report.get('command',[]),success=report.get('complete') is True,
                 returncode=report.get('returncode'),guardReportedSeconds=report.get('wallSeconds'))
        if end is None:
            row.update(status='no recorded finish',potentialWindowSeconds=until-max(start,begin));pending.append(row);continue
        if end<begin:raise ValueError('Invalid guard interval: '+str(path))
        lo,hi=max(start,begin),min(until,end)
        row.update(finishUtc=m.iso(end),interval=[lo,hi],seconds=hi-lo,finishedByCutoff=end<=until);rows.append(row)
    intervals=[row['interval'] for row in rows];occupied=m.seconds(intervals);summed=sum(row['seconds'] for row in rows)
    failed=[row['interval'] for row in rows if not row['success']]
    result=dict(kind='phase114-recorded-guard-occupancy',targetsRun=False,startUtc=m.iso(start),cutoffUtc=m.iso(until),capturedUtc=m.iso(captured),
        elapsedSeconds=until-start,recordedFinishedGuardUnionSeconds=occupied,guardIntervalSumSeconds=summed,
        guardOverlapSeconds=summed-occupied,outsideRecordedFinishedGuardSeconds=until-start-occupied,
        failedGuardUnionSeconds=m.seconds(failed),guards=rows,pendingGuards=pending,inputs=inputs,
        method=dict(file=str(Path(__file__).resolve().relative_to(ROOT)),
            bytes=Path(__file__).stat().st_size,sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
        intervalHelper=expected,binding=dict(file=str(binding_path.relative_to(ROOT)),bytes=binding_path.stat().st_size,sha256=hashlib.sha256(binding_path.read_bytes()).hexdigest()),
        scopeRoots=[str(path.relative_to(ROOT)) for path in roots],
        limitations=['Only recorded guard envelopes with a finish count; failures count too. Pending guards are listed without invented finish times.',
          'Intervals are clipped to the requested window and unioned. Nested and overlapping guards are not added twice.',
          'Outside recorded completed guards is unattributed time, not measured idle time: source work, analysis, scheduling, unguarded work and pending guards remain unresolved.',
          'No CPU-time, agent labor, quota compliance, category allocation or waiting-time claim follows from these wall intervals. No heuristic category labels are assigned.'])
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:result[key] for key in ['elapsedSeconds','recordedFinishedGuardUnionSeconds','guardOverlapSeconds','outsideRecordedFinishedGuardSeconds','failedGuardUnionSeconds']}))


if __name__=='__main__':main()
