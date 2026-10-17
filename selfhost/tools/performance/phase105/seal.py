#!/usr/bin/env python3
"""Preserve closed benchmark outputs/logs as verified content-addressed evidence."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def digest(data): return hashlib.sha256(data).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--run', type=Path, action='append', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists()
    paths = set()
    for run in a.run:
        run = run.resolve(); assert run.is_relative_to(ROOT/'selfhost/build/phase105')
        report = json.loads((run/'report.json').read_text())
        assert report['complete'] and report['passed'], 'Only closed runs; failures require a separate explicit archive'
        paths.update(f for f in run.rglob('*') if f.is_file())
        for case in report.get('cases',[]):
            for key in ['source','original']:
                if key in case: paths.add(Path(case[key]['file']))
    out.mkdir(parents=True)
    mapping, objects = [], set()
    with zipfile.ZipFile(out/'raw.zip','x',compression=zipfile.ZIP_DEFLATED,compresslevel=6,allowZip64=True) as archive:
        for file in sorted(paths):
            data = file.read_bytes(); key = digest(data)
            if key not in objects:
                archive.writestr('objects/'+key,data);objects.add(key)
            mapping.append(dict(file=str(file.relative_to(ROOT)),sha256=key,bytes=len(data),mode=file.stat().st_mode & 0o777))
    manifest = dict(kind='phase105-content-addressed-evidence',version=1,files=mapping)
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    with zipfile.ZipFile(out/'raw.zip') as archive:
        assert set(archive.namelist()) == {'objects/'+key for key in objects}
        for member in archive.namelist(): assert digest(archive.read(member)) == member.removeprefix('objects/')
        sizes = {i.filename.removeprefix('objects/'):i.file_size for i in archive.infolist()}
        assert all(sizes[r['sha256']]==r['bytes'] for r in mapping)
    receipt = dict(complete=True,verified=True,runDirectories=[str(x.resolve().relative_to(ROOT)) for x in a.run],
        archive=dict(file='raw.zip',bytes=(out/'raw.zip').stat().st_size,sha256=digest((out/'raw.zip').read_bytes())),
        manifest=dict(file='manifest.json',sha256=digest((out/'manifest.json').read_bytes())),
        fileCount=len(mapping),uniqueObjects=len(objects),
        scope='Closed run receipts, every sample path, full C/binaries, logs and benchmark sources. '
              'Identical bytes stored once. Compiler/toolchain/prior-oracle assets remain separately pinned prerequisites.')
    (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt))


if __name__=='__main__':main()
