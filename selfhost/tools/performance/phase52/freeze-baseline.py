#!/usr/bin/env python3
"""Repackage portable checked current + pinned TS outputs; execute no target/compiler."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import shutil
import sys
import tarfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'programs'))
from run import load_bundle, verify
from support import identity, save


def record(data, path):
    return dict(path=path, bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--current', type=Path, required=True)
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--catalog', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--expected-api', required=True, help='Explicit starting checked API SHA256')
    p.add_argument('--expected-runtime', required=True, help='Explicit Phase51 selected runtime SHA256')
    a = p.parse_args()
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    catalog = json.loads(a.catalog.read_text()); sha = identity(a.catalog)['sha256']
    inputs = [identity(x) for x in [__file__, a.current, a.reference, a.catalog]]
    parent_method = identity(HERE.parent / 'phase44/freeze-baseline.py')
    assert parent_method['sha256'] == '44ca91627a50ac8e35551beb3aca9ca2516c03de9c96dece2f31d84c40d500f7'
    inputs.append(parent_method)
    current = load_bundle(a.current, catalog, sha, catalog['cases'], ['candidate'], inputs, out / 'work/current')
    ref = load_bundle(a.reference, catalog, sha, catalog['cases'], ['baseline', 'typescript'], inputs, out / 'work/reference')
    c = current['roles']['candidate']['compiler']
    assert len(a.expected_api) == 64 and all(x in '0123456789abcdef' for x in a.expected_api)
    assert c['api']['sha256'] == a.expected_api == 'c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061'
    assert c['runtime']['sha256'] == a.expected_runtime == '3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46'
    assert c['kind'] == 'checked-development-attempt'
    origin = json.loads(a.current.read_text())
    assert origin['complete'] and origin.get('archive') and origin.get('provenance')
    verify(a.current.parent / origin['provenance']['path'], origin['provenance'])
    assert json.loads((a.current.parent / origin['provenance']['path']).read_text())['complete']
    files = {'consumed/freeze-baseline.py': Path(__file__).read_bytes()}
    # Retain already-closed portable acquisitions, never recurse over raw builds.
    for label, manifest in [('current', a.current), ('reference', a.reference)]:
        origin = json.loads(manifest.read_text())
        for name in ['manifest.json', origin['provenance']['path'], origin['archive']['path']]:
            file = manifest.parent / name
            assert file.is_file() and not file.is_symlink()
            files['acquisition/' + label + '/' + name] = file.read_bytes()
            inputs.append(identity(file))
    roles = {'baseline': current['roles']['candidate'], 'typescript': ref['roles']['typescript']}
    roles['baseline']['label'] = 'Phase52 starting Phase51 selected (retained portable acquisition)'
    cases = []
    for case in catalog['cases']:
        row = dict(id=case['id'], sourceSha256=case['source']['sha256'], point=case['point'], modules={})
        for role, bundle, oldrole in [('baseline', current, 'candidate'), ('typescript', ref, 'typescript')]:
            item = bundle['points'][case['id']][oldrole]
            data = Path(item['resolved']).read_bytes()
            name = role + '/modules/' + item['sha256'] + '.mjs'
            files[name] = data; row['modules'][role] = record(data, name)
        cases.append(row)
    provenance = dict(kind='phase52-retained-phase51-reference', complete=True,
        scope='Repackages exact retained Phase51 selected current and pinned TS outputs. No new compilation or execution. Current candidate role is relabeled baseline; original receipts and reference archive are retained.',
        inputs=inputs, cases=len(cases), baselineApi=c['api']['sha256'], parentTool=parent_method)
    data = (json.dumps(provenance, indent=2)+'\n').encode(); files['provenance.json'] = data
    archive = out / 'programs.tar.gz'
    with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', filename='', mtime=0) as gz:
        with tarfile.open(fileobj=gz, mode='w|') as tar:
            for name, body in sorted(files.items()):
                info = tarfile.TarInfo(name); info.size=len(body); info.mode=0o644; info.mtime=0
                tar.addfile(info, io.BytesIO(body))
    with tarfile.open(archive, 'r:gz') as tar:
        members=tar.getmembers(); assert len(members)==len(files)
        for m in members: assert m.isfile() and tar.extractfile(m).read()==files[m.name]
    for item in inputs: verify(item['path'], item)
    save(out/'manifest.json', dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
        upstreamCommit=catalog['upstreamCommit'], catalogSha256=sha, roles=roles, cases=cases,
        archive=record(archive.read_bytes(),'programs.tar.gz'), provenance=record(data,'provenance.json'),
        preservation=dict(members=len(files), reopenedVerified=True)))
    save(out/'provenance.json', provenance)
    shutil.rmtree(out/'work')
    print(json.dumps(dict(complete=True, cases=len(cases), bytes=archive.stat().st_size)))


if __name__ == '__main__':
    main()
