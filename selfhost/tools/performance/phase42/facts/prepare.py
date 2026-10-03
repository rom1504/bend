#!/usr/bin/env python3
"""Prepare a fresh normal-request CPU capture; execute no compiler."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('request', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
request_file = a.request.resolve()
out = a.out.resolve()
request = json.loads(request_file.read_text())
assert not request['typescript'], 'Use a checked Bend request'
assert not out.exists(), 'Preserve every attempt'
out.mkdir(parents=True)
root = Path(__file__).resolve().parents[5]
worker = root / 'selfhost/tools/performance/phase30/library-cost-worker.mjs'
node = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
assert worker.is_file() and node.is_file()
request['output'] = str(out / 'emission.mjs')
fresh = out / 'request.json'
fresh.write_text(json.dumps(request, indent=2) + '\n')
command = ['taskset', '-c', '3', str(node), '--stack-size=4096',
           '--max-old-space-size=1024', '--cpu-prof',
           '--cpu-prof-dir=' + str(out), '--cpu-prof-name=compiler.cpuprofile',
           str(worker), str(fresh), str(out / 'result.json')]
identity = lambda f: dict(file=str(f), sha256=hashlib.sha256(f.read_bytes()).hexdigest())
manifest = dict(kind='phase42-facts-profile-preparation', executed=False,
                inputs=[identity(request_file), identity(worker), identity(node), identity(Path(__file__).resolve())],
                command=command, scope='One normal checked library request. CPU capture includes preflight/import/postflight; requestMs is the maintained worker boundary. Not a timing comparison.')
(out / 'preparation.json').write_text(json.dumps(manifest, indent=2) + '\n')
(out / 'command.sh').write_text(shlex.join(command) + '\n')
print(shlex.join(command))
