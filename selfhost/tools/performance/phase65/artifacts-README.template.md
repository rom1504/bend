# Closed Phase65 evidence capsule

All raw writers were closed before publication. The producer verified every
published archive member's path, size and SHA256, then rechecked the entire
original tree, its 110 inherited protected files and seven preserved previous
installed artifacts. Failed, rejected and interrupted attempts retain their
original statuses. The [manifest](manifest.json) binds these checks.

- Files: **{{FILE_COUNT}}**.
- Uncompressed content: **{{UNCOMPRESSED_BYTES}} bytes**.
- Complete gzip-tar stream: **{{ARCHIVE_BYTES}} bytes**.
- Stream SHA256: `{{ARCHIVE_SHA256}}`.
- Ordered parts: **{{PART_COUNT}}**, each at most **64 MiB**.
- Source: `selfhost/build/phase65`; producer: [`../archive.py`](../archive.py).

{{PART_LINKS}}

The [derivation receipt](../archive-derivation.json) binds the exact Phase64
predecessor, Phase65 producer and textual changes. Parts form one gzip stream;
do not extract individual parts. The manifest records both each part's hash and
the concatenated stream's hash. No large joined archive needs to be tracked.

From the repository root, the following standard-library Python command
verifies the parts, complete stream and every member before restoring into an
**absent** raw tree. It joins the compressed stream in temporary storage, outside
the repository. Allow space for that stream plus the restored raw files.

```sh
python3 - <<'PYRESTORE'
import hashlib, json, shutil, tarfile, tempfile
from pathlib import Path, PurePosixPath
root = Path.cwd()
raw = root / 'selfhost/build/phase65'
assert not raw.exists() and not raw.is_symlink(), 'Restore into an isolated checkout; never overwrite a campaign'
manifest = json.loads((root / 'selfhost/tools/performance/phase65/artifacts/manifest.json').read_text())
assert manifest['complete'] and manifest['pass'] and manifest['reopenedAllMembers']
with tempfile.TemporaryFile(mode='w+b') as joined:
    whole = hashlib.sha256()
    for part in manifest['archive']['parts']:
        source = PurePosixPath(part['file'])
        assert source.parts[:5] == ('selfhost', 'tools', 'performance', 'phase65', 'artifacts')
        assert '..' not in source.parts
        h = hashlib.sha256()
        size = 0
        with (root / source).open('rb') as stream:
            for block in iter(lambda: stream.read(1048576), b''):
                h.update(block); whole.update(block); joined.write(block); size += len(block)
        assert size == part['bytes'] and h.hexdigest() == part['sha256']
    assert joined.tell() == manifest['archive']['bytes']
    assert whole.hexdigest() == manifest['archive']['sha256']
    joined.seek(0)
    with tarfile.open(fileobj=joined, mode='r:gz') as tar:
        members = tar.getmembers()
        expected = manifest['files']
        assert [m.name for m in members] == [e['file'] for e in expected]
        assert len({m.name for m in members}) == len(members)
        for member, entry in zip(members, expected):
            name = PurePosixPath(member.name)
            assert name.parts[:3] == ('selfhost', 'build', 'phase65') and '..' not in name.parts
            assert member.isfile() and member.size == entry['bytes']
            h = hashlib.sha256()
            with tar.extractfile(member) as stream:
                for block in iter(lambda: stream.read(1048576), b''): h.update(block)
            assert h.hexdigest() == entry['sha256'], member.name
        for member in members:
            target = root / member.name
            target.parent.mkdir(parents=True, exist_ok=True)
            with tar.extractfile(member) as source, target.open('xb') as destination:
                shutil.copyfileobj(source, destination)
            target.chmod(member.mode & 0o777)
    for entry in expected:
        target = root / entry['file']
        assert target.stat().st_size == entry['bytes']
        h = hashlib.sha256()
        with target.open('rb') as stream:
            for block in iter(lambda: stream.read(1048576), b''): h.update(block)
        assert h.hexdigest() == entry['sha256'], entry['file']
print('Restored and verified', len(members), 'Phase65 files')
PYRESTORE
```

Members retain the complete `selfhost/build/phase65/` prefix. Do not strip it or
restore inside that directory. The restored previous release is under
`previous-installed/`, with exact hashes and bytes checked against
`installed-before.json`; restoration does not replace `selfhost/dist/`.
The 110 inherited files were verified in place and are not duplicated here.

Historical prerequisites remain in the existing Phase58–64 capsules and their
linked earlier evidence. Retain the pinned upstream, Node, Base and helper
identities. Old recipes contain original absolute workspace paths; a new
workspace needs explicit fresh bindings and output directories. This capsule
preserves evidence, without promising that external tools or paths already
exist on another machine. Selected compact evidence is also tracked in
[`implementation/phase65/evidence/`](../../../../../implementation/phase65/evidence/).
Read the [phase report](../../../../../implementation/phase65/README.md) for
qualification, compiler-speed boundaries and experiment decisions.

Writer closure, time accounting, compiler qualification and archive integrity
are separate records. Final receipt copies and writer closure were completed
before the raw inventory; this README and publication metadata are outside the
closed raw tree. No writer may resume inside that historical tree.
