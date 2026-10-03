#!/usr/bin/env python3
"""Count two frozen checked snapshots using Phase32's static source-count definitions."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
PARENT = HERE.parent/'phase32/local-complexity.py'


def identity(path):
    path = Path(path).resolve()
    b = path.read_bytes()
    return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


# Definitions copied unchanged from the maintained local-complexity tool.
def stats(b):
    text = b.decode(); lines = text.splitlines()
    return dict(physicalLines=len(lines), nonblankLines=sum(bool(x.strip()) for x in lines),
                bytes=len(b), **{field: len(re.findall(r'^'+word+r'\b', text, re.M))
                                for field, word in [('defs', 'def'), ('laws', 'law'), ('types', 'type')]})


def snapshot(attempt):
    file = attempt/'attempt.json' if attempt.is_dir() else attempt
    receipt = json.loads(file.read_text())
    assert receipt['checked'] and receipt['artifactKind'] == 'derived-b1'
    root = Path(receipt['snapshot']['root'])
    frozen = {Path(r['frozen']['file']).resolve(): r['frozen'] for r in receipt['snapshot']['sources']}
    def checked(path):
        row = identity(path); expected = frozen[Path(path).resolve()]
        assert row['sha256'] == expected['sha256']
        return row
    manifest = root/'src/compiler.json'
    manifest_id = checked(manifest)
    modules = json.loads(manifest.read_text())['modules']
    assert modules and len(modules) == len(set(modules))
    files = []
    for name in modules:
        path = root/name
        assert path.resolve().is_relative_to(root.resolve())
        files.append(dict(name=name, **checked(path), counts=stats(path.read_bytes())))
    counts = {k: sum(r['counts'][k] for r in files) for k in files[0]['counts']}
    counts['modules'] = len(files)
    runtime = Path(receipt['runtime']['file'])
    runtime_id = identity(runtime)
    assert runtime_id['sha256'] == receipt['runtime']['sha256']
    return dict(attempt=identity(file), api=receipt['api']['sha256'], manifest=manifest_id,
                files=files, counts=counts, runtime=dict(**runtime_id, counts=stats(runtime.read_bytes())))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline-attempt', type=Path, required=True)
    p.add_argument('--baseline-api', required=True)
    p.add_argument('--attempt', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True, help='New JSON file')
    a = p.parse_args()
    assert not a.out.exists()
    baseline, candidate = snapshot(a.baseline_attempt), snapshot(a.attempt)
    assert baseline['api'] == a.baseline_api
    result = dict(kind='phase40-static-source-counts', complete=True, parent=identity(PARENT),
                  producer=identity(__file__), baseline=baseline, candidate=candidate,
                  delta={k: candidate['counts'][k]-baseline['counts'][k] for k in baseline['counts']},
                  scope='Manifest Bend physical/nonblank lines and top-level def/law/type declarations; '
                        'runtime separately. Excludes generated compiler/API size and experiment tooling. '
                        'Static checked snapshot identity observations only; no execution or speed claim.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f:
        f.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(baseline=baseline['counts'], candidate=candidate['counts'], delta=result['delta'])))


if __name__ == '__main__':
    main()
