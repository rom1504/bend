#!/usr/bin/env python3
"""Hardlink completed exact-oracle outputs, retaining every artifact path and byte.

Only a complete profiler run below selfhost/build is eligible. Shared output
inodes must remain immutable; subsequent campaigns must use fresh directories.
"""
import argparse
import json
import os
from pathlib import Path
import stat

from run import pin, verify, save

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/build'


def regular(path):
    path = Path(path).absolute()
    if not path.is_relative_to(BUILD) or '..' in path.parts:
        raise ValueError('Only generated build artifacts are eligible')
    current = ROOT
    for part in path.relative_to(ROOT).parts:
        current /= part
        if current.is_symlink():
            raise ValueError('Symlinks are excluded')
    s = path.stat()
    if not stat.S_ISREG(s.st_mode):
        raise ValueError('Regular file required')
    return path, s


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--report', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise ValueError('Fresh receipt required')
    report = json.loads(a.report.read_text())
    manifest_path = a.report.resolve().with_name('manifest.json')
    manifest = json.loads(manifest_path.read_text())
    if not report.get('complete') or not report.get('passed') or report.get('changedInputs'):
        raise ValueError('Only completed, verified campaigns may be deduplicated')
    contracts = {(w['name'], v['name']): v['expected']
                 for w in manifest['workloads'] for v in w['variants']}
    result = dict(complete=False, inputs=[pin(a.report), pin(manifest_path), pin(__file__)],
                  replacements=[], recoveredAllocatedBytes=0,
                  policy='Exact complete-output oracle dedup only. Paths/content/mode/owner/xattrs retained; inode and mtime become shared. Artifacts must remain immutable.')
    save(a.out, result)
    try:
        for row in report['rows']:
            if not row.get('correct'):
                raise ValueError('Unverified row')
            for channel in ('stdout', 'stderr'):
                expected = contracts[row['workload'], row['variant']][channel]
                if expected['kind'] != 'exact' or row[channel]['bytes'] < 64*1024:
                    continue
                verify(row[channel]); verify(expected)
                destination, ds = regular(row[channel]['file'])
                keeper, ks = regular(expected['file'])
                if (row[channel]['sha256'], row[channel]['bytes']) != (expected['sha256'], expected['bytes']):
                    raise ValueError('Oracle/output mismatch')
                if ds.st_ino == ks.st_ino and ds.st_dev == ks.st_dev:
                    continue
                if ds.st_nlink != 1 or (ds.st_dev, ds.st_mode, ds.st_uid, ds.st_gid) != (ks.st_dev, ks.st_mode, ks.st_uid, ks.st_gid):
                    raise ValueError('Ineligible hardlink metadata')
                attrs = lambda f: {n: os.getxattr(f,n) for n in os.listxattr(f)}
                if attrs(destination) != attrs(keeper):
                    raise ValueError('Different extended attributes')
                temporary = destination.with_name(destination.name+'.profile-dedup-link')
                if temporary.exists():
                    raise ValueError('Temporary path already exists')
                entry = dict(source=pin(keeper), destination=pin(destination),
                             priorInode=ds.st_ino, priorMtimeNs=ds.st_mtime_ns,
                             sharedInode=ks.st_ino, allocatedBytes=ds.st_blocks*512, status='pending')
                result['replacements'].append(entry); save(a.out,result)
                try:
                    os.link(keeper,temporary)
                    verify(expected); verify(row[channel])
                    current = destination.stat()
                    metadata = lambda s: (s.st_dev, s.st_ino, s.st_size, s.st_mode,
                        s.st_uid, s.st_gid, s.st_nlink, s.st_mtime_ns, s.st_ctime_ns)
                    if metadata(current) != metadata(ds):
                        raise ValueError('Destination metadata changed')
                    os.replace(temporary,destination)
                    verify(row[channel]); entry['status']='complete'
                    result['recoveredAllocatedBytes'] += ds.st_blocks*512
                finally:
                    if temporary.exists():
                        temporary.unlink()
                save(a.out,result)
        for item in result['inputs']:
            verify(item)
        result['complete']=True
    except BaseException as e:
        result['error']=str(e)
        raise
    finally:
        save(a.out,result)
    print(json.dumps(dict(complete=True,recoveredAllocatedBytes=result['recoveredAllocatedBytes'])))


if __name__ == '__main__':
    main()
