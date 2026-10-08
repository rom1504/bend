# Closed Phase66 evidence capsule

All raw writers were closed before publication. The producer verified every
published archive member's path, type, mode, size and SHA256, then rechecked the entire
original tree, its 110 inherited protected files and seven preserved previous
installed artifacts, plus all 299 frozen baseline-source copies. Failed, rejected and interrupted attempts retain their
original statuses. The [manifest](manifest.json) binds these checks.

- Regular files: **119393**; files plus directories: **141442**.
- Uncompressed content: **1159498010 bytes**.
- Complete gzip-tar stream: **241587423 bytes**.
- Stream SHA256: `8fac8f978921e4e932e40f714a75ade5058f4a4cc2200b8bded16c6cb76c90ec`.
- Ordered parts: **5**, each at most **50 MiB**.
- Source: `selfhost/build/phase66`; producer: [`../archive-v2.py`](../archive-v2.py).

- [raw-campaign.tar.gz.part001](raw-campaign.tar.gz.part001)
- [raw-campaign.tar.gz.part002](raw-campaign.tar.gz.part002)
- [raw-campaign.tar.gz.part003](raw-campaign.tar.gz.part003)
- [raw-campaign.tar.gz.part004](raw-campaign.tar.gz.part004)
- [raw-campaign.tar.gz.part005](raw-campaign.tar.gz.part005)

The [derivation receipt](../archive-v2.derivation.json) binds the exact Phase65
predecessor, Phase66 producer and textual changes. Files and directories each
appear once in the manifest; their component-sorted union is the exact archive order. Parts form one gzip stream;
do not extract individual parts. The manifest records both each part's hash and
the concatenated stream's hash. No large joined archive needs to be tracked.

From the repository root, the following standard-library Python command
verifies the parts, complete stream and every member before restoring into an
**absent** raw tree. It joins the compressed stream in temporary storage, outside
the repository. Allow space for that stream plus the restored raw files.

```sh
python3 - <<'PYRESTORE'
import hashlib, json, os, shutil, stat, tarfile, tempfile
from pathlib import Path, PurePosixPath
if not __debug__: raise RuntimeError('Restore verification requires assertions enabled')
os.umask(0o077)  # Private, readable staging before saved modes are applied.
root = Path.cwd().resolve()
raw = root / 'selfhost/build/phase66'
def confined(value, prefix):
    name = PurePosixPath(value)
    assert not name.is_absolute() and '..' not in name.parts
    assert name.parts[:len(prefix)] == prefix
    target = root / name
    for path in (target, *target.parents):
        assert not path.is_symlink(), str(path)
        if path == root: break
    return target
confined('selfhost/build/phase66', ('selfhost', 'build', 'phase66'))
assert not raw.exists(), 'Restore into an isolated checkout; never overwrite a campaign'
manifest = json.loads((root / 'selfhost/tools/performance/phase66/artifacts/manifest.json').read_text())
assert manifest['complete'] and manifest['pass'] and manifest['reopenedAllMembers']
archive = manifest['archive']; parts = archive['parts']
expected = sorted(manifest['files'] + manifest['directories'],
                  key=lambda entry: PurePosixPath(entry['file']).parts)
assert parts and len({p['file'] for p in parts}) == len(parts)
assert archive['maxPartBytes'] == 50 * 1024 * 1024
with tempfile.TemporaryFile(mode='w+b') as joined:
    whole = hashlib.sha256()
    for part in parts:
        source = confined(part['file'], ('selfhost', 'tools', 'performance', 'phase66', 'artifacts'))
        assert source.is_file() and 0 < part['bytes'] <= archive['maxPartBytes']
        h = hashlib.sha256(); size = 0
        with source.open('rb') as stream:
            for block in iter(lambda: stream.read(1048576), b''):
                h.update(block); whole.update(block); joined.write(block); size += len(block)
        assert size == part['bytes'] and h.hexdigest() == part['sha256']
    assert joined.tell() == archive['bytes'] == sum(p['bytes'] for p in parts)
    assert whole.hexdigest() == archive['sha256']
    joined.seek(0)
    with tarfile.open(fileobj=joined, mode='r:gz') as tar:
        members = tar.getmembers()
        assert [m.name for m in members] == [e['file'] for e in expected]
        assert len({m.name for m in members}) == len(members) == manifest['entryCount']
        for member, entry in zip(members, expected):
            confined(member.name, ('selfhost', 'build', 'phase66'))
            assert member.mode == entry['mode']
            if entry['type'] == 'directory':
                assert member.isdir() and member.size == 0
            else:
                assert entry['type'] == 'file' and member.isfile() and member.size == entry['bytes']
                h = hashlib.sha256()
                with tar.extractfile(member) as stream:
                    for block in iter(lambda: stream.read(1048576), b''): h.update(block)
                assert h.hexdigest() == entry['sha256'], member.name
        # No output is created until every compressed byte/member is verified.
        for member, entry in zip(members, expected):
            target = confined(member.name, ('selfhost', 'build', 'phase66'))
            if entry['type'] == 'directory':
                target.mkdir(parents=True, exist_ok=False)
            else:
                with tar.extractfile(member) as source, target.open('xb') as destination:
                    shutil.copyfileobj(source, destination)
    def fail(error): raise error
    walked = []
    for current, directories, files in os.walk(raw, onerror=fail, followlinks=False):
        walked.extend(Path(current) / name for name in directories + files)
    actual = [raw, *sorted(walked)]
    assert [str(p.relative_to(root)) for p in actual] == [e['file'] for e in expected]
    for target, entry in zip(actual, expected):
        confined(entry['file'], ('selfhost', 'build', 'phase66'))
        if entry['type'] == 'directory':
            assert target.is_dir()
        else:
            assert target.is_file() and target.stat().st_size == entry['bytes']
            h = hashlib.sha256()
            with target.open('rb') as stream:
                for block in iter(lambda: stream.read(1048576), b''): h.update(block)
            assert h.hexdigest() == entry['sha256'], entry['file']
    # Verify all restored bytes while directories/files remain accessible.
    # Then set each saved mode and verify immediately, before any ancestor
    # receives a potentially restrictive mode.
    for entry in expected:
        if entry['type'] == 'file':
            target = root / entry['file']; target.chmod(entry['mode'])
            assert stat.S_IMODE(target.stat().st_mode) == entry['mode']
    for entry in reversed(expected):
        if entry['type'] == 'directory':
            target = root / entry['file']; target.chmod(entry['mode'])
            assert stat.S_IMODE(target.stat().st_mode) == entry['mode']
print('Restored and verified', manifest['fileCount'], 'Phase66 files and all directories/modes')
PYRESTORE
```

Members retain the complete `selfhost/build/phase66/` prefix. Do not strip it or
restore inside that directory. The restored previous release is under
`previous-installed/`, with exact hashes and bytes checked against
`installed-before.json`; restoration does not replace `selfhost/dist/`.
The 110 inherited files were verified in place and are not duplicated here.

The [external prerequisite inventory](../archive-prerequisites.json) and
[restoration notes](../archive-prerequisites.md) identify the exact Phase65,
Phase63, Phase58, Phase55, Phase45 and Phase22 capsule metadata used by this
campaign. Some historical archives are ordered gzip chunks; Phase22 uses
independent XZ archives. Their original formats and earlier recovery receipts
remain unchanged. The 110 inherited protected files are verified in place,
not duplicated; deleted old provider sources survive in the 299 baseline copies.

Node 24.18.0, both pinned upstream checkouts, Clang16 and its shared libraries,
headers and link libraries are external toolchain prerequisites. Bun1.4.2 is
captured under `bun-toolchain01/`, including official release metadata, verified
zip and executable; its saved executable mode is preserved. Runtime/FFI
qualification remains separate from acquisition and archive integrity.
Original absolute paths in recipes need explicit rebinding and fresh output
roots on another machine. This capsule preserves raw evidence, including
malformed/partial JSON and `.active` markers; it is not a self-contained build
image or proof that every historical command succeeded.

Directory names and permission modes are preserved. Ownership, timestamps,
extended attributes and hardlink identity are outside the restoration contract;
regular hardlinked source paths are stored as independent complete files. Symlinks
and other special raw entries cause publication to fail instead of being omitted.
Selected compact evidence is tracked in
[`implementation/phase66/evidence/`](../../../../../implementation/phase66/evidence/).
Read the [phase report](../../../../../implementation/phase66/README.md) for
qualification, five-metric boundaries and experiment decisions.

Writer closure, time accounting, compiler qualification and archive integrity
are separate records. Final receipt copies and writer closure were completed
before the raw inventory; this README and publication metadata are outside the
closed raw tree. No writer may resume inside that historical tree.
