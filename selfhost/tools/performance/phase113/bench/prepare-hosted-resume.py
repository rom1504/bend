#!/usr/bin/env python3
"""Prepare a fresh hosted45 continuation from independently complete pairs only."""
import argparse
import fcntl
import importlib.util
import json
import os
from pathlib import Path
from types import SimpleNamespace

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('hosted45_frozen',HERE/'hosted45-v2.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
m,ROOT=h.m,h.ROOT


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan',type=Path,required=True)
    p.add_argument('--tag',default='p113-final31-hosted45-rest')
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    if a.out.exists():raise ValueError('Fresh continuation plan required')
    with (ROOT/'selfhost/build/phase32/execution.lock').open('a') as lock:
        try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:raise RuntimeError('Target guard still active; wait for it to finish before preparing continuation')
        for proc in Path('/proc').iterdir():
            if not proc.name.isdecimal() or int(proc.name)==os.getpid():continue
            try:words=(proc/'cmdline').read_bytes().split(b'\0')
            except OSError:continue
            if any(word.endswith(b'/guard.py') and b'performance/' in word for word in words):
                raise RuntimeError('Performance guard still running: '+proc.name)
        old=m.read(a.plan)
        if old.get('kind')!='phase113-hosted45-plan-v2':raise ValueError('Original version2 hosted45 plan required')
        for row in old['inputs']:m.verify(row)
        reports=m.read(m.verify(old['reportsMap']))
        completed={};pending=[]
        for name,pair in reports.items():
            status={}
            for role in ['emission','build']:
                path=(ROOT/pair[role]).resolve()
                row=m.read(path) if path.is_file() else {}
                status[role]=dict(complete=row.get('complete') is True,
                    receipt=m.pin(path) if path.is_file() else None)
            if all(row['complete'] for row in status.values()):completed[name]=pair
            else:pending.append(dict(name=name,priorStatus=status))
        if not completed or not pending:raise ValueError('Expected nonempty authenticated completed subset and pending programs')
        manifest=h.corpus()
        # This validates actual original source/Base/carrier, API pipeline and
        # transport, all emission stages, QBE/build flags, runtime and products.
        h.authenticate(completed,manifest,old['api'],old['runtime'],old['emitter'],
                       'p113-resume-auth',old['pipeline'],old['transportContract'])
        a.out.parent.mkdir(parents=True,exist_ok=True)
        reuse=a.out.with_name(a.out.stem+'-reuse.json')
        receipt=a.out.with_name(a.out.stem+'-resume.json')
        if reuse.exists() or receipt.exists():raise ValueError('Fresh continuation auxiliary paths required')
        m.save(reuse,completed)
        h.prepare(SimpleNamespace(api=Path(old['api']['file']),runtime=Path(old['runtime']['file']),
            pipeline=old['pipeline'],tag=a.tag,reuse_reports=reuse,out=a.out),manifest)
        fresh=m.read(a.out)
        m.save(receipt,dict(kind='phase113-hosted45-resume-preparation',complete=True,targetsRun=False,
            method=m.pin(__file__),originalPlan=m.pin(a.plan),continuedPlan=m.pin(a.out),
            priorReportsMap=old['reportsMap'],reuseMap=m.pin(reuse),combinedReportsMap=fresh['reportsMap'],
            completedNames=list(completed),pendingPrograms=pending,newJobCount=len(fresh['jobs']),
            scope='Original attempt remains failed/partial. Complete individual pairs independently authenticated and reused. Every pending program receives fresh emission/build paths; incomplete emissions are retained as evidence but not reused. Exact original45 sources/API/runtime/profile unchanged. Audit the new combined plan after continuation, not the old plan.'))
        print(json.dumps(dict(complete=True,targetsRun=False,plan=m.pin(a.out),resumeReceipt=m.pin(receipt),
            completedPrograms=len(completed),pendingPrograms=len(pending),jobs=len(fresh['jobs']))))


if __name__=='__main__':main()
