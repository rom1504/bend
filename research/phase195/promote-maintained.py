#!/usr/bin/env python3
"""Plan or apply the qualified Phase195 maintained-source copy; never install images."""
from pathlib import Path
import argparse
import fcntl
import importlib.util
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[2]
BASELINE = '8230a06ef060d4e4b5eb375e1ce29c89b26f1bee'
BUILD = ROOT / 'selfhost/build/phase195'
LIVE = ROOT / 'selfhost'
STAGE = BUILD / 'selected-source02/maintained'
spec = importlib.util.spec_from_file_location('source', LIVE / 'tools/build/source.py')
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)

def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])

def check():
    assert git('rev-parse', 'HEAD').decode().strip() == BASELINE, 'Baseline HEAD moved'
    changes = json.loads((BUILD / 'selected-source02/changed-files.json').read_text())['files']
    audit = json.loads((ROOT / 'research/phase195/maintained-integration-audit.json').read_text())
    assert audit['complete'] and audit['exactExecutableBodiesIdentical']
    assert s.pin(STAGE / 'src/compiler.json') == audit['stagedManifest']
    selected = BUILD / 'selected-source02/compiler.bend'
    assert s.pin(selected) == audit['selectedSource']
    assembled = s.maintained_assemble(STAGE / 'src/compiler.json', STAGE, 'x86')
    assert assembled == selected.read_bytes(), 'Staged source changed'
    rows, states = [], []
    for row in changes:
        relative = row['file']
        candidate = (STAGE / relative).read_bytes()
        assert s.digest(candidate) == row['sha256'] and len(candidate) == row['afterBytes']
        historical = subprocess.run(['git', '-C', str(ROOT), 'show', BASELINE + ':selfhost/' + relative], capture_output=True)
        baseline = historical.stdout if historical.returncode == 0 else None
        assert (len(baseline) if baseline is not None else 0) == row['beforeBytes']
        actual = (LIVE / relative).read_bytes() if (LIVE / relative).exists() else None
        state = 'baseline' if actual == baseline else 'selected' if actual == candidate else 'unexpected'
        assert state != 'unexpected', 'Live source is neither HEAD baseline nor selected: ' + relative
        states.append(state)
        rows.append({'file': relative, 'state': state,
                     'baselineSha256': s.digest(baseline) if baseline is not None else None,
                     'selectedSha256': s.digest(candidate), 'selectedBytes': len(candidate)})
    assert len(set(states)) == 1, 'Mixed partial promotion; inspect before proceeding'
    changed = {row['file'] for row in changes}
    for p in (STAGE / 'src').rglob('*'):
        if p.is_file() and str(p.relative_to(STAGE)) not in changed:
            assert p.read_bytes() == (LIVE / p.relative_to(STAGE)).read_bytes(), 'Unrelated maintained source changed'
    profiles = {}
    for profile in ['qbe', 'native-c', 'js-api', 'qbe-policy', 'qbe-policy-test']:
        old, old_map = s.maintained_assemble(LIVE / 'src/compiler.json', LIVE, profile, with_map=True)
        new, new_map = s.maintained_assemble(STAGE / 'src/compiler.json', STAGE, profile, with_map=True)
        assert old == new and old_map == new_map, profile
        profiles[profile] = {'bytes': len(old), 'sha256': s.digest(old), 'mapIdentical': True}
    return {'kind': 'phase195-maintained-promotion', 'complete': True, 'baselineCommit': BASELINE,
            'applied': False, 'alreadySelected': states[0] == 'selected',
            'selectedSource': s.pin(selected), 'files': rows, 'otherProfiles': profiles,
            'method': s.pin(Path(__file__)), 'installedSelectionChanged': False}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true', help='Copy only after root qualification/measurement authorization')
    args = parser.parse_args()
    # Use the existing shared inode. No compiler or benchmark is run or nested.
    with (LIVE / 'build/phase32/execution.lock').open('r+') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        report = check()
        if args.apply and not report['alreadySelected']:
            for row in report['files']:
                destination = LIVE / row['file']
                destination.parent.mkdir(parents=True, exist_ok=True)
                temporary = destination.with_name(destination.name + '.phase195-copy')
                assert not temporary.exists()
                temporary.write_bytes((STAGE / row['file']).read_bytes())
                os.replace(temporary, destination)
            report = check()
            assert report['alreadySelected']
            report['applied'] = True
        if args.apply or report['alreadySelected']:
            assert s.maintained_assemble(LIVE / 'src/compiler.json', LIVE, 'x86') == (BUILD / 'selected-source02/compiler.bend').read_bytes()
        name = 'maintained-promotion01.json' if args.apply else 'maintained-promotion-plan01.json'
        s.dump(BUILD / name, report)
    print(json.dumps({'complete': True, 'applied': report['applied'], 'alreadySelected': report['alreadySelected'], 'report': str(BUILD / name)}))

if __name__ == '__main__':
    main()
