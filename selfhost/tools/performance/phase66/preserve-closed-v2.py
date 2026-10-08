#!/usr/bin/env python3
"""Data-only Phase65 full preservation check; never writes historical raw trees."""
import argparse
import hashlib
import importlib.util
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.dont_write_bytecode = True
TOOLS = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase66_archive', TOOLS / 'archive.py')
archive = importlib.util.module_from_spec(spec)
spec.loader.exec_module(archive)
ROOT, RAW = archive.ROOT, archive.RAW
pin, read, path = archive.identity, archive.read, archive.repo_file


def closed_inventory(closed):
    files = []
    path(closed)
    for file in archive.walk_paths(closed):
        path(file)
        assert file.is_file() or file.is_dir(), str(file)
        if file.is_file():
            files.append(pin(file))
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}, 'Data-only verification uses CPU0'
    assert not (RAW / 'writers-closed.json').exists(), 'Do not resume a closed campaign'
    out = path(args.output)
    assert not out.exists()
    assert out.is_relative_to(RAW) or out.is_relative_to(ROOT / 'implementation/phase66/evidence')
    manifest_file = ROOT / 'selfhost/tools/performance/phase65/artifacts/manifest.json'
    controls = [Path(__file__).resolve(), TOOLS / 'archive.py', manifest_file,
                RAW / 'inherited-before.json', RAW / 'installed-before.json',
                RAW / 'baseline-source.json']
    controls_before = [pin(p) for p in controls]
    manifest = read(manifest_file)
    assert manifest['complete'] is True and manifest['pass'] is True
    assert manifest['reopenedAllMembers'] is True
    assert len(manifest['files']) == manifest['fileCount'] == 17894
    closed = ROOT / 'selfhost/build/phase65'
    expected = sorted(manifest['files'], key=lambda row: Path(row['file']))
    assert all(path(row['file']).is_relative_to(closed) for row in expected)
    before = closed_inventory(closed)
    assert before == expected, 'Closed Phase65 inventory or bytes differ'
    protected_before = archive.preserved()
    # Phase65 has file:null and TWO ordered parts. Reopen the joined logical
    # stream directly; verify every member without extraction or writes there.
    recovered = archive.verify_archive(manifest['archive'], manifest['files'], manifest_file.parent)
    assert closed_inventory(closed) == before, 'Closed Phase65 changed during verification'
    assert archive.preserved() == protected_before, 'Protected predecessor changed'
    assert [pin(p) for p in controls] == controls_before, 'Control metadata changed'
    result = dict(kind='phase66-closed-evidence-preservation', complete=True,
                  dataOnly=True, targetExecuted=False,
                  created=datetime.now(timezone.utc).isoformat(),
                  producer=pin(Path(__file__).resolve()), controls=controls_before,
                  publishedManifest=pin(manifest_file),
                  closedPhase65=dict(files=len(before), bytes=sum(p['bytes'] for p in before),
                                     exactInventory=True, allHashesUnchanged=True,
                                     inventorySha256=hashlib.sha256(json.dumps(before, separators=(',', ':')).encode()).hexdigest()),
                  publishedArchive=recovered, protected=protected_before,
                  inheritedFiles=110, previousInstalledFiles=7, baselineSourceCopies=299,
                  scope='Every Phase65 raw file and every member of its ordered two-part archive '
                        'is verified. The 110 inherited paths, seven previous-installed copies '
                        'and 299 baseline-source copies retain exact bytes. Historical trees are '
                        'read only. Other historical capsules are explicit external prerequisites; '
                        'this receipt does not re-qualify their whole transitive histories.')
    result['pass'] = True
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=pin(out), files=len(before), archive=recovered, passed=True)))


if __name__ == '__main__':
    main()
