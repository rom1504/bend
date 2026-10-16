#!/usr/bin/env python3
"""Reuse frozen Phase98 qualification with the explicitly frozen Phase98 baseline."""
import copy
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
FROZEN = ROOT / 'selfhost/build/phase98/qualification-methods17/methods'
sys.path.insert(0, str(FROZEN))
import support

original_baseline = support.baseline
original_freeze = support.freeze_methods


def baseline(bindings):
    # Historical authentication supplies the unchanged toolchain/request assets,
    # never the performance producer selected below.
    ctx = original_baseline(bindings)
    manifest = support.read(bindings.bind(HERE / 'baseline.json')['file'])
    admission_pin = bindings.bind(manifest['admission'])
    admission = support.read(admission_pin['file'])
    assert admission['complete'] and admission['qualified'] and admission['inputsUnchanged']
    assert admission['source'] == manifest['source']
    bindings.bind(admission['source'])
    # Pin the completed qualification receipt; authenticate selected builds and
    # execution assets below, without replaying every historical test artifact.
    for name in ['base', 'runtime', 'template', 'parts', 'effects']:
        assert admission['assets'][name] == ctx['roles']['b2']['admission'][name]
    for name in ['carrier', 'stamp']:
        assert admission['assets']['cache'][name] == ctx['roles']['b2']['admission']['cache'][name]
    for stage in ['b1', 'b2']:
        current = admission['stages'][stage]
        assert current['source'] == admission['source']
        assert current['build'] == manifest['builds'][stage]
        bound = support.authenticate(current['binary'], stage, current['source'], current['build'], bindings, ctx)
        assert bound['binary'] == current['binary'] and bound['c'] == current['c']
        assets = copy.deepcopy(ctx['roles'][stage]['admission'])
        assets.update(source=current['source'], binary=current['binary'], c=current['c'], build=current['build'])
        ctx['roles'][stage] = dict(admission=assets, argvSentinel=False if stage == 'b1' else 'phase90-native',
                                   producer=current['producer'])
    ctx.update(source=admission['source'], build=manifest['builds']['b1'],
               kind='phase99-frozen-phase98-baseline', baselineAdmission=admission_pin)
    for file in sorted(HERE.iterdir()):
        if file.is_file(): bindings.bind(file)
    return ctx


def freeze(out, bindings):
    original_freeze(out, bindings)
    for file in sorted(HERE.iterdir()):
        if file.is_file():
            bindings.bind(file)
            target = out / 'methods/phase99' / file.name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(file.read_bytes())
            bindings.bind(target)


support.baseline = baseline
support.freeze_methods = freeze


def main():
    names = ['bind', 'build', 'request', 'backend-policy', 'backend-gates', 'conformance', 'compare']
    assert len(sys.argv) > 1 and sys.argv[1] in names + ['verify'], names
    name = sys.argv.pop(1)
    if name == 'verify':
        b = support.Bindings(); ctx = baseline(b); b.unchanged()
        print(json.dumps(dict(complete=True, targetsRun=False, source=ctx['source'],
            stages={s:support.baseline_producer(ctx, s) for s in ['b1', 'b2']}, inputs=len(b.rows))))
        return
    path = (HERE if name == 'compare' else FROZEN) / (name + '.py')
    spec = importlib.util.spec_from_file_location('phase99_reused_' + name.replace('-', '_'), path)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    module.main()


if __name__ == '__main__': main()
