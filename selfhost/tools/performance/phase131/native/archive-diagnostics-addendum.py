"""Append selected closed diagnostics without recompressing or rescanning capsule01."""
import argparse
import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
PARENT_METHOD = HERE / 'archive-diagnostics.py'
assert hashlib.sha256(PARENT_METHOD.read_bytes()).hexdigest() == '1e36a86b8231f5eb78e5792a8bfe20c0927b1d042b73ab49ecbd61cfb6c2865c'
spec = importlib.util.spec_from_file_location('capsule01', PARENT_METHOD)
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
ROOT, OUT = M.ROOT, M.OUT


def resolve(value):
    path = Path(value)
    return path if path.is_absolute() else ROOT / path


def verify(row):
    path = resolve(row['file'])
    actual = M.pin(path)
    M.require(actual['bytes'] == row['bytes'] and actual['sha256'] == row['sha256'], 'Changed input: ' + str(path))
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', type=Path, required=True)
    args = parser.parse_args()
    plan = M.read(args.plan)
    M.require(plan['kind'] == 'phase131-diagnostics-addendum02-plan', 'Wrong archive plan')
    M.require(not (OUT / 'addendum02.tar.gz').exists(), 'Fresh addendum required')
    parent_receipt = M.read(verify(plan['parentReceipt']))
    parent_inventory = M.read(verify(plan['parentInventory']))
    M.require(parent_receipt['complete'] and parent_receipt['everyMemberReopened'], 'Parent capsule not closed')
    M.require(plan['parentInventory'] in parent_receipt['outputs'] and parent_inventory['complete']
              and parent_inventory['kind'] == 'phase131-selected-diagnostics-inventory', 'Parent inventory not bound to receipt')
    parent_archive = next(r for r in parent_receipt['outputs'] if r['file'].endswith('/diagnostics.tar.gz'))
    verify(parent_archive)
    old = {r['file']: r for r in parent_inventory['members']}
    for gate in plan['closedReports']:
        data = M.read(verify(gate['pin']))
        M.require(data.get('complete'), 'Open addendum report')
        if gate.get('passed'): M.require(data.get('passed') and not data.get('changedInputs'), 'Failed target report')
        if 'rows' in gate: M.require(len(data['rows']) == gate['rows'], 'Unexpected report count')
    selected = {args.plan.resolve(), Path(__file__).resolve(), PARENT_METHOD}
    for relative in plan['trees']:
        directory = resolve(relative)
        M.require(directory.is_dir() and directory.is_relative_to(ROOT), 'Invalid selected tree')
        selected.update(p for p in directory.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
    for row in plan['files']: selected.add(verify(row))
    # Explicit one-level input closure for the named new receipts; never walk
    # into the full ancestry of these receipts or rewrite their absolute paths.
    for row in plan.get('inputReceipts', []):
        path = verify(row); selected.add(path)
        for item in M.references(M.read(path)):
            target = resolve(item['file'])
            if target.is_relative_to(ROOT): selected.add(verify(item))
    for row in plan.get('workloadManifests', []):
        path = verify(row); selected.add(path); data = M.read(path)
        parts = [data.get(k) for k in ['sampler', 'unwindTable']] + data.get('workloads', [])
        for item in M.references(parts):
            target = resolve(item['file'])
            if target.is_relative_to(ROOT): selected.add(verify(item))
    included, excluded, reused = [], [], []
    for path in sorted(selected):
        M.require(not path.is_symlink() and path.resolve().is_relative_to(ROOT), 'Unsafe member')
        row = M.pin(path)
        if row['file'] in old and all(old[row['file']][k] == row[k] for k in ['bytes', 'sha256']):
            reused.append(row); continue
        reason = M.excluded(path)
        if reason: excluded.append(dict(**row, reason=reason))
        else: included.append(dict(**row, member=str(path.relative_to(ROOT))))
    declared = {}
    for row in included:
        path = Path(row['file'])
        if path.suffix == '.json':
            for item in M.references(M.read(path)):
                declared[(item['file'], item['bytes'], item['sha256'])] = item
    seen = {r['file'] for r in included + excluded + reused}
    external = [r for r in declared.values() if str(resolve(r['file'])) not in seen]
    buffer = io.BytesIO()
    with gzip.GzipFile(filename='', mode='wb', fileobj=buffer, compresslevel=9, mtime=0) as zipped:
        with tarfile.open(fileobj=zipped, mode='w|', format=tarfile.PAX_FORMAT) as archive:
            for row in included:
                data = Path(row['file']).read_bytes()
                M.require(len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'], 'Member changed')
                info = tarfile.TarInfo(row['member']); info.size = len(data)
                info.mode = 0o644; info.mtime = 0; info.uid = info.gid = 0; info.uname = info.gname = ''
                archive.addfile(info, io.BytesIO(data))
    payload = buffer.getvalue()
    M.require(len(payload) + parent_archive['bytes'] <= 20 * 1024 * 1024, 'Combined compressed capsules exceed20MiB')
    with (OUT / 'addendum02.tar.gz').open('xb') as stream: stream.write(payload)
    with tarfile.open(OUT / 'addendum02.tar.gz', 'r:gz') as archive:
        members = archive.getmembers()
        M.require([m.name for m in members] == [r['member'] for r in included], 'Member list differs')
        for member, row in zip(members, included):
            M.require(member.isfile() and member.size == row['bytes'], 'Bad member type/size')
            M.require(hashlib.sha256(archive.extractfile(member).read()).hexdigest() == row['sha256'], 'Member hash differs')
    outputs = [M.pin(OUT / 'addendum02.tar.gz')]
    outputs.append(M.write_json('addendum02-inventory.json', dict(complete=True, targetsRun=False,
        parentReceipt=plan['parentReceipt'], parentInventory=plan['parentInventory'], plan=M.pin(args.plan),
        members=included, excluded=excluded, reusedParentMembers=reused, declaredExternalDependencies=external,
        scope=plan['scope'], dependencyPolicy='Included/excluded/reused selected files authenticated; other historical references are declarations only. Parent archive identity rechecked without rescanning its members.')))
    for name, row in plan.get('summaries', {}).items():
        M.require(Path(name).name == name and name.startswith('addendum02-'), 'Unsafe summary filename')
        path = verify(row)
        M.require(any(r['file'] == str(path) for r in included + reused), 'Summary outside selected inventory')
        with (OUT / name).open('xb') as stream: stream.write(path.read_bytes())
        outputs.append(M.pin(OUT / name))
    receipt = M.write_json('addendum02-receipt.json', dict(complete=True, targetsRun=False,
        method=M.pin(__file__), parentMethod=M.pin(PARENT_METHOD), plan=M.pin(args.plan), outputs=outputs,
        members=len(included), compressedBytes=len(payload), everyMemberReopened=True,
        parentMembersRescanned=False, scope=plan['scope']))
    print(json.dumps(dict(complete=True, archive=outputs[0], receipt=receipt, members=len(included), reused=len(reused))))


if __name__ == '__main__': main()
