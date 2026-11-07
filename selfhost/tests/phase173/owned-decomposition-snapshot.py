#!/usr/bin/env python3
"""Freeze the Packet workload and replace only main for the timing workload.

Source transport only: no checking, optimization, compiler or target execution.
"""
import argparse
import hashlib
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly
from common import fresh_output, pin, require, verify, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--workload', type=Path, required=True)
p.add_argument('--digest-main', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = [pin(__file__), pin(assembly.__file__), pin(a.workload), pin(a.digest_main)]
full, replacement = a.workload.read_bytes(), a.digest_main.read_bytes()
require(len(full) <= 65536 and len(replacement) <= 4096, 'Bounded source inputs')
prefix, rows = assembly.blocks(full)
extra, mains = assembly.blocks(replacement)
require(not extra.strip(), 'Digest module must contain only main')
require(len(mains) == 1 and mains[0]['kind'] == 'def' and mains[0]['name'] == 'main',
        'Exactly one replacement main required')
require(b'import Base' in prefix.splitlines(), 'Standalone imported Base required')
require(len({(r['kind'], r['name']) for r in rows}) == len(rows), 'Duplicate source declarations')
old_mains = [r for r in rows if r['name'] == 'main']
require(len(old_mains) == 1 and old_mains[0]['kind'] == 'def', 'Exactly one workload main required')
require(any(r['kind'] == 'type' and r['name'] == 'P173OwnedPacket' for r in rows),
        'Explicit Packet source schema required')
digest = prefix + b''.join(mains[0]['data'] if r['name'] == 'main' else r['data'] for r in rows)
_, after = assembly.blocks(digest)
before_kept = [(r['kind'], r['name'], r['data']) for r in rows if r['name'] != 'main']
after_kept = [(r['kind'], r['name'], r['data']) for r in after if r['name'] != 'main']
require(before_kept == after_kept, 'Non-main source bytes must remain exact')
out = fresh_output(a.out, ROOT)
(out / 'full.bend').write_bytes(full)
(out / 'digest.bend').write_bytes(digest)
for item in inputs:
    verify(item)
write_json(out / 'report.json', dict(
    kind='phase173-owned-packet-source-snapshot', version=1, complete=True,
    targetsRun=False, inputs=inputs, full=pin(out / 'full.bend'), digest=pin(out / 'digest.bend'),
    unchangedDeclarations=[dict(kind=kind, name=name, bytes=len(data),
        sha256=hashlib.sha256(data).hexdigest()) for kind, name, data in before_kept],
    originalMainSha256=hashlib.sha256(old_mains[0]['data']).hexdigest(),
    digestMainSha256=hashlib.sha256(mains[0]['data']).hexdigest(),
    scope='Full workload byte-identical; digest replaces only main. Source checking, independent upstream observation and native correctness are separate gates.'))
print(pin(out / 'report.json'))
