#!/usr/bin/env python3
"""Versioned native-build guard with whole-run disk admission and monitoring.

The original Phase111 guard and process supervisor remain frozen. This successor
reuses the same lock inode and owned-process cleanup; it does not delete files.
Disk accounting is sampled, not a filesystem quota. Declare every output root.
"""
import argparse
import importlib.util
import json
import math
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
SUPPORT = ROOT/'selfhost/tools/performance/programs/support.py'
spec = importlib.util.spec_from_file_location('retention_guard_support', SUPPORT)
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
MIB = 1024**2


def allocated_bytes(roots):
    """Count regular-file and directory blocks once; never follow symlinks."""
    seen, total = set(), 0
    pending = list(roots)
    while pending:
        path = pending.pop()
        try:
            info = path.lstat()
        except FileNotFoundError:
            continue
        key = (info.st_dev, info.st_ino)
        if key in seen:
            continue
        seen.add(key)
        total += info.st_blocks*512
        if stat.S_ISDIR(info.st_mode):
            with os.scandir(path) as entries:
                pending.extend(Path(entry.path) for entry in entries)
    return total


class DiskGuard(S.ExecutionGuard):
    def __init__(self, *, disk_bytes, reserve_bytes=5120*MIB, filesystem=ROOT,
                 free_bytes=None, usage_bytes=allocated_bytes, scan_seconds=1.0,
                 **kwargs):
        super().__init__(**kwargs)
        if disk_bytes <= 0 or reserve_bytes < 0 or not math.isfinite(scan_seconds) or scan_seconds <= 0:
            raise ValueError('Positive disk budget/scan interval and nonnegative reserve required')
        self.disk_budget = disk_bytes
        self.disk_reserve = reserve_bytes
        self.filesystem = Path(filesystem)
        self.disk_free = free_bytes or (lambda: shutil.disk_usage(self.filesystem).free)
        self.disk_usage = usage_bytes
        self.scan_seconds = scan_seconds
        self.locked = False

    def __enter__(self):
        super().__enter__()
        self.locked = True
        return self

    def __exit__(self, *args):
        try:
            super().__exit__(*args)
        finally:
            self.locked = False

    def run(self, command, directory, deadline, *, run_roots, env=None, method=None):
        if not self.locked:
            raise RuntimeError('Disk admission must occur under the shared execution lock')
        directory = Path(directory).absolute()
        roots = [Path(path).absolute() for path in run_roots]
        all_roots = [directory, *roots]
        if not roots or len(set(all_roots)) != len(all_roots):
            raise ValueError('Distinct guard output and artifact roots required')
        if any(a in b.parents or b in a.parents for i,a in enumerate(all_roots) for b in all_roots[i+1:]):
            raise ValueError('Guard output and artifact roots must not overlap')
        if any(path.exists() or path.is_symlink() for path in all_roots):
            raise ValueError('Fresh guard output and artifact roots required')
        device = self.filesystem.stat().st_dev
        for path in all_roots:
            parent = path.parent
            while not parent.exists():
                parent = parent.parent
            if path.resolve() != path or parent.stat().st_dev != device:
                raise ValueError('Output roots must be nonsymlink paths on the admitted filesystem')
        begin = time.monotonic()
        initial_free = self.disk_free()
        directory.mkdir(parents=True)
        report = dict(kind='build-retention-disk-guard-v1', complete=False, started=time.time(),
                      command=list(map(str, command)), returncode=None,
                      rssLimitBytes=self.rss_limit, availableFloorBytes=self.available_floor,
                      peakTreeRssBytes=0, minimumAvailableBytes=S.available_bytes(),
                      diskBudgetBytes=self.disk_budget, diskReserveBytes=self.disk_reserve,
                      initialDiskFreeBytes=initial_free, minimumDiskFreeBytes=initial_free,
                      peakRunAllocatedBytes=0, peakFilesystemDecreaseBytes=0,
                      artifactRoots=list(map(str, roots)), lockPath=str(self.lock_path),
                      diskAccounting='Sampled declared-root allocated blocks plus conservative net filesystem free decrease; external writers can cause refusal. Hardlinks counted once within roots. Not a filesystem quota.',
                      method=method)
        lifecycle = dict(kind='build-retention-run-v1', version=1, state='active', outcome=None,
                         closed=False, started=report['started'], artifactRoots=report['artifactRoots'],
                         guardDirectory=str(directory), diskBudgetBytes=self.disk_budget,
                         diskReserveBytes=self.disk_reserve, retained=[], archived=[], disposable=[],
                         qualification='A successful command is not automatically a qualified compiler.',
                         automaticDeletion=False)
        S.save(directory/'process.json', report)
        S.save(directory/'retention.json', lifecycle)
        clean_env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ('NODE_OPTIONS','NODE_PATH')}
        clean_env.update(env or {})
        self.seen = {}
        next_scan = begin

        def disk_reason(force=False):
            nonlocal next_scan
            free = self.disk_free()
            report['minimumDiskFreeBytes'] = min(report['minimumDiskFreeBytes'], free)
            decrease = max(0, initial_free-free)
            report['peakFilesystemDecreaseBytes'] = max(report['peakFilesystemDecreaseBytes'], decrease)
            if force or time.monotonic() >= next_scan:
                usage = self.disk_usage(all_roots)
                report['peakRunAllocatedBytes'] = max(report['peakRunAllocatedBytes'], usage)
                next_scan = time.monotonic()+self.scan_seconds
            if free < self.disk_reserve:
                return 'disk-reserve'
            if decrease > self.disk_budget or report['peakRunAllocatedBytes'] > self.disk_budget:
                return 'disk-budget'
            return None

        try:
            # Includes the small guard receipts written above and rechecks under
            # the lock immediately before any child can start.
            current_free = self.disk_free()
            report['minimumDiskFreeBytes'] = min(initial_free, current_free)
            reason = ('signal' if self.interrupted else
                      'deadline' if time.monotonic() >= deadline else
                      'host-headroom' if S.available_bytes() < self.available_floor else
                      'disk-admission' if current_free < self.disk_reserve+self.disk_budget else None)
            if reason:
                report['stoppedFor'] = reason
            else:
                with (directory/'stdout.log').open('w') as stdout, (directory/'stderr.log').open('w') as stderr:
                    self.active = subprocess.Popen(report['command'], stdout=stdout, stderr=stderr,
                                                   env=clean_env, start_new_session=True)
                    self._tree(self.active.pid)
                    while self.active.poll() is None:
                        rss, free = self._tree(self.active.pid), S.available_bytes()
                        report['peakTreeRssBytes'] = max(report['peakTreeRssBytes'], rss)
                        report['minimumAvailableBytes'] = min(report['minimumAvailableBytes'], free)
                        reason = ('signal' if self.interrupted else
                                  'tree-rss-limit' if rss > self.rss_limit else
                                  'host-headroom' if free < self.available_floor else
                                  'deadline' if time.monotonic() >= deadline else disk_reason())
                        if reason:
                            report['stoppedFor'] = reason
                            break
                        time.sleep(.02)
                    self._stop()
                    report['returncode'] = self.active.wait(timeout=2)
                # Fast children may exit before the polling loop; their final
                # retained outputs must still satisfy the whole-run budget.
                reason = disk_reason(force=True)
                if reason:
                    report.setdefault('stoppedFor', reason)
                report['complete'] = report['returncode'] == 0 and 'stoppedFor' not in report
        except Exception as error:
            report['error'] = repr(error)
        finally:
            self._stop()
            if self.active is not None:
                report['returncode'] = self.active.wait(timeout=2)
            self.active = None
            report.update(wallSeconds=time.monotonic()-begin, finished=time.time())
            lifecycle.update(state='finished', outcome='succeeded' if report['complete'] else 'failed',
                             finished=report['finished'], stoppedFor=report.get('stoppedFor'))
            S.save(directory/'process.json', report)
            S.save(directory/'retention.json', lifecycle)
        return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--run-root', type=Path, action='append', required=True,
                        help='Fresh artifact output root; repeat to declare every output location')
    parser.add_argument('--seconds', type=int, required=True)
    parser.add_argument('--disk-mib', type=int, required=True, help='Whole-run peak additional disk, including logs and guard receipts')
    parser.add_argument('--reserve-mib', type=int, default=5120)
    parser.add_argument('--rss-mib', type=int, default=2048)
    parser.add_argument('--available-mib', type=int, default=4096)
    parser.add_argument('--file-mib', type=int, default=128)
    parser.add_argument('--cpu', default='3')
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    if not command or args.seconds <= 0 or args.disk_mib <= 0 or args.reserve_mib < 0:
        parser.error('Command, positive duration/disk budget and nonnegative reserve required')
    if not (64 <= args.file_mib <= 256 and 0 < args.rss_mib <= 6144 and args.available_mib >= 4096):
        parser.error('Unsupported file/RSS/headroom limits')
    if args.rss_mib > 3072 and args.available_mib < 16384:
        parser.error('More than3GiB RSS requires16GiB host headroom')
    roots = [args.out, *args.run_root]
    if any(not path.absolute().is_relative_to(ROOT/'selfhost/build') for path in roots):
        parser.error('Fresh output paths must lie under selfhost/build')
    identities = [S.identity(file) for file in command if Path(file).is_file()]
    wrapped = ['bash','-c',f'ulimit -f {args.file_mib*1024}; ulimit -c 0; exec "$@"',
               'bend-build', 'taskset','-c',args.cpu,*command]
    method = dict(guard=S.identity(__file__), support=S.identity(SUPPORT), cpu=args.cpu,
                  fileLimitBytes=args.file_mib*MIB, commandFiles=identities)
    with DiskGuard(disk_bytes=args.disk_mib*MIB, reserve_bytes=args.reserve_mib*MIB,
                   rss_mib=args.rss_mib, available_mib=args.available_mib) as guard:
        report = guard.run(wrapped, args.out, time.monotonic()+args.seconds,
                           run_roots=args.run_root, method=method)
    print(json.dumps(report), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
