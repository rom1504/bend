#!/usr/bin/env python3
"""Bind the maintained native fixture runner to one frozen image; no targets."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(value):
    expected = value if isinstance(value, dict) else None
    path = Path(expected.get('file', expected.get('path')) if expected else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256'], path
        if 'bytes' in expected:
            assert result['bytes'] == expected['bytes'], path
    return result


def write(path, value):
    with path.open('x') as stream:
        stream.write(json.dumps(value, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['attempt', 'toolchain-recipe', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    out = args.out.resolve()
    out.relative_to(ROOT / 'selfhost/build/phase68')
    assert not out.exists()
    attempt_pin = pin(args.attempt / 'attempt.json')
    attempt = json.loads(Path(attempt_pin['file']).read_text())
    assert attempt['checked'] and attempt['config']['strictExact']
    assert str(attempt['config']['cpu']) == '3' and attempt['config']['jobs'] == 1
    snapshot = Path(attempt['snapshot']['root']).resolve(strict=True)
    snapshot.relative_to(ROOT / 'selfhost/build/phase68')
    inputs = [pin(__file__), attempt_pin]
    inputs += [pin(attempt[k]) for k in ['api', 'checkedApi', 'base', 'runtime', 'node']]
    inputs += [pin(row['frozen']) for row in attempt['snapshot']['sources']]
    recipe_pin = pin(args.toolchain_recipe)
    recipe = json.loads(Path(recipe_pin['file']).read_text())
    assert recipe['kind'] == 'phase67-native-method-v2' and recipe['api'] == attempt['api']['file']
    inputs += [recipe_pin, *[pin(row) for row in recipe['inputs']]]
    assert recipe['clangArgs'][0] == '-isystem'
    upstream = Path(attempt['config']['upstream']).resolve(strict=True)
    names = ['reg/array_clone_boxed', 'run/fork_shared_flat', 'run/nat_overflow', 'compile/bang_intrinsic_closure']
    inputs += [pin(upstream / 'tests' / (name + '.bend')) for name in names]
    parent = snapshot / 'src/back/native/fixtures.mjs'
    source = parent.read_text()
    # The same three isolation substitutions used by Phase67 prepare-focused-v3,
    # plus explicit GPU-off so this gate cannot silently exercise a device.
    edits = [
        ("from '../../../tools/typed-driver.mjs';", 'from ' + json.dumps((snapshot / 'tools/typed-driver.mjs').as_uri()) + ';'),
        ("const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../..');", 'const root=' + json.dumps(str(snapshot)) + ';'),
        ("const output=path.join(root,'build/native-fixtures');", 'const output=' + json.dumps(str(out / 'execution')) + ';'),
        ("['--threads',String(threads)]", "['--threads',String(threads),'--gpu','off']"),
    ]
    for before, after in edits:
        assert source.count(before) == 1, before
        source = source.replace(before, after)
    out.mkdir(parents=True)
    runner = out / 'threads-fixtures.mjs'
    runner.write_text(source)
    derivation = out / 'threads-derivation.json'
    write(derivation, dict(parent=pin(parent), output=pin(runner), edits=[dict(before=a, after=b, count=1) for a, b in edits]))
    guard = ROOT / 'selfhost/tools/performance/phase32/bounded-run.py'
    inputs += [pin(parent), pin(runner), pin(derivation), pin(guard)]
    env = {'CC': recipe['clang'], 'CPATH': recipe['clangArgs'][1], 'BEND_UPSTREAM': str(upstream), 'BEND_BASE': attempt['base']['file'], 'BEND_TYPED_API': attempt['api']['file'], 'BEND_TYPED_RUNTIME': attempt['runtime']['file'], 'BEND_TYPED_TRACE': '', 'NODE_OPTIONS': '', 'NODE_PATH': ''}
    command = ['python3', '-B', str(guard), '--seconds', '240', '--rss-mib', '2048', '--available-mib', '4096', str(out / 'supervisor'), '--', 'taskset', '-c', '3', 'env', *[k + '=' + v for k, v in env.items()], attempt['node']['file'], '--max-old-space-size=1024', '--stack-size=4096', str(runner), *names]
    for item in inputs:
        pin(item)
    write(out / 'plan.json', dict(kind='phase68-native-thread-controls-plan', targetExecuted=False, attempt=attempt_pin, selectedApi=pin(attempt['api']), toolchainRecipe=recipe_pin, fixtures=names, threads=[1, 4], gpu='off', command=command, report=str(out / 'execution/report.json'), inputs=inputs, scope='Four existing independent native fixture goldens at one and four CPU threads through the unchanged maintained runner, isolated to the selected snapshot. No GPU, arbitrary scheduling, performance, or full native conformance claim.'))
    print(json.dumps(pin(out / 'plan.json')))


if __name__ == '__main__':
    main()
