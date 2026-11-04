#!/usr/bin/env python3
"""Hardlink a completed Phase156 full-source pair to its retained qualified oracle.

Preserves paths, bytes, mode, ownership and xattrs. Inode/mtime become shared;
all linked outputs must remain immutable and future runs use fresh directories.
"""
import argparse
import fcntl
import json
import os
from pathlib import Path
import shutil
import stat
import sys

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase156'
LOCK = ROOT / 'selfhost/build/phase32/execution.lock'
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, same_bytes


def regular(path):
    path = Path(path).absolute()
    require(path.resolve() == path and path.is_relative_to(ROOT / 'selfhost/build'), 'Unsymlinked build artifact required')
    info = path.lstat()
    require(stat.S_ISREG(info.st_mode) and not stat.S_IMODE(info.st_mode) & 0o7000, 'Ordinary regular file required')
    return path, info


def metadata(info):
    return {k:getattr(info, k) for k in ('st_dev', 'st_ino', 'st_size', 'st_mode', 'st_uid', 'st_gid', 'st_nlink', 'st_mtime_ns', 'st_ctime_ns')}


def attrs(path):
    return {name:os.getxattr(path, name, follow_symlinks=False).hex() for name in os.listxattr(path, follow_symlinks=False)}


def syncdir(path):
    fd = os.open(path, os.O_RDONLY | os.O_DIRECTORY)
    try: os.fsync(fd)
    finally: os.close(fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); report_path = args.report.absolute(); out = args.out.absolute()
    require(report_path.resolve() == report_path and report_path.parent.parent == BUILD, 'Direct Phase156 campaign required')
    require(out.resolve() == out and out.is_relative_to(ROOT / 'selfhost/build-retention/phase156') and not out.exists(), 'Fresh Phase156 retention directory required')
    require(LOCK.is_file() and LOCK.resolve() == LOCK, 'Existing execution lock required')
    with LOCK.open('r') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB); lock_inode = LOCK.stat().st_ino
        report_pin = pin(report_path); report = json.loads(report_path.read_bytes())
        require(report['kind'] == 'phase156-actual-native-requests' and report['complete'] and report['rounds'] == 1, 'Complete Phase156 pair required')
        require(set(report['roles']) == {'old', 'publication'} and len(report['cases']) == 1, 'Only old/publication full-source pair admitted')
        case = report['cases'][0]
        require(case['name'] == 'full-compiler' and len(case['rows']) == 2 and {r['role'] for r in case['rows']} == set(report['roles']), 'Wrong case/rows')
        require(report['calls'] == [dict(case=case['name'], **row) for row in case['rows']], 'Calls and case rows disagree')
        guard = report_path.parent.with_name(report_path.parent.name + '-guard')
        lifecycle = json.loads((guard / 'retention.json').read_bytes()); process = json.loads((guard / 'process.json').read_bytes())
        require(process['complete'] and lifecycle['state'] in ('finished', 'sealed') and lifecycle['artifactRoots'] == process['artifactRoots'] == [str(report_path.parent)], 'Completed owning guard required')
        command = process['command']; require((ROOT / command[command.index('--out') + 1]).absolute() == report_path.parent, 'Guard output binding differs')
        qpath = ROOT / 'implementation/phase152/qualification.json'; qualified = json.loads(qpath.read_bytes())
        require(qualified['complete'], 'Complete Phase152 qualification required')
        verify(case['oracleReceipt']); oracle = json.loads(Path(case['oracleReceipt']['file']).read_bytes())
        image = pin(ROOT / qualified['selectedNative']['image']['file'])
        require(all(image[k] == qualified['selectedNative']['image'][k] for k in ('bytes', 'sha256')), 'Qualified image changed')
        require(oracle['complete'] and oracle['request']['target'] == 'qbe' and oracle['request']['image'] == image and oracle['request']['source'] == case['source'], 'Qualified oracle producer/source differs')
        require(all(case['source'][k] == qualified['source'][k] for k in ('bytes', 'sha256')), 'Not the qualified full source')
        require(oracle.get('product', oracle.get('retainedIR')) == case['oracle'], 'Oracle receipt/product differs')
        require(Path(case['oracle']['file']).is_relative_to(ROOT / 'selfhost/build/phase152'), 'Retained Phase152 oracle required')
        inputs = [report_pin, pin(__file__), pin(ROOT / 'selfhost/tools/profiler/deduplicate.py'), pin(qpath), pin(guard / 'process.json'), pin(guard / 'retention.json'), case['oracleReceipt'], case['oracle'], *report['inputs']]
        for item in inputs: verify(item)
        keeper, ks = regular(case['oracle']['file']); keeper_attrs = attrs(keeper); rows = []
        for row in case['rows']:
            child = row['process']; require(row['passed'] and row['byteExact'] and child['complete'] and child['exitCode'] == 0, 'Unverified child')
            require(child['stdout']['bytes'] == child['stderr']['bytes'] == 0, 'Unexpected diagnostics')
            destination, ds = regular(row['product']['file'])
            require(destination == report_path.parent / (case['name'] + '-0-' + row['role']) / 'program.ssa', 'Output path binding differs')
            require(child['command'][-3:] == [case['source']['file'], row['role'], str(destination)], 'Child command/product differs')
            require(all(row['product'][k] == case['oracle'][k] for k in ('bytes', 'sha256')), 'Oracle identity mismatch')
            verify(row['product']); require(same_bytes(destination, keeper), 'Exact bytes differ')
            require((ds.st_dev, ds.st_mode, ds.st_uid, ds.st_gid) == (ks.st_dev, ks.st_mode, ks.st_uid, ks.st_gid) and attrs(destination) == keeper_attrs, 'Mode/owner/device/xattrs differ')
            shared = ds.st_dev == ks.st_dev and ds.st_ino == ks.st_ino
            require(shared or ds.st_nlink == 1, 'Destination already shares another inode')
            temporary = destination.with_name(destination.name + '.phase156-dedup-link')
            require(not temporary.exists() and not temporary.is_symlink(), 'Temporary link exists')
            rows.append(dict(source=case['oracle'], destination=row['product'], prior=metadata(ds), xattrs=keeper_attrs, allocatedBytes=0 if shared else ds.st_blocks * 512, status='already-shared' if shared else 'pending'))
        out.mkdir(parents=True); syncdir(out.parent)
        result = dict(kind='phase156-full-output-dedup', version=1, complete=False, inputs=inputs, replacements=rows, recoveredAllocatedBytes=0, freeBeforeBytes=shutil.disk_usage(ROOT).free, policy=__doc__)
        def save():
            with (out / 'report.json').open('w') as stream:
                json.dump(result, stream, indent=2); stream.write('\n'); stream.flush(); os.fsync(stream.fileno())
            syncdir(out)
        save()
        with (out / 'journal.jsonl').open('x') as journal:
            def note(value):
                journal.write(json.dumps(value) + '\n'); journal.flush(); os.fsync(journal.fileno()); syncdir(out)
            note(dict(event='intent', inputs=inputs, replacements=rows))
            try:
                for entry in rows:
                    if entry['status'] == 'already-shared': continue
                    destination = Path(entry['destination']['file']); temporary = destination.with_name(destination.name + '.phase156-dedup-link')
                    require(metadata(destination.stat()) == entry['prior'] and attrs(destination) == keeper_attrs, 'Destination metadata changed')
                    verify(entry['destination']); verify(case['oracle']); require(attrs(keeper) == keeper_attrs, 'Oracle xattrs changed')
                    current = keeper.stat(); require((current.st_dev, current.st_ino, current.st_mode, current.st_uid, current.st_gid) == (ks.st_dev, ks.st_ino, ks.st_mode, ks.st_uid, ks.st_gid), 'Oracle inode/metadata changed')
                    note(dict(event='replace-pending', destination=str(destination)))
                    os.link(keeper, temporary); os.replace(temporary, destination); syncdir(destination.parent)
                    verify(entry['destination']); require(destination.stat().st_ino == ks.st_ino and attrs(destination) == keeper_attrs, 'Replacement verification failed')
                    entry['status'] = 'complete'; result['recoveredAllocatedBytes'] += entry['allocatedBytes']
                    note(dict(event='replace-complete', destination=str(destination), sharedInode=ks.st_ino)); save()
                for item in inputs: verify(item)
                require(LOCK.stat().st_ino == lock_inode, 'Execution lock inode changed')
                result['complete'] = True
            except BaseException as error:
                result['error'] = str(error); raise
            finally:
                result['freeAfterBytes'] = shutil.disk_usage(ROOT).free; save()
        print(json.dumps({k:result[k] for k in ('complete', 'recoveredAllocatedBytes', 'freeBeforeBytes', 'freeAfterBytes')}))


if __name__ == '__main__': main()
