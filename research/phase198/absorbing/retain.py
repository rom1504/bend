"""Seal lightweight receipts and witnesses; the guarded build retains actual products."""
import argparse
import gzip
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BUILD = ROOT / 'selfhost/build/phase198'
RETENTION = ROOT / 'selfhost/build-retention/phase198'


def members(job):
    guard = BUILD / (job + '-guard')
    state = json.loads((guard / 'retention.json').read_bytes())
    assert state['closed'] and state['state'] == 'sealed'
    yield guard / 'process.json'
    yield guard / 'retention.json'
    yield RETENTION / (job + '-close') / 'report.json'
    folder = BUILD / job
    for name in ('report.json', 'controls.json', 'refusal.json', 'result.json', 'stderr'):
        path = folder / name
        if path.exists():
            yield path
    for path in sorted(folder.glob('*.s')):
        yield path
    if state['outcome'] == 'failed':
        yield guard / 'stderr.log'
        yield guard / 'stdout.log'


def main(out, jobs):
    saved = io.BytesIO()
    with tarfile.open(fileobj=saved, mode='w') as archive:
        for job in jobs:
            assert job.startswith('absorb-') and '/' not in job
            for path in members(job):
                content = path.read_bytes()
                assert len(content) <= 4 * 1024 * 1024
                meta = tarfile.TarInfo(str(path.relative_to(ROOT)))
                meta.size = len(content)
                meta.mode = 0o644
                archive.addfile(meta, io.BytesIO(content))
    data = gzip.compress(saved.getvalue(), mtime=0)
    out.write_bytes(data)
    print(out, len(data), len(jobs))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('jobs', nargs='+')
    options = parser.parse_args()
    main(options.out, options.jobs)
