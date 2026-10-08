"""Verify preserved previous-release bytes and inherited work before installation."""
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


def main():
    root = Path(__file__).resolve().parents[5]
    raw = root / 'selfhost/build/phase66'

    def pin(path):
        data = path.read_bytes()
        return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

    def write(name, value):
        with (raw / name).open('x') as out:
            out.write(json.dumps(value, indent=2) + '\n')
        return pin(raw / name)

    producer = pin(Path(__file__).resolve())
    checked = []
    for name, count in [('installed-before.json', 7), ('inherited-before.json', 110)]:
        baseline = raw / name
        rows = json.loads(baseline.read_text())['files']
        assert len(rows) == count and len({row['file'] for row in rows}) == count
        copies = []
        for row in rows:
            live = (root / row['file']).resolve(strict=True)
            assert live.is_relative_to(root)
            observed = pin(live)
            assert observed['sha256'] == row['sha256'], str(live)
            assert 'bytes' not in row or observed['bytes'] == row['bytes']
            if count == 7:
                copy = raw / 'previous-installed' / live.relative_to(root / 'selfhost/dist')
                assert pin(copy)['sha256'] == row['sha256'], str(copy)
                copies.append(dict(original=row, copy=str(copy.relative_to(root)), sha256=row['sha256']))
        receipt = dict(complete=True, **{'pass': True}, verifiedFiles=count,
            baseline=pin(baseline), producer=producer,
            verifiedAt=datetime.now(timezone.utc).isoformat())
        if copies:
            receipt['files'] = copies
        output = 'previous-installed-preservation.json' if count == 7 else 'inherited-preinstall-preservation.json'
        checked.append(dict(**write(output, receipt), verifiedFiles=count))
    print(json.dumps(dict(complete=True, **{'pass': True}, preservation=checked)))


if __name__ == '__main__':
    main()
