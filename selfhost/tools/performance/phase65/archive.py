#!/usr/bin/env python3
"""Archive closed Phase65 evidence; verify all members and protected predecessors."""
import difflib
import hashlib
import io
import json
import tarfile
import tempfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase65'
OUT = ROOT / 'selfhost/tools/performance/phase65/artifacts'
TOOLS = Path(__file__).resolve().parent
PART_BYTES = 64 * 1024 * 1024


def digest(file):
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def identity(file):
    assert file.is_file() and not file.is_symlink(), str(file)
    return dict(file=str(file.relative_to(ROOT)), bytes=file.stat().st_size,
                sha256=digest(file))


def read(file):
    return json.loads(file.read_text())


def inventory():
    result = []
    for file in sorted(RAW.rglob('*')):
        assert not file.is_symlink(), str(file)
        if file.is_file():
            result.append(identity(file))
        else:
            assert file.is_dir(), 'Unexpected non-regular raw entry: ' + str(file)
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
        relative = Path(expected['file']).relative_to(ROOT / 'selfhost/dist')
        file = RAW / 'previous-installed' / relative
        observed = identity(file)
        assert observed['sha256'] == expected['sha256'], str(file)
        assert observed['bytes'] == expected['bytes'], str(file)
        previous.append(observed)
    assert len({r['file'] for r in previous}) == 7
    actual = [identity(p) for p in sorted((RAW / 'previous-installed').rglob('*'))
              if p.is_file()]
    assert sorted(actual, key=lambda x: x['file']) == sorted(previous, key=lambda x: x['file'])
    return dict(inherited=rows, previousInstalled=previous)


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
    # files never exceed 64 MiB, including campaigns above GitHub's file limit.
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
    paths = [ROOT / p['file'] for p in parts]
    reopened = hashlib.sha256()
    with Parts(paths) as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            reopened.update(block)
    assert reopened.hexdigest() == combined.hexdigest(), 'Published archive stream differs'
    with Parts(paths) as stream, tarfile.open(fileobj=stream, mode='r|gz') as tar:
        observed = 0
        for member in tar:
            assert observed < len(before), 'Unexpected archive member'
            expected = before[observed]
            assert member.name == expected['file']
            assert member.isfile() and member.size == expected['bytes']
            h = hashlib.sha256()
            with tar.extractfile(member) as entry:
                for block in iter(lambda: entry.read(1048576), b''):
                    h.update(block)
            assert h.hexdigest() == expected['sha256'], member.name
            observed += 1
        assert observed == len(before), 'Missing archive member'
    assert [identity(p) for p in paths] == parts, 'Published archive part changed'
    return dict(format='gzip-tar', file=parts[0]['file'] if count == 1 else None,
                bytes=total, sha256=combined.hexdigest(), split=count > 1,
                maxPartBytes=PART_BYTES, parts=parts)


def main():
    closure_file = RAW / 'writers-closed.json'
    assert closure_file.is_file(), 'Close all raw writers before archival'
    closure = read(closure_file)
    assert closure['kind'] == 'phase65-raw-writers-closed' and closure['complete'] is True
    assert closure.get('closed'), 'Record the actual writer-closure timestamp'
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
                     RAW / 'inherited-before.json', RAW / 'installed-before.json']
    copies = closure.get('copies', [])
    assert any(x['source'] == 'implementation/phase65/evidence/time-account-final.json'
               for x in copies), 'Close the final time account before archival'
    for copy in copies:
        destination = ROOT / copy['copy']
        destination.relative_to(RAW)
        for file in (ROOT / copy['source'], destination):
            assert digest(file) == copy['sha256'], str(file)
            control_files.append(file)
    controls_before = [identity(p) for p in control_files]
    preserved_before = preserved()
    before = inventory()
    assert before

    OUT.mkdir(exist_ok=False)
    archive = publish_archive(before)
    assert inventory() == before, 'Input tree changed during publication'
    assert preserved() == preserved_before, 'Protected predecessor changed during publication'
    assert [identity(p) for p in control_files] == controls_before, 'Publication inputs changed'
    report = dict(kind='phase65-reopened-evidence-archive', complete=True,
                  created=datetime.now(timezone.utc).isoformat(), files=before,
                  fileCount=len(before), uncompressedBytes=sum(x['bytes'] for x in before),
                  archive=archive, producer=identity(producer),
                  derivation=identity(derivation_file), template=identity(template),
                  writerClosure=identity(closure_file), protectedPredecessors=preserved_before,
                  inheritedCount=110, previousInstalledCount=7,
                  reopenedAllMembers=True, inputInventoryAndHashesUnchanged=True,
                  protectedPredecessorsUnchanged=True,
                  scope='Closed Phase65 raw evidence, including failed/rejected attempts and the '
                        'seven previous installed artifacts. The 110 inherited protected files '
                        'are verified in place, not duplicated. Historical Phase58-64 raw '
                        'prerequisites remain in their existing published capsules.')
    report['pass'] = True
    values = {'FILE_COUNT': str(report['fileCount']),
              'UNCOMPRESSED_BYTES': str(report['uncompressedBytes']),
              'ARCHIVE_BYTES': str(report['archive']['bytes']),
              'ARCHIVE_SHA256': report['archive']['sha256'],
              'PART_COUNT': str(len(archive['parts'])),
              'PART_LINKS': '\n'.join('- [' + Path(p['file']).name + '](' + Path(p['file']).name + ')'
                                      for p in archive['parts'])}
    text = template.read_text()
    for key, value in values.items():
        text = text.replace('{{' + key + '}}', value)
    assert '{{' not in text, 'Unexpanded publication placeholder'
    with (OUT / 'README.md').open('x') as stream:
        stream.write(text)
    with (OUT / 'manifest.json').open('x') as stream:
        stream.write(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ['fileCount', 'uncompressedBytes', 'archive']}))


if __name__ == '__main__':
    main()
