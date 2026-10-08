#!/usr/bin/env python3
"""Archive closed Phase66 evidence; verify all members and protected predecessors."""
import difflib
import hashlib
import io
import json
import os
import stat
import tarfile
import tempfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase66'
OUT = ROOT / 'selfhost/tools/performance/phase66/artifacts'
TOOLS = Path(__file__).resolve().parent
PART_BYTES = 50 * 1024 * 1024
if not __debug__:
    raise RuntimeError('Archive verification requires Python assertions enabled')


def digest(file):
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def repo_file(value):
    """Confine absolute or repository-relative input paths; reject symlink ancestry."""
    file = Path(value)
    if not file.is_absolute():
        file = ROOT / file
    assert '..' not in file.parts, str(file)
    file.relative_to(ROOT)
    for parent in (file, *file.parents):
        assert not parent.is_symlink(), str(parent)
        if parent == ROOT:
            break
    return file


def identity(file):
    file = repo_file(file)
    assert file.is_file() and not file.is_symlink(), str(file)
    return dict(file=str(file.relative_to(ROOT)), bytes=file.stat().st_size,
                sha256=digest(file))


def read(file):
    return json.loads(file.read_text())


def walk_paths(root):
    """Do not silently omit unreadable directories, as glob traversal may do."""
    def fail(error):
        raise error
    repo_file(root)
    result = []
    for current, directories, files in os.walk(root, onerror=fail, followlinks=False):
        for name in directories + files:
            result.append(repo_file(Path(current) / name))
    return sorted(result)


def inventory():
    """Keep all regular files and directories, including failed output and empty dirs."""
    result = []
    for file in [RAW, *walk_paths(RAW)]:
        file = repo_file(file)
        mode = stat.S_IMODE(file.stat().st_mode)
        if file.is_file():
            result.append(dict(**identity(file), type='file', mode=mode))
        else:
            assert file.is_dir(), 'Unexpected non-regular raw entry: ' + str(file)
            result.append(dict(file=str(file.relative_to(ROOT)), type='directory', mode=mode))
    return result


def preserved():
    inherited = read(RAW / 'inherited-before.json')['files']
    prior = read(RAW / 'installed-before.json')
    assert len(inherited) == 110 and prior['pass'] and len(prior['files']) == 7
    rows = []
    for expected in inherited:
        file = ROOT / expected['file']
        observed = identity(file)
        assert observed['sha256'] == expected['sha256'], str(file)
        rows.append(observed)
    assert len({r['file'] for r in rows}) == 110
    previous = []
    for expected in prior['files']:
        relative = repo_file(expected['file']).relative_to(ROOT / 'selfhost/dist')
        file = RAW / 'previous-installed' / relative
        observed = identity(file)
        assert observed['sha256'] == expected['sha256'], str(file)
        assert observed['bytes'] == expected['bytes'], str(file)
        previous.append(observed)
    assert len({r['file'] for r in previous}) == 7
    actual = [identity(p) for p in walk_paths(RAW / 'previous-installed')
              if p.is_file()]
    assert sorted(actual, key=lambda x: x['file']) == sorted(previous, key=lambda x: x['file'])
    baseline = read(RAW / 'baseline-source.json')
    assert baseline['complete'] is True and len(baseline['files']) == 299
    original_copies = []
    for row in baseline['files']:
        expected = row['copy']
        file = repo_file(expected['file'])
        file.relative_to(RAW / 'baseline-source')
        observed = identity(file)
        assert observed == expected and row['original']['sha256'] == expected['sha256']
        assert row['original']['bytes'] == expected['bytes']
        original_copies.append(observed)
    actual = [identity(p) for p in walk_paths(RAW / 'baseline-source') if p.is_file()]
    assert len({r['file'] for r in original_copies}) == 299
    assert sorted(actual, key=lambda x: x['file']) == sorted(original_copies, key=lambda x: x['file'])
    return dict(inherited=rows, previousInstalled=previous, baselineSource=original_copies)


class Parts(io.RawIOBase):
    """Read the exact ordered publication bytes without a joined repo file."""
    def __init__(self, files):
        super().__init__()
        self.files = iter(files)
        self.current = None

    def readable(self):
        return True

    def readinto(self, buffer):
        view = memoryview(buffer)
        used = 0
        while used < len(view):
            if self.current is None:
                file = next(self.files, None)
                if file is None:
                    break
                self.current = file.open('rb')
            count = self.current.readinto(view[used:])
            if count:
                used += count
            else:
                self.current.close()
                self.current = None
        return used

    def close(self):
        if self.current is not None:
            self.current.close()
        super().close()


def publish_archive(before):
    # The temporary complete stream stays outside the repository. Published
    # files never exceed 50 MiB, including campaigns above GitHub's file limit.
    with tempfile.TemporaryFile(mode='w+b') as temporary:
        with tarfile.open(fileobj=temporary, mode='w:gz', compresslevel=6, dereference=True) as tar:
            for item in before:
                tar.add(ROOT / item['file'], arcname=item['file'], recursive=False)
        total = temporary.tell()
        count = (total + PART_BYTES - 1) // PART_BYTES
        assert count > 0
        temporary.seek(0)
        parts = []
        combined = hashlib.sha256()
        for index in range(count):
            name = 'raw-campaign.tar.gz' + (f'.part{index + 1:03d}' if count > 1 else '')
            file = OUT / name
            remaining = min(PART_BYTES, total - index * PART_BYTES)
            with file.open('xb') as stream:
                while remaining:
                    block = temporary.read(min(1048576, remaining))
                    assert block, 'Unexpected temporary archive truncation'
                    stream.write(block)
                    combined.update(block)
                    remaining -= len(block)
            parts.append(identity(file))
        assert temporary.read(1) == b''
    archive = dict(format='gzip-tar', file=parts[0]['file'] if count == 1 else None,
                   bytes=total, sha256=combined.hexdigest(), split=count > 1,
                   maxPartBytes=PART_BYTES, parts=parts)
    verify_archive(archive, before, OUT)
    return archive


def verify_archive(archive, expected_entries, archive_root):
    """Read-only verifier; accepts Phase65 files-only inventories as predecessors."""
    parts = archive.get('parts') or [archive]
    assert parts and len({p['file'] for p in parts}) == len(parts)
    paths = [repo_file(p['file']) for p in parts]
    for file, expected in zip(paths, parts):
        file.relative_to(archive_root)
        assert identity(file) == {k: expected[k] for k in ('file', 'bytes', 'sha256')}
        assert 0 < expected['bytes'] <= archive.get('maxPartBytes', expected['bytes'])
    reopened = hashlib.sha256()
    total = 0
    with Parts(paths) as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            reopened.update(block)
            total += len(block)
    assert total == archive['bytes'] and total == sum(p['bytes'] for p in parts)
    assert reopened.hexdigest() == archive['sha256'], 'Published archive stream differs'
    assert len({e['file'] for e in expected_entries}) == len(expected_entries)
    with Parts(paths) as stream, tarfile.open(fileobj=stream, mode='r|gz') as tar:
        observed = 0
        for member in tar:
            assert observed < len(expected_entries), 'Unexpected archive member'
            expected = expected_entries[observed]
            assert member.name == expected['file']
            repo_file(member.name)
            if expected.get('type', 'file') == 'directory':
                assert member.isdir() and member.size == 0
            else:
                assert member.isfile() and member.size == expected['bytes']
                h = hashlib.sha256()
                with tar.extractfile(member) as entry:
                    for block in iter(lambda: entry.read(1048576), b''):
                        h.update(block)
                assert h.hexdigest() == expected['sha256'], member.name
            if 'mode' in expected:
                assert member.mode == expected['mode'], member.name
            observed += 1
        assert observed == len(expected_entries), 'Missing archive member'
    assert [identity(p) for p in paths] == [
        {k: p[k] for k in ('file', 'bytes', 'sha256')} for p in parts
    ], 'Published archive part changed'
    return dict(parts=len(parts), bytes=total, entries=observed, allContentsReopened=True)


def main():
    closure_file = RAW / 'writers-closed.json'
    assert closure_file.is_file(), 'Close all raw writers before archival'
    closure = read(closure_file)
    assert closure['kind'] == 'phase66-raw-writers-closed' and closure['complete'] is True
    assert closure.get('closed'), 'Record the actual writer-closure timestamp'
    assert closure.get('compilerTargetsClosed') is True
    assert closure.get('installationVerified') is True
    assert closure.get('ownerAcknowledgements') and all(v is True for v in closure['ownerAcknowledgements'].values())
    assert closure['ownerAcknowledgements'].get('root') is True
    assert os.sched_getaffinity(0) == {0}, 'Archive only on reserved data CPU0'
    repo_file(RAW)
    repo_file(OUT)
    assert not OUT.exists(), 'Never replace an existing or failed publication tree'

    derivation_file = TOOLS / 'archive-derivation.json'
    derivation = read(derivation_file)
    parent = ROOT / derivation['parent']['file']
    producer = Path(__file__).resolve()
    assert identity(parent) == derivation['parent']
    assert identity(producer) == derivation['child']
    diff = ''.join(difflib.unified_diff(parent.read_text().splitlines(keepends=True),
                    producer.read_text().splitlines(keepends=True),
                    fromfile=derivation['parent']['file'], tofile=derivation['child']['file']))
    assert diff == derivation['unifiedDiff'], 'Archive successor derivation differs'
    template = TOOLS / 'artifacts-README.template.md'
    control_files = [closure_file, derivation_file, parent, producer, template,
                     RAW / 'inherited-before.json', RAW / 'installed-before.json',
                     RAW / 'baseline-source.json', TOOLS / 'archive-prerequisites.json',
                     TOOLS / 'archive-prerequisites.md']
    prerequisites = read(TOOLS / 'archive-prerequisites.json')
    for expected in prerequisites['inputMetadata']:
        file = repo_file(expected['file'])
        assert identity(file) == expected, 'External prerequisite metadata changed: ' + str(file)
        control_files.append(file)
    for field in ('authorization', 'producer'):
        expected = closure[field]
        file = repo_file(expected['file'])
        assert identity(file) == expected, 'Writer seal provenance changed: ' + field
        control_files.append(file)
    copies = closure.get('copies', [])
    assert any(x['source'] == 'implementation/phase66/evidence/time-account-final.json'
               for x in copies), 'Close the final time account before archival'
    assert len({c['copy'] for c in copies}) == len(copies), 'Duplicate closure copy destinations'
    for copy in copies:
        destination = repo_file(copy['copy'])
        destination.relative_to(RAW)
        for file in (repo_file(copy['source']), destination):
            assert digest(file) == copy['sha256'], str(file)
            assert file.stat().st_size == copy['bytes'], str(file)
            control_files.append(file)
    required_roles = {'compilerQualification', 'releaseQualification', 'timeAccount',
                      'finalSimplicity', 'protectedInputs', 'installedFiles'}
    assert required_roles <= {c.get('role') for c in copies}, 'Missing final closure evidence role'
    controls_before = [identity(p) for p in control_files]
    template_bytes = template.read_bytes()
    assert hashlib.sha256(template_bytes).hexdigest() == identity(template)['sha256']
    preserved_before = preserved()
    before = inventory()
    assert before

    OUT.mkdir(exist_ok=False)
    archive = publish_archive(before)
    assert inventory() == before, 'Input tree changed during publication'
    assert preserved() == preserved_before, 'Protected predecessor changed during publication'
    assert [identity(p) for p in control_files] == controls_before, 'Publication inputs changed'
    report = dict(kind='phase66-reopened-evidence-archive', complete=True,
                  created=datetime.now(timezone.utc).isoformat(), entries=before,
                  files=[e for e in before if e['type'] == 'file'],
                  fileCount=sum(e['type'] == 'file' for e in before), entryCount=len(before),
                  uncompressedBytes=sum(x.get('bytes', 0) for x in before),
                  archive=archive, producer=identity(producer),
                  derivation=identity(derivation_file), template=identity(template),
                  writerClosure=identity(closure_file), protectedPredecessors=preserved_before,
                  inheritedCount=110, previousInstalledCount=7, baselineSourceCount=299,
                  externalPrerequisites=identity(TOOLS / 'archive-prerequisites.json'),
                  controls=controls_before,
                  reopenedAllMembers=True, inputInventoryAndHashesUnchanged=True,
                  protectedPredecessorsUnchanged=True,
                  scope='Closed Phase66 raw evidence, including failed/rejected attempts and the '
                        'seven previous installed artifacts. The 110 inherited protected files '
                        'are verified in place, not duplicated. All 299 baseline source copies are '
                        'checked. Directories and permission modes are preserved. Historical '
                        'capsule/toolchain prerequisites are explicitly listed separately; '
                        'this archive does not claim self-contained toolchain replay.')
    report['pass'] = True
    values = {'FILE_COUNT': str(report['fileCount']),
              'ENTRY_COUNT': str(report['entryCount']),
              'UNCOMPRESSED_BYTES': str(report['uncompressedBytes']),
              'ARCHIVE_BYTES': str(report['archive']['bytes']),
              'ARCHIVE_SHA256': report['archive']['sha256'],
              'PART_COUNT': str(len(archive['parts'])),
              'PART_LINKS': '\n'.join('- [' + Path(p['file']).name + '](' + Path(p['file']).name + ')'
                                      for p in archive['parts'])}
    text = template_bytes.decode()
    for key, value in values.items():
        text = text.replace('{{' + key + '}}', value)
    assert '{{' not in text, 'Unexpanded publication placeholder'
    with (OUT / 'README.md').open('x') as stream:
        stream.write(text)
    assert [identity(p) for p in control_files] == controls_before, 'Controls changed while rendering'
    with (OUT / 'manifest.json').open('x') as stream:
        stream.write(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ['fileCount', 'uncompressedBytes', 'archive']}))


if __name__ == '__main__':
    main()
