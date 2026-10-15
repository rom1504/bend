#!/usr/bin/env python3
"""Seal six completed public-CLI control request directories; never run targets."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import zipfile

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent
CONTROL = ROOT/'selfhost/build/phase90/native-cli01/report.json'
REQUESTS = ROOT/'selfhost/build/native/requests'
RESERVE = 160*1024**2
NAMES = ['cached-small', 'live-file-io', 'repeated-map', 'existing-output-refusal',
         'changed-manifest-refusal', 'invalid-source']


def pin(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for data in iter(lambda: stream.read(1024*1024), b''):
            h.update(data)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def verify(record):
    actual = pin(record['file'])
    assert actual['sha256'] == record['sha256']
    if 'bytes' in record:
        assert actual['bytes'] == record['bytes']
    return actual


def read(file):
    return json.loads(Path(file).read_text())


def original(file):
    file = Path(file)
    assert not file.is_symlink() and stat.S_ISREG(file.stat().st_mode), file
    identity = pin(file)
    return dict(path=str(file.resolve().relative_to(ROOT)), bytes=identity['bytes'],
                sha256=identity['sha256'], mode=stat.S_IMODE(file.stat().st_mode))


def inventory(directories):
    files = [CONTROL]
    empty = []
    for directory in directories:
        for entry in sorted(directory.rglob('*')):
            assert not entry.is_symlink(), entry
            if entry.is_dir():
                if not any(entry.iterdir()):
                    empty.append(str(entry.relative_to(ROOT)))
            else:
                assert entry.is_file(), entry
                files.append(entry)
    return [original(p) for p in sorted(files)], sorted(empty)


def write(file, value):
    with file.open('x') as stream:
        stream.write(json.dumps(value, indent=2)+'\n')


def main():
    try:
        os.sched_setaffinity(0, {0})
    except OSError:
        pass
    archive = HERE/'requests.zip'
    manifest_file, receipt_file = HERE/'manifest.json', HERE/'receipt.json'
    public = ROOT/'implementation/phase90/public-cli-evidence.json'
    assert all(not p.exists() for p in [archive, manifest_file, receipt_file, public])
    control_pin = pin(CONTROL)
    control = read(CONTROL)
    assert control['kind'] == 'phase90-native-public-cli-controls'
    assert control['complete'] and control['passed'] and control['inputsUnchanged']
    assert [r['name'] for r in control['rows']] == NAMES
    external = [verify(p) for p in control['inputs']]
    directories, checks = [], []
    for row in control['rows']:
        assert row['passed']
        for key in ['request', 'stdout', 'stderr']:
            verify(row[key])
        request_path = Path(row['request']['file']).resolve()
        directory = request_path.parent
        assert directory.parent == REQUESTS and request_path.name == 'report.json'
        assert directory not in directories
        directories.append(directory)
        request = read(request_path)
        assert request['kind'] == 'phase90-native-compiler-request' and request['log'] == str(directory)
        verify(request['method'])
        guard_file = directory/'guard/process.json'
        guard = read(guard_file) if guard_file.exists() else None
        positive = row['name'] in NAMES[:3]
        if positive:
            assert row['returncode'] == 0 and request['complete'] and request['repeatedCEqual']
            assert row['calls'] == request['calls'] == (5 if row['name'] == 'repeated-map' else 1)
            assert row['allOutputsExact'] and len(request['outputs']) == row['calls']
            published = verify(row['output'])
            assert verify(request['output']) == published
            for output in request['outputs']:
                actual = verify(output)
                assert Path(actual['file']).parent == directory
                assert all(actual[k] == published[k] for k in ['sha256', 'bytes'])
        else:
            assert row['returncode'] == 1 and not request['complete'] and request.get('error')
            assert not list(directory.glob('program.*.c'))
            if row['name'] == 'existing-output-refusal':
                assert row['targetExecuted'] is False and row['existingOutputUnchanged']
                assert request['error'] == 'Output already exists' and guard is None
            elif row['name'] == 'changed-manifest-refusal':
                assert row['targetExecuted'] is False and guard is None
                assert request['error'].startswith('Artifact changed: ')
                verify(row['changedSelection'])
            else:
                assert row['expectedRejectionObserved'] and row['outputAbsent']
                assert 'parse:' in (directory/'guard/stderr.log').read_text()
        if guard is not None:
            assert request['process'] == guard
            assert guard['returncode'] == (0 if positive else 1)
            assert isinstance(guard.get('finished'), (int, float)) and guard['finished'] >= guard['started']
            assert not guard.get('stoppedFor') and guard['returncode'] >= 0
            # ExecutionGuard.complete means exit status zero; expected rejection
            # still has a finished, resource-bounded guard with returncode one.
            assert guard['complete'] is positive
            assert guard['peakTreeRssBytes'] <= guard['rssLimitBytes']
        checks.append(dict(name=row['name'], controlPassed=True, request=str(request_path.relative_to(ROOT)),
                           directory=str(directory.relative_to(ROOT)), requestComplete=request['complete'],
                           launcherReturncode=row['returncode'], compilerExecuted=guard is not None,
                           compilerReturncode=guard['returncode'] if guard else None,
                           guardFinished=guard is not None, expectedRefusal=not positive))
    files, empty = inventory(directories)
    input_bytes = sum(p['bytes'] for p in files)
    before_free = shutil.disk_usage(ROOT).free
    assert before_free > RESERVE + input_bytes + 10*1024**2, 'Insufficient conservative ZIP headroom'
    manifest = dict(kind='phase90-public-cli-request-evidence-manifest', version=1,
                    sourceControl=control_pin, method=pin(__file__), controls=checks,
                    directories=[str(p.relative_to(ROOT)) for p in directories], files=files,
                    emptyDirectories=empty, externalControlInputs=external,
                    scope='Exact original paths for all files in six request directories, plus their completed control report. '
                          'External compiler/runtime/qualification assets remain separately pinned and archived; no targets run.')
    write(manifest_file, manifest)
    with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as zipped:
        for item in files:
            assert shutil.disk_usage(ROOT).free > RESERVE
            zipped.write(ROOT/item['path'], arcname=item['path'])
        for directory in empty:
            zipped.write(ROOT/directory, arcname=directory+'/')
    with zipfile.ZipFile(archive) as zipped:
        assert len(zipped.infolist()) == len(files)+len(empty)
        assert len(set(zipped.namelist())) == len(zipped.namelist())
        for item in files:
            info = zipped.getinfo(item['path'])
            data = zipped.read(info)
            assert len(data) == item['bytes'] and hashlib.sha256(data).hexdigest() == item['sha256']
            assert stat.S_IMODE(info.external_attr >> 16) == item['mode']
    assert inventory(directories) == (files, empty), 'Request evidence changed while sealing'
    assert pin(CONTROL) == control_pin
    for item in external:
        verify(item)
    after_free = shutil.disk_usage(ROOT).free
    assert after_free > RESERVE
    receipt = dict(kind='phase90-public-cli-request-evidence-capsule', complete=True,
        targetsExecuted=False, controlsPassed=6, successfulRequests=3, expectedRefusals=3,
        finishedCompilerGuards=4, successfulCompilerGuards=3, expectedRejectedCompilerGuards=1,
        preExecutionRefusals=2, cOutputs=7, sourceControl=control_pin, method=pin(__file__),
        manifest=pin(manifest_file), archive=pin(archive), files=len(files), inputBytes=input_bytes,
        allArchiveMembersVerified=True, inputBindingsUnchanged=True, modeBitsVerified=True,
        freeBytesBefore=before_free, freeBytesAfter=after_free, reserveBytes=RESERVE,
        recordedUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        restoration='Verify archive and manifest SHA256, then extract each exact manifest path under the repository root '
                    'only when absent (or already byte-identical); verify every length/SHA256 and restore mode bits. '
                    'Never rename historical paths or rewrite their receipts.',
        scope=manifest['scope'])
    write(receipt_file, receipt)
    write(public, receipt)
    print(json.dumps(dict(receipt=pin(public), capsuleReceipt=pin(receipt_file), archive=pin(archive),
                          files=len(files), inputBytes=input_bytes, targetsExecuted=False)))


if __name__ == '__main__':
    main()
