#!/usr/bin/env python3
"""Inventory or archive scoped Phase144 evidence; never run compiler targets."""
import argparse
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[4]
MIB = 1024 * 1024
BUILD_PHASES = (102, 111, 112, 113, 118, 130, 134)
TRACKED_CAPSULES = ('implementation/phase144/checkpoint01',
                    'implementation/phase144/serial-rfc-full-evidence')


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        while chunk := stream.read(MIB):
            digest.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def verify(row):
    assert pin(row['file']) == row, row['file']
    return Path(row['file'])


def read(path):
    return json.loads(Path(path).read_text())


def local(path):
    path = Path(path).resolve()
    assert path.is_relative_to(ROOT), path
    return path


def published():
    """Authenticated byte copies already committed separately are not duplicated."""
    reused = {}
    caps = []
    for directory in TRACKED_CAPSULES:
        base = ROOT / directory
        summary = read(base / 'summary.json')
        assert summary['complete']
        caps.extend(pin(p) for p in sorted(base.iterdir()) if p.is_file())
        if 'rows' in summary:
            pairs = [(r, dict(file=str(ROOT/r['archived']), bytes=r['bytes'],
                             sha256=r['sha256'])) for r in summary['rows']]
        else:
            pairs = [(r['original'], r['published']) for r in summary['evidence']]
        for original, copy in pairs:
            op = local(ROOT / original['file'])
            cp = local(ROOT / copy['file'])
            op_pin = dict(file=str(op), bytes=original['bytes'], sha256=original['sha256'])
            cp_pin = dict(file=str(cp), bytes=copy['bytes'], sha256=copy['sha256'])
            verify(op_pin); verify(cp_pin)
            reused[op] = dict(original=op_pin, published=cp_pin)
    return reused, caps


def select(plan_path):
    plan = read(plan_path)
    assert plan['complete'] and plan['sourceAdmission']['completeSourceReplay']
    n2_path = Path(plan['paths']['n2'])/'report.json'
    n2 = read(n2_path)
    assert n2['complete'] and n2['source'] == plan['sourceAdmission']['source']
    assert n2['runtime'] == plan['runtime']
    principal = [plan['sourceAdmission']['source'], plan['runtime'],
                 plan['base'], plan['carrier'], n2['binary'], n2['object']]
    for row in principal:
        verify(row)
    reused, capsules = published()
    explicit = {local(r['file']) for r in principal}
    # Address-based offline attribution requires these exact diagnostic images
    # and the owner map, not a replacement executable from the final source.
    for name in ('profile01/owners.json', 'profile01/runtime/program',
                 'stages02/runtime/program', 'stages02/runtime/runtime.o',
                 'stages02/runtime/sampler.so'):
        p = ROOT/'selfhost/build/phase144'/name
        assert p.is_file() and not p.is_symlink(), p
        explicit.add(p)
    files = set(explicit)
    skipped = Counter()
    exclusions = []
    roots = [ROOT/'selfhost/build/phase144']
    for phase in BUILD_PHASES:
        roots.extend(sorted((ROOT/f'selfhost/build/phase{phase}').glob('*p144*')))
    roots.extend(ROOT/p for p in ('selfhost/tools/performance/phase144',
        'research/phase144', 'experiments/phase144', 'design/phase144'))
    for base in roots:
        if not base.exists():
            continue
        for p in sorted(base.rglob('*')):
            if not p.is_file() or p.is_symlink() or '__pycache__' in p.parts:
                continue
            if p in explicit:
                continue
            if p in reused:
                skipped['already-published-copy'] += 1
                continue
            size = p.stat().st_size
            reason = None
            if p.name in {'api.mjs', 'program', 'compiler.bend', 'runtime.o'}:
                reason = 'generated-api-image-or-nonselected-source'
            elif p.suffix in {'.ssa', '.s', '.o', '.so', '.a', '.gz', '.zip'}:
                reason = 'generated-machine-or-archive-product'
            elif p.name.endswith(('.lock', '.tmp')):
                reason = 'transient-file'
            elif p.name in {'stdout', 'compiler.stdout'} and size > 64*1024:
                reason = 'large-generated-stdout'
            elif size > 2*MIB and p.suffix == '.json' and p.name not in {'report.json','manifest.json','plan.json'}:
                reason = 'large-derived-API-graph-or-state'
            elif size > 8*MIB:
                reason = 'over-eight-MiB-not-explicit'
            elif p.open('rb').read(4) == b'\x7fELF':
                reason = 'ordinary-executable'
            if reason:
                skipped[reason] += 1
                if size > MIB:
                    exclusions.append(dict(file=str(p.relative_to(ROOT)), bytes=size, reason=reason))
            else:
                files.add(p)
    # Small direct inputs preserve the native acquisition method and source/runtime
    # construction. This is deliberately not an unbounded receipt-closure crawler.
    dependencies = [plan['producerQualification'], plan['carrierReceipt'], plan['runtimeBuild'],
                    plan['sourceAdmission']['sourceManifest'], plan['sourceAdmission']['checkedApi']]
    for row in plan['inputs']:
        p = Path(row.get('file', ''))
        if p.is_absolute() and p.is_relative_to(ROOT) and row.get('bytes', 9*MIB) <= 8*MIB:
            if ('selfhost/tools' in str(p) or '.bootstrap/upstream-phase66/bend2/' in str(p)) and p.suffix in {'.py','.mjs','.ts','.bend','.json','.c','.h'}:
                dependencies.append(row)
    # Keep the published parent archive inventory as a dependency declaration;
    # do not include its tarball or duplicate the parent compiler binary.
    parent_inventory = ROOT/'implementation/phase143/evidence01/inventory.json'
    parent = read(parent_inventory)
    parent_archive = dict(parent['archive'])
    parent_archive['file'] = str(ROOT/parent_archive['file'])
    assert Path(parent_archive['file']).is_file()
    dependencies.append(pin(parent_inventory))
    for row in dependencies:
        p = verify(row)
        if p not in reused:
            files.add(local(p))
    files.add(local(plan_path));files.add(n2_path);files.add(Path(__file__).resolve())
    return plan, n2, sorted(files), dict(
        principalPins=principal, explicitRecoveryAndProfileArtifacts=[str(p.relative_to(ROOT)) for p in sorted(explicit)],
        reusedPublishedCopies=list(reused.values()), existingCapsules=capsules,
        parentArchiveDependency=parent_archive, parentArchiveRehashed=False, exclusionsByReason=dict(skipped),
        largeExcludedProducts=exclusions,
        scope='Scoped evidence plus final native recovery artifacts. Failed receipts retained. No giant QBE/API/assembly or ordinary binaries. '
              'Existing checkpoint01/serial capsules and Phase143 parent archive remain separate dependencies. '
              'No transitive historical requalification, portable release, or installed selection change. '
              'Absolute paths and external machine tools require explicit relocation and renewed validation.')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--plan', type=Path, required=True)
    ap.add_argument('--qualification', type=Path)
    ap.add_argument('--out', type=Path)
    ap.add_argument('--inventory-only', action='store_true')
    args = ap.parse_args()
    plan, n2, files, details = select(args.plan.resolve())
    if args.qualification:
        qpath = local(args.qualification)
        qualification = read(qpath)
        assert qualification['complete'] and qualification['nativeQualified']
        assert qualification['kind'] == 'phase144-native-qualification'
        assert qualification['plan'] == pin(args.plan)
        assert qualification['source'] == plan['sourceAdmission']['source']
        assert qualification['runtime'] == plan['runtime'] and qualification['n2'] == n2['binary']
        assert qualification['q2EqualsQ3'] and qualification['qbe']['q2'] == n2['retainedIR']
        files = sorted(set(files)|{qpath})
        details['qualification'] = pin(qpath)
    total = sum(p.stat().st_size for p in files)
    assert total <= 256*MIB, ('raw archive budget', total)
    if args.inventory_only:
        print(json.dumps(dict(kind='phase144-archive-inventory', archiveWritten=False,
          files=len(files), rawBytes=total, byTopDirectory=dict(Counter(str(p.relative_to(ROOT)).split('/')[0] for p in files)),
          explicitRecoveryAndProfileArtifacts=details['explicitRecoveryAndProfileArtifacts'],
          exclusionsByReason=details['exclusionsByReason'], largest=[dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size) for p in sorted(files,key=lambda x:x.stat().st_size,reverse=True)[:15]]),indent=2))
        return
    assert args.qualification and args.out, 'Archival requires completed qualification and explicit output'
    out = args.out.resolve()
    assert out.is_relative_to(ROOT/'implementation/phase144') and not out.exists()
    rows = [dict(pin(p), file=str(p.relative_to(ROOT)), mode=p.stat().st_mode & 0o777) for p in files]
    out.mkdir(parents=True)
    archive = out/'evidence.tar.gz'
    record = dict(kind='phase144-evidence', complete=False, method=pin(__file__), files=rows, **details)
    save = lambda: (out/'inventory.json').write_text(json.dumps(record,indent=2)+'\n')
    save()
    # Deterministic compressed transport with bounded memory; no extraction.
    with archive.open('xb') as raw:
        with gzip.GzipFile(fileobj=raw, mode='wb', filename='', mtime=0, compresslevel=6) as gz:
            with tarfile.open(fileobj=gz,mode='w|',format=tarfile.PAX_FORMAT) as tar:
                for p,row in zip(files,rows):
                    info = tarfile.TarInfo(row['file']);info.size=row['bytes'];info.mode=row['mode']
                    info.uid=info.gid=0;info.uname=info.gname='';info.mtime=0
                    with p.open('rb') as src:
                        tar.addfile(info,src)
    assert archive.stat().st_size <= 64*MIB, 'Compressed archive exceeds bounded64MiB budget'
    with tarfile.open(archive,'r|gz') as tar:
        for expected,member in zip(rows,tar,strict=True):
            assert member.isfile() and member.name == expected['file'] and member.mode == expected['mode']
            digest=hashlib.sha256();count=0
            src=tar.extractfile(member)
            while chunk := src.read(MIB):
                digest.update(chunk);count+=len(chunk)
            assert count==expected['bytes'] and digest.hexdigest()==expected['sha256']
    for p,row in zip(files,rows):
        now=pin(p)
        assert now['bytes']==row['bytes'] and now['sha256']==row['sha256']
    record.update(complete=True,archive=pin(archive),roundtripExact=True,currentInputsExact=True,
                  rawBytes=total,compressedBytes=archive.stat().st_size)
    save()
    print(json.dumps(dict(complete=True,files=len(rows),rawBytes=total,archive=record['archive'])))


if __name__ == '__main__':
    main()
