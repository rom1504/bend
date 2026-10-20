#!/usr/bin/env python3
"""Bind actual Phase114 N1/N2 using the unchanged Phase113 transport gate."""
import argparse
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BINDING = HERE/'transport-binding01.json'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qualification-plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--tag', required=True)
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase114') or not re.fullmatch(r'p114-[a-z0-9_-]+', a.tag):
        raise ValueError('Fresh Phase114 manifest and lowercase p114- output tag required')
    binding = json.loads(BINDING.read_text())
    for row in binding['methods']:
        raw = (ROOT/row['file']).read_bytes()
        if len(raw) != row['bytes'] or hashlib.sha256(raw).hexdigest() != row['sha256']:
            raise ValueError('Frozen transport gate changed: '+row['file'])
    gate_path = ROOT/binding['methods'][0]['file']
    spec = importlib.util.spec_from_file_location('phase114_exact_transport_gate', gate_path)
    gate = importlib.util.module_from_spec(spec); spec.loader.exec_module(gate)
    base = out.with_name(out.stem+'-base.json')
    if base.exists(): raise ValueError('Fresh retained base manifest required')
    saved = sys.argv
    try:
        sys.argv = [str(gate_path), '--qualification-plan', str(a.qualification_plan.resolve()),
                    '--tag', 'p113-adapter-'+a.tag, '--out', str(base)]
        with contextlib.redirect_stdout(io.StringIO()): gate.main()
    finally:
        sys.argv = saved
    original = gate.read(base)
    manifest = json.loads(json.dumps(original))
    manifest['roles']['phase111']['generation'] = 'Phase114 N1 (B1 in this route); legacy phase111 role key.'
    manifest['roles']['phase112']['generation'] = 'Phase114 N2 (B2 in this route); legacy phase112 role key.'
    manifest['lineage']['comparison'] = 'Same selected Phase114 source, N1 versus N2 versus pinned upstream.'
    manifest['lineage']['roleKeys'] = dict(phase111='Phase114 N1', phase112='Phase114 N2', upstream='pinned TypeScript/Bun C compiler')
    manifest['inputs'] += [gate.m.pin(base), gate.m.pin(__file__), gate.m.pin(BINDING)]
    manifest['phase114Derivation'] = dict(kind='phase114-native-transport-label-adapter',
        baseManifest=gate.m.pin(base), method=gate.m.pin(__file__), binding=gate.m.pin(BINDING),
        unchanged='Original native source/image/QBE/build authentication and all three sources, complete output oracles, assets, upstream, runtime, tools, clocks, schedule, build policy and per-stage limits. Only role descriptions and Phase114 provenance are added.')
    for key in ['kind','cases','nativeAssets','runtime','tools','scope','timer','buildPolicy','limits']:
        if manifest[key] != original[key]: raise ValueError('Unexpected timing-method change: '+key)
    for row in gate.m.pins(manifest): gate.m.verify(row)
    target = ROOT/'selfhost/build/phase112'/a.tag
    if target.exists(): raise ValueError('Fresh transport result path required')
    out.write_text(json.dumps(manifest, indent=2)+'\n')
    command = [sys.executable, '-B', str(gate.TRANSPORT/'run.py'), '--manifest', str(out),
               '--out', str(target), '--rounds', '3', '--modes', 'cache']
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=gate.m.pin(out),
                         rootGuardJob=dict(name='native-generation-three-source-transport', seconds=120, command=command))))


if __name__ == '__main__': main()
