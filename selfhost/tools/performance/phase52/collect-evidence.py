#!/usr/bin/env python3
"""Copy a bounded, verbatim Phase52 review packet after raw writers close.

No compiler, program, compression or extraction runs here. Reuse freeze-candidate.py
and freeze-baseline.py for runnable bundles, then the existing Phase42 streamed
archive-campaign-v1.py for the complete closed raw capsule. This packet is not
that capsule and does not independently qualify or install the selected image.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
RAW = REPO / 'selfhost/build/phase52'
MAX_FILE = 8 * 1024**2
MAX_TOTAL = 128 * 1024**2
MAX_FILES = 25000
SUFFIXES = {'.json', '.jsonl', '.md', '.log', '.stdout', '.stderr'}


def identity(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024**2), b''):
            h.update(chunk)
    return dict(file=str(file), bytes=file.stat().st_size, sha256=h.hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--attempt', type=Path, required=True)
    p.add_argument('--writers-closed', type=Path, required=True)
    p.add_argument('--protected-final', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(HERE/'evidence') and not out.exists()
    assert out != HERE/'evidence/prototype', 'Preserve the existing prototype packet'
    inputs, copies, large, requested = {}, [], [], {}

    def pin(file, expected=None):
        item = identity(file)
        if expected:
            assert item['sha256'] == expected['sha256'], file
            assert 'bytes' not in expected or item['bytes'] == expected['bytes'], file
        assert item['file'] not in inputs or inputs[item['file']] == item, file
        inputs[item['file']] = item
        return item

    def pointer(row):
        return pin(row.get('canonicalPath', row.get('file', row.get('path'))), row)

    def read(file):
        pin(file)
        return json.loads(Path(file).read_text())

    def add(name, file):
        file = Path(file)
        assert not file.is_symlink() and file.is_file(), file
        assert name and not Path(name).is_absolute() and '..' not in Path(name).parts
        assert name not in requested or requested[name] == file
        requested[name] = file

    attempt_file = a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt_file = attempt_file.resolve(strict=True)
    assert attempt_file.is_relative_to(RAW)
    attempt = read(attempt_file)
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    closed, protected = read(a.writers_closed), read(a.protected_final)
    assert closed['complete'] and closed['writersClosed'] and Path(closed['rawRoot']).resolve() == RAW
    assert pointer(closed['attempt']) == pin(attempt_file)
    assert pointer(closed['api']) == pointer(attempt['api'])
    assert protected['complete'] and protected['checked'] == 103 and protected['changed'] == []
    assert protected.get('protectedStaged', []) == []
    pointer(protected['start'])
    add('writers-closed.json', a.writers_closed)
    add('protected-final.json', a.protected_final)

    # Do not interpret failed reports as pass/fail qualification. Preserve their
    # exact bytes, command/resource receipts and observations alongside successes.
    for file in sorted(RAW.rglob('*')):
        assert not file.is_symlink(), file
        if not file.is_file():
            continue
        rel = file.relative_to(RAW)
        if 'snapshot' in rel.parts or file.name.endswith('.map.json'):
            continue
        if file.suffix in SUFFIXES or file.name.startswith('consumed-'):
            add('raw/'+rel.as_posix(), file)
    for file in sorted(HERE.rglob('*')):
        rel = file.relative_to(HERE)
        if rel.parts[0] in {'evidence', 'bundles', '__pycache__'}:
            continue
        assert not file.is_symlink(), file
        if file.is_file() and file.suffix in {'.py', '.mjs', '.js', '.c', '.bend', '.json', '.md'}:
            add('methods/'+rel.as_posix(), file)

    # Retain the selected source graph, not every historical snapshot/API image.
    # All other snapshots and raw leaf receipts remain in the full raw capsule.
    snapshot = Path(attempt['snapshot']['root']).resolve(strict=True)
    frozen = {Path(r['frozen']['file']).resolve(): r['frozen'] for r in attempt['snapshot']['sources']}
    manifest_file = snapshot/'src/compiler.json'
    pointer(frozen[manifest_file])
    manifest = read(manifest_file)
    assert manifest['upstream'] == '018751270e800bc222a93dad7f257083ee53a5f7'
    assert len(manifest['modules']) == len(set(manifest['modules']))
    selected = [*manifest['modules'], 'src/compiler.json', 'src/runtime/js/direct.mjs',
                'src/runtime/js/core.mjs', 'src/runtime.mjs', 'tools/typed-driver.mjs']
    # Direct standalone FFI also consumes the vendored provider manifest, exact
    # provider sources and attribution. They are part of the selected source
    # closure, not an implicit dependency on the historical upstream checkout.
    providers = sorted(path.relative_to(snapshot).as_posix() for path in frozen
                       if path.is_relative_to(snapshot/'src/runtime/js/effs'))
    assert 'src/runtime/js/effs/manifest.json' in providers
    selected.extend(providers)
    for relative in selected:
        file = (snapshot/relative).resolve(strict=True)
        assert file.is_relative_to(snapshot)
        pointer(frozen[file])
        add('selected-source/'+relative, file)
    for key in ['api', 'checkedApi', 'runtime', 'base', 'bootstrapReport', 'derivationReport']:
        if key in attempt:
            pointer(attempt[key])

    # Portable publication is a separate reviewed producer. Retain its manifests
    # and archive identities without copying/compressing those archives again.
    bundles = {}
    catalog_file = HERE.parent/'phase37/catalog.json'
    catalog = read(catalog_file)
    expected_ids = {c['id'] for c in catalog['cases']}
    assert len(expected_ids) == 45
    add('methods/primary-catalog.json', catalog_file)
    for role in ['baseline', 'current']:
        file = HERE/'bundles'/role/'manifest.json'
        bundle = read(file)
        assert bundle['complete'] and len(bundle['cases']) == 45
        assert {c['id'] for c in bundle['cases']} == expected_ids
        assert bundle['upstreamCommit'] == catalog['upstreamCommit']
        assert bundle['catalogSha256'] == pin(catalog_file)['sha256']
        if role == 'current':
            compiler = bundle['roles']['candidate']['compiler']
            assert compiler['api']['sha256'] == attempt['api']['sha256']
            assert compiler['directRuntime']['sha256'] == frozen[snapshot/'src/runtime/js/direct.mjs']['sha256']
            assert compiler['backend'] == 'direct' and compiler['callingContract'] == 'upstream-compatible-direct-v1'
        else:
            assert bundle['roles']['baseline']['compiler']['api']['sha256'] == 'c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061'
        archive = bundle['archive']
        path = (file.parent/archive['path']).resolve(strict=True)
        assert path.is_relative_to(file.parent)
        bundles[role] = dict(manifest=pin(file), archive=pin(path, archive))
        add('portable/'+role+'/manifest.json', file)
        if 'provenance' in bundle:
            row = bundle['provenance']; path = (file.parent/row['path']).resolve(strict=True)
            assert path.is_relative_to(file.parent)
            pin(path, row); add('portable/'+role+'/provenance.json', path)

    total = 0
    assert len(requested) <= MAX_FILES
    for name, file in sorted(requested.items()):
        item = pin(file)
        if item['bytes'] > MAX_FILE:
            large.append(dict(original=item, intendedCopy=name, reason='Exceeds compact-file cap; full raw capsule still required'))
            continue
        total += item['bytes']
        assert total <= MAX_TOTAL, 'Compact packet budget exceeded; review scope explicitly'
        copies.append(dict(original=item, copy=name))
    out.mkdir(parents=True, exist_ok=False)
    for row in copies:
        target = out/row['copy']; target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(row['original']['file'], target)
        actual = identity(target)
        assert all(actual[k] == row['original'][k] for k in ['sha256', 'bytes'])
    for file, item in inputs.items():
        assert identity(file) == item, 'Input changed: '+file
    result = dict(kind='phase52-final-evidence-copies', complete=True, selectedAttempt=pin(attempt_file),
        api=attempt['api'], producer=pin(__file__), copies=copies, oversizedReferences=large,
        portable=bundles, bounds=dict(maxFileBytes=MAX_FILE, maxTotalBytes=MAX_TOTAL, maxFiles=MAX_FILES),
        copiedBytes=total, inputs=list(inputs.values()), inputsUnchanged=True, rawArchiveJoined=False,
        scope='Verbatim closed-campaign review packet including failed receipts. No rewritten outcome, target execution, compression, compiler qualification or installation claim. Separate portable bundles hold runnable modules; a separately verified full raw capsule is required for omitted images/snapshots/large logs.')
    (out/'index.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(complete=True, copies=len(copies), copiedBytes=total, out=str(out))))


if __name__ == '__main__':
    main()
