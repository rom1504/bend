"""Seal selected closed Phase131 diagnostics, not the complete raw history."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT / 'selfhost/build/phase131'
OUT = ROOT / 'implementation/phase131/diagnostics'
CASES = ['lexer', 'coverage-closures-256', 'coverage-map-churn-128']
TREES = ['final-profile01', 'final-context01', 'final-profile-analysis01',
         'owning-full-timing01', 'wide-timing01', 'wide-results01',
         'final-full-profile01', 'final-full-profile-analysis01',
         'final-profile01-guard', 'final-context01-guard',
         'final-context-relink01-guard', 'final-full-profile01-guard']
TOOLS = ['selfhost/tools/profiler', 'selfhost/tools/performance/phase131/profile',
         'selfhost/tools/performance/phase131/identity/wide']
EXTRA = ['selfhost/build/phase131/final-profile-preflight01.json',
         'selfhost/build/phase131/final-physical-analysis01.json',
         'selfhost/build/phase131/owning-identity-full-probe01/report.json',
         'selfhost/build/phase131/owning-identity-full-audit01.json',
         'selfhost/build/phase131/wide-builds01/report.json',
         'selfhost/build/phase131/wide-source-bridge01/report.json',
         'selfhost/tools/performance/phase131/identity/owning-full-summary-v02.py',
         'selfhost/tools/performance/phase131/identity/owning-full-timing.py',
         'selfhost/tools/performance/phase131/identity/reader-identity-probe.py',
         'selfhost/tools/performance/phase129/summarize-context.py',
         'selfhost/build/phase131/profile-analysis01/report.json',
         'selfhost/tools/performance/phase131/identity/owning-identity-probe.py',
         'selfhost/build/phase131/owning-identity-full-probe01/ceiling.ssa',
         'selfhost/build/phase118/p131-wide-baseline-emit01/compiler-kdef.ssa',
         'selfhost/build/phase118/p131-wide-baseline-emit01/record-transfer.ssa',
         'selfhost/build/phase118/p131-wide-candidate-emit01/compiler-kdef.ssa',
         'selfhost/build/phase118/p131-wide-candidate-emit01/record-transfer.ssa']
SUMMARIES = {
    'short-profiles.json': 'final-profile-analysis01/report.json',
    'whole-identity.json': 'owning-full-timing01/summary02/report.json',
    'wide-records.json': 'wide-results01/report.json',
    'full-source.json': 'final-full-profile-analysis01/report.json',
}


def require(ok, message):
    if not ok: raise ValueError(message)


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for part in iter(lambda: stream.read(1024 * 1024), b''): value.update(part)
    return value.hexdigest()


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest(path))


def read(path):
    return json.loads(path.read_text())


def references(value):
    if isinstance(value, dict):
        if {'file', 'bytes', 'sha256'} <= value.keys():
            yield {k: value[k] for k in ['file', 'bytes', 'sha256']}
        for child in value.values(): yield from references(child)
    elif isinstance(value, list):
        for child in value: yield from references(child)


def excluded(path):
    if path.name in ['stdout', 'stdout.log'] and path.stat().st_size > 65536:
        return 'Repeated generated output; canonical oracle retained or separately pinned'
    if path.suffix in ['.ssa', '.s'] and path.stat().st_size > 2 * 1024 * 1024:
        return 'Large generated compiler representation'
    with path.open('rb') as stream: header = stream.read(4)
    if header == b'\x7fELF' or path.suffix in ['.o', '.so', '.pyc']:
        return 'Executable/object/tool binary; identity only'
    return None


def check_gate(path, count=None):
    data = read(path)
    require(data.get('complete') and data.get('passed') and not data.get('changedInputs'),
            'Unclosed or failed gate: ' + str(path))
    if count is not None: require(len(data['rows']) == count, 'Gate row count differs')


def write_json(name, value):
    with (OUT / name).open('x') as stream: stream.write(json.dumps(value, indent=2) + '\n')
    return pin(OUT / name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seal', action='store_true', required=True)
    parser.parse_args()
    require(not OUT.exists(), 'Fresh diagnostics output directory required')
    for case in CASES:
        check_gate(BUILD / 'final-profile01' / case / 'report.json')
        check_gate(BUILD / 'final-context01' / case / 'report.json')
    check_gate(BUILD / 'owning-full-timing01/timing/report.json', 18)
    check_gate(BUILD / 'wide-timing01/timing/report.json', 20)
    check_gate(BUILD / 'final-full-profile01/capture/report.json', 1)
    for name in SUMMARIES.values():
        require(read(BUILD / name).get('complete'), 'Summary still open: ' + name)
    selected = set()
    for relative in TREES:
        directory = BUILD / relative
        require(directory.is_dir(), 'Missing selected diagnostic tree: ' + str(directory))
        selected.update(p for p in directory.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
    for relative in TOOLS:
        selected.update(p for p in (ROOT / relative).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
    missing_optional = []
    for relative in EXTRA:
        path = ROOT / relative
        if path.is_file(): selected.add(path)
        else: missing_optional.append(relative)
    selected.add(Path(__file__).resolve())
    # Only direct workload inputs/oracles and interpretation tables are added.
    # Do not recurse through historical admission/qualification input inventories.
    direct = {}
    for path in sorted(selected):
        if path.name != 'manifest.json': continue
        data = read(path)
        for key in ['sampler', 'unwindTable']:
            item = data.get(key)
            if isinstance(item, dict) and {'file', 'bytes', 'sha256'} <= item.keys():
                direct[item['file']] = {k: item[k] for k in ['file', 'bytes', 'sha256']}
        for workload in data.get('workloads', []):
            for item in references(workload):
                prior = direct.get(item['file'])
                require(prior is None or prior == item, 'Conflicting direct input identity')
                direct[item['file']] = item
    for item in direct.values():
        path = Path(item['file'])
        require(pin(path) == item, 'Direct workload input changed: ' + str(path))
        if path.is_relative_to(ROOT): selected.add(path)
    rows, omitted = [], []
    for path in sorted(selected):
        require(not path.is_symlink() and path.resolve().is_relative_to(ROOT), 'Unsafe archive source')
        identity = pin(path)
        reason = excluded(path)
        if reason:
            omitted.append(dict(**identity, reason=reason))
        else:
            rows.append(dict(**identity, member=str(path.relative_to(ROOT))))
    # Record external historic identities as declarations only. These are not
    # rehashed or recursively imported, and are not archive-completeness claims.
    declared = {}
    for row in rows:
        path = Path(row['file'])
        if path.suffix != '.json': continue
        for item in references(read(path)):
            declared[(item['file'], item['sha256'], item['bytes'])] = item
    all_selected = {r['file'] for r in rows + omitted}
    external = [r for r in declared.values() if r['file'] not in all_selected]
    inventory = dict(kind='phase131-selected-diagnostics-inventory', complete=True, targetsRun=False,
        members=rows, excluded=omitted, declaredExternalDependencies=external,
        optionalAbsentPaths=missing_optional, directWorkloadInputs=list(direct.values()),
        policy='Current final short physical/context captures, analyses, full-source profile, two unqualified diagnostic timing experiments, and interpretation methods only. Excluded selected artifacts are rehashed; other historical dependency pins are retained declarations, not rescanned.',
        clocks='Sampling/counter timing is diagnostic. Whole-identity18 and wide20 have separate paired clean timing contracts. Neither experimental transform is the qualified source.')
    # Explicit headers avoid ownership/timestamp/platform-dependent tar metadata.
    buffer = io.BytesIO()
    with gzip.GzipFile(filename='', mode='wb', fileobj=buffer, compresslevel=9, mtime=0) as zipped:
        with tarfile.open(fileobj=zipped, mode='w|', format=tarfile.PAX_FORMAT) as archive:
            for row in rows:
                data = Path(row['file']).read_bytes()
                require(len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'], 'Input changed during archive')
                info = tarfile.TarInfo(row['member']); info.size = len(data)
                info.mode = 0o644; info.mtime = 0; info.uid = info.gid = 0; info.uname = info.gname = ''
                archive.addfile(info, io.BytesIO(data))
    payload = buffer.getvalue()
    require(len(payload) <= 20 * 1024 * 1024, 'Compressed diagnostics exceed 20 MiB')
    OUT.mkdir()
    with (OUT / 'diagnostics.tar.gz').open('xb') as stream: stream.write(payload)
    with tarfile.open(OUT / 'diagnostics.tar.gz', 'r:gz') as archive:
        members = archive.getmembers()
        require([m.name for m in members] == [r['member'] for r in rows], 'Archive member inventory differs')
        for member, row in zip(members, rows):
            require(member.isfile() and member.size == row['bytes'], 'Archive member type/size differs')
            data = archive.extractfile(member).read()
            require(hashlib.sha256(data).hexdigest() == row['sha256'], 'Archive member hash differs')
    outputs = [pin(OUT / 'diagnostics.tar.gz'), write_json('inventory.json', inventory)]
    for name, source in SUMMARIES.items():
        data = (BUILD / source).read_bytes()
        require(any(r['file'] == str(BUILD/source) and r['sha256'] == hashlib.sha256(data).hexdigest() for r in rows), 'Summary changed after archive')
        with (OUT / name).open('xb') as stream: stream.write(data)
        outputs.append(pin(OUT / name))
    receipt = write_json('receipt.json', dict(kind='phase131-selected-diagnostics-capsule', complete=True,
        targetsRun=False, method=pin(__file__), outputs=outputs, members=len(rows),
        uncompressedBytes=sum(r['bytes'] for r in rows), compressedBytes=len(payload),
        excludedSelectedArtifacts=len(omitted), declaredExternalDependencies=len(external),
        everyMemberReopened=True, pathsRelativeToRepository=True,
        scope='Exact selected evidence archive; not a standalone compiler/toolchain or full historical snapshot. Offline aggregate inspection is supported. Fresh symbolization or target replay needs excluded pinned binaries/toolchain and original identity-aware paths.'))
    print(json.dumps(dict(complete=True, archive=outputs[0], receipt=receipt, members=len(rows), compressedBytes=len(payload))))


if __name__ == '__main__': main()
