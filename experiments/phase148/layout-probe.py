#!/usr/bin/env python3
"""Run the frozen mixed-array probe inside one caller-owned resource guard."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time


def identity(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    rows = []
    for count, seed, repeats in [(0, 0, 1), (1, 1, 1), (17, 4294967290, 3),
                                  (256, 11, 100), (4096, 13, 100)]:
        command = [str(args.binary.resolve()), '--threads', '1', '--gpu', 'off', '--',
                   'layout', str(count), str(seed), str(repeats)]
        expected = ((1 + sum(((seed + 3 * i) & 0xffffffff) ^ 7
                             for i in range(count))) * repeats) & 0xffffffff
        start = time.monotonic()
        run = subprocess.run(command, capture_output=True, timeout=20)
        seconds = time.monotonic() - start
        passed = run.returncode == 0 and run.stdout == f'{expected}\n'.encode() and not run.stderr
        rows.append(dict(command=command, expected=expected, returncode=run.returncode,
                         stdout=run.stdout.decode(errors='replace'), stderr=run.stderr.decode(errors='replace'),
                         seconds=seconds, passed=passed))
        if not passed:
            break
    result = dict(kind='phase148-mixed-array-layout-controls', version=1,
                  inputs=[identity(Path(__file__)), identity(args.binary), identity(args.source)],
                  complete=len(rows) == 5, passed=len(rows) == 5 and all(r['passed'] for r in rows), rows=rows,
                  scope='Independent integer-output oracle and diagnostic loop timings; no compact-IR or whole-compiler speed claim.')
    (args.out / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=result['complete'], passed=result['passed'], seconds=[r['seconds'] for r in rows])))
    raise SystemExit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
