#!/usr/bin/env python3
"""Offline Phase190 guard-cost/source-growth snapshot; never execute target jobs."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
CAMPAIGN = ROOT / 'selfhost/build/phase190'
METRICS = ('wallSeconds', 'peakTreeRssBytes', 'peakRunAllocatedBytes',
           'peakFilesystemDecreaseBytes', 'diskBudgetBytes', 'diskReserveBytes', 'rssLimitBytes')


def identity(path, data):
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def capture(path):
    data = path.read_bytes()
    return data, identity(path, data)


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def category(name, command):
    words = ' '.join(command)
    if 'qualification.py' in words or 'native-catalog.py' in words or name.startswith('native45'):
        return 'native-qualification'
    if 'runtime-controls.py' in words:
        return 'native-runtime-controls'
    if 'native.py' in words:
        return 'native-acquisition'
    if 'runtime-loop.py' in words:
        return 'program-runtime'
    if 'profile' in name:
        return 'profile'
    if 'controls' in name:
        return 'controls'
    if 'emit-programs.mjs' in words or '-emit' in name:
        return 'hosted-emission'
    if 'build-programs.py' in words or '-build' in name:
        return 'program-build'
    if 'api' in name or 'hosted.mjs' in words:
        return 'checked-api-acquisition'
    if 'check' in name or 'source-diagnose' in words:
        return 'source-check'
    if 'diagnostic' in name:
        return 'diagnostic'
    return 'other'


def guards():
    rows = []
    for directory in sorted(CAMPAIGN.glob('*-guard')):
        path = directory / 'process.json'
        row = dict(job=directory.name.removesuffix('-guard'), category='unknown', status='incomplete')
        try:
            data, pin = capture(path)
            receipt = json.loads(data)
            if path.read_bytes() != data:
                raise ValueError('Receipt changed during capture')
            if receipt.get('kind') != 'build-retention-disk-guard-v1':
                raise ValueError('Expected disk-guard receipt')
            command = receipt.get('command', [])
            row.update(receipt=pin, category=category(row['job'], command), command=command,
                       returncode=receipt.get('returncode'), cpu=receipt.get('method', {}).get('cpu'),
                       started=receipt.get('started'), finished=receipt.get('finished'),
                       stoppedFor=receipt.get('stoppedFor'), error=receipt.get('error'),
                       artifactRoots=receipt.get('artifactRoots', []))
            if receipt.get('finished') is not None and receipt.get('returncode') is not None:
                row['status'] = 'succeeded' if receipt.get('complete') and receipt['returncode'] == 0 else 'failed'
            row.update({k: receipt.get(k) for k in METRICS})
        except (OSError, ValueError) as error:
            row['reason'] = str(error)
        rows.append(row)
    return rows


def totals(rows):
    finished = [r for r in rows if r['status'] in ('succeeded', 'failed')]
    durations = [r['wallSeconds'] for r in finished if isinstance(r.get('wallSeconds'), (int, float))]
    peaks = {key: max((r[key] for r in finished if isinstance(r.get(key), (int, float))), default=None)
             for key in METRICS if key != 'wallSeconds'}
    return dict(jobCount=len(rows), succeeded=sum(r['status'] == 'succeeded' for r in rows),
        failed=sum(r['status'] == 'failed' for r in rows), incomplete=sum(r['status'] == 'incomplete' for r in rows),
        recordedFinishedDurationCount=len(durations), recordedFinishedWallSeconds=sum(durations),
        succeededWallSeconds=sum(r['wallSeconds'] for r in finished if r['status'] == 'succeeded' and isinstance(r.get('wallSeconds'), (int, float))),
        failedWallSeconds=sum(r['wallSeconds'] for r in finished if r['status'] == 'failed' and isinstance(r.get('wallSeconds'), (int, float))),
        maximumPerJob=peaks)


def size(data):
    return dict(bytes=len(data), lines=len(data.splitlines()), sha256=hashlib.sha256(data).hexdigest())


def growth(args):
    before, before_pin = capture(args.baseline_source)
    after, after_pin = capture(args.selected_source)
    revision = git('rev-parse', '--verify', args.base + '^{commit}').decode().strip()
    modified = set(git('diff', '--name-only', '-z', revision, '--', 'selfhost/src').decode().split('\0'))
    untracked = set(git('ls-files', '--others', '--exclude-standard', '-z', '--', 'selfhost/src').decode().split('\0'))
    prior_names = set(git('ls-tree', '-r', '--name-only', '-z', revision, '--', 'selfhost/src').decode().split('\0'))
    rows = []
    for name in sorted((modified | untracked) - {''}):
        path = ROOT / name
        old = git('show', revision + ':' + name) if name in prior_names else b''
        new = path.read_bytes() if path.is_file() else b''
        if old == new:
            continue
        rows.append(dict(file=name, status='added' if name not in prior_names else 'modified' if path.is_file() else 'deleted',
            untracked=name in untracked, before=size(old), after=size(new),
            deltaBytes=len(new)-len(old), deltaLines=len(new.splitlines())-len(old.splitlines())))
    return dict(assembled=dict(baseline=before_pin, selected=after_pin,
        baselineLines=len(before.splitlines()), selectedLines=len(after.splitlines()),
        deltaBytes=len(after)-len(before), deltaLines=len(after.splitlines())-len(before.splitlines()),
        byteGrowthPercent=100*(len(after)/len(before)-1) if before else None),
        maintained=dict(baseRevision=revision, pathScope='selfhost/src', changedFiles=rows,
            changedFileCount=len(rows), addedFileCount=sum(r['status']=='added' for r in rows),
            netDeltaBytes=sum(r['deltaBytes'] for r in rows), netDeltaLines=sum(r['deltaLines'] for r in rows),
            scope='Worktree versus base commit, including staged, unstaged and untracked nonignored files under selfhost/src; excludes fixtures, host tools and documentation. Line deltas are net physical line counts, not diff churn.'))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True, help='Fresh JSON snapshot; use /tmp while jobs are active')
    p.add_argument('--base', default='57dc784', help='Maintained-source comparison commit')
    p.add_argument('--baseline-source', type=Path, default=CAMPAIGN/'baseline-source/compiler.bend')
    p.add_argument('--selected-source', type=Path, default=CAMPAIGN/'selected-source01/compiler.bend')
    args = p.parse_args()
    if args.out.exists() or args.out.suffix != '.json':
        p.error('--out must be a fresh .json file')
    rows = guards()
    groups = {name: totals([r for r in rows if r['category'] == name]) for name in sorted({r['category'] for r in rows})}
    statuses = {name: totals([r for r in rows if r['status'] == name]) for name in ('succeeded', 'failed', 'incomplete')}
    result = dict(kind='phase190-offline-campaign-cost', version=1,
        capturedUTC=datetime.now(timezone.utc).isoformat(), programsExecuted=False,
        method=capture(Path(__file__))[1], receiptDirectory=str(CAMPAIGN),
        summary=totals(rows), byCategory=groups, byStatus=statuses,
        failedJobs=[r['job'] for r in rows if r['status']=='failed'],
        incompleteJobs=[r['job'] for r in rows if r['status']=='incomplete'], jobs=rows,
        sourceGrowth=growth(args),
        scope='Sum of recorded finished Phase190 guarded-job wall durations, including failures; not research elapsed time, agent quota, CPU time, or a sum of benchmark kernel durations. Guards include acquisition, startup, checking and I/O. Incomplete/missing/changing receipts are listed but excluded from duration totals. RSS and disk values are observed per-job maxima; disk budgets/reserves are limits, never consumed-work totals. Disk usage is not summed across jobs because roots may overlap. Unguarded work is absent; this snapshot is not an atomic campaign close.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(out=str(args.out), summary=result['summary'], incomplete=result['incompleteJobs'],
        assembledGrowth=result['sourceGrowth']['assembled']['deltaBytes'],
        maintainedGrowth=result['sourceGrowth']['maintained']['netDeltaBytes'])))


if __name__ == '__main__':
    main()
