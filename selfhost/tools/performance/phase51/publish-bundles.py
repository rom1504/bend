#!/usr/bin/env python3
"""Package verified saved modules for replay; run only after timing stops."""
import argparse
import gzip
import json
from pathlib import Path
import sys
import tarfile

HERE = Path(__file__).resolve().parent
SH = HERE.parents[2]
sys.path.insert(0, str(HERE.parent / 'programs'))
from run import load_bundle
from support import identity

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('baseline', type=Path)
p.add_argument('candidate', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
assert not a.out.exists()
catalog_file = HERE.parent / 'phase37/catalog.json'
catalog = json.loads(catalog_file.read_text())
catalog_sha = identity(catalog_file)['sha256']
inputs = [identity(__file__), identity(catalog_file),
          identity(HERE.parent / 'programs/run.py'), identity(HERE.parent / 'programs/support.py')]
sources = [('baseline', a.baseline, ['baseline', 'typescript']),
           ('current', a.candidate, ['candidate'])]
for name, file, roles in sources:
    load_bundle(file, catalog, catalog_sha, catalog['cases'], roles, inputs)
a.out.mkdir(parents=True)
publications = []
for name, file, roles in sources:
    file = file.resolve()
    data = json.loads(file.read_text())
    assert 'archive' not in data, 'Input must be the fresh uncompressed acquisition'
    modules = {r['path']: r for c in data['cases'] for r in c['modules'].values()}
    dest = a.out / name
    dest.mkdir()
    archive = dest / 'modules.tar.gz'
    with archive.open('xb') as output, gzip.GzipFile(fileobj=output, mode='wb', filename='', mtime=0) as gz, tarfile.open(fileobj=gz, mode='w|') as tar:
        for relative, record in sorted(modules.items()):
            source = file.parent / relative
            actual = identity(source)
            assert all(actual[k] == record[k] for k in ['bytes', 'sha256'])
            info = tarfile.TarInfo(relative)
            info.size = actual['bytes']
            info.mode = 0o644
            with source.open('rb') as stream:
                tar.addfile(info, stream)
    archive_identity = identity(archive)
    data['archive'] = dict(path=archive.name, **{k: archive_identity[k] for k in ['bytes', 'sha256']})
    manifest = dest / 'manifest.json'
    manifest.write_text(json.dumps(data, indent=2) + '\n')
    # The maintained reader reopens and hashes every archived module.
    load_bundle(manifest, catalog, catalog_sha, catalog['cases'], roles, inputs)
    publications.append(dict(name=name, original=identity(file), manifest=identity(manifest), archive=archive_identity, modules=len(modules)))
for row in inputs:
    assert identity(row['path']) == row
report = dict(kind='phase51-portable-bundles', complete=True, inputs=inputs,
              points=45, publications=publications, reopenedVerified=True,
              scope='Byte-identical replay modules with unchanged compiler-role provenance; no new compilation or performance qualification.')
(a.out / 'publication.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(dict(complete=True, points=45, publication=str(a.out / 'publication.json'))))
