#!/usr/bin/env python3
"""Seal exact Phase154 evidence, deduplicating identical payloads; no pruning."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'implementation/phase154/evidence'


def main():
    OUT.mkdir(exist_ok=True)
    archive = OUT / 'phase154.tar.gz'
    if archive.exists():
        raise SystemExit('refusing to overwrite evidence')
    files = []
    for name in ('selfhost/build/phase154', 'experiments/phase154', 'selfhost/tests/phase154'):
        files.extend(p for p in (ROOT / name).rglob('*') if p.is_file())
    files.extend([ROOT / 'selfhost/build/phase147/profile-build02/runtime/sampler.so',
                  ROOT / 'selfhost/build/phase152/native-n2/report.json',
                  ROOT / 'selfhost/build/phase152/composite-api01/report.json',
                  ROOT / 'implementation/phase154/metrics.json',
                  ROOT / 'implementation/phase154/cost.json',
                  ROOT / 'implementation/phase154/retention.json'])
    for p in (ROOT / 'selfhost/build-retention/phase154').rglob('*.json'):
        files.append(p)
    payloads, aliases, known = [], [], {}
    with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', mtime=0, compresslevel=6) as gz:
        with tarfile.open(fileobj=gz, mode='w|') as tar:
            for p in sorted(set(files)):
                if p.is_symlink():
                    raise SystemExit(f'symlink refused: {p}')
                data = p.read_bytes()
                digest = hashlib.sha256(data).hexdigest()
                record = dict(file=str(p.relative_to(ROOT)), bytes=len(data), sha256=digest,
                              mode=p.stat().st_mode & 0o777)
                key = (digest, len(data), record['mode'])
                if key in known:
                    aliases.append(dict(record, payload=known[key]))
                    continue
                known[key] = record['file']
                entry = tarfile.TarInfo(record['file'])
                entry.mode, entry.size = record['mode'], len(data)
                tar.addfile(entry, io.BytesIO(data))
                payloads.append(record)
    expected = {r['file']: r for r in payloads}
    with tarfile.open(archive, 'r:gz') as tar:
        for member in tar:
            data = tar.extractfile(member).read()
            record = expected.pop(member.name)
            assert len(data) == record['bytes']
            assert hashlib.sha256(data).hexdigest() == record['sha256']
            assert member.mode == record['mode']
    assert not expected
    data = archive.read_bytes()
    result = dict(kind='phase154-evidence-capsule', payloads=payloads, aliases=aliases,
                  archive=dict(file=str(archive.relative_to(ROOT)), bytes=len(data),
                               sha256=hashlib.sha256(data).hexdigest()), verified=True,
                  scope='Exact phase inputs/products/profiles/methods/receipts. External compiler/toolchain assets remain required.')
    (OUT / 'capsule.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(archive=result['archive'], payloads=len(payloads), aliases=len(aliases))))


if __name__ == '__main__':
    main()
