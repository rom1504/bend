"""Bounded exact hardlink dedup of frozen phase111/118/120..125 artifacts."""
import argparse
from collections import defaultdict
import importlib.util
import json
import os
from pathlib import Path
import shutil
import time

HERE = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location('dedup126', HERE / 'dedup.py')
D = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(D)
ROOT = D.ROOT
ROOTS = [ROOT / 'selfhost/build' / ('phase' + str(n)) for n in (111, 118, 120, 121, 122, 123, 124, 125)]


def pin(path):
    return dict(file=str(path), bytes=path.stat().st_size, sha256=D.digest(path))


def allowed(path):
    return any(path.is_relative_to(root) for root in ROOTS) and not any(
        'p126' in component or component == 'phase126' for component in path.parts)


def save(out, report):
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--apply-plan', type=Path)
    parser.add_argument('--target-mib', type=int, default=384)
    args = parser.parse_args()
    assert 200 <= args.target_mib <= 512
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase126')
    out.mkdir(parents=True)
    started = time.monotonic()
    report = dict(complete=False, applied=bool(args.apply_plan), roots=list(map(str, ROOTS)),
        exclusions='Any path component containing p126, and phase126; no symlinks',
        inputs=[pin(Path(__file__).resolve()), pin(HERE / 'dedup.py')], plan=[], results=[],
        freeBefore=shutil.disk_usage(ROOT).free,
        scope='Frozen artifacts only. SHA256 plus byte equality, exact metadata recheck, atomic hardlink replacement. All paths/content/modes survive; inode and mtime may change. No compression, target execution or evidence removal.')
    save(out, report)
    if args.apply_plan:
        plan_path = args.apply_plan.resolve()
        source = json.loads(plan_path.read_text())
        assert source['complete'] and not source['applied'] and source['inputs'] == report['inputs']
        report['inputs'].append(pin(plan_path))
        report['plan'] = source['plan']
        reclaimed = 0
        for row in source['plan']:
            keep, path = Path(row['keep']), Path(row['file'])
            assert allowed(keep) and allowed(path) and not keep.is_symlink() and not path.is_symlink()
            before = D.stat(path)
            assert all(before[k] == row['before'][k] for k in ('device', 'inode', 'bytes', 'mode', 'uid', 'gid', 'mtimeNs'))
            assert D.digest(keep) == row['sha256'] == D.digest(path) and D.equal(keep, path)
            temp = path.with_name(path.name + '.p126-hardlink-v2-tmp')
            assert not temp.exists()
            os.link(keep, temp)
            os.replace(temp, path)
            after = D.stat(path)
            assert after['inode'] == D.stat(keep)['inode'] and D.digest(path) == row['sha256']
            freed = before['allocated'] if before['links'] == 1 else 0
            reclaimed += freed
            report['results'].append(dict(file=str(path), after=after, reclaimedAllocatedBytes=freed))
            save(out, report)
        report['reclaimedAllocatedBytes'] = reclaimed
    else:
        groups, hashes = defaultdict(list), {}
        examined = 0
        for root in ROOTS:
            for directory, subdirs, files in os.walk(root):
                subdirs[:] = sorted(name for name in subdirs if 'p126' not in name and name != 'phase126'
                                     and not (Path(directory) / name).is_symlink())
                for name in sorted(files):
                    path = Path(directory) / name
                    if not allowed(path) or path.is_symlink() or (path.suffix not in D.EXT and name != 'program'):
                        continue
                    s = D.stat(path)
                    if s['bytes'] >= 65536:
                        examined += 1
                        groups[tuple(s[k] for k in ('device', 'bytes', 'mode', 'uid', 'gid'))].append((path, s))
        expected = 0
        for key, rows in sorted(groups.items(), key=lambda item: -item[0][1]):
            if len({s['inode'] for _, s in rows}) < 2:
                continue
            matched = defaultdict(list)
            for path, s in rows:
                identity = (s['device'], s['inode'])
                if identity not in hashes:
                    hashes[identity] = D.digest(path)
                matched[hashes[identity]].append((path, s))
            for sha, members in matched.items():
                members.sort(key=lambda item: (-item[1]['links'], str(item[0])))
                keep, ks = members[0]
                by_inode = defaultdict(list)
                for path, s in members:
                    by_inode[s['inode']].append((path, s))
                for inode, duplicates in by_inode.items():
                    if inode == ks['inode'] or len(duplicates) != duplicates[0][1]['links']:
                        continue
                    for path, s in duplicates:
                        assert D.equal(keep, path)
                        report['plan'].append(dict(keep=str(keep), file=str(path), sha256=sha,
                            keeperBefore=ks, before=s))
                    expected += duplicates[0][1]['allocated']
                if expected >= args.target_mib * 1024**2:
                    break
            if expected >= args.target_mib * 1024**2:
                break
        report.update(examinedFiles=examined, hashedInodes=len(hashes), expectedReclaimedAllocatedBytes=expected)
    report.update(complete=True, duplicatePaths=len(report['plan']), seconds=time.monotonic()-started,
                  freeAfter=shutil.disk_usage(ROOT).free)
    save(out, report)
    print(json.dumps({k: v for k, v in report.items() if k in ('complete','applied','duplicatePaths','seconds','expectedReclaimedAllocatedBytes','reclaimedAllocatedBytes','freeBefore','freeAfter','hashedInodes')}))


if __name__ == '__main__':
    main()
