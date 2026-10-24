#!/usr/bin/env python3
"""Observe an already-required native request; the external guard owns limits.

One-second process-tree RSS/output-size observations are not compiler stage
clocks, PSS, peak live allocation, or a clean timing comparison.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]
PAGE = os.sysconf('SC_PAGE_SIZE')


def pin(path):
    path = Path(path); h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1048576), b''): h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def process(pid, proc=Path('/proc')):
    try:
        text = (proc/str(pid)/'stat').read_text()
        fields = text[text.rfind(')')+2:].split()
        tasks = proc/str(pid)/'task'
        children = set()
        for task in tasks.iterdir():
            try: children.update(int(x) for x in (task/'children').read_text().split())
            except (OSError, ValueError): pass
        return dict(pid=pid, startTicks=int(fields[19]), rssBytes=max(0,int(fields[21]))*PAGE,
                    userTicks=int(fields[11]), systemTicks=int(fields[12]), children=sorted(children))
    except (OSError, ValueError, IndexError): return None


def tree(pid):
    pending = [pid]; seen = set(); rows = []
    while pending:
        at = pending.pop()
        if at in seen: continue
        seen.add(at); row = process(at)
        if row is not None:
            pending.extend(row['children']); rows.append(row)
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--product', type=Path, required=True)
    ap.add_argument('--request-report', type=Path, required=True)
    ap.add_argument('command', nargs=argparse.REMAINDER)
    a = ap.parse_args(); command = a.command
    if command[:1] == ['--']: command = command[1:]
    out = a.out.resolve(); product = a.product.resolve(); request = a.request_report.resolve()
    if not command or out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase132'):
        raise ValueError('Command and fresh Phase132 observation directory required')
    if product.exists() or request.exists(): raise ValueError('Request outputs must be fresh')
    out.mkdir(parents=True)
    start = time.monotonic(); began = time.time()
    report = dict(kind='phase132-native-request-resource-observation', complete=False,
        method=pin(__file__), command=command, productPath=str(product), requestReportPath=str(request),
        startedUnixSeconds=began, intervalSeconds=1, inheritedAffinity=sorted(os.sched_getaffinity(0)),
        scope='Descendant RSS sum excluding this observer; RSS may double count shared pages. Output file size is observed independently. No stage, PSS, liveness, or clean-speed claim. External guard owns timeout/RSS/disk bounds.')
    def save():
        tmp=out/'report.json.tmp'; tmp.write_text(json.dumps(report,indent=2)+'\n'); tmp.replace(out/'report.json')
    save(); child = subprocess.Popen(command, cwd=ROOT)
    report['childPid'] = child.pid; count = 0; peak = 0; first = None
    with (out/'samples.jsonl').open('x') as log:
        while True:
            elapsed = time.monotonic()-start; rows = tree(child.pid)
            try: size = product.stat().st_size
            except FileNotFoundError: size = None
            rss = sum(r['rssBytes'] for r in rows); peak = max(peak,rss)
            if size and first is None: first = elapsed
            row = dict(elapsedSeconds=elapsed, processTreeRssBytes=rss, processes=rows,
                       productBytes=size, childExitCode=child.poll())
            log.write(json.dumps(row,separators=(',',':'))+'\n'); log.flush(); count += 1
            if row['childExitCode'] is not None: break
            # Bound the number of records if the enclosing guard is accidentally absent.
            # This only stops observation, not the authoritative request/guard.
            if count >= 3600:
                report['observationTruncated']=True; child.wait(); break
            time.sleep(1)
        os.fsync(log.fileno())
    report.update(exitCode=child.wait(), wallSeconds=time.monotonic()-start,
        samples=count, sampledPeakDescendantRssBytes=peak, firstObservedNonemptyOutputSeconds=first,
        samplesFile=pin(out/'samples.jsonl'))
    if request.is_file():
        report['requestReport']=pin(request)
        report['requestComplete']=json.loads(request.read_text()).get('complete') is True
    report['complete']=report['exitCode']==0 and report.get('requestComplete',False) and product.is_file()
    save(); print(json.dumps({k:report.get(k) for k in ['complete','wallSeconds','samples','sampledPeakDescendantRssBytes','firstObservedNonemptyOutputSeconds']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__': sys.exit(main())
