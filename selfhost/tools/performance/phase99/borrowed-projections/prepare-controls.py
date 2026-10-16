#!/usr/bin/env python3
"""Data-only plan for three focused aggregate controls, reusing existing emitter."""
import hashlib
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'selfhost/build/phase99/borrowed-projections-controls01'
def pin(file):
    file = file.resolve(); data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
def write(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')
OUT.mkdir(exist_ok=False)
prior = ROOT / 'selfhost/build/phase99/borrowed-projections-probe02'
plan = json.loads((prior / 'plan.json').read_text())
plan['method'] = pin(Path(__file__))
rows = [
    ('aggregate-alias', 'p99_pair_equal', ['p99_pair_escape', 'p99_pair_dump'],
     '1\n1\nowned-child\nλ🙂alias\nλ🙂alias\n43\nλ🙂alias\n'),
    ('opaque-applied', 'p99_opaque_stamp', ['p99_opaque_read', 'p99_opaque_count', 'p99_opaque_escape'],
     '73\n0\n61\npayloadλ🙂\nsecond\nnames-end\npayloadλ🙂\nsecond\nnames-end\n61\n67\ncounts-end\n73\npayloadλ🙂\nsecond\nnames-end\n61\n67\ncounts-end\n'),
    ('opaque-mutable', 'p99_mutable_stamp', ['p99_mutable_swap', 'p99_mutable_escape', 'p99_mutable_effect'],
     '47\n106\n7\neffect-once\n'),
]
plan['controls'] = [dict(id=name, source=pin(HERE / 'controls' / (name + '.bend')),
    stdout=stdout, stderr='', scalar=1, observerOwner=owner, forbiddenOwners=forbidden)
    for name, owner, forbidden, stdout in rows]
plan['scope'] = ('Three focused aggregate-boundary controls only: aliased descendants plus owning String escape; '
                 'opaque List instantiations plus scalar marker; opaque Array mutation/escape and IO effect refusal. '
                 'Each refusal program still executes through its owning route and prints exact values. '
                 'The existing emitter retains its permission/raw checks. No new framework, compiler image, or release action.')
write('plan.json', plan)
commands = json.loads((prior / 'commands.json').read_text())
commands[0]['argv'][-2:] = [str(OUT / 'plan.json'), str(OUT / 'emission')]
write('commands.json', commands)
print(json.dumps({'plan':pin(OUT / 'plan.json'), 'commands':pin(OUT / 'commands.json')}, indent=2))
