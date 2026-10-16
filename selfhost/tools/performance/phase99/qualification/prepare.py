#!/usr/bin/env python3
"""Data-only exact recipe adapter and staged root command list; never runs targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import reuse


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--acquisition', type=Path, required=True, help='Prospective checked upstream acquisition report')
    p.add_argument('--reason', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(reuse.ROOT / 'selfhost/build/phase99') and not out.exists()
    b = reuse.support.Bindings(); ctx = reuse.baseline(b)
    source = b.bind(a.source); recipe_pin = b.bind(a.recipe); recipe = reuse.support.read(recipe_pin['file'])
    assert recipe['complete'] and b.bind(recipe['candidate']) == source
    original = Path(b.bind(recipe['source'])['file']).read_text(); replay = original
    for edit in recipe['changes']:
        at, old, new = edit['offset'], edit['old'], edit['new']
        assert isinstance(at, int) and at >= 0 and replay[at:at+len(old)] == old
        replay = replay[:at] + new + replay[at+len(old):]
    assert replay == a.source.read_text()
    for edit in reversed(recipe['changes']):
        at, old, new = edit['offset'], edit['old'], edit['new']
        assert replay[at:at+len(new)] == new
        replay = replay[:at] + old + replay[at+len(new):]
    assert replay == original
    assert reuse.support.entry_definitions(a.source.read_text()) == reuse.support.entry_definitions(Path(ctx['source']['file']).read_text())
    out.mkdir(parents=True)
    adapted = {**recipe, 'originalRecipe':recipe_pin, 'forwardReplayExact':True, 'inverseRecoversSource':True,
               'adapterMethod':reuse.support.pin(__file__)}
    normalized = out / 'recipe.json'; reuse.support.S.save(normalized, adapted)
    policy = out / 'policy'; policy_method = reuse.FROZEN / 'backend-policy.py'
    spec = importlib.util.spec_from_file_location('phase99_policy_prepare', policy_method)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    previous = sys.argv
    try:
        sys.argv = [str(policy_method), '--source', str(a.source.resolve()), '--recipe', str(normalized),
                    '--reason', a.reason, '--out', str(policy)]
        module.main()  # Frozen data-only source replay/oracle pinning; no API or native execution.
    finally:
        sys.argv = previous
    launcher = [sys.executable, '-B', str(reuse.HERE / 'reuse.py')]
    commands = []
    def job(name, mode, *args, gate=None):
        row = dict(name=name, command=[*launcher, mode, *map(str, args)])
        if gate: row['decisionBeforeExecution'] = gate
        commands.append(row)
    b1, b2 = out / 'b1/compiler', out / 'b2/compiler'
    b1r, b2r = out / 'b1.json', out / 'b2.json'
    source_path = source['file']; policy_path = policy / 'policy.json'
    reference = out / 'baseline-b2-reference/report.json'; self1 = out / 'b1-self/report.json'
    b1reference = out / 'baseline-b1-reference/report.json'
    job('build-b1', 'build', '--emission-receipt', a.acquisition.resolve(), '--binary', b1, '--out', out / 'b1-build',
        gate='Only after exact-source small controls, mechanism and benefit gates justify a full image; acquisition must already be complete.')
    job('bind-b1', 'bind', '--stage', 'b1', '--binary', b1, '--source', source_path,
        '--emission-receipt', a.acquisition.resolve(), '--build-guard', out / 'b1-build', '--out', b1r)
    job('screen-b1', 'compare', '--stage', 'b1', '--b1-build', b1r, '--backend-policy', policy_path, '--out', out / 'b1-screen')
    job('reference-current-b2', 'request', '--baseline', 'b2', '--source', source_path, '--purpose', 'reference',
        '--out', reference.parent, gate='Review B1 screen and changed-C controls before full-self work.')
    job('self-b1', 'request', '--stage', 'b1', '--binary', b1, '--compiler-source', source_path, '--build-receipt', b1r,
        '--source', source_path, '--purpose', 'changed-backend', '--backend-policy', policy_path,
        '--oracle-report', reference, '--out', self1.parent)
    job('reference-current-b1', 'request', '--baseline', 'b1', '--source', source_path, '--purpose', 'reference', '--out', b1reference.parent)
    job('pairs-b1-self', 'compare', '--stage', 'b1', '--mode', 'self', '--b1-build', b1r, '--backend-policy', policy_path,
        '--baseline-self-reference', b1reference, '--candidate-self-reference', self1, '--out', out / 'b1-self-pairs')
    job('build-b2', 'build', '--emission-receipt', self1, '--binary', b2, '--out', out / 'b2-build',
        gate='Only after measured benefit and B1 semantics justify integration; this is a new native image build.')
    job('bind-b2', 'bind', '--stage', 'b2', '--binary', b2, '--source', source_path, '--emission-receipt', self1,
        '--build-guard', out / 'b2-build', '--out', b2r)
    job('self-b2', 'request', '--stage', 'b2', '--binary', b2, '--compiler-source', source_path, '--build-receipt', b2r,
        '--source', source_path, '--purpose', 'compare', '--backend-policy', policy_path, '--oracle-report', self1, '--out', out / 'b2-self')
    for mode in ['screen', 'self']:
        extra = ['--baseline-self-reference', reference, '--candidate-self-reference', self1] if mode == 'self' else []
        job('compare-b2-' + mode, 'compare', '--stage', 'b2', '--mode', mode, '--b1-build', b1r, '--b2-build', b2r,
            '--backend-policy', policy_path, *extra, '--out', out / ('b2-' + mode + ('-pairs' if mode == 'self' else '')))
    for suite in ['controls', 'broad45']:
        job(suite, 'backend-gates', '--b1-build', b1r, '--b2-build', b2r, '--backend-policy', policy_path,
            '--suite', suite, '--out', out / suite)
    conform = out / 'conformance'
    job('prepare-conformance', 'conformance', '--b1-build', b1r, '--b2-build', b2r, '--backend-policy', policy_path, '--out', conform)
    integrity = [sys.executable, '-B', str(reuse.FROZEN / 'conformance_integrity.py')]
    for role in ['b1', 'b2', 'diagnostics']:
        commands.append(dict(name='conformance-' + role, command=[*integrity, 'run', '--plan', str(conform / 'plan.json'), '--role', role]))
    commands.append(dict(name='collect-conformance', command=[*integrity, 'collect', '--plan', str(conform / 'plan.json'), '--out', str(conform / 'collected.json')]))
    b.unchanged()
    reuse.support.S.save(out / 'commands.json', dict(complete=True, targetsRun=False, source=source,
        baseline=ctx['baselineAdmission'], recipe=reuse.support.pin(normalized), policy=reuse.support.pin(policy_path),
        acquisition=str(a.acquisition.resolve()), commands=commands,
        scope='Prepared staged commands only. Root executes serially. No automatic run-all, admission or installed selection change.'))
    print(json.dumps(dict(complete=True, targetsRun=False, source=source, commands=str(out / 'commands.json'))))


if __name__ == '__main__': main()
