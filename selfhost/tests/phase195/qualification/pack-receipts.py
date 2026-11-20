"""Save the fresh qualification receipts and short raw oracle streams verbatim."""
import gzip
import hashlib
import io
import json
from pathlib import Path
import shutil
import tarfile


ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase195'
OUTPUT = ROOT / 'implementation/phase195/qualification-evidence'
PREFIXES = ('native', 'runtime10', 'broad-', 'remainder-', 'compiler-cost-',
            'selected-source', 'maintained-promotion-plan', 'hosted-native-compare')
NAMES = {'report.json', 'comparison.json', 'process.json', 'retention.json',
         'changed-files.json', 'independent-output.json', 'manifest.json',
         'programs.manifest.json', 'request.json', 'recipe.json', 'stdout', 'stderr',
         'runtime-calibration.py', 'profile-map-audit.json', 'seven-root-manifest.json'}


def capture():
    files = []
    for top in sorted(BUILD.iterdir()):
        if not top.name.startswith(PREFIXES) and top.name != 'runtime-calibration.py':
            continue
        if top.is_dir() and top.name.endswith('-guard'):
            process = json.loads((top / 'process.json').read_text())
            assert process['finished'] and process['returncode'] is not None, top
        for path in sorted(top.rglob('*')) if top.is_dir() else [top]:
            if not path.is_file() or path.is_symlink():
                continue
            if (path.parent == BUILD and path.suffix == '.json') or path.name in NAMES or path.suffix == '.stderr':
                size = path.stat().st_size
                with path.open('rb') as stream:
                    if stream.read(4) == b'\x7fELF':
                        continue
                assert size <= 16 * 1024**2, path
                files.append(path)
    assert shutil.disk_usage(ROOT).free > 5 * 1024**3 + sum(p.stat().st_size for p in files)
    OUTPUT.mkdir(exist_ok=False)
    archive = OUTPUT / 'receipts.tar.gz'
    hashes = {}
    with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, filename='', mode='wb', mtime=0) as gz, tarfile.open(fileobj=gz, mode='w|') as tar:
        for path in files:
            data = path.read_bytes()
            key = str(path.relative_to(ROOT))
            hashes[key] = hashlib.sha256(data).hexdigest()
            member = tarfile.TarInfo(key)
            member.size = len(data)
            tar.addfile(member, io.BytesIO(data))
    with tarfile.open(archive) as tar:
        verified = {m.name: hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar}
    assert verified == hashes
    receipt = dict(members=len(files), sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),
                   bytes=archive.stat().st_size, verified=True,
                   scope='Build metadata and oracle streams. Compiler images, object files and generated source excluded.')
    (OUTPUT / 'verification.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    capture()
