#!/usr/bin/env python3
"""Build the optional generic native sampling collector under an external guard."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
from run import pin, save


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--cc', default='gcc')
    p.add_argument('--unwind-table', type=Path)
    a = p.parse_args()
    out = a.out.resolve()
    assert not out.exists()
    out.mkdir(parents=True)
    source = Path(__file__).with_name('sample.c').resolve()
    compiler = Path(shutil.which(a.cc)).resolve()
    snapshot = out/'sample.c'; snapshot.write_bytes(source.read_bytes())
    method = out/'method.py'; method.write_bytes(Path(__file__).read_bytes())
    command = [str(compiler), '-O2', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
               '-fPIC', '-shared', str(snapshot), '-o', str(out/'sampler.so'), '-pthread', '-lrt', '-ldl']
    report = dict(complete=False, inputs=[pin(source), pin(compiler), pin(__file__)], command=command)
    report['snapshots'] = [pin(snapshot), pin(method)]
    if a.unwind_table:
        table = a.unwind_table.resolve()
        header = table.with_name('unwind-table.h')
        report['inputs'].extend([pin(table), pin(header)])
        frozen_header = out/'unwind-table.h'; frozen_header.write_bytes(header.read_bytes())
        report['snapshots'].append(pin(frozen_header))
        command.insert(1, '-DBEND_PROFILE_UNWIND_TABLE="' + str(frozen_header) + '"')
    save(out/'report.json', report)
    start = time.monotonic()
    with (out/'stdout').open('x') as stdout, (out/'stderr').open('x') as stderr:
        child = subprocess.run(command, stdout=stdout, stderr=stderr, timeout=30)
    report.update(returncode=child.returncode, seconds=time.monotonic()-start,
                  stdout=pin(out/'stdout'), stderr=pin(out/'stderr'))
    if child.returncode == 0:
        report.update(complete=True, sampler=pin(out/'sampler.so'))
    save(out/'report.json', report)
    print(json.dumps(report))
    if not report['complete']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
