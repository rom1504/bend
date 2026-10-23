"""Exact dedup of frozen Phase126 source≤33 snapshots and completed checked APIs."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p126_exact_dedup', HERE/'dedup.py')
D = importlib.util.module_from_spec(spec); spec.loader.exec_module(D)
ROOT = D.ROOT


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size, sha256=D.digest(path))


def verify(row):
    assert pin(row['file']) == row, 'Changed pinned file: '+row['file']


def stable(path, before):
    now = D.stat(path)
    assert all(now[k] == before[k] for k in ['device', 'inode', 'bytes', 'mode', 'uid', 'gid', 'mtimeNs'])
    return now


def inventory():
    proofs = []; candidates = {}; keepers = {}; sources = set()
    for manifest in sorted((ROOT/'selfhost/build/phase126').glob('*/manifest.json')):
        match = re.search(r'-source(\d+)$', manifest.parent.name)
        if not match or not 1 <= int(match[1]) <= 33: continue
        data = json.loads(manifest.read_text())
        if not data.get('complete') or 'source' not in data: continue
        source = data['source']; path = Path(source['file'])
        if path.parent != manifest.parent or path.name != 'compiler.bend': continue
        verify(source); sources.add(source['sha256']); proofs.append(pin(manifest))
        candidates[str(path)] = source
        bends = [r for r in data.get('inputs', []) if r['file'].endswith('.bend')]
        by_digest = {}
        for row in bends:
            p = Path(row['file'])
            if not p.is_relative_to(ROOT) or not p.is_file() or p.is_symlink(): continue
            if pin(p) != row: continue  # A later changed live module is not a keeper.
            keepers[str(p)] = row; by_digest[(row['bytes'], row['sha256'])] = row
        for snapshot in sorted(manifest.parent.glob('module[0-9]*.bend')):
            row = pin(snapshot)
            if (row['bytes'], row['sha256']) in by_digest:
                candidates[str(snapshot)] = row
    for report in sorted((ROOT/'selfhost/build/phase111').glob('p126-*/report.json')):
        data = json.loads(report.read_text())
        if not (data.get('complete') and data.get('checked') and 'api' in data): continue
        # Only APIs already completed for one of the admitted immutable sources.
        if not any(r.get('sha256') in sources and r['file'].endswith('.bend') for r in data.get('inputs', [])): continue
        row = data['api']; path = Path(row['file'])
        if path.parent != report.parent or path.name != 'api.mjs': continue
        verify(row); candidates[str(path)] = row; proofs.append(pin(report))
    return proofs, keepers, candidates


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply-plan', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    out.mkdir(parents=True); started = time.monotonic()
    methods = [pin(__file__), pin(HERE/'dedup.py')]
    r = dict(complete=False, applied=bool(args.apply_plan), methods=methods, inputs=methods[:], plan=[], results=[],
        freeBefore=shutil.disk_usage(ROOT).free, targetsRun=False,
        scope='Only authenticated frozen Phase126 compiler/module snapshots through source33 and completed checked p126 APIs. Equal pinned source/module files may serve as keepers. Reports, active outputs, SSA/ELF and all nonmatching files excluded. SHA256 plus exact bytes and metadata checks; atomic same-filesystem hardlinks preserve paths/contents.')
    def save(): (out/'report.json').write_text(json.dumps(r, indent=2)+'\n')
    save()
    if not args.apply_plan:
        proofs, keepers, candidates = inventory(); r['inputs'].extend(proofs)
        r['eligible'] = list(candidates.values()); matched = {}; expected = 0
        # Existing original inputs are preferred keepers. Only generated candidates
        # can be replaced, even if a keeper itself is independently allocated.
        rows = list(keepers.values())+[v for k, v in candidates.items() if k not in keepers]
        for row in rows:
            path = Path(row['file']); assert not path.is_symlink(); verify(row)
            before = D.stat(path); key = tuple(before[k] for k in ['device','bytes','mode','uid','gid'])+(row['sha256'],)
            if key not in matched:
                matched[key] = (path, before, row); continue
            keep, keeper_before, keeper_pin = matched[key]
            if str(path) not in candidates or before['links'] != 1 or before['inode'] == keeper_before['inode']: continue
            stable(keep, keeper_before); stable(path, before)
            assert D.equal(keep, path); stable(path, before)
            r['plan'].append(dict(keep=str(keep), file=str(path), sha256=row['sha256'],
                before=before, keeperBefore=keeper_before, filePin=row, keeperPin=keeper_pin))
            expected += before['allocated']
        r.update(expectedReclaimedAllocatedBytes=expected, eligiblePaths=len(candidates))
    else:
        previous = json.loads(args.apply_plan.read_text())
        assert previous['complete'] and not previous['applied'] and previous['methods'] == methods
        for row in previous['inputs']: verify(row)
        r['inputs'].extend([pin(args.apply_plan), *previous['inputs']]); r['plan'] = previous['plan']
        eligible = {x['file']: x for x in previous['eligible']}; reclaimed = 0
        for row in r['plan']:
            path, keep = Path(row['file']), Path(row['keep'])
            assert row['filePin'] == eligible[str(path)] and not path.is_symlink() and not keep.is_symlink()
            verify(row['filePin']); verify(row['keeperPin'])
            before = stable(path, row['before']); stable(keep, row['keeperBefore'])
            assert before['links'] == 1 and D.equal(keep, path)
            temporary = path.with_name(path.name+'.p126-frozen-exact-link')
            assert not temporary.exists(); os.link(keep, temporary); os.replace(temporary, path)
            after = D.stat(path); assert after['inode'] == D.stat(keep)['inode']
            verify(row['filePin']); reclaimed += before['allocated']
            r['results'].append(dict(file=str(path), reclaimedAllocatedBytes=before['allocated'], after=after)); save()
        r['reclaimedAllocatedBytes'] = reclaimed
    r.update(complete=True, duplicatePaths=len(r['plan']), seconds=time.monotonic()-started,
             freeAfter=shutil.disk_usage(ROOT).free)
    save()
    print(json.dumps({k:r[k] for k in ['complete','applied','duplicatePaths','freeBefore','freeAfter']}
          | {k:r[k] for k in ['expectedReclaimedAllocatedBytes','reclaimedAllocatedBytes'] if k in r}))


if __name__ == '__main__': main()
