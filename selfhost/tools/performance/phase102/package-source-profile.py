#!/usr/bin/env python3
"""Compose an experimental Phase102 source profile; only offline source replay."""
import argparse
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import subprocess
import sys
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PARENT = ROOT / 'selfhost/tools/native/profiles/phase98-comparison02/profile.json'
PARENT_SHA = '0044a9874982b3af9431dc95ea4d735d9d83435c23a513ef340f8ec517997d17'
REPLAY = ROOT / 'selfhost/tools/native/profile.py'
REPLAY_SHA = '0fd8774bf849223c2bdb409acc4ee9d74936c11dded7de46ffc8a18858721f9c'
spec = importlib.util.spec_from_file_location('phase102_source_profile', REPLAY)
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


def relative_pin(file):
    item = P.pin(file)
    item['file'] = str(Path(item['file']).relative_to(ROOT))
    return item


def data_pin(data):
    return dict(sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def changes_apply(text, changes, reverse=False):
    for row in reversed(changes) if reverse else changes:
        at, old, new = row['offset'], row['old'], row['new']
        assert type(at) is int and isinstance(old, str) and isinstance(new, str)
        if reverse: old, new = new, old
        assert 0 <= at <= len(text) and text[at:at + len(old)] == old
        text = text[:at] + new + text[at + len(old):]
    return text


def archive_bytes(payload):
    buffer = io.BytesIO()
    entry = zipfile.ZipInfo('changes.json', date_time=(1980, 1, 1, 0, 0, 0))
    entry.create_system = 3
    entry.external_attr = 0o100644 << 16
    entry.compress_type = zipfile.ZIP_DEFLATED
    with zipfile.ZipFile(buffer, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as saved:
        saved.writestr(entry, payload, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    return buffer.getvalue()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipe', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--verification-out', required=True, type=Path)
    parser.add_argument('--name', required=True)
    args = parser.parse_args()
    out, verification = args.out.resolve(), args.verification_out.resolve()
    assert re.fullmatch(r'phase102-[a-z0-9][a-z0-9-]*', args.name)
    assert out.is_relative_to(ROOT / 'selfhost/tools/native/profiles') or out.is_relative_to(ROOT / 'selfhost/build/phase102')
    assert verification.is_relative_to(ROOT / 'selfhost/build/phase102')
    assert not out.exists() and not verification.exists() and out != verification
    assert not verification.is_relative_to(out), 'keep full replay source outside compact profile directory'
    parent_pin, replay_pin = P.pin(PARENT), P.pin(REPLAY)
    assert parent_pin['sha256'] == PARENT_SHA and replay_pin['sha256'] == REPLAY_SHA
    parent = json.loads(PARENT.read_text())
    assert parent['kind'] == 'bend-native-exact-source-profile' and parent['version'] == 1
    recipe_pin = P.pin(args.recipe); recipe = json.loads(Path(recipe_pin['file']).read_text())
    assert recipe['complete'] and recipe['inverseExact']
    inputs = [P.pin(__file__), parent_pin, replay_pin, recipe_pin]
    for key in ('source', 'candidate'):
        actual = P.pin(recipe[key]['file']); assert actual == recipe[key]; inputs.append(actual)
    assert all(recipe['source'][key] == parent['candidate'][key] for key in ('sha256', 'bytes'))
    capsule = parent['baselineCapsule']
    for key in ('archive', 'manifest', 'receipt'): inputs.append(P.check(capsule[key]))
    manifest = json.loads((ROOT / capsule['manifest']['file']).read_text())
    receipt = json.loads((ROOT / capsule['receipt']['file']).read_text())
    assert receipt['complete'] and receipt['archive'] == capsule['archive'] and receipt['manifest'] == capsule['manifest']
    assert manifest['complete'] and manifest['canonicalRoot'] == str(ROOT)
    rows = [row for row in manifest['files'] if row['file'] == parent['source']['file']]
    assert len(rows) == 1 and all(rows[0][k] == parent['source'][k] for k in ('file', 'sha256', 'bytes'))
    with zipfile.ZipFile(ROOT / capsule['archive']['file']) as saved:
        assert saved.namelist().count(parent['source']['file']) == 1
        original_bytes = saved.read(parent['source']['file'])
    P.identity(original_bytes, parent['source'])
    inputs.append(P.check(parent['delta']))
    with zipfile.ZipFile(ROOT / parent['delta']['file']) as saved:
        assert saved.namelist() == ['changes.json']
        payload = saved.read('changes.json')
    P.identity(payload, parent['deltaPayload'])
    parent_changes = json.loads(payload); assert len(parent_changes) == parent['changeCount']
    original = original_bytes.decode('utf-8')
    middle = changes_apply(original, parent_changes)
    P.identity(middle.encode(), parent['candidate'])
    assert middle == Path(recipe['source']['file']).read_text()
    final = changes_apply(middle, recipe['changes'])
    P.identity(final.encode(), recipe['candidate'])
    assert final == Path(recipe['candidate']['file']).read_text()
    assert changes_apply(final, recipe['changes'], reverse=True) == middle
    changes = parent_changes + recipe['changes']
    assert changes_apply(original, changes) == final
    assert changes_apply(final, changes, reverse=True) == original
    payload = (json.dumps(changes, ensure_ascii=False, sort_keys=True, separators=(',', ':')) + '\n').encode()
    archive = archive_bytes(payload)
    assert archive_bytes(payload) == archive
    out.mkdir(parents=True); verification.mkdir(parents=True)
    (out / 'changes.zip').write_bytes(archive)
    profile = dict(kind=parent['kind'], version=1, profile=args.name,
        source=parent['source'], candidate=data_pin(final.encode()), baselineCapsule=capsule,
        delta=relative_pin(out / 'changes.zip'), deltaPayload=data_pin(payload),
        changeCount=len(changes), physicalLineDelta=len(final.splitlines()) - len(original.splitlines()),
        parentProfile=relative_pin(PARENT), parentDelta=parent['delta'],
        parentCandidate=parent['candidate'], originRecipe=relative_pin(args.recipe),
        packagingMethod=relative_pin(__file__), replayMethod=relative_pin(REPLAY),
        parentChangeCount=len(parent_changes), addedChangeCount=len(recipe['changes']),
        experimental=True, releaseQualified=False,
        scope='Exact Phase102 edits composed after the authenticated Phase98 comparison02 profile over '
              'the committed D04 baseline capsule. Experimental source transport only; no native release '
              'selection, checked-compilation, conformance or performance claim.')
    (out / 'profile.json').write_text(json.dumps(profile, indent=2) + '\n')
    # This is the existing unmodified source-only replayer, not a compiler target.
    replay = subprocess.run([sys.executable, '-B', str(REPLAY), '--profile', str(out / 'profile.json'),
        '--out-source', str(verification / 'compiler.bend'), '--receipt', str(verification / 'replay.json')],
        cwd=ROOT, capture_output=True, text=True)
    (verification / 'replay.stdout').write_text(replay.stdout)
    (verification / 'replay.stderr').write_text(replay.stderr)
    assert replay.returncode == 0, ('source-only replay failed; preserve outputs', verification)
    replayed = json.loads((verification / 'replay.json').read_text())
    assert replayed['complete'] and replayed['forwardReplayExact'] and replayed['inverseRecoversSource']
    assert (verification / 'compiler.bend').read_bytes() == Path(recipe['candidate']['file']).read_bytes()
    for item in inputs: assert P.pin(item['file']) == item
    result = dict(kind='phase102-source-profile-package', complete=True, targetsRun=False,
        experimental=True, releaseQualified=False, profile=P.pin(out / 'profile.json'),
        delta=P.pin(out / 'changes.zip'), replay=P.pin(verification / 'replay.json'),
        inputs=inputs, parentChanges=len(parent_changes), addedChanges=len(recipe['changes']),
        forwardReplayExact=True, inverseRecoversD04=True, deterministicArchive=True)
    (verification / 'packaging.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, profile=result['profile'],
                         delta=result['delta'], verification=str(verification / 'packaging.json'))))


if __name__ == '__main__': main()
