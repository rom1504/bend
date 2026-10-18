#!/usr/bin/env python3
"""Check frozen Bend source and acquire a testing API; run under the root guard."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('p111_prepare', HERE / 'prepare.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('exports', nargs='+')
    args = p.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Use fresh Phase111 output')
    out.mkdir(parents=True)
    tool = ROOT / 'selfhost/tools/stage0-library.mjs'
    bun = ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun'
    upstream = Path(os.environ.get('BEND_UPSTREAM', ROOT / 'selfhost/.bootstrap/upstream-phase66')).resolve()
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'stage0-library.mjs').write_bytes(tool.read_bytes())
    command = [str(bun), str(tool), str(args.source.resolve()), str(out / 'api.mjs'), *args.exports]
    record = dict(kind='phase111-checked-api', complete=False, checked=False,
                  inputs=[P.pin(out / 'method.py'), P.pin(HERE / 'prepare.py'), P.pin(out / 'stage0-library.mjs'),
                          P.pin(bun), P.pin(args.source),
                          *[P.pin(upstream / 'bend2' / name) for name in ['bend.ts', 'comp.ts', 'base.bend']]],
                  command=command, exports=args.exports)
    save = lambda: (out / 'report.json').write_text(json.dumps(record, indent=2) + '\n')
    save()
    start = time.monotonic()
    with (out / 'stdout').open('xb') as so, (out / 'stderr').open('xb') as se:
        child = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se)
    record.update(seconds=time.monotonic()-start, status=child.returncode,
                  complete=child.returncode == 0, checked=child.returncode == 0)
    if record['complete']:
        record['api'] = P.pin(out / 'api.mjs')
    record['stdout'], record['stderr'] = P.pin(out / 'stdout'), P.pin(out / 'stderr')
    for row in record['inputs']:
        if P.pin(row['file']) != row:
            record['complete'] = False
            record['error'] = 'Input changed: ' + row['file']
    save()
    print(json.dumps(dict(complete=record['complete'], seconds=record['seconds'], out=str(out))))
    raise SystemExit(0 if record['complete'] else 1)


if __name__ == '__main__':
    main()
