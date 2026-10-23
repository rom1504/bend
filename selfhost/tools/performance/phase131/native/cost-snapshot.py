#!/usr/bin/env python3
"""Snapshot only Phase131 guard costs and small evidence; run no targets.

Guard wall sums are not CPU time, elapsed research time, or model-token cost.
The incremental archive excludes large products and is independently pinned.
"""
import argparse
import collections
import hashlib
import io
import json
import os
from pathlib import Path
import tarfile
import time

ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/build/phase131'


def pin_bytes(path, data):
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def stable(path, maximum=None):
    before = path.stat()
    if path.is_symlink() or (maximum is not None and before.st_size > maximum):
        raise ValueError('Excluded symlink/oversized file')
    data = path.read_bytes()
    after = path.stat()
    if (before.st_size, before.st_mtime_ns, before.st_ino) != (after.st_size, after.st_mtime_ns, after.st_ino):
        raise ValueError('File changed during read')
    return data


def union_seconds(intervals):
    total, end = 0.0, None
    for start, finish in sorted(intervals):
        total += max(0, finish - max(start, end if end is not None else start))
        end = max(finish, end if end is not None else finish)
    return total


def classify(path, command, cpu):
    text = str(path).lower()
    args = ' '.join(command).lower()
    if cpu == '4':
        return 'proof-and-law-controls'
    if 'native-request.py' in args and 'compiler.bend' in args:
        parts = path.relative_to(PHASE).parts
        self_emission = any(p == 'self' or p.startswith('self-') or '-self' in p for p in parts)
        return 'full-compiler-self-emission' if self_emission else 'full-compiler-acquisition'
    if any(x in text for x in ['-n1-build', '-n2-build', '-n3-build']):
        return 'full-compiler-machine-build'
    if 'timing-run.py' in args:
        return 'clean-compiler-comparison' if cpu == '3' else 'diagnostic-compiler-comparison'
    if 'native-timing' in args:
        return 'clean-proxy-timing' if cpu == '3' else 'diagnostic-proxy-timing'
    if any(x in text for x in ['/profile', '/context']) or 'tools/profiler/' in args:
        return 'profiling-or-instrumentation'
    if 'check-api.py' in args or '--check-only' in args:
        return 'independent-source-check'
    if 'coverage.py' in args or 'full45.py' in args or '-focused' in text:
        return 'native-semantic-gates'
    if 'emit' in text or 'build-aligned.py' in args:
        return 'proxy-emission-or-build'
    return 'controls-diagnostics-other'


def totals(rows):
    intervals = [(r['started'], r['finished']) for r in rows]
    summed = sum(r['guardWallSeconds'] for r in rows)
    union = union_seconds(intervals)
    return dict(receipts=len(rows), successful=sum(r['complete'] for r in rows),
        nonzeroOrIncomplete=sum(not r['complete'] for r in rows),
        negativeControlLabel=sum(r['negativeControlLabel'] for r in rows),
        failedWithoutNegativeLabel=sum(not r['complete'] and not r['negativeControlLabel'] for r in rows),
        guardedWallSumSeconds=summed, coveredIntervalUnionSeconds=union,
        intervalOverlapSeconds=max(0, sum(b-a for a,b in intervals)-union),
        maximumTreeRssBytes=max((r['peakTreeRssBytes'] for r in rows), default=0))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--previous', type=Path)
    a = ap.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(PHASE):
        raise ValueError('Fresh Phase131 output required')
    prior, previous_pin = {}, None
    if a.previous:
        old_data = stable(a.previous)
        old = json.loads(old_data)
        if old.get('kind') != 'phase131-guard-cost-snapshot' or not old.get('complete'):
            raise ValueError('Previous completed cost snapshot required')
        prior = old['cumulativeArchivedFiles']
        previous_pin = pin_bytes(a.previous.resolve(), old_data)
    snapshot_time = time.time()
    rows, skipped, evidence = [], [], {}
    for directory, dirs, files in os.walk(PHASE, followlinks=False):
        dirs[:] = [d for d in dirs if not (Path(directory) / d).is_symlink()]
        if 'process.json' not in files:
            continue
        path = Path(directory) / 'process.json'
        try:
            data = stable(path, 1048576)
            r = json.loads(data)
            if not all(k in r for k in ['command', 'started', 'finished', 'wallSeconds', 'complete']):
                raise ValueError('Pending/non-guard receipt')
            if r['finished'] > snapshot_time:
                raise ValueError('Finished after snapshot cutoff')
            command = r['command']
            cpu = command[command.index('taskset') + 2] if 'taskset' in command else 'unknown'
            negative = any(x in str(path) for x in ['kernel-negative', 'laws-mutation', 'laws-merge-mutation'])
            row = dict(receipt=pin_bytes(path, data), cpu=cpu, category=classify(path, command, cpu),
                complete=bool(r['complete']), returncode=r.get('returncode'),
                negativeControlLabel=negative, started=r['started'], finished=r['finished'],
                guardWallSeconds=r['wallSeconds'], peakTreeRssBytes=r.get('peakTreeRssBytes', 0),
                minimumAvailableBytes=r.get('minimumAvailableBytes'), command=command)
            rows.append(row)
            evidence[str(path.relative_to(ROOT))] = data
            for name in ['inputs.json', 'method.json', 'stdout.log', 'stderr.log']:
                sidecar = path.parent / name
                if sidecar.exists():
                    try:
                        evidence[str(sidecar.relative_to(ROOT))] = stable(sidecar, 65536 if name.endswith('.log') else 262144)
                    except ValueError:
                        skipped.append(dict(file=str(sidecar.relative_to(ROOT)), reason='Sidecar oversized/unstable/symlink; guard receipt retained'))
            # Nearby completed proof/control report explains expected negative
            # exits without importing compiler images or raw program products.
            for parent in [path.parent, path.parent.parent]:
                summary = parent / 'report.json'
                if summary.is_file() and summary.is_relative_to(PHASE):
                    try:
                        b = stable(summary, 262144)
                        if json.loads(b).get('complete'):
                            evidence[str(summary.relative_to(ROOT))] = b
                    except (ValueError, json.JSONDecodeError):
                        pass
        except (OSError, ValueError, json.JSONDecodeError) as error:
            skipped.append(dict(file=str(path.relative_to(ROOT)), reason=str(error)))
    rows.sort(key=lambda r: (r['started'], r['receipt']['file']))
    evidence[str(Path(__file__).relative_to(ROOT))] = Path(__file__).read_bytes()
    by_cpu = {k:totals([r for r in rows if r['cpu'] == k]) for k in sorted({r['cpu'] for r in rows})}
    by_category = {k:totals([r for r in rows if r['category'] == k]) for k in sorted({r['category'] for r in rows})}
    all_pins = {name:pin_bytes(ROOT / name, data) for name,data in evidence.items()}
    additions = {name:data for name,data in evidence.items() if prior.get(name) != all_pins[name]}
    cumulative = {**prior, **all_pins}
    report = dict(kind='phase131-guard-cost-snapshot', complete=True, cutoffUnixSeconds=snapshot_time,
        method=pin_bytes(Path(__file__), Path(__file__).read_bytes()), previousSnapshot=previous_pin,
        totals=totals(rows), byCpu=by_cpu, byCategory=by_category, rows=rows, skipped=skipped,
        cumulativeArchivedFiles=cumulative, addedArchiveFiles=[all_pins[n] for n in sorted(additions)],
        scope='Only completed guard receipts under selfhost/build/phase131 at cutoff. '
        'Guard wall sums include wrapper overhead and may overlap; interval unions are reported separately. '
        'These are not CPU time, elapsed total research time, agent tokens or monetary cost. '
        'CPU3 includes acquisition, clean timings and instrumented profiling; CPU4 is proof/law work, '
        'CPU5/6 are separate correctness/investigation lanes. Categories and negative-control intent '
        'are transparent command/path classifications, not independent semantic verdicts. '
        'Unfinished guards, unguarded metadata/storage/agent work and large target artifacts are excluded.')
    out.mkdir(parents=True)
    archive = out / 'guard-evidence.tar.gz'
    with tarfile.open(archive, 'w:gz', compresslevel=6) as tar:
        for name in sorted(additions):
            data = additions[name]
            entry = tarfile.TarInfo(name)
            entry.size, entry.mtime, entry.mode = len(data), 0, 0o644
            tar.addfile(entry, io.BytesIO(data))
    report['archive'] = pin_bytes(archive, archive.read_bytes())
    report['archiveUncompressedBytes'] = sum(len(b) for b in additions.values())
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    lines = ['# Phase131 guarded-work snapshot', '',
        '| CPU lane | Guards | Guard wall sum, seconds | Interval union, seconds | Nonzero/incomplete | Negative-control labels |',
        '|---|---:|---:|---:|---:|---:|']
    for cpu, t in by_cpu.items():
        lines.append(f"|{cpu}|{t['receipts']}|{t['guardedWallSumSeconds']:.2f}|{t['coveredIntervalUnionSeconds']:.2f}|{t['nonzeroOrIncomplete']}|{t['negativeControlLabel']}|")
    lines += ['', '| Purpose | Guards | Guard wall sum, seconds |', '|---|---:|---:|']
    for cat,t in by_category.items():
        lines.append(f"|{cat}|{t['receipts']}|{t['guardedWallSumSeconds']:.2f}|")
    lines += ['', report['scope'], '',
        f"Incremental evidence archive:{report['archive']['bytes']} compressed bytes;{len(additions)} small files. Preserve previous archives referenced by `previousSnapshot` when restoring the evidence chain.", '',
        'Successful negative controls can have a nonzero guard exit. Review their nearby retained proof/control reports; do not call every nonzero exit a failed optimization. All nonzero records remain in `report.json`.']
    (out / 'README.md').write_text('\n'.join(lines) + '\n')
    print(json.dumps(dict(complete=True, totals=report['totals'], archive=report['archive'], addedFiles=len(additions))))


if __name__ == '__main__':
    main()
