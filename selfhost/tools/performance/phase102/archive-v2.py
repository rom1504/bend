#!/usr/bin/env python3
"""Archive frozen Phase102 evidence and explicitly referenced public CLI requests."""
import argparse
import hashlib
import json
from pathlib import Path
import stat
import tarfile

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase102'
DEFAULT_OUT = ROOT / 'implementation/phase102/evidence'
REQUESTS = ROOT / 'selfhost/build/native/requests'
PARENT = Path(__file__).with_name('archive.py')


def digest(stream):
    result = hashlib.sha256()
    while True:
        block = stream.read(1024 * 1024)
        if not block:
            return result.hexdigest()
        result.update(block)


def pin(path):
    path = Path(path).absolute()
    assert not path.is_symlink() and path.resolve(strict=True) == path
    assert path.is_relative_to(ROOT) and path.is_file()
    with path.open('rb') as stream:
        sha = digest(stream)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=sha)


def read_bound(record):
    assert pin(record['file']) == record, 'Changed or missing receipt: ' + record['file']
    return json.loads(Path(record['file']).read_text())


def request_directory(record):
    request = read_bound(record)
    path = Path(record['file'])
    assert path.name == 'report.json' and path.parent.parent == REQUESTS
    assert request['kind'] == 'bend-native-compiler-request' and request['version'] == 1
    assert request['log'] == str(path.parent), 'Request log differs from its receipt directory'
    # Expected refusal requests have complete=False, and may have no guard.
    # Preserve their whole actual directory without inventing missing artifacts.
    if 'process' in request:
        process_path = path.parent / 'guard/process.json'
        assert json.loads(process_path.read_text()) == request['process']
        for stream in ('stdout.log', 'stderr.log'):
            assert (process_path.parent / stream).is_file()
        for stream in ('launcher.stdout', 'launcher.stderr'):
            assert (path.parent / stream).is_file()
    for output in request.get('outputs', []):
        assert Path(output['file']).parent == path.parent
        assert pin(output['file']) == output, 'Changed request output'
    return path.parent


def cli_requests(path):
    report_pin = pin(path)
    report = read_bound(report_pin)
    assert report['kind'] == 'bend-native-public-cli-controls' and report['version'] == 1
    assert report['complete'] and report['passed'] and report['inputsUnchanged']
    rows = report['rows']
    assert len(rows) == 9 and all(row['passed'] for row in rows)
    assert len({row['name'] for row in rows}) == len(rows)
    directories = []
    request_pins = []
    for row in rows:
        directories.append(request_directory(row['request']))
        request_pins.append(row['request'])
        for stream in ('stdout', 'stderr'):
            pin_record = row[stream]
            assert pin(pin_record['file']) == pin_record
    assert len(set(directories)) == len(rows), 'Repeated CLI request directory'
    return report_pin, request_pins, directories


def members(roots):
    files = set()
    for root in roots:
        assert root.exists() and not root.is_symlink()
        values = [root] if root.is_file() else root.rglob('*')
        for path in values:
            assert not path.is_symlink(), 'Symlink in evidence: ' + str(path)
            if path.is_file():
                assert path.resolve(strict=True) == path and path.is_relative_to(ROOT)
                files.add(path)
    return sorted(files)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--frozen', action='store_true', required=True,
                        help='Confirm all included target and metadata writers have stopped')
    parser.add_argument('--cli-report', type=Path, action='append', default=[],
                        help='Complete Phase102 public CLI report; repeat for multiple reports')
    parser.add_argument('--request-report', type=Path, action='append', default=[],
                        help='Exact additional request receipt, e.g. the final default smoke')
    parser.add_argument('--out', type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'implementation/phase102') and not out.exists()
    roots = [BUILD, *sorted((ROOT / 'selfhost/build/phase99').glob('phase102-*')),
             ROOT / 'selfhost/tools/performance/phase99/runtime']
    cli_pins, request_pins, request_dirs = [], [], []
    for path in args.cli_report:
        path = path.resolve(strict=True)
        assert any(path.is_relative_to(root) for root in roots[: -1]), 'Not a Phase102 CLI report'
        report_pin, requests, directories = cli_requests(path)
        cli_pins.append(report_pin)
        request_pins.extend(requests)
        request_dirs.extend(directories)
    for path in args.request_report:
        record = pin(path.resolve(strict=True))
        request_dirs.append(request_directory(record))
        request_pins.append(record)
    request_dirs = sorted(set(request_dirs))
    roots.extend(request_dirs)
    roots.extend([Path(__file__).resolve(), PARENT])
    method_pins = [pin(__file__), pin(PARENT)]
    files = members(roots)
    assert files
    manifest = []
    for path in files:
        record = pin(path)
        manifest.append(dict(path=str(path.relative_to(ROOT)), bytes=record['bytes'],
                             mode=stat.S_IMODE(path.stat().st_mode), sha256=record['sha256']))
    out.mkdir(parents=True, exist_ok=False)
    archive = out / 'phase102.tar.xz'
    with tarfile.open(archive, 'w:xz', preset=3, dereference=True) as saved:
        for path in files:
            saved.add(path, arcname=str(path.relative_to(ROOT)), recursive=False)
    with tarfile.open(archive, 'r:xz') as saved:
        actual = saved.getmembers()
        assert len(actual) == len(manifest)
        for expected, member in zip(manifest, actual):
            assert member.name == expected['path'] and member.isfile()
            assert member.size == expected['bytes'] and member.mode == expected['mode']
            with saved.extractfile(member) as stream:
                assert digest(stream) == expected['sha256']
    assert members(roots) == files, 'Evidence paths changed during archive'
    for record in [*method_pins, *cli_pins, *request_pins]:
        assert pin(record['file']) == record, 'Request receipt changed during archive'
    with archive.open('rb') as stream:
        archive_sha = digest(stream)
    receipt = dict(kind='phase102-frozen-evidence-archive', complete=True,
        method=method_pins[0], parentMethod=method_pins[1], targetsRun=False,
        roots=[str(path.relative_to(ROOT)) for path in roots],
        cliReports=cli_pins, requestReports=request_pins,
        explicitRequestDirectories=[str(path.relative_to(ROOT)) for path in request_dirs],
        files=len(manifest), uncompressedBytes=sum(row['bytes'] for row in manifest),
        archive=dict(path=str(archive.relative_to(ROOT)), bytes=archive.stat().st_size, sha256=archive_sha),
        everyMemberVerified=True,
        scope='Original-path experiment evidence plus only explicitly referenced public request directories; no all-native-history scan, no receipt rewriting, no restoration claim.')
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    main()
