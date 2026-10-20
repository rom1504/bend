#!/usr/bin/env python3
"""Seal selected final31 JSON receipts after all guards exit; no target execution."""
import argparse
from datetime import datetime, timezone
import fcntl
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import tarfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('native_pin_tools',ROOT/'selfhost/tools/performance/phase111/native-emit.py')
native=importlib.util.module_from_spec(spec);spec.loader.exec_module(native)
pin=native.pin


def read(path):return json.loads(Path(path).read_text())


def refs(value, base=ROOT):
    if isinstance(value,dict):
        file=value.get('file',value.get('path'))
        if isinstance(file,str) and isinstance(value.get('bytes'),int) and isinstance(value.get('sha256'),str):
            yield dict(file=str((base/file).resolve()),bytes=value['bytes'],sha256=value['sha256'])
        for child in value.values():yield from refs(child, base)
    elif isinstance(value,list):
        for child in value:yield from refs(child, base)


def assert_no_guards():
    for proc in Path('/proc').iterdir():
        if not proc.name.isdecimal() or int(proc.name)==os.getpid():continue
        try:words=(proc/'cmdline').read_bytes().split(b'\0')
        except (OSError,ProcessLookupError):continue
        if any(word.endswith(b'/guard.py') and b'performance/' in word for word in words):
            raise RuntimeError('A performance guard is still running, PID '+proc.name)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan',type=Path,default=HERE/'final31-evidence-plan.json')
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    if a.out.exists():raise ValueError('Fresh capsule directory required')
    plan=read(a.plan)
    if plan.get('kind')!='phase113-final31-json-evidence-selection':raise ValueError('Exact final31 evidence plan required')
    # Hold the same lock as every guarded target for the entire snapshot. Run
    # this outside a guard; merely observing an unlocked file would race.
    with (ROOT/'selfhost/build/phase32/execution.lock').open('a') as lock:
        try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:raise RuntimeError('A target guard owns the execution lock; do not collect live receipts')
        assert_no_guards()
        for rel in plan['knownAbsentNativeImages']:
            if (ROOT/rel).exists():raise ValueError('Unexpected native image; this failure-specific plan must be reviewed: '+rel)
        failed=read(ROOT/'selfhost/build/phase113/p113-final31-qualification-guard/process.json')
        if failed.get('complete') is not False or 'finished' not in failed:
            raise ValueError('Ended failed native acquisition receipt required')
        six=read(ROOT/'selfhost/build/phase112/p113-final31-screen/report.json')
        if six.get('rounds')!=3 or len(six.get('cases',[]))!=6:
            raise ValueError('Original paired-three-round six-case screen required')
        controls=read(ROOT/'selfhost/build/phase113/width-wide30-31-native/report.json')
        if len(controls.get('jobs',[]))!=80:
            raise ValueError('Expected actual80-job run; jobs are not80 independent controls')
        selected={a.plan.resolve()}
        missing=[]
        def add(path,required=False):
            path=Path(path).resolve()
            if path.is_file():
                if path.suffix=='.json':selected.add(path)
                elif required:raise ValueError('JSON files only: '+str(path))
            elif required:missing.append(str(path))
        def tree(path):
            path=Path(path).resolve()
            if path.is_dir():
                if a.out.resolve().is_relative_to(path):raise ValueError('Capsule destination intersects selected tree')
                selected.update(path.rglob('*.json'))
        for rel in plan['requiredFiles']:add(ROOT/rel,True)
        for rel in plan['optionalFiles']:add(ROOT/rel)
        for rel in plan['jsonTrees']:tree(ROOT/rel)
        job_plans=plan['jobPlans']+[rel for rel in plan.get('optionalJobPlans',[]) if (ROOT/rel).is_file()]
        for rel in job_plans:
            path=ROOT/rel;add(path,True)
            for job in read(path)['jobs']:
                for word in job['command']:
                    candidate=(ROOT/str(word)).resolve()
                    if candidate.is_relative_to(ROOT/'selfhost/build'):
                        if candidate.is_dir():tree(candidate)
                        elif candidate.suffix=='.json':add(candidate)
                    elif candidate.is_relative_to(ROOT/'selfhost/tools/performance/phase113') and candidate.suffix=='.json':add(candidate)
        report_maps=plan['reportMaps']+[rel for rel in plan.get('optionalReportMaps',[]) if (ROOT/rel).is_file()]
        for rel in report_maps:
            path=ROOT/rel;add(path,True)
            for row in read(path).values():
                # The original map may include unfinished products. Preserve
                # every existing original receipt; require all combined pairs.
                combined=bool(plan.get('optionalReportMaps')) and rel in plan.get('optionalReportMaps',[])
                for report in row.values() if isinstance(row,dict) else [row]:
                    add(ROOT/report,combined or not any((ROOT/p).is_file() for p in plan.get('optionalReportMaps',[])))
        if missing:raise ValueError('Missing required JSON receipts: '+json.dumps(missing))
        raw_total=0;payload=[];references={};values={}
        for path in sorted(selected):
            raw=path.read_bytes();value=json.loads(raw);info=pin(path)
            if len(raw)!=info['bytes'] or hashlib.sha256(raw).hexdigest()!=info['sha256']:
                raise ValueError('Receipt changed during read: '+str(path))
            if len(raw)>plan['maximumSingleJsonBytes']:raise ValueError('Oversize JSON: '+str(path))
            raw_total+=len(raw)
            if raw_total>plan['maximumRawJsonBytes']:raise ValueError('Raw JSON ceiling exceeded; review explicit selection')
            if path.name=='process.json' and 'finished' not in value:raise ValueError('Unfinished guard receipt: '+str(path))
            member='receipts/'+path.relative_to(ROOT).as_posix()
            payload.append((dict(member=member,**info),raw));values[str(path)]=value
            # Interim03 explicitly stores file names relative to its index.
            # Ordinary experiment receipts use absolute/repository paths.
            reference_base = path.parent if isinstance(value, dict) and value.get('kind') == 'phase113-interim03-bounded-receipt-capsule' else ROOT
            for row in refs(value, reference_base):references[(row['file'],row['sha256'],row['bytes'])]=row
        # Record all references, including superseded/missing historical files.
        # Only receipts are copied; no missing dependency is claimed preserved.
        actual={}
        for row in references.values():
            file=row['file']
            if file not in actual:actual[file]=pin(file) if Path(file).is_file() else None
            got=actual[file]
            row['status']='missing' if got is None else 'verified' if all(row[k]==got[k] for k in ['bytes','sha256']) else 'changed'
        for info,raw in payload:
            if pin(info['file'])!={key:info[key] for key in ['file','bytes','sha256']}:raise ValueError('Receipt changed before sealing')
        assert_no_guards()
        # Construct in memory so an oversize capsule is never published.
        buffer=io.BytesIO()
        with tarfile.open(fileobj=buffer,mode='w:gz') as archive:
            for info,raw in payload:
                entry=tarfile.TarInfo(info['member']);entry.size=len(raw);entry.mode=0o644;entry.mtime=0
                archive.addfile(entry,io.BytesIO(raw))
        archive_bytes=buffer.getvalue()
        def status(rel):
            value=values.get(str(ROOT/rel))
            return None if value is None else {key:value[key] for key in ['complete','passed','executionComplete','fullCorpusOutputQualified','fullMeasuredCorpus','rounds','ratioCaseCount','requestedCorpusCount','error'] if key in value}
        result=dict(kind='phase113-final31-json-capsule',complete=True,targetsRun=False,
            createdUtc=datetime.now(timezone.utc).isoformat(),method=pin(__file__),selectionPlan=pin(a.plan),
            archive=dict(file=str((a.out/'receipts.tar.gz').resolve()),bytes=len(archive_bytes),sha256=hashlib.sha256(archive_bytes).hexdigest()),
            receiptCount=len(payload),rawReceiptBytes=raw_total,receipts=[row for row,raw in payload],references=list(references.values()),
            nativeQualified=False,expectedAbsentNativeImages=plan['knownAbsentNativeImages'],
            outcomes=dict(nativeAttempt=status('selfhost/build/phase113/p113-final31-qualification-guard/process.json'),
                standard80JobRun=status('selfhost/build/phase113/width-wide30-31-native/report.json'),
                pairedSix=status('selfhost/build/phase112/p113-final31-screen/report.json'),
                hostedAcquisition=status('selfhost/build/phase113/final31-hosted45-jobs/report.json'),
                hostedContinuation=status('selfhost/build/phase113/final31-hosted45-rest-jobs/report.json'),
                hostedProducerAudit=status('selfhost/build/phase113/final31-hosted45-audit.json'),
                combinedProducerAudit=status('selfhost/build/phase113/final31-hosted45-rest-audit.json'),
                broadRuntime=status('selfhost/build/phase112/p113-final31-hosted45-runtime01/report.json')),
            scope='Capsule completeness means all selected raw JSON bytes were copied. It is not qualification. Native acquisition failed and produced noN1/N2. Hosted and runtime outcomes remain separate. External product/source/API/tool/output hashes do not mean those bytes are archived.',
            referenceStatusCounts={name:sum(row['status']==name for row in references.values()) for name in ['verified','changed','missing']})
        encoded=(json.dumps(result,separators=(',',':'))+'\n').encode()
        if len(encoded)+len(archive_bytes)>=plan['maximumCapsuleBytes']:
            raise ValueError('Archive plus manifest exceeds3MiB; nothing published. Narrow selected JSON deliberately.')
        a.out.mkdir(parents=True)
        (a.out/'receipts.tar.gz').write_bytes(archive_bytes)
        (a.out/'manifest.json').write_bytes(encoded)
        print(json.dumps(dict(complete=True,targetsRun=False,nativeQualified=False,receiptCount=len(payload),
             capsuleBytes=len(encoded)+len(archive_bytes),manifest=pin(a.out/'manifest.json'),archive=pin(a.out/'receipts.tar.gz'))))


if __name__=='__main__':main()
