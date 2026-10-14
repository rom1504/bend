#!/usr/bin/env python3
"""Freeze reviewed self-check/fixed-point methods and commands, without targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase90'
TOOLS = ROOT/'selfhost/tools'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'
PARENT = ROOT/'selfhost/build/phase67/qualification-method01'
PARENT_SHA = '86d03731708c12a5ff76327dcfdab2ae1023673e60cae3d8d6490fdc729ac78c'


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(file, value):
    file.parent.mkdir(parents=True, exist_ok=True)
    with file.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2)+'\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['attempt', 'b2', 'out', 'qualification-out']:
        parser.add_argument('--'+name, required=True, type=Path)
    args = parser.parse_args()
    attempt_dir = args.attempt.resolve(strict=True)
    attempt_file = attempt_dir/'attempt.json'
    attempt = json.loads(attempt_file.read_text())
    validation_file = attempt_dir/'validation-001/report.json'
    validation = json.loads(validation_file.read_text())
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    assert attempt['node']['file'] == NODE
    assert pin(attempt['api']['file'])['sha256'] == attempt['api']['sha256']
    out, qualification = args.out.resolve(), args.qualification_out.resolve()
    for directory in (out, qualification):
        assert directory.parent == RAW and not directory.exists(), directory
    parent_manifest = pin(PARENT/'methods.json')
    assert parent_manifest['sha256'] == PARENT_SHA
    parents = {row['output']['file']: row['output'] for row in json.loads((PARENT/'methods.json').read_text())['methods']}
    methods = []
    for relative in ['bootstrap/setup.mjs', 'bootstrap/reproduce.mjs', 'qualification/self-check.mjs']:
        parent = PARENT/relative
        assert pin(parent)['sha256'] == parents[str(parent)]['sha256']
        text = parent.read_text()
        edits = []
        for before, after in [('selfhost/build/phase67', 'selfhost/build/phase90'), ('inside Phase67', 'inside Phase90')]:
            edits.append(dict(before=before, after=after, count=text.count(before)))
            text = text.replace(before, after)
        destination = out/relative
        write(destination, text)
        methods.append(dict(parent=pin(parent), output=pin(destination), edits=edits))
    pins_file = args.b2.resolve()/'image-pins.json'
    pins = dict(path=str(pins_file), exists=pins_file.exists())
    if pins_file.exists():
        value = json.loads(pins_file.read_text())
        assert value['kind'] == 'phase56-direct-image-pins'
        assert value['attempt']['sha256'] == pin(attempt_file)['sha256']
        assert value['b1']['sha256'] == attempt['api']['sha256']
        pins['identity'] = pin(pins_file)
    commands = []
    for name, script in [('self-check', out/'qualification/self-check.mjs'), ('fixed-point', out/'bootstrap/reproduce.mjs')]:
        command = ['python3', '-B', str(TOOLS/'performance/phase86/guard.py'),
                   '--out', str(qualification/('job-'+name)), '--seconds', '180',
                   '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--',
                   NODE, '--stack-size=4096', '--max-old-space-size=1024', str(script),
                   str(pins_file), str(qualification/name)]
        commands.append(dict(name=name, command=command))
    result = dict(kind='phase90-selfhosting-qualification-plan', dataOnly=True, targetsExecuted=False,
                  method=pin(__file__), attempt=pin(attempt_file), validation=pin(validation_file),
                  b2Pins=pins, parentMethods=parent_manifest, methods=methods,
                  qualification=str(qualification), commands=commands,
                  inputs=[pin(attempt_file), pin(validation_file), parent_manifest, pin(TOOLS/'performance/phase86/guard.py')],
                  scope='Same reviewed fresh own-source check and B2/B3 byte equality; only fresh output roots change. No release installation or native qualification is implied.')
    write(out/'plan.json', result)
    print(json.dumps(dict(plan=pin(out/'plan.json'), targetJobs=0)))


if __name__ == '__main__':
    main()
