#!/usr/bin/env python3
"""Reclaim disk by hard-linking exact immutable generated build duplicates.

Paths, contents and modes survive; record original timestamps/inodes explicitly.
Never use this on editable source. A future editor of these historical outputs
must replace the file atomically, or first copy it to a new experiment directory.
"""
import fcntl, hashlib, json, os, pathlib, shutil, stat, sys

root = pathlib.Path(__file__).resolve().parents[4]
plan, receipt = map(pathlib.Path, sys.argv[1:])
assert not receipt.exists()
groups = json.loads(plan.read_text())
result = dict(complete=False, plan=str(plan.resolve()), freeBefore=shutil.disk_usage(root).free,
              pathsPreserved=True, contentsPreserved=True, modesPreserved=True, rows=[])

def save():
    receipt.write_text(json.dumps(result, indent=2) + '\n')

with (root/'selfhost/build/phase32/execution.lock').open() as lock:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    for group in groups:
        paths = [pathlib.Path(p) for p in group['paths']]
        for path in paths:
            assert path.is_relative_to(root/'selfhost/build') and path.suffix in ['.c', '.mjs']
            info = path.lstat()
            assert stat.S_ISREG(info.st_mode) and info.st_nlink == 1
            assert (info.st_size, info.st_mode) == (group['bytes'], group['mode'])
            assert hashlib.sha256(path.read_bytes()).hexdigest() == group['sha256']
    save()
    for group in groups:
        keeper = pathlib.Path(group['paths'][0])
        for name in group['paths'][1:]:
            path = pathlib.Path(name)
            before = path.stat()
            assert path.read_bytes() == keeper.read_bytes()
            temporary = path.with_name(path.name + '.phase94-link')
            assert not temporary.exists()
            os.link(keeper, temporary)
            os.replace(temporary, path)
            assert path.samefile(keeper)
            result['rows'].append(dict(file=name, keeper=str(keeper), sha256=group['sha256'],
                bytes=group['bytes'], mode=before.st_mode, oldInode=before.st_ino,
                oldMtimeNs=before.st_mtime_ns, newInode=path.stat().st_ino))
        save()
    result.update(complete=True, freeAfter=shutil.disk_usage(root).free,
                  logicalBytesDeduplicated=sum(row['bytes'] for row in result['rows']))
    save()
print(json.dumps({k:v for k,v in result.items() if k != 'rows'}))
