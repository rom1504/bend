"""Byte-verified hardlink deduplication of explicit immutable build artifacts."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('files', type=Path, nargs='+')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase144') and not out.exists()
paths = [f.resolve() for f in a.files]
assert len(paths) == len(set(paths))
rows = []
groups = {}
for path in paths:
    assert path.is_file() and path.is_relative_to(ROOT/'selfhost/build')
    assert path.name in {'program.ssa', 'program.o', 'stdout'}
    data = path.read_bytes()
    row = dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest(),
               oldInode=path.stat().st_ino, oldLinks=path.stat().st_nlink)
    rows.append(row)
    groups.setdefault((len(data), row['sha256']), []).append(path)
saved = 0
for matches in groups.values():
    first = matches[0]
    for path in matches[1:]:
        if os.path.samefile(first, path):
            continue
        assert first.read_bytes() == path.read_bytes()
        previous = path.stat()
        temp = path.with_name(path.name+'.p144-dedup')
        assert not temp.exists()
        os.link(first, temp)
        os.replace(temp, path)
        if previous.st_nlink == 1:
            saved += previous.st_size
for row, path in zip(rows, paths):
    data = path.read_bytes()
    assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
    row['newInode'] = path.stat().st_ino
    row['newLinks'] = path.stat().st_nlink
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(dict(complete=True, contentUnchanged=True,
                              estimatedBytesFreed=saved, rows=rows), indent=2)+'\n')
print(json.dumps(dict(files=len(rows), estimatedBytesFreed=saved)))
