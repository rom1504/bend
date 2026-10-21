#!/usr/bin/env python3
"""Prepare the three fixed P114-012 cases through the original broad planner."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[5]
HERE = ROOT / 'selfhost/tools/performance/phase113/bench'
NAMES = ['raytrace', 'symreg', 'mandelbrot']


def pin(p):
    b = p.read_bytes()
    return dict(file=str(p.resolve()), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase114')
    spec = importlib.util.spec_from_file_location('phase114_original_broad', HERE / 'hosted45-v2.py')
    legacy = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(legacy)
    manifest_path = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
    manifest = json.loads(manifest_path.read_text())
    cases = {c['name']: c for c in manifest['cases']}
    assert len(cases) == 45
    manifest = dict(manifest, cases=[cases[n] for n in NAMES])
    base = out.with_name(out.stem + '-base.json')
    legacy.prepare(SimpleNamespace(api=ROOT / 'selfhost/build/phase111/p114-float-lanes-api01/api.mjs',
        runtime=ROOT / 'selfhost/build/phase113/runtime-products-build01/runtime.o',
        pipeline='array', tag='p113-p114-float-family01', reuse_reports=None, out=base), manifest)
    old = 'p113-p114-float-family01'
    new = 'p114-float-family01'
    r = json.loads(base.read_text().replace(old, new))
    oldmap = base.with_name(base.stem + '-reports.json')
    mapping = out.with_name(out.stem + '-reports.json')
    mapping.write_text(oldmap.read_text().replace(old, new))
    binding = out.with_name(out.stem + '-binding.json')
    r.update(kind='phase114-float-family-plan', reportsMap=pin(mapping),
             derivation=dict(base=pin(base), originalMapping=pin(oldmap), names=NAMES,
                             pathReplacement=[old, new], method=pin(Path(__file__)),
                             hypothesis=pin(ROOT / 'experiments/phase114/P114-012-float-family-extension.md')))
    runner = str(ROOT / 'selfhost/tools/performance/phase112/benchmark45/run.py')
    r['jobs'].extend([
        dict(name='bind', seconds=30, command=['python3', '-B', runner, 'bind', '--label', new,
             '--reports', str(mapping), '--out', str(binding), '--names', *NAMES]),
        dict(name='measure', seconds=180, command=['python3', '-B', runner, 'measure', '--bindings',
             str(ROOT / 'selfhost/build/phase114/final45-audit01-binding.json'), str(binding),
             '--profile', r['profile']['file'], '--names', *NAMES, '--rounds', '3', '--seconds', '30',
             '--budget-seconds', '300', '--out', str(ROOT / 'selfhost/build/phase112/p114-float-family01-measure')])])
    out.write_text(json.dumps(r, indent=2) + '\n')
    print(json.dumps(dict(plan=str(out), names=NAMES, jobs=len(r['jobs']))))


if __name__ == '__main__':
    main()
