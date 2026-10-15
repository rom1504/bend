#!/usr/bin/env python3
"""Review/apply only three archived relocation-copy inventories; restore to a fresh root.

Review and restore never remove files. Apply redoes the complete review before any
unlink, then removes only listed regular, single-link relocation copies. Existing
reports, outputs, current selfhost files and archive members are never modified.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import stat
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[4]
METHOD = Path(__file__).resolve().relative_to(ROOT).as_posix()
COMMIT = '1806ba4c289cf5cbf282f8f4dd9e8bbd37f17357'
CAPSULE = 'selfhost/tools/performance/phase90/evidence05/'
SPECS = [
    ('release07/legacy42/checks', 'copiedFiles', 'release07/job-legacy42', False),
    ('release07-retry01/legacy42/checks', 'copiedFiles', 'release07-retry01/job-legacy42', True),
    ('release07-retry01/default24', 'copied', 'release07-retry01/job-default24', True),
]


def require(ok, message):
    if not ok:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(name):
    data = (ROOT / name).read_bytes()
    return {'file': name, 'sha256': digest(data), 'bytes': len(data)}


def check_bytes(data, expected):
    require(len(data) == expected['bytes'] and digest(data) == expected['sha256'],
            'Bytes changed: ' + expected['file'])


def local(name, expected, single_link=False, mode=None):
    path = ROOT / name
    require(path.resolve() == path, 'Symlink/path alias: ' + name)
    st = path.lstat()
    require(stat.S_ISREG(st.st_mode), 'Not a regular file: ' + name)
    require(not single_link or st.st_nlink == 1, 'Not single-link: ' + name)
    require(mode is None or stat.S_IMODE(st.st_mode) == mode, 'Mode changed: ' + name)
    data = path.read_bytes()
    check_bytes(data, expected)
    return data


def committed(name):
    expected = pin(name)
    proc = subprocess.Popen(['git', 'cat-file', 'blob', COMMIT + ':' + name],
                            cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    h, size = hashlib.sha256(), 0
    for block in iter(lambda: proc.stdout.read(1024 * 1024), b''):
        h.update(block)
        size += len(block)
    stderr = proc.stderr.read()
    require(proc.wait() == 0, 'Committed capsule unavailable: ' + stderr.decode())
    require((h.hexdigest(), size) == (expected['sha256'], expected['bytes']),
            'Local capsule differs from commit: ' + name)
    return expected


def collect(live):
    """With live=False, reconstruct the same selection solely from committed evidence."""
    capsule_pins = [committed(CAPSULE + n) for n in ('manifest.json', 'phase90.zip')]
    manifest = json.loads((ROOT / capsule_pins[0]['file']).read_text())
    indexed = {x['file']: x for x in manifest}
    require(len(indexed) == len(manifest), 'Duplicate manifest paths')
    rows, reports, guards, source_pins, groups = [], [], [], {}, []
    with zipfile.ZipFile(ROOT / capsule_pins[1]['file']) as archive:
        require(len(set(archive.namelist())) == len(archive.namelist()), 'Duplicate ZIP paths')

        def member(name):
            expected = indexed[name]
            data = archive.read(name)
            check_bytes(data, expected)
            return data

        for suffix, key, guard_suffix, expected_pass in SPECS:
            base = 'selfhost/build/phase90/' + suffix
            report_name, guard_name = base + '/report.json', 'selfhost/build/phase90/' + guard_suffix + '/process.json'
            report = json.loads(member(report_name))
            guard = json.loads(member(guard_name))
            require(report['pass'] is expected_pass and
                    (report.get('finished') or report.get('complete') is True), 'Unfinished/unexpected report')
            require(guard.get('finished') and isinstance(guard.get('wallSeconds'), (int, float)) and
                    guard.get('returncode') == (0 if expected_pass else 1) and not guard.get('stoppedFor'),
                    'Unfinished/unexpected guard: ' + guard_name)
            for name in (report_name, guard_name):
                if live:
                    local(name, indexed[name])
            reports.append(indexed[report_name])
            guards.append(indexed[guard_name])
            relocation = report['relocation']
            root = ROOT / base / 'relocated'
            require(relocation['root'] == str(root), 'Unexpected relocation root')
            inventory = relocation[key]
            count_before = len(rows)
            for entry in inventory:
                relative = entry['relative']
                rel = PurePosixPath(relative)
                require(not rel.is_absolute() and '..' not in rel.parts and str(rel) == relative,
                        'Invalid copy-relative path')
                name = (root / relative).relative_to(ROOT).as_posix()
                require(entry['file'] == str(ROOT / name), 'Copy path does not match fixed root')
                expected = indexed[name]
                require((entry['sha256'], entry['bytes']) == (expected['sha256'], expected['bytes']),
                        'Copy metadata differs from archive: ' + name)
                info = archive.getinfo(name)
                file_mode = info.external_attr >> 16
                require(stat.S_ISREG(file_mode), 'Archive member is not regular: ' + name)
                mode = stat.S_IMODE(file_mode)
                data = member(name)
                source = 'selfhost/' + relative
                source_pin = {'file': source, 'sha256': expected['sha256'], 'bytes': expected['bytes']}
                if live:
                    require(local(name, expected, single_link=True, mode=mode) == data,
                            'Archive/live bytes differ: ' + name)
                    if source not in source_pins:
                        require(local(source, source_pin) == data, 'Current source differs: ' + source)
                source_pins[source] = source_pin
                rows.append(dict(expected, source=source, mode=mode))
            require(len(rows) > count_before, 'Empty relocation inventory')
            groups.append({'root': root.relative_to(ROOT).as_posix(), 'report': report_name,
                           'files': len(inventory), 'bytes': sum(x['bytes'] for x in inventory)})
    require(len({x['file'] for x in rows}) == len(rows), 'Duplicate deletion target')
    return {'kind': 'phase90-release-relocation-copy-reclaim', 'complete': True,
            'capsuleCommit': COMMIT, 'capsule': capsule_pins, 'method': pin(METHOD),
            'reports': reports, 'guards': guards, 'groups': groups,
            'retainedCurrentFiles': sorted(source_pins.values(), key=lambda x: x['file']),
            'files': rows, 'count': len(rows), 'bytes': sum(x['bytes'] for x in rows),
            'scope': 'Only metadata-listed relocated copies; no reports, outputs, logs, current files or native assets.'}


def write_fresh(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['review', 'apply', 'restore'])
    parser.add_argument('--plan', required=True)
    parser.add_argument('--receipt')
    parser.add_argument('--dest', help='Restore only: a new, absent directory outside the repository')
    args = parser.parse_args()
    os.sched_setaffinity(0, {0})
    with (ROOT / 'selfhost/build/phase32/execution.lock').open('r') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if args.action == 'review':
            require(not Path(args.plan).exists(), 'Plan already exists')
            plan = collect(live=True)
            # Recheck all current inputs before declaring review complete.
            require(plan == collect(live=True), 'Review inputs changed')
            write_fresh(args.plan, plan)
        else:
            plan_bytes = Path(args.plan).read_bytes()
            plan = json.loads(plan_bytes)
            require(plan.get('complete') is True and plan == collect(live=args.action == 'apply'),
                    'Plan is incomplete, changed, or no longer matches its inputs')
            if args.action == 'apply':
                require(args.receipt and not Path(args.receipt).exists(), 'A fresh --receipt is required')
                # Complete all verification before deleting anything; verify each file again at unlink.
                for row in plan['files']:
                    local(row['file'], row, single_link=True, mode=row['mode'])
                    (ROOT / row['file']).unlink()
                receipt = {'kind': 'phase90-release-copy-reclaim-applied', 'complete': True,
                           'planSha256': digest(plan_bytes), 'filesRemoved': plan['count'],
                           'bytesRemoved': plan['bytes'], 'capsuleCommit': COMMIT}
                write_fresh(args.receipt, receipt)
            else:
                require(args.dest, 'Restore requires --dest')
                destination = Path(args.dest).absolute()
                require(destination.resolve() == destination and not destination.exists(), 'Destination must be fresh')
                require(ROOT not in destination.parents and destination != ROOT, 'Restore outside the repository')
                destination.mkdir(parents=True)
                with zipfile.ZipFile(ROOT / (CAPSULE + 'phase90.zip')) as archive:
                    for row in plan['files']:
                        data = archive.read(row['file'])
                        check_bytes(data, row)
                        path = destination / row['file']
                        path.parent.mkdir(parents=True, exist_ok=True)
                        with path.open('xb') as stream:
                            stream.write(data)
                        path.chmod(row['mode'])
                        require(path.read_bytes() == data and stat.S_IMODE(path.stat().st_mode) == row['mode'],
                                'Restoration verification failed')
                write_fresh(destination / 'restore-receipt.json', {
                    'kind': 'phase90-release-copy-fresh-restoration', 'complete': True,
                    'planSha256': digest(plan_bytes), 'filesRestored': plan['count'],
                    'bytesRestored': plan['bytes'], 'capsuleCommit': COMMIT})
        print(json.dumps({'action': args.action, 'complete': True, 'files': plan['count'],
                          'bytes': plan['bytes'], 'MiB': plan['bytes'] / (1024 * 1024)}))


if __name__ == '__main__':
    main()
