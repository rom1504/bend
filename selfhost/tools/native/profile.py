#!/usr/bin/env python3
"""Replay an exact native source profile; no compiler or program execution."""
import argparse, hashlib, json, os, tempfile, zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DEFAULT = HERE / 'profiles/phase98-comparison01/profile.json'


def pin(file):
    file = Path(file).resolve(strict=True); h = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024*1024), b''): h.update(chunk)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def check(record):
    file = (ROOT / record['file']).resolve()
    assert file.is_relative_to(ROOT)
    actual = pin(file)
    assert all(actual[k] == record[k] for k in ['sha256', 'bytes']), str(file)
    return actual


def identity(data, record):
    assert len(data) == record['bytes'] and hashlib.sha256(data).hexdigest() == record['sha256']


def exclusive(file, data):
    file = Path(file).resolve(); assert not file.exists()
    file.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=file.parent) as stream:
        stream.write(data); stream.flush(); os.link(stream.name, file)
    return pin(file)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', type=Path, default=DEFAULT)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--out-source', type=Path)
    group.add_argument('--verify-source', type=Path)
    parser.add_argument('--receipt', type=Path, required=True)
    args = parser.parse_args(); assert not args.receipt.exists()
    pp = pin(args.profile); profile = json.loads(Path(pp['file']).read_text())
    assert profile['kind'] == 'bend-native-exact-source-profile' and profile['version'] == 1
    inputs = [pp, pin(__file__)]
    for key in ['archive', 'manifest', 'receipt']:
        inputs.append(check(profile['baselineCapsule'][key]))
    manifest = json.loads(Path(inputs[-2]['file']).read_text())
    receipt = json.loads(Path(inputs[-1]['file']).read_text())
    capsule = profile['baselineCapsule']; source = profile['source']
    assert receipt['complete'] and receipt['archive'] == capsule['archive'] and receipt['manifest'] == capsule['manifest']
    assert manifest['complete'] and manifest['canonicalRoot'] == str(ROOT)
    rows = [row for row in manifest['files'] if row['file'] == source['file']]
    assert len(rows) == 1 and all(rows[0][k] == source[k] for k in ['file', 'sha256', 'bytes'])
    with zipfile.ZipFile(inputs[-3]['file']) as saved:
        assert saved.namelist().count(source['file']) == 1
        assert saved.getinfo(source['file']).file_size == source['bytes']
        original_bytes = saved.read(source['file'])
    identity(original_bytes, source)
    delta_pin = check(profile['delta']); inputs.append(delta_pin)
    with zipfile.ZipFile(delta_pin['file']) as saved:
        assert saved.namelist() == ['changes.json']
        assert saved.getinfo('changes.json').file_size == profile['deltaPayload']['bytes']
        payload = saved.read('changes.json')
    identity(payload, profile['deltaPayload']); changes = json.loads(payload)
    assert len(changes) == profile['changeCount']
    original = original_bytes.decode('utf-8'); text = original
    for row in changes:
        at, old, new = row['offset'], row['old'], row['new']
        assert isinstance(at, int) and 0 <= at <= len(text) and text[at:at+len(old)] == old
        text = text[:at] + new + text[at+len(old):]
    data = text.encode('utf-8'); identity(data, profile['candidate'])
    reverse = text
    for row in reversed(changes):
        at, old, new = row['offset'], row['old'], row['new']
        assert reverse[at:at+len(new)] == new
        reverse = reverse[:at] + old + reverse[at+len(new):]
    assert reverse == original
    assert len(text.splitlines()) - len(original.splitlines()) == profile['physicalLineDelta']
    if args.verify_source:
        candidate = pin(args.verify_source); identity(Path(candidate['file']).read_bytes(), profile['candidate'])
    else:
        candidate = exclusive(args.out_source, data)
    # Same-root source pin lets the admission collector independently replay it.
    origin = dict(file=str(ROOT/source['file']), sha256=source['sha256'], bytes=source['bytes'])
    if Path(origin['file']).exists(): assert pin(origin['file']) == origin
    for record in inputs: assert pin(record['file']) == record
    result = dict(kind='bend-native-exact-source-replay', version=1, complete=True, targetsRun=False,
        source=origin, candidate=candidate, method=pin(__file__), inputs=inputs, changes=changes,
        physicalLineDelta=profile['physicalLineDelta'], forwardReplayExact=True, inverseRecoversSource=True,
        scope='Source transport only; checked compilation, proof and native qualification remain separate.')
    rp = exclusive(args.receipt, (json.dumps(result, indent=2)+'\n').encode())
    print(json.dumps(dict(complete=True, targetsRun=False, candidate=candidate, receipt=rp)))


if __name__ == '__main__': main()
