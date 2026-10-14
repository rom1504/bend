#!/usr/bin/env python3
"""Restore only native89 assets listed in sealed evidence02/03 capsules.

Restore Phase88 shared runtime/cache assets with phase88/restore.py first.
No compiler or generated program is executed here.
"""
import argparse
import hashlib
import json
import os
import shutil
import tempfile
import zipfile
from pathlib import Path

from admission import ROOT, DEFAULT_CACHE, authenticate, pin, require


def relative_pin(record):
    path = (ROOT / record['file']).resolve()
    require(path.is_relative_to(ROOT), 'Escaping capsule path')
    actual = pin(path)
    require(all(actual[k] == record[k] for k in ('sha256', 'bytes')),
            'Changed capsule metadata: ' + str(path))
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify-only', action='store_true', help='Verify selected archived bytes without writing')
    args = parser.parse_args()
    members, archives, names, images = {}, {}, set(), set()
    for suffix in ('02', '03'):
        receipt = json.loads((ROOT/f'implementation/phase89/evidence{suffix}.json').read_text())
        require(receipt['complete'], 'Incomplete capsule')
        archive = relative_pin(receipt['archive'])
        rows = json.loads(relative_pin(receipt['manifest']).read_text())
        require(len({row['file'] for row in rows}) == len(rows), 'Duplicate capsule members')
        archives[archive] = rows
        # A later capsule explicitly supersedes a same-path earlier snapshot.
        for row in rows:
            members[row['file']] = (archive, row)
        if 'nativeAssets' in receipt:
            assets = json.loads(relative_pin(receipt['nativeAssets']).read_text())
            require(assets['canonicalRoot'] == str(ROOT), 'Relocation requires new qualification')
            names.update(assets['files'])
            images.add(assets['executable'])
    require(names and images and names <= members.keys(), 'Missing sealed native asset selection')
    require(images <= names, 'Native image absent from asset selection')
    needed = 0
    for name in names:
        _, row = members[name]
        dest = (ROOT/name).resolve()
        require(dest.is_relative_to(ROOT), 'Escaping asset path')
        if dest.exists():
            actual = pin(dest)
            require(all(actual[k] == row[k] for k in ('sha256', 'bytes')),
                    'Refusing changed existing file: ' + str(dest))
        else:
            needed += row['bytes']
    if not args.verify_only:
        require(shutil.disk_usage(ROOT).free >= needed + 160*1024**2,
                'Insufficient disk for restoration plus 160 MiB reserve')
    for archive, rows in archives.items():
        with zipfile.ZipFile(archive) as saved:
            require(saved.namelist() == [row['file'] for row in rows], 'Archive member list mismatch')
            for row in rows:
                name = row['file']
                if name not in names or members[name][0] != archive:
                    continue
                data = saved.read(name)
                require(len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'],
                        'Corrupt archived asset: ' + name)
                dest = ROOT/name
                if args.verify_only or dest.exists():
                    continue
                dest.parent.mkdir(parents=True, exist_ok=True)
                with tempfile.NamedTemporaryFile(dir=dest.parent) as temp:
                    temp.write(data); temp.flush(); os.link(temp.name, dest)
    if not args.verify_only:
        for name in images:
            image = ROOT/name
            image.chmod(image.stat().st_mode | 0o111)
            authenticate(image, DEFAULT_CACHE)
    print(json.dumps(dict(complete=True, verifiedFiles=len(names),
                         mode='verify' if args.verify_only else 'restore', targetJobsRun=0)))


if __name__ == '__main__':
    main()
