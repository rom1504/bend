#!/usr/bin/env python3
"""Copy a frozen checked snapshot plus explicit file overlays; never build."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase48'


def identity(file):
    file = file.resolve(strict=True)
    return dict(file=str(file), bytes=file.stat().st_size,
                sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline-attempt', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--config', type=Path, required=True)
    p.add_argument('--overlay', action='append', default=[], metavar='RELATIVE_TARGET=SOURCE_FILE')
    a = p.parse_args()
    attempt = a.baseline_attempt.resolve(strict=True) / 'attempt.json'
    manifest = json.loads(attempt.read_text())
    assert manifest['checked'] and manifest['config']['strictExact']
    snapshot = Path(manifest['snapshot']['root']).resolve(strict=True)
    out, config = a.out.resolve(), a.config.resolve()
    assert out.is_relative_to(RAW) and config.is_relative_to(RAW)
    assert not out.exists() and not config.exists() and not config.is_relative_to(out)
    pins = [identity(Path(__file__)), identity(attempt)]
    for key in ['api', 'runtime']:
        row = identity(Path(manifest[key]['file']))
        assert row['sha256'] == manifest[key]['sha256']
        pins.append(row)
    for source in manifest['snapshot']['sources']:
        frozen = source['frozen']
        file = Path(frozen['file']).resolve(strict=True)
        assert file.is_relative_to(snapshot)
        assert file.relative_to(snapshot).parts[0] in ['src', 'tools', 'tests']
        row = identity(file)
        assert row['sha256'] == frozen['sha256'], file
        assert str(file) == frozen.get('canonicalPath', str(file)), file
        pins.append(row)
    overlays = []
    for item in a.overlay:
        name, source = item.split('=', 1)
        target = Path(name)
        assert not target.is_absolute() and '..' not in target.parts
        assert target.parts and target.parts[0] in ['src', 'tools', 'tests']
        source = Path(source)
        assert source.is_file() and not source.is_symlink()
        row = identity(source)
        pins.append(row)
        overlays.append(dict(target=target.as_posix(), source=row))
    assert len({r['target'] for r in overlays}) == len(overlays), 'Duplicate overlay target'
    for directory in ['src', 'tools', 'tests']:
        for file in sorted((snapshot / directory).rglob('*')):
            assert not file.is_symlink(), file
            if file.is_file():
                pins.append(identity(file))
    out.mkdir(parents=True)
    for directory in ['src', 'tools', 'tests']:
        shutil.copytree(snapshot / directory, out / directory)
    for row in pins:
        original = Path(row['file'])
        if original.is_relative_to(snapshot):
            assert identity(out / original.relative_to(snapshot))['sha256'] == row['sha256']
    for row in overlays:
        target = out / row['target']
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(row['source']['file'], target)
        assert identity(target)['sha256'] == row['source']['sha256']
    for row in pins:
        assert identity(Path(row['file'])) == row, row['file']
    cfg = dict(project=str(out), upstream=manifest['config']['upstream'], profile='equality',
               fullFrontend=False, strictExact=True, jobs=1, cpu='3', heapMb=1024, recycleAfter=64)
    config.parent.mkdir(parents=True, exist_ok=True)
    with config.open('x') as stream:
        json.dump(cfg, stream, indent=2); stream.write('\n')
    receipt = dict(kind='phase48-explicit-candidate-snapshot', complete=True, targetExecuted=False,
        inputs=pins, overlays=overlays, config=identity(config), baselineAttempt=identity(attempt),
        copiedTrees=['src', 'tools', 'tests'],
        scope='Only frozen snapshot trees plus listed individual files. New module order must be supplied explicitly through a src/compiler.json overlay; no live-directory sweep.')
    with (out / 'snapshot-receipt.json').open('x') as stream:
        json.dump(receipt, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, targetExecuted=False, project=str(out), config=str(config))))


if __name__ == '__main__':
    main()
