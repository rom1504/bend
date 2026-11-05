#!/usr/bin/env python3
"""One guarded native self-emission: bound source/assets, hash complete stream.

No lowering, verification or IR interpretation happens in this transport.
The outer disk/process guard supplies the whole-process deadline and limits.
"""
import argparse
import hashlib
import json
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import clean_environment, fresh_output, pin, require, verify, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--build', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
build = json.loads(a.build.read_text())
require(build['complete'] and build['imageBinding']['protocol'] == 'qbe-source-v1',
        'Complete native compiler receipt required')
request = build['request']
image = build['binary']
require(build['imageBinding']['sourceIdentity'] == request['source'],
        'Successor must have the same compiler source')
inputs = [pin(__file__), pin(a.build), image, request['source'], request['base'],
          request['carrier'], build['runtime']]
for item in inputs:
    verify(item)
command = [image['file'], *request['command'][1:]]
out = fresh_output(a.out, ROOT)
report = dict(complete=False, inputs=inputs, command=command,
              expected=build['irDigest'], scope='Native compiler execution, complete '
              'source-to-QBE including output/teardown; excludes QBE, assembly and linking. '
              'Exact predecessor stream hash comparison is self-reproduction, not a proof.')
write_json(out / 'report.json', report)
start = time.perf_counter()
try:
    digest, size, first = hashlib.sha256(), 0, None
    with (out / 'compiler.stderr').open('xb') as error:
        process = subprocess.Popen(command, cwd=ROOT, env=clean_environment(),
                                   stdout=subprocess.PIPE, stderr=error)
        with process.stdout:
            while True:
                block = process.stdout.read(65536)
                if not block:
                    break
                if first is None:
                    first = time.perf_counter() - start
                size += len(block)
                digest.update(block)
        report['exitCode'] = process.wait()
    report.update(seconds=time.perf_counter() - start, firstBlockSeconds=first,
                  irDigest=dict(bytes=size, sha256=digest.hexdigest()),
                  stderr=pin(out / 'compiler.stderr'))
    require(report['exitCode'] == 0 and report['stderr']['bytes'] == 0,
            'Native self-emission failed')
    require(report['irDigest'] == report['expected'], 'Self-emission differs')
    for item in inputs:
        verify(item)
    report['complete'] = True
finally:
    report['observedSeconds'] = time.perf_counter() - start
    write_json(out / 'report.json', report)
    print(json.dumps({k: report.get(k) for k in
          ['complete', 'seconds', 'firstBlockSeconds', 'irDigest']}))
