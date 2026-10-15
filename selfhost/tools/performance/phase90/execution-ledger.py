#!/usr/bin/env python3
"""Summarize finished, unique Phase90 ExecutionGuard receipts; no target runs."""
import argparse
from collections import Counter, defaultdict
import datetime
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT/'selfhost/build/phase90'
PUBLIC = ROOT/'implementation/phase90/public-cli-evidence.json'
LOCK = ROOT/'selfhost/build/phase32/execution.lock'
RESOURCE_STOPS = {'deadline', 'tree-rss-limit', 'host-headroom'}


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(path=str(file.relative_to(ROOT)), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def verify(record):
    file = Path(record.get('file', record.get('path')))
    if not file.is_absolute():
        file = ROOT/file
    actual = pin(file)
    assert actual['sha256'] == record['sha256'] and actual['bytes'] == record['bytes'], file
    return actual


def read(file):
    return json.loads(Path(file).read_text())


def numeric(value):
    return isinstance(value, (float, int)) and not isinstance(value, bool) and math.isfinite(value)


def category(row):
    command = row['command']
    names = [Path(x).name for x in command]
    text = ' '.join(command)
    group = row['group']
    if any(re.fullmatch(r'(clang(?:\+\+)?(?:-\d+)?|llc|opt)', n) for n in names):
        return 'Clang/LLVM build or probe'
    if 'workflow.mjs' in names and 'run' in command:
        return 'Checked B1 build and focused validation'
    if row['scope'] == 'public-cli-request':
        return 'Public native CLI controls'
    if any(x in group for x in ['screen', 'paired', 'measure', 'cold']):
        return 'Compilation timing or screen'
    if 'profile' in group or any(x in text for x in ['--cpu-prof', '--prof', 'profile-self']):
        return 'Profiling/diagnostic capture'
    if any(x in group for x in ['release', 'qualification', 'controls', 'gates', 'broad', 'whitespace']):
        return 'Qualification, controls or release'
    if any(x in group for x in ['self', '-b2', 'acquisition']) or any(n in names for n in ['emit-split.mjs', 'acquire-native.mjs']):
        return 'Compiler emission or self-hosting'
    return 'Other guarded work'


def aggregate(rows):
    return dict(jobs=len(rows), statuses=dict(Counter(x['status'] for x in rows)),
                summedWallSeconds=sum(x['wallSeconds'] for x in rows),
                peakTreeRssBytes=max((x['peakTreeRssBytes'] for x in rows), default=0))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-only', action='store_true')
    parser.add_argument('--json', type=Path, default=ROOT/'implementation/phase90/execution-ledger.json')
    parser.add_argument('--markdown', type=Path, default=ROOT/'implementation/phase90/execution-ledger.md')
    parser.add_argument('--required-report', action='append', type=Path, default=[])
    a = parser.parse_args()
    try:
        os.sched_setaffinity(0, {0})
    except OSError:
        pass
    # Hold the shared execution lock only for this offline scan. An active
    # guarded target makes us refuse immediately; no process is interrupted.
    with LOCK.open('r') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_SH | fcntl.LOCK_NB)
        except BlockingIOError:
            raise SystemExit('Not ready: a guarded target still holds the execution lock')
        required = []
        for file in a.required_report:
            record = read(file)
            assert record.get('complete') is True, file
            assert all(record[k] is True for k in ['passed', 'pass'] if k in record), file
            assert record.get('returncode', 0) == 0 and not record.get('stoppedFor'), file
            required.append(pin(file))
        public_pin = pin(PUBLIC)
        public = read(PUBLIC)
        assert public['complete'] and public['controlsPassed'] == 6 and public['allArchiveMembersVerified']
        manifest_pin = verify(public['manifest'])
        manifest = read(ROOT/manifest_pin['path'])
        assert len(manifest['controls']) == 6 and all(x['controlPassed'] for x in manifest['controls'])
        archived = {x['path']: x for x in manifest['files']}
        cli = {}
        for row in manifest['controls']:
            expected = row['directory']+'/guard/process.json'
            if row['compilerExecuted']:
                verify(archived[expected])
                cli[str((ROOT/expected).resolve())] = row
            else:
                assert expected not in archived and not (ROOT/expected).exists()
        candidates = sorted(set(p.resolve() for p in RAW.rglob('process.json')) | {Path(p) for p in cli})
        identities, skipped, malformed, by_job = [], [], [], defaultdict(list)
        for file in candidates:
            identity = pin(file)
            identities.append(identity)
            try:
                value = read(file)
            except (ValueError, UnicodeError) as error:
                malformed.append(dict(**identity, error=str(error)))
                continue
            # Nested workflow child-process receipts have a different schema.
            if not isinstance(value, dict) or not all(k in value for k in ['rssLimitBytes', 'minimumAvailableBytes', 'started', 'command']):
                skipped.append(identity['path'])
                continue
            assert numeric(value['started']) and isinstance(value['command'], list) and all(isinstance(x, str) for x in value['command']), file
            key = json.dumps([value['started'], value['command']], separators=(',', ':'))
            finished = (numeric(value.get('finished')) and numeric(value.get('wallSeconds'))
                        and value['finished'] >= value['started'] and value['wallSeconds'] >= 0)
            by_job[key].append(dict(identity=identity, value=value, finished=finished, file=file))
        rows, unfinished, duplicates = [], [], []
        for key, records in by_job.items():
            completed = [x for x in records if x['finished']]
            if not completed:
                unfinished.extend(dict(**x['identity'], started=x['value']['started'], command=x['value']['command']) for x in records)
                continue
            completed.sort(key=lambda x: (len(Path(x['identity']['path']).parts), x['identity']['path']))
            chosen = completed[0]
            value, file = chosen['value'], chosen['file']
            fields = ['started', 'finished', 'command', 'complete', 'returncode', 'stoppedFor', 'wallSeconds',
                      'rssLimitBytes', 'availableFloorBytes', 'peakTreeRssBytes', 'minimumAvailableBytes', 'error']
            core = {k: value.get(k) for k in fields}
            assert all({k:x['value'].get(k) for k in fields} == core for x in completed), 'Conflicting completed copies: '+key
            aliases = [x['identity']['path'] for x in records if x is not chosen]
            if aliases:
                duplicates.append(dict(canonical=chosen['identity']['path'], aliases=aliases,
                                       unfinishedCopies=sum(not x['finished'] for x in records)))
            stopped, code = value.get('stoppedFor'), value.get('returncode')
            if code == 0 and not stopped and value.get('complete') is True:
                status = 'success'
            elif stopped in RESOURCE_STOPS:
                status = 'resource_stop'
            elif isinstance(code, int) and code != 0 and not stopped:
                status = 'other_nonzero'
            elif stopped:
                status = 'other_guard_stop'
            else:
                status = 'guard_error_or_prelaunch_refusal'
            is_cli = str(file) in cli
            group = ('public-cli/'+cli[str(file)]['name'] if is_cli else file.relative_to(RAW).parts[0])
            row = dict(evidence=chosen['identity'], aliases=aliases, group=group,
                       scope='public-cli-request' if is_cli else 'phase90-raw', status=status,
                       started=value['started'], finished=value['finished'], wallSeconds=value['wallSeconds'],
                       returncode=code, stoppedFor=stopped, guardComplete=value.get('complete'),
                       peakTreeRssBytes=value.get('peakTreeRssBytes', 0), rssLimitBytes=value['rssLimitBytes'],
                       minimumAvailableBytes=value['minimumAvailableBytes'], command=value['command'])
            if is_cli:
                row['expectedCompilerRejection'] = cli[str(file)]['expectedRefusal']
            row['category'] = category(row)
            rows.append(row)
        rows.sort(key=lambda x: (x['started'], x['evidence']['path']))
        intervals = sorted((x['started'], x['finished']) for x in rows)
        union, covered_end = 0.0, None
        for start, end in intervals:
            union += end-start if covered_end is None else max(0, end-max(start, covered_end))
            covered_end = end if covered_end is None else max(end, covered_end)
        interval_sum = sum(end-start for start, end in intervals)
        groups, categories = defaultdict(list), defaultdict(list)
        for row in rows:
            groups[row['group']].append(row)
            categories[row['category']].append(row)
        groups = {k: aggregate(v) for k,v in groups.items()}
        categories = {k: aggregate(v) for k,v in categories.items()}
        assert sorted(set(p.resolve() for p in RAW.rglob('process.json')) | {Path(p) for p in cli}) == candidates
        for item in identities + [public_pin, manifest_pin] + required:
            verify(item)
        totals = aggregate(rows)
        result = dict(kind='phase90-finished-guard-execution-ledger', complete=not malformed,
            generatedUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(), method=pin(__file__),
            targetsExecuted=False, sourceRoot=str(RAW.relative_to(ROOT)), requiredCompletedReports=required,
            executionLockObservedIdle=True, allScannedInputsUnchanged=True, totals=totals,
            resourceStopReasons=dict(Counter(x['stoppedFor'] for x in rows if x['status']=='resource_stop')),
            stoppedReasons=dict(Counter(x['stoppedFor'] for x in rows if x['stoppedFor'])),
            timeline=dict(firstStarted=intervals[0][0] if intervals else None,
                          lastFinished=intervals[-1][1] if intervals else None,
                          guardedIntervalUnionSeconds=union, summedEpochIntervalSeconds=interval_sum,
                          overlappingIntervalSeconds=max(0, interval_sum-union)),
            byCategory=categories, byTopLevelGroup=groups, publicCliEvidence=public_pin,
            publicCliManifest=manifest_pin, publicCliControls=6, publicCliCompilerGuards=len(cli),
            publicCliEarlyRefusals=6-len(cli), duplicateRecordsExcluded=duplicates,
            childOrOtherProcessRecordsExcluded=skipped, unfinishedRecordsExcluded=unfinished,
            malformedProcessRecords=malformed, rows=rows,
            limitations=['Counts finished ExecutionGuard receipts only, not all shell commands, agent work, waiting or browsing.',
                'Sum of unique guarded wall durations is not elapsed session time or CPU time; interval union reports overlaps separately.',
                'Repeated path or identical started+command copies count once. Unfinished records are listed and excluded.',
                'A nonzero compiler exit may be an expected rejection; it is not automatically a conformance regression.',
                'Peak is the maximum sampled sum of process-tree RSS, not a hard memory ceiling or unique physical memory.',
                'Categories are descriptive command/path heuristics; exact commands and source receipts remain in every row.',
                'No exact token or quota telemetry is available here. Wall time and RSS cannot reconstruct quota consumption.'])
        if a.check_only:
            print(json.dumps(dict(complete=result['complete'], totals=totals, unfinished=len(unfinished),
                                  malformed=len(malformed), duplicates=len(duplicates), targetsExecuted=False)))
            return
        assert not malformed, 'Unreadable process records need review before final publication'
        assert not a.json.exists() and not a.markdown.exists(), 'Use fresh output paths for a later ledger revision'
        a.json.write_text(json.dumps(result, indent=2)+'\n')
        counts=totals['statuses']
        text = ['# Phase90 execution ledger', '',
            f"{totals['jobs']} unique finished guarded jobs: {counts.get('success',0)} successful exits, "
            f"{counts.get('resource_stop',0)} resource stops and {counts.get('other_nonzero',0)} other nonzero exits. "
            f"Other guard stops/errors: {counts.get('other_guard_stop',0)+counts.get('guard_error_or_prelaunch_refusal',0)}.", '',
            f"Summed guarded wall time: **{totals['summedWallSeconds']/3600:.2f} hours** "
            f"({totals['summedWallSeconds']:.2f} seconds). Guarded interval union: {union/3600:.2f} hours; "
            f"overlapping interval time: {max(0,interval_sum-union):.2f} seconds. "
            f"Maximum sampled process-tree RSS: **{totals['peakTreeRssBytes']/1024**3:.2f} GiB**.", '',
            '| Category | Jobs | Guarded minutes | Peak tree RSS (GiB) |',
            '| --- | ---: | ---: | ---: |']
        for name, group in sorted(categories.items(), key=lambda x: -x[1]['summedWallSeconds']):
            text.append(f"| {name} | {group['jobs']} | {group['summedWallSeconds']/60:.2f} | {group['peakTreeRssBytes']/1024**3:.2f} |")
        text += ['', f"The public CLI capsule contributes {len(cli)} compiler guards from six controls; "
                 'two refusals occurred before compiler execution. Its expected parse rejection remains a finished nonzero exit.', '',
                 f"Excluded {sum(len(x['aliases']) for x in duplicates)} duplicate records, {len(skipped)} child/other process records "
                 f"and {len(unfinished)} unfinished records. Resource-stop reasons: {json.dumps(result['resourceStopReasons'],sort_keys=True)}.", '',
                 'These are recorded process durations, not a complete account of session or agent time. Expected rejection tests '
                 'and failed experiments remain included; nonzero exits do not imply conformance regressions. No exact token/quota '
                 'telemetry is available, and these timings cannot reconstruct quota consumption.', '',
                 '[Full ledger, commands and receipt hashes](execution-ledger.json). No targets were run to prepare this ledger.', '']
        a.markdown.write_text('\n'.join(text))
        print(json.dumps(dict(json=pin(a.json), markdown=pin(a.markdown), totals=totals,
                              unfinished=len(unfinished), duplicateRecords=sum(len(x['aliases']) for x in duplicates),
                              targetsExecuted=False)))


if __name__ == '__main__':
    main()
