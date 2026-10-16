#!/usr/bin/env python3
"""Prepare candidate-parameterized release commands/source transport; no target runs."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import zipfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
NATIVE = ROOT / 'selfhost/tools/native'


def pin(path):
    path = Path(path).resolve(strict=True); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def check(record):
    actual = pin(ROOT / record['file'])
    assert all(actual[k] == record[k] for k in ['sha256', 'bytes'])
    return actual


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as stream: json.dump(value, stream, indent=2); stream.write('\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__); sub = parser.add_subparsers(dest='mode', required=True)
    plan = sub.add_parser('plan')
    for key in ['qualification', 'source', 'recipe', 'backend-controls', 'out', 'public-assets']:
        plan.add_argument('--' + key, type=Path, required=True)
    plan.add_argument('--baseline-capsule', type=Path, default=NATIVE / 'releases/phase98-assets02/receipt.json')
    selection = sub.add_parser('selection')
    selection.add_argument('--admission', type=Path, required=True); selection.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    if args.mode == 'selection':
        admission_pin = pin(args.admission); admission = json.loads(args.admission.read_text())
        assert admission['complete'] and admission['qualified'] and admission['inputsUnchanged']
        assert admission['kind'] == 'phase98-native-candidate-qualification' and admission['defaultSelection'] is False
        save(out, dict(kind='bend-native-compiler-selection', version=1, complete=True, admission=admission_pin, defaultStage='b2'))
        spec = importlib.util.spec_from_file_location('phase99_staged_selection', NATIVE / 'launch.py')
        module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
        for stage in ['b1', 'b2']: module.load(out, stage=stage)
        print(json.dumps(dict(complete=True, targetsRun=False, selection=pin(out), installed=False))); return
    q = args.qualification.resolve(); source = pin(args.source); recipe_pin = pin(args.recipe)
    recipe = json.loads(args.recipe.read_text()); assert recipe['complete'] and check(recipe['candidate']) == source
    initial = check(recipe['source']); original = Path(initial['file']).read_text(); text = original
    for row in recipe['changes']:
        at, old, new = row['offset'], row['old'], row['new']
        assert isinstance(at, int) and 0 <= at <= len(text) and text[at:at+len(old)] == old
        text = text[:at] + new + text[at+len(old):]
    assert text == Path(source['file']).read_text()
    for row in reversed(recipe['changes']):
        at, old, new = row['offset'], row['old'], row['new']; assert text[at:at+len(new)] == new
        text = text[:at] + old + text[at+len(new):]
    assert text == original
    baseline = json.loads((HERE.parent / 'qualification/baseline.json').read_text()); assert initial == baseline['source']
    policy = q / 'policy/policy.json'; assert json.loads(policy.read_text())['source'] == source
    capsule_pin = pin(args.baseline_capsule); capsule = json.loads(args.baseline_capsule.read_text())
    assert capsule['complete'] and capsule['kind'] == 'bend-native-public-assets-capsule'
    for key in ['archive', 'manifest']: check(capsule[key])
    public = args.public_assets.resolve(); assert public.is_relative_to(NATIVE) and not public.exists()
    out.mkdir(parents=True)
    payload = (json.dumps(recipe['changes'], indent=2) + '\n').encode(); delta = out / 'changes.zip'
    with zipfile.ZipFile(delta, 'x', compression=zipfile.ZIP_DEFLATED) as saved: saved.writestr('changes.json', payload)
    relative = lambda record: {**record, 'file':str(Path(record['file']).relative_to(ROOT))}
    profile = dict(kind='bend-native-exact-source-profile', version=1, source=relative(initial),
        candidate={key:source[key] for key in ['sha256', 'bytes']},
        baselineCapsule={**{key:capsule[key] for key in ['archive', 'manifest']}, 'receipt':relative(capsule_pin)},
        delta=relative(pin(delta)), deltaPayload=dict(sha256=hashlib.sha256(payload).hexdigest(), bytes=len(payload)),
        changeCount=len(recipe['changes']), physicalLineDelta=len(Path(source['file']).read_text().splitlines())-len(original.splitlines()),
        originRecipe=recipe_pin, scope='Exact source transport; no image qualification or speed claim.')
    save(out / 'profile.json', profile)
    commands = []
    def job(name, script, *argv, target=False, requires=None):
        commands.append(dict(name=name, command=[sys.executable, '-B', str(script), *map(str, argv)], targetExecution=target,
                             requires=requires or []))
    replay = out / 'profile-replay.json'; backend = args.backend_controls.resolve(); admission = out / 'admission.json'
    job('source-replay', NATIVE / 'profile.py', '--profile', out / 'profile.json', '--verify-source', source['file'], '--receipt', replay)
    common = ['--b1-build', q / 'b1.json', '--b2-build', q / 'b2.json', '--backend-policy', policy]
    job('final-five', HERE / 'reuse.py', 'final-controls', *common, '--backend-controls', backend, '--out', out / 'final-five',
        target=True, requires=['Exact-source backend-specific controls, including new final-image borrowed-call evidence'])
    job('runtime-continuity', HERE / 'reuse.py', 'batch-continuity', 'emit', '--plan', ROOT / 'selfhost/build/phase98/batch-continuity-plan01/plan.json',
        '--b2-build', q / 'b2.json', '--backend-policy', policy, '--out', out / 'runtime-continuity', target=True,
        requires=['Selected source passed benefit and semantic gates; changed C requires matched runtime measurements'])
    job('admission', HERE / 'reuse.py', 'admit', *common, '--b1-self', q / 'b1-self/report.json', '--b2-self', q / 'b2-self/report.json',
        '--source-recipe', replay, '--conformance', q / 'conformance/collected.json', '--controls', q / 'controls/report.json',
        '--broad45', q / 'broad45/report.json', '--backend-controls', backend, '--final-controls', out / 'final-five/report.json', '--out', admission,
        requires=['Completed exact-source qualification and backend-specific receipt; no superseded-source evidence'])
    pointer = out / 'selection.json'
    job('staged-selection', __file__, 'selection', '--admission', admission, '--out', pointer)
    job('public-cli', HERE / 'cli-controls.py', pointer, q / 'controls/report.json', out / 'public-cli', target=True)
    job('public-assets', NATIVE / 'assets.py', 'seal', pointer, public, requires=['Nine public CLI controls passed'])
    job('verify-public-assets', NATIVE / 'assets.py', 'restore', public / 'receipt.json', '--verify-only')
    save(out / 'commands.json', dict(complete=True, targetsRun=False, installed=False, source=source, recipe=recipe_pin,
        method=pin(__file__), policy=pin(policy), qualification=str(q), backendControls=str(backend), commands=commands,
        scope='Prepared serial steps only. Backend-specific evidence and performance promotion decision remain prerequisites; installed selection is untouched.'))
    print(json.dumps(dict(complete=True, targetsRun=False, installed=False, commands=str(out / 'commands.json'))))


if __name__ == '__main__': main()
