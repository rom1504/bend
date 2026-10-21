"""Coalesce exact frozen build artifacts; preserve every path, byte and mode."""
import argparse, collections, hashlib, json, os, stat
from pathlib import Path
ROOT = Path(__file__).resolve().parents[4]
def digest(p):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda: f.read(1048576), b''): h.update(b)
    return h.hexdigest()
def save(p, x): p.write_text(json.dumps(x, indent=2)+'\n')
p = argparse.ArgumentParser()
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--apply', type=Path)
p.add_argument('roots', nargs='*', type=Path)
a = p.parse_args()
if a.apply:
    assert not a.apply.exists()
    rows = json.loads(a.plan.read_text())['groups']; freed = 0
    for r in rows:
        paths = [ROOT/x for x in r['paths']]
        for f in paths:
            st = f.stat()
            assert not f.is_symlink() and stat.S_ISREG(st.st_mode)
            assert (st.st_size, stat.S_IMODE(st.st_mode), digest(f)) == (r['bytes'], r['mode'], r['sha256'])
        for f in paths[1:]:
            if os.path.samefile(paths[0], f): continue
            st = f.stat()
            if st.st_nlink == 1: freed += st.st_size
            tmp = f.with_name(f.name+'.dedup118')
            assert not tmp.exists()
            os.link(paths[0], tmp); os.replace(tmp, f)
            assert digest(f) == r['sha256']
    save(a.apply, dict(complete=True, reclaimedBytes=freed, plan=str(a.plan),
        scope='Immutable generated artifacts only; paths, bytes and modes retained. Never mutate frozen artifacts in place.'))
    print(freed)
else:
    assert not a.plan.exists()
    sizes = collections.defaultdict(list)
    for root in a.roots:
        root = root.resolve()
        assert root.resolve().is_relative_to(ROOT/'selfhost/build')
        for f in root.rglob('*'):
            if f.is_symlink() or not f.is_file() or f.suffix not in {'.c','.ssa','.s','.o','.mjs','.bend'}: continue
            st = f.stat()
            if st.st_size >= 262144: sizes[(st.st_size, stat.S_IMODE(st.st_mode))].append(f)
    groups = []
    for (size, mode), files in sizes.items():
        if len({(f.stat().st_dev, f.stat().st_ino) for f in files}) < 2: continue
        hashes = collections.defaultdict(list); inodes = {}
        for f in files:
            key = (f.stat().st_dev, f.stat().st_ino)
            if key not in inodes: inodes[key] = digest(f)
            hashes[inodes[key]].append(f)
        for sha, paths in hashes.items():
            if len({(f.stat().st_dev, f.stat().st_ino) for f in paths}) > 1:
                groups.append(dict(bytes=size, mode=mode, sha256=sha, paths=[str(f.relative_to(ROOT)) for f in paths]))
    a.plan.parent.mkdir(parents=True, exist_ok=True)
    save(a.plan, dict(groups=groups, roots=list(map(str,a.roots))))
    print(json.dumps(dict(groups=len(groups), candidateBytes=sum(r['bytes']*(len(r['paths'])-1) for r in groups))))
