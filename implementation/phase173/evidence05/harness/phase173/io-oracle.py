#!/usr/bin/env python3
"""Run a pinned upstream IO program and compare its complete expected trace."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', type=Path, required=True)
p.add_argument('--expected', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--upstream', type=Path, required=True)
p.add_argument('--engine', type=Path, required=True)
a = p.parse_args()
up = a.upstream.resolve(strict=True) / 'bend2'
engine = a.engine.resolve(strict=True)
source = a.source.resolve(strict=True)
out = fresh_output(a.out, ROOT)
inputs = [pin(__file__), pin(source), pin(a.expected), pin(engine)]
inputs += [pin(up / name) for name in ['main.ts', 'bend.ts', 'comp.ts', 'safe.ts', 'base.bend']]
inputs += [pin(f) for f in sorted((up / 'effs').rglob('*')) if f.is_file()]
for item in inputs:
    verify(item)
command = [str(engine), str(up / 'main.ts'), str(source)]
env = {k: v for k, v in os.environ.items()
       if not k.startswith('BEND_') and k not in ['LD_PRELOAD', 'LD_AUDIT']}
env['BEND_NO_TELEMETRY'] = '1'
report = dict(kind='phase173-independent-io-trace', complete=False, inputs=inputs,
              command=command, scope='Pinned upstream source check and ordinary IO execution; exact complete stdout, not a mathematical proof.')
write_json(out / 'report.json', report)
try:
    result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=20)
    (out / 'stdout').write_bytes(result.stdout)
    (out / 'stderr').write_bytes(result.stderr)
    report.update(exitCode=result.returncode, stdout=pin(out / 'stdout'), stderr=pin(out / 'stderr'))
    require(result.returncode == 0 and not result.stderr, 'Upstream IO execution failed')
    require(result.stdout == a.expected.read_bytes(), 'Upstream complete trace differs')
    for item in inputs:
        verify(item)
    report.update(complete=True, outputExact=True)
except Exception as error:
    report['error'] = str(error)
    raise
finally:
    write_json(out / 'report.json', report)
