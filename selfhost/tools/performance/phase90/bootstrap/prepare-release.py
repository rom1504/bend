#!/usr/bin/env python3
"""Prepare actual B2 installation and smoke commands only after self-host gates."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT/'selfhost'
TOOLS = PROJECT/'tools'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def checked(record):
    actual = pin(record['file'])
    assert actual['sha256'] == record['sha256'], actual['file']
    if 'bytes' in record:
        assert actual['bytes'] == record['bytes']
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['attempt', 'b2', 'qualification', 'out', 'cc', 'cpath']:
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    attempt_dir, b2 = args.attempt.resolve(strict=True), args.b2.resolve(strict=True)
    qualification, cc, cpath = (p.resolve(strict=True) for p in [args.qualification, args.cc, args.cpath])
    out = args.out.resolve()
    assert out.parent == ROOT/'selfhost/build/phase90' and not out.exists()
    attempt_file, pins_file = attempt_dir/'attempt.json', b2/'image-pins.json'
    attempt, pins = (json.loads(p.read_text()) for p in [attempt_file, pins_file])
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    assert pins['kind'] == 'phase56-direct-image-pins'
    assert checked(pins['attempt'])['sha256'] == pin(attempt_file)['sha256']
    assert checked(pins['b1'])['sha256'] == checked(attempt['api'])['sha256']
    image, source, runtime = (checked(pins[key]) for key in ['b2', 'source', 'runtime'])
    gates = []
    for name, kind in [('self-check', 'phase56-b2-fresh-own-source-check'), ('fixed-point', 'phase56-direct-self-emission-v2')]:
        file = qualification/name/'report.json'
        report = json.loads(file.read_text())
        assert report['kind'] == kind and report['complete'] and report['pass']
        assert report['subject']['source']['sha256'] == source['sha256']
        assert report['subject']['attempt']['sha256'] == pin(attempt_file)['sha256']
        if name == 'self-check':
            assert report['freshTypeCheck'] and report['expectedProofTrustFailure'] and not report['mathematicalProof']
            assert report['image']['sha256'] == image['sha256']
        else:
            assert report['byteEquality'] and checked(report['b3'])['sha256'] == image['sha256']
            assert report['b2']['sha256'] == image['sha256']
        gates.append(pin(file))
    assert attempt['node']['file'] == NODE
    checked(attempt['node'])
    packaging = TOOLS/'development/release.mjs'
    environment = dict(CC=str(cc), CPATH=str(cpath), NODE_OPTIONS='', NODE_PATH='')
    jobs = [
        ('install', packaging, ['--install-b2', str(attempt_dir), str(pins_file), str(qualification)]),
        ('verify-before', packaging, ['--verify']),
        ('legacy42', TOOLS/'performance/phase77/legacy-release-smoke-launch-v1.mjs', [str(PROJECT), str(out/'legacy42'), image['sha256']]),
        ('default24', TOOLS/'performance/phase66/release/default-release-smoke-v1.mjs', [str(PROJECT), str(out/'default24'), image['sha256'], source['sha256'], runtime['sha256']]),
        ('verify-after', packaging, ['--verify']),
    ]
    commands = []
    for name, script, arguments in jobs:
        command = ['python3', '-B', str(TOOLS/'performance/phase86/guard.py'), '--out', str(out/('job-'+name)),
                   '--seconds', '180', '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--',
                   'env', *[k+'='+v for k,v in environment.items()], NODE, '--stack-size=4096',
                   '--max-old-space-size=1024', str(script), *arguments]
        commands.append(dict(name=name, command=command))
    previous_file = PROJECT/'dist/release.json'
    previous = json.loads(previous_file.read_text())
    prior_artifacts = [pin(previous_file)]
    for record in previous['files']:
        actual = pin(PROJECT/record['path'])
        assert actual['sha256'] == record['sha256'] and actual['bytes'] == record['bytes']
        prior_artifacts.append(actual)
    out.mkdir()
    result = dict(kind='phase90-qualified-b2-deferred-release-plan', dataOnly=True, targetsExecuted=False,
                  producer=pin(__file__), attempt=pin(attempt_file), imagePins=pin(pins_file), api=image,
                  gates=gates, oldReleaseArtifacts=prior_artifacts, environment=environment,
                  commands=commands, inputs=[pin(cc), pin(NODE), pin(packaging), *[pin(s) for _,s,_ in jobs]],
                  requires=['Root reviews focused native/static-image correctness and JS performance continuity before selecting promotion.',
                            'Current production modules and host must still match the checked attempt; real installer verifies this.',
                            'Run these commands sequentially, stop on any failure; actual installation is a separate root action.'],
                  scope='Selects genuine self-emitted B2 with original checked B1 lineage and fresh self-hosting gates. No manifest-only source rebind; no native image admission; no full-language conformance or speed claim.')
    target = out/'plan.json'
    target.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(plan=pin(target), targetsExecuted=False)))


if __name__ == '__main__':
    main()
